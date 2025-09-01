class_name DialogueSystem
extends CanvasLayer
## Main dialogue system controller handling all dialogue interactions

# Signals
signal dialogue_box_shown
signal dialogue_box_hidden
signal choice_presented(choices: Array)
signal typing_started
signal typing_completed

# Canvas layer configuration
const DIALOGUE_LAYER: int = 150  # Between fade (100) and HUD (200)

# Export properties
@export var typing_speed: float = 30.0
@export var auto_advance_delay: float = 2.0
@export var choice_timeout: float = 10.0

# Node references
@onready var dialogue_box: DialogueBox = $DialogueBox
var screenshot_manager: RefCounted

# Current dialogue state
var current_dialogue_id: String = ""
var current_speaker: String = ""
var current_text: String = ""
var current_choices: Array = []
var is_dialogue_active: bool = false
var is_waiting_for_input: bool = false
var is_showing_choices: bool = false

# Dialogue data structure for testing
var test_dialogue_data: Dictionary = {
	"test_intro": {
		"speaker": "Rando",
		"text": "This is a test dialogue line to verify the dialogue system is working properly.",
		"emotional_impact": {"rage": 0.0, "reservoir": 0.0},
		"choices": []
	},
	"test_choice": {
		"speaker": "Family Member",
		"text": "How are you feeling about being back home?",
		"emotional_impact": {"rage": 0.0, "reservoir": 0.0},
		"choices": [
			{
				"text": "I'm glad to be home.",
				"emotional_impact": {"rage": -5.0, "reservoir": 5.0},
				"next_dialogue": ""
			},
			{
				"text": "It's complicated...",
				"emotional_impact": {"rage": 2.0, "reservoir": -2.0},
				"next_dialogue": ""
			},
			{
				"text": "I don't want to talk about it.",
				"emotional_impact": {"rage": 5.0, "reservoir": -5.0},
				"next_dialogue": ""
			}
		]
	}
}

func _ready() -> void:
	# Set canvas layer
	layer = DIALOGUE_LAYER
	follow_viewport_enabled = false
	
	# Initialize screenshot manager (RefCounted, not Node)
	var ScreenshotManagerClass = load("res://testing/screenshot_manager.gd")
	if ScreenshotManagerClass:
		screenshot_manager = ScreenshotManagerClass.new()
	
	# Initialize dialogue system
	_initialize_dialogue_system()
	
	# Connect to EventBus signals
	_connect_signals()
	
	# Set initial state
	visible = false  # Hidden until dialogue starts
	is_dialogue_active = false
	
	# Set up debug controls
	if OS.is_debug_build():
		_setup_debug_controls()
		print("DialogueSystem initialized on layer ", layer)

func _initialize_dialogue_system() -> void:
	"""Initialize dialogue system components and state"""
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	
	# Ensure dialogue box is properly configured
	if dialogue_box:
		dialogue_box.visible = false
		dialogue_box.typing_completed.connect(_on_typing_completed)
		dialogue_box.choice_selected.connect(_on_choice_selected)
		
		# Configure text animation speed
		dialogue_box.set_typing_speed(typing_speed)

func _connect_signals() -> void:
	"""Connect to EventBus and other global signals"""
	# Listen for dialogue events
	EventBus.dialogue_started.connect(_on_dialogue_started)
	EventBus.dialogue_ended.connect(_on_dialogue_ended)
	
	# Connect to game state events
	EventBus.game_paused.connect(_on_game_paused)
	EventBus.game_resumed.connect(_on_game_resumed)
	
	if OS.is_debug_build():
		print("DialogueSystem: EventBus signals connected")

func _setup_debug_controls() -> void:
	"""Set up debug keyboard shortcuts for testing"""
	pass  # Debug controls will be handled in _input

