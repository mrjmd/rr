extends SceneTree

# Integration Test Script for Complete Menu System
# Tests all navigation workflows and captures proof screenshots

var test_number: int = 1
var screenshot_dir: String = "testing/screenshots/current/"

func _initialize():
	print("Starting Menu Integration Test Suite")
	print("Testing complete workflows with screenshot capture")
	
	# Ensure screenshot directory exists
	DirAccess.open("user://").make_dir_recursive(screenshot_dir)
	
	# Run all integration tests
	await test_main_menu_startup()
	await test_main_to_game_workflow()
	await test_pause_menu_integration()
	await test_settings_menu_integration()
	await test_complete_navigation_cycle()
	
	print("Integration Testing Complete")
	quit()

func capture_screenshot(description: String):
	var viewport = get_root().get_viewport()
	var image = viewport.get_texture().get_image()
	var filename = "integration_%02d_%s.png" % [test_number, description]
	var full_path = screenshot_dir + filename
	image.save_png(full_path)
	print("Screenshot captured: %s" % filename)
	test_number += 1
	
	# Small delay to ensure screenshot is written
	await process_frame
	await process_frame

func test_main_menu_startup():
	print("\n=== TEST 1: Main Menu Startup ===")
	
	# Load main menu scene
	get_root().get_child(0).queue_free()
	var main_menu_scene = load("res://src/scenes/ui/menus/main_menu_simple.tscn")
	var main_menu = main_menu_scene.instantiate()
	get_root().add_child(main_menu)
	
	# Wait for initialization
	await process_frame
	await process_frame
	
	capture_screenshot("main_menu_loaded")
	print("✓ Main menu scene loaded successfully")

func test_main_to_game_workflow():
	print("\n=== TEST 2: Main Menu to Game Workflow ===")
	
	# Try to start game (simulate button click)
	var main_menu = get_root().get_child(0)
	if main_menu.has_method("_on_start_button_pressed"):
		capture_screenshot("before_start_game")
		main_menu._on_start_button_pressed()
		
		# Wait for scene change
		await process_frame
		await process_frame
		await process_frame
		
		capture_screenshot("game_started")
		print("✓ Game start workflow completed")
	else:
		print("⚠ Could not test start game - method not found")

func test_pause_menu_integration():
	print("\n=== TEST 3: Pause Menu Integration ===")
	
	# Simulate ESC key press to open pause menu
	var input_event = InputEventKey.new()
	input_event.keycode = KEY_ESCAPE
	input_event.pressed = true
	
	capture_screenshot("before_pause")
	
	# Send input event
	get_root().get_viewport().push_input(input_event)
	await process_frame
	await process_frame
	
	capture_screenshot("pause_menu_opened")
	
	# Try to resume (ESC again)
	get_root().get_viewport().push_input(input_event)
	await process_frame
	await process_frame
	
	capture_screenshot("game_resumed")
	print("✓ Pause menu integration tested")

func test_settings_menu_integration():
	print("\n=== TEST 4: Settings Menu Integration ===")
	
	# Load settings menu scene
	get_root().get_child(0).queue_free()
	var settings_scene = load("res://src/scenes/ui/menus/settings_menu_simple.tscn")
	var settings_menu = settings_scene.instantiate()
	get_root().add_child(settings_menu)
	
	await process_frame
	await process_frame
	
	capture_screenshot("settings_menu_loaded")
	print("✓ Settings menu loaded successfully")

func test_complete_navigation_cycle():
	print("\n=== TEST 5: Complete Navigation Cycle ===")
	
	# Start from main menu
	get_root().get_child(0).queue_free()
	var main_menu_scene = load("res://src/scenes/ui/menus/main_menu_simple.tscn")
	var main_menu = main_menu_scene.instantiate()
	get_root().add_child(main_menu)
	
	await process_frame
	await process_frame
	
	capture_screenshot("cycle_start_main")
	
	# Try settings navigation if button exists
	if main_menu.has_method("_on_settings_button_pressed"):
		main_menu._on_settings_button_pressed()
		await process_frame
		await process_frame
		capture_screenshot("cycle_in_settings")
		
		# Try to go back to main
		var current_scene = get_root().get_child(0)
		if current_scene.has_method("_on_back_button_pressed"):
			current_scene._on_back_button_pressed()
			await process_frame
			await process_frame
			capture_screenshot("cycle_back_to_main")
	
	print("✓ Navigation cycle tested")

# Final summary
func _finalize():
	print("\n=== INTEGRATION TEST SUMMARY ===")
	print("Total screenshots captured: %d" % (test_number - 1))
	print("All tests completed - check screenshots for visual verification")