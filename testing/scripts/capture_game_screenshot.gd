extends Node
## Script to capture game screenshots for testing

func _ready():
	print("[Screenshot] Waiting for scene to load...")
	# Wait a frame for everything to be ready
	await get_tree().process_frame
	await get_tree().process_frame
	
	# Wait a bit more for UI to render
	await get_tree().create_timer(0.5).timeout
	
	print("[Screenshot] Capturing screenshot...")
	capture_screenshot("main_menu_diagnostic")
	
	# Exit after capture
	get_tree().quit()

func capture_screenshot(filename: String):
	var viewport = get_viewport()
	if not viewport:
		print("ERROR: Could not get viewport")
		return
	
	# Get the rendered image
	var image = viewport.get_texture().get_image()
	if not image:
		print("ERROR: Could not get image from viewport")
		return
	
	# Save to testing directory
	var save_path = "testing/screenshots/current/" + filename + ".png"
	var result = image.save_png(save_path)
	
	if result == OK:
		print("Screenshot saved: " + save_path)
	else:
		print("ERROR: Failed to save screenshot: " + str(result))