class_name SimplePauseMenu
extends CanvasLayer
## Simple pause menu without BaseMenu dependency for testing

# Menu buttons
@onready var resume_button: Button = $MenuContainer/MainPanel/VBoxContainer/ButtonContainer/ResumeButton
@onready var settings_button: Button = $MenuContainer/MainPanel/VBoxContainer/ButtonContainer/SettingsButton
@onready var main_menu_button: Button = $MenuContainer/MainPanel/VBoxContainer/ButtonContainer/MainMenuButton

# UI containers
@onready var main_panel: Panel = $MenuContainer/MainPanel
@onready var title_label: Label = $MenuContainer/MainPanel/VBoxContainer/TitleContainer/TitleLabel

# Background overlay
@onready var background_overlay: ColorRect = $MenuContainer/BackgroundOverlay

# State
var is_menu_open: bool = false
var was_paused_before: bool = false

func _ready() -> void:
	# Set layer and process mode
	layer = 250
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	
	# Initially hidden
	visible = false
	
	# Setup UI
	_setup_ui()
	
	# Connect buttons
	_connect_buttons()
	
	if OS.is_debug_build():
		print("SimplePauseMenu initialized")

func _setup_ui() -> void:
	"""Setup UI styling"""
	if title_label:
		title_label.text = "PAUSED"
		title_label.add_theme_font_size_override("font_size", 36)
		title_label.add_theme_color_override("font_color", Color(0.9, 0.9, 1.0))
		title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	
	if background_overlay:
		background_overlay.color = Color(0, 0, 0, 0.7)
	
	if main_panel:
		var style = StyleBoxFlat.new()
		style.bg_color = Color(0.1, 0.1, 0.15, 0.95)
		style.corner_radius_bottom_left = 8
		style.corner_radius_bottom_right = 8
		style.corner_radius_top_left = 8
		style.corner_radius_top_right = 8
		style.border_width_left = 2
		style.border_width_right = 2
		style.border_width_top = 2
		style.border_width_bottom = 2
		style.border_color = Color(0.3, 0.3, 0.4, 0.6)
		main_panel.add_theme_stylebox_override("panel", style)

func _connect_buttons() -> void:
	"""Connect button signals"""
	if resume_button:
		resume_button.pressed.connect(_on_resume_pressed)
	if settings_button:
		settings_button.pressed.connect(_on_settings_pressed)
	if main_menu_button:
		main_menu_button.pressed.connect(_on_main_menu_pressed)

func _unhandled_input(event: InputEvent) -> void:
	"""Handle input"""
	if event.is_action_pressed("pause_menu"):
		toggle_menu()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_cancel") and is_menu_open:
		hide_menu()
		get_viewport().set_input_as_handled()

func show_menu() -> void:
	"""Show the pause menu"""
	if is_menu_open:
		return
	
	was_paused_before = get_tree().paused
	is_menu_open = true
	visible = true
	get_tree().paused = true
	
	# Set focus to resume button
	if resume_button:
		resume_button.grab_focus()
	
	# Emit EventBus signal only if available
	var event_bus: Node = get_node_or_null("/root/EventBus")
	if event_bus and event_bus.has_signal("game_paused"):
		event_bus.game_paused.emit()
	
	if OS.is_debug_build():
		print("Pause menu opened")

func hide_menu() -> void:
	"""Hide the pause menu"""
	if not is_menu_open:
		return
	
	is_menu_open = false
	visible = false
	
	if not was_paused_before:
		get_tree().paused = false
	
	# Emit EventBus signal only if available
	var event_bus: Node = get_node_or_null("/root/EventBus")
	if event_bus and event_bus.has_signal("game_resumed"):
		event_bus.game_resumed.emit()
	
	if OS.is_debug_build():
		print("Pause menu closed")

func toggle_menu() -> void:
	"""Toggle menu visibility"""
	if is_menu_open:
		hide_menu()
	else:
		show_menu()

func is_open() -> bool:
	"""Check if menu is open"""
	return is_menu_open

# Button handlers
func _on_resume_pressed() -> void:
	"""Handle resume button"""
	hide_menu()

func _on_settings_pressed() -> void:
	"""Handle settings button"""
	if OS.is_debug_build():
		print("Settings not implemented yet")

func _on_main_menu_pressed() -> void:
	"""Handle main menu button"""
	hide_menu()
	# Return to main menu - only if SceneManager is available
	var scene_manager = get_node_or_null("/root/SceneManager")
	if scene_manager and scene_manager.has_method("change_scene"):
		scene_manager.change_scene("main_menu", scene_manager.TransitionType.FADE_BLACK)
	else:
		if OS.is_debug_build():
			print("SceneManager not available - main menu navigation disabled")