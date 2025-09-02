extends SceneTree
## Test script for menu navigation system

func _ready():
	print("=== Menu Navigation System Test ===")
	print("Loading menu navigation demo...")
	
	# Load the demo scene
	var demo_scene = load("res://src/scenes/demo/menu_navigation_demo.tscn")
	if not demo_scene:
		print("ERROR: Could not load menu navigation demo scene")
		quit(1)
		return
	
	var demo_instance = demo_scene.instantiate()
	root.add_child(demo_instance)
	
	# Wait for initialization
	await process_frame
	await process_frame
	
	# Check MenuManager availability
	if not root.has_node("/root/MenuManager"):
		print("ERROR: MenuManager not available as singleton")
		quit(1)
		return
	
	var menu_manager = root.get_node("/root/MenuManager")
	print("✅ MenuManager found and accessible")
	
	# Test basic functionality
	print("\n--- Testing Basic Menu Operations ---")
	
	# Test 1: Open main menu
	print("1. Opening main menu...")
	menu_manager.open_menu("main_menu", false)  # No transitions for testing
	await process_frame
	
	var current_menu = menu_manager.get_current_menu()
	if current_menu == "main_menu":
		print("✅ Main menu opened successfully")
	else:
		print("❌ Main menu failed to open. Current:", current_menu)
		quit(1)
		return
	
	# Test 2: Open settings menu (building stack)
	print("2. Opening settings menu...")
	menu_manager.open_menu("settings_menu", false)
	await process_frame
	
	current_menu = menu_manager.get_current_menu()
	var stack = menu_manager.get_menu_stack()
	if current_menu == "settings_menu" and stack.size() == 2:
		print("✅ Settings menu opened, stack size:", stack.size())
	else:
		print("❌ Settings menu failed. Current:", current_menu, "Stack:", stack)
		quit(1)
		return
	
	# Test 3: Go back
	print("3. Going back...")
	menu_manager.go_back()
	await process_frame
	
	current_menu = menu_manager.get_current_menu()
	stack = menu_manager.get_menu_stack()
	if current_menu == "main_menu" and stack.size() == 1:
		print("✅ Go back worked. Current:", current_menu, "Stack size:", stack.size())
	else:
		print("❌ Go back failed. Current:", current_menu, "Stack:", stack)
		quit(1)
		return
	
	# Test 4: Close all menus
	print("4. Closing all menus...")
	menu_manager.close_all_menus(false)
	await process_frame
	
	current_menu = menu_manager.get_current_menu()
	stack = menu_manager.get_menu_stack()
	if current_menu.is_empty() and stack.size() == 0:
		print("✅ Close all worked. Stack cleared.")
	else:
		print("❌ Close all failed. Current:", current_menu, "Stack:", stack)
		quit(1)
		return
	
	# Test 5: Test transitions
	print("5. Testing transitions...")
	menu_manager.open_menu("main_menu", true)  # With transition
	await create_timer(0.5).timeout  # Wait for transition
	
	current_menu = menu_manager.get_current_menu()
	if current_menu == "main_menu":
		print("✅ Transition test passed")
	else:
		print("❌ Transition test failed. Current:", current_menu)
	
	# Clean up
	menu_manager.close_all_menus(false)
	await process_frame
	
	# Print final state
	print("\n--- Final State ---")
	menu_manager.debug_print_state()
	
	print("\n🎉 All menu navigation tests PASSED!")
	print("===================================")
	quit(0)