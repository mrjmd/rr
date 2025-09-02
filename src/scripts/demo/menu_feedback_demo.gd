class_name MenuFeedbackDemo
extends Control
## Demo scene showcasing menu audio and visual feedback systems

# UI References
@onready var normal_button: Button = $Container/ButtonContainer/NormalButton
@onready var confirm_button: Button = $Container/ButtonContainer/ConfirmButton
@onready var back_button: Button = $Container/ButtonContainer/BackButton
@onready var error_button: Button = $Container/ButtonContainer/ErrorButton
@onready var test_slider: HSlider = $Container/SliderContainer/TestSlider
@onready var slider_value_label: Label = $Container/SliderContainer/SliderValue
@onready var test_checkbox: CheckBox = $Container/CheckboxContainer/TestCheckbox
@onready var status_label: Label = $Container/StatusLabel
@onready var back_to_menu_button: Button = $Container/BackToMenuButton

# Audio feedback state
var last_slider_sound_time: float = 0.0
var slider_sound_cooldown: float = 0.1

func _ready() -> void:
	_setup_buttons()
	_connect_signals()
	_update_status("Demo ready - try interacting with the controls!")
	
	if OS.is_debug_build():
		print("MenuFeedbackDemo initialized")

func _setup_buttons() -> void:
	"""Setup button data and types"""
	# Configure normal button
	if normal_button:
		normal_button.set_button_data("normal", "normal_action", {
			"text": "Normal Click Button",
			"tooltip": "Standard button with click sound and scaling"
		})
	
	# Configure confirm button 
	if confirm_button:
		confirm_button.set_button_data("confirm", "confirm_action", {
			"text": "Confirm Button", 
			"tooltip": "Confirm action with confirmation sound"
		})
	
	# Configure back button
	if back_button:
		back_button.set_button_data("back", "back_action", {
			"text": "Back Button",
			"tooltip": "Back action with back sound"
		})
	
	# Configure error button
	if error_button:
		error_button.set_button_data("error", "error_action", {
			"text": "Error Trigger Button",
			"tooltip": "Demonstrates error feedback"
		})
	
	# Configure back to menu button
	if back_to_menu_button:
		back_to_menu_button.set_button_data("back_to_menu", "menu_action", {
			"text": "Back to Main Menu",
			"tooltip": "Return to main menu"
		})

func _connect_signals() -> void:
	"""Connect all UI signals"""
	# Button signals
	if normal_button:
		normal_button.pressed.connect(_on_normal_button_pressed)
	
	if confirm_button:
		confirm_button.pressed.connect(_on_confirm_button_pressed)
	
	if back_button:
		back_button.pressed.connect(_on_back_button_pressed)
	
	if error_button:
		error_button.pressed.connect(_on_error_button_pressed)
	
	if back_to_menu_button:
		back_to_menu_button.pressed.connect(_on_back_to_menu_pressed)
	
	# Slider signal
	if test_slider:
		test_slider.value_changed.connect(_on_test_slider_changed)
	
	# Checkbox signal
	if test_checkbox:
		test_checkbox.toggled.connect(_on_test_checkbox_toggled)

# Input handling for keyboard navigation demo
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_on_back_to_menu_pressed()

# Button handlers
func _on_normal_button_pressed() -> void:
	"""Handle normal button press"""
	_update_status("Normal button clicked! Standard audio and visual feedback played.")
	
	if OS.is_debug_build():
		print("MenuFeedbackDemo: Normal button pressed")

func _on_confirm_button_pressed() -> void:
	"""Handle confirm button press"""
	_update_status("Confirm button clicked! Confirmation sound played.")
	
	# Use the specific confirm sound
	if confirm_button:
		confirm_button.trigger_confirm_button()
	
	if OS.is_debug_build():
		print("MenuFeedbackDemo: Confirm button pressed")

func _on_back_button_pressed() -> void:
	"""Handle back button press"""
	_update_status("Back button clicked! Back sound played.")
	
	# Use the specific back sound
	if back_button:
		back_button.trigger_back_button()
	
	if OS.is_debug_build():
		print("MenuFeedbackDemo: Back button pressed")

