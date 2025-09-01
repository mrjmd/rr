class_name EmotionalState
extends Resource

# Signals for emotional state changes
signal state_changed(new_state: EmotionalStateType, old_state: EmotionalStateType)
signal rage_level_changed(new_level: float, old_level: float)
signal reservoir_level_changed(new_level: float, old_level: float)
signal overwhelm_level_changed(new_level: float, old_level: float)
signal breaking_point_reached
signal rage_suppressed(amount_suppressed: float)

# Emotional state enum
enum EmotionalStateType {
	CALM,
	STRESSED,
	OVERWHELMED,
	ANGRY,
	BREAKING,
	SUPPRESSED
}

# State thresholds (percentages)
const STRESSED_THRESHOLD: float = 25.0
const OVERWHELMED_THRESHOLD: float = 50.0
const ANGRY_THRESHOLD: float = 75.0
const BREAKING_THRESHOLD: float = 90.0
const MAX_LEVEL: float = 100.0
const MIN_LEVEL: float = 0.0

# Core emotional levels (0-100)
@export var rage_level: float = 0.0 : set = _set_rage_level
@export var reservoir_level: float = 0.0 : set = _set_reservoir_level
@export var overwhelm_level: float = 0.0 : set = _set_overwhelm_level

# Current emotional state
var current_state: EmotionalStateType = EmotionalStateType.CALM
var previous_state: EmotionalStateType = EmotionalStateType.CALM
var suppression_count: int = 0

# Debug flag for console output
@export var debug_enabled: bool = true

# Initialize the emotional state
func _init() -> void:
	current_state = EmotionalStateType.CALM
	previous_state = EmotionalStateType.CALM
	suppression_count = 0
	if debug_enabled:
		print("[EmotionalState] Initialized - Starting in CALM state")

# Setter for rage_level with validation and signal emission
func _set_rage_level(value: float) -> void:
	var old_level: float = rage_level
	rage_level = clampf(value, MIN_LEVEL, MAX_LEVEL)
	
	if rage_level != old_level:
		rage_level_changed.emit(rage_level, old_level)
		_update_state()
		
		if debug_enabled:
			print("[EmotionalState] Rage level changed: %.1f -> %.1f" % [old_level, rage_level])

# Setter for reservoir_level with validation and signal emission
func _set_reservoir_level(value: float) -> void:
	var old_level: float = reservoir_level
	reservoir_level = clampf(value, MIN_LEVEL, MAX_LEVEL)
	
	if reservoir_level != old_level:
		reservoir_level_changed.emit(reservoir_level, old_level)
		_update_state()
		
		if debug_enabled:
			print("[EmotionalState] Reservoir level changed: %.1f -> %.1f" % [old_level, reservoir_level])

# Setter for overwhelm_level with validation and signal emission
func _set_overwhelm_level(value: float) -> void:
	var old_level: float = overwhelm_level
	overwhelm_level = clampf(value, MIN_LEVEL, MAX_LEVEL)
	
	if overwhelm_level != old_level:
		overwhelm_level_changed.emit(overwhelm_level, old_level)
		_update_state()
		
		if debug_enabled:
			print("[EmotionalState] Overwhelm level changed: %.1f -> %.1f" % [old_level, overwhelm_level])

# Increase rage level by specified amount
func increase_rage(amount: float) -> void:
	if amount <= 0.0:
		if debug_enabled:
			print("[EmotionalState] Warning: Attempted to increase rage by non-positive amount: %.1f" % amount)
		return
	
	var old_rage: float = rage_level
	rage_level += amount
	
	if debug_enabled:
		print("[EmotionalState] Rage increased by %.1f (%.1f -> %.1f)" % [amount, old_rage, rage_level])
		
		# Check if we hit breaking point
		if rage_level >= BREAKING_THRESHOLD and old_rage < BREAKING_THRESHOLD:
			print("[EmotionalState] ⚠️ BREAKING POINT REACHED! Rage: %.1f%%" % rage_level)
			breaking_point_reached.emit()

# Suppress rage by moving it to the reservoir
func suppress_rage() -> void:
	if rage_level <= 0.0:
		if debug_enabled:
			print("[EmotionalState] No rage to suppress (current: %.1f)" % rage_level)
		return
	
	var amount_to_suppress: float = rage_level
	var transfer_amount: float = amount_to_suppress * 0.8  # 80% goes to reservoir, 20% is lost
	
	# Move rage to reservoir
	var old_reservoir: float = reservoir_level
	reservoir_level += transfer_amount
	rage_level = 0.0
	suppression_count += 1
	
	rage_suppressed.emit(amount_to_suppress)
	
	if debug_enabled:
		print("[EmotionalState] Rage suppressed! %.1f rage -> %.1f reservoir (%.1f -> %.1f)" % [
			amount_to_suppress, transfer_amount, old_reservoir, reservoir_level
		])
		print("[EmotionalState] 📦 Rage bottled up - this might cause problems later...")

