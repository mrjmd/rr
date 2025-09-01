extends Control
## Simple test scene to verify transitions are working

@onready var back_button: Button = $VBoxContainer/BackButton

func _ready() -> void:
	print("Simple test scene loaded!")
	back_button.pressed.connect(_on_back_pressed)
	
	# Visual feedback that we're in a different scene
	modulate = Color(1, 1, 1, 0)
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.3)

func _on_back_pressed() -> void:
	print("Going back to transition demo...")
	# Use the actual scene path for the demo
	var demo_scene = load("res://src/scenes/shared/transition_demo.tscn")
	get_tree().change_scene_to_packed(demo_scene)