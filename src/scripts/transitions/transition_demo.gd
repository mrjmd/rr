extends Control
## Demo scene for testing the fade transition system

@onready var normal_fade_button: Button = $VBoxContainer/NormalFadeButton
@onready var slow_fade_button: Button = $VBoxContainer/SlowFadeButton
@onready var fast_fade_button: Button = $VBoxContainer/FastFadeButton
@onready var test_scene_button: Button = $VBoxContainer/TestSceneButton

func _ready() -> void:
	# Connect button signals
	normal_fade_button.pressed.connect(_on_normal_fade_pressed)
	slow_fade_button.pressed.connect(_on_slow_fade_pressed)
	fast_fade_button.pressed.connect(_on_fast_fade_pressed)
	test_scene_button.pressed.connect(_on_test_scene_pressed)
	
	print("=== Fade Transition Demo Ready ===")
	print("Available transitions:")
	print("- Normal Fade: 0.5 seconds (default)")
	print("- Slow Fade: 1.5 seconds")
	print("- Fast Fade: 0.2 seconds")
	print("- Switch to Test Scene")

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):  # Space key
		_on_normal_fade_pressed()
	elif event.is_action_pressed("ui_cancel"):  # Escape key
		_on_fast_fade_pressed()
	elif event.is_action_pressed("debug_reload_scene"):  # R key
		print("Reloading scene with fade...")
		SceneManager.reload_current_scene()

func _on_normal_fade_pressed() -> void:
	print("Testing normal fade transition (0.5s)...")
	_demonstrate_fade(0.5)

func _on_slow_fade_pressed() -> void:
	print("Testing slow fade transition (1.5s)...")
	_demonstrate_fade(1.5)

func _on_fast_fade_pressed() -> void:
	print("Testing fast fade transition (0.2s)...")
	_demonstrate_fade(0.2)

func _on_test_scene_pressed() -> void:
	print("Testing full fade cycle (0.75s)...")
	_demonstrate_fade(0.75)
	
func _demonstrate_fade(duration: float) -> void:
	var fade_scene = preload("res://src/scenes/transitions/fade_transition.tscn")
	var fade = fade_scene.instantiate()
	get_tree().root.add_child(fade)
	fade.set_fade_duration(duration)
	fade.transition()
	await fade.transition_completed
	fade.queue_free()
	print("Fade demonstration complete!")

## Demonstrate manual fade transition usage
func _demonstrate_manual_fade() -> void:
	print("Creating manual fade transition...")
	
	# Create fade transition directly
	var fade_scene = preload("res://src/scenes/transitions/fade_transition.tscn")
	var fade = fade_scene.instantiate() as FadeTransition
	
	# Add to scene tree
	get_tree().root.add_child(fade)
	
	# Customize the fade
	fade.set_fade_duration(1.0)
	fade.set_fade_color(Color.BLUE)
	
	# Connect signals for feedback
	fade.fade_in_completed.connect(func(): print("Manual fade in completed!"))
	fade.fade_out_completed.connect(func(): print("Manual fade out completed!"))
	fade.transition_completed.connect(func(): 
		print("Manual transition completed!")
		fade.queue_free()
	)
	
	# Start the complete transition
	fade.transition()

## Example of using PackedScene transition
func _demonstrate_packed_scene_transition() -> void:
	print("Testing PackedScene transition...")
	var packed_scene = preload("res://src/scenes/shared/test_scene.tscn")
	SceneManager.transition_to_packed(packed_scene, 0.8)

func _on_debug_button_pressed() -> void:
	# For testing various transition features
	match randi() % 3:
		0:
			_demonstrate_manual_fade()
		1:
			_demonstrate_packed_scene_transition()
		2:
			# Test with different colors
			var fade = preload("res://src/scenes/transitions/fade_transition.tscn").instantiate()
			get_tree().root.add_child(fade)
			fade.set_fade_color(Color.WHITE)
			fade.set_fade_duration(0.3)
			await fade.fade_in()
			await get_tree().create_timer(0.5).timeout
			await fade.fade_out()
			fade.queue_free()