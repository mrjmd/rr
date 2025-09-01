extends Control
## Direct test scene to verify fade transition visibility

@onready var fade_transition: FadeTransition
var test_step: int = 0

func _ready() -> void:
	print("=== FADE DIRECT TEST STARTING ===")
	
	# Set bright background color for maximum contrast
	var bg = ColorRect.new()
	bg.color = Color(0.0, 1.0, 0.0, 1.0)  # Bright green background
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	move_child(bg, 0)
	
	# Add large visible label
	var label = Label.new()
	label.text = "BRIGHT GREEN BACKGROUND - PRESS SPACE TO TEST FADE"
	label.add_theme_font_size_override("font_size", 24)
	label.add_theme_color_override("font_color", Color.BLACK)
	label.set_anchors_preset(Control.PRESET_CENTER)
	add_child(label)
	
	print("Creating fade transition...")
	
	# Load and instantiate the fade transition
	var fade_scene = load("res://src/scenes/transitions/fade_transition.tscn")
	if not fade_scene:
		print("ERROR: Could not load fade transition scene!")
		return
		
	fade_transition = fade_scene.instantiate()
	if not fade_transition:
		print("ERROR: Could not instantiate fade transition!")
		return
	
	print("Adding fade transition to scene tree...")
	get_tree().root.add_child.call_deferred(fade_transition)
	
	# Connect signals for testing
	if fade_transition.has_signal("transition_started"):
		fade_transition.transition_started.connect(_on_transition_started)
	if fade_transition.has_signal("transition_halfway"):
		fade_transition.transition_halfway.connect(_on_transition_halfway)
	if fade_transition.has_signal("fade_in_completed"):
		fade_transition.fade_in_completed.connect(_on_fade_in_completed)
	if fade_transition.has_signal("fade_out_completed"):
		fade_transition.fade_out_completed.connect(_on_fade_out_completed)
	
	# Wait for initialization (longer wait for deferred call)
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().create_timer(0.1).timeout
	
	print("=== FADE TEST READY - PRESS SPACE TO START ===")
	print("ColorRect found:", fade_transition.color_rect != null)
	if fade_transition.color_rect:
		print("ColorRect layer:", fade_transition.layer)
		print("ColorRect z_index:", fade_transition.color_rect.z_index)
		print("ColorRect color:", fade_transition.color_rect.color)
		print("ColorRect modulate:", fade_transition.color_rect.modulate)
		print("ColorRect visible:", fade_transition.color_rect.visible)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):  # Space key
		_run_test_sequence()

func _run_test_sequence() -> void:
	if not fade_transition:
		print("ERROR: No fade transition available!")
		return
	
	match test_step:
		0:
			print("TEST STEP 0: Showing instant black overlay")
			fade_transition.show_overlay()
			_take_screenshot("direct_test_01_black_overlay")
		1:
			print("TEST STEP 1: Hiding overlay")
			fade_transition.hide_overlay()
			_take_screenshot("direct_test_02_green_restored")
		2:
			print("TEST STEP 2: Starting fade in animation")
			fade_transition.set_fade_duration(2.0)  # Slow fade for visibility
			fade_transition.fade_in()
		3:
			print("TEST STEP 3: Starting fade out animation")
			fade_transition.fade_out()
		4:
			print("TEST STEP 4: Complete transition test")
			fade_transition.transition()
		_:
			print("All tests complete!")
			test_step = -1
			return
	
	test_step += 1

func _take_screenshot(filename: String) -> void:
	if fade_transition and fade_transition.has_method("take_screenshot"):
		fade_transition.take_screenshot(filename)
	else:
		# Fallback screenshot method
		var viewport = get_viewport()
		var image = viewport.get_texture().get_image()
		var dir = DirAccess.open("user://")
		if not dir.dir_exists("test_screenshots"):
			dir.make_dir("test_screenshots")
		image.save_png("user://test_screenshots/" + filename + ".png")
		print("Screenshot saved (fallback method): ", filename)

# Signal callbacks
func _on_transition_started() -> void:
	print("SIGNAL: Transition started")
	_take_screenshot("direct_test_transition_started")

func _on_transition_halfway() -> void:
	print("SIGNAL: Transition halfway")
	_take_screenshot("direct_test_transition_halfway")

func _on_fade_in_completed() -> void:
	print("SIGNAL: Fade in completed")
	_take_screenshot("direct_test_fade_in_complete")

func _on_fade_out_completed() -> void:
	print("SIGNAL: Fade out completed")
	_take_screenshot("direct_test_fade_out_complete")