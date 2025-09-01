class_name TextAnimator
extends Node
## Handles text animation effects for dialogue system

# Signals
signal typing_completed
signal character_typed(character: String)

# Animation properties
var typing_speed: float = 30.0  # Characters per second
var current_tween: Tween
var is_animating: bool = false
var current_text_label: RichTextLabel
var full_text: String = ""
var current_index: int = 0

# Sound effects (placeholder for future audio integration)
var typing_sound_enabled: bool = true
var typing_sound_pitch: float = 1.0

func _ready() -> void:
	if OS.is_debug_build():
		print("TextAnimator initialized")

# Public API Methods

func animate_typing(text_label: RichTextLabel, text: String, speed: float = 30.0) -> void:
	"""Start typing animation for given text"""
	if is_animating:
		stop_animation()
	
	current_text_label = text_label
	full_text = text
	typing_speed = max(1.0, speed)
	current_index = 0
	is_animating = true
	
	# Clear the label initially
	if current_text_label:
		current_text_label.text = ""
	
	# Start typing animation
	_start_typing()
	
	if OS.is_debug_build():
		print("TextAnimator: Starting animation for text length: ", text.length(), " at speed: ", speed)

func stop_animation() -> void:
	"""Stop current animation"""
	if current_tween and current_tween.is_valid():
		current_tween.kill()
	
	is_animating = false
	
	# Show full text immediately
	if current_text_label and full_text != "":
		current_text_label.text = full_text
	
	if OS.is_debug_build():
		print("TextAnimator: Animation stopped")

func skip_to_end() -> void:
	"""Skip animation and show full text immediately"""
	stop_animation()
	typing_completed.emit()

func pause_animation() -> void:
	"""Pause the current animation"""
	if current_tween and current_tween.is_valid():
		current_tween.pause()

func resume_animation() -> void:
	"""Resume paused animation"""
	if current_tween and current_tween.is_valid():
		current_tween.play()

func set_typing_speed(speed: float) -> void:
	"""Set typing speed in characters per second"""
	typing_speed = max(1.0, speed)

func is_typing() -> bool:
	"""Check if animation is currently running"""
	return is_animating

# Internal Methods

func _start_typing() -> void:
	"""Internal method to start the typing animation"""
	if not current_text_label or full_text == "":
		_complete_animation()
		return
	
	current_tween = create_tween()
	current_tween.set_process_mode(Tween.TWEEN_PROCESS_IDLE)
	
	# Calculate timing for each character
	var char_delay = 1.0 / typing_speed
	
	# Animate each character
	for i in range(full_text.length()):
		current_tween.tween_callback(_add_character.bind(i)).set_delay(i * char_delay)
	
	# Complete animation after all characters
	current_tween.tween_callback(_complete_animation).set_delay(full_text.length() * char_delay)

func _add_character(index: int) -> void:
	"""Add a single character to the display"""
	if not is_animating or not current_text_label:
		return
	
	if index >= full_text.length():
		_complete_animation()
		return
	
	current_index = index
	var partial_text = full_text.substr(0, index + 1)
	current_text_label.text = partial_text
	
	# Emit character typed signal
	var character = full_text[index]
	character_typed.emit(character)
	
	# Play typing sound effect (placeholder)
	_play_typing_sound(character)

func _complete_animation() -> void:
	"""Complete the typing animation"""
	is_animating = false
	
	# Ensure full text is displayed
	if current_text_label and full_text != "":
		current_text_label.text = full_text
	
	# Clean up
	current_text_label = null
	full_text = ""
	current_index = 0
	
	# Emit completion signal
	typing_completed.emit()
	
	if OS.is_debug_build():
		print("TextAnimator: Animation completed")

func _play_typing_sound(character: String) -> void:
	"""Play typing sound effect (placeholder for future implementation)"""
	if not typing_sound_enabled:
		return
	
	# Placeholder for audio implementation
	# Different sounds could be played for different character types
	# For example: punctuation, vowels, consonants, etc.
	
	# This would integrate with the AudioManager when sound is implemented
	# AudioManager.play_sfx("typing_" + _get_character_type(character))
	pass

