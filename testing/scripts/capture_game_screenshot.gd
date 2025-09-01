extends SceneTree
## Automated screenshot capture script for Godot
## Captures ONLY the game viewport, not the entire desktop

func _init() -> void:
	print("[Screenshot] Waiting for scene to load...")
	# Wait for first frame
	await process_frame
	await create_timer(0.5).timeout
	
	print("[Screenshot] Taking viewport screenshot...")
	# Get the main viewport
	var viewport = get_root()
	var image = viewport.get_texture().get_image()
	
	# Save with timestamp
	var timestamp = Time.get_unix_time_from_system()
	var filename = "res://testing/screenshots/current/godot_capture_%d.png" % timestamp
	image.save_png(filename)
	
	print("[Screenshot] Saved to: " + filename)
	print("[Screenshot] Image size: %s" % image.get_size())
	
	# Also save a "latest" version for easy access
	var latest_filename = "res://testing/screenshots/current/LATEST_CAPTURE.png"
	image.save_png(latest_filename)
	print("[Screenshot] Also saved as: " + latest_filename)
	
	# Test if dialogue is visible by checking pixels
	var center = image.get_size() / 2
	var bottom_center = Vector2i(center.x, image.get_height() - 150)
	var pixel_color = image.get_pixelv(bottom_center)
	
	print("[Screenshot] Bottom center pixel color: %s" % pixel_color)
	if pixel_color.a > 0.1:
		print("[Screenshot] Something visible at dialogue position!")
	else:
		print("[Screenshot] WARNING: Nothing visible at expected dialogue position!")
	
	quit()