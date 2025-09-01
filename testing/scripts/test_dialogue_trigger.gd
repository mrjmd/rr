extends SceneTree
## Test script that triggers dialogue and captures screenshot

func _init() -> void:
	print("[DialogueTest] Starting dialogue trigger test...")
	
	# Wait for scene to fully load
	await process_frame
	await create_timer(1.0).timeout
	
	# Get the dialogue demo node
	var demo = get_root().get_node("DialogueDemo")
	if not demo:
		print("[DialogueTest] ERROR: Could not find DialogueDemo node!")
		quit(1)
		return
	
	print("[DialogueTest] Found DialogueDemo, triggering test_basic_dialogue...")
	
	# Call the test method directly
	demo._test_basic_dialogue()
	
	# Wait for dialogue to appear
	await create_timer(1.0).timeout
	
	print("[DialogueTest] Taking screenshot after dialogue trigger...")
	
	# Capture screenshot
	var viewport = get_root()
	var image = viewport.get_texture().get_image()
	
	var filename = "res://testing/screenshots/current/dialogue_triggered.png"
	image.save_png(filename)
	print("[DialogueTest] Saved screenshot to: " + filename)
	
	# Check if dialogue is actually visible
	var dialogue_system = demo.get_node("DialogueSystem")
	if dialogue_system:
		print("[DialogueTest] DialogueSystem node found")
		print("[DialogueTest] DialogueSystem visible: %s" % dialogue_system.visible)
		
		var dialogue_box = dialogue_system.get_node("DialogueBox")
		if dialogue_box:
			print("[DialogueTest] DialogueBox found")
			print("[DialogueTest] DialogueBox visible: %s" % dialogue_box.visible)
			print("[DialogueTest] DialogueBox global position: %s" % dialogue_box.global_position)
			print("[DialogueTest] DialogueBox size: %s" % dialogue_box.size)
		else:
			print("[DialogueTest] ERROR: DialogueBox not found!")
	else:
		print("[DialogueTest] ERROR: DialogueSystem not found!")
	
	await create_timer(2.0).timeout
	quit()