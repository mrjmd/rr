class_name GameMenuButton
extends Button
## Specialized button for menu navigation with consistent styling and animations

# Signals
signal button_hovered(button_name: String)
signal button_unhovered(button_name: String)
signal button_focused(button_name: String)
signal button_unfocused(button_name: String)

# Button properties
var button_name: String = ""
var button_action: String = ""
var button_data: Dictionary = {}

# Color palette - matching the game's dark theme
@export var background_color: Color = Color(0.1, 0.1, 0.15, 0.95)
@export var button_normal_color: Color = Color(0.25, 0.25, 0.35, 0.9)
@export var button_hover_color: Color = Color(0.35, 0.35, 0.45, 0.95)
@export var button_pressed_color: Color = Color(0.45, 0.45, 0.55, 1.0)
@export var button_focus_color: Color = Color(0.4, 0.4, 0.5, 0.95)

# Border colors
@export var border_normal_color: Color = Color(0.4, 0.4, 0.5, 0.5)
@export var border_hover_color: Color = Color(0.6, 0.6, 0.7, 0.8)
@export var border_pressed_color: Color = Color(0.8, 0.8, 0.9, 1.0)

# Text colors
@export var text_normal_color: Color = Color(0.9, 0.9, 0.9, 1.0)
@export var text_hover_color: Color = Color(1.0, 1.0, 1.0, 1.0)
@export var text_pressed_color: Color = Color(1.0, 1.0, 1.0, 1.0)

# Animation settings
@export var hover_scale: Vector2 = Vector2(1.05, 1.05)
@export var press_scale: Vector2 = Vector2(0.95, 0.95)
@export var animation_duration: float = 0.2
@export var hover_glow_strength: float = 0.2
@export var press_feedback_duration: float = 0.1

# Internal state
var _is_hovering: bool = false
var _is_pressed: bool = false
var _original_scale: Vector2
var _current_tween: Tween

func _ready() -> void:
	# Store original scale
	_original_scale = scale
	
	# Set button name from node name if not set
	if button_name.is_empty():
		button_name = name
	
	# Connect button signals
	_connect_button_signals()
	
	# Setup button styling
	_setup_button_styling()
	
	# Connect focus signals
	_connect_focus_signals()
	
	if OS.is_debug_build():
		print("MenuButton initialized: ", button_name)

func _connect_button_signals() -> void:
	"""Connect all button signals"""
	pressed.connect(_on_button_pressed)
	button_down.connect(_on_button_down)
	button_up.connect(_on_button_up)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

func _connect_focus_signals() -> void:
	"""Connect focus-related signals"""
	focus_entered.connect(_on_focus_entered)
	focus_exited.connect(_on_focus_exited)

func _setup_button_styling() -> void:
	"""Configure button appearance and styling"""
	# Basic button properties
	flat = false
	alignment = HORIZONTAL_ALIGNMENT_CENTER
	text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	
	# Set minimum size for consistent layout
	custom_minimum_size = Vector2(200, 50)
	
	# Configure font
	add_theme_font_size_override("font_size", 16)
	
	# Create and apply custom styles
	_create_button_styles()

func _create_button_styles() -> void:
	"""Create custom button styles with consistent theming"""
	# Normal state style
	var normal_style = _create_base_style()
	normal_style.bg_color = button_normal_color
	normal_style.border_color = border_normal_color
	_apply_text_color(normal_style, text_normal_color)
	
	# Hover state style
	var hover_style = _create_base_style()
	hover_style.bg_color = button_hover_color
	hover_style.border_color = border_hover_color
	_apply_text_color(hover_style, text_hover_color)
	
	# Pressed state style
	var pressed_style = _create_base_style()
	pressed_style.bg_color = button_pressed_color
	pressed_style.border_color = border_pressed_color
	_apply_text_color(pressed_style, text_pressed_color)
	
	# Focus state style
	var focus_style = _create_base_style()
	focus_style.bg_color = button_focus_color
	focus_style.border_color = border_hover_color
	focus_style.border_width_left = 3
	focus_style.border_width_right = 3
	focus_style.border_width_top = 3
	focus_style.border_width_bottom = 3
	_apply_text_color(focus_style, text_hover_color)
	
	# Apply all styles
	add_theme_stylebox_override("normal", normal_style)
	add_theme_stylebox_override("hover", hover_style)
	add_theme_stylebox_override("pressed", pressed_style)
	add_theme_stylebox_override("focus", focus_style)

