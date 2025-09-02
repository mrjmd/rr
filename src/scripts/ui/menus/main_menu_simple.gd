class_name MainMenuSimple
extends CanvasLayer
## Simplified main menu for testing without BaseMenu dependency

# Menu buttons
@onready var start_button: Button = $MenuContainer/MainPanel/VBoxContainer/ButtonContainer/StartButton
@onready var settings_button: Button = $MenuContainer/MainPanel/VBoxContainer/ButtonContainer/SettingsButton
@onready var quit_button: Button = $MenuContainer/MainPanel/VBoxContainer/ButtonContainer/QuitButton

# UI containers
@onready var main_panel: Panel = $MenuContainer/MainPanel
@onready var title_label: Label = $MenuContainer/MainPanel/VBoxContainer/TitleContainer/TitleLabel
@onready var subtitle_label: Label = $MenuContainer/MainPanel/VBoxContainer/TitleContainer/SubtitleLabel

# Background elements
@onready var background_rect: ColorRect = $MenuContainer/BackgroundRect

func _ready() -> void:
	# Set proper layer for menus
	layer = 200
	
	# Register with MenuManager if available
	var menu_manager = get_node_or_null("/root/MenuManager")
	if menu_manager:
		menu_manager.register_menu("main_menu", self)
	
	# Handle visibility - if loaded directly (standalone), show immediately
	# If loaded via MenuManager, stay hidden until explicitly shown
	var is_standalone = not get_node_or_null("/root/MenuManager") or get_tree().current_scene == self
	visible = is_standalone
	
	# Configure title and subtitle
	_setup_title_elements()
	
	# Setup menu buttons
	_setup_menu_buttons()
	
	# Setup background styling
	_setup_background_styling()
	
	print("MainMenuSimple initialized")

func _setup_title_elements() -> void:
	"""Configure title and subtitle styling"""
	if title_label:
		title_label.text = "Rando's Reservoir"
		title_label.add_theme_font_size_override("font_size", 48)
		title_label.add_theme_color_override("font_color", Color(0.9, 0.9, 1.0, 1.0))
		title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	
	if subtitle_label:
		subtitle_label.text = "An Emotional Journey"
		subtitle_label.add_theme_font_size_override("font_size", 16)
		subtitle_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.8, 0.8))
		subtitle_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

func _setup_menu_buttons() -> void:
	"""Configure all menu buttons"""
	# Start Game Button
	if start_button:
		start_button.text = "Start Game"
		start_button.tooltip_text = "Begin a new journey"
		start_button.pressed.connect(_on_start_button_pressed)
		_style_menu_button(start_button)
	
	# Settings Button
	if settings_button:
		settings_button.text = "Settings"
		settings_button.tooltip_text = "Configure game options"
		settings_button.pressed.connect(_on_settings_button_pressed)
		_style_menu_button(settings_button)
	
	# Quit Button
	if quit_button:
		quit_button.text = "Quit Game"
		quit_button.tooltip_text = "Exit Rando's Reservoir"
		quit_button.pressed.connect(_on_quit_button_pressed)
		_style_menu_button(quit_button)

func _style_menu_button(button: Button) -> void:
	"""Apply consistent styling to menu buttons"""
	if not button:
		return
	
	# Set font size
	button.add_theme_font_size_override("font_size", 18)
	
	# Create normal button style
	var normal_style = StyleBoxFlat.new()
	normal_style.bg_color = Color(0.25, 0.25, 0.35, 0.9)  # button normal
	normal_style.corner_radius_bottom_left = 8
	normal_style.corner_radius_bottom_right = 8
	normal_style.corner_radius_top_left = 8
	normal_style.corner_radius_top_right = 8
	normal_style.content_margin_left = 20
	normal_style.content_margin_right = 20
	normal_style.content_margin_top = 15
	normal_style.content_margin_bottom = 15
	normal_style.border_width_left = 2
	normal_style.border_width_right = 2
	normal_style.border_width_top = 2
	normal_style.border_width_bottom = 2
	normal_style.border_color = Color(0.4, 0.4, 0.5, 0.5)
	
	# Create hover style
	var hover_style = normal_style.duplicate()
	hover_style.bg_color = Color(0.35, 0.35, 0.45, 0.95)  # button hover
	hover_style.border_color = Color(0.6, 0.6, 0.7, 0.8)
	
	# Create pressed style
	var pressed_style = normal_style.duplicate()
	pressed_style.bg_color = Color(0.45, 0.45, 0.55, 1.0)
	pressed_style.border_color = Color(0.8, 0.8, 0.9, 1.0)
	
	# Apply styles
	button.add_theme_stylebox_override("normal", normal_style)
	button.add_theme_stylebox_override("hover", hover_style)
	button.add_theme_stylebox_override("pressed", pressed_style)
	
	# Text color
	button.add_theme_color_override("font_color", Color(0.9, 0.9, 0.9, 1.0))
	button.add_theme_color_override("font_hover_color", Color(1.0, 1.0, 1.0, 1.0))
	button.add_theme_color_override("font_pressed_color", Color(1.0, 1.0, 1.0, 1.0))

func _setup_background_styling() -> void:
	"""Configure background and panel styling"""
	# Background rect styling
	if background_rect:
		background_rect.color = Color(0.1, 0.1, 0.15, 0.95)
		background_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	# Main panel styling
	if main_panel:
		_setup_panel_style(main_panel)

func _setup_panel_style(panel: Panel) -> void:
	"""Create and apply panel styling"""
	var panel_style = StyleBoxFlat.new()
	
	# Background color
	panel_style.bg_color = Color(0.15, 0.15, 0.2, 0.95)
	
	# Corner radius
	panel_style.corner_radius_bottom_left = 12
	panel_style.corner_radius_bottom_right = 12
	panel_style.corner_radius_top_left = 12
	panel_style.corner_radius_top_right = 12
	
	# Border
	panel_style.border_width_left = 2
	panel_style.border_width_right = 2
	panel_style.border_width_top = 2
	panel_style.border_width_bottom = 2
	panel_style.border_color = Color(0.3, 0.3, 0.4, 0.6)
	
	# Padding/margins
	panel_style.content_margin_left = 40
	panel_style.content_margin_right = 40
	panel_style.content_margin_top = 30
	panel_style.content_margin_bottom = 30
	
	# Apply style
	panel.add_theme_stylebox_override("panel", panel_style)

# Button handlers
func _on_start_button_pressed() -> void:
	print("Start Game button pressed!")
	# Transition to kitchen POC scene
	if get_node_or_null("/root/SceneManager"):
		get_node("/root/SceneManager").change_scene("kitchen", 0)

func _on_settings_button_pressed() -> void:
	print("Settings button pressed!")
	# Open settings menu via MenuManager
	var menu_manager = get_node_or_null("/root/MenuManager")
	if menu_manager:
		menu_manager.open_menu("settings_menu", true)
	else:
		print("WARNING: MenuManager not available - cannot open settings")

func _on_quit_button_pressed() -> void:
	print("Quit Game button pressed!")
	get_tree().quit()

# MenuManager-compatible methods
func open_menu(animate: bool = true) -> void:
	"""MenuManager-compatible open method"""
	visible = true
	if start_button:
		start_button.grab_focus()
	
	if OS.is_debug_build():
		print("MainMenuSimple: Menu opened")

func close_menu(animate: bool = true) -> void:
	"""MenuManager-compatible close method"""
	visible = false
	
	if OS.is_debug_build():
		print("MainMenuSimple: Menu closed")

func is_open() -> bool:
	"""Check if menu is open"""
	return visible