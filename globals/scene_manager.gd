extends Node
## Handles scene transitions and loading

var current_scene: Node
var scene_stack: Array[String] = []
var is_transitioning: bool = false

# Scene paths mapping
const SCENES = {
	"main_menu": "res://src/scenes/main_menu.tscn",
	"airport_montage": "res://src/scenes/day1/airport_montage/montage_controller.tscn",
	"parking_garage": "res://src/scenes/day1/parking_garage/parking_garage.tscn",
	"car_drive": "res://src/scenes/day1/car_drive/car_drive.tscn",
	"family_home": "res://src/scenes/day1/family_home/home_arrival.tscn",
	"test_scene": "res://src/scenes/shared/test_scene.tscn"
}

# Transition types
enum TransitionType {
	NONE,
	FADE_BLACK,
	FADE_WHITE,
	CROSSFADE,
	SLIDE_LEFT,
	SLIDE_RIGHT
}

# References to transition scenes (will be created when needed)
var fade_transition_scene: PackedScene
var current_transition: Node

func _ready():
	# Set as singleton
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	# Get reference to current scene
	var root = get_tree().root
	current_scene = root.get_child(root.get_child_count() - 1)
	
	# Connect to scene request events
	EventBus.scene_transition_requested.connect(_on_scene_transition_requested)
	
	if OS.is_debug_build():
		print("SceneManager initialized")

func change_scene(scene_key: String, transition: TransitionType = TransitionType.FADE_BLACK):
	if is_transitioning:
		print("Already transitioning, ignoring request")
		return
		
	if not scene_key in SCENES:
		push_error("Scene key not found: " + scene_key)
		return
	
	var scene_path = SCENES[scene_key]
	
	# Update game manager
	GameManager.current_phase = scene_key
	
	if transition != TransitionType.NONE:
		await _transition_to_scene(scene_path, transition)
	else:
		_load_scene_immediate(scene_path)
	
	# Notify systems
	EventBus.scene_loaded.emit(scene_key)

func change_scene_to_path(scene_path: String, transition: TransitionType = TransitionType.FADE_BLACK):
	if is_transitioning:
		print("Already transitioning, ignoring request")
		return
		
	if not ResourceLoader.exists(scene_path):
		push_error("Scene path not found: " + scene_path)
		return
	
	if transition != TransitionType.NONE:
		await _transition_to_scene(scene_path, transition)
	else:
		_load_scene_immediate(scene_path)
	
	# Notify systems
	EventBus.scene_loaded.emit(scene_path.get_file().get_basename())

func _transition_to_scene(scene_path: String, transition: TransitionType):
	is_transitioning = true
	
	# Create transition overlay
	var transition_node = await _create_transition(transition)
	if transition_node:
		get_tree().root.add_child(transition_node)
		
		# Fade in transition
		if transition_node.has_method("fade_in"):
			await transition_node.fade_in()
	
	# Load new scene
	_load_scene_immediate(scene_path)
	
	# Fade out transition
	if transition_node and transition_node.has_method("fade_out"):
		await transition_node.fade_out()
		transition_node.queue_free()
	
	is_transitioning = false

func _load_scene_immediate(scene_path: String):
	# Free current scene
	if current_scene:
		current_scene.queue_free()
		await current_scene.tree_exited
	
	# Load new scene
	var new_scene_resource = load(scene_path)
	if new_scene_resource:
		current_scene = new_scene_resource.instantiate()
		get_tree().root.add_child(current_scene)
		get_tree().current_scene = current_scene
		scene_stack.append(scene_path)
		
		if OS.is_debug_build():
			print("Scene loaded: ", scene_path)
	else:
		push_error("Failed to load scene: " + scene_path)

func _create_transition(transition_type: TransitionType) -> Node:
	# For now, create a simple fade transition
	# Later we'll create proper transition scenes
	var canvas = CanvasLayer.new()
	var rect = ColorRect.new()
	rect.color = Color.BLACK if transition_type == TransitionType.FADE_BLACK else Color.WHITE
	rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	rect.modulate.a = 0.0
	canvas.add_child(rect)
	
	# Add fade methods
	canvas.set_script(load("res://globals/transition_helper.gd") if ResourceLoader.exists("res://globals/transition_helper.gd") else null)
	
	# If script doesn't exist, add basic fade functionality
	if not canvas.has_method("fade_in"):
		canvas.set_meta("rect", rect)
		canvas.set_script(null)  # Clear any failed script
		
		# Create inline fade functions
		var fade_in_func = func():
			var tween = canvas.create_tween()
			tween.tween_property(rect, "modulate:a", 1.0, 0.5)
			await tween.finished
		
		var fade_out_func = func():
			var tween = canvas.create_tween()
			tween.tween_property(rect, "modulate:a", 0.0, 0.5)
			await tween.finished
		
		canvas.set_meta("fade_in", fade_in_func)
		canvas.set_meta("fade_out", fade_out_func)
		
		# Make methods callable
		canvas.fade_in = canvas.get_meta("fade_in")
		canvas.fade_out = canvas.get_meta("fade_out")
	
	return canvas

func _on_scene_transition_requested(scene_key: String):
	change_scene(scene_key)

func reload_current_scene():
	if scene_stack.size() > 0:
		var current_path = scene_stack[-1]
		change_scene_to_path(current_path, TransitionType.NONE)

func go_back():
	if scene_stack.size() > 1:
		scene_stack.pop_back()  # Remove current
		var previous_path = scene_stack.pop_back()  # Get previous
		change_scene_to_path(previous_path)

func get_current_scene_name() -> String:
	if scene_stack.size() > 0:
		return scene_stack[-1].get_file().get_basename()
	return ""