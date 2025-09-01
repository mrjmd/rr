class_name FadeSignalTest
extends Node
## Signal-based test that captures screenshots at exact moments of fade transition

# Test configuration
const TEST_DURATION: float = 3.0
const SCREENSHOT_DIR: String = "test_screenshots/"

# References
var fade_transition: FadeTransition
var test_timer: float = 0.0
var screenshots_taken: int = 0

func _ready() -> void:
	print("=== Starting Fade Signal Test ===")
	
	# Ensure screenshot directory exists
	var dir = DirAccess.open("user://")
	if not dir.dir_exists(SCREENSHOT_DIR):
		dir.make_dir(SCREENSHOT_DIR)
		print("Created screenshot directory: user://" + SCREENSHOT_DIR)
	
	# Setup background first
	_setup_test_background()
	
	# Wait a frame before adding fade transition
	await get_tree().process_frame
	
	# Create and setup fade transition
	fade_transition = preload("res://src/scenes/transitions/fade_transition.tscn").instantiate()
	get_tree().root.add_child.call_deferred(fade_transition)
	
	# Wait for it to be added
	await get_tree().process_frame
	
	# Connect signals for precise timing
	if fade_transition:
		fade_transition.transition_started.connect(_on_transition_started)
		fade_transition.transition_halfway.connect(_on_transition_halfway)
		fade_transition.transition_completed.connect(_on_transition_completed)
		fade_transition.fade_in_completed.connect(_on_fade_in_completed)
		fade_transition.fade_out_completed.connect(_on_fade_out_completed)
		print("Fade transition instantiated and signals connected")
	
	# Start test after a brief delay
	await get_tree().create_timer(0.5).timeout
	_start_test()

func _setup_test_background() -> void:
	# Create a bright background to make fade visible
	var bg = ColorRect.new()
	bg.color = Color(0.2, 0.8, 0.2, 1.0)  # Bright green
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	get_tree().root.add_child.call_deferred(bg)
	print("Test background added: bright green for contrast")

func _start_test() -> void:
	print("Starting fade transition test...")
	_save_screenshot("00_before_transition.png")
	
	# Start the full transition
	fade_transition.transition()

func _on_transition_started() -> void:
	print("Signal received: transition_started")
	_save_screenshot("01_transition_started.png")

func _on_fade_in_completed() -> void:
	print("Signal received: fade_in_completed")
	_save_screenshot("02_fade_in_completed.png")

func _on_transition_halfway() -> void:
	print("Signal received: transition_halfway")
	_save_screenshot("03_transition_halfway.png")

func _on_fade_out_completed() -> void:
	print("Signal received: fade_out_completed")
	_save_screenshot("04_fade_out_completed.png")

func _on_transition_completed() -> void:
	print("Signal received: transition_completed")
	_save_screenshot("05_transition_completed.png")
	
	# Test complete
	await get_tree().create_timer(0.5).timeout
	_finish_test()

func _save_screenshot(filename: String) -> void:
	screenshots_taken += 1
	var timestamp = Time.get_unix_time_from_system()
	var timestamped_name = "%02d_%s_%d.png" % [screenshots_taken, filename.get_basename(), timestamp]
	
	# Use Godot's viewport screenshot method
	var image = get_viewport().get_texture().get_image()
	if not image:
		print("ERROR: Could not capture viewport image for ", filename)
		return
	
	var full_path = "user://" + SCREENSHOT_DIR + timestamped_name
	var error = image.save_png(full_path)
	
	if error == OK:
		var real_path = OS.get_user_data_dir() + "/" + SCREENSHOT_DIR + timestamped_name
		print("Screenshot saved: ", real_path)
	else:
		print("ERROR: Could not save screenshot ", timestamped_name, " Error: ", error)

func _finish_test() -> void:
	print("\n=== Fade Signal Test Complete ===")
	print("Screenshots taken: ", screenshots_taken)
	print("Screenshots location: ", OS.get_user_data_dir() + "/" + SCREENSHOT_DIR)
	
	# Create completion marker file
	var completion_file = FileAccess.open("user://" + SCREENSHOT_DIR + "test_complete.txt", FileAccess.WRITE)
	if completion_file:
		completion_file.store_string("Fade signal test completed at: " + str(Time.get_unix_time_from_system()))
		completion_file.close()
	
	# Clean up and exit
	if fade_transition:
		fade_transition.queue_free()
	
	print("Test cleanup complete. Exiting in 2 seconds...")
	await get_tree().create_timer(2.0).timeout
	get_tree().quit()

func _process(delta: float) -> void:
	test_timer += delta
	
	# Safety timeout
	if test_timer > TEST_DURATION * 3:
		print("WARNING: Test timeout reached, forcing exit")
		_finish_test()