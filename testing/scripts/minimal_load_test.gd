extends SceneTree

func _init():
    print("--- Minimal Scene Load Test ---")
    var scene_path = "res://src/scenes/poc/kitchen.tscn"
    var err = change_scene_to_path(scene_path)
    if err != OK:
        print("[FAIL] Could not change scene to kitchen. Error code: %d" % err)
        quit(1)
    
    await process_frame
    await create_timer(0.5).timeout
    
    var current_scene = get_root().get_child(get_root().get_child_count() - 1)
    if current_scene and current_scene.get_scene_file_path() == scene_path:
        print("[SUCCESS] Kitchen scene loaded successfully.")
        quit(0)
    else:
        print("[FAIL] Scene did not load or is incorrect.")
        quit(1)
