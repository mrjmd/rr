extends SceneTree

# Manual Integration Test for Menu System
# Captures screenshots and tests workflows step by step

func _initialize():
	print("=== MANUAL INTEGRATION TEST SUITE ===")
	print("Testing all menu workflows with visual proof")
	
	# Test 1: Main Menu Direct Load
	print("\n1. Testing Main Menu Direct Load...")
	await test_main_menu_direct()
	
	# Test 2: Settings Menu Load
	print("\n2. Testing Settings Menu Load...")  
	await test_settings_menu()
	
	# Test 3: Game Scene with Pause
	print("\n3. Testing Game Scene with Pause Menu...")
	await test_game_pause_workflow()
	
	print("\n=== INTEGRATION TEST COMPLETE ===")
	quit()

func test_main_menu_direct():
	# Clear any existing scene
	var current = get_root().get_child(0)
	if current:
		current.queue_free()
		await process_frame
	
	# Load main menu
	var main_scene = load("res://src/scenes/ui/menus/main_menu_simple.tscn")
	var main_menu = main_scene.instantiate()
	get_root().add_child(main_menu)
	
	# Wait for full initialization
	await process_frame
	await process_frame
	await process_frame
	
	# Manual screenshot command output
	print("✓ Main menu loaded - Take screenshot: integration_01_main_menu_loaded")
	await create_timed_delay(2.0)

func test_settings_menu():
	# Check if settings scene exists first
	if not ResourceLoader.exists("res://src/scenes/ui/menus/settings_menu_simple.tscn"):
		print("⚠ Settings menu scene not found - skipping test")
		return
	
	# Clear and load settings menu
	var current = get_root().get_child(0)
	if current:
		current.queue_free()
		await process_frame
	
	var settings_scene = load("res://src/scenes/ui/menus/settings_menu_simple.tscn")
	var settings_menu = settings_scene.instantiate()
	get_root().add_child(settings_menu)
	
	await process_frame
	await process_frame
	await process_frame
	
	print("✓ Settings menu loaded - Take screenshot: integration_02_settings_menu")
	await create_timed_delay(2.0)

func test_game_pause_workflow():
	# Load a simple test scene or the main game scene
	var current = get_root().get_child(0)
	if current:
		current.queue_free()
		await process_frame
	
	# Check if we have a test scene first
	var test_scene_path = "res://src/scenes/testing/integration_test_scene.tscn"
	
	if not ResourceLoader.exists(test_scene_path):
		# Create a minimal test scene
		print("Creating minimal test scene for pause testing...")
		await create_minimal_test_scene()
	
	print("✓ Test scene ready - Take screenshot: integration_03_test_scene")
	await create_timed_delay(2.0)
	
	# Simulate pause input
	var input_event = InputEventKey.new()
	input_event.keycode = KEY_ESCAPE
	input_event.pressed = true
	
	print("Sending ESC key to trigger pause...")
	get_root().get_viewport().push_input(input_event)
	
	await process_frame
	await process_frame
	
	print("✓ Pause menu should be active - Take screenshot: integration_04_pause_menu_active")
	await create_timed_delay(2.0)

func create_minimal_test_scene():
	# Create a minimal scene for testing
	var root_node = Node2D.new()
	root_node.name = "TestScene"
	
	# Add a colored background
	var color_rect = ColorRect.new()
	color_rect.color = Color.CYAN
	color_rect.size = Vector2(1152, 648)
	root_node.add_child(color_rect)
	
	# Add pause menu functionality
	var pause_scene = load("res://src/scenes/ui/menus/pause_menu_simple.tscn")
	if pause_scene:
		var pause_menu = pause_scene.instantiate()
		root_node.add_child(pause_menu)
	
	get_root().add_child(root_node)

func create_timed_delay(seconds: float):
	var timer = Timer.new()
	timer.wait_time = seconds
	timer.one_shot = true
	get_root().add_child(timer)
	timer.start()
	await timer.timeout
	timer.queue_free()