func _on_error_button_pressed() -> void:
	"""Handle error button press"""
	_update_status("Error feedback triggered! Red flash and error sound played.")
	
	# Trigger error feedback
	if error_button:
		error_button.trigger_error_feedback()
	
	if OS.is_debug_build():
		print("MenuFeedbackDemo: Error button pressed")

func _on_back_to_menu_pressed() -> void:
	"""Handle back to menu button"""
	_update_status("Returning to main menu...")
	
	# Use MenuManager if available, otherwise fallback
	var menu_manager = get_node_or_null("/root/MenuManager")
	if menu_manager:
		menu_manager.open_menu("main_menu", true)
	else:
		# Fallback to loading main menu directly
		get_tree().change_scene_to_file("res://src/scenes/ui/menus/main_menu.tscn")
	
	if OS.is_debug_build():
		print("MenuFeedbackDemo: Returning to main menu")

# Slider handler
func _on_test_slider_changed(value: float) -> void:
	"""Handle test slider value change"""
	# Play audio feedback with debouncing
	_play_slider_sound()
	
	# Update value label
	if slider_value_label:
		slider_value_label.text = str(int(value * 100)) + "%"
	
	_update_status("Slider changed to " + str(int(value * 100)) + "% - audio feedback played.")

# Checkbox handler
func _on_test_checkbox_toggled(button_pressed: bool) -> void:
	"""Handle checkbox toggle"""
	# Play checkbox audio
	var audio_manager = get_node_or_null("/root/AudioManager")
	if audio_manager and audio_manager.has_method("play_ui_sound"):
		audio_manager.play_ui_sound("ui_click")
	
	var state_text = "checked" if button_pressed else "unchecked"
	_update_status("Checkbox " + state_text + " - click sound played.")
	
	if OS.is_debug_build():
		print("MenuFeedbackDemo: Checkbox toggled to ", button_pressed)

# Audio feedback methods
func _play_slider_sound() -> void:
	"""Play sound for slider interaction with debouncing"""
	var current_time = Time.get_ticks_msec() / 1000.0
	if current_time - last_slider_sound_time >= slider_sound_cooldown:
		var audio_manager = get_node_or_null("/root/AudioManager")
		if audio_manager and audio_manager.has_method("play_ui_sound"):
			audio_manager.play_ui_sound("ui_hover", -10.0)  # Quieter for sliders
		last_slider_sound_time = current_time

# Utility methods
func _update_status(message: String) -> void:
	"""Update the status label"""
	if status_label:
		status_label.text = "Status: " + message
	
	if OS.is_debug_build():
		print("MenuFeedbackDemo Status: ", message)

# Demo information display
func _get_demo_info() -> String:
	"""Get information about this demo"""
	return """
Menu Audio & Visual Feedback Demo

This demo showcases the enhanced menu system with:

AUDIO FEEDBACK:
• ui_hover: Hover sounds on buttons
• ui_click: Standard click sounds  
• ui_back: Back/cancel sounds
• ui_confirm: Confirmation sounds
• ui_error: Error feedback sounds
• ui_transition: Menu transition sounds

VISUAL FEEDBACK:
• Hover scaling (1.05x scale)
• Hover glow effect
• Press scaling (0.95x scale)
• Flash effects for selection
• Error red flash effect
• Focus animations

INTERACTION TYPES:
• Normal buttons: Standard feedback
• Confirm buttons: Confirmation sound
• Back buttons: Back sound
• Error triggers: Red flash + error sound
• Sliders: Debounced hover sounds
• Checkboxes: Click sounds
"""

# Debug methods
func get_demo_debug_info() -> Dictionary:
	"""Get debug information about demo state"""
	return {
		"demo_active": visible,
		"buttons_connected": normal_button != null and confirm_button != null,
		"audio_manager_available": get_node_or_null("/root/AudioManager") != null,
		"menu_manager_available": get_node_or_null("/root/MenuManager") != null,
		"last_slider_sound_time": last_slider_sound_time,
		"slider_value": test_slider.value if test_slider else 0.0,
		"checkbox_state": test_checkbox.button_pressed if test_checkbox else false
	}

func debug_print_demo_state() -> void:
	"""Print current demo state for debugging"""
	if OS.is_debug_build():
		print("MenuFeedbackDemo Debug State: ", get_demo_debug_info())