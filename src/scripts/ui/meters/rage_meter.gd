class_name RageMeter
extends Control
## Simple UI component displaying the player's rage level

# Node references
@onready var label: Label = $VBoxContainer/Label
@onready var progress_bar: ProgressBar = $VBoxContainer/ProgressBar

# Current value
var current_rage: float = 0.0

func _ready() -> void:
	# Set up progress bar
	progress_bar.min_value = 0.0
	progress_bar.max_value = 100.0
	progress_bar.value = 0.0
	
	# Connect to emotional state updates
	if GameManager.emotional_state:
		GameManager.emotional_state.rage_level_changed.connect(_on_rage_level_changed)
		# Initialize with current value
		_update_display(GameManager.emotional_state.rage_level)
	
	# Connect to event bus
	EventBus.rage_updated.connect(_on_rage_updated)
	
	# Set initial label
	label.text = "RAGE: 0%"

func _on_rage_level_changed(new_rage: float, _old_rage: float) -> void:
	_update_display(new_rage)

func _on_rage_updated(new_rage: float) -> void:
	_update_display(new_rage)

func _update_display(new_rage: float) -> void:
	current_rage = clamp(new_rage, 0.0, 100.0)
	progress_bar.value = current_rage
	label.text = "RAGE: %d%%" % int(current_rage)

# Debug method to manually set rage (for testing)
func set_rage_debug(value: float) -> void:
	_update_display(value)

# Method to get current displayed rage value
func get_current_rage() -> float:
	return current_rage
