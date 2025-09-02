extends CanvasLayer
## Standalone test version of main menu that's always visible

@onready var start_button: Button = $MenuContainer/MainPanel/VBoxContainer/ButtonContainer/StartButton
@onready var settings_button: Button = $MenuContainer/MainPanel/VBoxContainer/ButtonContainer/SettingsButton
@onready var quit_button: Button = $MenuContainer/MainPanel/VBoxContainer/ButtonContainer/QuitButton

func _ready() -> void:
	print("=== STANDALONE MAIN MENU TEST ===")
	layer = 200
	
	# ALWAYS VISIBLE FOR TESTING
	visible = true
	
	# Setup buttons
	if start_button:
		start_button.pressed.connect(_on_start_pressed)
		print("Start button connected")
	
	if settings_button:
		settings_button.pressed.connect(_on_settings_pressed)
		print("Settings button connected")
	
	if quit_button:
		quit_button.pressed.connect(_on_quit_pressed)
		print("Quit button connected")
	
	print("Standalone main menu ready - VISIBLE")
	
	# Auto-exit after 3 seconds for testing
	await get_tree().create_timer(0.5).timeout
	capture_test_screenshot()
	
	await get_tree().create_timer(2.0).timeout
	print("=== TEST COMPLETE - EXITING ===")
	get_tree().quit()

func capture_test_screenshot():
	var viewport = get_viewport()
	if viewport:
		var image = viewport.get_texture().get_image()
		if image:
			var result = image.save_png("testing/screenshots/current/main_menu_standalone_test.png")
			if result == OK:
				print("Test screenshot saved!")
			else:
				print("Failed to save test screenshot: ", result)

func _on_start_pressed():
	print("START BUTTON CLICKED - WORKING!")

func _on_settings_pressed():
	print("SETTINGS BUTTON CLICKED - WORKING!")

func _on_quit_pressed():
	print("QUIT BUTTON CLICKED - WORKING!")
	get_tree().quit()