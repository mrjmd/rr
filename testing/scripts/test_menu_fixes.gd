extends Node

## Test script to verify menu fixes and capture screenshots

func _ready() -> void:
	print("=== TESTING MENU FIXES ===")
	print("Test 1: Pause menu in game")
	print("- ESC/P keys should now work")
	print("")
	
	# Wait a moment for scene to stabilize
	await get_tree().create_timer(1.0).timeout
	
	# Capture initial game state
	print("Capturing initial game state...")
	capture_screenshot("fix_test_01_game_running.png")
	
	# Simulate ESC key press
	await get_tree().create_timer(1.0).timeout
	print("Pressing ESC key...")
	var esc_event = InputEventKey.new()
	esc_event.keycode = KEY_ESCAPE
	esc_event.pressed = true
	Input.parse_input_event(esc_event)
	
	# Wait for pause menu to appear
	await get_tree().create_timer(0.5).timeout
	
	# Check if pause menu is visible
	var pause_menu = get_node_or_null("/root/PlayerTestScene/PauseMenu")
	if pause_menu:
		print("Pause menu found: %s" % pause_menu.visible)
		capture_screenshot("fix_test_02_after_esc.png")
	else:
		print("ERROR: Pause menu not found in scene!")
	
	# Test P key
	await get_tree().create_timer(1.0).timeout
	print("Pressing P key to toggle...")
	var p_event = InputEventKey.new()
	p_event.keycode = KEY_P
	p_event.pressed = true
	Input.parse_input_event(p_event)
	
	await get_tree().create_timer(0.5).timeout
	capture_screenshot("fix_test_03_after_p_toggle.png")
	
	print("\n=== TEST COMPLETE ===")
	print("Screenshots saved to testing/screenshots/current/")
	print("Please verify with Read tool")
	
	await get_tree().create_timer(2.0).timeout
	get_tree().quit()

func capture_screenshot(filename: String) -> void:
	var image = get_viewport().get_texture().get_image()
	var path = "user://testing/screenshots/current/" + filename
	
	# Ensure directory exists
	DirAccess.make_dir_recursive_absolute("user://testing/screenshots/current")
	
	image.save_png(path)
	var size = FileAccess.get_file_as_bytes(path).size()
	print("Screenshot: %s (%d bytes)" % [filename, size])
	
	if size < 10000:
		print("⚠️ WARNING: Screenshot may be black/empty!")