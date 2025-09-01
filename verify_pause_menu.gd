extends SceneTree
## Simple pause menu verification script

func _init() -> void:
	print("=== Pause Menu Verification ===")
	
	# Load the standalone scene
	var scene = load("res://src/scenes/testing/pause_menu_standalone.tscn").instantiate()
	current_scene = scene
	
	# Wait for initialization
	await process_frame
	await create_timer(1.0).timeout
	
	print("Scene loaded, checking components...")
	
	# Check if EventBus is available
	var eventbus_available = root.has_node("/root/EventBus")
	print("EventBus available: ", eventbus_available)
	
	# Get the pause menu
	var pause_menu = scene.get_node("PauseMenu")
	if pause_menu:
		print("Pause menu found: ", pause_menu.get_class())
		print("Initial visibility: ", pause_menu.visible)
		print("Initial open state: ", pause_menu.is_open() if pause_menu.has_method("is_open") else "unknown")
	else:
		print("ERROR: Pause menu not found!")
		quit(1)
		return
	
	# Test opening the menu
	print("Opening pause menu...")
	pause_menu.show_menu()
	await process_frame
	
	print("After opening:")
	print("  Visible: ", pause_menu.visible)
	print("  Open: ", pause_menu.is_open() if pause_menu.has_method("is_open") else "unknown")
	print("  Tree paused: ", paused)
	
	# Take screenshot
	var viewport = get_root()
	var image = viewport.get_texture().get_image()
	var filename = "res://testing/screenshots/current/pause_menu_verification.png"
	image.save_png(filename)
	print("Screenshot saved: ", filename)
	
	# Test closing
	print("Closing pause menu...")
	pause_menu.hide_menu()
	await process_frame
	
	print("After closing:")
	print("  Visible: ", pause_menu.visible)
	print("  Open: ", pause_menu.is_open() if pause_menu.has_method("is_open") else "unknown")
	print("  Tree paused: ", paused)
	
	print("=== Verification Complete ===")
	quit()