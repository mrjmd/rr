extends Node
## Test script to demonstrate fade transition usage

# Example of how to use the new fade transition system

func _ready() -> void:
	# Wait a moment then demonstrate transitions
	await get_tree().create_timer(2.0).timeout
	_demonstrate_transitions()

func _demonstrate_transitions() -> void:
	print("=== Fade Transition System Demo ===")
	
	# Example 1: Transition using scene key
	print("1. Transitioning to test scene with 1.0 second fade...")
	SceneManager.transition_to_scene("test_scene", 1.0)
	
	# Wait for transition to complete
	await get_tree().create_timer(3.0).timeout
	
	# Example 2: Transition using PackedScene
	print("2. Loading scene directly...")
	var scene_to_load = preload("res://src/scenes/shared/test_scene.tscn")
	SceneManager.transition_to_packed(scene_to_load, 0.75)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		print("Testing fade transition...")
		SceneManager.transition_to_scene("test_scene")
	
	if event.is_action_pressed("ui_cancel"):
		print("Testing fast fade...")
		SceneManager.transition_to_scene("test_scene", 0.2)

## Manual fade transition example
func _create_manual_fade() -> void:
	# You can also use the FadeTransition directly
	var fade_scene = preload("res://src/scenes/transitions/fade_transition.tscn")
	var fade = fade_scene.instantiate()
	
	get_tree().root.add_child(fade)
	
	# Customize the transition
	fade.set_fade_duration(0.8)
	fade.set_fade_color(Color.RED)
	
	# Connect signals
	fade.fade_in_completed.connect(_on_fade_in_complete)
	fade.transition_completed.connect(_on_transition_complete)
	
	# Start transition
	fade.transition()

func _on_fade_in_complete() -> void:
	print("Fade in completed - screen is now covered")

func _on_transition_complete() -> void:
	print("Full transition completed - screen is now revealed")