extends Node
## Automated fade test that runs without user input and captures screenshots

@onready var fade_transition: FadeTransition
var test_stage: int = 0

func _ready() -> void:
	print("=== AUTOMATED FADE TEST STARTING ===")
	
	# Create the main scene
	var main_scene = Control.new()
	main_scene.set_anchors_preset(Control.PRESET_FULL_RECT)
	get_tree().root.add_child(main_scene)
	
	# Add bright background for contrast
	var bg = ColorRect.new()
	bg.color = Color(0.0, 1.0, 0.0, 1.0)  # Bright green
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	main_scene.add_child(bg)
	
	# Add label
	var label = Label.new()
	label.text = "AUTOMATED FADE TEST - GREEN BACKGROUND"
	label.add_theme_font_size_override("font_size", 32)
	label.add_theme_color_override("font_color", Color.BLACK)
	label.set_anchors_preset(Control.PRESET_CENTER)
	main_scene.add_child(label)
	
	# Load fade transition
	var fade_scene = load("res://src/scenes/transitions/fade_transition.tscn")
	fade_transition = fade_scene.instantiate()
	get_tree().root.add_child.call_deferred(fade_transition)
	
	# Wait for setup
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().create_timer(0.2).timeout
	
	print("Fade transition setup - ColorRect found:", fade_transition.color_rect != null)
	
	# Start automated test sequence
	_run_test_sequence()

func _run_test_sequence() -> void:
	print("Starting automated test sequence...")
	
	# Test 1: Initial state - green background should be visible
	await get_tree().create_timer(1.0).timeout
	_take_screenshot("automated_01_initial_green")
	
	# Test 2: Show instant black overlay
	print("TEST: Showing instant black overlay")
	fade_transition.show_overlay()
	await get_tree().process_frame
	await get_tree().process_frame
	_take_screenshot("automated_02_instant_black_overlay")
	
	# Verify overlay is showing
	if fade_transition.color_rect:
		print("Overlay alpha:", fade_transition.color_rect.modulate.a)
		print("Overlay visible:", fade_transition.color_rect.visible)
		print("Overlay color:", fade_transition.color_rect.color)
	
	# Test 3: Hold black overlay for verification
	await get_tree().create_timer(2.0).timeout
	_take_screenshot("automated_03_black_overlay_held")
	
	# Test 4: Hide overlay - should return to green
	print("TEST: Hiding overlay - should return to green")
	fade_transition.hide_overlay()
	await get_tree().process_frame
	await get_tree().process_frame
	_take_screenshot("automated_04_green_restored")
	
	# Test 5: Animated fade in
	print("TEST: Starting animated fade in")
	fade_transition.set_fade_duration(2.0)  # Slow fade for visibility
	fade_transition.fade_in()
	
	# Capture at different stages
	await get_tree().create_timer(0.5).timeout
	_take_screenshot("automated_05_fade_in_25_percent")
	
	await get_tree().create_timer(1.0).timeout
	_take_screenshot("automated_06_fade_in_75_percent")
	
	await fade_transition.fade_in_completed
	_take_screenshot("automated_07_fade_in_complete")
	
	# Test 6: Animated fade out
	print("TEST: Starting animated fade out")
	fade_transition.fade_out()
	
	await get_tree().create_timer(1.0).timeout
	_take_screenshot("automated_08_fade_out_50_percent")
	
	await fade_transition.fade_out_completed
	_take_screenshot("automated_09_fade_out_complete")
	
	print("=== AUTOMATED TEST COMPLETE ===")
	print("Check test_screenshots/ for visual proof")
	
	# Quit after completion
	await get_tree().create_timer(1.0).timeout
	get_tree().quit()

func _take_screenshot(filename: String) -> void:
	var viewport = get_viewport()
	var image = viewport.get_texture().get_image()
	
	# Ensure directory exists
	var dir = DirAccess.open("user://")
	if not dir.dir_exists("test_screenshots"):
		dir.make_dir("test_screenshots")
	
	var path = "user://test_screenshots/" + filename + ".png"
	var error = image.save_png(path)
	
	if error == OK:
		var real_path = OS.get_user_data_dir() + "/test_screenshots/" + filename + ".png"
		print("Screenshot saved: ", real_path)
	else:
		print("ERROR saving screenshot: ", filename, " Error code: ", error)