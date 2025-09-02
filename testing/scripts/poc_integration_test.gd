extends Node

var test_step = 0
var error_occurred = false

func _ready():
    # This is crucial to prevent the script from pausing when the pause menu is shown.
    process_mode = Node.PROCESS_MODE_ALWAYS
    print("--- STARTING POC INTEGRATION TEST (v3) ---")
    # The launcher script has already loaded the main menu, so we wait a moment and then start the test steps.
    await get_tree().create_timer(1.0).timeout
    run_test()

func run_test():
    var main_menu = get_tree().get_root().get_child(get_tree().get_root().get_child_count() - 1)
    if main_menu.get_name() != "MainMenuSimple":
        return fail_test("Main Menu was not the active scene.")
    
    print_step("Main Menu active. Taking screenshot...")
    ScreenshotManager.take_screenshot("01_main_menu_loaded.png", ScreenshotManager.Category.AUTOMATED, "poc_integration")

    # Step 2: Click Start Game
    print_step("Simulating 'Start Game' button press...")
    var start_button = main_menu.get_node("MenuContainer/MainPanel/VBoxContainer/ButtonContainer/StartButton")
    if !start_button:
        return fail_test("Could not find 'Start Game' button.")
    
    start_button.emit_signal("pressed")
    print("  ... awaiting process frame.")
    await get_tree().process_frame
    print("  ... awaiting timer.")
    await get_tree().create_timer(1.0).timeout

    # Step 3: Verify Kitchen Scene
    var current_scene = get_tree().get_root().get_child(get_tree().get_root().get_child_count() - 1)
    if "kitchen" not in current_scene.get_scene_file_path().to_lower():
         return fail_test("Scene did not change to Kitchen. Current scene: " + current_scene.get_scene_file_path())
    
    var player = current_scene.get_node_or_null("Player")
    if !player:
        return fail_test("Player node not found in the kitchen scene.")
        
    print_step("Kitchen scene loaded. Taking screenshot...")
    ScreenshotManager.take_screenshot("02_kitchen_loaded.png", ScreenshotManager.Category.AUTOMATED, "poc_integration")

    # Step 4: Test Movement
    print_step("Simulating player movement (W key)...")
    var event = InputEventKey.new()
    event.keycode = KEY_W
    event.pressed = true
    get_tree().get_root().get_viewport().push_input(event)
    print("  ... awaiting timer for movement.")
    await get_tree().create_timer(0.5).timeout
    event.pressed = false
    get_tree().get_root().get_viewport().push_input(event)
    
    print_step("Movement simulated. Taking screenshot...")
    ScreenshotManager.take_screenshot("03_player_moved.png", ScreenshotManager.Category.AUTOMATED, "poc_integration")

    # Step 5: Open Pause Menu
    print_step("Simulating ESC key press for pause menu...")
    var pause_event = InputEventAction.new()
    pause_event.action = "ui_cancel"
    pause_event.pressed = true
    get_tree().get_root().get_viewport().push_input(pause_event)
    print("  ... awaiting process frame.")
    await get_tree().process_frame
    pause_event.pressed = false
    get_tree().get_root().get_viewport().push_input(pause_event)
    print("  ... awaiting timer for pause menu to appear.")
    await get_tree().create_timer(1.0).timeout

    var pause_menu = find_node("PauseMenu")
    if !pause_menu:
        return fail_test("Pause Menu did not appear after pressing ESC.")
        
    print_step("Pause menu opened. Taking screenshot...")
    ScreenshotManager.take_screenshot("04_pause_menu_opened.png", ScreenshotManager.Category.AUTOMATED, "poc_integration")

    # Step 6: Return to Main Menu
    print_step("Simulating 'Main Menu' button press...")
    var main_menu_button = pause_menu.get_node("MenuContainer/MainPanel/VBoxContainer/ButtonContainer/MainMenuButton")
    if !main_menu_button:
        return fail_test("Could not find 'Main Menu' button in pause menu.")
        
    main_menu_button.emit_signal("pressed")
    print("  ... awaiting process frame.")
    await get_tree().process_frame
    print("  ... awaiting timer for menu transition.")
    await get_tree().create_timer(1.0).timeout
    
    # Step 7: Verify Return to Main Menu
    var final_scene = get_tree().get_root().get_child(get_tree().get_root().get_child_count() - 1)
    if final_scene.get_name() != "MainMenuSimple":
        return fail_test("Did not return to Main Menu. Current scene: " + final_scene.get_name())

    print_step("Returned to Main Menu. Taking final screenshot...")
    ScreenshotManager.take_screenshot("05_returned_to_main_menu.png", ScreenshotManager.Category.AUTOMATED, "poc_integration")

    finish_test()

func find_node(node_name):
    var root = get_tree().get_root()
    var queue = [root]
    while !queue.is_empty():
        var current = queue.pop_front()
        if current.get_name() == node_name:
            return current
        for child in current.get_children():
            queue.append(child)
    return null

func print_step(message):
    test_step += 1
    print("[STEP %d] %s" % [test_step, message])

func fail_test(reason):
    error_occurred = true
    print("[ERROR] Test failed at step %d: %s" % [test_step, reason])
    finish_test()

func finish_test():
    if error_occurred:
        print("--- POC INTEGRATION TEST: FAILED ---")
    else:
        print("--- POC INTEGRATION TEST: PASSED ---")
    
    print("Screenshots saved in testing/screenshots/automated/poc_integration/")
    get_tree().quit()
