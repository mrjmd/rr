class_name SettingsMenu
extends BaseMenu
## Settings menu for Rando's Reservoir with audio, video, and controls configuration

# Settings tabs
@onready var tab_container: TabContainer = $MenuContainer/MainPanel/VBoxContainer/TabContainer

# Audio tab controls
@onready var master_volume_slider: HSlider = $MenuContainer/MainPanel/VBoxContainer/TabContainer/Audio/VBoxContainer/MasterVolumeContainer/MasterVolumeSlider
@onready var master_volume_label: Label = $MenuContainer/MainPanel/VBoxContainer/TabContainer/Audio/VBoxContainer/MasterVolumeContainer/MasterVolumeLabel
@onready var master_volume_value: Label = $MenuContainer/MainPanel/VBoxContainer/TabContainer/Audio/VBoxContainer/MasterVolumeContainer/MasterVolumeValue

@onready var music_volume_slider: HSlider = $MenuContainer/MainPanel/VBoxContainer/TabContainer/Audio/VBoxContainer/MusicVolumeContainer/MusicVolumeSlider
@onready var music_volume_label: Label = $MenuContainer/MainPanel/VBoxContainer/TabContainer/Audio/VBoxContainer/MusicVolumeContainer/MusicVolumeLabel
@onready var music_volume_value: Label = $MenuContainer/MainPanel/VBoxContainer/TabContainer/Audio/VBoxContainer/MusicVolumeContainer/MusicVolumeValue

@onready var sfx_volume_slider: HSlider = $MenuContainer/MainPanel/VBoxContainer/TabContainer/Audio/VBoxContainer/SFXVolumeContainer/SFXVolumeSlider
@onready var sfx_volume_label: Label = $MenuContainer/MainPanel/VBoxContainer/TabContainer/Audio/VBoxContainer/SFXVolumeContainer/SFXVolumeLabel
@onready var sfx_volume_value: Label = $MenuContainer/MainPanel/VBoxContainer/TabContainer/Audio/VBoxContainer/SFXVolumeContainer/SFXVolumeValue

# Video tab controls
@onready var fullscreen_check: CheckBox = $MenuContainer/MainPanel/VBoxContainer/TabContainer/Video/VBoxContainer/FullscreenContainer/FullscreenCheck
@onready var vsync_check: CheckBox = $MenuContainer/MainPanel/VBoxContainer/TabContainer/Video/VBoxContainer/VsyncContainer/VsyncCheck
@onready var resolution_option: OptionButton = $MenuContainer/MainPanel/VBoxContainer/TabContainer/Video/VBoxContainer/ResolutionContainer/ResolutionOption

# Controls tab
@onready var controls_info: Label = $MenuContainer/MainPanel/VBoxContainer/TabContainer/Controls/VBoxContainer/ControlsInfo

# Back button
@onready var back_button: GameMenuButton = $MenuContainer/MainPanel/VBoxContainer/ButtonContainer/BackButton

# UI containers
@onready var main_panel: Panel = $MenuContainer/MainPanel
@onready var title_label: Label = $MenuContainer/MainPanel/VBoxContainer/TitleContainer/TitleLabel

# Background overlay
@onready var background_overlay: ColorRect = $MenuContainer/BackgroundOverlay

# Settings state
var current_settings: Dictionary = {
	"master_volume": 1.0,
	"music_volume": 1.0,
	"sfx_volume": 1.0,
	"fullscreen": false,
	"vsync": true
}

# Private variables
var _returning_to_menu: String = ""  # Track which menu to return to

func _ready() -> void:
	# Set menu name and layer (above other menus)
	menu_name = "settings_menu"
	layer = 225  # Above menu layer but below pause
	
	# Set menu container and background for BaseMenu
	menu_container = $MenuContainer
	background_panel = main_panel
	
	# This menu is modal
	is_modal = true
	
	# Call parent ready
	super._ready()

func _initialize_menu() -> void:
	"""Initialize settings menu specific setup"""
	super._initialize_menu()
	
	# Configure title
	_setup_title_elements()
	
	# Setup tab container
	_setup_tab_container()
	
	# Setup audio controls
	_setup_audio_controls()
	
	# Setup video controls  
	_setup_video_controls()
	
	# Setup controls tab
	_setup_controls_info()
	
	# Setup back button
	_setup_back_button()
	
	# Setup background styling
	_setup_background_styling()
	
	# Load current settings
	_load_settings()
	
	if OS.is_debug_build():
		print("SettingsMenu initialization complete")

