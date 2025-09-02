extends Node2D
## Test settings menu functionality

func _ready():
	print("=== SETTINGS MENU TEST ===")
	
	# Create simple background
	var bg = ColorRect.new()
	bg.color = Color(0.4, 0.2, 0.6, 1.0)
	bg.size = Vector2(1920, 1080)
	add_child(bg)
	
	var label = Label.new()
	label.text = "SETTINGS MENU TEST"
	label.position = Vector2(100, 100)
	label.add_theme_font_size_override("font_size", 32)
	add_child(label)
	
	await get_tree().create_timer(1.0).timeout
	test_settings_menu()

func test_settings_menu():
	print("Testing settings menu loading...")
	
	# Try to load settings menu via MenuManager
	var menu_manager = get_node_or_null("/root/MenuManager")
	if menu_manager:
		print("MenuManager found")
		
		# Test opening settings menu
		print("Opening settings menu via MenuManager...")
		menu_manager.open_menu("settings_menu", false)
		
		await get_tree().process_frame
		await get_tree().process_frame
		
		# Check if it opened
		var current_menu = menu_manager.get_current_menu()
		print("Current menu after open: ", current_menu)
		
		capture_screenshot("settings_test_01_opened")
		
		# Try to get the settings menu instance
		var settings_instance = menu_manager.get_menu_instance("settings_menu")
		if settings_instance:
			print("Settings menu instance found: ", settings_instance)
			print("Settings menu visible: ", settings_instance.visible)
		else:
			print("ERROR: Settings menu instance not found")
			
		await get_tree().create_timer(2.0).timeout
		
		# Try to close
		menu_manager.close_current_menu(false)
		capture_screenshot("settings_test_02_closed")
	else:
		print("ERROR: MenuManager not found")
	
	await get_tree().create_timer(1.0).timeout
	print("=== SETTINGS MENU TEST COMPLETE ===")
	get_tree().quit()

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