extends SceneTree
## Automated screenshot capture for settings menu demo verification

const SCREENSHOT_PATH = "testing/screenshots/current/settings_menu_demo_proof.png"

func _ready():
	print("Starting settings menu demo screenshot capture...")
	
	# Load the demo scene
	var demo_scene = load("res://src/scenes/demo/settings_menu_standalone_demo.tscn")
	if not demo_scene:
		print("ERROR: Could not load settings demo scene")
		quit()
		return
	
	# Instance the scene
	var scene_instance = demo_scene.instantiate()
	if not scene_instance:
		print("ERROR: Could not instantiate settings demo scene")
		quit()
		return
	
	# Add to scene tree
	root.add_child(scene_instance)
	
	print("Demo scene loaded successfully")
	
	# Wait a few frames for everything to initialize
	await process_frame
	await process_frame
	await process_frame
	
	# Take initial screenshot
	_take_screenshot("01_initial")
	
	# Get the settings menu
	var settings_menu = scene_instance.get_node("SettingsMenuStandalone")
	if not settings_menu:
		print("ERROR: Could not find settings menu")
		quit()
		return
	
	print("Found settings menu, opening...")
	
	# Open the settings menu
	settings_menu.open_settings()
	
	# Wait for menu to open
	await process_frame
	await process_frame
	await process_frame
	
	# Take screenshot with menu open
	_take_screenshot("02_menu_open")
	
	# Change some settings for demonstration
	print("Changing audio settings...")
	
	# Get audio sliders
	var master_slider = settings_menu.get_node("MenuContainer/MainPanel/VBoxContainer/TabContainer/Audio/VBoxContainer/MasterVolumeContainer/MasterVolumeSlider")
	var music_slider = settings_menu.get_node("MenuContainer/MainPanel/VBoxContainer/TabContainer/Audio/VBoxContainer/MusicVolumeContainer/MusicVolumeSlider")
	
	if master_slider:
		master_slider.value = 0.5
		print("Set master volume to 50%")
	
	if music_slider:
		music_slider.value = 0.7
		print("Set music volume to 70%")
	
	# Wait for changes to apply
	await process_frame
	await process_frame
	
	# Take screenshot with changed values
	_take_screenshot("03_audio_changed")
	
	# Switch to video tab
	print("Switching to video tab...")
	var tab_container = settings_menu.get_node("MenuContainer/MainPanel/VBoxContainer/TabContainer")
	if tab_container:
		tab_container.current_tab = 1  # Video tab
	
	await process_frame
	await process_frame
	
	# Take screenshot of video tab
	_take_screenshot("04_video_tab")
	
	# Toggle fullscreen setting
	var fullscreen_check = settings_menu.get_node("MenuContainer/MainPanel/VBoxContainer/TabContainer/Video/VBoxContainer/FullscreenContainer/FullscreenCheck")
	if fullscreen_check:
		fullscreen_check.button_pressed = true
		print("Enabled fullscreen")
	
	await process_frame
	await process_frame
	
	# Take screenshot with fullscreen enabled
	_take_screenshot("05_fullscreen_enabled")
	
	# Switch to controls tab
	print("Switching to controls tab...")
	if tab_container:
		tab_container.current_tab = 2  # Controls tab
	
	await process_frame
	await process_frame
	
	# Take screenshot of controls tab
	_take_screenshot("06_controls_tab")
	
	# Close the menu
	print("Closing settings menu...")
	settings_menu.close_settings()
	
	await process_frame
	await process_frame
	
	# Take final screenshot
	_take_screenshot("07_menu_closed")
	
	print("Settings menu demo screenshots completed successfully!")
	print("Check testing/screenshots/current/ for captured images")
	
	quit()

func _take_screenshot(suffix: String):
	"""Take a screenshot with the given suffix"""
	var viewport = get_root().get_viewport()
	if not viewport:
		print("ERROR: Could not get viewport for screenshot")
		return
	
	# Wait one more frame to ensure rendering is complete
	await process_frame
	
	# Get the viewport texture
	var image = viewport.get_texture().get_image()
	if not image:
		print("ERROR: Could not get viewport image")
		return
	
	# Create the filename
	var filename = "testing/screenshots/current/settings_menu_" + suffix + ".png"
	
	# Save the image
	var error = image.save_png(filename)
	if error == OK:
		print("Screenshot saved: ", filename)
	else:
		print("ERROR: Failed to save screenshot: ", filename, " (Error: ", error, ")")