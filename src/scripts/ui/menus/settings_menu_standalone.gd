class_name SettingsMenuStandalone
extends CanvasLayer
## Standalone Settings menu for Rando's Reservoir (temporary version without BaseMenu dependency)

# Settings tabs
@onready var tab_container: TabContainer = $MenuContainer/MainPanel/VBoxContainer/TabContainer

# Audio tab controls
@onready var master_volume_slider: HSlider = $MenuContainer/MainPanel/VBoxContainer/TabContainer/Audio/VBoxContainer/MasterVolumeContainer/MasterVolumeSlider
@onready var master_volume_value: Label = $MenuContainer/MainPanel/VBoxContainer/TabContainer/Audio/VBoxContainer/MasterVolumeContainer/MasterVolumeValue
@onready var music_volume_slider: HSlider = $MenuContainer/MainPanel/VBoxContainer/TabContainer/Audio/VBoxContainer/MusicVolumeContainer/MusicVolumeSlider
@onready var music_volume_value: Label = $MenuContainer/MainPanel/VBoxContainer/TabContainer/Audio/VBoxContainer/MusicVolumeContainer/MusicVolumeValue
@onready var sfx_volume_slider: HSlider = $MenuContainer/MainPanel/VBoxContainer/TabContainer/Audio/VBoxContainer/SFXVolumeContainer/SFXVolumeSlider
@onready var sfx_volume_value: Label = $MenuContainer/MainPanel/VBoxContainer/TabContainer/Audio/VBoxContainer/SFXVolumeContainer/SFXVolumeValue

# Video tab controls
@onready var fullscreen_check: CheckBox = $MenuContainer/MainPanel/VBoxContainer/TabContainer/Video/VBoxContainer/FullscreenContainer/FullscreenCheck
@onready var vsync_check: CheckBox = $MenuContainer/MainPanel/VBoxContainer/TabContainer/Video/VBoxContainer/VsyncContainer/VsyncCheck
@onready var resolution_option: OptionButton = $MenuContainer/MainPanel/VBoxContainer/TabContainer/Video/VBoxContainer/ResolutionContainer/ResolutionOption

# Controls tab
@onready var controls_info: Label = $MenuContainer/MainPanel/VBoxContainer/TabContainer/Controls/VBoxContainer/ControlsInfo

# Back button  
@onready var back_button: Button = $MenuContainer/MainPanel/VBoxContainer/ButtonContainer/BackButton

# UI containers
@onready var main_panel: Panel = $MenuContainer/MainPanel
@onready var title_label: Label = $MenuContainer/MainPanel/VBoxContainer/TitleContainer/TitleLabel
@onready var background_overlay: ColorRect = $MenuContainer/BackgroundOverlay

# Signals
signal settings_closed
signal volume_changed(type: String, value: float)
signal video_setting_changed(setting: String, value: bool)

# Settings state
var current_settings: Dictionary = {
	"master_volume": 1.0,
	"music_volume": 1.0,
	"sfx_volume": 1.0,
	"fullscreen": false,
	"vsync": true
}

func _ready() -> void:
	# Set layer
	layer = 225
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	
	# Initially hidden
	visible = false
	
	# Setup UI
	_setup_ui()
	
	# Connect signals
	_connect_signals()
	
	# Load settings
	_load_settings()
	
	if OS.is_debug_build():
		print("SettingsMenuStandalone initialized")

func _setup_ui() -> void:
	"""Setup all UI elements"""
	_setup_title()
	_setup_tabs()
	_setup_audio_controls()
	_setup_video_controls()
	_setup_controls_info()
	_setup_styling()

func _setup_title() -> void:
	"""Setup title label"""
	if title_label:
		title_label.text = "SETTINGS"
		title_label.add_theme_font_size_override("font_size", 32)
		title_label.add_theme_color_override("font_color", Color(0.9, 0.9, 1.0, 1.0))

func _setup_tabs() -> void:
	"""Setup tab container"""
	if tab_container:
		tab_container.set_tab_title(0, "Audio")
		tab_container.set_tab_title(1, "Video")
		tab_container.set_tab_title(2, "Controls")

func _setup_audio_controls() -> void:
	"""Setup audio slider controls"""
	# Master Volume
	if master_volume_slider:
		master_volume_slider.min_value = 0.0
		master_volume_slider.max_value = 1.0
		master_volume_slider.step = 0.01
		master_volume_slider.value = current_settings.master_volume
	
	# Music Volume
	if music_volume_slider:
		music_volume_slider.min_value = 0.0
		music_volume_slider.max_value = 1.0
		music_volume_slider.step = 0.01
		music_volume_slider.value = current_settings.music_volume
	
	# SFX Volume
	if sfx_volume_slider:
		sfx_volume_slider.min_value = 0.0
		sfx_volume_slider.max_value = 1.0
		sfx_volume_slider.step = 0.01
		sfx_volume_slider.value = current_settings.sfx_volume

func _setup_video_controls() -> void:
	"""Setup video controls"""
	if fullscreen_check:
		fullscreen_check.text = "Fullscreen"
		fullscreen_check.button_pressed = current_settings.fullscreen
	
	if vsync_check:
		vsync_check.text = "Vertical Sync"
		vsync_check.button_pressed = current_settings.vsync
	
	if resolution_option:
		resolution_option.add_item("1920x1080 (Current)")
		resolution_option.add_item("1366x768") 
		resolution_option.add_item("1024x768")
		resolution_option.selected = 0
		resolution_option.disabled = true  # Placeholder

func _setup_controls_info() -> void:
	"""Setup controls information"""
	if controls_info:
		controls_info.text = """Input Remapping

Controls can be remapped through the pause menu during gameplay.

Current Bindings:
• Move: Arrow Keys / WASD
• Interact: Space / Enter
• Pause: Escape
• Menu Navigation: Arrow Keys / Tab

Input remapping interface will be available in a future update."""
		controls_info.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