func _create_base_style() -> StyleBoxFlat:
	"""Create base style with common properties"""
	var style = StyleBoxFlat.new()
	
	# Corner radius for consistent rounded appearance
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	
	# Content margins for proper text spacing
	style.content_margin_left = 20
	style.content_margin_right = 20
	style.content_margin_top = 15
	style.content_margin_bottom = 15
	
	# Border properties
	style.border_width_left = 2
	style.border_width_right = 2
	style.border_width_top = 2
	style.border_width_bottom = 2
	
	return style

func _apply_text_color(style: StyleBoxFlat, color: Color) -> void:
	"""Apply text color to button - this would be done via theme in practice"""
	# In Godot, text color is typically set via theme
	# This is a placeholder for the proper theme integration
	add_theme_color_override("font_color", color)

# Public API Methods

func set_button_data(name: String, action: String = "", data: Dictionary = {}) -> void:
	"""Set button data and configuration"""
	button_name = name
	button_action = action
	button_data = data
	
	# Update button text if provided
	if data.has("text"):
		text = data["text"]
	elif not text:
		text = name.capitalize()
	
	# Update tooltip if provided
	if data.has("tooltip"):
		tooltip_text = data["tooltip"]
	
	if OS.is_debug_build():
		print("MenuButton data set: ", button_name, " with action: ", button_action)

# Public methods for specific button types
func trigger_back_button() -> void:
	"""Trigger this button as a back/cancel button with appropriate sound"""
	_play_back_sound()
	flash_selection()
	pressed.emit()

func trigger_confirm_button() -> void:
	"""Trigger this button as a confirm button with appropriate sound"""
	_play_confirm_sound()
	flash_selection()
	pressed.emit()

func trigger_error_feedback() -> void:
	"""Show error feedback without triggering the button"""
	_play_error_sound()
	# Add red flash for error
	_stop_current_animation()
	_current_tween = create_tween()
	_current_tween.tween_property(self, "modulate", Color(1.8, 0.8, 0.8, 1.0), 0.1)
	_current_tween.tween_property(self, "modulate", Color.WHITE, 0.4)

func get_button_data() -> Dictionary:
	"""Get button data"""
	return button_data

func get_button_name() -> String:
	"""Get button name"""
	return button_name

func get_button_action() -> String:
	"""Get button action"""
	return button_action

# Animation Methods

func animate_hover_enter() -> void:
	"""Animate button when hover begins"""
	_stop_current_animation()
	
	_current_tween = create_tween()
	_current_tween.set_parallel(true)
	
	# Scale animation
	_current_tween.tween_property(self, "scale", _original_scale * hover_scale, animation_duration)
	# Subtle glow effect via modulation
	var glow_color = Color(1.0 + hover_glow_strength, 1.0 + hover_glow_strength, 1.0 + hover_glow_strength, 1.0)
	_current_tween.tween_property(self, "modulate", glow_color, animation_duration)
	_current_tween.tween_method(_update_hover_progress, 0.0, 1.0, animation_duration)

func animate_hover_exit() -> void:
	"""Animate button when hover ends"""
	_stop_current_animation()
	
	_current_tween = create_tween()
	_current_tween.set_parallel(true)
	
	# Scale animation back to normal
	_current_tween.tween_property(self, "scale", _original_scale, animation_duration)
	# Remove glow effect
	_current_tween.tween_property(self, "modulate", Color.WHITE, animation_duration)
	_current_tween.tween_method(_update_hover_progress, 1.0, 0.0, animation_duration)

func animate_press() -> void:
	"""Animate button press"""
	_stop_current_animation()
	
	_current_tween = create_tween()
	_current_tween.set_parallel(true)
	
	# Quick press animation with immediate feedback
	_current_tween.tween_property(self, "scale", _original_scale * press_scale, press_feedback_duration)
	# Return to hover scale after press
	_current_tween.tween_property(self, "scale", _original_scale * hover_scale, press_feedback_duration).set_delay(press_feedback_duration)
	# Brief brightness increase on press
	_current_tween.tween_property(self, "modulate", Color(1.3, 1.3, 1.3, 1.0), press_feedback_duration)
	var glow_color = Color(1.0 + hover_glow_strength, 1.0 + hover_glow_strength, 1.0 + hover_glow_strength, 1.0)
	_current_tween.tween_property(self, "modulate", glow_color, press_feedback_duration).set_delay(press_feedback_duration)