func _setup_title_elements() -> void:
	"""Configure title styling"""
	if title_label:
		title_label.text = "SETTINGS"
		title_label.add_theme_font_size_override("font_size", 32)
		title_label.add_theme_color_override("font_color", Color(0.9, 0.9, 1.0, 1.0))
		title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

func _setup_tab_container() -> void:
	"""Configure tab container styling"""
	if tab_container:
		# Set tab names
		tab_container.set_tab_title(0, "Audio")
		tab_container.set_tab_title(1, "Video") 
		tab_container.set_tab_title(2, "Controls")
		
		# Style the tab container
		var tab_style = StyleBoxFlat.new()
		tab_style.bg_color = Color(0.2, 0.2, 0.25, 0.9)
		tab_style.corner_radius_top_left = 6
		tab_style.corner_radius_top_right = 6
		
		# Apply tab styling if possible
		# Note: TabContainer styling in Godot is limited via code

func _setup_audio_controls() -> void:
	"""Setup audio slider controls"""
	# Master Volume
	if master_volume_slider:
		master_volume_slider.min_value = 0.0
		master_volume_slider.max_value = 1.0
		master_volume_slider.step = 0.01
		master_volume_slider.value = current_settings.master_volume
		master_volume_slider.value_changed.connect(_on_master_volume_changed)
		
		if master_volume_label:
			master_volume_label.text = "Master Volume"
			master_volume_label.add_theme_color_override("font_color", Color(0.9, 0.9, 0.9, 1.0))
		
		_update_volume_label(master_volume_value, current_settings.master_volume)
	
	# Music Volume
	if music_volume_slider:
		music_volume_slider.min_value = 0.0
		music_volume_slider.max_value = 1.0
		music_volume_slider.step = 0.01
		music_volume_slider.value = current_settings.music_volume
		music_volume_slider.value_changed.connect(_on_music_volume_changed)
		
		if music_volume_label:
			music_volume_label.text = "Music Volume"
			music_volume_label.add_theme_color_override("font_color", Color(0.9, 0.9, 0.9, 1.0))
		
		_update_volume_label(music_volume_value, current_settings.music_volume)
	
	# SFX Volume
	if sfx_volume_slider:
		sfx_volume_slider.min_value = 0.0
		sfx_volume_slider.max_value = 1.0
		sfx_volume_slider.step = 0.01
		sfx_volume_slider.value = current_settings.sfx_volume
		sfx_volume_slider.value_changed.connect(_on_sfx_volume_changed)
		
		if sfx_volume_label:
			sfx_volume_label.text = "SFX Volume"
			sfx_volume_label.add_theme_color_override("font_color", Color(0.9, 0.9, 0.9, 1.0))
		
		_update_volume_label(sfx_volume_value, current_settings.sfx_volume)

func _setup_video_controls() -> void:
	"""Setup video option controls"""
	# Fullscreen toggle
	if fullscreen_check:
		fullscreen_check.text = "Fullscreen"
		fullscreen_check.button_pressed = current_settings.fullscreen
		fullscreen_check.toggled.connect(_on_fullscreen_toggled)
		fullscreen_check.add_theme_color_override("font_color", Color(0.9, 0.9, 0.9, 1.0))
	
	# VSync toggle
	if vsync_check:
		vsync_check.text = "Vertical Sync"
		vsync_check.button_pressed = current_settings.vsync
		vsync_check.toggled.connect(_on_vsync_toggled)
		vsync_check.add_theme_color_override("font_color", Color(0.9, 0.9, 0.9, 1.0))
	
	# Resolution dropdown (placeholder for now)
	if resolution_option:
		resolution_option.add_item("1920x1080 (Current)")
		resolution_option.add_item("1366x768")
		resolution_option.add_item("1024x768")
		resolution_option.selected = 0  # Default selection
		resolution_option.disabled = true  # Placeholder - not functional yet
		
		# Style the option button
		resolution_option.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7, 1.0))

func _setup_controls_info() -> void:
	"""Setup controls information tab"""
	if controls_info:
		controls_info.text = """Input Remapping
		
Controls can be remapped through the pause menu during gameplay.

Current Bindings:
• Move: Arrow Keys / WASD
• Interact: Space / Enter
• Pause: Escape
• Menu Navigation: Arrow Keys / Tab

Input remapping interface will be available in a future update."""
		
		controls_info.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8, 1.0))
		controls_info.add_theme_font_size_override("font_size", 14)
		controls_info.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		controls_info.vertical_alignment = VERTICAL_ALIGNMENT_TOP

