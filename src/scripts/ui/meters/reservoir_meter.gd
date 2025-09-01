class_name ReservoirMeter
extends Control
## UI component displaying the reservoir of suppressed emotions

# Node references
@onready var progress_bar: ProgressBar = $HBoxContainer/ProgressContainer/ProgressBar
@onready var label: Label = $HBoxContainer/Label
@onready var percentage_label: Label = $HBoxContainer/ProgressContainer/PercentageLabel
@onready var warning_icon: TextureRect = $HBoxContainer/ProgressContainer/WarningIcon
# Tween will be created dynamically in Godot 4
var tween: Tween

# Visual components
var progress_style: StyleBoxFlat
var background_style: StyleBoxFlat

# Warning thresholds
const WARNING_THRESHOLD: float = 70.0
const CRITICAL_THRESHOLD: float = 85.0

# Colors for different states
const COLOR_LOW: Color = Color(0.3, 0.6, 0.9, 1.0)  # Blue
const COLOR_MEDIUM: Color = Color(0.9, 0.6, 0.3, 1.0)  # Orange
const COLOR_HIGH: Color = Color(0.9, 0.3, 0.3, 1.0)  # Red
const COLOR_CRITICAL: Color = Color(0.6, 0.1, 0.1, 1.0)  # Dark Red

# Animation variables
var is_warning: bool = false
var is_visible_to_player: bool = false

# Current values
var current_reservoir: float = 0.0
var target_reservoir: float = 0.0

# Visibility control
var first_suppression_occurred: bool = false

func _ready() -> void:
	# Initially hide the meter (only appears after first suppression)
	visible = false
	
	# Set up UI
	_setup_progress_bar()
	_setup_styles()
	
	# Connect to emotional state updates
	if GameManager.emotional_state:
		GameManager.emotional_state.reservoir_level_changed.connect(_on_reservoir_level_changed)
		GameManager.emotional_state.rage_suppressed.connect(_on_rage_suppressed)
		# Initialize with current value
		if GameManager.emotional_state.suppression_count > 0:
			first_suppression_occurred = true
			_make_visible()
			_update_display(GameManager.emotional_state.reservoir_level, false)
	
	# Connect to event bus
	EventBus.reservoir_updated.connect(_on_reservoir_updated)
	EventBus.suppression_activated.connect(_on_suppression_activated)
	
	# Set initial label and percentage
	label.text = "RESERVOIR"
	percentage_label.text = "0%"
	
	# Hide warning icon initially
	if warning_icon:
		warning_icon.visible = false

func _setup_progress_bar() -> void:
	progress_bar.min_value = 0.0
	progress_bar.max_value = 100.0
	progress_bar.value = 0.0
	progress_bar.step = 0.1

func _setup_styles() -> void:
	# Create custom style for progress bar
	progress_style = StyleBoxFlat.new()
	progress_style.bg_color = COLOR_LOW
	progress_style.corner_radius_top_left = 4
	progress_style.corner_radius_top_right = 4
	progress_style.corner_radius_bottom_left = 4
	progress_style.corner_radius_bottom_right = 4
	
	background_style = StyleBoxFlat.new()
	background_style.bg_color = Color(0.1, 0.1, 0.2, 1.0)  # Dark blue background
	background_style.border_width_left = 2
	background_style.border_width_right = 2
	background_style.border_width_top = 2
	background_style.border_width_bottom = 2
	background_style.border_color = Color(0.5, 0.7, 0.9, 1.0)  # Light blue border
	background_style.corner_radius_top_left = 4
	background_style.corner_radius_top_right = 4
	background_style.corner_radius_bottom_left = 4
	background_style.corner_radius_bottom_right = 4
	
	# Apply styles
	progress_bar.add_theme_stylebox_override("fill", progress_style)
	progress_bar.add_theme_stylebox_override("background", background_style)

func _on_rage_suppressed(_amount_suppressed: float) -> void:
	if not first_suppression_occurred:
		first_suppression_occurred = true
		_make_visible()

func _on_suppression_activated() -> void:
	if not first_suppression_occurred:
		first_suppression_occurred = true
		_make_visible()

func _make_visible() -> void:
	if is_visible_to_player:
		return
		
	is_visible_to_player = true
	
	# Fade in effect
	visible = true
	modulate = Color.TRANSPARENT
	
	var fade_tween = create_tween()
	fade_tween.tween_property(self, "modulate", Color.WHITE, 0.8)

