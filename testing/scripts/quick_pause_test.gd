extends SceneTree

func _init() -> void:
    print("=== QUICK PAUSE MENU ESC TEST ===")
    
    # Create a simple scene
    var main_scene = Node2D.new()
    main_scene.name = "TestScene"
    root.add_child(main_scene)
    
    # Add pause menu
    var pause_menu_scene = load("res://src/scenes/ui/menus/pause_menu.tscn")
    if not pause_menu_scene:
        print("ERROR: Could not load pause menu scene")
        quit(1)
        return
    
    var pause_menu = pause_menu_scene.instantiate()
    root.add_child(pause_menu)
    print("✓ Pause menu loaded")
    
    # Test sequence
    call_deferred("_test_esc_key", pause_menu)

func _test_esc_key(pause_menu: Node) -> void:
    print("Testing ESC key functionality...")
    
    # Wait for initialization
    for i in range(3):
        await process_frame
    
    print("Initial state:")
    print("- Pause menu visible: ", pause_menu.visible)
    print("- Game paused: ", paused)
    
    if pause_menu.has_method("is_open"):
        print("- Menu is_open(): ", pause_menu.is_open())
    
    # Test ESC key press
    print("\n--- Testing ESC key ---")
    var esc_event = InputEventKey.new()
    esc_event.keycode = KEY_ESCAPE
    esc_event.pressed = true
    
    # Send the input event
    Input.parse_input_event(esc_event)
    
    # Wait for processing
    await process_frame
    await process_frame
    
    print("After ESC press:")
    print("- Pause menu visible: ", pause_menu.visible)
    print("- Game paused: ", paused)
    
    if pause_menu.has_method("is_open"):
        print("- Menu is_open(): ", pause_menu.is_open())
    
    # Test release
    esc_event.pressed = false
    Input.parse_input_event(esc_event)
    
    await process_frame
    
    # Test P key as well
    print("\n--- Testing P key ---")
    var p_event = InputEventKey.new()
    p_event.keycode = KEY_P
    p_event.pressed = true
    
    Input.parse_input_event(p_event)
    
    await process_frame
    await process_frame
    
    print("After P press:")
    print("- Pause menu visible: ", pause_menu.visible)
    print("- Game paused: ", paused)
    
    if pause_menu.has_method("is_open"):
        print("- Menu is_open(): ", pause_menu.is_open())
    
    print("\n=== PAUSE MENU ESC TEST COMPLETE ===")
    quit(0)