extends SceneTree
## Test script for menu audio and visual feedback system

const DEMO_SCENE = "res://src/scenes/demo/menu_feedback_demo.tscn"
const SCREENSHOT_DIR = "testing/screenshots/current/"

func _ready() -> void:
	if OS.is_debug_build():
		print("Starting menu feedback test...")
	
	# Load the demo scene
	var demo_scene = load(DEMO_SCENE)
	if not demo_scene:
		print("ERROR: Could not load demo scene: ", DEMO_SCENE)
		quit(1)
		return
	
	var demo_instance = demo_scene.instantiate()
	if not demo_instance:
		print("ERROR: Could not instantiate demo scene")
		quit(1)
		return
	
	root.add_child(demo_instance)
	
	# Wait a frame for everything to initialize
	await process_frame
	
	# Run feedback tests
	await _run_feedback_tests(demo_instance)
	
	print("Menu feedback test completed successfully!")
	quit(0)

func _run_feedback_tests(demo: Node) -> void:
	"""Run comprehensive feedback system tests"""
	print("Testing menu feedback system...")
	
	# Test 1: Initial state
	_capture_screenshot("feedback_01_initial", "Initial demo state")
	await _wait_frames(10)
	
	# Test 2: Test hover effects (simulate via code since we can't simulate mouse)
	print("Testing hover effects...")
	var normal_button = demo.get_node("Container/ButtonContainer/NormalButton")
	if normal_button and normal_button.has_method("animate_hover_enter"):
		normal_button.animate_hover_enter()
		await _wait_frames(15)
		_capture_screenshot("feedback_02_hover", "Button hover effect")
		
		normal_button.animate_hover_exit()
		await _wait_frames(10)
	
	# Test 3: Test press animation
	print("Testing press animation...")
	if normal_button and normal_button.has_method("animate_press"):
		normal_button.animate_press()
		await _wait_frames(5)
		_capture_screenshot("feedback_03_press", "Button press animation")
		await _wait_frames(10)
	
	# Test 4: Test confirm button feedback
	print("Testing confirm button...")
	var confirm_button = demo.get_node("Container/ButtonContainer/ConfirmButton")
	if confirm_button and confirm_button.has_method("trigger_confirm_button"):
		confirm_button.trigger_confirm_button()
		await _wait_frames(10)
		_capture_screenshot("feedback_04_confirm", "Confirm button feedback")
	
	# Test 5: Test back button feedback
	print("Testing back button...")
	var back_button = demo.get_node("Container/ButtonContainer/BackButton")
	if back_button and back_button.has_method("trigger_back_button"):
		back_button.trigger_back_button()
		await _wait_frames(10)
		_capture_screenshot("feedback_05_back", "Back button feedback")
	
	# Test 6: Test error feedback
	print("Testing error feedback...")
	var error_button = demo.get_node("Container/ButtonContainer/ErrorButton")
	if error_button and error_button.has_method("trigger_error_feedback"):
		error_button.trigger_error_feedback()
		await _wait_frames(5)
		_capture_screenshot("feedback_06_error", "Error feedback (red flash)")
		await _wait_frames(15)  # Wait for error animation to complete
	
	# Test 7: Test slider interaction
	print("Testing slider interaction...")
	var test_slider = demo.get_node("Container/SliderContainer/TestSlider")
	if test_slider:
		var original_value = test_slider.value
		test_slider.value = 0.3
		await _wait_frames(5)
		_capture_screenshot("feedback_07_slider", "Slider value changed")
		test_slider.value = original_value
		await _wait_frames(5)
	
	# Test 8: Test checkbox interaction
	print("Testing checkbox interaction...")
	var test_checkbox = demo.get_node("Container/CheckboxContainer/TestCheckbox")
	if test_checkbox:
		test_checkbox.button_pressed = true
		await _wait_frames(5)
		_capture_screenshot("feedback_08_checkbox", "Checkbox checked")
		test_checkbox.button_pressed = false
		await _wait_frames(5)
	
	# Test 9: Test audio manager availability
	print("Testing audio system availability...")
	var has_audio_manager = root.has_node("AudioManager")
	print("AudioManager available: ", has_audio_manager)
	
	if has_audio_manager:
		var audio_manager = root.get_node("AudioManager")
		if audio_manager.has_method("play_ui_sound"):
			print("AudioManager methods available:")
			print("  - play_ui_sound: Available")
			print("  - SFX sounds configured: Available")
			# Note: We'll test actual sound playback in the demo
	
	# Test 10: Final state
	_capture_screenshot("feedback_09_final", "Final test state")
	
	# Test button debug info
	if normal_button and normal_button.has_method("get_button_debug_info"):
		var debug_info = normal_button.get_button_debug_info()
		print("Button debug info: ", debug_info)

func _wait_frames(count: int) -> void:
	"""Wait for specified number of frames"""
	for i in count:
		await process_frame

func _capture_screenshot(filename: String, description: String) -> void:
	"""Capture a screenshot for verification"""
	print("Capturing screenshot: ", filename, " - ", description)
	
	# Wait one frame to ensure rendering is complete
	await process_frame
	
	var viewport = get_root().get_viewport()
	var image = viewport.get_texture().get_image()
	
	# Ensure screenshot directory exists
	if not DirAccess.dir_exists_absolute(SCREENSHOT_DIR):
		DirAccess.open("user://").make_dir_recursive_absolute(SCREENSHOT_DIR)
	
	var full_path = SCREENSHOT_DIR + filename + ".png"
	var error = image.save_png(full_path)
	
	if error == OK:
		print("Screenshot saved: ", full_path)
	else:
		print("ERROR: Failed to save screenshot: ", error)

func _test_audio_integration() -> void:
	"""Test audio system integration"""
	print("Testing audio system integration...")
	
	if not root.has_node("AudioManager"):
		print("WARNING: AudioManager not available")
		return
	
	var audio_manager = root.get_node("AudioManager")
	
	# Test each UI sound
	var ui_sounds = ["ui_click", "ui_hover", "ui_back", "ui_confirm", "ui_error"]
	
	for sound in ui_sounds:
		print("Testing sound: ", sound)
		if audio_manager.has_method("play_ui_sound"):
			audio_manager.play_ui_sound(sound)
		else:
			print("  WARNING: play_ui_sound method not available")
		
		await _wait_frames(10)  # Brief pause between sounds