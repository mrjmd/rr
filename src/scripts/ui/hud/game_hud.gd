class_name GameHUD
extends Control
## Main HUD containing all UI meters and status indicators

# Node references
@onready var rage_meter: RageMeter = $HUDContainer/VBoxContainer/RageMeter
@onready var reservoir_meter: ReservoirMeter = $HUDContainer/VBoxContainer/ReservoirMeter
@onready var debug_panel: Control = $DebugPanel

# HUD state
var is_hud_visible: bool = true
var is_debug_mode: bool = false

func _ready() -> void:
	# Set up proper anchoring for responsive design
	_setup_anchoring()
	
	# Connect to game events
	_connect_signals()
	
	# Set up debug mode
	is_debug_mode = OS.is_debug_build()
	if debug_panel:
		debug_panel.visible = is_debug_mode
	
	# Handle input for debug controls
	if is_debug_mode:
		_setup_debug_controls()

func _setup_anchoring() -> void:
	# Anchor HUD to top-left corner
	set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	
	# Ensure HUD stays in proper position regardless of screen size
	anchor_left = 0.0
	anchor_top = 0.0
	anchor_right = 0.0
	anchor_bottom = 0.0
	
	# Set margins for proper spacing from screen edge
	offset_left = 20
	offset_top = 20

func _connect_signals() -> void:
	# Game state events
	EventBus.game_paused.connect(_on_game_paused)
	EventBus.game_resumed.connect(_on_game_resumed)
	EventBus.scene_transition_requested.connect(_on_scene_transition)
	
	# Debug events
	if is_debug_mode:
		EventBus.debug_rage_modified.connect(_on_debug_rage_modified)

func _setup_debug_controls() -> void:
	if not debug_panel:
		return
	
	# Create debug buttons and sliders
	var debug_vbox = VBoxContainer.new()
	debug_panel.add_child(debug_vbox)
	
	# Debug label
	var debug_label = Label.new()
	debug_label.text = "DEBUG CONTROLS"
	debug_vbox.add_child(debug_label)
	
	# Rage slider
	var rage_container = HBoxContainer.new()
	debug_vbox.add_child(rage_container)
	
	var rage_label = Label.new()
	rage_label.text = "Rage:"
	rage_label.custom_minimum_size.x = 60
	rage_container.add_child(rage_label)
	
	var rage_slider = HSlider.new()
	rage_slider.min_value = 0.0
	rage_slider.max_value = 100.0
	rage_slider.step = 1.0
	rage_slider.custom_minimum_size.x = 150
	rage_slider.value_changed.connect(_on_debug_rage_slider_changed)
	rage_container.add_child(rage_slider)
	
	# Reservoir slider
	var reservoir_container = HBoxContainer.new()
	debug_vbox.add_child(reservoir_container)
	
	var reservoir_label = Label.new()
	reservoir_label.text = "Reservoir:"
	reservoir_label.custom_minimum_size.x = 60
	reservoir_container.add_child(reservoir_label)
	
	var reservoir_slider = HSlider.new()
	reservoir_slider.min_value = 0.0
	reservoir_slider.max_value = 100.0
	reservoir_slider.step = 1.0
	reservoir_slider.custom_minimum_size.x = 150
	reservoir_slider.value_changed.connect(_on_debug_reservoir_slider_changed)
	reservoir_container.add_child(reservoir_slider)
	
	# Show reservoir button
	var show_reservoir_btn = Button.new()
	show_reservoir_btn.text = "Show Reservoir"
	show_reservoir_btn.pressed.connect(_on_debug_show_reservoir)
	debug_vbox.add_child(show_reservoir_btn)
	
	# Reset button
	var reset_btn = Button.new()
	reset_btn.text = "Reset All"
	reset_btn.pressed.connect(_on_debug_reset_all)
	debug_vbox.add_child(reset_btn)

