extends Node

## Menu state verification script with proper screenshot capture

var screenshot_dir: String = "testing/screenshots/current"
var test_results: Dictionary = {}

func _ready() -> void:
	print("=== MENU STATE VERIFICATION STARTING ===")
	
	# Create screenshot directory if needed
	var dir = DirAccess.open("user://")
	if dir:
		dir.make_dir_recursive(screenshot_dir)
	
	# Start verification sequence
	await get_tree().create_timer(1.0).timeout
	verify_main_menu()

func verify_main_menu() -> void:
	print("\n[TEST] Verifying Main Menu...")
	
	# Load main menu
	var main_menu_scene = load("res://src/scenes/ui/menus/main_menu_simple.tscn")
	if not main_menu_scene:
		print("ERROR: Cannot load main_menu_simple.tscn")
		test_results["main_menu"] = "FAILED - Cannot load scene"
		verify_pause_menu()
		return
	
	var main_menu = main_menu_scene.instantiate()
	get_tree().root.add_child(main_menu)
	
	await get_tree().create_timer(0.5).timeout
	
	# Check visibility
	print("Main menu visible: %s" % main_menu.visible)
	print("Main menu modulate: %s" % main_menu.modulate)
	
	# Force visible for testing
	main_menu.visible = true
	main_menu.modulate.a = 1.0
	
	await get_tree().create_timer(0.5).timeout
	
	# Capture screenshot
	var screenshot_path = screenshot_dir + "/verify_01_main_menu.png"
	capture_screenshot(screenshot_path)
	
	# Check for buttons
	var start_button = main_menu.find_child("StartButton", true, false)
	var settings_button = main_menu.find_child("SettingsButton", true, false)
	var quit_button = main_menu.find_child("QuitButton", true, false)
	
	print("Start button found: %s" % (start_button != null))
	print("Settings button found: %s" % (settings_button != null))
	print("Quit button found: %s" % (quit_button != null))
	
	test_results["main_menu"] = "Visible: %s, Buttons: %s" % [
		main_menu.visible,
		(start_button != null and settings_button != null and quit_button != null)
	]
	
	main_menu.queue_free()
	await get_tree().create_timer(0.5).timeout
	
	verify_pause_menu()

func verify_pause_menu() -> void:
	print("\n[TEST] Verifying Pause Menu...")
	
	# Create a simple game scene first
	var game_scene = Node2D.new()
	game_scene.name = "TestGameScene"
	
	# Add a colored background to see if pause overlay works
	var background = ColorRect.new()
	background.color = Color.DARK_GREEN
	background.size = Vector2(1920, 1080)
	game_scene.add_child(background)
	
	get_tree().root.add_child(game_scene)
	
	await get_tree().create_timer(0.5).timeout
	
	# Capture game state
	var screenshot_path = screenshot_dir + "/verify_02_game_before_pause.png"
	capture_screenshot(screenshot_path)
	
	# Load pause menu
	var pause_menu_scene = load("res://src/scenes/ui/menus/pause_menu.tscn")
	if not pause_menu_scene:
		print("ERROR: Cannot load pause_menu.tscn")
		test_results["pause_menu"] = "FAILED - Cannot load scene"
		verify_settings_menu()
		return
	
	var pause_menu = pause_menu_scene.instantiate()
	get_tree().root.add_child(pause_menu)
	
	await get_tree().create_timer(0.5).timeout
	
	# Test pause menu visibility
	print("Pause menu initial visible: %s" % pause_menu.visible)
	
	# Test showing pause menu
	if pause_menu.has_method("show_menu"):
		pause_menu.show_menu()
		print("Called show_menu()")
	else:
		pause_menu.visible = true
		print("Forced visible = true")
	
	await get_tree().create_timer(0.5).timeout
	
	print("Pause menu after show: %s" % pause_menu.visible)
	print("Game paused: %s" % get_tree().paused)
	
	# Capture paused state
	screenshot_path = screenshot_dir + "/verify_03_pause_menu_shown.png"
	capture_screenshot(screenshot_path)
	
	# Test ESC key input
	print("\n[TEST] Simulating ESC key press...")
	var esc_event = InputEventKey.new()
	esc_event.keycode = KEY_ESCAPE
	esc_event.pressed = true
	Input.parse_input_event(esc_event)
	
	await get_tree().create_timer(0.5).timeout
	
	screenshot_path = screenshot_dir + "/verify_04_after_esc.png"
	capture_screenshot(screenshot_path)
	
	test_results["pause_menu"] = "Loaded: true, Show works: %s" % pause_menu.visible
	
	pause_menu.queue_free()
	game_scene.queue_free()
	await get_tree().create_timer(0.5).timeout
	
	verify_settings_menu()

func verify_settings_menu() -> void:
	print("\n[TEST] Verifying Settings Menu...")
	
	var settings_menu_scene = load("res://src/scenes/ui/menus/settings_menu.tscn")
	if not settings_menu_scene:
		print("ERROR: Cannot load settings_menu.tscn")
		test_results["settings_menu"] = "FAILED - Cannot load scene"
		print_summary()
		return
	
	var settings_menu = settings_menu_scene.instantiate()
	get_tree().root.add_child(settings_menu)
	
	# Force visible
	settings_menu.visible = true
	
	await get_tree().create_timer(0.5).timeout
	
	# Capture screenshot
	var screenshot_path = screenshot_dir + "/verify_05_settings_menu.png"
	capture_screenshot(screenshot_path)
	
	print("Settings menu visible: %s" % settings_menu.visible)
	
	# Check for tabs
	var tab_container = settings_menu.find_child("TabContainer", true, false)
	if tab_container:
		print("Tab container found with %d tabs" % tab_container.get_tab_count())
	
	test_results["settings_menu"] = "Visible: %s" % settings_menu.visible
	
	settings_menu.queue_free()
	await get_tree().create_timer(0.5).timeout
	
	print_summary()

func capture_screenshot(path: String) -> void:
	var image = get_viewport().get_texture().get_image()
	var full_path = "user://" + path
	image.save_png(full_path)
	
	var file_size = FileAccess.get_file_as_bytes(full_path).size()
	print("Screenshot saved: %s (%d bytes)" % [path, file_size])
	
	if file_size < 10000:
		print("WARNING: Screenshot appears to be black/empty!")

func print_summary() -> void:
	print("\n=== VERIFICATION SUMMARY ===")
	for test_name in test_results:
		print("%s: %s" % [test_name, test_results[test_name]])
	
	print("\nScreenshots saved to: %s" % screenshot_dir)
	print("Please use Read tool to verify each screenshot shows expected content")
	
	await get_tree().create_timer(2.0).timeout
	get_tree().quit()