class_name MenuNavigationDemo
extends Control
## Demo scene for testing the MenuManager navigation system

# UI References
@onready var open_main_menu_btn: Button = $DemoUI/DemoControls/ButtonsContainer/OpenMainMenuBtn
@onready var open_pause_menu_btn: Button = $DemoUI/DemoControls/ButtonsContainer/OpenPauseMenuBtn
@onready var open_settings_btn: Button = $DemoUI/DemoControls/ButtonsContainer/OpenSettingsBtn
@onready var close_all_btn: Button = $DemoUI/DemoControls/ButtonsContainer/CloseAllBtn

# Info Labels
@onready var current_menu_label: Label = $DemoUI/DemoControls/InfoContainer/CurrentMenuLabel
@onready var stack_size_label: Label = $DemoUI/DemoControls/InfoContainer/StackSizeLabel
@onready var is_transitioning_label: Label = $DemoUI/DemoControls/InfoContainer/IsTransitioningLabel

# Menu instances
@onready var main_menu: Node = $MainMenu
@onready var pause_menu: Node = $PauseMenu
@onready var settings_menu: Node = $SettingsMenu
@onready var fade_transition: Node = $FadeTransition

# Update timer
var update_timer: Timer

func _ready() -> void:
	print("MenuNavigationDemo: Starting...")
	
	# Wait for singletons to be ready
	await get_tree().process_frame
	
	# Connect buttons
	_connect_buttons()
	
	# Setup update timer for info display
	_setup_update_timer()
	
	# Ensure MenuManager is available
	if MenuManager:
		_connect_menu_manager_signals()
		print("MenuNavigationDemo: MenuManager connected")
	else:
		print("ERROR: MenuManager not available!")
	
	# Initial info update
	_update_info_labels()
	
	print("MenuNavigationDemo: Ready")

func _connect_buttons() -> void:
	"""Connect demo control buttons"""
	if open_main_menu_btn:
		open_main_menu_btn.pressed.connect(_on_open_main_menu_pressed)
	
	if open_pause_menu_btn:
		open_pause_menu_btn.pressed.connect(_on_open_pause_menu_pressed)
	
	if open_settings_btn:
		open_settings_btn.pressed.connect(_on_open_settings_pressed)
	
	if close_all_btn:
		close_all_btn.pressed.connect(_on_close_all_pressed)
	
	print("MenuNavigationDemo: Buttons connected")

func _setup_update_timer() -> void:
	"""Setup timer for updating info labels"""
	update_timer = Timer.new()
	update_timer.wait_time = 0.1  # Update 10 times per second
	update_timer.timeout.connect(_update_info_labels)
	add_child(update_timer)
	update_timer.start()

func _connect_menu_manager_signals() -> void:
	"""Connect to MenuManager signals for demo info"""
	if not MenuManager:
		return
	
	MenuManager.menu_opened.connect(_on_menu_opened)
	MenuManager.menu_closed.connect(_on_menu_closed)
	MenuManager.menu_stack_changed.connect(_on_menu_stack_changed)
	MenuManager.transition_started.connect(_on_transition_started)
	MenuManager.transition_completed.connect(_on_transition_completed)

# Button Handlers

func _on_open_main_menu_pressed() -> void:
	"""Open main menu via MenuManager"""
	if MenuManager:
		print("MenuNavigationDemo: Opening main menu")
		MenuManager.open_menu("main_menu", true)

func _on_open_pause_menu_pressed() -> void:
	"""Open pause menu via MenuManager"""
	if MenuManager:
		print("MenuNavigationDemo: Opening pause menu")
		MenuManager.open_menu("pause_menu", true)

func _on_open_settings_pressed() -> void:
	"""Open settings menu via MenuManager"""
	if MenuManager:
		print("MenuNavigationDemo: Opening settings menu")
		MenuManager.open_menu("settings_menu", true)

func _on_close_all_pressed() -> void:
	"""Close all menus via MenuManager"""
	if MenuManager:
		print("MenuNavigationDemo: Closing all menus")
		MenuManager.close_all_menus(true)

# MenuManager Signal Handlers

func _on_menu_opened(menu_name: String) -> void:
	"""Handle menu opened signal"""
	print("MenuNavigationDemo: Menu opened - ", menu_name)
	_update_info_labels()

func _on_menu_closed(menu_name: String) -> void:
	"""Handle menu closed signal"""
	print("MenuNavigationDemo: Menu closed - ", menu_name)
	_update_info_labels()

func _on_menu_stack_changed(stack_size: int) -> void:
	"""Handle menu stack size change"""
	print("MenuNavigationDemo: Menu stack size changed to ", stack_size)
	_update_info_labels()

func _on_transition_started(from_menu: String, to_menu: String) -> void:
	"""Handle transition started"""
	print("MenuNavigationDemo: Transition started from '", from_menu, "' to '", to_menu, "'")
	_update_info_labels()

func _on_transition_completed(from_menu: String, to_menu: String) -> void:
	"""Handle transition completed"""
	print("MenuNavigationDemo: Transition completed from '", from_menu, "' to '", to_menu, "'")
	_update_info_labels()

