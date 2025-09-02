extends Node

func _ready() -> void:
    print("Input debug helper ready")

func _input(event: InputEvent) -> void:
    if event is InputEventKey and event.pressed:
        print("INPUT DEBUG: Key pressed - ", event.keycode, " (", char(event.keycode), ")")

func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventKey and event.pressed:
        print("UNHANDLED INPUT DEBUG: Key - ", event.keycode, " (", char(event.keycode), ")")