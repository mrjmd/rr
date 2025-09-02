extends SceneTree

func _init() -> void:
    print("=== PAUSE MENU INPUT DEBUG TEST ===")
    
    # Create main scene
    var main = Node2D.new()
    main.name = "Main"
    root.add_child(main)
    current_scene = main
    
    # Create pause menu
    var pause_menu_scene = load("res://src/scenes/ui/menus/pause_menu.tscn")
    if not pause_menu_scene:
        print("ERROR: Cannot load pause menu")
        quit(1)
        return
    
    var pause_menu = pause_menu_scene.instantiate()
    root.add_child(pause_menu)
    
    print("✓ Pause menu loaded")
    
    # Don't add debug input listener - it may consume input
    print("Skipping debug helper to avoid input consumption")
    
    call_deferred("_run_test", pause_menu)

func _run_test(pause_menu: Node) -> void:
    # Wait for setup
    await process_frame
    await process_frame
    
    print("\n--- Testing Input Actions ---")
    
    # Test if pause_menu action exists
    var actions = InputMap.get_actions()
    if "pause_menu" in actions:
        print("✓ 'pause_menu' action exists")
        var events = InputMap.action_get_events("pause_menu")
        print("  Events: ", events)
    else:
        print("✗ 'pause_menu' action NOT found")
        print("Available actions: ", actions)
    
    print("\nTesting direct ESC key...")
    var esc_key = InputEventKey.new()
    esc_key.keycode = KEY_ESCAPE
    esc_key.pressed = true
    
    # Try different ways to send input
    print("Sending input event...")
    Input.parse_input_event(esc_key)
    
    await process_frame
    await process_frame
    
    print("Final pause menu state:")
    print("- visible: ", pause_menu.visible)
    print("- is_open: ", pause_menu.is_open() if pause_menu.has_method("is_open") else "N/A")
    
    quit(0)