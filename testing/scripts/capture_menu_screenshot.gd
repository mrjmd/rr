extends Node

func _ready() -> void:
    print("Starting menu screenshot capture...")
    
    # Wait a frame for scene to fully render
    await get_tree().process_frame
    await get_tree().process_frame
    
    # Get the viewport
    var viewport = get_viewport()
    
    # Capture the viewport
    var image = viewport.get_texture().get_image()
    
    # Save the screenshot
    var timestamp = Time.get_datetime_string_from_system().replace(":", "-").replace("T", "_")
    var path = "res://testing/screenshots/current/main_menu_" + timestamp + ".png"
    var result = image.save_png(path)
    
    if result == OK:
        print("Screenshot saved to: " + path)
        
        # Also save as latest
        var latest_path = "res://testing/screenshots/current/LATEST_MAIN_MENU.png"
        result = image.save_png(latest_path)
        if result == OK:
            print("Also saved as: " + latest_path)
    else:
        print("Failed to save screenshot: " + str(result))
    
    # Quit after capture
    get_tree().quit()
