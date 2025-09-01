extends Control
## Test scene for UI components - use this to test meters in isolation

@onready var game_hud: GameHUD = $GameHUD
@onready var ui_initializer: UIInitializer = $UIInitializer

func _ready() -> void:
	# Initialize UI system
	UIInitializer.setup_ui_for_scene(self)
	
	# Wait for UI to be ready
	if ui_initializer:
		await ui_initializer.ui_initialized
	
	# Validate UI components
	if game_hud and ui_initializer:
		ui_initializer.validate_ui_components(game_hud)
	
	print("UI Test Scene loaded. Use debug keys to test meters:")
	print("1 - Increase rage")
	print("2 - Suppress rage (shows reservoir)")
	print("3 - Increase overwhelm")
	print("Enter - Cycle through threshold levels")
	print("Escape - Reset all values")
	print("F1 - Toggle HUD visibility")
	print("F2 - Toggle debug panel")
	print("F3 - Run rage progression test")
	print("F4 - Run suppression cycle test")

func _input(event: InputEvent) -> void:
	if not GameManager.emotional_state:
		return
	
	# Test rage increase
	if event.is_action_pressed("debug_increase_rage"):
		GameManager.emotional_state.increase_rage(15.0)
		print("Rage increased to: ", GameManager.emotional_state.rage_level)
	
	# Test suppression
	elif event.is_action_pressed("debug_suppress"):
		GameManager.emotional_state.suppress_rage()
		print("Rage suppressed. Reservoir: ", GameManager.emotional_state.reservoir_level)
	
	# Test overwhelm
	elif event.is_action_pressed("debug_overwhelm"):
		GameManager.emotional_state.increase_overwhelm(20.0)
		print("Overwhelm increased to: ", GameManager.emotional_state.overwhelm_level)
	
	# Test threshold crossing
	elif event.is_action_pressed("ui_accept"):
		# Quickly set to different threshold levels for testing
		var current_rage = GameManager.emotional_state.rage_level
		if current_rage < 25:
			GameManager.emotional_state.rage_level = 25
		elif current_rage < 50:
			GameManager.emotional_state.rage_level = 50
		elif current_rage < 75:
			GameManager.emotional_state.rage_level = 75
		elif current_rage < 90:
			GameManager.emotional_state.rage_level = 90
		else:
			GameManager.emotional_state.rage_level = 0
		print("Rage set to: ", GameManager.emotional_state.rage_level)
	
	# Reset all values
	elif event.is_action_pressed("ui_cancel"):
		GameManager.emotional_state.reset()
		print("All emotional values reset")
	
	# Test progression
	elif event.is_action_pressed("debug_toggle"):  # F12
		if ui_initializer:
			ui_initializer.test_rage_progression()
	
	# Test suppression cycle
	elif event.is_action_pressed("debug_toggle_hud"):  # F1 (reusing for test)
		if event.shift_pressed and ui_initializer:  # Shift+F1
			ui_initializer.test_suppression_cycle()