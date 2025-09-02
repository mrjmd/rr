class_name SettingsMenuSimple
extends CanvasLayer
## Simplified settings menu that works standalone without BaseMenu dependency

# Tab container and controls
@onready var tab_container: TabContainer = $MenuContainer/MainPanel/VBoxContainer/TabContainer
@onready var back_button: Button = $MenuContainer/MainPanel/VBoxContainer/ButtonContainer/BackButton

# UI containers
@onready var main_panel: Panel = $MenuContainer/MainPanel
@onready var title_label: Label = $MenuContainer/MainPanel/VBoxContainer/TitleContainer/TitleLabel
@onready var background_overlay: ColorRect = $MenuContainer/BackgroundOverlay

# Audio controls
@onready var master_volume_slider: HSlider = $MenuContainer/MainPanel/VBoxContainer/TabContainer/Audio/VBoxContainer/MasterVolumeContainer/MasterVolumeSlider
@onready var master_volume_value: Label = $MenuContainer/MainPanel/VBoxContainer/TabContainer/Audio/VBoxContainer/MasterVolumeContainer/MasterVolumeValue

func _ready() -> void:
	# Set layer
	layer = 225
	
	# Check if running standalone
	var is_standalone = get_tree().current_scene == self
	
	# If standalone, ensure visible
	if is_standalone:
		visible = true
		print("SettingsMenuSimple running in standalone mode")
	
	# Setup UI
	_setup_ui()
	
	# Connect signals
	_connect_signals()
	
	# Load saved settings or defaults
	_load_settings()

func _setup_ui() -> void:
	"""Setup UI styling"""
	if title_label:
		title_label.text = "SETTINGS"
		title_label.add_theme_font_size_override("font_size", 32)
	
	if background_overlay:
		background_overlay.color = Color(0, 0, 0, 0.8)
	
	if main_panel:
		var style = StyleBoxFlat.new()
		style.bg_color = Color(0.1, 0.1, 0.15, 0.95)
		style.corner_radius_bottom_left = 8
		style.corner_radius_bottom_right = 8
		style.corner_radius_top_left = 8
		style.corner_radius_top_right = 8
		main_panel.add_theme_stylebox_override("panel", style)

func _connect_signals() -> void:
	"""Connect control signals"""
	if back_button:
		back_button.pressed.connect(_on_back_pressed)
	
	if master_volume_slider:
		master_volume_slider.value_changed.connect(_on_master_volume_changed)

func _load_settings() -> void:
	"""Load settings with defaults"""
	if master_volume_slider:
		master_volume_slider.value = 80
		if master_volume_value:
			master_volume_value.text = "80%"

func _on_master_volume_changed(value: float) -> void:
	"""Handle volume change"""
	if master_volume_value:
		master_volume_value.text = "%d%%" % int(value)
	
	# Apply to audio bus if available
	var audio_manager = get_node_or_null("/root/AudioManager")
	if audio_manager and audio_manager.has_method("set_master_volume"):
		audio_manager.set_master_volume(value / 100.0)

func _on_back_pressed() -> void:
	"""Handle back button"""
	var menu_manager = get_node_or_null("/root/MenuManager")
	if menu_manager:
		menu_manager.close_menu("settings_menu")
	else:
		# Standalone mode - just hide or quit
		if get_tree().current_scene == self:
			get_tree().quit()
		else:
			visible = false

func open_menu(animate: bool = true) -> void:
	"""MenuManager-compatible open"""
	visible = true
	if back_button:
		back_button.grab_focus()

func close_menu(animate: bool = true) -> void:
	"""MenuManager-compatible close"""
	visible = false