#!/usr/bin/env -S godot --headless --script
## Test script to capture pause menu screenshots for verification

extends SceneTree

# Screenshot configuration
const SCREENSHOT_DIR = "testing/screenshots/current/"
const SCENE_PATH = "res://src/scenes/testing/pause_menu_standalone.tscn"

# Test timing
var test_stage: int = 0
var stage_timer: float = 0.0
var stage_duration: float = 1.0

# Scene references
var test_scene: Node
var pause_menu: Node

func _initialize() -> void:
	"""Initialize the screenshot test"""
	print("=== Pause Menu Screenshot Test ===")
	
	# Load the standalone test scene
	var scene_resource = load(SCENE_PATH)
	if not scene_resource:
		print("ERROR: Could not load test scene: ", SCENE_PATH)
		quit(1)
		return
	
	test_scene = scene_resource.instantiate()
	current_scene = test_scene
	
	# Find the pause menu
	pause_menu = test_scene.get_node("PauseMenu")
	if not pause_menu:
		print("ERROR: Could not find PauseMenu node")
		quit(1)
		return
	
	print("Test scene loaded successfully")
	
	# Check for EventBus through the scene tree root
	var eventbus_available = false
	if root and root.has_node("/root/EventBus"):
		eventbus_available = true
	print("EventBus available: ", eventbus_available)
	
	# Start the test sequence
	_start_test_sequence()

func _start_test_sequence() -> void:
	"""Start the automated test sequence"""
	print("Starting test sequence...")
	test_stage = 0
	stage_timer = 0.0

func _process(delta: float) -> bool:
	"""Process the test stages"""
	stage_timer += delta
	
	match test_stage:
		0:
			# Initial state - capture before opening menu
			if stage_timer >= stage_duration:
				_capture_screenshot("pause_menu_before")
				_advance_stage()
		
		1:
			# Open pause menu
			if stage_timer >= 0.5:  # Brief pause
				print("Opening pause menu...")
				pause_menu.show_menu()
				_advance_stage()
		
		2:
			# Menu open - capture screenshot
			if stage_timer >= stage_duration:
				_capture_screenshot("pause_menu_open")
				_advance_stage()
		
		3:
			# Close menu
			if stage_timer >= 0.5:
				print("Closing pause menu...")
				pause_menu.hide_menu()
				_advance_stage()
		
		4:
			# Final state - capture after closing
			if stage_timer >= stage_duration:
				_capture_screenshot("pause_menu_after")
				_finish_test()
	
	return true

func _advance_stage() -> void:
	"""Advance to the next test stage"""
	test_stage += 1
	stage_timer = 0.0

func _capture_screenshot(filename_prefix: String) -> void:
	"""Capture a viewport screenshot"""
	var viewport = root.get_viewport()
	if not viewport:
		print("ERROR: No viewport available")
		return
	
	# Get the viewport texture
	var img = viewport.get_texture().get_image()
	if not img:
		print("ERROR: Could not get viewport image")
		return
	
	# Ensure screenshot directory exists
	if not DirAccess.dir_exists_absolute(SCREENSHOT_DIR):
		DirAccess.open("res://").make_dir_recursive_absolute(SCREENSHOT_DIR)
	
	# Save screenshot
	var timestamp = Time.get_datetime_string_from_system().replace(":", "-")
	var filename = "%s_%s.png" % [filename_prefix, timestamp]
	var filepath = SCREENSHOT_DIR + filename
	
	var result = img.save_png(filepath)
	if result == OK:
		print("Screenshot saved: ", filepath)
	else:
		print("ERROR: Failed to save screenshot: ", filepath, " (Error: ", result, ")")

func _print_test_state() -> void:
	"""Print current test state for debugging"""
	if not test_scene:
		print("Test scene not available")
		return
	
	var state = test_scene.get_test_state() if test_scene.has_method("get_test_state") else {}
	print("Test State: ", state)
	
	if pause_menu:
		print("Pause Menu - Visible: ", pause_menu.visible, ", Open: ", pause_menu.is_open() if pause_menu.has_method("is_open") else "unknown")

func _finish_test() -> void:
	"""Complete the test and exit"""
	print("Test sequence completed!")
	_print_test_state()
	print("=== Test Complete ===")
	quit(0)

# Entry point when run as script
func _ready() -> void:
	_initialize()