extends SceneTree
## Comprehensive dialogue visual proof capture

func _init() -> void:
	print("\n=== DIALOGUE VISUAL PROOF TEST ===\n")
	
	# Wait for scene to fully load
	await process_frame
	await create_timer(1.5).timeout
	
	# Capture initial state
	print("1. Capturing initial state...")
	capture_screenshot("01_initial_state")
	
	# Get the dialogue demo node
	var demo = get_root().get_node("DialogueDemo")
	if not demo:
		print("ERROR: Could not find DialogueDemo node!")
		quit(1)
		return
	
	# Trigger basic dialogue
	print("\n2. Triggering basic dialogue...")
	demo._test_basic_dialogue()
	
	# Wait for dialogue to fully appear
	await create_timer(2.0).timeout
	
	print("3. Capturing dialogue active state...")
	capture_screenshot("02_dialogue_active")
	
	# Check dialogue system state
	var dialogue_system = demo.get_node("DialogueSystem")
	if dialogue_system:
		print("\nDialogue System Debug Info:")
		print("  - Visible: %s" % dialogue_system.visible)
		print("  - Modulate: %s" % dialogue_system.modulate)
		print("  - Layer: %s" % dialogue_system.layer)
		
		var dialogue_box = dialogue_system.get_node("DialogueBox")
		if dialogue_box:
			print("\nDialogue Box Debug Info:")
			print("  - Visible: %s" % dialogue_box.visible)
			print("  - Position: %s" % dialogue_box.position)
			print("  - Global Position: %s" % dialogue_box.global_position)
			print("  - Size: %s" % dialogue_box.size)
			print("  - Modulate: %s" % dialogue_box.modulate)
			print("  - Self Modulate: %s" % dialogue_box.self_modulate)
			
			var panel = dialogue_box.get_node("BackgroundPanel")
			if panel:
				print("\nBackground Panel Debug Info:")
				print("  - Visible: %s" % panel.visible)
				print("  - Position: %s" % panel.position)
				print("  - Size: %s" % panel.size)
				print("  - Modulate: %s" % panel.modulate)
				
				# Check if it has the style
				var style = panel.get_theme_stylebox("panel")
				if style:
					print("  - Has StyleBox: YES")
					if style is StyleBoxFlat:
						print("  - Background Color: %s" % style.bg_color)
						print("  - Border Color: %s" % style.border_color)
				else:
					print("  - Has StyleBox: NO (THIS IS THE PROBLEM!)")
	
	# Try to trigger dialogue differently
	print("\n4. Testing dialogue visibility directly...")
	if dialogue_system:
		dialogue_system.show()
		var dialogue_box = dialogue_system.get_node("DialogueBox")
		if dialogue_box:
			dialogue_box.show()
			dialogue_box.modulate = Color.WHITE
			dialogue_box.self_modulate = Color.WHITE
			
			# Force set some test text
			var dialogue_text = dialogue_box.get_node("BackgroundPanel/ContentContainer/DialogueText")
			if dialogue_text:
				dialogue_text.text = "TEST: This dialogue should be visible!"
				dialogue_text.modulate = Color.WHITE
			
			var speaker = dialogue_box.get_node("BackgroundPanel/ContentContainer/SpeakerLabel")
			if speaker:
				speaker.text = "TEST SPEAKER"
				speaker.modulate = Color.WHITE
	
	await create_timer(1.0).timeout
	print("5. Capturing forced visibility state...")
	capture_screenshot("03_forced_visible")
	
	print("\n=== TEST COMPLETE ===")
	print("Check screenshots in testing/screenshots/current/")
	print("Files: 01_initial_state.png, 02_dialogue_active.png, 03_forced_visible.png")
	
	await create_timer(1.0).timeout
	quit()

func capture_screenshot(filename: String) -> void:
	var viewport = get_root()
	var image = viewport.get_texture().get_image()
	var path = "res://testing/screenshots/current/%s.png" % filename
	image.save_png(path)
	print("  Screenshot saved: %s" % path)