func _input(event: InputEvent) -> void:
	# Handle dialogue advancement
	if is_dialogue_active and event.is_action_pressed("dialogue_advance"):
		_handle_dialogue_advance()
		get_viewport().set_input_as_handled()
	
	# Debug controls (only in debug builds)
	if OS.is_debug_build():
		if event.is_action_pressed("debug_toggle"):
			if event is InputEventKey and event.keycode == KEY_1:
				# F + 1: Test basic dialogue
				start_dialogue("test_intro")
				get_viewport().set_input_as_handled()
			elif event is InputEventKey and event.keycode == KEY_2:
				# F + 2: Test choice dialogue
				start_dialogue("test_choice")
				get_viewport().set_input_as_handled()
			elif event is InputEventKey and event.keycode == KEY_3:
				# F + 3: Take screenshot for testing
				take_screenshot("dialogue_test")
				get_viewport().set_input_as_handled()

func _handle_dialogue_advance() -> void:
	"""Handle input for advancing dialogue"""
	if not dialogue_box:
		return
	
	if dialogue_box.get_is_typing():
		# Skip typing animation
		dialogue_box.skip_typing()
	elif is_waiting_for_input and not is_showing_choices:
		# Advance to next line or end dialogue
		end_dialogue()
	# Note: Choice selection is handled by choice buttons directly

# Public API Methods

func start_dialogue(dialogue_id: String) -> void:
	"""Start a dialogue sequence"""
	if is_dialogue_active:
		print("DialogueSystem: Dialogue already active")
		return
	
	if not dialogue_id in test_dialogue_data:
		print("DialogueSystem: Dialogue ID not found: ", dialogue_id)
		return
	
	var dialogue_data = test_dialogue_data[dialogue_id]
	
	# Set dialogue state
	current_dialogue_id = dialogue_id
	current_speaker = dialogue_data.speaker
	current_text = dialogue_data.text
	current_choices = dialogue_data.get("choices", [])
	is_dialogue_active = true
	is_waiting_for_input = false
	is_showing_choices = false
	
	# Update game manager state
	if GameManager:
		GameManager.is_in_dialogue = true
	
	# Show dialogue system
	show_dialogue()
	
	# Emit signals
	EventBus.dialogue_started.emit(dialogue_id)
	dialogue_box_shown.emit()
	
	# Start displaying the dialogue
	_display_dialogue()
	
	# Take screenshot for testing
	if OS.is_debug_build():
		take_screenshot("dialogue_started_" + dialogue_id, ScreenshotManager.Category.AUTOMATED)
	
	if OS.is_debug_build():
		print("DialogueSystem: Started dialogue '", dialogue_id, "' with speaker: ", current_speaker)

func end_dialogue() -> void:
	"""End the current dialogue"""
	if not is_dialogue_active:
		return
	
	# Take screenshot before ending
	if OS.is_debug_build():
		take_screenshot("dialogue_ending_" + current_dialogue_id, ScreenshotManager.Category.AUTOMATED)
	
	# Reset state
	is_dialogue_active = false
	is_waiting_for_input = false
	is_showing_choices = false
	
	# Update game manager state
	if GameManager:
		GameManager.is_in_dialogue = false
	
	# Hide dialogue system
	hide_dialogue()
	
	# Emit signals
	EventBus.dialogue_ended.emit()
	dialogue_box_hidden.emit()
	
	# Clear current dialogue data
	current_dialogue_id = ""
	current_speaker = ""
	current_text = ""
	current_choices = []
	
	if OS.is_debug_build():
		print("DialogueSystem: Dialogue ended")

func show_dialogue() -> void:
	"""Show the dialogue interface"""
	# CRITICAL: Make the CanvasLayer visible first!
	visible = true
	
	# Force DialogueBox to be visible as well  
	if dialogue_box:
		dialogue_box.visible = true
		dialogue_box.modulate = Color.TRANSPARENT
		var fade_tween = create_tween()
		fade_tween.tween_property(dialogue_box, "modulate", Color.WHITE, 0.3)
	
	# Adjust HUD for dialogue mode
	_set_hud_dialogue_mode(true)
	
	if OS.is_debug_build():
		print("DialogueSystem: show_dialogue() - CanvasLayer visible: ", visible)

