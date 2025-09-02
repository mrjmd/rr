extends SceneTree

func _init() -> void:
    print("=== MAIN MENU STANDALONE TEST ===")
    
    # Load the main menu scene
    var menu_scene = load("res://src/scenes/ui/menus/main_menu_simple.tscn")
    if not menu_scene:
        print("ERROR: Could not load main menu scene")
        quit(1)
        return
    
    var menu = menu_scene.instantiate()
    if not menu:
        print("ERROR: Could not instantiate main menu")
        quit(1)
        return
    
    root.add_child(menu)
    print("✓ Main menu scene loaded and added to tree")
    
    # Give it time to initialize
    call_deferred("_capture_screenshot")

func _capture_screenshot() -> void:
    print("Capturing screenshot...")
    
    # Wait for a few frames to ensure everything is rendered
    for i in range(3):
        await root.get_tree().process_frame
    
    # Get the viewport and capture screenshot
    var viewport = root.get_viewport()
    if not viewport:
        print("ERROR: No viewport found")
        quit(1)
        return
    
    var texture = viewport.get_texture()
    if not texture:
        print("ERROR: No texture from viewport")
        quit(1)
        return
    
    var image = texture.get_image()
    if not image:
        print("ERROR: No image from texture")
        quit(1)
        return
    
    # Save screenshot
    var timestamp = Time.get_datetime_string_from_system().replace(":", "-").replace("T", "_")
    var filename = "main_menu_fixed_" + timestamp + ".png"
    var path = "res://testing/screenshots/current/" + filename
    
    var result = image.save_png(path)
    if result == OK:
        print("✓ Screenshot saved: " + path)
        
        # Also save as LATEST for easy access
        image.save_png("res://testing/screenshots/current/LATEST_MAIN_MENU_FIXED.png")
        print("✓ Also saved as LATEST_MAIN_MENU_FIXED.png")
        
        print("=== MAIN MENU TEST SUCCESS ===")
        print("Menu should be visible in screenshot!")
    else:
        print("✗ Failed to save screenshot: " + str(result))
    
    quit(0)