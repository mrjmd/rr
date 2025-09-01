extends SceneTree
## Automated dialogue system testing script
## Run with: godot --headless --script res://src/scripts/testing/dialogue_automated_test.gd

var test_results: Array = []
var screenshot_count: int = 0

func _init():
	print("=== AUTOMATED DIALOGUE SYSTEM TEST ===")
	print("Starting automated test sequence...")
	
	# Wait for initialization
	await process_frame
	await process_frame
	
	# Run tests
	await _run_test_sequence()
	
	# Print results
	_print_test_results()
	
	# Save results to file
	_save_test_results()
	
	quit()

func _run_test_sequence():
	"""Run complete automated test sequence"""
	print("\n--- TEST 1: Scene Loading ---")
	await _test_scene_loading()
	
	print("\n--- TEST 2: Screenshot Capture ---")
	await _test_screenshot_system()
	
	print("\n--- TEST 3: Basic Dialogue System ---")
	await _test_basic_dialogue_system()

func _test_scene_loading():
	"""Test that dialogue demo scene loads correctly"""
	var scene_path = "res://src/scenes/demo/dialogue_demo.tscn"
	
	if ResourceLoader.exists(scene_path):
		var scene = ResourceLoader.load(scene_path)
		if scene:
			var instance = scene.instantiate()
			get_root().add_child(instance)
			
			# Wait for initialization
			await process_frame
			await process_frame
			
			_log_test("Scene Loading", true, "Dialogue demo scene loaded successfully")
			
			# Check if dialogue system exists
			var dialogue_system = instance.get_node_or_null("DialogueSystem")
			if dialogue_system:
				_log_test("DialogueSystem Node", true, "DialogueSystem found in scene")
			else:
				_log_test("DialogueSystem Node", false, "DialogueSystem not found in scene")
			
			return instance
		else:
			_log_test("Scene Loading", false, "Failed to instantiate scene")
	else:
		_log_test("Scene Loading", false, "Scene file does not exist: " + scene_path)
	
	return null

func _test_screenshot_system():
	"""Test screenshot capture functionality"""
	var viewport = get_root()
	if viewport:
		var image = viewport.get_texture().get_image()
		if image:
			var filename = "automated_test_" + str(screenshot_count) + ".png"
			var path = "/Users/matt/Projects/randos-reservoir/testing/screenshots/verification/" + filename
			
			var error = image.save_png(path)
			if error == OK:
				_log_test("Screenshot System", true, "Screenshot saved: " + filename)
				screenshot_count += 1
				
				# Verify file exists
				var file = FileAccess.open(path, FileAccess.READ)
				if file:
					file.close()
					_log_test("Screenshot Verification", true, "Screenshot file verified on disk")
				else:
					_log_test("Screenshot Verification", false, "Screenshot file not found on disk")
			else:
				_log_test("Screenshot System", false, "Failed to save screenshot: " + str(error))
		else:
			_log_test("Screenshot System", false, "Failed to get viewport image")
	else:
		_log_test("Screenshot System", false, "No viewport available")

func _test_basic_dialogue_system():
	"""Test basic dialogue system functionality without user input"""
	# Load dialogue demo scene
	var scene_path = "res://src/scenes/demo/dialogue_demo.tscn"
	var scene = ResourceLoader.load(scene_path)
	
	if not scene:
		_log_test("Dialogue System", false, "Could not load dialogue demo scene")
		return
	
	var instance = scene.instantiate()
	get_root().add_child(instance)
	
	# Wait for initialization
	await process_frame
	await process_frame
	
	# Take screenshot of initial state
	await _capture_test_screenshot("dialogue_demo_initial")
	
	# Find dialogue system
	var dialogue_system = instance.get_node_or_null("DialogueSystem")
	if not dialogue_system:
		_log_test("Dialogue System", false, "DialogueSystem node not found")
		return
	
	_log_test("Dialogue System Found", true, "DialogueSystem node located")
	
	# Test dialogue system initialization
	if dialogue_system.has_method("get_dialogue_active"):
		var is_active = dialogue_system.get_dialogue_active()
		_log_test("Initial State", not is_active, "Dialogue system starts inactive: " + str(not is_active))
	else:
		_log_test("API Check", false, "get_dialogue_active method not found")
	
	# Test starting dialogue
	if dialogue_system.has_method("start_dialogue"):
		dialogue_system.start_dialogue("test_intro")
		
		# Wait for dialogue to start
		await process_frame
		await process_frame
		await process_frame
		
		# Take screenshot after dialogue starts
		await _capture_test_screenshot("dialogue_demo_active")
		
		var is_active = dialogue_system.get_dialogue_active()
		_log_test("Start Dialogue", is_active, "Dialogue activated: " + str(is_active))
		
		# Wait a bit for any animations
		await create_timer(1.0).timeout
		
		# Take final screenshot
		await _capture_test_screenshot("dialogue_demo_final")
		
		# Test ending dialogue
		if dialogue_system.has_method("end_dialogue"):
			dialogue_system.end_dialogue()
			await process_frame
			
			var is_still_active = dialogue_system.get_dialogue_active()
			_log_test("End Dialogue", not is_still_active, "Dialogue ended: " + str(not is_still_active))
	else:
		_log_test("API Check", false, "start_dialogue method not found")

func _capture_test_screenshot(test_name: String):
	"""Capture screenshot for specific test"""
	var viewport = get_root()
	if viewport:
		var image = viewport.get_texture().get_image()
		if image:
			var filename = test_name + "_" + str(screenshot_count) + ".png"
			var path = "/Users/matt/Projects/randos-reservoir/testing/screenshots/verification/" + filename
			
			var error = image.save_png(path)
			if error == OK:
				print("Screenshot captured: " + filename)
				screenshot_count += 1
			else:
				print("Failed to capture screenshot: " + str(error))

func _log_test(test_name: String, passed: bool, details: String = ""):
	"""Log test result"""
	var result = {
		"test": test_name,
		"passed": passed,
		"details": details,
		"timestamp": Time.get_datetime_string_from_system()
	}
	test_results.append(result)
	
	var status = "PASS" if passed else "FAIL"
	print("[%s] %s: %s" % [status, test_name, details])

func _print_test_results():
	"""Print summary of all test results"""
	print("\n=== TEST RESULTS SUMMARY ===")
	
	var total_tests = test_results.size()
	var passed_tests = 0
	var failed_tests = 0
	
	for result in test_results:
		if result.passed:
			passed_tests += 1
		else:
			failed_tests += 1
	
	print("Total Tests: %d" % total_tests)
	print("Passed: %d" % passed_tests)
	print("Failed: %d" % failed_tests)
	print("Success Rate: %.1f%%" % (float(passed_tests) / float(total_tests) * 100.0))
	print("Screenshots Captured: %d" % screenshot_count)

func _save_test_results():
	"""Save test results to file"""
	var results_data = {
		"test_run_timestamp": Time.get_datetime_string_from_system(),
		"total_tests": test_results.size(),
		"passed_tests": test_results.filter(func(r): return r.passed).size(),
		"screenshot_count": screenshot_count,
		"results": test_results
	}
	
	var json_string = JSON.stringify(results_data, "\t")
	var file = FileAccess.open("/Users/matt/Projects/randos-reservoir/testing/screenshots/verification/test_results.json", FileAccess.WRITE)
	if file:
		file.store_string(json_string)
		file.close()
		print("Test results saved to: test_results.json")
	else:
		print("Failed to save test results")