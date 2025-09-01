extends GutTest
class_name FadeVisualTest
## Comprehensive test that proves the fade transition system works visually
## Uses signal-based testing with built-in screenshot capability

var fade_transition: FadeTransition
var test_scene: Control
var screenshot_counter: int = 0

func before_each() -> void:
	print("=== Starting Fade Visual Test ===")
	screenshot_counter = 0
	
	# Create bright test background
	test_scene = Control.new()
	test_scene.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child_autofree(test_scene)
	
	# Add bright red background for contrast
	var bg = ColorRect.new()
	bg.color = Color(1.0, 0.0, 0.0, 1.0)  # Bright red
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	test_scene.add_child(bg)
	
	# Add large visible label
	var label = Label.new()
	label.text = "FADE VISUAL TEST - RED BACKGROUND"
	label.add_theme_font_size_override("font_size", 32)
	label.add_theme_color_override("font_color", Color.WHITE)
	label.set_anchors_preset(Control.PRESET_CENTER)
	test_scene.add_child(label)
	
	# Load and instance the fade transition
	var fade_scene = load("res://src/scenes/transitions/fade_transition.tscn")
	assert_not_null(fade_scene, "Fade transition scene should load")
	
	fade_transition = fade_scene.instantiate()
	assert_not_null(fade_transition, "Fade transition should instantiate")
	
	# Add to main scene tree (not as child of test scene)
	get_tree().root.add_child(fade_transition)
	
	# Wait for initialization
	await get_tree().process_frame
	await get_tree().process_frame

func after_each() -> void:
	if fade_transition and is_instance_valid(fade_transition):
		fade_transition.queue_free()
	print("=== Fade Visual Test Complete ===")

func test_fade_transition_visibility() -> void:
	watch_signals(fade_transition)
	
	print("TEST: Testing fade transition visibility with screenshots")
	
	# Take initial screenshot showing red background
	await get_tree().process_frame
	_take_test_screenshot("01_initial_red_background")
	
	# Test instant overlay show
	print("STEP 1: Testing instant black overlay")
	fade_transition.show_overlay()
	await get_tree().process_frame
	_take_test_screenshot("02_black_overlay_instant")
	
	# Verify the overlay is actually visible by checking modulate
	assert_eq(fade_transition.color_rect.modulate.a, 1.0, "ColorRect should be fully opaque")
	
	# Hide overlay to return to red
	print("STEP 2: Hiding overlay to show red again")
	fade_transition.hide_overlay()
	await get_tree().process_frame
	_take_test_screenshot("03_red_background_restored")
	
	# Test animated fade in
	print("STEP 3: Testing animated fade in with signals")
	fade_transition.set_fade_duration(1.0)  # 1 second for testing
	
	# Start fade in and capture at key moments
	fade_transition.fade_in()
	
	# Wait for transition started signal
	await wait_for_signal(fade_transition.transition_started, 2.0)
	assert_signal_emitted(fade_transition, "transition_started")
	_take_test_screenshot("04_fade_in_started")
	
	# Wait for halfway signal
	await wait_for_signal(fade_transition.transition_halfway, 2.0)
	assert_signal_emitted(fade_transition, "transition_halfway")
	_take_test_screenshot("05_fade_in_halfway")
	
	# Wait for completion
	await wait_for_signal(fade_transition.fade_in_completed, 2.0)
	assert_signal_emitted(fade_transition, "fade_in_completed")
	_take_test_screenshot("06_fade_in_complete")
	
	# Verify final state
	assert_eq(fade_transition.color_rect.modulate.a, 1.0, "ColorRect should be fully opaque after fade in")
	
	# Test fade out
	print("STEP 4: Testing animated fade out")
	fade_transition.fade_out()
	
	await wait_for_signal(fade_transition.fade_out_completed, 2.0)
	assert_signal_emitted(fade_transition, "fade_out_completed")
	_take_test_screenshot("07_fade_out_complete")
	
	# Verify final state
	assert_almost_eq(fade_transition.color_rect.modulate.a, 0.0, 0.01, "ColorRect should be fully transparent after fade out")
	
	print("TEST COMPLETE: All screenshots saved - check test_screenshots/ folder")

func test_complete_transition() -> void:
	watch_signals(fade_transition)
	
	print("TEST: Testing complete transition (fade in + fade out)")
	
	fade_transition.set_fade_duration(0.5)  # Faster for testing
	
	# Take screenshot before transition
	_take_test_screenshot("transition_01_before")
	
	# Start complete transition
	fade_transition.transition()
	
	# Wait for completion
	await wait_for_signal(fade_transition.transition_completed, 5.0)
	assert_signal_emitted(fade_transition, "transition_completed")
	
	# Take screenshot after transition
	_take_test_screenshot("transition_02_after")
	
	print("COMPLETE TRANSITION TEST FINISHED")

func _take_test_screenshot(suffix: String) -> void:
	screenshot_counter += 1
	var filename = "fade_test_%02d_%s.png" % [screenshot_counter, suffix]
	
	if fade_transition and fade_transition.has_method("take_screenshot"):
		var path = fade_transition.take_screenshot(filename)
		if path != "":
			print("Screenshot saved: ", path)
		else:
			print("ERROR: Screenshot failed for ", filename)
	else:
		print("ERROR: take_screenshot method not available on fade_transition")