func _setup_back_button() -> void:
	"""Configure back button"""
	if back_button:
		back_button.set_button_data(
			"back",
			"close_settings",
			{
				"text": "Back",
				"tooltip": "Return to previous menu"
			}
		)
		add_menu_button(back_button, "back")
		
		# Set initial focus to back button
		set_initial_focus_button(back_button)

func _setup_background_styling() -> void:
	"""Configure background overlay and panel styling"""
	# Semi-transparent dark overlay
	if background_overlay:
		background_overlay.color = Color(0, 0, 0, 0.5)
		background_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	# Main panel styling
	if main_panel:
		_setup_panel_style(main_panel)

func _setup_panel_style(panel: Panel) -> void:
	"""Create and apply panel styling"""
	var panel_style = StyleBoxFlat.new()
	
	# Background color - matching other menus
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

# Settings Management

func _load_settings() -> void:
	"""Load settings from GameManager or use defaults"""
	# Try to load from GameManager if it exists
	if GameManager and GameManager.has_method("get_setting"):
		current_settings.master_volume = GameManager.get_setting("master_volume", 1.0)
		current_settings.music_volume = GameManager.get_setting("music_volume", 1.0)
		current_settings.sfx_volume = GameManager.get_setting("sfx_volume", 1.0)
		current_settings.fullscreen = GameManager.get_setting("fullscreen", false)
		current_settings.vsync = GameManager.get_setting("vsync", true)
	else:
		# Load from system settings
		current_settings.fullscreen = DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN
		current_settings.vsync = DisplayServer.window_get_vsync_mode() != DisplayServer.VSYNC_DISABLED
	
	# Update UI controls with loaded values
	_update_ui_from_settings()
	
	if OS.is_debug_build():
		print("Settings loaded: ", current_settings)

func _save_settings() -> void:
	"""Save current settings"""
	# Save to GameManager if available
	if GameManager and GameManager.has_method("set_setting"):
		for key in current_settings:
			GameManager.set_setting(key, current_settings[key])
		
		if GameManager.has_method("save_settings"):
			GameManager.save_settings()
	
	# Apply settings to system
	_apply_settings()
	
	if OS.is_debug_build():
		print("Settings saved: ", current_settings)

func _apply_settings() -> void:
	"""Apply settings to the game systems"""
	# Apply audio settings through AudioManager if available
	if has_node("/root/AudioManager"):
		var audio_manager = get_node("/root/AudioManager")
		if audio_manager.has_method("set_master_volume"):
			audio_manager.set_master_volume(current_settings.master_volume)
		if audio_manager.has_method("set_music_volume"):
			audio_manager.set_music_volume(current_settings.music_volume)
		if audio_manager.has_method("set_sfx_volume"):
			audio_manager.set_sfx_volume(current_settings.sfx_volume)
	
	# Apply video settings
	if current_settings.fullscreen:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	
	if current_settings.vsync:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
	else:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)

func _update_ui_from_settings() -> void:
	"""Update UI controls to match current settings"""
	# Update audio sliders
	if master_volume_slider:
		master_volume_slider.value = current_settings.master_volume
		_update_volume_label(master_volume_value, current_settings.master_volume)
	
	if music_volume_slider:
		music_volume_slider.value = current_settings.music_volume
		_update_volume_label(music_volume_value, current_settings.music_volume)
	
	if sfx_volume_slider:
		sfx_volume_slider.value = current_settings.sfx_volume
		_update_volume_label(sfx_volume_value, current_settings.sfx_volume)
	
	# Update video checkboxes
	if fullscreen_check:
		fullscreen_check.button_pressed = current_settings.fullscreen
	
	if vsync_check:
		vsync_check.button_pressed = current_settings.vsync

func _update_volume_label(label: Label, value: float) -> void:
	"""Update volume percentage label"""
	if label:
		label.text = str(int(value * 100)) + "%"
		label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.8, 1.0))

# Signal Callbacks - Audio

func _on_master_volume_changed(value: float) -> void:
	"""Handle master volume slider change"""
	current_settings.master_volume = value
	_update_volume_label(master_volume_value, value)
	
	# Apply immediately for preview
	if has_node("/root/AudioManager"):
		var audio_manager = get_node("/root/AudioManager")
		if audio_manager.has_method("set_master_volume"):
			audio_manager.set_master_volume(value)
	
	# Play test sound for feedback
	_play_test_sound()

