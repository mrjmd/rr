class_name PauseMenu
extends BaseMenu
## Pause menu for Rando's Reservoir with game controls and settings access

# Menu buttons
@onready var resume_button: GameMenuButton = $MenuContainer/MainPanel/VBoxContainer/ButtonContainer/ResumeButton
@onready var settings_button: GameMenuButton = $MenuContainer/MainPanel/VBoxContainer/ButtonContainer/SettingsButton
@onready var main_menu_button: GameMenuButton = $MenuContainer/MainPanel/VBoxContainer/ButtonContainer/MainMenuButton

# UI containers
@onready var main_panel: Panel = $MenuContainer/MainPanel
@onready var title_label: Label = $MenuContainer/MainPanel/VBoxContainer/TitleContainer/TitleLabel
@onready var button_container: VBoxContainer = $MenuContainer/MainPanel/VBoxContainer/ButtonContainer

# Background overlay
@onready var background_overlay: ColorRect = $MenuContainer/BackgroundOverlay

# Private variables
var _was_paused_before_menu: bool = false

func _ready() -> void:
	# Set menu name and layer
	menu_name = "pause_menu"
	layer = 250  # Above main menu but below dialogue
	
	# Set menu container and background for BaseMenu
	menu_container = $MenuContainer
	background_panel = main_panel
	
	# This menu is modal and should pause the game
	is_modal = true
	
	# Call parent ready
	super._ready()

func _initialize_menu() -> void:
	"""Initialize pause menu specific setup"""
	super._initialize_menu()
	
	# Register with MenuManager
	if MenuManager:
		MenuManager.register_menu("pause_menu", self)
	
	# Configure title
	_setup_title_elements()
	
	# Setup menu buttons
	_setup_menu_buttons()
	
	# Setup background styling
	_setup_background_styling()
	
	# Connect to game input
	_setup_input_handling()
	
	if OS.is_debug_build():
		print("PauseMenu initialization complete")

func _setup_title_elements() -> void:
	"""Configure title styling"""
	if title_label:
		title_label.text = "PAUSED"
		title_label.add_theme_font_size_override("font_size", 36)
		title_label.add_theme_color_override("font_color", Color(0.9, 0.9, 1.0, 1.0))
		title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

func _setup_menu_buttons() -> void:
	"""Configure all menu buttons"""
	# Resume Button
	if resume_button:
		resume_button.set_button_data(
			"resume",
			"resume_game",
			{
				"text": "Resume",
				"tooltip": "Continue playing"
			}
		)
		add_menu_button(resume_button, "resume")
	
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
	
	# Main Menu Button
	if main_menu_button:
		main_menu_button.set_button_data(
			"main_menu",
			"return_to_main_menu",
			{
				"text": "Main Menu",
				"tooltip": "Return to main menu"
			}
		)
		add_menu_button(main_menu_button, "main_menu")
	
	# Set initial focus to resume button
	if resume_button:
		set_initial_focus_button(resume_button)

func _setup_background_styling() -> void:
	"""Configure background overlay and panel styling"""
	# Semi-transparent dark overlay
	if background_overlay:
		background_overlay.color = Color(0, 0, 0, 0.7)
		background_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	# Main panel styling
	if main_panel:
		_setup_panel_style(main_panel)

func _setup_panel_style(panel: Panel) -> void:
	"""Create and apply panel styling"""
	var panel_style = StyleBoxFlat.new()
	
	# Background color - matching main menu
	panel_style.bg_color = Color(0.1, 0.1, 0.15, 0.95)
	
	# Corner radius
	panel_style.corner_radius_bottom_left = 8
	panel_style.corner_radius_bottom_right = 8
	panel_style.corner_radius_top_left = 8
	panel_style.corner_radius_top_right = 8
	
	# Border
	panel_style.border_width_left = 2
	panel_style.border_width_right = 2
	panel_style.border_width_top = 2
	panel_style.border_width_bottom = 2
	panel_style.border_color = Color(0.3, 0.3, 0.4, 0.6)
	
	# Padding/margins
	panel_style.content_margin_left = 30
	panel_style.content_margin_right = 30
	panel_style.content_margin_top = 25
	panel_style.content_margin_bottom = 25
	
	# Apply style
	panel.add_theme_stylebox_override("panel", panel_style)

func _setup_input_handling() -> void:
	"""Setup pause menu input handling"""
	# The BaseMenu already handles ui_cancel (escape)
	# We just need to connect to our specific pause_menu action
	pass

# Input Handling

func _unhandled_input(event: InputEvent) -> void:
	# Handle pause menu toggle input
	if event.is_action_pressed("pause_menu"):
		_toggle_pause_menu()
		get_viewport().set_input_as_handled()
		return
	
	# Only handle other inputs if menu is open
	if not is_menu_open():
		return
	
	# Call parent input handling
	super._unhandled_input(event)

