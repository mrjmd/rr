extends SceneTree
## Visual verification test for menu navigation system

func _ready():
	print("=== Visual Menu Navigation Test ===")
	print("Starting visual verification test...")
	
	# Load the demo scene
	var demo_scene = load("res://src/scenes/demo/menu_navigation_demo.tscn")
	if not demo_scene:
		print("ERROR: Could not load menu navigation demo scene")
		quit(1)
		return
	
	var demo_instance = demo_scene.instantiate()
	root.add_child(demo_instance)
	
	# Wait for full initialization
	await process_frame
	await process_frame
	await process_frame
	
	if not root.has_node("/root/MenuManager"):
		print("ERROR: MenuManager not available")
		quit(1)
		return
	
	var menu_manager = root.get_node("/root/MenuManager")
	
	print("Running visual test sequence with screenshots...")
	
	# Test sequence with screenshots
	await _test_main_menu_flow(demo_instance)
	await _test_pause_menu_flow(demo_instance)
	await _test_settings_flow(demo_instance)
	
	print("Visual verification test completed successfully!")
	print("==================================")
	quit(0)

func _test_main_menu_flow(demo_instance) -> void:
	"""Test main menu flow with screenshots"""
	print("Testing main menu flow...")
	var menu_manager = root.get_node("/root/MenuManager")
	
	# Screenshot 1: Initial state
	_take_screenshot(demo_instance, "01_initial_state")
	
	# Open main menu
	menu_manager.open_menu("main_menu", true)
	await create_timer(1.0).timeout
	_take_screenshot(demo_instance, "02_main_menu_open")
	
	# Open settings from main menu
	menu_manager.open_menu("settings_menu", true)
	await create_timer(1.0).timeout
	_take_screenshot(demo_instance, "03_settings_from_main")
	
	# Go back to main
	menu_manager.go_back()
	await create_timer(1.0).timeout
	_take_screenshot(demo_instance, "04_back_to_main")
	
	# Close all
	menu_manager.close_all_menus(true)
	await create_timer(0.5).timeout

func _test_pause_menu_flow(demo_instance) -> void:
	"""Test pause menu flow with screenshots"""
	print("Testing pause menu flow...")
	var menu_manager = root.get_node("/root/MenuManager")
	
	# Open pause menu
	menu_manager.open_menu("pause_menu", true)
	await create_timer(1.0).timeout
	_take_screenshot(demo_instance, "05_pause_menu_open")
	
	# Open settings from pause
	menu_manager.open_menu("settings_menu", true)
	await create_timer(1.0).timeout
	_take_screenshot(demo_instance, "06_settings_from_pause")
	
	# Go back to pause
	menu_manager.go_back()
	await create_timer(1.0).timeout
	_take_screenshot(demo_instance, "07_back_to_pause")
	
	# Close all
	menu_manager.close_all_menus(true)
	await create_timer(0.5).timeout

func _test_settings_flow(demo_instance) -> void:
	"""Test direct settings access"""
	print("Testing direct settings access...")
	var menu_manager = root.get_node("/root/MenuManager")
	
	# Direct settings open
	menu_manager.open_menu("settings_menu", true)
	await create_timer(1.0).timeout
	_take_screenshot(demo_instance, "08_direct_settings")
	
	# Close settings
	menu_manager.close_all_menus(true)
	await create_timer(1.0).timeout
	_take_screenshot(demo_instance, "09_final_state")

func _take_screenshot(demo_instance, name: String) -> void:
	"""Take a screenshot using the demo instance"""
	if demo_instance and demo_instance.has_method("take_screenshot"):
		var result = demo_instance.take_screenshot("menu_nav_" + name)
		if not result.is_empty():
			print("📸 Screenshot saved: ", result)
		else:
			print("⚠️ Screenshot failed for: ", name)
	else:
		print("⚠️ Cannot take screenshot - method not available")