func _on_music_volume_changed(value: float) -> void:
	"""Handle music volume slider change"""
	current_settings.music_volume = value
	_update_volume_label(music_volume_value, value)
	
	# Apply immediately for preview
	if has_node("/root/AudioManager"):
		var audio_manager = get_node("/root/AudioManager")
		if audio_manager.has_method("set_music_volume"):
			audio_manager.set_music_volume(value)

func _on_sfx_volume_changed(value: float) -> void:
	"""Handle SFX volume slider change"""
	current_settings.sfx_volume = value
	_update_volume_label(sfx_volume_value, value)
	
	# Apply immediately for preview
	if has_node("/root/AudioManager"):
		var audio_manager = get_node("/root/AudioManager")
		if audio_manager.has_method("set_sfx_volume"):
			audio_manager.set_sfx_volume(value)
	
	# Play test sound for feedback
	_play_test_sound()

# Signal Callbacks - Video

func _on_fullscreen_toggled(button_pressed: bool) -> void:
	"""Handle fullscreen toggle"""
	current_settings.fullscreen = button_pressed
	
	# Apply immediately
	if button_pressed:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

func _on_vsync_toggled(button_pressed: bool) -> void:
	"""Handle VSync toggle"""
	current_settings.vsync = button_pressed
	
	# Apply immediately
	if button_pressed:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
	else:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)

# Audio Feedback

func _play_test_sound() -> void:
	"""Play a test sound for volume preview"""
	if has_node("/root/AudioManager"):
		var audio_manager = get_node("/root/AudioManager")
		if audio_manager.has_method("play_sfx"):
			audio_manager.play_sfx("ui_click")

# Button Action Handlers

func _on_menu_button_pressed(button_name: String) -> void:
	"""Handle menu button presses"""
	super._on_menu_button_pressed(button_name)
	
	match button_name:
		"back":
			_handle_back_button()
		_:
			if OS.is_debug_build():
				print("Unhandled settings menu button press: ", button_name)

func _handle_back_button() -> void:
	"""Handle back button press"""
	if OS.is_debug_build():
		print("Closing settings menu...")
	
	# Save settings before closing
	_save_settings()
	
	# Close menu
	close_menu(true)

# Public API

func open_settings_from_menu(from_menu: String = "") -> void:
	"""Open settings from another menu"""
	_returning_to_menu = from_menu
	open_menu(true)

func show_settings_menu() -> void:
	"""Public method to show settings menu"""
	open_menu(true)

func hide_settings_menu() -> void:
	"""Public method to hide settings menu"""
	close_menu(true)

# Override BaseMenu close behavior

func close_menu(animate: bool = true) -> void:
	"""Close settings menu and optionally return to previous menu"""
	# Call parent implementation
	super.close_menu(animate)
	
	# If we know which menu to return to, navigate back
	if not _returning_to_menu.is_empty():
		if has_node("/root/EventBus"):
			var event_bus = get_node("/root/EventBus")
			match _returning_to_menu:
				"main_menu":
					if event_bus.has_signal("menu_navigation_requested"):
						event_bus.menu_navigation_requested.emit("settings_menu", "main_menu")
				"pause_menu":
					if event_bus.has_signal("menu_navigation_requested"):
						event_bus.menu_navigation_requested.emit("settings_menu", "pause_menu")
		_returning_to_menu = ""

# Input Handling

func _unhandled_input(event: InputEvent) -> void:
	# Only handle input if menu is open
	if not is_menu_open():
		return
	
	# Call parent input handling
	super._unhandled_input(event)
	
	# Handle tab switching with number keys
	if tab_container:
		if event.is_action_pressed("ui_1") or event.is_action_pressed("ui_text_backspace"):
			tab_container.current_tab = 0  # Audio tab
			get_viewport().set_input_as_handled()
		elif event.is_action_pressed("ui_2"):
			tab_container.current_tab = 1  # Video tab
			get_viewport().set_input_as_handled()
		elif event.is_action_pressed("ui_3"):
			tab_container.current_tab = 2  # Controls tab
			get_viewport().set_input_as_handled()

# Debug Methods

func get_settings_menu_debug_info() -> Dictionary:
	"""Get debug information specific to settings menu"""
	var base_info = get_menu_debug_info()
	base_info.merge({
		"current_settings": current_settings,
		"returning_to_menu": _returning_to_menu,
		"current_tab": tab_container.current_tab if tab_container else -1,
		"audio_manager_available": has_node("/root/AudioManager"),
		"game_manager_available": GameManager != null
	})
	return base_info

func debug_print_settings_state() -> void:
	"""Print settings menu specific debug state"""
	if OS.is_debug_build():
		print("SettingsMenu Debug State: ", get_settings_menu_debug_info())