class_name PlayerIdleState
extends State
## Player idle state - when player is stationary in top-down view

@onready var player: PlayerController = get_owner()

func enter() -> void:
	if OS.is_debug_build():
		print("Entered Idle state")
	
	# Play idle animation if available
	if player.animation_player and player.animation_player.has_animation("idle"):
		player.animation_player.play("idle")

func physics_update(_delta: float) -> void:
	if not player:
		return
	
	# Check for any movement input
	if player.get_movement_input() != Vector2.ZERO:
		# Check if running
		if player.is_running:
			transition_to("PlayerRunState")
		else:
			transition_to("PlayerWalkState")

func handle_input(event: InputEvent) -> void:
	# Handle immediate input responses if needed
	if event.is_action_pressed("run") and player.get_movement_input() != Vector2.ZERO:
		transition_to("PlayerRunState")

func exit() -> void:
	pass
