class_name State
extends Node
## Base class for all states in the state machine pattern

# Reference to the state machine managing this state
var state_machine: StateMachine

# Called when entering this state
func enter() -> void:
	pass

# Called when exiting this state
func exit() -> void:
	pass

# Called every frame when this state is active
func update(_delta: float) -> void:
	pass

# Called every physics frame when this state is active
func physics_update(_delta: float) -> void:
	pass

# Handle input events when this state is active
func handle_input(_event: InputEvent) -> void:
	pass

# Request a transition to another state
func transition_to(state_name: String) -> void:
	if state_machine:
		state_machine.transition_to(state_name)