class_name PlayerRunState
extends State
## Player running state - when player is moving at high speed in top-down view

@onready var player: PlayerController = get_owner()

func enter() -> void:
	if OS.is_debug_build():
		print("Entered Run state")
	
	# Play run animation if available
	if player.animation_player and player.animation_player.has_animation("run"):
		player.animation_player.play("run")

func physics_update(_delta: float) -> void:
	if not player:
		return
	
	# Check if stopped moving
	if player.get_movement_input() == Vector2.ZERO:
		transition_to("PlayerIdleState")
	# Check if stopped running (released run button)
	elif not player.is_running:
		transition_to("PlayerWalkState")

func handle_input(event: InputEvent) -> void:
	# Handle run release
	if event.is_action_released("run") and player.get_movement_input() != Vector2.ZERO:
		transition_to("PlayerWalkState")

func exit() -> void:
	pass
