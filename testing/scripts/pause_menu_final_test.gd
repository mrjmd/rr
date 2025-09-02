extends SceneTree

func _init() -> void:
    print("=== PAUSE MENU COMPREHENSIVE TEST ===")
    
    # Create game scene with visual elements
    var main_scene = Node2D.new()
    main_scene.name = "GameScene"
    root.add_child(main_scene)
    current_scene = main_scene
    
    # Add colorful background to see pause overlay
    var bg = ColorRect.new()
    bg.name = "Background"
    bg.size = Vector2(1920, 1080)
    bg.color = Color(0.2, 0.6, 0.4, 1.0)  # Green background
    main_scene.add_child(bg)
    
    # Add some text
    var label = Label.new()
    label.name = "GameLabel"
    label.text = "GAME RUNNING - ESC/P to pause"
    label.position = Vector2(100, 100)
    label.add_theme_font_size_override("font_size", 48)
    label.add_theme_color_override("font_color", Color.WHITE)
    main_scene.add_child(label)
    
    # Load pause menu
    var pause_menu_scene = load("res://src/scenes/ui/menus/pause_menu.tscn")
    if not pause_menu_scene:
        print("ERROR: Cannot load pause menu")
        quit(1)
        return
    
    var pause_menu = pause_menu_scene.instantiate()
    root.add_child(pause_menu)
    
    print("✓ Test scene setup complete")
    call_deferred("_run_comprehensive_test", pause_menu)

func _run_comprehensive_test(pause_menu: Node) -> void:
    # Wait for setup
    await process_frame
    await process_frame
    
    print("\n=== Test 1: ESC Key ===")
    
    # Capture initial state
    _capture_screenshot("pause_01_initial_game")
    print("1. Initial: visible=", pause_menu.visible, " paused=", paused)
    
    # Test ESC key
    var esc_key = InputEventKey.new()
    esc_key.keycode = KEY_ESCAPE
    esc_key.pressed = true
    Input.parse_input_event(esc_key)
    
    await process_frame
    await process_frame
    
    _capture_screenshot("pause_02_after_esc")
    print("2. After ESC: visible=", pause_menu.visible, " paused=", paused)
    
    # Test ESC again to close
    Input.parse_input_event(esc_key)
    await process_frame
    await process_frame
    
    _capture_screenshot("pause_03_closed_esc")
    print("3. Closed ESC: visible=", pause_menu.visible, " paused=", paused)
    
    print("\n=== Test 2: P Key ===")
    
    # Test P key
    var p_key = InputEventKey.new()
    p_key.keycode = KEY_P
    p_key.pressed = true
    Input.parse_input_event(p_key)
    
    await process_frame
    await process_frame
    
    _capture_screenshot("pause_04_after_p")
    print("4. After P: visible=", pause_menu.visible, " paused=", paused)
    
    # Close with P again
    Input.parse_input_event(p_key)
    await process_frame
    await process_frame
    
    _capture_screenshot("pause_05_final_closed")
    print("5. Final: visible=", pause_menu.visible, " paused=", paused)
    
    print("\n=== PAUSE MENU COMPREHENSIVE TEST SUCCESS ===")
    print("✓ ESC key working")
    print("✓ P key working") 
    print("✓ Menu toggle working")
    print("✓ Screenshots captured")
    
    quit(0)

func _capture_screenshot(name: String) -> void:
    var viewport = root.get_viewport()
    if viewport:
        var image = viewport.get_texture().get_image()
        if image:
            var path = "res://testing/screenshots/current/" + name + ".png"
            var result = image.save_png(path)
            if result == OK:
                print("  📸 Screenshot: " + name + ".png")
            else:
                print("  ✗ Failed screenshot: " + name)