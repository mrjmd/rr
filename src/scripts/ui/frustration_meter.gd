extends Control
class_name FrustrationMeter

# UI Elements  
@onready var progress_bar: ProgressBar = $VBoxContainer/FrustrationProgressBar
@onready var label: Label = $VBoxContainer/FrustrationLabel

# Frustration meter properties
@export var frustration_value: float = 0.0      # Current frustration level (0.0 to 100.0)
@export var blocked_action_increase: float = 10.0  # Frustration increase per blocked action
@export var high_fuss_increase_rate: float = 2.0   # Frustration per second when baby fuss > 75%
@export var breathe_decrease: float = 20.0         # Frustration decrease when breathing
@export var breathe_cooldown: float = 2.0          # Cooldown between breath actions

# State tracking
var breathe_timer: float = 0.0
var high_fuss_threshold: float = 75.0

# Visual feedback colors
const COLOR_CALM: Color = Color.GREEN       # 0-33% frustration
const COLOR_TENSE: Color = Color.YELLOW     # 34-66% frustration
const COLOR_STRESSED: Color = Color.RED     # 67-100% frustration

# Signals
signal frustration_changed(new_level: float)
signal player_too_stressed  # Emitted when frustration reaches 100%
signal blocked_action_occurred(action_name: String)

func _ready() -> void:
	print("FrustrationMeter initialized")
	print("FrustrationMeter position: ", position)
	print("FrustrationMeter size: ", size)
	
	# Add to group so other systems can find us
	add_to_group("frustration_meters")
	
	# Initialize UI
	if label:
		label.text = "Your Frustration: 0%"
		print("Frustration label found and initialized")
	else:
		print("ERROR: Frustration label not found!")
	
	if progress_bar:
		progress_bar.min_value = 0.0
		progress_bar.max_value = 100.0
		progress_bar.value = frustration_value
		_update_visual_feedback()
		print("Frustration ProgressBar initialized - value: ", progress_bar.value)
	else:
		print("ERROR: Frustration ProgressBar not found!")
	
	# Connect to other systems
	_connect_to_systems()

func _connect_to_systems() -> void:
	await get_tree().process_frame
	
	# Connect to player for blocked actions
	var players = get_tree().get_nodes_in_group("players")
	if players.size() > 0:
		print("FrustrationMeter found player, monitoring for blocked actions")
	else:
		print("FrustrationMeter: No player found in scene")
	
	# Connect to fuss meter
	var fuss_meters = get_tree().get_nodes_in_group("fuss_meters")
	if fuss_meters.size() > 0:
		var fuss_meter = fuss_meters[0]
		if fuss_meter.has_signal("fuss_level_changed"):
			fuss_meter.fuss_level_changed.connect(_on_baby_fuss_changed)
			print("FrustrationMeter connected to fuss meter signals")
	else:
		print("FrustrationMeter: No fuss meter found for connection")

func _process(delta: float) -> void:
	# Update breathe cooldown
	if breathe_timer > 0.0:
		breathe_timer -= delta
	
	# Check for high baby fuss and increase frustration
	_check_high_fuss_frustration(delta)
	
	# Update UI display
	_update_ui_display()

func _input(event: InputEvent) -> void:
	# Handle breathing action (B key)
	if event.is_action_pressed("breathe") and breathe_timer <= 0.0:
		take_deep_breath()

func _check_high_fuss_frustration(delta: float) -> void:
	# Find fuss meter and check if baby fuss is high
	var fuss_meters = get_tree().get_nodes_in_group("fuss_meters")
	if fuss_meters.size() > 0:
		var fuss_meter = fuss_meters[0]
		if fuss_meter.has_method("get_fuss_level"):
			var fuss_level = fuss_meter.get_fuss_level()
			if fuss_level > high_fuss_threshold:
				increase_frustration(high_fuss_increase_rate * delta, "high_baby_fuss")

func increase_frustration(amount: float, reason: String = "") -> void:
	var old_frustration = frustration_value
	frustration_value = min(100.0, frustration_value + amount)
	
	if frustration_value != old_frustration:
		print("FrustrationMeter: Increased by ", amount, " for reason: ", reason, " (now: ", frustration_value, ")")
		frustration_changed.emit(frustration_value)
		
		# Check for game over condition
		if frustration_value >= 100.0:
			player_too_stressed.emit()
			print("🚨 GAME OVER: Player too stressed!")

func decrease_frustration(amount: float, reason: String = "") -> void:
	var old_frustration = frustration_value
	frustration_value = max(0.0, frustration_value - amount)
	
	if frustration_value != old_frustration:
		print("FrustrationMeter: Decreased by ", amount, " for reason: ", reason, " (now: ", frustration_value, ")")
		frustration_changed.emit(frustration_value)

func take_deep_breath() -> void:
	if breathe_timer > 0.0:
		print("FrustrationMeter: Still on breathe cooldown (", breathe_timer, "s remaining)")
		return
	
	decrease_frustration(breathe_decrease, "deep_breathing")
	breathe_timer = breathe_cooldown
	
	# Show feedback to player
	_show_breathing_feedback()
	print("😮‍💨 Player took a deep breath - frustration reduced by ", breathe_decrease)

func _show_breathing_feedback() -> void:
	# Find feedback display and show message
	var feedback_displays = get_tree().get_nodes_in_group("feedback_displays")
	if feedback_displays.size() > 0:
		var feedback = feedback_displays[0]
		if feedback.has_method("show_message"):
			feedback.show_message("Taking a deep breath... (B to breathe)")
	
	# Or display feedback through player controller
	var players = get_tree().get_nodes_in_group("players")
	if players.size() > 0:
		var player = players[0]
		if player.has_method("show_feedback"):
			var cooldown_text = "breathe ready" if breathe_timer <= 0 else "breathe cooldown"
			player.show_feedback("Deep breath taken! (" + cooldown_text + ")")

func _update_ui_display() -> void:
	if progress_bar:
		progress_bar.value = frustration_value
		_update_visual_feedback()
	
	if label:
		var frustration_percentage = int(frustration_value)
		var breathe_status = ""
		if breathe_timer > 0.0:
			breathe_status = " (B: " + str(int(breathe_timer) + 1) + "s)"
		else:
			breathe_status = " (B to breathe)"
		label.text = "Your Frustration: " + str(frustration_percentage) + "%" + breathe_status

func _update_visual_feedback() -> void:
	if not progress_bar:
		return
	
	# Change progress bar color based on frustration level
	if frustration_value <= 33.0:
		progress_bar.modulate = COLOR_CALM
	elif frustration_value <= 66.0:
		progress_bar.modulate = COLOR_TENSE
	else:
		progress_bar.modulate = COLOR_STRESSED

# Signal handlers
func _on_baby_fuss_changed(new_fuss_level: float) -> void:
	# This gets called when baby fuss level changes
	# High fuss increases are handled in _process to be smooth
	pass

func on_blocked_action(action_name: String) -> void:
	"""Called when player tries to do something but is blocked by baby needs"""
	increase_frustration(blocked_action_increase, "blocked_action_" + action_name)
	blocked_action_occurred.emit(action_name)
	print("🚫 Blocked action increased frustration: ", action_name)

# Public methods
func get_frustration_level() -> float:
	return frustration_value

func reset_frustration() -> void:
	frustration_value = 0.0
	print("FrustrationMeter: Frustration level reset to 0")

func set_frustration(value: float) -> void:
	frustration_value = clamp(value, 0.0, 100.0)
	print("FrustrationMeter: Frustration set to ", frustration_value)