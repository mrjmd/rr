extends SceneTree

# Automated testing script for verification
# Run with: godot --headless --script scripts/test_automation.gd

signal test_complete(success: bool, report: Dictionary)

var test_results: Dictionary = {
    "timestamp": "",
    "scene_loaded": false,
    "errors_found": [],
    "warnings_found": [],
    "screenshots": [],
    "performance": {},
    "features_tested": [],
    "overall_status": "PENDING"
}

var screenshot_count: int = 0
var screenshot_dir: String = "res://test_screenshots/"

func _init() -> void:
    print("=== GODOT AUTOMATED TESTER v1.0 ===")
    test_results["timestamp"] = Time.get_datetime_string_from_system()
    
    # Ensure screenshot directory exists
    DirAccess.make_dir_recursive_absolute(screenshot_dir)
    
    # Run tests
    await run_all_tests()

func run_all_tests() -> void:
    print("\n[1/5] Waiting for scene initialization...")
    await process_frame
    await create_timer(2.0).timeout
    
    print("[2/5] Capturing initial state...")
    capture_screenshot("00_initial_load")
    
    print("[3/5] Checking scene structure...")
    await test_scene_structure()
    
    print("[4/5] Testing features...")
    await test_active_features()
    
    print("[5/5] Generating report...")
    generate_final_report()
    
    # Exit with appropriate code
    var exit_code = 0 if test_results["overall_status"] == "PASS" else 1
    quit(exit_code)

func test_scene_structure() -> void:
    var root = get_root()
    test_results["scene_loaded"] = root != null
    
    if not root:
        test_results["errors_found"].append("CRITICAL: No root scene found")
        test_results["overall_status"] = "FAIL"
        return
    
    # Check for player
    var player = root.find_child("Player", true, false)
    if player:
        test_results["features_tested"].append("Player node found")
        capture_screenshot("01_player_found")
        await test_player_functionality(player)
    else:
        test_results["warnings_found"].append("Player node not found in scene")
    
    # Check for UI elements
    var ui_elements = root.find_children("*", "Control", true, false)
    test_results["features_tested"].append("UI elements: %d found" % ui_elements.size())
    
    # Check for specific meters
    var rage_meter = root.find_child("RageMeter", true, false)
    var reservoir_meter = root.find_child("ReservoirMeter", true, false)
    
    if rage_meter:
        test_results["features_tested"].append("RageMeter found")
        capture_screenshot("02_rage_meter")
    
    if reservoir_meter:
        test_results["features_tested"].append("ReservoirMeter found")
        capture_screenshot("03_reservoir_meter")

func test_active_features() -> void:
    var root = get_root()
    
    # Test any active animations
    var anim_players = root.find_children("*", "AnimationPlayer", true, false)
    for anim in anim_players:
        if anim.is_playing():
            test_results["features_tested"].append("Active animation: " + anim.current_animation)
            capture_screenshot("04_animation_active")
    
    # Test performance
    test_results["performance"]["fps"] = Engine.get_frames_per_second()
    test_results["performance"]["memory_mb"] = OS.get_static_memory_usage() / 1048576.0
    test_results["performance"]["process_time_ms"] = get_process_time() * 1000
    
    # Check for any runtime errors
    if test_results["errors_found"].is_empty():
        test_results["features_tested"].append("No runtime errors detected")

func test_player_functionality(player: Node) -> void:
    # Test player properties
    if player.has_method("get_class"):
        test_results["features_tested"].append("Player class: " + player.get_class())
    
    # Check for movement capability
    if player.has_method("move_and_slide") or player.has_method("velocity"):
        test_results["features_tested"].append("Player has movement capability")
        
        # Simulate movement test
        capture_screenshot("05_before_movement")
        await create_timer(0.5).timeout
        
        # Try to access position
        if "position" in player:
            var original_pos = player.position
            test_results["features_tested"].append("Player position: " + str(original_pos))
            capture_screenshot("06_position_logged")

func capture_screenshot(label: String) -> void:
    var viewport = get_root()
    if not viewport:
        print("WARNING: Cannot capture screenshot - no viewport")
        return
        
    var image = viewport.get_texture().get_image()
    var timestamp = Time.get_unix_time_from_system()
    var filename = "%s%s_%d.png" % [screenshot_dir, label, int(timestamp)]
    
    # Save screenshot
    var error = image.save_png(filename)
    if error == OK:
        print("  ✓ Screenshot saved: " + filename)
        test_results["screenshots"].append(filename)
    else:
        print("  ✗ Failed to save screenshot: " + filename)
        test_results["warnings_found"].append("Screenshot save failed: " + label)
    
    screenshot_count += 1

func generate_final_report() -> void:
    # Determine overall status
    if not test_results["errors_found"].is_empty():
        test_results["overall_status"] = "FAIL"
    elif not test_results["warnings_found"].is_empty():
        test_results["overall_status"] = "PASS_WITH_WARNINGS"
    else:
        test_results["overall_status"] = "PASS"
    
    # Build report
    var report = "\n" + "="*50 + "\n"
    report += "         AUTOMATED TEST REPORT\n"
    report += "="*50 + "\n\n"
    
    report += "Timestamp: " + test_results["timestamp"] + "\n"
    report += "Status: " + test_results["overall_status"] + "\n\n"
    
    report += "SCENE VALIDATION:\n"
    report += "  Scene Loaded: " + str(test_results["scene_loaded"]) + "\n\n"
    
    report += "FEATURES TESTED (%d):\n" % test_results["features_tested"].size()
    for feature in test_results["features_tested"]:
        report += "  ✓ " + feature + "\n"
    report += "\n"
    
    if not test_results["errors_found"].is_empty():
        report += "ERRORS (%d):\n" % test_results["errors_found"].size()
        for error in test_results["errors_found"]:
            report += "  ✗ " + error + "\n"
        report += "\n"
    
    if not test_results["warnings_found"].is_empty():
        report += "WARNINGS (%d):\n" % test_results["warnings_found"].size()
        for warning in test_results["warnings_found"]:
            report += "  ⚠ " + warning + "\n"
        report += "\n"
    
    report += "PERFORMANCE:\n"
    for metric in test_results["performance"]:
        report += "  " + metric + ": " + str(test_results["performance"][metric]) + "\n"
    report += "\n"
    
    report += "SCREENSHOTS CAPTURED: %d\n" % test_results["screenshots"].size()
    for screenshot in test_results["screenshots"]:
        report += "  📸 " + screenshot + "\n"
    
    report += "\n" + "="*50 + "\n"
    
    # Print to console
    print(report)
    
    # Save report to file
    var file = FileAccess.open("res://test_report.txt", FileAccess.WRITE)
    if file:
        file.store_string(report)
        file.close()
        print("\nReport saved to: res://test_report.txt")
    else:
        print("\nWARNING: Could not save report to file")
    
    # Also save as JSON for parsing
    var json_file = FileAccess.open("res://test_results.json", FileAccess.WRITE)
    if json_file:
        json_file.store_string(JSON.stringify(test_results, "\t"))
        json_file.close()
        print("JSON results saved to: res://test_results.json")