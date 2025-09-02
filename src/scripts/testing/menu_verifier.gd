extends Node
## Menu verification script that can be added to any scene

signal test_complete

var test_phase: int = 0
var screenshot_count: int = 0
var results: Dictionary = {}

func _ready() -> void:
	print("=== MENU VERIFIER ACTIVE ===")
	set_process_unhandled_key_input(true)
	
	# Auto-start if configured
	if OS.has_environment("AUTO_TEST"):
		await get_tree().create_timer(2.0).timeout
		start_verification()

func start_verification() -> void:
	print("Starting menu verification sequence...")
	run_next_test()

func _unhandled_key_input(event: InputEvent) -> void:
	# Manual trigger with F9
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_F9:
			print("Manual test triggered with F9")
			start_verification()
			get_viewport().set_input_as_handled()

func run_next_test() -> void:
	test_phase += 1
	
	match test_phase:
		1:
			await test_initial_state()
		2:
			await test_pause_menu_esc()
		3:
			await test_pause_menu_p()
		4:
			await test_settings_from_pause()
		5:
			print_results()
			test_complete.emit()

func test_initial_state() -> void:
	print("\n[TEST 1] Initial State")
	capture_screenshot("01_initial_state")
	results["initial_state"] = "captured"
	await get_tree().create_timer(1.0).timeout
	run_next_test()

func test_pause_menu_esc() -> void:
	print("\n[TEST 2] ESC Key → Pause Menu")
	
	# Simulate ESC press
	print("  Pressing ESC...")
	var esc_event = InputEventKey.new()
	esc_event.keycode = KEY_ESCAPE
	esc_event.pressed = true
	Input.parse_input_event(esc_event)
	
	await get_tree().create_timer(0.5).timeout
	
	# Check pause menu
	var pause_menu = get_tree().get_first_node_in_group("pause_menu")
	if not pause_menu:
		pause_menu = get_node_or_null("/root/PlayerTestScene/PauseMenu")
	
	if pause_menu and pause_menu.visible:
		print("  ✓ Pause menu opened")
		results["esc_opens_pause"] = "PASS"
	else:
		print("  ✗ Pause menu not visible")
		results["esc_opens_pause"] = "FAIL"
	
	capture_screenshot("02_pause_menu_esc")
	
	# Close it
	await get_tree().create_timer(1.0).timeout
	print("  Pressing ESC again to close...")
	Input.parse_input_event(esc_event)
	
	await get_tree().create_timer(0.5).timeout
	capture_screenshot("03_pause_closed")
	
	await get_tree().create_timer(1.0).timeout
	run_next_test()

func test_pause_menu_p() -> void:
	print("\n[TEST 3] P Key → Pause Menu")
	
	# Simulate P press
	print("  Pressing P...")
	var p_event = InputEventKey.new()
	p_event.keycode = KEY_P
	p_event.pressed = true
	Input.parse_input_event(p_event)
	
	await get_tree().create_timer(0.5).timeout
	
	# Check pause menu
	var pause_menu = get_node_or_null("/root/PlayerTestScene/PauseMenu")
	if pause_menu and pause_menu.visible:
		print("  ✓ P key opens pause menu")
		results["p_opens_pause"] = "PASS"
	else:
		print("  ✗ P key failed")
		results["p_opens_pause"] = "FAIL"
	
	capture_screenshot("04_pause_menu_p")
	
	await get_tree().create_timer(1.0).timeout
	run_next_test()

func test_settings_from_pause() -> void:
	print("\n[TEST 4] Settings from Pause Menu")
	
	# Ensure pause menu is open
	var pause_menu = get_node_or_null("/root/PlayerTestScene/PauseMenu")
	if not pause_menu or not pause_menu.visible:
		print("  Opening pause menu first...")
		var esc = InputEventKey.new()
		esc.keycode = KEY_ESCAPE
		esc.pressed = true
		Input.parse_input_event(esc)
		await get_tree().create_timer(0.5).timeout
	
	# Find settings button
	if pause_menu:
		var settings_btn = pause_menu.find_child("SettingsButton", true, false)
		if settings_btn and settings_btn is Button:
			print("  Clicking Settings button...")
			settings_btn.pressed.emit()
			await get_tree().create_timer(1.0).timeout
			
			# Check if settings opened
			var settings = get_node_or_null("/root/SettingsMenu")
			if not settings:
				# Try finding in scene
				settings = get_tree().get_first_node_in_group("settings_menu")
			
			if settings and settings.visible:
				print("  ✓ Settings menu opened")
				results["settings_from_pause"] = "PASS"
			else:
				print("  ✗ Settings menu not visible")
				results["settings_from_pause"] = "FAIL"
				
				# Debug info
				var menu_manager = get_node_or_null("/root/MenuManager")
				if menu_manager:
					print("  DEBUG: MenuManager exists")
		else:
			print("  ✗ Settings button not found")
			results["settings_from_pause"] = "FAIL - No button"
	
	capture_screenshot("05_settings_attempt")
	
	await get_tree().create_timer(1.0).timeout
	run_next_test()

func capture_screenshot(name: String) -> void:
	screenshot_count += 1
	var img = get_viewport().get_texture().get_image()
	
	# Save to user data
	var dir_path = "user://testing/screenshots/current"
	DirAccess.make_dir_recursive_absolute(dir_path)
	
	var path = dir_path + "/" + name + ".png"
	img.save_png(path)
	
	# Get file size for validation
	var file = FileAccess.open(path, FileAccess.READ)
	if file:
		var size = file.get_length()
		file.close()
		print("  📸 %s.png: %d bytes %s" % [
			name, 
			size,
			"⚠️ SUSPICIOUS" if size < 10000 else "✓"
		])
		
		# Also save size in results
		results[name + "_size"] = size

func print_results() -> void:
	var separator = "=".repeat(50)
	print("\n" + separator)
	print("VERIFICATION RESULTS")
	print(separator)
	
	var passed = 0
	var failed = 0
	
	for test in results:
		if not test.ends_with("_size"):
			if results[test] == "PASS":
				passed += 1
				print("✓ %s: PASS" % test)
			elif results[test].begins_with("FAIL"):
				failed += 1
				print("✗ %s: %s" % [test, results[test]])
	
	print("\nSummary: %d passed, %d failed" % [passed, failed])
	print("Screenshots: %d captured" % screenshot_count)
	print("\nScreenshots saved to:")
	print("~/Library/Application Support/Godot/app_userdata/Rando's Reservoir/testing/screenshots/current/")
	print("\nUSE READ TOOL TO VERIFY EACH SCREENSHOT")
