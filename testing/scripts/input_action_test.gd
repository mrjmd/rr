extends Node
## Test input action mappings

func _ready():
	print("=== INPUT ACTION DIAGNOSTIC ===")
	
	# Check if pause_menu action exists
	var pause_action_exists = InputMap.has_action("pause_menu")
	print("pause_menu action exists: ", pause_action_exists)
	
	if pause_action_exists:
		var events = InputMap.action_get_events("pause_menu")
		print("pause_menu events: ", events.size())
		for i in range(events.size()):
			var event = events[i]
			print("  Event ", i, ": ", event)
			if event is InputEventKey:
				print("    Keycode: ", event.keycode, " (ESC=", KEY_ESCAPE, ")")
	
	# Check ui_cancel action
	var cancel_action_exists = InputMap.has_action("ui_cancel")
	print("ui_cancel action exists: ", cancel_action_exists)
	
	if cancel_action_exists:
		var events = InputMap.action_get_events("ui_cancel")
		print("ui_cancel events: ", events.size())
		for i in range(events.size()):
			var event = events[i]
			print("  Event ", i, ": ", event)
			if event is InputEventKey:
				print("    Keycode: ", event.keycode, " (ESC=", KEY_ESCAPE, ")")
	
	# Test manual input checking
	await get_tree().create_timer(1.0).timeout
	print("Now testing manual ESC key detection for 3 seconds...")
	
	await get_tree().create_timer(3.0).timeout
	print("=== INPUT TEST COMPLETE ===")
	get_tree().quit()

func _unhandled_input(event: InputEvent):
	if event is InputEventKey and event.pressed:
		print("Key pressed: ", event.keycode, " (ESC=", KEY_ESCAPE, ")")
		
		# Test action checking
		if event.is_action_pressed("pause_menu"):
			print("  -> pause_menu action TRIGGERED")
		else:
			print("  -> pause_menu action NOT TRIGGERED")
			
		if event.is_action_pressed("ui_cancel"):
			print("  -> ui_cancel action TRIGGERED")
		else:
			print("  -> ui_cancel action NOT TRIGGERED")