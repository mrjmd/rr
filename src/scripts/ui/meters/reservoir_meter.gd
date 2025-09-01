class_name ReservoirMeter
extends Control
## Simple UI component displaying the reservoir of suppressed emotions

# Node references
@onready var label: Label = $VBoxContainer/Label
@onready var progress_bar: ProgressBar = $VBoxContainer/ProgressBar

# Current values
var current_reservoir: float = 0.0
var first_suppression_occurred: bool = false

func _ready() -> void:
	# Initially hide the meter (only appears after first suppression)
	visible = false
	
	# Set up progress bar
	progress_bar.min_value = 0.0
	progress_bar.max_value = 100.0
	progress_bar.value = 0.0
	
	# Connect to emotional state updates
	if GameManager.emotional_state:
		GameManager.emotional_state.reservoir_level_changed.connect(_on_reservoir_level_changed)
		GameManager.emotional_state.rage_suppressed.connect(_on_rage_suppressed)
		# Initialize with current value
		if GameManager.emotional_state.suppression_count > 0:
			first_suppression_occurred = true
			_make_visible()
			_update_display(GameManager.emotional_state.reservoir_level)
	
	# Connect to event bus
	EventBus.reservoir_updated.connect(_on_reservoir_updated)
	EventBus.suppression_activated.connect(_on_suppression_activated)
	
	# Set initial label
	label.text = "RESERVOIR: 0%"

func _on_rage_suppressed(_amount_suppressed: float) -> void:
	if not first_suppression_occurred:
		first_suppression_occurred = true
		_make_visible()

func _on_suppression_activated() -> void:
	if not first_suppression_occurred:
		first_suppression_occurred = true
		_make_visible()

func _make_visible() -> void:
	visible = true
	
func _on_reservoir_level_changed(new_reservoir: float, _old_reservoir: float) -> void:
	_update_display(new_reservoir)

func _on_reservoir_updated(new_reservoir: float) -> void:
	_update_display(new_reservoir)

func _update_display(new_reservoir: float) -> void:
	if not visible:
		return
		
	current_reservoir = clamp(new_reservoir, 0.0, 100.0)
	progress_bar.value = current_reservoir
	label.text = "RESERVOIR: %d%%" % int(current_reservoir)

# Method to force show the meter (for testing)
func force_show() -> void:
	first_suppression_occurred = true
	_make_visible()

# Method to hide the meter (for reset)
func hide_meter() -> void:
	first_suppression_occurred = false
	visible = false

# Debug method to manually set reservoir (for testing)
func set_reservoir_debug(value: float) -> void:
	if not visible:
		force_show()
	_update_display(value)

# Method to get current displayed reservoir value
func get_current_reservoir() -> float:
	return current_reservoir
