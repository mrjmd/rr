extends Control
## Debug dialogue box positioning to find why it's invisible

var dialogue_system: DialogueSystem

func _ready():
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	
	# Create background
	var bg = ColorRect.new()
	bg.color = Color.RED  # Bright red so we can see the scene loaded
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	
	# Add debug label
	var label = Label.new()
	label.text = "DIALOGUE BOX POSITION DEBUG"
	label.add_theme_font_size_override("font_size", 32)
	label.modulate = Color.WHITE
	label.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(label)
	
	# Load dialogue system
	var dialogue_scene = preload("res://src/scenes/ui/dialogue/dialogue_system.tscn")
	dialogue_system = dialogue_scene.instantiate()
	add_child(dialogue_system)
	
	# Wait and debug
	await get_tree().create_timer(2.0).timeout
	_debug_positioning()
	
	# Try to start dialogue
	await get_tree().create_timer(1.0).timeout
	dialogue_system.start_dialogue("test_intro")
	
	# Debug after dialogue start
	await get_tree().create_timer(2.0).timeout
	_debug_positioning()

func _debug_positioning():
	print("\n=== DIALOGUE SYSTEM DEBUG ===")
	
	if dialogue_system:
		print("DialogueSystem:")
		print("  Layer: ", dialogue_system.layer)
		print("  Visible: ", dialogue_system.visible)
		print("  Position: ", dialogue_system.position)
		print("  Size: ", dialogue_system.size)
		print("  Global Position: ", dialogue_system.global_position)
		print("  Anchors: L:", dialogue_system.anchor_left, " T:", dialogue_system.anchor_top, " R:", dialogue_system.anchor_right, " B:", dialogue_system.anchor_bottom)
		
		var dialogue_box = dialogue_system.get_node_or_null("DialogueBox")
		if dialogue_box:
			print("DialogueBox:")
			print("  Visible: ", dialogue_box.visible)
			print("  Position: ", dialogue_box.position)
			print("  Size: ", dialogue_box.size)
			print("  Global Position: ", dialogue_box.global_position)
			print("  Anchors: L:", dialogue_box.anchor_left, " T:", dialogue_box.anchor_top, " R:", dialogue_box.anchor_right, " B:", dialogue_box.anchor_bottom)
			print("  Offset: ", dialogue_box.offset_left, ",", dialogue_box.offset_top, " to ", dialogue_box.offset_right, ",", dialogue_box.offset_bottom)
			print("  Modulate: ", dialogue_box.modulate)
			print("  Z-Index: ", dialogue_box.z_index)
			
			var bg_panel = dialogue_box.get_node_or_null("BackgroundPanel")
			if bg_panel:
				print("BackgroundPanel:")
				print("  Visible: ", bg_panel.visible)
				print("  Position: ", bg_panel.position)
				print("  Size: ", bg_panel.size)
				print("  Modulate: ", bg_panel.modulate)
			
			# Force the dialogue box to be visible and positioned
			print("\n=== FORCING VISIBILITY ===")
			dialogue_box.visible = true
			dialogue_box.modulate = Color.WHITE
			dialogue_box.z_index = 1000  # Force to front
			
			# Override positioning to center screen
			dialogue_box.anchor_left = 0.1
			dialogue_box.anchor_right = 0.9
			dialogue_box.anchor_top = 0.7
			dialogue_box.anchor_bottom = 0.95
			dialogue_box.offset_left = 0
			dialogue_box.offset_right = 0
			dialogue_box.offset_top = 0
			dialogue_box.offset_bottom = 0
			
			print("FORCED DialogueBox to center screen with high z-index")
			
			if bg_panel:
				bg_panel.visible = true
				bg_panel.modulate = Color(1, 1, 1, 0.9)  # Slightly transparent white
		else:
			print("ERROR: DialogueBox node not found!")
	else:
		print("ERROR: DialogueSystem not found!")
		
	print("=== END DEBUG ===\n")