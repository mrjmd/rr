class_name PlayerWalkState
extends State
## Player walking state - when player is moving at normal speed in top-down view

@onready var player: PlayerController = get_owner()

func enter() -> void:
	if OS.is_debug_build():
		print("Entered Walk state")
	
	# Play walk animation if available
	if player.animation_player and player.animation_player.has_animation("walk"):
		player.animation_player.play("walk")

func physics_update(_delta: float) -> void:
	if not player:
		return
	
	# Check if stopped moving
	if player.get_movement_input() == Vector2.ZERO:
		transition_to("PlayerIdleState")
	# Check if started running
	elif player.is_running:
		transition_to("PlayerRunState")

func handle_input(event: InputEvent) -> void:
	# Handle run toggle
	if event.is_action_pressed("run") and player.get_movement_input() != Vector2.ZERO:
		transition_to("PlayerRunState")

func exit() -> void:
	pass