func _setup_styling() -> void:
	"""Setup visual styling"""
	# Background overlay
	if background_overlay:
		background_overlay.color = Color(0, 0, 0, 0.5)
	
	# Main panel
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

func _connect_signals() -> void:
	"""Connect all UI signals"""
	# Audio sliders
	if master_volume_slider:
		master_volume_slider.value_changed.connect(_on_master_volume_changed)
	if music_volume_slider:
		music_volume_slider.value_changed.connect(_on_music_volume_changed)
	if sfx_volume_slider:
		sfx_volume_slider.value_changed.connect(_on_sfx_volume_changed)
	
	# Video checkboxes
	if fullscreen_check:
		fullscreen_check.toggled.connect(_on_fullscreen_toggled)
	if vsync_check:
		vsync_check.toggled.connect(_on_vsync_toggled)
	
	# Back button
	if back_button:
		back_button.pressed.connect(_on_back_button_pressed)

func _load_settings() -> void:
	"""Load current settings"""
	# Try GameManager first, then defaults
	if GameManager and GameManager.has_method("get_setting"):
		current_settings.master_volume = GameManager.get_setting("master_volume", 1.0)
		current_settings.music_volume = GameManager.get_setting("music_volume", 1.0)
		current_settings.sfx_volume = GameManager.get_setting("sfx_volume", 1.0)
		current_settings.fullscreen = GameManager.get_setting("fullscreen", false)
		current_settings.vsync = GameManager.get_setting("vsync", true)
	else:
		# Use system defaults
		current_settings.fullscreen = DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN
		current_settings.vsync = DisplayServer.window_get_vsync_mode() != DisplayServer.VSYNC_DISABLED
	
	_update_ui_from_settings()

func _save_settings() -> void:
	"""Save current settings"""
	if GameManager and GameManager.has_method("set_setting"):
		for key in current_settings:
			GameManager.set_setting(key, current_settings[key])
		
		if GameManager.has_method("save_settings"):
			GameManager.save_settings()
	
	_apply_settings()

func _apply_settings() -> void:
	"""Apply settings to the system"""
	# Apply audio settings
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
	"""Update UI to match current settings"""
	if master_volume_slider:
		master_volume_slider.value = current_settings.master_volume
		_update_volume_label(master_volume_value, current_settings.master_volume)
	
	if music_volume_slider:
		music_volume_slider.value = current_settings.music_volume
		_update_volume_label(music_volume_value, current_settings.music_volume)
	
	if sfx_volume_slider:
		sfx_volume_slider.value = current_settings.sfx_volume
		_update_volume_label(sfx_volume_value, current_settings.sfx_volume)
	
	if fullscreen_check:
		fullscreen_check.button_pressed = current_settings.fullscreen
	
	if vsync_check:
		vsync_check.button_pressed = current_settings.vsync

func _update_volume_label(label: Label, value: float) -> void:
	"""Update volume percentage label"""
	if label:
		label.text = str(int(value * 100)) + "%"

# Signal Handlers

func _on_master_volume_changed(value: float) -> void:
	"""Handle master volume change"""
	current_settings.master_volume = value
	_update_volume_label(master_volume_value, value)
	
	# Apply immediately
	if has_node("/root/AudioManager"):
		var audio_manager = get_node("/root/AudioManager")
		if audio_manager.has_method("set_master_volume"):
			audio_manager.set_master_volume(value)
	
	volume_changed.emit("master", value)

func _on_music_volume_changed(value: float) -> void:
	"""Handle music volume change"""
	current_settings.music_volume = value
	_update_volume_label(music_volume_value, value)
	
	# Apply immediately
	if has_node("/root/AudioManager"):
		var audio_manager = get_node("/root/AudioManager")
		if audio_manager.has_method("set_music_volume"):
			audio_manager.set_music_volume(value)
	
	volume_changed.emit("music", value)

func _on_sfx_volume_changed(value: float) -> void:
	"""Handle SFX volume change"""
	current_settings.sfx_volume = value
	_update_volume_label(sfx_volume_value, value)
	
	# Apply immediately
	if has_node("/root/AudioManager"):
		var audio_manager = get_node("/root/AudioManager")
		if audio_manager.has_method("set_sfx_volume"):
			audio_manager.set_sfx_volume(value)
	
	volume_changed.emit("sfx", value)

func _on_fullscreen_toggled(button_pressed: bool) -> void:
	"""Handle fullscreen toggle"""
	current_settings.fullscreen = button_pressed
	
	# Apply immediately
	if button_pressed:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	
	video_setting_changed.emit("fullscreen", button_pressed)

func _on_vsync_toggled(button_pressed: bool) -> void:
	"""Handle VSync toggle"""
	current_settings.vsync = button_pressed
	
	# Apply immediately
	if button_pressed:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
	else:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	
	video_setting_changed.emit("vsync", button_pressed)

func _on_back_button_pressed() -> void:
	"""Handle back button press"""
	_save_settings()
	close_settings()

# Public API

func open_settings() -> void:
	"""Open settings menu"""
	visible = true
	get_tree().paused = true
	
	if back_button:
		back_button.grab_focus()
	
	if OS.is_debug_build():
		print("Settings menu opened")

func close_settings() -> void:
	"""Close settings menu"""
	visible = false
	get_tree().paused = false
	settings_closed.emit()
	
	if OS.is_debug_build():
		print("Settings menu closed")

func is_open() -> bool:
	"""Check if settings menu is open"""
	return visible

# Input handling

func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	
	if event.is_action_pressed("ui_cancel"):
		close_settings()
		get_viewport().set_input_as_handled()