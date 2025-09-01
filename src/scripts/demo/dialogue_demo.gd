class_name DialogueDemo
extends Control
## Demo scene for testing dialogue system functionality

# Node references
@onready var dialogue_system: DialogueSystem = $DialogueSystem
@onready var character_portrait_left: CharacterPortrait = $CharacterPortraitLeft
@onready var character_portrait_right: CharacterPortrait = $CharacterPortraitRight
@onready var demo_ui: Control = $DemoUI
@onready var instructions_label: Label = $DemoUI/InstructionsPanel/VBoxContainer/InstructionsLabel
@onready var status_label: Label = $DemoUI/StatusPanel/StatusLabel

# Demo state
var demo_running: bool = false
var current_demo_step: int = 0

func _ready() -> void:
	# Set up demo environment
	_setup_demo_environment()
	
	# Connect dialogue system signals
	_connect_dialogue_signals()
	
	# Set up character portraits
	_setup_character_portraits()
	
	# Update UI
	_update_instructions()
	_update_status("Ready - Press keys to test dialogue system")
	
	if OS.is_debug_build():
		print("DialogueDemo: Demo scene initialized")

func _setup_demo_environment() -> void:
	"""Configure demo environment"""
	# Set background color
	var background = ColorRect.new()
	background.color = Color(0.1, 0.15, 0.2, 1.0)
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(background)
	move_child(background, 0)  # Move to back
	
	# Ensure proper layer ordering
	move_child(dialogue_system, get_child_count() - 1)

func _connect_dialogue_signals() -> void:
	"""Connect to dialogue system signals"""
	if dialogue_system:
		dialogue_system.dialogue_box_shown.connect(_on_dialogue_shown)
		dialogue_system.dialogue_box_hidden.connect(_on_dialogue_hidden)
		dialogue_system.typing_completed.connect(_on_typing_completed)
		dialogue_system.choice_presented.connect(_on_choices_presented)
	
	# Connect to EventBus for demonstration
	EventBus.dialogue_started.connect(_on_dialogue_started)
	EventBus.dialogue_ended.connect(_on_dialogue_ended)
	EventBus.choice_made.connect(_on_choice_made)

func _setup_character_portraits() -> void:
	"""Configure character portraits for demo"""
	if character_portrait_left:
		character_portrait_left.set_portrait_position(CharacterPortrait.PortraitPosition.LEFT)
		character_portrait_left.set_show_name(true)
	
	if character_portrait_right:
		character_portrait_right.set_portrait_position(CharacterPortrait.PortraitPosition.RIGHT)
		character_portrait_right.set_show_name(true)

func _input(event: InputEvent) -> void:
	"""Handle demo input controls"""
	if event.is_action_pressed("ui_accept"):  # Enter key
		_start_guided_demo()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_cancel"):  # Escape key
		_reset_demo()
		get_viewport().set_input_as_handled()
	
	# Number keys for specific tests
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_1:
				_test_basic_dialogue()
			KEY_2:
				_test_choice_dialogue()
			KEY_3:
				_test_character_portraits()
			KEY_4:
				_test_emotional_impact()
			KEY_5:
				_take_demo_screenshot()
			KEY_R:
				_reset_demo()
			KEY_H:
				_toggle_instructions()

# Test Methods

func _start_guided_demo() -> void:
	"""Start guided demonstration"""
	if demo_running:
		return
	
	demo_running = true
	current_demo_step = 0
	_update_status("Starting guided demo...")
	
	# Step 1: Show character portraits
	_update_status("Step 1: Character portraits")
	character_portrait_left.show_portrait("Rando", true)
	await character_portrait_left.animation_completed
	
	character_portrait_right.show_portrait("Family Member", true)
	await character_portrait_right.animation_completed
	
	await get_tree().create_timer(1.0).timeout
	
	# Step 2: Basic dialogue
	_update_status("Step 2: Basic dialogue")
	dialogue_system.start_dialogue("test_intro")
	await EventBus.dialogue_ended
	
	await get_tree().create_timer(1.0).timeout
	
	# Step 3: Choice dialogue
	_update_status("Step 3: Choice dialogue with emotional impact")
	dialogue_system.start_dialogue("test_choice")
	await EventBus.dialogue_ended
	
	await get_tree().create_timer(1.0).timeout
	
	# Step 4: Hide portraits
	_update_status("Step 4: Hiding portraits")
	character_portrait_left.hide_portrait(true)
	character_portrait_right.hide_portrait(true)
	await character_portrait_left.animation_completed
	
	demo_running = false
	_update_status("Guided demo completed! Press keys for manual tests.")

func _test_basic_dialogue() -> void:
	"""Test basic dialogue without choices"""
	_update_status("Testing: Basic dialogue")
	if character_portrait_left:
		character_portrait_left.show_portrait("Rando", true)
	dialogue_system.start_dialogue("test_intro")

func _test_choice_dialogue() -> void:
	"""Test dialogue with choices"""
	_update_status("Testing: Choice dialogue")
	if character_portrait_right:
		character_portrait_right.show_portrait("Family Member", true)
	dialogue_system.start_dialogue("test_choice")

