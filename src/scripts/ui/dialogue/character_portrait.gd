class_name CharacterPortrait
extends Control
## Character portrait display for dialogue system

# Signals
signal portrait_shown(character_name: String)
signal portrait_hidden
signal animation_completed

# Node references
@onready var portrait_sprite: TextureRect = $PortraitContainer/PortraitSprite
@onready var portrait_container: Control = $PortraitContainer
@onready var character_name_label: Label = $NameLabel

# Portrait positioning
enum PortraitPosition {
	LEFT,
	RIGHT,
	CENTER
}

# Export properties
@export var portrait_position: PortraitPosition = PortraitPosition.LEFT
@export var show_character_name: bool = true
@export var fade_duration: float = 0.3
@export var slide_duration: float = 0.4
@export var default_portrait_size: Vector2 = Vector2(150, 200)

# Portrait state
var current_character: String = ""
var is_visible: bool = false
var character_portraits: Dictionary = {}
var current_texture: Texture2D

# Animation tweens
var fade_tween: Tween
var slide_tween: Tween
var scale_tween: Tween

func _ready() -> void:
	# Set up initial positioning
	_setup_positioning()
	
	# Load placeholder portraits
	_load_placeholder_portraits()
	
	# Initialize components
	_initialize_components()
	
	# Set initial state
	visible = false
	is_visible = false
	
	if OS.is_debug_build():
		print("CharacterPortrait initialized at position: ", PortraitPosition.keys()[portrait_position])

func _setup_positioning() -> void:
	"""Configure portrait positioning based on export setting"""
	match portrait_position:
		PortraitPosition.LEFT:
			set_anchors_and_offsets_preset(Control.PRESET_CENTER_LEFT)
			anchor_left = 0.05
			anchor_right = 0.25
		PortraitPosition.RIGHT:
			set_anchors_and_offsets_preset(Control.PRESET_CENTER_RIGHT)
			anchor_left = 0.75
			anchor_right = 0.95
		PortraitPosition.CENTER:
			set_anchors_and_offsets_preset(Control.PRESET_CENTER)
			anchor_left = 0.4
			anchor_right = 0.6
	
	anchor_top = 0.2
	anchor_bottom = 0.8

func _load_placeholder_portraits() -> void:
	"""Load placeholder portraits for testing"""
	# Create placeholder textures for common characters
	character_portraits = {
		"Rando": _create_placeholder_texture(Color.CYAN, "R"),
		"Family Member": _create_placeholder_texture(Color.GREEN, "F"),
		"Friend": _create_placeholder_texture(Color.YELLOW, "FR"),
		"Stranger": _create_placeholder_texture(Color.RED, "S"),
		"Therapist": _create_placeholder_texture(Color.PURPLE, "T"),
		"Default": _create_placeholder_texture(Color.GRAY, "?")
	}

func _create_placeholder_texture(color: Color, initial: String) -> ImageTexture:
	"""Create a placeholder portrait texture with colored background and initial"""
	var image = Image.create(150, 200, false, Image.FORMAT_RGBA8)
	image.fill(color)
	
	# Add darker border
	var border_color = color.darkened(0.3)
	# Simple border drawing (this is a placeholder - in a real game you'd use proper portrait assets)
	for x in range(image.get_width()):
		for y in range(image.get_height()):
			if x < 5 or x >= image.get_width() - 5 or y < 5 or y >= image.get_height() - 5:
				image.set_pixel(x, y, border_color)
	
	var texture = ImageTexture.new()
	texture.set_image(image)
	return texture

func _initialize_components() -> void:
	"""Initialize portrait components"""
	# Configure portrait sprite
	if portrait_sprite:
		portrait_sprite.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
		portrait_sprite.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	
	# Configure name label
	if character_name_label:
		character_name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		character_name_label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
		character_name_label.add_theme_font_size_override("font_size", 16)
		character_name_label.modulate = Color(0.9, 0.9, 1.0, 1.0)
		
		# Position name label below portrait
		character_name_label.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
		character_name_label.anchor_top = 1.0
		character_name_label.anchor_bottom = 1.1
		character_name_label.visible = show_character_name
	
	# Set up portrait container
	if portrait_container:
		portrait_container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

# Public API Methods