func _on_reservoir_level_changed(new_reservoir: float, _old_reservoir: float) -> void:
	_update_display(new_reservoir, true)

func _on_reservoir_updated(new_reservoir: float) -> void:
	_update_display(new_reservoir, true)

func _update_display(new_reservoir: float, animate: bool = true) -> void:
	if not is_visible_to_player:
		return
		
	target_reservoir = clamp(new_reservoir, 0.0, 100.0)
	
	if animate:
		_animate_to_value(target_reservoir)
	else:
		current_reservoir = target_reservoir
		progress_bar.value = current_reservoir
		_update_visual_effects()

func _animate_to_value(target_value: float) -> void:
	if tween:
		tween.kill()
	
	tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	
	# Animate progress bar value
	tween.parallel().tween_method(_set_progress_value, current_reservoir, target_value, 0.6)
	
	# Update current reservoir for effects
	current_reservoir = target_value
	
	# Apply visual effects after animation
	tween.tween_callback(_update_visual_effects)

func _set_progress_value(value: float) -> void:
	progress_bar.value = value

func _update_visual_effects() -> void:
	# Update color based on reservoir level
	var color = _get_reservoir_color(current_reservoir)
	progress_style.bg_color = color
	
	# Update percentage label on the progress bar
	percentage_label.text = "%d%%" % int(current_reservoir)
	
	# Handle warning effects
	if current_reservoir >= WARNING_THRESHOLD:
		_start_warning_effects()
	else:
		_stop_warning_effects()

func _get_reservoir_color(reservoir_value: float) -> Color:
	if reservoir_value >= CRITICAL_THRESHOLD:
		return COLOR_CRITICAL
	elif reservoir_value >= WARNING_THRESHOLD:
		return COLOR_HIGH
	elif reservoir_value >= 40.0:
		return COLOR_MEDIUM
	else:
		return COLOR_LOW

func _start_warning_effects() -> void:
	if not is_warning:
		is_warning = true
		
		# Show warning icon
		if warning_icon:
			warning_icon.visible = true
			_pulse_warning_icon()
		
		# Add subtle pulsing to the entire meter
		if current_reservoir >= CRITICAL_THRESHOLD:
			_pulse_critical()

func _stop_warning_effects() -> void:
	is_warning = false
	
	# Hide warning icon
	if warning_icon:
		warning_icon.visible = false
	
	# Reset visual effects
	modulate = Color.WHITE
	scale = Vector2.ONE

func _pulse_warning_icon() -> void:
	if not is_warning or not warning_icon:
		return
	
	var icon_tween = create_tween()
	icon_tween.set_loops()
	
	# Pulse the warning icon
	icon_tween.tween_property(warning_icon, "modulate", Color(1.0, 0.5, 0.5, 1.0), 0.5)
	icon_tween.tween_property(warning_icon, "modulate", Color.WHITE, 0.5)
	
	# Continue pulsing if still in warning state
	icon_tween.tween_callback(func():
		if is_warning:
			_pulse_warning_icon()
	)

func _pulse_critical() -> void:
	if current_reservoir < CRITICAL_THRESHOLD:
		return
	
	var critical_tween = create_tween()
	critical_tween.set_loops()
	
	# Pulse the entire meter
	critical_tween.parallel().tween_property(self, "modulate", Color(1.2, 1.0, 1.0, 1.0), 0.4)
	critical_tween.parallel().tween_property(self, "modulate", Color.WHITE, 0.4)
	
	critical_tween.tween_callback(func():
		if current_reservoir >= CRITICAL_THRESHOLD:
			_pulse_critical()
	)

# Method to force show the meter (for testing)
func force_show() -> void:
	first_suppression_occurred = true
	_make_visible()

# Method to hide the meter (for reset)
func hide_meter() -> void:
	first_suppression_occurred = false
	is_visible_to_player = false
	visible = false

# Debug method to manually set reservoir (for testing)
func set_reservoir_debug(value: float) -> void:
	if not is_visible_to_player:
		force_show()
	_update_display(value, true)

# Method to get current displayed reservoir value
func get_current_reservoir() -> float:
	return current_reservoir

# Method to check if reservoir is in warning state
func is_in_warning() -> bool:
	return current_reservoir >= WARNING_THRESHOLD

# Method to check if reservoir is in critical state
func is_in_critical() -> bool:
	return current_reservoir >= CRITICAL_THRESHOLD

# Method to check if the meter should be visible
func should_be_visible() -> bool:
	return first_suppression_occurred