# Info Updates

func _update_info_labels() -> void:
	"""Update the info labels with current MenuManager state"""
	if not MenuManager:
		if current_menu_label:
			current_menu_label.text = "Current: MenuManager not available"
		return
	
	# Update current menu
	if current_menu_label:
		var current = MenuManager.get_current_menu()
		current_menu_label.text = "Current: " + (current if not current.is_empty() else "None")
	
	# Update stack size
	if stack_size_label:
		var stack = MenuManager.get_menu_stack()
		stack_size_label.text = "Stack Size: " + str(stack.size())
		if stack.size() > 0:
			stack_size_label.text += " (" + str(stack) + ")"
	
	# Update transition state
	if is_transitioning_label:
		var transitioning = MenuManager.is_transitioning
		is_transitioning_label.text = "Transitioning: " + ("Yes" if transitioning else "No")

# Input Handling

func _unhandled_input(event: InputEvent) -> void:
	# Let MenuManager handle ESC for navigation
	# We can add debug keys here if needed
	if event.is_action_pressed("ui_home") and OS.is_debug_build():
		# Debug: Print MenuManager state
		if MenuManager:
			MenuManager.debug_print_state()

# Screenshots for testing

func take_screenshot(name: String) -> String:
	"""Take a screenshot for testing verification"""
	if fade_transition and fade_transition.has_method("take_screenshot"):
		return fade_transition.take_screenshot(name + ".png", "working")
	else:
		print("MenuNavigationDemo: Cannot take screenshot - FadeTransition not available")
		return ""

# Testing Methods

func test_menu_flow() -> void:
	"""Automated test of menu flow"""
	print("MenuNavigationDemo: Starting automated menu flow test...")
	
	# Test 1: Main Menu -> Settings -> Back
	await _test_main_to_settings()
	await get_tree().create_timer(1.0).timeout
	
	# Test 2: Pause Menu -> Settings -> Back
	await _test_pause_to_settings()
	await get_tree().create_timer(1.0).timeout
	
	# Test 3: Multiple menu stack
	await _test_menu_stack()
	
	print("MenuNavigationDemo: Automated test completed")

func _test_main_to_settings() -> void:
	"""Test Main Menu -> Settings -> Back flow"""
	print("Test: Main Menu -> Settings -> Back")
	
	# Open main menu
	MenuManager.open_menu("main_menu", true)
	await get_tree().create_timer(0.5).timeout
	take_screenshot("test_main_menu_open")
	
	# Open settings from main menu
	MenuManager.open_menu("settings_menu", true)
	await get_tree().create_timer(0.5).timeout
	take_screenshot("test_settings_from_main")
	
	# Go back
	MenuManager.go_back()
	await get_tree().create_timer(0.5).timeout
	take_screenshot("test_back_to_main")
	
	# Close all
	MenuManager.close_all_menus(true)
	await get_tree().create_timer(0.5).timeout

func _test_pause_to_settings() -> void:
	"""Test Pause Menu -> Settings -> Back flow"""
	print("Test: Pause Menu -> Settings -> Back")
	
	# Open pause menu
	MenuManager.open_menu("pause_menu", true)
	await get_tree().create_timer(0.5).timeout
	take_screenshot("test_pause_menu_open")
	
	# Open settings from pause menu
	MenuManager.open_menu("settings_menu", true)
	await get_tree().create_timer(0.5).timeout
	take_screenshot("test_settings_from_pause")
	
	# Go back
	MenuManager.go_back()
	await get_tree().create_timer(0.5).timeout
	take_screenshot("test_back_to_pause")
	
	# Close all
	MenuManager.close_all_menus(true)
	await get_tree().create_timer(0.5).timeout

func _test_menu_stack() -> void:
	"""Test multiple menu stack navigation"""
	print("Test: Multiple menu stack navigation")
	
	# Build stack: Main -> Settings
	MenuManager.open_menu("main_menu", true)
	await get_tree().create_timer(0.3).timeout
	
	MenuManager.open_menu("settings_menu", true)
	await get_tree().create_timer(0.3).timeout
	take_screenshot("test_menu_stack_built")
	
	# Go back step by step
	MenuManager.go_back()
	await get_tree().create_timer(0.3).timeout
	take_screenshot("test_menu_stack_back_once")
	
	MenuManager.go_back()
	await get_tree().create_timer(0.3).timeout
	take_screenshot("test_menu_stack_back_twice")

# Debug Methods

func get_debug_info() -> Dictionary:
	"""Get debug information about the demo state"""
	var info = {
		"demo_ready": is_inside_tree(),
		"menu_manager_available": MenuManager != null,
		"fade_transition_available": fade_transition != null,
		"update_timer_active": update_timer != null and not update_timer.is_stopped()
	}
	
	if MenuManager:
		info["menu_manager_info"] = MenuManager.get_debug_info()
	
	return info

func debug_print_state() -> void:
	"""Print current demo state for debugging"""
	if OS.is_debug_build():
		print("=== MenuNavigationDemo Debug State ===")
		var debug_info = get_debug_info()
		for key in debug_info:
			print(key, ": ", debug_info[key])
		print("========================================")