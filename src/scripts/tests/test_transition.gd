extends SceneTree
## Automated test script to verify fade transitions work

var screenshots_taken: int = 0
var test_complete: bool = false

func _init():
	print("Starting fade transition test...")
	# Give scene time to load
	await create_timer(1.0).timeout
	await run_test()

func run_test():
	print("Loading transition demo scene...")
	
	# Load the transition demo scene
	var demo_scene = load("res://src/scenes/shared/transition_demo.tscn")
	var demo = demo_scene.instantiate()
	root.add_child(demo)
	
	# Wait for scene to be ready
	await create_timer(0.5).timeout
	take_screenshot("01_demo_loaded")
	
	print("Creating fade transition...")
	# Create fade transition directly
	var fade_scene = load("res://src/scenes/transitions/fade_transition.tscn")
	var fade = fade_scene.instantiate()
	root.add_child(fade)
	
	# Start fade in (screen goes black)
	print("Starting fade in...")
	fade.fade_in()
	
	# Capture during fade
	await create_timer(0.25).timeout
	take_screenshot("02_during_fade_in")
	
	# Wait for fade in to complete
	await create_timer(0.25).timeout
	take_screenshot("03_fade_in_complete")
	
	# Load test scene while faded
	print("Loading test scene...")
	demo.queue_free()
	await demo.tree_exited
	
	var test_scene = load("res://src/scenes/shared/simple_test_scene.tscn")
	var test = test_scene.instantiate()
	root.add_child(test)
	
	take_screenshot("04_test_scene_loaded_faded")
	
	# Start fade out (reveal new scene)
	print("Starting fade out...")
	fade.fade_out()
	
	# Capture during fade out
	await create_timer(0.25).timeout
	take_screenshot("05_during_fade_out")
	
	# Wait for fade out to complete
	await create_timer(0.25).timeout
	take_screenshot("06_fade_out_complete")
	
	print("Test complete! Check screenshots in project root.")
	print("Screenshots taken: ", screenshots_taken)
	
	# Clean up
	fade.queue_free()
	test_complete = true
	
	await create_timer(1.0).timeout
	quit()

func take_screenshot(name: String):
	var image = root.get_texture().get_image()
	var filename = "transition_test_" + name + ".png"
	image.save_png("res://" + filename)
	screenshots_taken += 1
	print("Screenshot saved: ", filename)