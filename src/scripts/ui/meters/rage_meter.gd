class_name RageMeter
extends Control
## UI component displaying the player's rage level with visual effects and thresholds

# Node references
@onready var progress_bar: ProgressBar = $VBoxContainer/ProgressContainer/ProgressBar
@onready var label: Label = $VBoxContainer/Label
@onready var threshold_markers: Control = $VBoxContainer/ProgressContainer/ThresholdMarkers
@onready var tween: Tween = $Tween

# Visual components
var progress_style: StyleBoxFlat
var background_style: StyleBoxFlat

# Threshold values
const THRESHOLD_STRESSED: float = 25.0
const THRESHOLD_OVERWHELMED: float = 50.0
const THRESHOLD_ANGRY: float = 75.0
const THRESHOLD_BREAKING: float = 90.0

# Colors for different thresholds
const COLOR_CALM: Color = Color.GREEN
const COLOR_STRESSED: Color = Color.YELLOW
const COLOR_OVERWHELMED: Color = Color.ORANGE
const COLOR_ANGRY: Color = Color.RED
const COLOR_BREAKING: Color = Color.DARK_RED

# Animation variables
var is_pulsing: bool = false
var shake_intensity: float = 0.0
var original_position: Vector2

# Current values
var current_rage: float = 0.0
var target_rage: float = 0.0

func _ready() -> void:
	# Set up UI
	_setup_progress_bar()
	_create_threshold_markers()
	_setup_styles()
	
	# Store original position for shake effect
	original_position = position
	
	# Connect to emotional state updates
	if GameManager.emotional_state:
		GameManager.emotional_state.rage_changed.connect(_on_rage_changed)
		# Initialize with current value
		_update_display(GameManager.emotional_state.rage_level, false)
	
	# Connect to event bus
	EventBus.rage_updated.connect(_on_rage_updated)
	
	# Set initial label
	label.text = "RAGE"

func _setup_progress_bar() -> void:
	progress_bar.min_value = 0.0
	progress_bar.max_value = 100.0
	progress_bar.value = 0.0
	progress_bar.step = 0.1

func _create_threshold_markers() -> void:
	# Create marker lines at thresholds
	var thresholds = [THRESHOLD_STRESSED, THRESHOLD_OVERWHELMED, THRESHOLD_ANGRY, THRESHOLD_BREAKING]
	
	for i in range(thresholds.size()):
		var threshold = thresholds[i]
		var marker = ColorRect.new()
		marker.color = Color.WHITE
		marker.size = Vector2(2, 20)
		marker.position.x = (threshold / 100.0) * progress_bar.size.x - 1
		marker.position.y = -2
		threshold_markers.add_child(marker)

func _setup_styles() -> void:
	# Create custom style for progress bar
	progress_style = StyleBoxFlat.new()
	progress_style.bg_color = COLOR_CALM
	progress_style.corner_radius_top_left = 4
	progress_style.corner_radius_top_right = 4
	progress_style.corner_radius_bottom_left = 4
	progress_style.corner_radius_bottom_right = 4
	
	background_style = StyleBoxFlat.new()
	background_style.bg_color = Color.BLACK
	background_style.border_width_left = 2
	background_style.border_width_right = 2
	background_style.border_width_top = 2
	background_style.border_width_bottom = 2
	background_style.border_color = Color.WHITE
	background_style.corner_radius_top_left = 4
	background_style.corner_radius_top_right = 4
	background_style.corner_radius_bottom_left = 4
	background_style.corner_radius_bottom_right = 4
	
	# Apply styles
	progress_bar.add_theme_stylebox_override("fill", progress_style)
	progress_bar.add_theme_stylebox_override("background", background_style)

func _process(delta: float) -> void:
	# Handle shake effect
	if shake_intensity > 0.0:
		var shake_offset = Vector2(
			randf_range(-shake_intensity, shake_intensity),
			randf_range(-shake_intensity, shake_intensity)
		)
		position = original_position + shake_offset
		
		# Decay shake
		shake_intensity = max(0.0, shake_intensity - delta * 20.0)
		
		if shake_intensity <= 0.0:
			position = original_position

func _on_rage_changed(new_rage: float) -> void:
	_update_display(new_rage, true)

func _on_rage_updated(new_rage: float) -> void:
	_update_display(new_rage, true)

func _update_display(new_rage: float, animate: bool = true) -> void:
	target_rage = clamp(new_rage, 0.0, 100.0)
	
	if animate:
		_animate_to_value(target_rage)
	else:
		current_rage = target_rage
		progress_bar.value = current_rage
		_update_visual_effects()

func _animate_to_value(target_value: float) -> void:
	if tween:
		tween.kill()
	
	tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	
	# Animate progress bar value
	tween.parallel().tween_method(_set_progress_value, current_rage, target_value, 0.5)
	
	# Update current rage for effects
	current_rage = target_value
	
	# Apply visual effects after animation
	tween.tween_callback(_update_visual_effects)

func _set_progress_value(value: float) -> void:
	progress_bar.value = value

func _update_visual_effects() -> void:
	# Update color based on rage level
	var color = _get_rage_color(current_rage)
	progress_style.bg_color = color
	
	# Update label with percentage
	label.text = "RAGE: %d%%" % int(current_rage)
	
	# Handle high rage effects
	if current_rage >= THRESHOLD_ANGRY:
		_start_high_rage_effects()
	else:
		_stop_high_rage_effects()

func _get_rage_color(rage_value: float) -> Color:
	if rage_value >= THRESHOLD_BREAKING:
		return COLOR_BREAKING
	elif rage_value >= THRESHOLD_ANGRY:
		return COLOR_ANGRY
	elif rage_value >= THRESHOLD_OVERWHELMED:
		return COLOR_OVERWHELMED
	elif rage_value >= THRESHOLD_STRESSED:
		return COLOR_STRESSED
	else:
		return COLOR_CALM

func _start_high_rage_effects() -> void:
	# Start pulsing effect
	if not is_pulsing:
		is_pulsing = true
		_pulse_effect()
	
	# Add shake effect for breaking point
	if current_rage >= THRESHOLD_BREAKING:
		shake_intensity = 3.0
	elif current_rage >= THRESHOLD_ANGRY:
		shake_intensity = 1.0

func _stop_high_rage_effects() -> void:
	is_pulsing = false
	shake_intensity = 0.0
	
	# Reset to original properties
	modulate = Color.WHITE
	scale = Vector2.ONE

func _pulse_effect() -> void:
	if not is_pulsing:
		return
	
	var pulse_tween = create_tween()
	pulse_tween.set_loops()
	
	# Pulse modulation
	pulse_tween.parallel().tween_property(self, "modulate", Color(1.2, 1.0, 1.0, 1.0), 0.3)
	pulse_tween.parallel().tween_property(self, "modulate", Color.WHITE, 0.3)
	
	# Slight scale pulse
	pulse_tween.parallel().tween_property(self, "scale", Vector2(1.05, 1.05), 0.3)
	pulse_tween.parallel().tween_property(self, "scale", Vector2.ONE, 0.3)
	
	# Continue pulsing if still high rage
	pulse_tween.tween_callback(func(): 
		if is_pulsing:
			_pulse_effect()
	)

# Debug method to manually set rage (for testing)
func set_rage_debug(value: float) -> void:
	_update_display(value, true)

# Method to get current displayed rage value
func get_current_rage() -> float:
	return current_rage

# Method to check if meter is in critical state
func is_critical() -> bool:
	return current_rage >= THRESHOLD_ANGRY