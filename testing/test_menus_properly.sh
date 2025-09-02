#!/bin/bash

# PROPER MENU TESTING SCRIPT - NO EXCUSES
# This runs Godot WITH GUI and captures REAL screenshots

echo "=== STARTING PROPER MENU VERIFICATION ==="
echo "This will:"
echo "1. Launch game WITH GUI (not headless)"
echo "2. Test pause menu (ESC/P keys)"
echo "3. Test settings from pause menu"
echo "4. Capture screenshots that actually show something"
echo ""

# Clean up old screenshots
rm -rf ~/Library/Application\ Support/Godot/app_userdata/Rando\'s\ Reservoir/testing/screenshots/current/*

# Create test script that will run IN the game
cat > /tmp/menu_test.gd << 'EOF'
extends Node

var test_step = 0
var screenshot_dir = "user://testing/screenshots/current"

func _ready():
	print("=== MENU TEST STARTING ===")
	DirAccess.make_dir_recursive_absolute(screenshot_dir)
	set_process(true)
	
	# Give game time to load
	await get_tree().create_timer(2.0).timeout
	next_test()

func next_test():
	test_step += 1
	match test_step:
		1: test_initial_state()
		2: test_esc_opens_pause()
		3: test_esc_closes_pause()
		4: test_p_opens_pause()
		5: test_settings_button()
		6: finish_test()

func test_initial_state():
	print("\n[1] Capturing initial game state...")
	capture_screenshot("01_game_running")
	await get_tree().create_timer(1.0).timeout
	next_test()

func test_esc_opens_pause():
	print("\n[2] Pressing ESC to open pause menu...")
	simulate_key(KEY_ESCAPE)
	await get_tree().create_timer(0.5).timeout
	capture_screenshot("02_pause_menu_open")
	
	var pause_menu = get_node_or_null("/root/PlayerTestScene/PauseMenu")
	if pause_menu and pause_menu.visible:
		print("✓ Pause menu opened with ESC")
	else:
		print("✗ Pause menu failed to open")
	
	await get_tree().create_timer(1.0).timeout
	next_test()

func test_esc_closes_pause():
	print("\n[3] Pressing ESC to close pause menu...")
	simulate_key(KEY_ESCAPE)
	await get_tree().create_timer(0.5).timeout
	capture_screenshot("03_pause_menu_closed")
	
	await get_tree().create_timer(1.0).timeout
	next_test()

func test_p_opens_pause():
	print("\n[4] Pressing P to open pause menu...")
	simulate_key(KEY_P)
	await get_tree().create_timer(0.5).timeout
	capture_screenshot("04_pause_menu_p_key")
	
	var pause_menu = get_node_or_null("/root/PlayerTestScene/PauseMenu")
	if pause_menu and pause_menu.visible:
		print("✓ Pause menu opened with P")
	else:
		print("✗ P key failed to open pause menu")
	
	await get_tree().create_timer(1.0).timeout
	next_test()

func test_settings_button():
	print("\n[5] Testing Settings button from pause menu...")
	
	var pause_menu = get_node_or_null("/root/PlayerTestScene/PauseMenu")
	if pause_menu:
		var settings_btn = pause_menu.find_child("SettingsButton", true, false)
		if settings_btn and settings_btn is Button:
			print("Found settings button, clicking...")
			settings_btn.pressed.emit()
			await get_tree().create_timer(1.0).timeout
			capture_screenshot("05_settings_from_pause")
			
			# Check if settings opened
			var settings = get_node_or_null("/root/SettingsMenu")
			if settings and settings.visible:
				print("✓ Settings menu opened")
			else:
				print("✗ Settings menu failed to open")
				print("  Checking MenuManager...")
				var menu_manager = get_node_or_null("/root/MenuManager")
				if menu_manager:
					print("  MenuManager exists")
					if menu_manager.has_method("get_current_menu"):
						print("  Current menu: " + str(menu_manager.get_current_menu()))
	
	await get_tree().create_timer(1.0).timeout
	next_test()

func finish_test():
	print("\n=== TEST COMPLETE ===")
	print("Screenshots saved to: " + screenshot_dir)
	print("NOW VERIFY WITH READ TOOL!")
	
	# List screenshots with sizes
	var dir = DirAccess.open(screenshot_dir)
	if dir:
		dir.list_dir_begin()
		var file = dir.get_next()
		while file != "":
			if file.ends_with(".png"):
				var path = screenshot_dir + "/" + file
				var size = FileAccess.get_file_as_bytes(path).size()
				print("  - %s: %d bytes %s" % [file, size, "⚠️ LIKELY BLACK" if size < 10000 else "✓"])
			file = dir.get_next()
	
	await get_tree().create_timer(2.0).timeout
	get_tree().quit()

func simulate_key(keycode):
	var event = InputEventKey.new()
	event.keycode = keycode
	event.pressed = true
	Input.parse_input_event(event)
	await get_tree().process_frame
	event.pressed = false
	Input.parse_input_event(event)

func capture_screenshot(name):
	var img = get_viewport().get_texture().get_image()
	var path = screenshot_dir + "/" + name + ".png"
	img.save_png(path)
	var size = FileAccess.get_file_as_bytes(path).size()
	print("📸 Screenshot: %s.png (%d bytes)" % [name, size])
EOF

# Run the test WITH GUI
echo "Launching Godot WITH GUI for testing..."
echo "The game window will open - this is REQUIRED for proper testing"
echo ""

/Applications/Godot.app/Contents/MacOS/Godot \
  --path /Users/matt/Projects/randos-reservoir \
  --script /tmp/menu_test.gd \
  2>&1 | grep -E "(TEST|Screenshot|✓|✗|ERROR|pause|settings|📸)"

echo ""
echo "Test complete. Screenshots are in:"
echo "~/Library/Application Support/Godot/app_userdata/Rando's Reservoir/testing/screenshots/current/"
echo ""
echo "NEXT STEP: Use Read tool to verify each screenshot shows the expected UI"