# Increase overwhelm level by specified amount
func increase_overwhelm(amount: float) -> void:
	if amount <= 0.0:
		if debug_enabled:
			print("[EmotionalState] Warning: Attempted to increase overwhelm by non-positive amount: %.1f" % amount)
		return
	
	var old_overwhelm: float = overwhelm_level
	overwhelm_level += amount
	
	if debug_enabled:
		print("[EmotionalState] Overwhelm increased by %.1f (%.1f -> %.1f)" % [amount, old_overwhelm, overwhelm_level])

# Determine emotional state based on current levels
func get_state_from_levels() -> EmotionalStateType:
	# Priority order: Breaking > Angry > Overwhelmed > Stressed > Suppressed > Calm
	
	# Check for breaking point (highest priority)
	if rage_level >= BREAKING_THRESHOLD:
		return EmotionalStateType.BREAKING
	
	# Check for angry state
	if rage_level >= ANGRY_THRESHOLD:
		return EmotionalStateType.ANGRY
	
	# Check for overwhelmed state
	if overwhelm_level >= OVERWHELMED_THRESHOLD:
		return EmotionalStateType.OVERWHELMED
	
	# Check for stressed state
	if rage_level >= STRESSED_THRESHOLD or overwhelm_level >= STRESSED_THRESHOLD:
		return EmotionalStateType.STRESSED
	
	# Check for suppressed state (high reservoir with low current emotions)
	if reservoir_level >= OVERWHELMED_THRESHOLD and rage_level < STRESSED_THRESHOLD:
		return EmotionalStateType.SUPPRESSED
	
	# Default to calm
	return EmotionalStateType.CALM

# Update the current state based on levels
func _update_state() -> void:
	previous_state = current_state
	current_state = get_state_from_levels()
	
	if current_state != previous_state:
		state_changed.emit(current_state, previous_state)
		
		if debug_enabled:
			var state_names: PackedStringArray = ["CALM", "STRESSED", "OVERWHELMED", "ANGRY", "BREAKING", "SUPPRESSED"]
			print("[EmotionalState] 🔄 State changed: %s -> %s" % [
				state_names[previous_state], state_names[current_state]
			])
			print("[EmotionalState] Current levels - Rage: %.1f%%, Reservoir: %.1f%%, Overwhelm: %.1f%%" % [
				rage_level, reservoir_level, overwhelm_level
			])

# Reset all emotional levels to zero
func reset() -> void:
	var had_emotions: bool = rage_level > 0.0 or reservoir_level > 0.0 or overwhelm_level > 0.0
	
	rage_level = 0.0
	reservoir_level = 0.0
	overwhelm_level = 0.0
	
	if debug_enabled:
		if had_emotions:
			print("[EmotionalState] 🔄 All emotional levels reset to 0")
		else:
			print("[EmotionalState] Reset called - already at baseline")

# Get a human-readable description of the current state
func get_state_description() -> String:
	match current_state:
		EmotionalStateType.CALM:
			return "Feeling calm and centered"
		EmotionalStateType.STRESSED:
			return "Starting to feel pressure building"
		EmotionalStateType.OVERWHELMED:
			return "Too much to handle right now"
		EmotionalStateType.ANGRY:
			return "Anger is rising - need to be careful"
		EmotionalStateType.BREAKING:
			return "At the breaking point - explosive emotions"
		EmotionalStateType.SUPPRESSED:
			return "Emotions are bottled up - feels heavy"
		_:
			return "Unknown emotional state"

# Get current levels as a dictionary for saving/loading
func get_levels_data() -> Dictionary:
	return {
		"rage_level": rage_level,
		"reservoir_level": reservoir_level,
		"overwhelm_level": overwhelm_level,
		"current_state": current_state
	}

# Set levels from dictionary data (for loading saves)
func set_levels_data(data: Dictionary) -> void:
	if data.has("rage_level"):
		rage_level = data.rage_level
	if data.has("reservoir_level"):
		reservoir_level = data.reservoir_level
	if data.has("overwhelm_level"):
		overwhelm_level = data.overwhelm_level
	
	_update_state()
	
	if debug_enabled:
		print("[EmotionalState] Loaded emotional state data - Rage: %.1f%%, Reservoir: %.1f%%, Overwhelm: %.1f%%" % [
			rage_level, reservoir_level, overwhelm_level
		])

# Check if currently in a dangerous emotional state
func is_dangerous_state() -> bool:
	return current_state in [EmotionalStateType.ANGRY, EmotionalStateType.BREAKING]

# Check if emotions are building up dangerously
func is_building_pressure() -> bool:
	return reservoir_level > OVERWHELMED_THRESHOLD or overwhelm_level > ANGRY_THRESHOLD

# Get a warning message if in a concerning state
func get_warning_message() -> String:
	if current_state == EmotionalStateType.BREAKING:
		return "⚠️ CRITICAL: At breaking point!"
	elif current_state == EmotionalStateType.ANGRY:
		return "⚠️ WARNING: Anger levels high"
	elif is_building_pressure():
		return "⚠️ CAUTION: Pressure building up"
	elif current_state == EmotionalStateType.SUPPRESSED:
		return "⚠️ NOTE: Emotions are bottled up"
	else:
		return ""
