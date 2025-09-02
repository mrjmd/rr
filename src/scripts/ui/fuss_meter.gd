extends Control
class_name FussMeter

# UI Elements
@onready var progress_bar: ProgressBar = $VBoxContainer/FussProgressBar
@onready var label: Label = $VBoxContainer/FussLabel

# Fuss meter properties
@export var max_fuss_time: float = 10.0  # Time to reach maximum fuss when baby is alone
@export var recovery_time: float = 2.0   # Time to fully recover when baby is carried
@export var fuss_value: float = 0.0      # Current fuss level (0.0 to 100.0)

# State tracking
var baby_is_alone: bool = true
var fuss_timer: float = 0.0

# Visual feedback colors
const COLOR_CONTENT: Color = Color.GREEN      # 0-33% fuss
const COLOR_GETTING_FUSSY: Color = Color.YELLOW  # 34-66% fuss  
const COLOR_VERY_FUSSY: Color = Color.RED    # 67-100% fuss

signal fuss_level_changed(new_level: float)
signal baby_very_fussy  # Emitted when fuss reaches critical level

func _ready() -> void:
	print("FussMeter initialized")
	print("FussMeter position: ", position)
	print("FussMeter size: ", size)
	print("FussMeter visible: ", visible)
	
	# Add to group so frustration meter can find us
	add_to_group("fuss_meters")
	
	# Initialize UI
	if label:
		label.text = "Baby Fuss Level"
		print("Label found and initialized: ", label.text)
	else:
		print("ERROR: Label not found!")
	
	if progress_bar:
		progress_bar.min_value = 0.0
		progress_bar.max_value = 100.0
		progress_bar.value = fuss_value
		_update_visual_feedback()
		print("ProgressBar initialized - value: ", progress_bar.value)
	else:
		print("ERROR: ProgressBar not found!")
	
	# Connect to player signals if available
	_connect_to_player()

func _connect_to_player() -> void:
	# Look for player in scene and connect to baby state changes
	await get_tree().process_frame  # Wait for scene to be fully loaded
	
	var players = get_tree().get_nodes_in_group("players")
	if players.size() > 0:
		var player = players[0]
		# We'll manually monitor the player's holding_baby state
		print("FussMeter found player, will monitor baby state")
	else:
		print("FussMeter: No player found in scene")

func _process(delta: float) -> void:
	# Check player's baby carrying state
	_update_baby_state()
	
	# Update fuss level based on state
	_update_fuss_level(delta)
	
	# Update UI display
	_update_ui_display()

func _update_baby_state() -> void:
	# Find player and check if holding baby
	var players = get_tree().get_nodes_in_group("players")
	if players.size() > 0:
		var player = players[0]
		if player.has_method("get") and player.get("holding_baby") != null:
			var new_alone_state = not player.holding_baby
			if new_alone_state != baby_is_alone:
				baby_is_alone = new_alone_state
				print("FussMeter: Baby state changed - alone: ", baby_is_alone)

func _update_fuss_level(delta: float) -> void:
	var old_fuss = fuss_value
	
	if baby_is_alone:
		# Baby is alone - increase fuss over time
		var fuss_increase_rate = (100.0 / max_fuss_time) * delta
		fuss_value = min(100.0, fuss_value + fuss_increase_rate)
	else:
		# Baby is being carried - decrease fuss quickly
		var fuss_decrease_rate = (100.0 / recovery_time) * delta
		fuss_value = max(0.0, fuss_value - fuss_decrease_rate)
	
	# Debug output when fuss level changes significantly
	if abs(fuss_value - old_fuss) > 1.0:
		print("FussMeter: Fuss level changed from ", old_fuss, " to ", fuss_value, " (baby alone: ", baby_is_alone, ")")
	
	# Emit signals for level changes
	fuss_level_changed.emit(fuss_value)
	
	# Check for critical fuss level
	if fuss_value >= 90.0 and baby_is_alone:
		baby_very_fussy.emit()

func _update_ui_display() -> void:
	if progress_bar:
		progress_bar.value = fuss_value
		_update_visual_feedback()
	
	# Optional: Update label with percentage
	if label:
		var fuss_percentage = int(fuss_value)
		label.text = "Baby Fuss Level: " + str(fuss_percentage) + "%"

func _update_visual_feedback() -> void:
	if not progress_bar:
		return
	
	# Change progress bar color based on fuss level
	var style_box = progress_bar.get_theme_stylebox("fill")
	
	if fuss_value <= 33.0:
		progress_bar.modulate = COLOR_CONTENT
	elif fuss_value <= 66.0:
		progress_bar.modulate = COLOR_GETTING_FUSSY
	else:
		progress_bar.modulate = COLOR_VERY_FUSSY

# Public methods for external control
func set_baby_alone(alone: bool) -> void:
	baby_is_alone = alone
	print("FussMeter: Manually set baby alone state: ", alone)

func get_fuss_level() -> float:
	return fuss_value

func reset_fuss() -> void:
	fuss_value = 0.0
	print("FussMeter: Fuss level reset to 0")