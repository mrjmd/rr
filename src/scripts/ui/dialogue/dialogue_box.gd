class_name DialogueBox
extends Control
## Dialogue box UI component handling text display and choice presentation

# Signals
signal typing_completed
signal choice_selected(choice_index: int)
signal dialogue_box_clicked

# Node references
@onready var background_panel: Panel = $BackgroundPanel
@onready var content_container: VBoxContainer = $BackgroundPanel/ContentContainer
@onready var speaker_label: Label = $BackgroundPanel/ContentContainer/SpeakerLabel
@onready var dialogue_text: RichTextLabel = $BackgroundPanel/ContentContainer/DialogueText
@onready var choices_container: VBoxContainer = $BackgroundPanel/ContentContainer/ChoicesContainer
@onready var text_animator: Node = $TextAnimator

# Styling and configuration
@export var background_color: Color = Color(0.1, 0.1, 0.2, 0.9)
@export var speaker_color: Color = Color(1.0, 0.8, 0.4, 1.0)
@export var text_color: Color = Color.WHITE
@export var padding: Vector2 = Vector2(20, 15)
@export var corner_radius: float = 8.0

# Animation state
var is_typing: bool = false
var current_text: String = ""
var target_text: String = ""
var typing_speed: float = 30.0
var _typing_tween: Tween

func _ready() -> void:
	# Keep scene-configured anchors and positioning - don't override
	# Scene is now configured for proper bottom positioning
	
	# Configure styling
	_setup_styling()
	
	# Initialize components
	_initialize_components()
	
	# Connect signals
	_connect_signals()
	
	# Start hidden
	visible = false
	
	if OS.is_debug_build():
		print("DialogueBox initialized with size: ", size)

func _setup_styling() -> void:
	"""Configure visual styling for the dialogue box"""
	
	if background_panel:
		
		# Get existing StyleBox from scene configuration and modify it
		var style_box = background_panel.get_theme_stylebox("panel")
		
		if not style_box:
			# Fallback: Create custom StyleBox if none exists
			style_box = StyleBoxFlat.new()
			style_box.bg_color = background_color
			
			style_box.corner_radius_bottom_left = corner_radius
			style_box.corner_radius_bottom_right = corner_radius
			style_box.corner_radius_top_left = corner_radius
			style_box.corner_radius_top_right = corner_radius
			
			# Add border and shadow
			if style_box is StyleBoxFlat:
				var flat_style = style_box as StyleBoxFlat
				flat_style.border_width_left = 2
				flat_style.border_width_top = 2
				flat_style.border_width_right = 2
				flat_style.border_width_bottom = 2
				flat_style.border_color = Color(0.4, 0.4, 0.5, 1)
				flat_style.shadow_color = Color(0, 0, 0, 0.5)
				flat_style.shadow_size = 4
				flat_style.shadow_offset = Vector2(2, 2)
			
			background_panel.add_theme_stylebox_override("panel", style_box)
			
		else:
			pass
		
		# Ensure the panel is visible
		background_panel.visible = true
		background_panel.modulate = Color.WHITE
		
	
	# Configure speaker label
	if speaker_label:
		speaker_label.modulate = speaker_color
		speaker_label.add_theme_font_size_override("font_size", 18)
		speaker_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	
	# Configure dialogue text
	if dialogue_text:
		dialogue_text.modulate = text_color
		dialogue_text.fit_content = true
		dialogue_text.scroll_active = false
		dialogue_text.bbcode_enabled = true
		dialogue_text.add_theme_font_size_override("normal_font_size", 16)
	

func _initialize_components() -> void:
	"""Initialize dialogue box components"""
	# Set up content container
	if content_container:
		content_container.add_theme_constant_override("separation", 10)
	
	# Connect text animator if available from scene
	if text_animator:
		text_animator.typing_completed.connect(_on_typing_animation_completed)
	else:
		print("DialogueBox: Warning - TextAnimator not found in scene")
	
	# Set up choices container
	if choices_container:
		choices_container.visible = false
		choices_container.add_theme_constant_override("separation", 8)