func show_portrait(character_name: String, animate: bool = true) -> void:
	"""Show portrait for specified character"""
	if current_character == character_name and is_visible:
		return  # Already showing this character
	
	# Get portrait texture
	var portrait_texture = character_portraits.get(character_name, character_portraits["Default"])
	
	# Set character data
	current_character = character_name
	current_texture = portrait_texture
	
	# Update portrait sprite
	if portrait_sprite:
		portrait_sprite.texture = portrait_texture
	
	# Update name label
	if character_name_label and show_character_name:
		character_name_label.text = character_name
	
	# Show portrait
	if animate:
		_animate_show()
	else:
		_show_immediately()
	
	if OS.is_debug_build():
		print("CharacterPortrait: Showing portrait for '", character_name, "'")

func hide_portrait(animate: bool = true) -> void:
	"""Hide the current portrait"""
	if not is_visible:
		return
	
	if animate:
		_animate_hide()
	else:
		_hide_immediately()
	
	if OS.is_debug_build():
		print("CharacterPortrait: Hiding portrait")

func change_portrait(new_character: String, animate: bool = true) -> void:
	"""Change to a different character portrait"""
	if is_visible:
		# Hide current, then show new
		if animate:
			hide_portrait(true)
			await animation_completed
		else:
			hide_portrait(false)
	
	show_portrait(new_character, animate)

func set_portrait_position(position: PortraitPosition) -> void:
	"""Change portrait position"""
	portrait_position = position
	_setup_positioning()

func pulse_attention() -> void:
	"""Pulse animation to draw attention to speaker"""
	if not is_visible:
		return
	
	scale_tween = create_tween()
	scale_tween.set_loops(2)
	scale_tween.tween_property(self, "scale", Vector2(1.1, 1.1), 0.3)
	scale_tween.tween_property(self, "scale", Vector2.ONE, 0.3)

func emotional_reaction(emotion: String) -> void:
	"""Play emotional reaction animation"""
	if not is_visible:
		return
	
	match emotion.to_lower():
		"happy":
			_bounce_animation()
		"angry":
			_shake_animation()
		"sad":
			_fade_animation()
		"surprised":
			_scale_pop_animation()
		_:
			pulse_attention()

# Animation Methods

func _animate_show() -> void:
	"""Animate showing the portrait"""
	# Stop any existing animations
	_stop_animations()
	
	# Set initial state
	visible = true
	modulate = Color.TRANSPARENT
	
	# Slide in from side
	var start_offset = Vector2()
	match portrait_position:
		PortraitPosition.LEFT:
			start_offset = Vector2(-200, 0)
		PortraitPosition.RIGHT:
			start_offset = Vector2(200, 0)
		PortraitPosition.CENTER:
			start_offset = Vector2(0, -100)
	
	position += start_offset
	
	# Create animation sequence
	fade_tween = create_tween()
	fade_tween.set_parallel(true)  # Allow multiple properties to animate simultaneously
	
	# Fade in
	fade_tween.tween_property(self, "modulate", Color.WHITE, fade_duration)
	
	# Slide in
	fade_tween.tween_property(self, "position", position - start_offset, slide_duration)
	
	await fade_tween.finished
	
	is_visible = true
	portrait_shown.emit(current_character)
	animation_completed.emit()

func _animate_hide() -> void:
	"""Animate hiding the portrait"""
	if not is_visible:
		return
	
	# Stop any existing animations
	_stop_animations()
	
	# Create fade out animation
	fade_tween = create_tween()
	fade_tween.set_parallel(true)
	
	# Fade out
	fade_tween.tween_property(self, "modulate", Color.TRANSPARENT, fade_duration)
	
	# Slide out
	var end_offset = Vector2()
	match portrait_position:
		PortraitPosition.LEFT:
			end_offset = Vector2(-200, 0)
		PortraitPosition.RIGHT:
			end_offset = Vector2(200, 0)
		PortraitPosition.CENTER:
			end_offset = Vector2(0, 100)
	
	fade_tween.tween_property(self, "position", position + end_offset, slide_duration)
	
	await fade_tween.finished
	
	_hide_immediately()
	animation_completed.emit()

func _show_immediately() -> void:
	"""Show portrait without animation"""
	visible = true
	modulate = Color.WHITE
	is_visible = true
	portrait_shown.emit(current_character)

func _hide_immediately() -> void:
	"""Hide portrait without animation"""
	visible = false
	is_visible = false
	current_character = ""
	portrait_hidden.emit()

