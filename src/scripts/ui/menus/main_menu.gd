class_name MainMenu
extends BaseMenu
## Main menu for Rando's Reservoir with scene navigation and game controls

# Menu buttons
@onready var start_button: GameMenuButton = $MenuContainer/MainPanel/VBoxContainer/ButtonContainer/StartButton
@onready var settings_button: GameMenuButton = $MenuContainer/MainPanel/VBoxContainer/ButtonContainer/SettingsButton
@onready var quit_button: GameMenuButton = $MenuContainer/MainPanel/VBoxContainer/ButtonContainer/QuitButton

# UI containers
@onready var main_panel: Panel = $MenuContainer/MainPanel
@onready var title_label: Label = $MenuContainer/MainPanel/VBoxContainer/TitleContainer/TitleLabel
@onready var subtitle_label: Label = $MenuContainer/MainPanel/VBoxContainer/TitleContainer/SubtitleLabel
@onready var button_container: VBoxContainer = $MenuContainer/MainPanel/VBoxContainer/ButtonContainer

# Background elements
@onready var background_rect: ColorRect = $MenuContainer/BackgroundRect

func _ready() -> void:
	# Set menu name
	menu_name = "main_menu"
	
	# Set menu container and background for BaseMenu
	menu_container = $MenuContainer
	background_panel = main_panel
	
	# Call parent ready
	super._ready()

func _initialize_menu() -> void:
	"""Initialize main menu specific setup"""
	super._initialize_menu()
	
	# Configure title and subtitle
	_setup_title_elements()
	
	# Setup menu buttons
	_setup_menu_buttons()
	
	# Setup background styling
	_setup_background_styling()
	
	# Connect to SceneManager
	integrate_with_scene_manager()
	
	if OS.is_debug_build():
		print("MainMenu initialization complete")

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
		start_button.set_button_data(
			"start_game",
			"start_new_game",
			{
				"text": "Start Game",
				"tooltip": "Begin a new journey"
			}
		)
		add_menu_button(start_button, "start_game")
	
	# Settings Button
	if settings_button:
		settings_button.set_button_data(
			"settings",
			"open_settings",
			{
				"text": "Settings",
				"tooltip": "Configure game options"
			}
		)
		add_menu_button(settings_button, "settings")
	
	# Quit Button
	if quit_button:
		quit_button.set_button_data(
			"quit",
			"quit_game",
			{
				"text": "Quit Game",
				"tooltip": "Exit Rando's Reservoir"
			}
		)
		add_menu_button(quit_button, "quit")
	
	# Set initial focus to start button
	if start_button:
		set_initial_focus_button(start_button)

func _setup_background_styling() -> void:
	"""Configure background and panel styling"""
	# Background rect styling
	if background_rect:
		background_rect.color = background_color
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

# Button Action Handlers

func _on_menu_button_pressed(button_name: String) -> void:
	"""Handle menu button presses"""
	super._on_menu_button_pressed(button_name)
	
	match button_name:
		"start_game":
			_handle_start_game()
		"settings":
			_handle_open_settings()
		"quit":
			_handle_quit_game()
		_:
			if OS.is_debug_build():
				print("Unhandled button press: ", button_name)

func _handle_start_game() -> void:
	"""Handle start game button press"""
	if OS.is_debug_build():
		print("Starting new game...")
	
	# Close menu first
	close_menu(false)  # No animation for immediate transition
	
	# Transition to first game scene
	# Using the airport_montage scene as the first scene based on SceneManager
	SceneManager.change_scene("airport_montage", SceneManager.TransitionType.FADE_BLACK)

func _handle_open_settings() -> void:
	"""Handle settings button press"""
	if OS.is_debug_build():
		print("Opening settings menu...")
	
	# Navigate to settings menu (placeholder for now)
	navigate_to_menu("settings_menu")
	
	# For now, just show a debug message
	if has_node("/root/EventBus"):
		var event_bus = get_node("/root/EventBus")
		if event_bus.has_signal("debug_message"):
			event_bus.debug_message.emit("Settings menu not yet implemented")

func _handle_quit_game() -> void:
	"""Handle quit game button press"""
	if OS.is_debug_build():
		print("Quitting game...")
	
	# Show confirmation dialog in production
	# For now, quit immediately
	get_tree().quit()

# Scene Manager Integration

func integrate_with_scene_manager() -> void:
	"""Connect to SceneManager for scene transitions"""
	super.integrate_with_scene_manager()
	
	# Connect to scene loaded events to handle transitions
	if has_node("/root/EventBus"):
		var event_bus = get_node("/root/EventBus")
		if event_bus.has_signal("scene_loaded") and not event_bus.scene_loaded.is_connected(_on_scene_loaded):
			event_bus.scene_loaded.connect(_on_scene_loaded)

func _on_scene_loaded(scene_name: String) -> void:
	"""Handle when a new scene is loaded"""
	if OS.is_debug_build():
		print("MainMenu: Scene loaded - ", scene_name)
	
	# Close menu if it's open and we're loading a game scene
	if is_menu_open() and scene_name != "main_menu":
		close_menu(false)

# Input Handling Override

func _unhandled_input(event: InputEvent) -> void:
	if not is_menu_open():
		return
	
	# Call parent input handling first
	super._unhandled_input(event)
	
	# Handle additional main menu specific inputs
	if event.is_action_pressed("ui_select") or event.is_action_pressed("ui_accept"):
		# If no button has focus, focus the start button
		var focused = get_viewport().gui_get_focus_owner()
		if not focused and start_button:
			start_button.grab_focus()

# Animation Overrides

func _play_open_animation() -> void:
	"""Custom main menu open animation"""
	if not menu_container:
		return
	
	# Start with menu off-screen from top
	menu_container.position.y = -get_viewport().get_visible_rect().size.y
	menu_container.modulate = Color.TRANSPARENT
	menu_container.scale = Vector2.ONE
	
	# Create slide-in animation
	var tween = create_tween()
	tween.set_parallel(true)
	
	# Slide in from top
	var final_position = Vector2.ZERO
	tween.tween_property(menu_container, "position", final_position, fade_duration)
	tween.tween_method(_update_slide_easing, 0.0, 1.0, fade_duration)
	
	# Fade in
	tween.tween_property(menu_container, "modulate", Color.WHITE, fade_duration * 0.8)
	
	# Wait for animation
	await tween.finished

func _update_slide_easing(progress: float) -> void:
	"""Apply easing to slide animation"""
	# Ease out cubic for smooth landing
	var eased = 1.0 - pow(1.0 - progress, 3.0)
	# This is handled by the tween itself, but can be used for custom effects

# Utility Methods

func show_main_menu() -> void:
	"""Public method to show the main menu"""
	open_menu(true)

func hide_main_menu() -> void:
	"""Public method to hide the main menu"""
	close_menu(true)

func reset_to_start_button() -> void:
	"""Reset focus to start button"""
	if start_button:
		start_button.grab_focus()

# Debug Methods

func get_main_menu_debug_info() -> Dictionary:
	"""Get debug information specific to main menu"""
	var base_info = get_menu_debug_info()
	base_info.merge({
		"start_button_exists": start_button != null,
		"settings_button_exists": settings_button != null,
		"quit_button_exists": quit_button != null,
		"title_text": title_label.text if title_label else "",
		"subtitle_text": subtitle_label.text if subtitle_label else ""
	})
	return base_info

func debug_print_main_menu_state() -> void:
	"""Print main menu specific debug state"""
	if OS.is_debug_build():
		print("MainMenu Debug State: ", get_main_menu_debug_info())