extends Node
## Diagnostic script for menu testing

var screenshots_taken: int = 0
var max_screenshots: int = 3

func _ready():
	print("=== MENU DIAGNOSTIC STARTED ===")
	print("Main menu scene loaded")
	
	# Wait for systems to initialize
	await get_tree().process_frame
	await get_tree().process_frame
	
	# Take initial screenshot
	capture_screenshot("menu_diagnostic_01_loaded")
	
	# Check if main menu is visible
	check_menu_visibility()
	
	# Try to interact with the menu after a delay
	await get_tree().create_timer(1.0).timeout
	test_menu_interaction()
	
	# Wait and exit
	await get_tree().create_timer(2.0).timeout
	print("=== DIAGNOSTIC COMPLETE ===")
	get_tree().quit()

func check_menu_visibility():
	print("--- Menu Visibility Check ---")
	var main_menu = get_tree().get_first_node_in_group("main_menu")
	if not main_menu:
		main_menu = get_node_or_null("/root/MainMenuSimple")
	
	if main_menu:
		print("Main menu found: ", main_menu)
		print("Main menu visible: ", main_menu.visible)
		if main_menu is CanvasLayer:
			print("Main menu layer: ", main_menu.layer)
	else:
		print("ERROR: Main menu not found!")
	
	# Check MenuManager state
	var menu_manager = get_node_or_null("/root/MenuManager")
	if menu_manager:
		print("MenuManager found - current menu: ", menu_manager.get_current_menu())
		print("MenuManager debug info: ", menu_manager.get_debug_info())
	else:
		print("ERROR: MenuManager not found!")

func test_menu_interaction():
	print("--- Testing Menu Interaction ---")
	
	# Try to find start button
	var start_button = get_tree().get_first_node_in_group("start_button")
	if not start_button:
		var main_menu = get_node_or_null("/root/MainMenuSimple")
		if main_menu:
			start_button = main_menu.get_node_or_null("MenuContainer/MainPanel/VBoxContainer/ButtonContainer/StartButton")
	
	if start_button:
		print("Start button found: ", start_button)
		print("Start button visible: ", start_button.visible)
		capture_screenshot("menu_diagnostic_02_button_found")
		
		# Try to press the button
		print("Simulating button press...")
		start_button.pressed.emit()
		
		await get_tree().process_frame
		capture_screenshot("menu_diagnostic_03_button_pressed")
	else:
		print("ERROR: Start button not found!")

func capture_screenshot(filename: String):
	if screenshots_taken >= max_screenshots:
		return
		
	var viewport = get_viewport()
	if not viewport:
		print("ERROR: Could not get viewport")
		return
	
	var image = viewport.get_texture().get_image()
	if not image:
		print("ERROR: Could not get image from viewport")
		return
	
	var save_path = "testing/screenshots/current/" + filename + ".png"
	var result = image.save_png(save_path)
	
	if result == OK:
		print("Screenshot saved: " + save_path)
		screenshots_taken += 1
	else:
		print("ERROR: Failed to save screenshot: " + str(result))