# Emotional Reaction Animations

func _bounce_animation() -> void:
	"""Happy bounce animation"""
	scale_tween = create_tween()
	scale_tween.tween_property(self, "scale", Vector2(1.2, 0.8), 0.1)
	scale_tween.tween_property(self, "scale", Vector2(0.9, 1.1), 0.1)
	scale_tween.tween_property(self, "scale", Vector2.ONE, 0.2)

func _shake_animation() -> void:
	"""Angry shake animation"""
	var original_position = position
	scale_tween = create_tween()
	scale_tween.set_loops(6)
	scale_tween.tween_property(self, "position", original_position + Vector2(5, 0), 0.05)
	scale_tween.tween_property(self, "position", original_position + Vector2(-5, 0), 0.05)
	scale_tween.tween_callback(func(): position = original_position)

func _fade_animation() -> void:
	"""Sad fade animation"""
	scale_tween = create_tween()
	scale_tween.tween_property(self, "modulate", Color(0.7, 0.7, 0.9, 0.8), 0.5)
	scale_tween.tween_property(self, "modulate", Color.WHITE, 0.5)

func _scale_pop_animation() -> void:
	"""Surprised pop animation"""
	scale_tween = create_tween()
	scale_tween.tween_property(self, "scale", Vector2(1.3, 1.3), 0.1)
	scale_tween.tween_property(self, "scale", Vector2.ONE, 0.3)

func _stop_animations() -> void:
	"""Stop all running animations"""
	if fade_tween and fade_tween.is_valid():
		fade_tween.kill()
	if slide_tween and slide_tween.is_valid():
		slide_tween.kill()
	if scale_tween and scale_tween.is_valid():
		scale_tween.kill()

# Portrait Management

func add_portrait(character_name: String, texture: Texture2D) -> void:
	"""Add a custom portrait texture for a character"""
	character_portraits[character_name] = texture
	
	if OS.is_debug_build():
		print("CharacterPortrait: Added portrait for '", character_name, "'")

func remove_portrait(character_name: String) -> void:
	"""Remove a character portrait"""
	if character_name in character_portraits:
		character_portraits.erase(character_name)

func has_portrait(character_name: String) -> bool:
	"""Check if portrait exists for character"""
	return character_name in character_portraits

func get_available_characters() -> Array:
	"""Get list of available character portraits"""
	return character_portraits.keys()

# Configuration Methods

func set_show_name(show_name: bool) -> void:
	"""Set whether to show character name"""
	show_character_name = show_name
	if character_name_label:
		character_name_label.visible = show_name

func set_fade_duration(duration: float) -> void:
	"""Set fade animation duration"""
	fade_duration = max(0.1, duration)

func set_slide_duration(duration: float) -> void:
	"""Set slide animation duration"""
	slide_duration = max(0.1, duration)

func set_portrait_size(size: Vector2) -> void:
	"""Set portrait display size"""
	default_portrait_size = size
	if portrait_sprite:
		portrait_sprite.custom_minimum_size = size

# Utility Methods

func is_portrait_visible() -> bool:
	"""Check if portrait is currently visible"""
	return is_visible

func get_current_character() -> String:
	"""Get the name of currently displayed character"""
	return current_character

func get_portrait_texture(character_name: String) -> Texture2D:
	"""Get portrait texture for character"""
	return character_portraits.get(character_name, character_portraits["Default"])

# Debug Methods

func get_debug_info() -> Dictionary:
	"""Get debug information about portrait state"""
	return {
		"is_visible": is_visible,
		"current_character": current_character,
		"position": PortraitPosition.keys()[portrait_position],
		"show_name": show_character_name,
		"available_characters": character_portraits.keys(),
		"has_texture": current_texture != null
	}

func debug_print_state() -> void:
	"""Print current portrait state (debug only)"""
	if OS.is_debug_build():
		print("CharacterPortrait Debug State: ", get_debug_info())

func debug_test_portraits() -> void:
	"""Test all available portraits (debug only)"""
	if not OS.is_debug_build():
		return
	
	print("CharacterPortrait: Testing all portraits...")
	for character in character_portraits.keys():
		show_portrait(character, true)
		await get_tree().create_timer(2.0).timeout
		hide_portrait(true)
		await animation_completed
		await get_tree().create_timer(0.5).timeout
	print("CharacterPortrait: Portrait test completed")