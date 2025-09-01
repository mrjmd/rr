class_name PlayerController
extends CharacterBody2D
## Top-down RPG player controller with state machine integration and emotional state support

# Constants - Top-down movement speeds
const WALK_SPEED: float = 200.0
const RUN_SPEED: float = 350.0
const ACCELERATION: float = 800.0
const FRICTION: float = 1200.0

# Signals
signal emotional_state_changed(new_state: String)
signal player_moved(direction: Vector2)
signal player_direction_changed(new_direction: Vector2)

# Export variables for tweaking in editor
@export var walk_speed_multiplier: float = 1.0
@export var run_speed_multiplier: float = 1.0
@export var enable_debug_movement: bool = true

# Node references
@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var state_machine: StateMachine = $StateMachine

# Movement state - Top-down
var movement_input: Vector2 = Vector2.ZERO
var movement_direction: Vector2 = Vector2.ZERO
var facing_direction: Vector2 = Vector2.DOWN  # Default facing down like classic RPGs
var is_running: bool = false

# Emotional integration
var emotional_state: EmotionalState
var last_emotional_state: String = "calm"

func _ready() -> void:
	add_to_group("player")
	_setup_emotional_integration()
	_connect_signals()
	
	if OS.is_debug_build():
		print("PlayerController initialized (Top-Down RPG)")

func _physics_process(delta: float) -> void:
	_handle_input()
	_handle_movement(delta)
	_update_sprite_direction()
	
	# Apply movement
	move_and_slide()

func _unhandled_input(event: InputEvent) -> void:
	if enable_debug_movement:
		_handle_debug_input(event)

func _handle_input() -> void:
	# Get 8-directional input
	movement_input = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	# Check if running
	is_running = Input.is_action_pressed("run")

func _handle_movement(delta: float) -> void:
	var target_speed: float = RUN_SPEED if is_running else WALK_SPEED
	target_speed *= walk_speed_multiplier if not is_running else run_speed_multiplier
	
	if movement_input != Vector2.ZERO:
		# Normalize diagonal movement to prevent faster diagonal movement
		var normalized_input = movement_input.normalized()
		
		# Update facing direction for sprite
		facing_direction = normalized_input
		movement_direction = normalized_input
		
		# Accelerate towards target velocity
		velocity = velocity.move_toward(normalized_input * target_speed, ACCELERATION * delta)
		
		player_moved.emit(movement_direction)
		player_direction_changed.emit(facing_direction)
	else:
		# Apply friction when not moving
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
		movement_direction = Vector2.ZERO

func _update_sprite_direction() -> void:
	# 8-directional sprite facing for top-down view
	if facing_direction != Vector2.ZERO:
		# Determine primary direction for sprite orientation
		if abs(facing_direction.x) > abs(facing_direction.y):
			# Horizontal movement takes priority
			if facing_direction.x > 0:
				sprite.flip_h = false  # Facing right
			else:
				sprite.flip_h = true   # Facing left
		else:
			# Vertical movement - don't flip horizontally
			pass  # Could add separate animations for up/down if needed

# Top-down specific methods
func get_current_speed() -> float:
	return velocity.length()

func get_max_speed() -> float:
	var base_speed = RUN_SPEED if is_running else WALK_SPEED
	return base_speed * (run_speed_multiplier if is_running else walk_speed_multiplier)

func _setup_emotional_integration() -> void:
	# Access emotional state through GameManager
	if GameManager and GameManager.emotional_state:
		emotional_state = GameManager.emotional_state
		# Connect to emotional state changes
		if emotional_state and emotional_state.has_signal("state_changed"):
			emotional_state.state_changed.connect(_on_emotional_state_changed)
	else:
		# Create fallback emotional state dynamically
		var EmotionalStateClass = load("res://src/resources/emotional_state.gd")
		if EmotionalStateClass:
			emotional_state = EmotionalStateClass.new()
			if emotional_state and emotional_state.has_signal("state_changed"):
				emotional_state.state_changed.connect(_on_emotional_state_changed)

func _connect_signals() -> void:
	# Connect to EventBus if available
	if EventBus:
		player_moved.connect(func(dir): EventBus.player_moved.emit(dir))
		player_direction_changed.connect(func(dir): EventBus.player_direction_changed.emit(dir))
	
	# Connect to state machine transitions
	if state_machine:
		state_machine.state_changed.connect(_on_player_state_changed)

func _on_emotional_state_changed(new_state: String) -> void:
	if new_state != last_emotional_state:
		last_emotional_state = new_state
		emotional_state_changed.emit(new_state)
		_update_movement_based_on_emotion(new_state)

func _update_movement_based_on_emotion(emotion_state: String) -> void:
	# Adjust movement speeds based on emotional state
	match emotion_state:
		"calm":
			walk_speed_multiplier = 1.0
			run_speed_multiplier = 1.0
		"stressed":
			walk_speed_multiplier = 1.1
			run_speed_multiplier = 1.2
		"overwhelmed":
			walk_speed_multiplier = 0.7
			run_speed_multiplier = 0.8
		"angry":
			walk_speed_multiplier = 1.4
			run_speed_multiplier = 1.6
		"breaking":
			walk_speed_multiplier = 0.5
			run_speed_multiplier = 0.6
		"suppressed":
			walk_speed_multiplier = 0.8
			run_speed_multiplier = 0.9

func _on_player_state_changed(from_state: String, to_state: String) -> void:
	if OS.is_debug_build():
		print("Player state changed: ", from_state, " -> ", to_state)

func _handle_debug_input(event: InputEvent) -> void:
	# Debug controls for testing emotional states
	if event.is_action_pressed("debug_increase_rage"):
		if emotional_state:
			emotional_state.increase_rage(10.0)
	elif event.is_action_pressed("debug_suppress"):
		if emotional_state:
			emotional_state.suppress_rage()
	elif event.is_action_pressed("debug_overwhelm"):
		if emotional_state:
			emotional_state.increase_overwhelm(10.0)

# Public API methods
func get_movement_direction() -> Vector2:
	return movement_direction

func get_movement_input() -> Vector2:
	return movement_input

func get_facing_direction() -> Vector2:
	return facing_direction

func is_moving() -> bool:
	return velocity.length() > 10.0

func is_player_running() -> bool:
	return is_running and is_moving()

func get_current_emotional_state() -> String:
	if emotional_state:
		return emotional_state.get_state_description()
	return "calm"

func force_emotional_state(state: String) -> void:
	if emotional_state:
		# Convert string to enum value
		match state.to_lower():
			"calm":
				emotional_state.reset()
			"stressed":
				emotional_state.rage_level = 30.0
			"overwhelmed":
				emotional_state.overwhelm_level = 60.0
			"angry":
				emotional_state.rage_level = 80.0
			"breaking":
				emotional_state.rage_level = 95.0

# Called by external systems to trigger specific behaviors
func trigger_rage_increase(amount: float) -> void:
	if emotional_state:
		emotional_state.increase_rage(amount)

func trigger_suppression() -> void:
	if emotional_state:
		emotional_state.suppress_rage()

func set_movement_enabled(enabled: bool) -> void:
	set_physics_process(enabled)
	if not enabled:
		velocity = Vector2.ZERO