func _connect_signals() -> void:
	"""Connect internal signals"""
	# Connect mouse input for advancing dialogue
	gui_input.connect(_on_gui_input)
	
	if OS.is_debug_build():
		print("DialogueBox: Signals connected")

func _on_gui_input(event: InputEvent) -> void:
	"""Handle mouse input on dialogue box"""
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			dialogue_box_clicked.emit()
			get_viewport().set_input_as_handled()

# Public API Methods

func show_dialogue(speaker_name: String, text: String) -> void:
	"""Display dialogue with speaker name and text"""
	
	# Set speaker name
	if speaker_label:
		speaker_label.text = speaker_name
		speaker_label.visible = speaker_name != ""
	
	# Hide choices while showing dialogue
	if choices_container:
		choices_container.visible = false
		_clear_choices()
	
	# Set up text animation
	target_text = text
	current_text = ""
	
	# Clear dialogue text
	if dialogue_text:
		dialogue_text.text = ""
	
	# Show dialogue box
	visible = true
	
	# Start typing animation
	_start_typing_animation()
	
	
	if OS.is_debug_build():
		print("DialogueBox: Showing dialogue - Speaker: '", speaker_name, "' Text length: ", text.length())

func show_choices(choices: Array) -> void:
	"""Display dialogue choices"""
	if not choices_container:
		print("DialogueBox: No choices container available")
		return
	
	# Clear existing choices
	_clear_choices()
	
	# Create choice buttons
	for i in range(choices.size()):
		var choice_data = choices[i]
		var choice_button = _create_choice_button(choice_data, i)
		choices_container.add_child(choice_button)
	
	# Show choices container
	choices_container.visible = true
	
	if OS.is_debug_build():
		print("DialogueBox: Showing ", choices.size(), " choices")

func hide_dialogue() -> void:
	"""Hide the dialogue box"""
	visible = false
	_stop_typing_animation()
	if choices_container:
		choices_container.visible = false
		_clear_choices()

func set_typing_speed(speed: float) -> void:
	"""Set the typing animation speed"""
	typing_speed = max(1.0, speed)

func skip_typing() -> void:
	"""Skip typing animation and show full text immediately"""
	if is_typing:
		_stop_typing_animation()
		if dialogue_text:
			dialogue_text.text = target_text
		current_text = target_text
		is_typing = false
		typing_completed.emit()
		
		if OS.is_debug_build():
			print("DialogueBox: Typing animation skipped")

func get_is_typing() -> bool:
	"""Check if typing animation is active"""
	return is_typing

func pause_animations() -> void:
	"""Pause typing animations"""
	if _typing_tween and _typing_tween.is_valid():
		_typing_tween.pause()

func resume_animations() -> void:
	"""Resume typing animations"""
	if _typing_tween and _typing_tween.is_valid():
		_typing_tween.play()

# Internal Methods

func _start_typing_animation() -> void:
	"""Start typing animation effect"""
	if not dialogue_text or target_text == "":
		return
	
	is_typing = true
	current_text = ""
	
	# Calculate animation duration based on text length and speed
	var char_count = target_text.length()
	var duration = char_count / typing_speed
	
	# Use text animator if available, otherwise use simple tween
	if text_animator and text_animator.has_method("animate_typing"):
		text_animator.animate_typing(dialogue_text, target_text, typing_speed)
	else:
		_simple_typing_animation(duration)

func _simple_typing_animation(duration: float) -> void:
	"""Fallback typing animation using tween"""
	_typing_tween = create_tween()
	
	var char_count = target_text.length()
	for i in range(char_count + 1):
		var partial_text = target_text.substr(0, i)
		var delay = (float(i) / char_count) * duration
		
		_typing_tween.tween_callback(_update_displayed_text.bind(partial_text)).set_delay(delay)
	
	# Complete animation
	_typing_tween.tween_callback(_on_typing_animation_completed).set_delay(duration)

