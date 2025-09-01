class_name ChoiceButton
extends Button
## Specialized button for dialogue choices with emotional impact indicators

# Signals
signal choice_hovered(choice_index: int, choice_data: Dictionary)
signal choice_unhovered(choice_index: int)

# Choice data
var choice_data: Dictionary = {}
var choice_index: int = -1
var emotional_impact: Dictionary = {}

# Visual indicators
@export var impact_positive_color: Color = Color(0.4, 0.8, 0.4, 1.0)  # Green for positive
@export var impact_negative_color: Color = Color(0.8, 0.4, 0.4, 1.0)  # Red for negative
@export var impact_neutral_color: Color = Color(0.6, 0.6, 0.6, 1.0)   # Gray for neutral

# Impact indicator UI
var impact_indicator: Control
var impact_label: Label

func _ready() -> void:
	# Connect button signals
	pressed.connect(_on_button_pressed)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	
	# Set up styling
	_setup_button_styling()
	
	# Create impact indicator
	_create_impact_indicator()
	
	if OS.is_debug_build():
		print("ChoiceButton initialized")

func _setup_button_styling() -> void:
	"""Configure button appearance"""
	# Basic button properties
	flat = false
	alignment = HORIZONTAL_ALIGNMENT_LEFT
	text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	
	# Set minimum size for proper layout
	custom_minimum_size = Vector2(200, 40)
	
	# Configure font
	add_theme_font_size_override("font_size", 14)
	
	# Create custom styles
	_create_button_styles()

func _create_button_styles() -> void:
	"""Create custom button styles"""
	# Normal state
	var normal_style = StyleBoxFlat.new()
	normal_style.bg_color = Color(0.25, 0.25, 0.35, 0.9)
	normal_style.corner_radius_bottom_left = 6
	normal_style.corner_radius_bottom_right = 6
	normal_style.corner_radius_top_left = 6
	normal_style.corner_radius_top_right = 6
	normal_style.content_margin_left = 15
	normal_style.content_margin_right = 40  # Extra space for impact indicator
	normal_style.content_margin_top = 10
	normal_style.content_margin_bottom = 10
	normal_style.border_width_left = 2
	normal_style.border_width_right = 2
	normal_style.border_width_top = 2
	normal_style.border_width_bottom = 2
	normal_style.border_color = Color(0.4, 0.4, 0.5, 0.5)
	
	# Hover state
	var hover_style = normal_style.duplicate()
	hover_style.bg_color = Color(0.35, 0.35, 0.45, 0.95)
	hover_style.border_color = Color(0.6, 0.6, 0.7, 0.8)
	
	# Pressed state
	var pressed_style = normal_style.duplicate()
	pressed_style.bg_color = Color(0.45, 0.45, 0.55, 1.0)
	pressed_style.border_color = Color(0.8, 0.8, 0.9, 1.0)
	
	# Apply styles
	add_theme_stylebox_override("normal", normal_style)
	add_theme_stylebox_override("hover", hover_style)
	add_theme_stylebox_override("pressed", pressed_style)

func _create_impact_indicator() -> void:
	"""Create visual indicator for emotional impact"""
	# Create container for impact indicator
	impact_indicator = Control.new()
	impact_indicator.set_anchors_and_offsets_preset(Control.PRESET_RIGHT_WIDE)
	impact_indicator.anchor_left = 1.0
	impact_indicator.anchor_right = 1.0
	impact_indicator.offset_left = -35
	impact_indicator.offset_right = -5
	impact_indicator.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(impact_indicator)
	
	# Create impact label
	impact_label = Label.new()
	impact_label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	impact_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	impact_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	impact_label.add_theme_font_size_override("font_size", 12)
	impact_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	impact_indicator.add_child(impact_label)
	
	# Initially hidden
	impact_indicator.visible = false

# Public API Methods