func hide_dialogue() -> void:
	"""Hide the dialogue interface"""
	# Fade out animation on dialogue box
	if dialogue_box:
		var fade_tween = create_tween()
		fade_tween.tween_property(dialogue_box, "modulate", Color.TRANSPARENT, 0.3)
		fade_tween.tween_callback(func(): visible = false)
	else:
		visible = false
	
	# Restore normal HUD mode
	_set_hud_dialogue_mode(false)

func _display_dialogue() -> void:
	"""Display the current dialogue text and choices"""
	if not dialogue_box:
		print("DialogueSystem: No dialogue box available")
		return
	
	# Show dialogue box
	dialogue_box.visible = true
	dialogue_box.show_dialogue(current_speaker, current_text)
	
	# Start typing animation
	typing_started.emit()
	
	# Apply emotional impact immediately
	_apply_emotional_impact()

func _apply_emotional_impact() -> void:
	"""Apply emotional impact from current dialogue"""
	if not GameManager or not GameManager.emotional_state:
		return
	
	var dialogue_data = test_dialogue_data[current_dialogue_id]
	var emotional_impact = dialogue_data.get("emotional_impact", {})
	
	for emotion in emotional_impact:
		var impact_value = emotional_impact[emotion]
		if impact_value != 0.0:
			match emotion:
				"rage":
					GameManager.emotional_state.rage_level += impact_value
				"reservoir":
					GameManager.emotional_state.reservoir_level += impact_value
	
	if OS.is_debug_build() and emotional_impact.size() > 0:
		print("DialogueSystem: Applied emotional impact: ", emotional_impact)

func _set_hud_dialogue_mode(is_dialogue_mode: bool) -> void:
	"""Adjust HUD appearance for dialogue mode"""
	var hud = get_tree().get_first_node_in_group("hud")
	if hud and hud.has_method("set_hud_mode"):
		if is_dialogue_mode:
			hud.set_hud_mode("dialogue")
		else:
			hud.set_hud_mode("normal")

# Signal Callbacks

func _on_dialogue_started(dialogue_id: String) -> void:
	"""Handle external dialogue start requests"""
	if dialogue_id != current_dialogue_id:
		start_dialogue(dialogue_id)

func _on_dialogue_ended() -> void:
	"""Handle external dialogue end requests"""
	end_dialogue()

func _on_typing_completed() -> void:
	"""Handle typing animation completion"""
	typing_completed.emit()
	
	if current_choices.size() > 0:
		# Show choices
		_show_choices()
	else:
		# Wait for input to continue
		is_waiting_for_input = true
		
		# Auto-advance if enabled
		if GameManager and GameManager.settings.get("auto_advance", false):
			await get_tree().create_timer(auto_advance_delay).timeout
			if is_waiting_for_input:  # Check if still waiting
				end_dialogue()

func _show_choices() -> void:
	"""Display dialogue choices"""
	is_showing_choices = true
	is_waiting_for_input = false
	
	if dialogue_box:
		dialogue_box.show_choices(current_choices)
	
	choice_presented.emit(current_choices)
	
	if OS.is_debug_build():
		print("DialogueSystem: Showing ", current_choices.size(), " choices")
		take_screenshot("dialogue_choices_" + current_dialogue_id, ScreenshotManager.Category.AUTOMATED)

