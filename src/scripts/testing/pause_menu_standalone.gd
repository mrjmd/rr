class_name PauseMenuStandalone
extends Control
## Standalone test scene for pause menu functionality without EventBus dependency

# UI references
@onready var title_label: Label = $CenterContainer/VBoxContainer/TitleLabel
@onready var instruction_label: Label = $CenterContainer/VBoxContainer/InstructionLabel
@onready var status_label: Label = $CenterContainer/VBoxContainer/StatusLabel
@onready var pause_menu = $PauseMenu

# Test state
var test_timer: float = 0.0
var is_running: bool = true

func _ready() -> void:
	"""Initialize the standalone test"""
	_setup_ui()
	_setup_input_map()
	
	if OS.is_debug_build():
		print("PauseMenuStandalone initialized - EventBus independent test")

func _setup_ui() -> void:
	"""Configure UI elements with proper styling"""
	if title_label:
		title_label.add_theme_font_size_override("font_size", 28)
		title_label.add_theme_color_override("font_color", Color.WHITE)
	
	if instruction_label:
		instruction_label.add_theme_font_size_override("font_size", 16)
		instruction_label.add_theme_color_override("font_color", Color(0.9, 0.9, 1.0))
	
	if status_label:
		status_label.add_theme_font_size_override("font_size", 14)
		status_label.add_theme_color_override("font_color", Color(0.8, 1.0, 0.8))

func _setup_input_map() -> void:
	"""Ensure required input actions exist for testing"""
	if not InputMap.has_action("pause_menu"):
		InputMap.add_action("pause_menu")
		var escape_event := InputEventKey.new()
		escape_event.keycode = KEY_ESCAPE
		var p_event := InputEventKey.new()
		p_event.keycode = KEY_P
		InputMap.action_add_event("pause_menu", escape_event)
		InputMap.action_add_event("pause_menu", p_event)
		
		if OS.is_debug_build():
			print("Created pause_menu input action with ESC and P keys")

func _process(delta: float) -> void:
	"""Update test timer and status display"""
	if is_running and not get_tree().paused:
		test_timer += delta
	
	_update_status_display()

func _update_status_display() -> void:
	"""Update the status label with current information"""
	if not status_label:
		return
	
	var status_text: String = ""
	
	if get_tree().paused:
		if pause_menu and pause_menu.is_open():
			status_text = "Status: PAUSED (Menu Open) - Timer: %.2f s" % test_timer
		else:
			status_text = "Status: PAUSED (External) - Timer: %.2f s" % test_timer
	else:
		status_text = "Status: Running - Timer: %.2f s" % test_timer
	
	status_label.text = status_text

func _input(event: InputEvent) -> void:
	"""Handle test-specific input"""
	# Debug info toggle
	if event.is_action_pressed("ui_accept") and OS.is_debug_build():
		_print_debug_info()
	
	# Reset test
	if event.is_action_pressed("ui_home"):
		reset_test()

func _print_debug_info() -> void:
	"""Print current test state for debugging"""
	if not OS.is_debug_build():
		return
	
	print("=== Pause Menu Standalone Debug Info ===")
	print("Test Timer: %.2f", test_timer)
	print("Tree Paused: ", get_tree().paused)
	print("Test Running: ", is_running)
	print("EventBus Available: ", get_node_or_null("/root/EventBus") != null)
	
	if pause_menu:
		print("Pause Menu Open: ", pause_menu.is_open())
		print("Pause Menu Visible: ", pause_menu.visible)
	else:
		print("Pause Menu: Not found!")
	
	print("=== End Debug Info ===")

# Public API for testing

func reset_test() -> void:
	"""Reset the test to initial state"""
	test_timer = 0.0
	is_running = true
	
	# Close pause menu if open
	if pause_menu and pause_menu.is_open():
		pause_menu.hide_menu()
	
	if OS.is_debug_build():
		print("Test reset")

func get_test_state() -> Dictionary:
	"""Get current test state for verification"""
	return {
		"timer": test_timer,
		"is_running": is_running,
		"tree_paused": get_tree().paused,
		"pause_menu_open": pause_menu.is_open() if pause_menu else false,
		"pause_menu_visible": pause_menu.visible if pause_menu else false,
		"eventbus_available": get_node_or_null("/root/EventBus") != null
	}

func take_test_screenshot() -> void:
	"""Trigger screenshot capture for visual verification"""
	if OS.is_debug_build():
		print("Test screenshot requested - use external capture script")