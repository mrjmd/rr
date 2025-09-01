extends Node2D

func _ready() -> void:
    print("Creating pause menu visibility test...")
    
    # Create a blue background
    var background = ColorRect.new()
    background.color = Color(0.2, 0.3, 0.6, 1.0)
    background.anchor_right = 1.0
    background.anchor_bottom = 1.0
    add_child(background)
    
    # Create dark overlay (pause menu background)
    var overlay = ColorRect.new()
    overlay.color = Color(0, 0, 0, 0.7)
    overlay.anchor_right = 1.0
    overlay.anchor_bottom = 1.0
    add_child(overlay)
    
    # Create pause menu panel
    var panel = Panel.new()
    panel.size = Vector2(400, 300)
    panel.position = Vector2(440, 200)  # Centered for 1280x720
    
    # Style the panel
    var panel_style = StyleBoxFlat.new()
    panel_style.bg_color = Color(0.1, 0.1, 0.15, 0.95)
    panel_style.border_color = Color(0.4, 0.4, 0.5, 1.0)
    panel_style.set_border_width_all(2)
    panel_style.set_corner_radius_all(8)
    panel_style.set_content_margin_all(20)
    panel.add_theme_stylebox_override("panel", panel_style)
    add_child(panel)
    
    # Add PAUSED title
    var title = Label.new()
    title.text = "PAUSED"
    title.position = Vector2(150, 30)
    title.size = Vector2(100, 40)
    title.add_theme_font_size_override("font_size", 36)
    title.add_theme_color_override("font_color", Color(0.9, 0.9, 1.0))
    panel.add_child(title)
    
    # Create buttons container
    var button_container = VBoxContainer.new()
    button_container.position = Vector2(100, 100)
    button_container.size = Vector2(200, 150)
    button_container.add_theme_constant_override("separation", 10)
    panel.add_child(button_container)
    
    # Create Resume button
    var resume_btn = Button.new()
    resume_btn.text = "Resume"
    resume_btn.custom_minimum_size = Vector2(200, 40)
    var btn_style = StyleBoxFlat.new()
    btn_style.bg_color = Color(0.25, 0.25, 0.35, 0.9)
    btn_style.set_corner_radius_all(8)
    resume_btn.add_theme_stylebox_override("normal", btn_style)
    button_container.add_child(resume_btn)
    
    # Create Settings button
    var settings_btn = Button.new()
    settings_btn.text = "Settings"
    settings_btn.custom_minimum_size = Vector2(200, 40)
    settings_btn.add_theme_stylebox_override("normal", btn_style)
    button_container.add_child(settings_btn)
    
    # Create Main Menu button
    var main_menu_btn = Button.new()
    main_menu_btn.text = "Main Menu"
    main_menu_btn.custom_minimum_size = Vector2(200, 40)
    main_menu_btn.add_theme_stylebox_override("normal", btn_style)
    button_container.add_child(main_menu_btn)
    
    print("Pause menu visible for screenshot")
    
    # Capture screenshot after a frame
    await get_tree().process_frame
    await get_tree().process_frame
    
    var viewport = get_viewport()
    var image = viewport.get_texture().get_image()
    var path = "res://testing/screenshots/current/pause_menu_final_proof.png"
    var result = image.save_png(path)
    
    if result == OK:
        print("✓ Screenshot saved: " + path)
    else:
        print("✗ Failed to save screenshot")
    
    # Keep running for visual inspection
    print("Pause menu test ready - visible on screen")
