extends Node2D
## Test pause menu functionality in a simple game scene

@onready var pause_menu: Node = null
var test_phase: int = 0

func _ready():
	print("=== PAUSE MENU DIAGNOSTIC TEST ===")
	
	# Create a simple background
	var bg = ColorRect.new()
	bg.color = Color(0.2, 0.4, 0.6, 1.0)
	bg.size = Vector2(1920, 1080)
	add_child(bg)
	
	# Add simple test content
	var label = Label.new()
	label.text = "PAUSE MENU TEST SCENE\nPress ESC or P to test pause menu"
	label.position = Vector2(100, 100)
	label.add_theme_font_size_override("font_size", 24)
	add_child(label)
	
	# Load pause menu scene
	await get_tree().process_frame
	load_pause_menu()
	
	# Start testing sequence
	start_testing_sequence()

func load_pause_menu():
	print("Loading pause menu...")
	var pause_menu_scene = load("res://src/scenes/ui/menus/pause_menu_simple.tscn")
	if pause_menu_scene:
		pause_menu = pause_menu_scene.instantiate()
		get_tree().root.add_child(pause_menu)
		print("Pause menu loaded and added to scene")
	else:
		print("ERROR: Could not load pause menu scene")

func start_testing_sequence():
	print("Starting pause menu test sequence...")
	
	# Phase 1: Initial state
	await get_tree().create_timer(1.0).timeout
	capture_screenshot("pause_test_01_initial")
	test_phase = 1
	
	# Phase 2: Simulate ESC press
	await get_tree().create_timer(1.0).timeout
	print("Simulating ESC key press...")
	var input_event = InputEventKey.new()
	input_event.keycode = KEY_ESCAPE
	input_event.pressed = true
	Input.parse_input_event(input_event)
	
	await get_tree().process_frame
	await get_tree().process_frame
	capture_screenshot("pause_test_02_esc_pressed")
	test_phase = 2
	
	# Phase 3: Check if pause menu appeared
	await get_tree().create_timer(1.0).timeout
	check_pause_menu_state()
	capture_screenshot("pause_test_03_final_state")
	
	# Exit
	await get_tree().create_timer(1.0).timeout
	print("=== PAUSE MENU TEST COMPLETE ===")
	get_tree().quit()

func check_pause_menu_state():
	print("--- Checking Pause Menu State ---")
	if pause_menu:
		print("Pause menu exists: ", pause_menu)
		print("Pause menu visible: ", pause_menu.visible)
		if pause_menu.has_method("is_open"):
			print("Pause menu is_open(): ", pause_menu.is_open())
	else:
		print("ERROR: Pause menu not found")
	
	print("Game paused state: ", get_tree().paused)

func capture_screenshot(filename: String):
	var viewport = get_viewport()
	if viewport:
		var image = viewport.get_texture().get_image()
		if image:
			var save_path = "testing/screenshots/current/" + filename + ".png"
			var result = image.save_png(save_path)
			if result == OK:
				print("Screenshot saved: " + save_path)
			else:
				print("Failed to save screenshot: " + str(result))

func _input(event: InputEvent):
	if event is InputEventKey:
		print("Key event received: ", event.keycode, " pressed: ", event.pressed)
		if event.keycode == KEY_ESCAPE and event.pressed:
			print("ESC key detected in test scene")