func set_choice_data(data: Dictionary, index: int) -> void:
	"""Set the choice data and index"""
	choice_data = data
	choice_index = index
	emotional_impact = data.get("emotional_impact", {})
	
	# Update button text
	text = data.get("text", "Choice " + str(index + 1))
	
	# Update impact indicator
	_update_impact_indicator()
	
	# Update tooltip
	_update_tooltip()
	
	if OS.is_debug_build():
		print("ChoiceButton: Set choice data for index ", index, " with impact: ", emotional_impact)

func get_choice_data() -> Dictionary:
	"""Get the choice data"""
	return choice_data

func get_choice_index() -> int:
	"""Get the choice index"""
	return choice_index

func get_emotional_impact() -> Dictionary:
	"""Get the emotional impact data"""
	return emotional_impact

func has_emotional_impact() -> bool:
	"""Check if choice has any emotional impact"""
	for emotion in emotional_impact:
		if emotional_impact[emotion] != 0.0:
			return true
	return false

# Visual Updates

func _update_impact_indicator() -> void:
	"""Update the visual impact indicator"""
	if not impact_indicator or not impact_label:
		return
	
	if not has_emotional_impact():
		impact_indicator.visible = false
		return
	
	# Calculate total impact
	var total_impact = 0.0
	var impact_types = []
	
	for emotion in emotional_impact:
		var impact_value = emotional_impact[emotion]
		if impact_value != 0.0:
			total_impact += impact_value
			impact_types.append(emotion)
	
	# Determine indicator appearance
	var indicator_color: Color
	var indicator_text: String
	
	if total_impact > 0:
		indicator_color = impact_positive_color
		indicator_text = "+"
	elif total_impact < 0:
		indicator_color = impact_negative_color
		indicator_text = "-"
	else:
		indicator_color = impact_neutral_color
		indicator_text = "="
	
	# Update indicator
	impact_label.text = indicator_text
	impact_label.modulate = indicator_color
	impact_indicator.visible = true
	
	# Add background circle for better visibility
	_create_indicator_background(indicator_color)

func _create_indicator_background(color: Color) -> void:
	"""Create background circle for impact indicator"""
	if not impact_indicator:
		return
	
	# Remove existing background
	for child in impact_indicator.get_children():
		if child.name == "Background":
			child.queue_free()
	
	# Create new background
	var background = Control.new()
	background.name = "Background"
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	impact_indicator.add_child(background)
	impact_indicator.move_child(background, 0)  # Move to back
	
	# Custom draw for circle background
	background.draw.connect(func(): _draw_indicator_circle(background, color))

func _draw_indicator_circle(control: Control, color: Color) -> void:
	"""Draw circular background for impact indicator"""
	var center = control.size / 2
	var radius = min(control.size.x, control.size.y) / 2 - 2
	
	# Draw circle
	control.draw_circle(center, radius, color.lerp(Color.TRANSPARENT, 0.7))
	control.draw_arc(center, radius, 0, TAU, 32, color, 1.5)

func _update_tooltip() -> void:
	"""Update button tooltip with detailed information"""
	var tooltip_parts: Array = []
	
	# Add choice text (shortened)
	var choice_text = choice_data.get("text", "")
	if choice_text.length() > 50:
		choice_text = choice_text.substr(0, 47) + "..."
	tooltip_parts.append("Choice: " + choice_text)
	
	# Add emotional impact details
	if has_emotional_impact():
		tooltip_parts.append("\nEmotional Impact:")
		for emotion in emotional_impact:
			var impact_value = emotional_impact[emotion]
			if impact_value != 0.0:
				var sign = "+" if impact_value > 0 else ""
				tooltip_parts.append("  " + emotion.capitalize() + ": " + sign + str(impact_value))
	
	# Add consequences hint if available
	var consequences = choice_data.get("consequences", "")
	if consequences != "":
		tooltip_parts.append("\nConsequences: " + consequences)
	
	tooltip_text = "\n".join(tooltip_parts)

# Animation Effects

