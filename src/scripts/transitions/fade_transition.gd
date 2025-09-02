class_name FadeTransition
extends CanvasLayer
## Handles smooth fade in/out transitions between scenes

# Signals
signal fade_in_completed
signal fade_out_completed
signal transition_completed
# Testing signals for precise timing
signal transition_started
signal transition_halfway

# Export properties
@export var fade_duration: float = 1.0
@export var fade_color: Color = Color.BLACK

# Node references
var color_rect: ColorRect

# Internal state
var _tween: Tween
var _is_transitioning: bool = false

func _ready() -> void:
	# Find the ColorRect child
	color_rect = get_node("ColorRect")
	
	if OS.is_debug_build():
		print("FadeTransition _ready - ColorRect found:", color_rect != null)
	
	# Set layer to render on top of everything with high priority
	layer = 1000
	follow_viewport_enabled = false
	
	# Ensure ColorRect covers the entire screen and is properly configured
	if color_rect:
		color_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
		color_rect.color = fade_color
		color_rect.modulate.a = 0.0  # Start invisible but ready
		# Force mouse filter to ignore to prevent blocking input when transparent
		color_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
		# Set very high z-index to ensure it renders on top
		color_rect.z_index = 4096
		# Ensure visible flag is true (required for modulate to work)
		color_rect.visible = true
		# Ensure it's topmost child
		move_child(color_rect, get_child_count() - 1)
		
		if OS.is_debug_build():
			print("ColorRect configured - z_index:", color_rect.z_index, "visible:", color_rect.visible)
	else:
		print("ERROR: ColorRect not found in FadeTransition scene!")
	
	# Block input during transitions by default
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	
	if OS.is_debug_build():
		print("FadeTransition initialized - Layer:", layer)

## Fade in (from transparent to opaque) - used to hide scene before switching
func fade_in() -> void:
	if _is_transitioning:
		return
	
	_is_transitioning = true
	
	# Kill any existing tween
	if _tween and _tween.is_valid():
		_tween.kill()
	
	# Ensure we start from transparent
	color_rect.modulate.a = 0.0
	
	if OS.is_debug_build():
		print("FadeTransition: Starting fade in - alpha:", color_rect.modulate.a, " duration:", fade_duration)
	
	# Emit transition started signal
	transition_started.emit()
	
	# Create new tween and animate
	_tween = get_tree().create_tween()
	_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)  # Process when paused
	_tween.set_ease(Tween.EASE_IN_OUT)
	_tween.set_trans(Tween.TRANS_CUBIC)
	_tween.tween_property(color_rect, "modulate:a", 1.0, fade_duration)
	
	await _tween.finished
	
	_is_transitioning = false
	fade_in_completed.emit()
	
	if OS.is_debug_build():
		print("FadeTransition: Fade in completed")

## Fade out (from opaque to transparent) - used to reveal new scene
func fade_out() -> void:
	if _is_transitioning:
		return
	
	_is_transitioning = true
	
	# Kill any existing tween
	if _tween and _tween.is_valid():
		_tween.kill()
	
	# Ensure we start from opaque
	color_rect.modulate.a = 1.0
	
	if OS.is_debug_build():
		print("FadeTransition: Starting fade out - alpha:", color_rect.modulate.a, " duration:", fade_duration)
	
	# Create new tween and animate
	_tween = get_tree().create_tween()
	_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)  # Process when paused
	_tween.set_ease(Tween.EASE_IN_OUT)
	_tween.set_trans(Tween.TRANS_CUBIC)
	_tween.tween_property(color_rect, "modulate:a", 0.0, fade_duration)
	
	await _tween.finished
	
	_is_transitioning = false
	fade_out_completed.emit()
	
	if OS.is_debug_build():
		print("FadeTransition: Fade out completed")

## Complete fade transition (fade in, then fade out) - full scene transition
func transition() -> void:
	if _is_transitioning:
		return
	
	await fade_in()
	await fade_out()
	
	transition_completed.emit()
	
	if OS.is_debug_build():
		print("FadeTransition: Complete transition finished")

## Set the overlay to fully opaque (for instant scene switches)
func show_overlay() -> void:
	if color_rect:
		color_rect.modulate.a = 1.0
		color_rect.visible = true
		if OS.is_debug_build():
			print("FadeTransition: Overlay shown - alpha:", color_rect.modulate.a, " visible:", color_rect.visible)

## Set the overlay to fully transparent (for instant scene reveals)
func hide_overlay() -> void:
	if color_rect:
		color_rect.modulate.a = 0.0
		if OS.is_debug_build():
			print("FadeTransition: Overlay hidden - alpha:", color_rect.modulate.a, " visible:", color_rect.visible)

## Check if currently transitioning
func is_transitioning() -> bool:
	return _is_transitioning

## Set custom fade color
func set_fade_color(new_color: Color) -> void:
	fade_color = new_color
	if color_rect:
		color_rect.color = fade_color

## Set custom fade duration
func set_fade_duration(new_duration: float) -> void:
	fade_duration = max(0.1, new_duration)  # Minimum duration to prevent instant changes

## Kill any active tween and reset state
func reset() -> void:
	if _tween:
		_tween.kill()
	
	_is_transitioning = false
	hide_overlay()
	
	if OS.is_debug_build():
		print("FadeTransition: Reset to initial state")

## Built-in screenshot method for testing - Updated for organized structure
func take_screenshot(filename: String, category: String = "working") -> String:
	var viewport = get_viewport()
	if not viewport:
		print("ERROR: No viewport available for screenshot")
		return ""
	
	var image = viewport.get_texture().get_image()
	if not image:
		print("ERROR: Could not get viewport image")
		return ""
	
	# Use organized screenshot directory structure
	var base_dir = "res://testing/screenshots/"
	var screenshot_dir = ""
	
	# Determine directory based on category
	match category:
		"working":
			screenshot_dir = base_dir + "current/working/"
		"session":
			screenshot_dir = base_dir + "current/session-4/"
		"automated":
			screenshot_dir = base_dir + "automated/fade-transitions/"
		"archive":
			screenshot_dir = base_dir + "archive/session-3/"
		_:
			screenshot_dir = base_dir + "current/working/"
	
	# Ensure directory exists (convert to user:// path for actual file operations)
	var user_path = screenshot_dir.replace("res://", "user://")
	var dir = DirAccess.open("user://")
	
	# Create nested directories
	var path_parts = user_path.replace("user://", "").split("/")
	var current_path = "user://"
	for part in path_parts:
		if part != "":
			current_path += part + "/"
			if not dir.dir_exists(current_path):
				dir.make_dir_recursive(current_path)
	
	# Add timestamp to filename if not already present
	var timestamped_filename = filename
	if not filename.contains(Time.get_datetime_string_from_system()):
		var timestamp = Time.get_datetime_string_from_system().replace(":", "-").replace(" ", "_")
		timestamped_filename = filename.get_basename() + "_" + timestamp + "." + filename.get_extension()
	
	var full_path = user_path + timestamped_filename
	var error = image.save_png(full_path)
	if error != OK:
		print("ERROR: Could not save screenshot to ", full_path, " Error: ", error)
		return ""
	
	# Also save to project directory for easy access
	var project_path = screenshot_dir + timestamped_filename
	image.save_png(project_path)
	
	print("Screenshot saved to: ", project_path, " (and ", full_path, ")")
	return project_path