func _test_character_portraits() -> void:
	"""Test character portrait system"""
	_update_status("Testing: Character portraits")
	
	# Show left portrait
	character_portrait_left.show_portrait("Rando", true)
	await get_tree().create_timer(1.5).timeout
	
	# Show right portrait
	character_portrait_right.show_portrait("Family Member", true)
	await get_tree().create_timer(1.5).timeout
	
	# Test emotional reactions
	character_portrait_left.emotional_reaction("happy")
	await get_tree().create_timer(1.0).timeout
	
	character_portrait_right.emotional_reaction("angry")
	await get_tree().create_timer(1.0).timeout
	
	# Hide portraits
	character_portrait_left.hide_portrait(true)
	character_portrait_right.hide_portrait(true)
	
	_update_status("Portrait test completed")

func _test_emotional_impact() -> void:
	"""Test emotional impact system"""
	_update_status("Testing: Emotional impact")
	
	if not GameManager or not GameManager.emotional_state:
		_update_status("Error: GameManager or emotional_state not available")
		return
	
	# Show current emotional state
	var rage = GameManager.emotional_state.rage_level
	var reservoir = GameManager.emotional_state.reservoir_level
	_update_status("Before - Rage: %.1f, Reservoir: %.1f" % [rage, reservoir])
	
	# Start choice dialogue to test impact
	dialogue_system.start_dialogue("test_choice")

func _take_demo_screenshot() -> void:
	"""Take screenshot for testing"""
	_update_status("Taking screenshot...")
	
	# Ensure dialogue is visible for screenshot
	if not dialogue_system.get_dialogue_active():
		dialogue_system.start_dialogue("test_intro")
		await dialogue_system.typing_completed
	
	var screenshot_path = dialogue_system.take_screenshot("demo_test", "session")
	_update_status("Screenshot saved: " + screenshot_path)

func _reset_demo() -> void:
	"""Reset demo to initial state"""
	demo_running = false
	current_demo_step = 0
	
	# End any active dialogue
	if dialogue_system and dialogue_system.get_dialogue_active():
		dialogue_system.end_dialogue()
	
	# Hide portraits
	if character_portrait_left and character_portrait_left.is_portrait_visible():
		character_portrait_left.hide_portrait(false)
	if character_portrait_right and character_portrait_right.is_portrait_visible():
		character_portrait_right.hide_portrait(false)
	
	# Reset emotional state
	if GameManager and GameManager.emotional_state:
		GameManager.emotional_state.rage_level = 0.0
		GameManager.emotional_state.reservoir_level = 0.0
		GameManager.emotional_state.overwhelm_level = 0.0
	
	_update_status("Demo reset - Press keys to test dialogue system")

func _toggle_instructions() -> void:
	"""Toggle instructions panel visibility"""
	if demo_ui:
		demo_ui.visible = !demo_ui.visible

# UI Update Methods

func _update_instructions() -> void:
	"""Update instructions display"""
	if instructions_label:
		instructions_label.text = """DIALOGUE SYSTEM DEMO

CONTROLS:
ENTER - Start guided demo
ESC / R - Reset demo
H - Toggle this help

MANUAL TESTS:
1 - Basic dialogue
2 - Choice dialogue  
3 - Character portraits
4 - Emotional impact
5 - Take screenshot

DIALOGUE CONTROLS:
SPACE - Advance dialogue
CLICK - Advance dialogue
SELECT - Choose option"""

func _update_status(message: String) -> void:
	"""Update status display"""
	if status_label:
		status_label.text = message
	
	if OS.is_debug_build():
		print("DialogueDemo: ", message)

# Signal Callbacks

func _on_dialogue_shown() -> void:
	"""Handle dialogue system shown"""
	_update_status("Dialogue system shown")

func _on_dialogue_hidden() -> void:
	"""Handle dialogue system hidden"""
	_update_status("Dialogue system hidden")

func _on_typing_completed() -> void:
	"""Handle typing animation completed"""
	_update_status("Typing completed - Press SPACE to continue")

func _on_choices_presented(choices: Array) -> void:
	"""Handle choices presented"""
	_update_status("Choices presented (" + str(choices.size()) + " options)")

func _on_dialogue_started(dialogue_id: String) -> void:
	"""Handle dialogue started via EventBus"""
	_update_status("Dialogue started: " + dialogue_id)

func _on_dialogue_ended() -> void:
	"""Handle dialogue ended via EventBus"""
	_update_status("Dialogue ended")
	
	# Show updated emotional state if available
	if GameManager and GameManager.emotional_state:
		var rage = GameManager.emotional_state.rage_level
		var reservoir = GameManager.emotional_state.reservoir_level
		_update_status("After - Rage: %.1f, Reservoir: %.1f" % [rage, reservoir])

func _on_choice_made(choice_data: Dictionary) -> void:
	"""Handle choice made via EventBus"""
	var choice_text = choice_data.get("choice_data", {}).get("text", "Unknown")
	_update_status("Choice made: " + choice_text)

# Debug Methods

func _get_demo_info() -> Dictionary:
	"""Get debug information about demo state"""
	return {
		"demo_running": demo_running,
		"current_step": current_demo_step,
		"dialogue_active": dialogue_system.get_dialogue_active() if dialogue_system else false,
		"left_portrait_visible": character_portrait_left.is_portrait_visible() if character_portrait_left else false,
		"right_portrait_visible": character_portrait_right.is_portrait_visible() if character_portrait_right else false
	}

func debug_print_state() -> void:
	"""Print current demo state (debug only)"""
	if OS.is_debug_build():
		print("DialogueDemo Debug State: ", _get_demo_info())