func _toggle_pause_menu() -> void:
	"""Toggle the pause menu open/closed"""
	if is_menu_open():
		_handle_resume_game()
	else:
		_show_pause_menu()

func _show_pause_menu() -> void:
	"""Show the pause menu"""
	# Store current pause state
	_was_paused_before_menu = get_tree().paused
	
	# Open the menu (this will pause the game via BaseMenu)
	open_menu(true)
	
	if OS.is_debug_build():
		print("Pause menu opened")

# Button Action Handlers

func _on_menu_button_pressed(button_name: String) -> void:
	"""Handle menu button presses"""
	super._on_menu_button_pressed(button_name)
	
	match button_name:
		"resume":
			_handle_resume_game()
		"settings":
			_handle_open_settings()
		"main_menu":
			_handle_return_to_main_menu()
		_:
			if OS.is_debug_build():
				print("Unhandled pause menu button press: ", button_name)

func _handle_resume_game() -> void:
	"""Handle resume button press"""
	if OS.is_debug_build():
		print("Resuming game...")
	
	# Close menu (this will unpause the game via BaseMenu)
	close_menu(true)

func _handle_open_settings() -> void:
	"""Handle settings button press"""
	if OS.is_debug_build():
		print("PauseMenu: _handle_open_settings() called")
	
	# Use MenuManager to open settings
	if MenuManager:
		if OS.is_debug_build():
			print("PauseMenu: Calling MenuManager.open_menu('settings_menu', true)")
		MenuManager.open_menu("settings_menu", true)
	else:
		if OS.is_debug_build():
			print("PauseMenu: No MenuManager, using navigate_to_menu fallback")
		# Fallback to BaseMenu navigation
		navigate_to_menu("settings_menu")

func _handle_return_to_main_menu() -> void:
	"""Handle main menu button press"""
	if OS.is_debug_build():
		print("Returning to main menu from pause...")
	
	# Use MenuManager to close all menus and transition to main menu
	if MenuManager:
		MenuManager.close_all_menus(true)
		# Wait a frame for menu closure
		await get_tree().process_frame
	else:
		# Close menu first (this will unpause the game)
		close_menu(false)  # No animation for immediate transition
	
	# Transition to main menu scene
	SceneManager.change_scene("main_menu", SceneManager.TransitionType.FADE_BLACK)

# Override BaseMenu methods for pause-specific behavior

func open_menu(animate: bool = true) -> void:
	"""Open pause menu with pause state management"""
	if current_state != MenuState.CLOSED:
		return
	
	# Store current pause state before opening
	_was_paused_before_menu = get_tree().paused
	
	# Call parent implementation
	super.open_menu(animate)

func close_menu(animate: bool = true) -> void:
	"""Close pause menu with pause state restoration"""
	if current_state != MenuState.OPEN:
		return
	
	# Call parent implementation
	super.close_menu(animate)
	
	# Restore previous pause state if it wasn't paused before
	if not _was_paused_before_menu:
		get_tree().paused = false

# Event Callbacks

func _on_game_paused() -> void:
	"""Handle game pause event from EventBus"""
	# Don't auto-show menu for external pause events
	pass

func _on_game_resumed() -> void:
	"""Handle game resume event from EventBus"""
	# Close menu if it's open and game is resumed externally
	if is_menu_open():
		close_menu(false)

# Public API

func show_pause_menu() -> void:
	"""Public method to show the pause menu"""
	_show_pause_menu()

func hide_pause_menu() -> void:
	"""Public method to hide the pause menu"""
	close_menu(true)

func is_game_paused_by_menu() -> bool:
	"""Check if the game is currently paused by this menu"""
	return is_menu_open() and is_modal

# Utility Methods

func can_pause() -> bool:
	"""Check if the game can be paused right now"""
	# Don't pause during scene transitions or if already in another modal
	return not SceneManager.is_transitioning() and not _is_other_modal_open()

func _is_other_modal_open() -> bool:
	"""Check if another modal (like dialogue) is currently open"""
	# This could be expanded to check other modal systems
	# For now, assume we can always pause unless explicitly blocked
	return false

# Debug Methods

func get_pause_menu_debug_info() -> Dictionary:
	"""Get debug information specific to pause menu"""
	var base_info = get_menu_debug_info()
	base_info.merge({
		"resume_button_exists": resume_button != null,
		"settings_button_exists": settings_button != null,
		"main_menu_button_exists": main_menu_button != null,
		"was_paused_before_menu": _was_paused_before_menu,
		"current_tree_paused": get_tree().paused,
		"can_pause": can_pause()
	})
	return base_info

func debug_print_pause_menu_state() -> void:
	"""Print pause menu specific debug state"""
	if OS.is_debug_build():
		print("PauseMenu Debug State: ", get_pause_menu_debug_info())