func _update_displayed_text(text: String) -> void:
	"""Update the displayed text during animation"""
	if dialogue_text:
		dialogue_text.text = text
	current_text = text

func _stop_typing_animation() -> void:
	"""Stop the typing animation"""
	if _typing_tween and _typing_tween.is_valid():
		_typing_tween.kill()
	is_typing = false

func _create_choice_button(choice_data: Dictionary, index: int) -> Button:
	"""Create a choice button with styling"""
	var button = ChoiceButton.new() if ChoiceButton else Button.new()
	
	# Set button text
	button.text = choice_data.get("text", "Choice " + str(index + 1))
	
	# Configure button styling
	button.flat = false
	button.add_theme_font_size_override("font_size", 14)
	
	# Create custom button style
	var normal_style = StyleBoxFlat.new()
	normal_style.bg_color = Color(0.3, 0.3, 0.4, 0.8)
	normal_style.corner_radius_bottom_left = 4
	normal_style.corner_radius_bottom_right = 4
	normal_style.corner_radius_top_left = 4
	normal_style.corner_radius_top_right = 4
	normal_style.content_margin_left = 12
	normal_style.content_margin_right = 12
	normal_style.content_margin_top = 8
	normal_style.content_margin_bottom = 8
	
	var hover_style = normal_style.duplicate()
	hover_style.bg_color = Color(0.4, 0.4, 0.5, 0.9)
	
	var pressed_style = normal_style.duplicate()
	pressed_style.bg_color = Color(0.5, 0.5, 0.6, 1.0)
	
	button.add_theme_stylebox_override("normal", normal_style)
	button.add_theme_stylebox_override("hover", hover_style)
	button.add_theme_stylebox_override("pressed", pressed_style)
	
	# Connect button signal
	button.pressed.connect(_on_choice_button_pressed.bind(index))
	
	# Add emotional impact indicator if available
	var emotional_impact = choice_data.get("emotional_impact", {})
	if emotional_impact.size() > 0:
		button.tooltip_text = _format_emotional_impact_tooltip(emotional_impact)
	
	# Set button properties if it's a ChoiceButton
	if button.has_method("set_choice_data"):
		button.set_choice_data(choice_data, index)
	
	return button

func _format_emotional_impact_tooltip(emotional_impact: Dictionary) -> String:
	"""Format emotional impact as tooltip text"""
	var tooltip_parts: Array = []
	
	for emotion in emotional_impact:
		var impact_value = emotional_impact[emotion]
		if impact_value != 0.0:
			var sign = "+" if impact_value > 0 else ""
			tooltip_parts.append(emotion.capitalize() + ": " + sign + str(impact_value))
	
	return "Emotional Impact:\n" + "\n".join(tooltip_parts)

func _clear_choices() -> void:
	"""Clear all choice buttons"""
	if not choices_container:
		return
	
	for child in choices_container.get_children():
		child.queue_free()

func _on_choice_button_pressed(choice_index: int) -> void:
	"""Handle choice button press"""
	choice_selected.emit(choice_index)
	
	if OS.is_debug_build():
		print("DialogueBox: Choice ", choice_index, " selected")

func _on_typing_animation_completed() -> void:
	"""Handle typing animation completion"""
	is_typing = false
	typing_completed.emit()
	
	if OS.is_debug_build():
		print("DialogueBox: Typing animation completed")

# Debug Methods

func get_debug_info() -> Dictionary:
	"""Get debug information about dialogue box state"""
	return {
		"visible": visible,
		"is_typing": is_typing,
		"current_text_length": current_text.length(),
		"target_text_length": target_text.length(),
		"choices_visible": choices_container.visible if choices_container else false,
		"choice_count": choices_container.get_child_count() if choices_container else 0
	}

func debug_print_state() -> void:
	"""Print current dialogue box state (debug only)"""
	if OS.is_debug_build():
		print("DialogueBox Debug State: ", get_debug_info())