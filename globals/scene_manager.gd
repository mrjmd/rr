extends Node
## Handles scene transitions and loading

var current_scene: Node
var scene_stack: Array[String] = []
var is_transitioning: bool = false

# Scene paths mapping
const SCENES = {
	"main_menu": "res://src/scenes/ui/menus/main_menu_simple.tscn",
	"kitchen": "res://src/scenes/poc/kitchen.tscn",
	"airport_montage": "res://src/scenes/day1/airport_montage/montage_controller.tscn",
	"parking_garage": "res://src/scenes/day1/parking_garage/parking_garage.tscn",
	"car_drive": "res://src/scenes/day1/car_drive/car_drive.tscn",
	"family_home": "res://src/scenes/day1/family_home/home_arrival.tscn",
	"test_scene": "res://src/scenes/shared/simple_test_scene.tscn",
	"transition_demo": "res://src/scenes/shared/transition_demo.tscn"
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

# References to transition scenes
var fade_transition_scene: PackedScene
var current_transition: Node

func _ready():
	# Set as singleton
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	# Load fade transition scene
	fade_transition_scene = preload("res://src/scenes/transitions/fade_transition.tscn")
	
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
	
	# Create and setup transition overlay
	var transition_node = _create_transition(transition)
	if transition_node:
		get_tree().root.add_child(transition_node)
		current_transition = transition_node
		
		# Fade in transition (hide current scene)
		await transition_node.fade_in()
		
		# Load new scene while screen is black
		_load_scene_immediate(scene_path)
		
		# Fade out transition (reveal new scene)
		await transition_node.fade_out()
		
		# Clean up
		transition_node.queue_free()
		current_transition = null
	
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
	# Create proper fade transition from scene
	if not fade_transition_scene:
		push_error("FadeTransition scene not loaded!")
		return null
	
	var transition = fade_transition_scene.instantiate()
	
	# Configure transition based on type
	match transition_type:
		TransitionType.FADE_BLACK:
			transition.set_fade_color(Color.BLACK)
		TransitionType.FADE_WHITE:
			transition.set_fade_color(Color.WHITE)
		_:
			transition.set_fade_color(Color.BLACK)  # Default to black
	
	return transition

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

## New transition methods using the FadeTransition system

## Transition to a scene using scene key with fade effect
func transition_to_scene(scene_key: String, fade_duration: float = 0.5) -> void:
	if is_transitioning:
		print("Already transitioning, ignoring request")
		return
		
	if not scene_key in SCENES:
		push_error("Scene key not found: " + scene_key)
		return
	
	var scene_path = SCENES[scene_key]
	
	# Update game manager
	GameManager.current_phase = scene_key
	
	await _transition_with_fade(scene_path, fade_duration)
	
	# Notify systems
	EventBus.scene_loaded.emit(scene_key)

## Transition to a scene using direct path with fade effect
func transition_to_packed(packed_scene: PackedScene, fade_duration: float = 0.5) -> void:
	if is_transitioning:
		print("Already transitioning, ignoring request")
		return
		
	if not packed_scene:
		push_error("PackedScene is null!")
		return
	
	await _transition_with_packed_scene(packed_scene, fade_duration)
	
	# Notify systems
	var scene_name = "packed_scene"  # Generic name for packed scenes
	EventBus.scene_loaded.emit(scene_name)

## Internal method to handle fade transition with scene path
func _transition_with_fade(scene_path: String, fade_duration: float) -> void:
	is_transitioning = true
	
	# Create fade transition
	var transition = _create_transition(TransitionType.FADE_BLACK)
	if transition:
		transition.set_fade_duration(fade_duration)
		get_tree().root.add_child(transition)
		current_transition = transition
		
		# Fade in (hide current scene)
		await transition.fade_in()
		
		# Load new scene while screen is black
		_load_scene_immediate(scene_path)
		
		# Fade out (reveal new scene)
		await transition.fade_out()
		
		# Clean up
		transition.queue_free()
		current_transition = null
	
	is_transitioning = false

## Internal method to handle fade transition with packed scene
func _transition_with_packed_scene(packed_scene: PackedScene, fade_duration: float) -> void:
	is_transitioning = true
	
	# Create fade transition
	var transition = _create_transition(TransitionType.FADE_BLACK)
	if transition:
		transition.set_fade_duration(fade_duration)
		get_tree().root.add_child(transition)
		current_transition = transition
		
		# Fade in (hide current scene)
		await transition.fade_in()
		
		# Load new scene while screen is black
		_load_packed_scene_immediate(packed_scene)
		
		# Fade out (reveal new scene)
		await transition.fade_out()
		
		# Clean up
		transition.queue_free()
		current_transition = null
	
	is_transitioning = false

## Load a packed scene immediately without transition
func _load_packed_scene_immediate(packed_scene: PackedScene) -> void:
	# Free current scene
	if current_scene:
		current_scene.queue_free()
		await current_scene.tree_exited
	
	# Instantiate new scene
	current_scene = packed_scene.instantiate()
	if current_scene:
		get_tree().root.add_child(current_scene)
		get_tree().current_scene = current_scene
		
		# Add to stack with generic name
		scene_stack.append("packed_scene")
		
		if OS.is_debug_build():
			print("Packed scene loaded")
	else:
		push_error("Failed to instantiate packed scene")