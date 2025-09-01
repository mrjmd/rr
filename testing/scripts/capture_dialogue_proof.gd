extends SceneTree
## Automated screenshot capture for dialogue system verification

func _init():
	# Change to demo scene directory
	var demo_scene = load("res://src/scenes/demo/dialogue_demo.tscn")
	if not demo_scene:
		print("ERROR: Could not load demo scene")
		quit(1)
		return
	
	# Instantiate and add demo scene
	var demo_instance = demo_scene.instantiate()
	get_root().add_child(demo_instance)
	
	# Wait a frame for scene to initialize
	await process_frame
	await get_tree().create_timer(0.5).timeout
	
	print("Taking screenshot 1: Initial demo state")
	_take_screenshot("01_demo_initial.png")
	
	# Get dialogue system from the demo
	var dialogue_system = demo_instance.get_node("DialogueSystem")
	if not dialogue_system:
		print("ERROR: Could not find DialogueSystem")
		quit(1)
		return
	
	# Start basic dialogue
	print("Starting basic dialogue...")
	dialogue_system.start_dialogue("test_intro")
	
	# Wait for dialogue to appear
	await get_tree().create_timer(1.0).timeout
	
	print("Taking screenshot 2: Basic dialogue active")
	_take_screenshot("02_dialogue_basic.png")
	
	# End dialogue
	dialogue_system.end_dialogue()
	await get_tree().create_timer(0.5).timeout
	
	# Start choice dialogue
	print("Starting choice dialogue...")
	dialogue_system.start_dialogue("test_choice")
	
	# Wait for choices to appear
	await get_tree().create_timer(1.5).timeout
	
	print("Taking screenshot 3: Choice dialogue with options")
	_take_screenshot("03_dialogue_choices.png")
	
	print("Screenshot capture complete!")
	print("Check /testing/screenshots/verification/ for proof images")
	
	quit(0)

func _take_screenshot(filename: String):
	var viewport = get_root()
	var image = viewport.get_texture().get_image()
	
	# Ensure directory exists
	var dir = DirAccess.open("res://")
	dir.make_dir_recursive("testing/screenshots/verification")
	
	# Save screenshot
	var path = "res://testing/screenshots/verification/" + filename
	image.save_png(path)
	print("Screenshot saved: ", path)