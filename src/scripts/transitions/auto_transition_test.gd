extends Control
## Automatic transition test - triggers transition automatically

var transition_count: int = 0

func _ready() -> void:
	print("Auto Transition Test Started")
	print("Will trigger fade transition in 2 seconds...")
	
	# Set background color so we can see the scene
	var bg = ColorRect.new()
	bg.color = Color(0.3, 0.3, 0.5, 1.0)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	move_child(bg, 0)
	
	# Add label
	var label = Label.new()
	label.text = "Automatic Transition Test\nTransition will trigger in 2 seconds..."
	label.add_theme_font_size_override("font_size", 32)
	label.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	add_child(label)
	
	# Wait then trigger transition
	await get_tree().create_timer(2.0).timeout
	
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
	
	# Connect signals to track progress
	fade.fade_in_completed.connect(func(): print("FADE IN COMPLETED!"))
	fade.fade_out_completed.connect(func(): print("FADE OUT COMPLETED!"))
	fade.transition_completed.connect(func(): 
		print("FULL TRANSITION COMPLETED!")
		label.text = "Transition Complete!"
	)
	
	print("Starting transition (fade to black then back)...")
	fade.transition()
	
	# After transition completes, change the label
	await fade.transition_completed
	label.text = "Transition Complete!\nThe screen faded to black and back!"
	
	# Clean up
	fade.queue_free()