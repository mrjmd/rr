extends Node
## Demo scene for testing the Settings Menu functionality

@onready var settings_menu: SettingsMenu = $SettingsMenu
@onready var status_label: Label = $CenterContainer/VBoxContainer/StatusLabel
@onready var instruction_label: Label = $CenterContainer/VBoxContainer/InstructionLabel

func _ready() -> void:
	# Connect to settings menu signals
	if settings_menu:
		settings_menu.menu_opened.connect(_on_settings_menu_opened)
		settings_menu.menu_closed.connect(_on_settings_menu_closed)
		settings_menu.menu_button_pressed.connect(_on_settings_menu_button_pressed)
	
	# Initially hide the settings menu
	if settings_menu:
		settings_menu.visible = false
	
	# Set up instructions
	_update_instructions()
	
	if OS.is_debug_build():
		print("Settings Menu Demo initialized")

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):  # Space key
		_toggle_settings_menu()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_cancel"):  # Escape key
		if settings_menu and settings_menu.is_menu_open():
			settings_menu.close_menu()
		else:
			_quit_demo()
		get_viewport().set_input_as_handled()

func _toggle_settings_menu() -> void:
	"""Toggle the settings menu open/closed"""
	if not settings_menu:
		return
	
	if settings_menu.is_menu_open():
		settings_menu.close_menu()
	else:
		settings_menu.open_menu()

func _quit_demo() -> void:
	"""Quit the demo"""
	if OS.is_debug_build():
		print("Quitting settings menu demo")
	get_tree().quit()

func _update_instructions() -> void:
	"""Update instruction text"""
	if instruction_label:
		instruction_label.text = """Press SPACE to toggle settings menu
Press ESCAPE to close menu or quit demo

Use mouse or keyboard to navigate settings"""

# Signal Callbacks

func _on_settings_menu_opened(menu_name: String) -> void:
	"""Handle when settings menu opens"""
	if status_label:
		status_label.text = "Settings Menu: Open"
		status_label.add_theme_color_override("font_color", Color.GREEN)
	
	if OS.is_debug_build():
		print("Settings menu opened: ", menu_name)

func _on_settings_menu_closed(menu_name: String) -> void:
	"""Handle when settings menu closes"""
	if status_label:
		status_label.text = "Settings Menu: Closed"
		status_label.add_theme_color_override("font_color", Color.WHITE)
	
	if OS.is_debug_build():
		print("Settings menu closed: ", menu_name)

func _on_settings_menu_button_pressed(button_name: String) -> void:
	"""Handle when settings menu button is pressed"""
	if OS.is_debug_build():
		print("Settings menu button pressed: ", button_name)
	
	# Handle specific button actions if needed
	match button_name:
		"back":
			if status_label:
				status_label.text = "Back button pressed - menu closing"