func _input(event: InputEvent) -> void:
	if not is_debug_mode:
		return
	
	# Toggle HUD visibility with F1
	if event.is_action_pressed("debug_toggle_hud"):
		toggle_hud_visibility()
	
	# Toggle debug panel with F2
	elif event.is_action_pressed("debug_toggle_panel"):
		toggle_debug_panel()

func toggle_hud_visibility() -> void:
	is_hud_visible = !is_hud_visible
	
	var tween = create_tween()
	if is_hud_visible:
		tween.tween_property(self, "modulate", Color.WHITE, 0.3)
	else:
		tween.tween_property(self, "modulate", Color.TRANSPARENT, 0.3)

func toggle_debug_panel() -> void:
	if debug_panel:
		debug_panel.visible = !debug_panel.visible

func _on_game_paused() -> void:
	# Dim HUD when game is paused
	modulate = Color(0.7, 0.7, 0.7, 0.8)

func _on_game_resumed() -> void:
	# Restore normal HUD appearance
	modulate = Color.WHITE

func _on_scene_transition(scene_path: String) -> void:
	# Handle HUD behavior during scene transitions
	var transition_tween = create_tween()
	transition_tween.tween_property(self, "modulate", Color(1.0, 1.0, 1.0, 0.5), 0.5)

func _on_debug_rage_modified(amount: float) -> void:
	# Handle debug rage modifications
	if GameManager.emotional_state:
		GameManager.emotional_state.rage_level += amount

# Debug control callbacks
func _on_debug_rage_slider_changed(value: float) -> void:
	if GameManager.emotional_state:
		GameManager.emotional_state.rage_level = value

func _on_debug_reservoir_slider_changed(value: float) -> void:
	if GameManager.emotional_state:
		GameManager.emotional_state.reservoir_level = value

func _on_debug_show_reservoir() -> void:
	if reservoir_meter:
		reservoir_meter.force_show()

func _on_debug_reset_all() -> void:
	if GameManager.emotional_state:
		GameManager.emotional_state.reset()
	
	if reservoir_meter:
		reservoir_meter.hide_meter()

# Public methods for external control
func show_hud() -> void:
	visible = true
	is_hud_visible = true
	modulate = Color.WHITE

func hide_hud() -> void:
	is_hud_visible = false
	modulate = Color.TRANSPARENT

func set_hud_alpha(alpha: float) -> void:
	modulate = Color(1.0, 1.0, 1.0, alpha)

# Getters for meter states
func get_rage_level() -> float:
	if rage_meter:
		return rage_meter.get_current_rage()
	return 0.0

func get_reservoir_level() -> float:
	if reservoir_meter:
		return reservoir_meter.get_current_reservoir()
	return 0.0

func is_rage_critical() -> bool:
	if rage_meter:
		return rage_meter.is_critical()
	return false

func is_reservoir_critical() -> bool:
	if reservoir_meter:
		return reservoir_meter.is_in_critical()
	return false

# Method to update HUD for different game phases
func set_hud_mode(mode: String) -> void:
	match mode:
		"dialogue":
			# Slightly fade HUD during dialogue
			set_hud_alpha(0.6)
		"minigame":
			# Hide or minimize HUD during mini-games
			set_hud_alpha(0.3)
		"normal":
			# Full visibility during normal gameplay
			set_hud_alpha(1.0)
		"cutscene":
			# Hide HUD during cutscenes
			hide_hud()

# Animation method for attention-grabbing effects
func pulse_attention() -> void:
	var attention_tween = create_tween()
	attention_tween.set_loops(3)
	
	attention_tween.tween_property(self, "scale", Vector2(1.1, 1.1), 0.2)
	attention_tween.tween_property(self, "scale", Vector2.ONE, 0.2)

# Method to handle emotional state changes
func on_emotional_state_changed(new_state: String) -> void:
	match new_state:
		"breaking", "angry":
			pulse_attention()
		"overwhelmed":
			# Subtle visual indication
			var warning_tween = create_tween()
			warning_tween.tween_property(self, "modulate", Color(1.2, 1.0, 1.0, 1.0), 0.3)
			warning_tween.tween_property(self, "modulate", Color.WHITE, 0.3)