extends SceneTree

func _init() -> void:
    print("Loading main menu for testing...")
    
    # Load and instantiate the main menu scene
    var menu_scene = load("res://src/scenes/ui/menus/main_menu_simple.tscn")
    if not menu_scene:
        print("ERROR: Could not load main menu scene")
        quit()
        return
    
    var menu = menu_scene.instantiate()
    root.add_child(menu)
    
    print("Main menu loaded, waiting for render...")
    
    # Wait for scene to render
    await root.get_tree().process_frame
    await root.get_tree().process_frame
    
    # Capture screenshot
    var viewport = root.get_viewport()
    var image = viewport.get_texture().get_image()
    
    var timestamp = Time.get_datetime_string_from_system().replace(":", "-").replace("T", "_")
    var path = "res://testing/screenshots/current/main_menu_test_" + timestamp + ".png"
    
    var result = image.save_png(path)
    if result == OK:
        print("✓ Screenshot saved: " + path)
        
        # Also save as LATEST
        image.save_png("res://testing/screenshots/current/LATEST_MAIN_MENU.png")
        print("✓ Also saved as LATEST_MAIN_MENU.png")
    else:
        print("✗ Failed to save screenshot")
    
    print("Test complete")
    quit()
