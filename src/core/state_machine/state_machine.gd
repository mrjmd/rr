class_name StateMachine
extends Node
## Manages state transitions and updates for a collection of states

# The initial state to enter when ready
@export var initial_state: State

# Current active state
var current_state: State

# Dictionary of all available states
var states: Dictionary = {}

# History of state transitions for debugging
var state_history: Array[String] = []
var max_history_size: int = 10

signal state_changed(from_state: String, to_state: String)

func _ready():
	# Collect all State children
	for child in get_children():
		if child is State:
			states[child.name.to_lower()] = child
			child.state_machine = self
			
			if OS.is_debug_build():
				print("State registered: ", child.name)
	
	# Enter initial state
	if initial_state:
		current_state = initial_state
		current_state.enter()
		state_history.append(current_state.name.to_lower())
	elif states.size() > 0:
		# Fallback to first state if no initial state specified
		var first_state = states.values()[0]
		current_state = first_state
		current_state.enter()
		state_history.append(current_state.name.to_lower())

func _process(delta):
	if current_state:
		current_state.update(delta)

func _physics_process(delta):
	if current_state:
		current_state.physics_update(delta)

func _unhandled_input(event):
	if current_state:
		current_state.handle_input(event)

# Transition to a new state by name
func transition_to(state_name: String) -> void:
	var state_key = state_name.to_lower()
	
	if not state_key in states:
		push_error("State not found: " + state_name)
		return
		
	if current_state == states[state_key]:
		# Already in this state
		return
	
	var previous_state_name = ""
	
	# Exit current state
	if current_state:
		previous_state_name = current_state.name.to_lower()
		current_state.exit()
	
	# Enter new state
	current_state = states[state_key]
	current_state.enter()
	
	# Update history
	state_history.append(state_key)
	if state_history.size() > max_history_size:
		state_history.pop_front()
	
	# Emit signal
	state_changed.emit(previous_state_name, state_key)
	
	if OS.is_debug_build():
		print("State transition: ", previous_state_name, " -> ", state_key)

# Get the name of the current state
func get_current_state_name() -> String:
	if current_state:
		return current_state.name.to_lower()
	return ""

# Check if currently in a specific state
func is_in_state(state_name: String) -> bool:
	return get_current_state_name() == state_name.to_lower()

# Get state history for debugging
func get_state_history() -> Array[String]:
	return state_history

# Force a specific state without transitions (use carefully)
func force_state(state_name: String) -> void:
	var state_key = state_name.to_lower()
	
	if not state_key in states:
		push_error("State not found: " + state_name)
		return
	
	current_state = states[state_key]
	state_history.append(state_key)
