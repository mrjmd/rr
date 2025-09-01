extends Control
## Visual test - holds black overlay for longer visibility testing

func _ready() -> void:
	print("Fade Visual Test Started")
	
	# Set bright background color for contrast
	var bg = ColorRect.new()
	bg.color = Color(1.0, 0.0, 0.0, 1.0)  # Bright red background
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	move_child(bg, 0)
	
	# Add large visible label
	var label = Label.new()
	label.text = "RED BACKGROUND - FADE TEST"
	label.add_theme_font_size_override("font_size", 48)
	label.add_theme_color_override("font_color", Color.WHITE)
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
	
	print("Starting visual tests...")
	
	# Show red screen for 2 seconds
	await get_tree().create_timer(2.0).timeout
	label.text = "NOW FADING TO BLACK IN 3 SECONDS..."
	
	await get_tree().create_timer(3.0).timeout
	
	# Show black overlay for extended time
	print("SHOWING BLACK OVERLAY - SHOULD SEE BLACK SCREEN")
	fade.show_overlay()
	label.text = "BLACK OVERLAY ACTIVE"
	
	# Hold black overlay for 5 seconds
	await get_tree().create_timer(5.0).timeout
	
	# Hide overlay to return to red
	print("HIDING BLACK OVERLAY - SHOULD SEE RED AGAIN") 
	fade.hide_overlay()
	label.text = "BLACK OVERLAY HIDDEN - RED BACKGROUND"
	
	await get_tree().create_timer(3.0).timeout
	
	# Test manual fade in with extended duration
	fade.set_fade_duration(2.0)  # Slow 2 second fade
	print("STARTING SLOW FADE IN (2 seconds)")
	label.text = "SLOW FADE TO BLACK STARTING..."
	fade.fade_in()
	await fade.fade_in_completed
	
	print("FADE IN COMPLETE - HOLDING BLACK")
	await get_tree().create_timer(3.0).timeout
	
	# Test manual fade out
	print("STARTING SLOW FADE OUT (2 seconds)")
	fade.fade_out()
	await fade.fade_out_completed
	
	print("FADE OUT COMPLETE")
	label.text = "ALL FADE TESTS COMPLETE!"
	
	await get_tree().create_timer(2.0).timeout
	
	# Clean up
	fade.queue_free()