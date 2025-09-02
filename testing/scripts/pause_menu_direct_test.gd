extends Node2D
## Direct pause menu method testing

@onready var pause_menu: Node = null

func _ready():
	print("=== DIRECT PAUSE MENU TEST ===")
	
	# Create simple background
	var bg = ColorRect.new()
	bg.color = Color(0.3, 0.5, 0.7, 1.0)
	bg.size = Vector2(1920, 1080)
	add_child(bg)
	
	var label = Label.new()
	label.text = "DIRECT PAUSE MENU TEST"
	label.position = Vector2(100, 100)
	label.add_theme_font_size_override("font_size", 32)
	add_child(label)
	
	# Load pause menu
	await get_tree().process_frame
	load_pause_menu()
	start_direct_test()

func load_pause_menu():
	print("Loading pause menu...")
	var pause_menu_scene = load("res://src/scenes/ui/menus/pause_menu.tscn")
	if pause_menu_scene:
		pause_menu = pause_menu_scene.instantiate()
		get_tree().root.add_child(pause_menu)
		print("Pause menu loaded")
		print("Pause menu type: ", pause_menu.get_class())
		print("Pause menu script: ", pause_menu.get_script())
	else:
		print("ERROR: Could not load pause menu")

func start_direct_test():
	await get_tree().create_timer(1.0).timeout
	capture_screenshot("direct_test_01_before")
	
	print("--- Direct Method Test ---")
	if pause_menu:
		if pause_menu.has_method("show_menu"):
			print("Calling show_menu() directly...")
			pause_menu.show_menu()
			
			await get_tree().process_frame
			await get_tree().process_frame
			
			print("After show_menu():")
			print("  visible: ", pause_menu.visible)
			print("  is_open(): ", pause_menu.is_open() if pause_menu.has_method("is_open") else "N/A")
			print("  game paused: ", get_tree().paused)
			
			capture_screenshot("direct_test_02_show_called")
			
			await get_tree().create_timer(2.0).timeout
			
			if pause_menu.has_method("hide_menu"):
				print("Calling hide_menu()...")
				pause_menu.hide_menu()
				
				await get_tree().process_frame
				capture_screenshot("direct_test_03_hide_called")
		else:
			print("ERROR: show_menu method not found")
	
	await get_tree().create_timer(1.0).timeout
	print("=== DIRECT TEST COMPLETE ===")
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