func animate_focus() -> void:
	"""Animate button when it gains focus"""
	# Create a subtle pulse effect for focus
	_stop_current_animation()
	
	_current_tween = create_tween()
	_current_tween.set_loops(2)
	_current_tween.tween_property(self, "modulate", Color(1.2, 1.2, 1.2, 1.0), 0.3)
	_current_tween.tween_property(self, "modulate", Color.WHITE, 0.3)

func highlight() -> void:
	"""Highlight the button temporarily"""
	_stop_current_animation()
	
	_current_tween = create_tween()
	_current_tween.set_loops(3)
	_current_tween.tween_property(self, "modulate", Color(1.3, 1.3, 1.3, 1.0), 0.2)
	_current_tween.tween_property(self, "modulate", Color.WHITE, 0.2)

func flash_selection() -> void:
	"""Flash effect when button is activated"""
	_stop_current_animation()
	
	_current_tween = create_tween()
	_current_tween.tween_property(self, "modulate", Color(1.5, 1.5, 1.5, 1.0), 0.1)
	_current_tween.tween_property(self, "modulate", Color.WHITE, 0.3)

func _stop_current_animation() -> void:
	"""Stop the current animation tween"""
	if _current_tween:
		_current_tween.kill()
		_current_tween = null

func _update_hover_progress(progress: float) -> void:
	"""Update hover animation progress"""
	# This can be used for custom hover effects
	# Currently just used for timing
	pass

# Signal Callbacks

func _on_button_pressed() -> void:
	"""Handle button press"""
	flash_selection()
	_play_selection_sound()
	
	if OS.is_debug_build():
		print("MenuButton pressed: ", button_name, " with action: ", button_action)

func _on_button_down() -> void:
	"""Handle button down (pressed state)"""
	_is_pressed = true
	animate_press()

func _on_button_up() -> void:
	"""Handle button up (released state)"""
	_is_pressed = false

func _on_mouse_entered() -> void:
	"""Handle mouse hover start"""
	_is_hovering = true
	animate_hover_enter()
	button_hovered.emit(button_name)
	_play_hover_sound()

func _on_mouse_exited() -> void:
	"""Handle mouse hover end"""
	_is_hovering = false
	if not has_focus():  # Only animate out if not focused
		animate_hover_exit()
	button_unhovered.emit(button_name)

func _on_focus_entered() -> void:
	"""Handle focus gained"""
	animate_focus()
	button_focused.emit(button_name)
	
	if OS.is_debug_build():
		print("MenuButton focused: ", button_name)

func _on_focus_exited() -> void:
	"""Handle focus lost"""
	if not _is_hovering:  # Only reset if not hovering
		scale = _original_scale
	button_unfocused.emit(button_name)

# Audio Methods

func _play_selection_sound() -> void:
	"""Play sound when button is selected"""
	if AudioManager:
		AudioManager.play_ui_sound("ui_click")

func _play_hover_sound() -> void:
	"""Play sound when button is hovered"""
	if AudioManager:
		AudioManager.play_ui_sound("ui_hover")

func _play_back_sound() -> void:
	"""Play sound for back/cancel actions"""
	if AudioManager:
		AudioManager.play_ui_sound("ui_back")

func _play_confirm_sound() -> void:
	"""Play sound for confirm actions"""
	if AudioManager:
		AudioManager.play_ui_sound("ui_confirm")

func _play_error_sound() -> void:
	"""Play sound for error actions"""
	if AudioManager:
		AudioManager.play_ui_sound("ui_error")

# Utility Methods

func set_colors(normal: Color, hover: Color, pressed: Color) -> void:
	"""Set custom colors for button states"""
	button_normal_color = normal
	button_hover_color = hover
	button_pressed_color = pressed
	_create_button_styles()

func is_button_interacting() -> bool:
	"""Check if button is being interacted with"""
	return _is_hovering or _is_pressed or has_focus()

func reset_button_state() -> void:
	"""Reset button to default state"""
	_stop_current_animation()
	scale = _original_scale
	modulate = Color.WHITE
	_is_hovering = false
	_is_pressed = false

# Debug Methods

func get_button_debug_info() -> Dictionary:
	"""Get debug information about button state"""
	return {
		"button_name": button_name,
		"button_action": button_action,
		"is_hovering": _is_hovering,
		"is_pressed": _is_pressed,
		"has_focus": has_focus(),
		"is_interacting": is_button_interacting(),
		"current_scale": scale,
		"button_text": text
	}

func debug_print_button_state() -> void:
	"""Print current button state for debugging"""
	if OS.is_debug_build():
		print("MenuButton Debug State: ", get_button_debug_info())