func highlight() -> void:
	"""Highlight the button with animation"""
	var highlight_tween = create_tween()
	highlight_tween.set_loops(2)
	highlight_tween.tween_property(self, "modulate", Color(1.2, 1.2, 1.2, 1.0), 0.2)
	highlight_tween.tween_property(self, "modulate", Color.WHITE, 0.2)

func pulse_warning() -> void:
	"""Pulse button with warning color for high emotional impact"""
	if not has_emotional_impact():
		return
	
	var total_impact = 0.0
	for emotion in emotional_impact:
		total_impact += abs(emotional_impact[emotion])
	
	if total_impact >= 10.0:  # High impact threshold
		var warning_tween = create_tween()
		warning_tween.set_loops(3)
		warning_tween.tween_property(self, "modulate", Color(1.5, 1.0, 1.0, 1.0), 0.3)
		warning_tween.tween_property(self, "modulate", Color.WHITE, 0.3)

func flash_selection() -> void:
	"""Flash effect when button is selected"""
	var flash_tween = create_tween()
	flash_tween.tween_property(self, "modulate", Color(1.5, 1.5, 1.5, 1.0), 0.1)
	flash_tween.tween_property(self, "modulate", Color.WHITE, 0.2)

# Signal Callbacks

func _on_button_pressed() -> void:
	"""Handle button press"""
	# Flash effect
	flash_selection()
	
	# Play selection sound (placeholder)
	_play_selection_sound()
	
	if OS.is_debug_build():
		print("ChoiceButton: Choice ", choice_index, " selected - '", text, "'")

func _on_mouse_entered() -> void:
	"""Handle mouse hover start"""
	# Highlight button
	highlight()
	
	# Show detailed impact indicator
	if has_emotional_impact() and impact_indicator:
		var hover_tween = create_tween()
		hover_tween.tween_property(impact_indicator, "scale", Vector2(1.2, 1.2), 0.2)
	
	# Emit hover signal
	choice_hovered.emit(choice_index, choice_data)
	
	# Play hover sound (placeholder)
	_play_hover_sound()

func _on_mouse_exited() -> void:
	"""Handle mouse hover end"""
	# Reset impact indicator scale
	if impact_indicator:
		var unhover_tween = create_tween()
		unhover_tween.tween_property(impact_indicator, "scale", Vector2.ONE, 0.2)
	
	# Emit unhover signal
	choice_unhovered.emit(choice_index)

# Audio (placeholder methods for future implementation)

func _play_selection_sound() -> void:
	"""Play sound when choice is selected"""
	# This would integrate with AudioManager
	# AudioManager.play_sfx("choice_select")
	pass

func _play_hover_sound() -> void:
	"""Play sound when choice is hovered"""
	# This would integrate with AudioManager
	# AudioManager.play_sfx("choice_hover")
	pass

# Utility Methods

func set_impact_colors(positive: Color, negative: Color, neutral: Color) -> void:
	"""Set custom colors for impact indicators"""
	impact_positive_color = positive
	impact_negative_color = negative
	impact_neutral_color = neutral
	_update_impact_indicator()

func get_total_impact() -> float:
	"""Get total emotional impact value"""
	var total = 0.0
	for emotion in emotional_impact:
		total += emotional_impact[emotion]
	return total

func is_high_impact_choice() -> bool:
	"""Check if this is a high impact choice"""
	var total_impact = 0.0
	for emotion in emotional_impact:
		total_impact += abs(emotional_impact[emotion])
	return total_impact >= 10.0  # Threshold for high impact

# Debug Methods

func get_debug_info() -> Dictionary:
	"""Get debug information about choice button"""
	return {
		"choice_index": choice_index,
		"has_impact": has_emotional_impact(),
		"total_impact": get_total_impact(),
		"is_high_impact": is_high_impact_choice(),
		"impact_data": emotional_impact,
		"button_text": text
	}

func debug_print_state() -> void:
	"""Print current choice button state (debug only)"""
	if OS.is_debug_build():
		print("ChoiceButton Debug State: ", get_debug_info())