func _on_choice_selected(choice_index: int) -> void:
	"""Handle choice selection"""
	if choice_index < 0 or choice_index >= current_choices.size():
		print("DialogueSystem: Invalid choice index: ", choice_index)
		return
	
	var selected_choice = current_choices[choice_index]
	
	# Apply choice emotional impact
	_apply_choice_impact(selected_choice)
	
	# Record choice in history
	if GameManager:
		GameManager.choice_history.append({
			"dialogue_id": current_dialogue_id,
			"choice_index": choice_index,
			"choice_text": selected_choice.text,
			"emotional_impact": selected_choice.get("emotional_impact", {}),
			"timestamp": Time.get_unix_time_from_system()
		})
	
	# Emit choice made signal
	EventBus.choice_made.emit({
		"dialogue_id": current_dialogue_id,
		"choice_index": choice_index,
		"choice_data": selected_choice
	})
	
	# Take screenshot of choice result
	if OS.is_debug_build():
		take_screenshot("choice_selected_" + current_dialogue_id, ScreenshotManager.Category.AUTOMATED)
	
	# End dialogue or continue to next
	var next_dialogue = selected_choice.get("next_dialogue", "")
	if next_dialogue != "":
		# Continue to next dialogue
		end_dialogue()
		start_dialogue(next_dialogue)
	else:
		# End current dialogue
		end_dialogue()
	
	if OS.is_debug_build():
		print("DialogueSystem: Choice selected - ", selected_choice.text)

func _apply_choice_impact(choice_data: Dictionary) -> void:
	"""Apply emotional impact from selected choice"""
	if not GameManager or not GameManager.emotional_state:
		return
	
	var emotional_impact = choice_data.get("emotional_impact", {})
	
	for emotion in emotional_impact:
		var impact_value = emotional_impact[emotion]
		if impact_value != 0.0:
			match emotion:
				"rage":
					GameManager.emotional_state.rage_level += impact_value
				"reservoir":
					GameManager.emotional_state.reservoir_level += impact_value
	
	if OS.is_debug_build() and emotional_impact.size() > 0:
		print("DialogueSystem: Applied choice impact: ", emotional_impact)

func _on_game_paused() -> void:
	"""Handle game pause"""
	if is_dialogue_active:
		# Pause dialogue animations
		if dialogue_box:
			dialogue_box.pause_animations()

func _on_game_resumed() -> void:
	"""Handle game resume"""
	if is_dialogue_active:
		# Resume dialogue animations
		if dialogue_box:
			dialogue_box.resume_animations()

# Screenshot Integration

func take_screenshot(filename: String, category = ScreenshotManager.Category.WORKING) -> String:
	"""Take screenshot for testing purposes"""
	if screenshot_manager:
		return ScreenshotManager.take_screenshot(filename, category)
	
	# Fallback to simple screenshot
	var viewport = get_viewport()
	if not viewport:
		return ""
	
	var image = viewport.get_texture().get_image()
	if not image:
		return ""
	
	var timestamp = Time.get_datetime_string_from_system().replace(":", "-").replace(" ", "_")
	var full_filename = "dialogue_" + filename + "_" + timestamp + ".png"
	var path = "res://testing/screenshots/current/working/" + full_filename
	
	image.save_png(path)
	print("DialogueSystem: Screenshot saved - ", path)
	return path

# Utility Methods

func get_dialogue_active() -> bool:
	"""Check if dialogue is currently active"""
	return is_dialogue_active

func get_current_speaker() -> String:
	"""Get the current speaker name"""
	return current_speaker

func get_current_dialogue_id() -> String:
	"""Get the current dialogue ID"""
	return current_dialogue_id

func set_typing_speed(speed: float) -> void:
	"""Set typing animation speed"""
	typing_speed = max(1.0, speed)
	if dialogue_box:
		dialogue_box.set_typing_speed(typing_speed)

func skip_current_typing() -> void:
	"""Skip current typing animation"""
	if dialogue_box and dialogue_box.get_is_typing():
		dialogue_box.skip_typing()

# Debug Methods (only available in debug builds)

func _get_debug_info() -> Dictionary:
	"""Get debug information about dialogue system state"""
	return {
		"is_active": is_dialogue_active,
		"current_dialogue": current_dialogue_id,
		"current_speaker": current_speaker,
		"waiting_for_input": is_waiting_for_input,
		"showing_choices": is_showing_choices,
		"layer": layer,
		"visible": visible
	}

func debug_print_state() -> void:
	"""Print current dialogue system state (debug only)"""
	if OS.is_debug_build():
		print("DialogueSystem Debug State: ", _get_debug_info())
