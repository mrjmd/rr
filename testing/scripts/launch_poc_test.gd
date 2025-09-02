extends SceneTree

func _init():
    # Load the main menu scene first
    print("--- Test Launcher: Loading Main Menu Scene ---")
    get_root().change_scene_to_path("res://src/scenes/ui/menus/main_menu_simple.tscn")
    print("--- Test Launcher: Awaiting first frame...")
    await process_frame
    print("--- Test Launcher: Awaiting timer...")
    await create_timer(0.2).timeout
    
    # Now add the test runner node into the loaded scene
    print("--- Test Launcher: Injecting test runner node ---")
    var test_node_script = load("res://testing/scripts/poc_integration_test.gd")
    if test_node_script == null:
        print("[ERROR] Test Launcher: Failed to load test runner script.")
        quit(1)
        
    var test_node = test_node_script.new()
    test_node.set_name("IntegrationTestRunner")
    get_root().get_current_scene().add_child(test_node)
    print("--- Test Launcher: Test runner injected. Handing off control. ---")