func _get_character_type(character: String) -> String:
	"""Get character type for sound variation (placeholder)"""
	if character in ".!?":
		return "punctuation"
	elif character in "aeiouAEIOU":
		return "vowel"
	elif character == " ":
		return "space"
	else:
		return "consonant"

# Advanced Animation Effects (for future enhancement)

func animate_with_effect(text_label: RichTextLabel, text: String, effect_type: String, speed: float = 30.0) -> void:
	"""Animate text with special effects"""
	match effect_type:
		"normal":
			animate_typing(text_label, text, speed)
		"wave":
			_animate_wave_effect(text_label, text, speed)
		"shake":
			_animate_shake_effect(text_label, text, speed)
		"fade":
			_animate_fade_effect(text_label, text, speed)
		_:
			animate_typing(text_label, text, speed)

func _animate_wave_effect(text_label: RichTextLabel, text: String, speed: float) -> void:
	"""Animate text with wave effect (placeholder for future implementation)"""
	# This would create a wave motion for characters as they appear
	animate_typing(text_label, text, speed)

func _animate_shake_effect(text_label: RichTextLabel, text: String, speed: float) -> void:
	"""Animate text with shake effect (placeholder for future implementation)"""
	# This would create a shaking effect, useful for angry dialogue
	animate_typing(text_label, text, speed)

func _animate_fade_effect(text_label: RichTextLabel, text: String, speed: float) -> void:
	"""Animate text with fade effect (placeholder for future implementation)"""
	# This would fade in characters instead of just appearing
	animate_typing(text_label, text, speed)

# Rich Text Support

func animate_rich_text(text_label: RichTextLabel, rich_text: String, speed: float = 30.0) -> void:
	"""Animate rich text with BBCode support"""
	# Parse BBCode tags and animate accordingly
	var clean_text = _strip_bbcode(rich_text)
	
	# For now, animate the clean text and then apply formatting
	animate_typing(text_label, clean_text, speed)
	
	# Future enhancement: Animate while preserving BBCode formatting
	await typing_completed
	
	# Apply rich text formatting after animation completes
	if current_text_label:
		current_text_label.text = rich_text

func _strip_bbcode(rich_text: String) -> String:
	"""Strip BBCode tags from text for length calculation"""
	var regex = RegEx.new()
	regex.compile("\\[/?\\w+[^\\]]*\\]")
	return regex.sub(rich_text, "", true)

# Speed Control Methods

func set_speed_multiplier(multiplier: float) -> void:
	"""Set speed multiplier for current animation"""
	var new_speed = typing_speed * multiplier
	typing_speed = max(1.0, new_speed)
	
	# If animation is running, adjust tween speed
	if current_tween and current_tween.is_valid():
		current_tween.set_speed_scale(multiplier)

func speed_up() -> void:
	"""Increase typing speed"""
	set_speed_multiplier(2.0)

func slow_down() -> void:
	"""Decrease typing speed"""
	set_speed_multiplier(0.5)

func reset_speed() -> void:
	"""Reset to default speed"""
	typing_speed = 30.0
	if current_tween and current_tween.is_valid():
		current_tween.set_speed_scale(1.0)

# Utility Methods

func get_animation_progress() -> float:
	"""Get current animation progress (0.0 to 1.0)"""
	if not is_animating or full_text == "":
		return 1.0
	
	return float(current_index) / float(full_text.length())

func get_remaining_time() -> float:
	"""Get estimated remaining time for animation"""
	if not is_animating or full_text == "":
		return 0.0
	
	var remaining_chars = full_text.length() - current_index
	return remaining_chars / typing_speed

# Debug Methods

func get_debug_info() -> Dictionary:
	"""Get debug information about animation state"""
	return {
		"is_animating": is_animating,
		"typing_speed": typing_speed,
		"current_index": current_index,
		"full_text_length": full_text.length(),
		"progress": get_animation_progress(),
		"remaining_time": get_remaining_time(),
		"has_tween": current_tween != null and current_tween.is_valid()
	}

func debug_print_state() -> void:
	"""Print current animation state (debug only)"""
	if OS.is_debug_build():
		print("TextAnimator Debug State: ", get_debug_info())