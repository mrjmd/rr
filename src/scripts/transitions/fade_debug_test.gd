extends Control
## Debug test - shows fade overlay manually for visibility

func _ready() -> void:
	print("Fade Debug Test Started")
	
	# Set background color so we can see the scene
	var bg = ColorRect.new()
	bg.color = Color(0.3, 0.5, 0.3, 1.0)  # Green background
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	move_child(bg, 0)
	
	# Add label
	var label = Label.new()
	label.text = "Fade Debug Test\nWait for manual overlay tests..."
	label.add_theme_font_size_override("font_size", 24)
	label.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	add_child(label)
	
	print("Creating fade transition overlay...")
	
	# Create the fade transition directly
	var fade_scene = load("res://src/scenes/transitions/fade_transition.tscn")
	if not fade_scene:
		print("ERROR: Could not load fade transition scene!")
		return
		
	var fade = fade_scene.instantiate()
	if not fade:
		print("ERROR: Could not instantiate fade transition!")
		return
	
	print("Adding fade transition to scene tree...")
	get_tree().root.add_child.call_deferred(fade)
	
	# Wait for the deferred call to complete
	await get_tree().process_frame
	await get_tree().process_frame
	
	print("Starting debug tests...")
	
	# Test 1: Show overlay immediately (should be black screen)
	await get_tree().create_timer(1.0).timeout
	label.text = "TEST 1: Showing black overlay (should be black screen)"
	print("TEST 1: Showing black overlay")
	fade.show_overlay()
	
	await get_tree().create_timer(2.0).timeout
	
	# Test 2: Hide overlay (should show green background)
	label.text = "TEST 2: Hiding overlay (should show green background)"
	print("TEST 2: Hiding overlay")
	fade.hide_overlay()
	
	await get_tree().create_timer(2.0).timeout
	
	# Test 3: Manual fade in
	label.text = "TEST 3: Fade in (should fade to black)"
	print("TEST 3: Manual fade in")
	fade.fade_in()
	await fade.fade_in_completed
	
	await get_tree().create_timer(1.0).timeout
	
	# Test 4: Manual fade out  
	label.text = "TEST 4: Fade out (should fade back to green)"
	print("TEST 4: Manual fade out")
	fade.fade_out()
	await fade.fade_out_completed
	
	await get_tree().create_timer(1.0).timeout
	
	label.text = "All tests complete!"
	print("All manual tests completed")
	
	# Clean up
	fade.queue_free()