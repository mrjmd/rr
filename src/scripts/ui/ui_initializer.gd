class_name UIInitializer
extends Node
## Utility class to ensure proper UI initialization and emotional state setup

# Signal emitted when UI is fully initialized
signal ui_initialized

# Tracks initialization status
var is_initialized: bool = false

func _ready() -> void:
	# Initialize emotional state if missing
	_ensure_emotional_state()
	
	# Wait one frame for all systems to be ready
	await get_tree().process_frame
	
	# Complete initialization
	_complete_initialization()

func _ensure_emotional_state() -> void:
	"""Ensure GameManager has a valid emotional state resource"""
	if not GameManager.emotional_state:
		print("UIInitializer: Creating new EmotionalState resource")
		
		# Create new emotional state
		var emotional_state = EmotionalState.new()
		GameManager.emotional_state = emotional_state
		
		# Connect to emotional state signals for debugging
		if OS.is_debug_build():
			emotional_state.rage_changed.connect(_on_debug_rage_changed)
			emotional_state.reservoir_changed.connect(_on_debug_reservoir_changed)
			emotional_state.threshold_reached.connect(_on_debug_threshold_reached)
			emotional_state.state_changed.connect(_on_debug_state_changed)
	
	# Verify connection to event bus
	if not EventBus.rage_updated.is_connected(_on_event_bus_rage_updated):
		EventBus.rage_updated.connect(_on_event_bus_rage_updated)

func _complete_initialization() -> void:
	"""Complete UI initialization and emit signal"""
	is_initialized = true
	ui_initialized.emit()
	
	if OS.is_debug_build():
		print("UIInitializer: UI system fully initialized")
		print("  - Rage Level: ", GameManager.emotional_state.rage_level)
		print("  - Reservoir Level: ", GameManager.emotional_state.reservoir_level)
		print("  - Overwhelm Level: ", GameManager.emotional_state.overwhelm_level)

# Debug signal handlers
func _on_debug_rage_changed(new_rage: float) -> void:
	if OS.is_debug_build():
		print("UIInitializer: Rage changed to ", new_rage)

func _on_debug_reservoir_changed(new_reservoir: float) -> void:
	if OS.is_debug_build():
		print("UIInitializer: Reservoir changed to ", new_reservoir)

func _on_debug_threshold_reached(threshold_type: String) -> void:
	if OS.is_debug_build():
		print("UIInitializer: Threshold reached - ", threshold_type)

func _on_debug_state_changed(new_state: String) -> void:
	if OS.is_debug_build():
		print("UIInitializer: Emotional state changed to - ", new_state)

func _on_event_bus_rage_updated(new_value: float) -> void:
	# This confirms EventBus is working
	if OS.is_debug_build():
		print("UIInitializer: EventBus rage update - ", new_value)

# Utility methods for external use
static func setup_ui_for_scene(scene_root: Node) -> void:
	"""Static method to set up UI for any scene"""
	var initializer = UIInitializer.new()
	scene_root.add_child(initializer)

func get_emotional_state() -> EmotionalState:
	"""Safe getter for emotional state"""
	return GameManager.emotional_state

func is_ui_ready() -> bool:
	"""Check if UI system is ready for use"""
	return is_initialized and GameManager.emotional_state != null

# Test methods for debugging
func test_rage_progression() -> void:
	"""Test method to cycle through rage levels"""
	if not GameManager.emotional_state:
		return
	
	var test_values = [0.0, 25.0, 50.0, 75.0, 90.0, 100.0]
	var current_index = 0
	
	for value in test_values:
		GameManager.emotional_state.rage_level = value
		await get_tree().create_timer(1.0).timeout
		print("Test: Rage set to ", value)

func test_suppression_cycle() -> void:
	"""Test method to demonstrate suppression mechanics"""
	if not GameManager.emotional_state:
		return
	
	print("Testing suppression cycle...")
	
	# Build up rage
	GameManager.emotional_state.rage_level = 80.0
	await get_tree().create_timer(1.0).timeout
	
	# Suppress it
	GameManager.emotional_state.suppress_rage()
	await get_tree().create_timer(1.0).timeout
	
	# Build up again
	GameManager.emotional_state.rage_level = 60.0
	await get_tree().create_timer(1.0).timeout
	
	# Suppress again
	GameManager.emotional_state.suppress_rage()
	
	print("Suppression test complete")

# Method to validate UI components
func validate_ui_components(hud: GameHUD) -> bool:
	"""Validate that all UI components are properly set up"""
	if not hud:
		print("UIInitializer: No HUD provided for validation")
		return false
	
	var validation_passed = true
	
	# Check for rage meter
	if not hud.rage_meter:
		print("UIInitializer: Missing RageMeter component")
		validation_passed = false
	
	# Check for reservoir meter
	if not hud.reservoir_meter:
		print("UIInitializer: Missing ReservoirMeter component")
		validation_passed = false
	
	# Check emotional state connection
	if not GameManager.emotional_state:
		print("UIInitializer: Missing EmotionalState resource")
		validation_passed = false
	
	if validation_passed:
		print("UIInitializer: All UI components validated successfully")
	
	return validation_passed