class_name EmotionalState
extends Resource
## Manages the player's emotional state including rage, reservoir, and overwhelm

@export_range(0.0, 100.0) var rage_level: float = 0.0:
	set(value):
		var old_rage = rage_level
		rage_level = clamp(value, 0.0, 100.0)
		if rage_level != old_rage:
			rage_changed.emit(rage_level)
			EventBus.rage_updated.emit(rage_level)
			_check_thresholds(old_rage, rage_level)

@export_range(0.0, 100.0) var reservoir_level: float = 0.0:
	set(value):
		reservoir_level = clamp(value, 0.0, 100.0)
		reservoir_changed.emit(reservoir_level)
		EventBus.reservoir_updated.emit(reservoir_level)

@export_range(0.0, 100.0) var overwhelm_level: float = 0.0:
	set(value):
		overwhelm_level = clamp(value, 0.0, 100.0)
		overwhelm_changed.emit(overwhelm_level)
		EventBus.overwhelm_updated.emit(overwhelm_level)

@export var suppression_count: int = 0
@export var rage_releases: int = 0
@export var current_state: String = "calm"

# Thresholds
const RAGE_THRESHOLD_STRESSED = 25.0
const RAGE_THRESHOLD_OVERWHELMED = 50.0
const RAGE_THRESHOLD_ANGRY = 75.0
const RAGE_THRESHOLD_BREAKING = 90.0

# Modifiers
@export var rage_multiplier: float = 1.0
@export var overwhelm_affects_rage: bool = true

# Signals
signal rage_changed(new_value: float)
signal reservoir_changed(new_value: float)
signal overwhelm_changed(new_value: float)
signal threshold_reached(threshold_type: String)
signal state_changed(new_state: String)
signal suppression_triggered()
signal rage_released()

func increase_rage(amount: float):
	var modified_amount = amount * rage_multiplier
	
	# Overwhelm affects rage gain
	if overwhelm_affects_rage and overwhelm_level > 50:
		modified_amount *= 1.0 + (overwhelm_level - 50) * 0.01
	
	rage_level += modified_amount

func decrease_rage(amount: float):
	rage_level -= amount

func suppress_rage():
	# Transfer rage to reservoir
	var transfer_amount = rage_level * 0.1
	reservoir_level += transfer_amount
	
	# Clear rage
	rage_level = 0.0
	
	# Track suppression
	suppression_count += 1
	
	# Update state
	_update_emotional_state()
	
	# Emit signals
	suppression_triggered.emit()
	EventBus.suppression_activated.emit()
	
	if GameManager.player_data:
		GameManager.player_data.suppressions_count += 1

func release_rage():
	# Clear rage without suppression
	rage_level = 0.0
	rage_releases += 1
	
	# Update state
	_update_emotional_state()
	
	# Emit signals
	rage_released.emit()
	
	if GameManager.player_data:
		GameManager.player_data.rage_releases_count += 1

func increase_overwhelm(amount: float):
	overwhelm_level += amount
	
	if overwhelm_level >= 100.0 and GameManager.player_data:
		GameManager.player_data.times_overwhelmed += 1

func decrease_overwhelm(amount: float):
	overwhelm_level -= amount

func _check_thresholds(old_rage: float, new_rage: float):
	# Check each threshold crossing
	if old_rage < RAGE_THRESHOLD_BREAKING and new_rage >= RAGE_THRESHOLD_BREAKING:
		threshold_reached.emit("breaking")
		EventBus.rage_threshold_reached.emit()
		EventBus.emotional_breaking_point.emit()
	elif old_rage < RAGE_THRESHOLD_ANGRY and new_rage >= RAGE_THRESHOLD_ANGRY:
		threshold_reached.emit("angry")
		EventBus.rage_threshold_reached.emit()
	elif old_rage < RAGE_THRESHOLD_OVERWHELMED and new_rage >= RAGE_THRESHOLD_OVERWHELMED:
		threshold_reached.emit("overwhelmed")
	elif old_rage < RAGE_THRESHOLD_STRESSED and new_rage >= RAGE_THRESHOLD_STRESSED:
		threshold_reached.emit("stressed")
	
	# Update emotional state
	_update_emotional_state()

func _update_emotional_state():
	var new_state = "calm"
	
	if rage_level >= RAGE_THRESHOLD_BREAKING:
		new_state = "breaking"
	elif rage_level >= RAGE_THRESHOLD_ANGRY:
		new_state = "angry"
	elif rage_level >= RAGE_THRESHOLD_OVERWHELMED:
		new_state = "overwhelmed"
	elif rage_level >= RAGE_THRESHOLD_STRESSED:
		new_state = "stressed"
	elif reservoir_level > 50:
		new_state = "suppressed"
	
	if new_state != current_state:
		current_state = new_state
		state_changed.emit(new_state)
		
		if GameManager.player_data:
			GameManager.player_data.current_emotional_state = new_state

func get_emotional_intensity() -> float:
	# Returns a 0-1 value representing overall emotional intensity
	var rage_factor = rage_level / 100.0
	var reservoir_factor = reservoir_level / 100.0
	var overwhelm_factor = overwhelm_level / 100.0
	
	return clamp((rage_factor + reservoir_factor * 0.5 + overwhelm_factor * 0.3) / 1.8, 0.0, 1.0)

func reset():
	rage_level = 0.0
	reservoir_level = 0.0
	overwhelm_level = 0.0
	suppression_count = 0
	rage_releases = 0
	current_state = "calm"
	rage_multiplier = 1.0