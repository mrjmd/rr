extends Node

## Interactive menu testing with input simulation and screenshot capture
## This runs WITH the GUI (not headless) to properly test interaction

var test_phase: int = 0
var screenshot_count: int = 0

func _ready() -> void:
	print("=== INTERACTIVE MENU TEST STARTING ===")
	print("This test will simulate user input and capture screenshots")
	print("")
	
	# Start the test sequence
	await get_tree().create_timer(2.0).timeout
	run_next_test()

func run_next_test() -> void:
	test_phase += 1
	
	match test_phase:
		1:
			test_pause_menu_esc()
		2:
			test_pause_menu_p()
		3:
			test_settings_from_pause()
		4:
			finish_testing()

func test_pause_menu_esc() -> void:
	print("\n[TEST 1] Testing ESC key for pause menu")
	print("- Waiting for game to stabilize...")
	await get_tree().create_timer(1.0).timeout
	
	# Capture before state
	capture_screenshot("test_01_before_esc")
	
	# Simulate ESC key press
	print("- Pressing ESC key...")
	simulate_key_press(KEY_ESCAPE)
	
	await get_tree().create_timer(0.5).timeout
	
	# Capture after state
	capture_screenshot("test_02_after_esc")
	
	# Check if pause menu is visible
	var pause_menu = get_node_or_null("/root/PlayerTestScene/PauseMenu")
	if pause_menu:
		print("  ✓ Pause menu found in scene")
		print("  ✓ Visible: %s" % pause_menu.visible)
		if pause_menu.has_method("is_open"):
			print("  ✓ Is open: %s" % pause_menu.is_open())
	else:
		print("  ✗ ERROR: Pause menu not found!")
	
	# Close it again
	await get_tree().create_timer(1.0).timeout
	print("- Pressing ESC again to close...")
	simulate_key_press(KEY_ESCAPE)
	
	await get_tree().create_timer(0.5).timeout
	capture_screenshot("test_03_esc_closed")
	
	await get_tree().create_timer(1.0).timeout
	run_next_test()

func test_pause_menu_p() -> void:
	print("\n[TEST 2] Testing P key for pause menu")
	
	# Simulate P key press
	print("- Pressing P key...")
	simulate_key_press(KEY_P)
	
	await get_tree().create_timer(0.5).timeout
	capture_screenshot("test_04_after_p")
	
	# Check state
	var pause_menu = get_node_or_null("/root/PlayerTestScene/PauseMenu")
	if pause_menu and pause_menu.visible:
		print("  ✓ P key opens pause menu")
	else:
		print("  ✗ P key failed to open pause menu")
	
	await get_tree().create_timer(1.0).timeout
	run_next_test()

func test_settings_from_pause() -> void:
	print("\n[TEST 3] Testing Settings button from pause menu")
	
	# Make sure pause menu is open
	var pause_menu = get_node_or_null("/root/PlayerTestScene/PauseMenu")
	if not pause_menu or not pause_menu.visible:
		print("- Opening pause menu first...")
		simulate_key_press(KEY_ESCAPE)
		await get_tree().create_timer(0.5).timeout
	
	capture_screenshot("test_05_pause_open")
	
	# Find and click settings button
	if pause_menu:
		var settings_button = pause_menu.find_child("SettingsButton", true, false)
		if settings_button and settings_button is Button:
			print("- Clicking Settings button...")
			settings_button.pressed.emit()
			await get_tree().create_timer(0.5).timeout
			capture_screenshot("test_06_settings_opened")
			
			# Check if settings menu opened
			var settings_menu = get_node_or_null("/root/SettingsMenu")
			if settings_menu and settings_menu.visible:
				print("  ✓ Settings menu opened successfully")
			else:
				print("  ✗ Settings menu did not open")
		else:
			print("  ✗ Settings button not found")
	
	await get_tree().create_timer(1.0).timeout
	run_next_test()

func finish_testing() -> void:
	print("\n=== TEST COMPLETE ===")
	print("Screenshots saved: %d" % screenshot_count)
	print("Location: user://testing/screenshots/current/")
	print("\nNOW YOU MUST:")
	print("1. Use Read tool to verify each screenshot")
	print("2. Check that UI elements are visible (not black)")
	print("3. Confirm menus appear as expected")
	
	await get_tree().create_timer(3.0).timeout
	get_tree().quit()

func simulate_key_press(keycode: int) -> void:
	var event = InputEventKey.new()
	event.keycode = keycode
	event.pressed = true
	event.echo = false
	Input.parse_input_event(event)
	
	# Also trigger the release
	await get_tree().process_frame
	event.pressed = false
	Input.parse_input_event(event)

func capture_screenshot(name: String) -> void:
	screenshot_count += 1
	var image = get_viewport().get_texture().get_image()
	var path = "user://testing/screenshots/current/%s.png" % name
	
	# Ensure directory exists
	DirAccess.make_dir_recursive_absolute("user://testing/screenshots/current")
	
	image.save_png(path)
	var size = FileAccess.get_file_as_bytes(path).size()
	
	print("  📸 Screenshot: %s.png (%d bytes)" % [name, size])
	
	if size < 10000:
		print("  ⚠️ WARNING: Screenshot may be black/empty! Must verify with Read tool!")
		print("  ⚠️ File size %d is suspiciously small" % size)