extends Node
## Demo scene for testing the Standalone Settings Menu functionality

@onready var settings_menu = $SettingsMenuStandalone
@onready var status_label: Label = $CenterContainer/VBoxContainer/StatusLabel
@onready var instruction_label: Label = $CenterContainer/VBoxContainer/InstructionLabel
@onready var volume_status: Label = $CenterContainer/VBoxContainer/VolumeStatus

func _ready() -> void:
	# Connect to settings menu signals
	if settings_menu:
		settings_menu.settings_closed.connect(_on_settings_closed)
		settings_menu.volume_changed.connect(_on_volume_changed)
		settings_menu.video_setting_changed.connect(_on_video_setting_changed)
	
	# Set up instructions
	_update_instructions()
	_update_status()
	
	if OS.is_debug_build():
		print("Settings Menu Standalone Demo initialized")

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):  # Space key
		_toggle_settings_menu()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_cancel"):  # Escape key
		if settings_menu and settings_menu.is_open():
			settings_menu.close_settings()
		else:
			_quit_demo()
		get_viewport().set_input_as_handled()

func _toggle_settings_menu() -> void:
	"""Toggle the settings menu open/closed"""
	if not settings_menu:
		return
	
	if settings_menu.is_open():
		settings_menu.close_settings()
	else:
		settings_menu.open_settings()

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

Test the audio sliders and video checkboxes!
Changes apply immediately."""

func _update_status() -> void:
	"""Update status display"""
	if status_label:
		var status: String = "Settings Menu: "
		if settings_menu and settings_menu.is_open():
			status += "Open"
			status_label.add_theme_color_override("font_color", Color.GREEN)
		else:
			status += "Closed"
			status_label.add_theme_color_override("font_color", Color.WHITE)
		status_label.text = status

# Signal Callbacks

func _on_settings_closed() -> void:
	"""Handle when settings menu closes"""
	_update_status()
	if OS.is_debug_build():
		print("Settings menu closed from demo")

func _on_volume_changed(type: String, value: float) -> void:
	"""Handle volume changes"""
	if volume_status:
		volume_status.text = "Last changed: " + type.capitalize() + " Volume = " + str(int(value * 100)) + "%"
		volume_status.add_theme_color_override("font_color", Color.YELLOW)
	
	if OS.is_debug_build():
		print("Volume changed - ", type, ": ", value)

func _on_video_setting_changed(setting: String, value: bool) -> void:
	"""Handle video setting changes"""
	if volume_status:
		volume_status.text = "Video setting changed: " + setting.capitalize() + " = " + str(value)
		volume_status.add_theme_color_override("font_color", Color.CYAN)
	
	if OS.is_debug_build():
		print("Video setting changed - ", setting, ": ", value)

# Also monitor menu open state
func _process(_delta: float) -> void:
	"""Update status every frame (simple polling)"""
	var was_open: bool = status_label.text.ends_with("Open")
	var is_open_now: bool = settings_menu and settings_menu.is_open()
	
	if was_open != is_open_now:
		_update_status()