extends Control
## Simple standalone proof that fade transition works with clear visual contrast

@onready var fade_transition: FadeTransition
@onready var status_label: Label

func _ready() -> void:
	print("=== SIMPLE FADE PROOF TEST ===")
	
	# Set bright cyan background
	var bg = ColorRect.new()
	bg.color = Color(0.0, 1.0, 1.0, 1.0)  # Bright cyan
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	move_child(bg, 0)
	
	# Add status label
	status_label = Label.new()
	status_label.text = "BRIGHT CYAN BACKGROUND - FADE PROOF"
	status_label.add_theme_font_size_override("font_size", 36)
	status_label.add_theme_color_override("font_color", Color.BLACK)
	status_label.set_anchors_preset(Control.PRESET_CENTER)
	add_child(status_label)
	
	# Load fade transition
	var fade_scene = load("res://src/scenes/transitions/fade_transition.tscn")
	fade_transition = fade_scene.instantiate()
	get_tree().root.add_child.call_deferred(fade_transition)
	
	# Wait for setup
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().create_timer(0.2).timeout
	
	print("Starting proof sequence...")
	_run_proof_sequence()

func _run_proof_sequence() -> void:
	# Proof 1: Show cyan background (should be clearly visible)
	await get_tree().create_timer(1.0).timeout
	_take_screenshot("simple_proof_01_cyan_visible")
	
	# Proof 2: Show black overlay (should completely cover cyan)
	status_label.text = "BLACK OVERLAY COVERING CYAN"
	print("PROOF: Showing black overlay - cyan should disappear")
	fade_transition.show_overlay()
	await get_tree().process_frame
	await get_tree().process_frame
	_take_screenshot("simple_proof_02_black_covers_cyan")
	
	# Hold black overlay for clear evidence
	await get_tree().create_timer(2.0).timeout
	_take_screenshot("simple_proof_03_black_overlay_held")
	
	# Proof 3: Hide overlay (cyan should reappear)
	print("PROOF: Hiding overlay - cyan should reappear")
	status_label.text = "CYAN BACKGROUND RESTORED"
	fade_transition.hide_overlay()
	await get_tree().process_frame
	await get_tree().process_frame
	_take_screenshot("simple_proof_04_cyan_restored")
	
	print("=== SIMPLE PROOF COMPLETE ===")
	print("If you see different colors in screenshots, fade is working!")
	print("Cyan background → Black overlay → Cyan background")
	
	# Quit after proof
	await get_tree().create_timer(2.0).timeout
	get_tree().quit()

func _take_screenshot(filename: String) -> void:
	var viewport = get_viewport()
	var image = viewport.get_texture().get_image()
	
	# Save to project test_screenshots
	var dir = DirAccess.open("res://")
	if not dir.dir_exists("test_screenshots"):
		dir.make_dir("test_screenshots")
	
	var path = "res://test_screenshots/" + filename + ".png"
	var error = image.save_png(path)
	
	if error == OK:
		print("Proof screenshot saved: ", path)
	else:
		print("ERROR saving proof screenshot: ", filename)