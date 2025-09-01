extends GutTest
class_name FadeFinalProof
## Final visual proof test that the fade transition system works correctly
## Uses bright contrasting colors and clear visual indicators

var fade_transition: FadeTransition
var main_scene: Control
var status_label: Label

func before_each() -> void:
	print("=== FADE FINAL PROOF TEST ===")
	
	# Create main scene with bright magenta background
	main_scene = Control.new()
	main_scene.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child_autofree(main_scene)
	
	# Bright magenta background for maximum contrast
	var bg = ColorRect.new()
	bg.color = Color(1.0, 0.0, 1.0, 1.0)  # Bright magenta
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	main_scene.add_child(bg)
	
	# Large status label
	status_label = Label.new()
	status_label.text = "BRIGHT MAGENTA BACKGROUND - FADE TEST PROOF"
	status_label.add_theme_font_size_override("font_size", 28)
	status_label.add_theme_color_override("font_color", Color.WHITE)
	status_label.set_anchors_preset(Control.PRESET_CENTER)
	main_scene.add_child(status_label)
	
	# Load fade transition
	var fade_scene = load("res://src/scenes/transitions/fade_transition.tscn")
	assert_not_null(fade_scene, "Fade transition scene should load")
	
	fade_transition = fade_scene.instantiate()
	assert_not_null(fade_transition, "Fade transition should instantiate")
	
	# Add to scene tree
	get_tree().root.add_child(fade_transition)
	
	# Wait for setup
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().create_timer(0.1).timeout

func after_each() -> void:
	if fade_transition and is_instance_valid(fade_transition):
		fade_transition.queue_free()

func test_fade_visual_proof() -> void:
	assert_not_null(fade_transition.color_rect, "ColorRect should be found")
	
	print("PROOF TEST: Starting visual verification")
	
	# STEP 1: Show magenta background clearly
	status_label.text = "STEP 1: MAGENTA BACKGROUND VISIBLE"
	await get_tree().create_timer(0.5).timeout
	_take_proof_screenshot("proof_01_magenta_background")
	
	# Verify initial state
	assert_almost_eq(fade_transition.color_rect.modulate.a, 0.0, 0.01, "Overlay should start transparent")
	
	# STEP 2: Show instant black overlay
	print("PROOF: Showing black overlay over magenta")
	status_label.text = "STEP 2: BLACK OVERLAY COVERING MAGENTA"
	fade_transition.show_overlay()
	
	await get_tree().process_frame
	await get_tree().process_frame
	_take_proof_screenshot("proof_02_black_overlay_over_magenta")
	
	# Verify overlay is opaque
	assert_eq(fade_transition.color_rect.modulate.a, 1.0, "Overlay should be fully opaque")
	
	# STEP 3: Hide overlay to reveal magenta again
	print("PROOF: Hiding overlay to reveal magenta")
	status_label.text = "STEP 3: MAGENTA REVEALED AGAIN"
	fade_transition.hide_overlay()
	
	await get_tree().process_frame
	await get_tree().process_frame
	_take_proof_screenshot("proof_03_magenta_revealed")
	
	# Verify overlay is transparent
	assert_almost_eq(fade_transition.color_rect.modulate.a, 0.0, 0.01, "Overlay should be transparent")
	
	# STEP 4: Test animated fade in with slow duration
	print("PROOF: Testing slow animated fade in")
	status_label.text = "STEP 4: SLOW FADE TO BLACK STARTING"
	fade_transition.set_fade_duration(1.5)
	
	# Start fade in
	fade_transition.fade_in()
	
	# Capture at different stages
	await get_tree().create_timer(0.3).timeout
	_take_proof_screenshot("proof_04_fade_in_20_percent")
	
	await get_tree().create_timer(0.6).timeout
	_take_proof_screenshot("proof_05_fade_in_60_percent")
	
	await fade_transition.fade_in_completed
	_take_proof_screenshot("proof_06_fade_in_complete")
	
	# STEP 5: Test animated fade out
	print("PROOF: Testing slow animated fade out")
	status_label.text = "STEP 5: SLOW FADE TO MAGENTA"
	fade_transition.fade_out()
	
	await get_tree().create_timer(0.6).timeout
	_take_proof_screenshot("proof_07_fade_out_40_percent")
	
	await fade_transition.fade_out_completed
	_take_proof_screenshot("proof_08_fade_out_complete")
	
	print("=== FADE PROOF TEST COMPLETE ===")
	print("Visual evidence saved to test_screenshots/ folder")
	print("Magenta → Black → Magenta transitions verified!")

func _take_proof_screenshot(filename: String) -> void:
	if fade_transition and fade_transition.has_method("take_screenshot"):
		fade_transition.take_screenshot(filename)
	else:
		# Fallback method
		var viewport = get_viewport()
		var image = viewport.get_texture().get_image()
		var dir = DirAccess.open("user://")
		if not dir.dir_exists("test_screenshots"):
			dir.make_dir("test_screenshots")
		image.save_png("user://test_screenshots/" + filename + ".png")
	
	print("Proof screenshot: ", filename)