class_name ScreenshotManager
extends RefCounted
## Centralized screenshot management for organized testing and documentation

# Screenshot categories
enum Category {
	WORKING,      # Current working screenshots
	SESSION,      # Session-specific screenshots  
	AUTOMATED,    # Automated testing screenshots
	ARCHIVE,      # Archived session screenshots
	REFERENCE     # Reference comparison screenshots
}

# Base screenshot directory
const BASE_DIR = "res://testing/screenshots/"

# Directory mappings
static var category_paths = {
	Category.WORKING: "current/working/",
	Category.SESSION: "current/session-4/",
	Category.AUTOMATED: "automated/",
	Category.ARCHIVE: "archive/",
	Category.REFERENCE: "reference/"
}

## Take a screenshot with automatic organization and timestamping
static func take_screenshot(filename: String, category: Category = Category.WORKING, subcategory: String = "") -> String:
	var viewport = Engine.get_main_loop().current_scene.get_viewport()
	if not viewport:
		print("ERROR: No viewport available for screenshot")
		return ""
	
	var image = viewport.get_texture().get_image()
	if not image:
		print("ERROR: Could not get viewport image")
		return ""
	
	# Build directory path
	var dir_path = BASE_DIR + category_paths[category]
	if subcategory != "":
		dir_path += subcategory + "/"
	
	# Ensure directory exists
	var dir = DirAccess.open("res://")
	if not dir.dir_exists(dir_path):
		dir.make_dir_recursive(dir_path)
	
	# Add timestamp if not present
	var timestamped_filename = _add_timestamp_if_needed(filename)
	
	# Save screenshot
	var full_path = dir_path + timestamped_filename
	var error = image.save_png(full_path)
	if error != OK:
		print("ERROR: Could not save screenshot to ", full_path, " Error: ", error)
		return ""
	
	print("Screenshot saved to: ", full_path)
	return full_path

## Take multiple screenshots for a test sequence
static func take_sequence(base_filename: String, count: int, category: Category = Category.AUTOMATED, subcategory: String = "") -> Array[String]:
	var screenshots: Array[String] = []
	for i in range(count):
		var filename = base_filename.get_basename() + "_step" + str(i+1) + "." + base_filename.get_extension()
		var path = take_screenshot(filename, category, subcategory)
		if path != "":
			screenshots.append(path)
		# Brief pause between screenshots
		await Engine.get_main_loop().process_frame
	return screenshots

## Archive current session screenshots
static func archive_session(session_number: int) -> void:
	var source_dir = BASE_DIR + "current/"
	var dest_dir = BASE_DIR + "archive/session-" + str(session_number) + "/"
	
	var dir = DirAccess.open(source_dir)
	if dir:
		# Ensure archive directory exists
		var archive_dir = DirAccess.open(BASE_DIR + "archive/")
		if not archive_dir.dir_exists("session-" + str(session_number)):
			archive_dir.make_dir("session-" + str(session_number))
		
		# Move screenshots to archive
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name.ends_with(".png"):
				var source_path = source_dir + file_name
				var dest_path = dest_dir + file_name
				dir.rename(source_path, dest_path)
				print("Archived: ", file_name, " to ", dest_path)
			file_name = dir.get_next()
	
	print("Session ", session_number, " screenshots archived")

## Clean up old working screenshots
static func cleanup_working_screenshots(keep_recent: int = 10) -> void:
	var working_dir = BASE_DIR + "current/working/"
	var dir = DirAccess.open(working_dir)
	if not dir:
		return
	
	var files: Array[String] = []
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if file_name.ends_with(".png"):
			files.append(file_name)
		file_name = dir.get_next()
	
	# Sort by modification time (newest first)
	files.sort_custom(func(a, b): return FileAccess.get_modified_time(working_dir + a) > FileAccess.get_modified_time(working_dir + b))
	
	# Delete old files
	for i in range(keep_recent, files.size()):
		var file_path = working_dir + files[i]
		dir.remove(file_path)
		print("Cleaned up old screenshot: ", files[i])

## Generate timestamp for filename
static func _add_timestamp_if_needed(filename: String) -> String:
	var timestamp_pattern = RegEx.new()
	timestamp_pattern.compile(r"\d{4}-\d{2}-\d{2}_\d{2}-\d{2}-\d{2}")
	
	# Check if filename already has timestamp
	if timestamp_pattern.search(filename):
		return filename
	
	# Add timestamp
	var timestamp = Time.get_datetime_string_from_system().replace(":", "-").replace(" ", "_")
	var extension = filename.get_extension()
	var basename = filename.get_basename()
	
	return basename + "_" + timestamp + "." + extension

## Get screenshot directory for category
static func get_category_dir(category: Category, subcategory: String = "") -> String:
	var dir_path = BASE_DIR + category_paths[category]
	if subcategory != "":
		dir_path += subcategory + "/"
	return dir_path
