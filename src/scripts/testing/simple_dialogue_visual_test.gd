extends Control
## Simple visual test to verify dialogue UI is actually visible

# References
var dialogue_system: DialogueSystem
var test_running: bool = false

func _ready() -> void:
	# Create the test environment
	_setup_test_environment()
	
	# Add dialogue system
	_create_dialogue_system()
	
	# Auto-start test
	await get_tree().create_timer(1.0).timeout
	_run_visual_test()

func _setup_test_environment() -> void:
	"""Set up a clear test environment"""
	# Full screen
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	
	# Clear background
	var background = ColorRect.new()
	background.color = Color.DARK_BLUE
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(background)
	
	# Add title
	var title_label = Label.new()
	title_label.text = "DIALOGUE SYSTEM VISUAL TEST"
	title_label.add_theme_font_size_override("font_size", 32)
	title_label.modulate = Color.YELLOW
	title_label.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.offset_top = 50
	title_label.offset_bottom = 100
	add_child(title_label)
	
	print("SimpleDialogueTest: Test environment created")

func _create_dialogue_system() -> void:
	"""Create and configure dialogue system"""
	# Load dialogue system scene
	var dialogue_scene = preload("res://src/scenes/ui/dialogue/dialogue_system.tscn")
	dialogue_system = dialogue_scene.instantiate()
	add_child(dialogue_system)
	
	print("SimpleDialogueTest: DialogueSystem added to scene")

func _run_visual_test() -> void:
	"""Run simple visual test"""
	if not dialogue_system:
		print("SimpleDialogueTest: ERROR - No dialogue system available")
		return
	
	test_running = true
	print("SimpleDialogueTest: Starting visual test...")
	
	# Take screenshot of initial state
	_take_test_screenshot("01_initial_state")
	await get_tree().create_timer(1.0).timeout
	
	# Start basic dialogue
	print("SimpleDialogueTest: Starting basic dialogue...")
	dialogue_system.start_dialogue("test_intro")
	await get_tree().create_timer(2.0).timeout
	
	# Take screenshot after dialogue start
	_take_test_screenshot("02_dialogue_started")
	await get_tree().create_timer(3.0).timeout
	
	# Take screenshot of typing complete
	_take_test_screenshot("03_dialogue_complete")
	
	# End dialogue
	dialogue_system.end_dialogue()
	await get_tree().create_timer(1.0).timeout
	
	# Take final screenshot
	_take_test_screenshot("04_dialogue_ended")
	
	# Start choice dialogue
	print("SimpleDialogueTest: Starting choice dialogue...")
	dialogue_system.start_dialogue("test_choice")
	await get_tree().create_timer(3.0).timeout
	
	# Take screenshot of choices
	_take_test_screenshot("05_choices_shown")
	
	# Print results
	_print_test_results()
	
	test_running = false

func _take_test_screenshot(test_name: String) -> void:
	"""Take screenshot with clear naming"""
	var viewport = get_viewport()
	if viewport:
		var image = viewport.get_texture().get_image()
		if image:
			var filename = "visual_test_" + test_name + ".png"
			var path = "/Users/matt/Projects/randos-reservoir/testing/screenshots/verification/" + filename
			
			var error = image.save_png(path)
			if error == OK:
				print("SimpleDialogueTest: Screenshot saved - " + filename)
			else:
				print("SimpleDialogueTest: Failed to save screenshot - " + str(error))

func _print_test_results() -> void:
	"""Print test results and analysis"""
	print("\n=== DIALOGUE VISUAL TEST RESULTS ===")
	
	if dialogue_system:
		print("DialogueSystem Status:")
		print("  - Available: YES")
		print("  - Layer: ", dialogue_system.layer)
		print("  - Visible: ", dialogue_system.visible)
		
		var dialogue_box = dialogue_system.get_node_or_null("DialogueBox")
		if dialogue_box:
			print("DialogueBox Status:")
			print("  - Available: YES")
			print("  - Visible: ", dialogue_box.visible)
			print("  - Size: ", dialogue_box.size)
			print("  - Position: ", dialogue_box.position)
			print("  - Global Position: ", dialogue_box.global_position)
		else:
			print("DialogueBox Status: NOT FOUND")
	else:
		print("DialogueSystem Status: NOT AVAILABLE")
	
	print("\nScreenshots saved to: /Users/matt/Projects/randos-reservoir/testing/screenshots/verification/")
	print("Check these files to see what's actually being displayed")
	print("=== END TEST RESULTS ===")

func _input(event: InputEvent) -> void:
	"""Handle input during test"""
	if event.is_action_pressed("ui_cancel"):
		# ESC to quit
		get_tree().quit()
	elif event.is_action_pressed("ui_accept"):
		# Enter to restart test
		if not test_running:
			_run_visual_test()