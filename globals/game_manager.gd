extends Node
## Main game manager handling core game state and data

# Game state
var current_day: int = 1
var current_phase: String = "none"
var game_time: float = 0.0
var is_paused: bool = false
var is_in_dialogue: bool = false
var is_in_minigame: bool = false

# Player data references (will be loaded from resources)
var player_data: Resource
var emotional_state: Resource

# Pattern tracking
var pattern_history: Dictionary = {}
var choice_history: Array = []

# Settings
var settings: Dictionary = {
	"master_volume": 1.0,
	"music_volume": 1.0,
	"sfx_volume": 1.0,
	"text_speed": 1.0,
	"auto_advance": false,
	"skip_seen_dialogue": false,
	"debug_mode": OS.is_debug_build()
}

# Scene flow
const SCENE_ORDER = [
	"airport_montage",
	"parking_garage",
	"car_drive",
	"family_home"
]

func _ready():
	# Set as singleton
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	# Initialize data resources
	_initialize_game_data()
	
	# Connect to critical events
	EventBus.rage_threshold_reached.connect(_on_rage_threshold)
	EventBus.emotional_breaking_point.connect(_on_breaking_point)
	EventBus.pattern_detected.connect(_on_pattern_detected)
	EventBus.game_paused.connect(_on_game_paused)
	EventBus.game_resumed.connect(_on_game_resumed)
	
	if OS.is_debug_build():
		print("GameManager initialized")

func _process(delta):
	if not is_paused:
		game_time += delta

func _initialize_game_data():
	# Load or create player data
	if ResourceLoader.exists("res://src/resources/game_data/player_data.tres"):
		player_data = load("res://src/resources/game_data/player_data.tres")
	else:
		# Create default player data dynamically
		var PlayerDataClass = load("res://src/resources/game_data/player_data.gd")
		if PlayerDataClass:
			player_data = PlayerDataClass.new()
		else:
			player_data = null
		
	# Create emotional state dynamically
	var EmotionalStateClass = load("res://src/resources/emotional_state.gd")
	if EmotionalStateClass:
		emotional_state = EmotionalStateClass.new()
		# Initialize with default values
		if emotional_state:
			emotional_state.rage_level = 0.0
			emotional_state.reservoir_level = 0.0
			emotional_state.overwhelm_level = 0.0
	else:
		emotional_state = null

func _on_rage_threshold():
	print("Rage threshold reached at phase: ", current_phase)
	# Additional logic will be scene-specific

func _on_breaking_point():
	print("Emotional breaking point reached!")
	# Trigger special scene or consequence

func _on_pattern_detected(pattern_type: String):
	if not pattern_type in pattern_history:
		pattern_history[pattern_type] = 0
	pattern_history[pattern_type] += 1
	
	if settings.debug_mode:
		print("Pattern detected: ", pattern_type, " (Count: ", pattern_history[pattern_type], ")")

func _on_game_paused():
	is_paused = true
	get_tree().paused = true

func _on_game_resumed():
	is_paused = false
	get_tree().paused = false

func save_game(save_name: String = "autosave"):
	var save_dict = {
		"current_day": current_day,
		"current_phase": current_phase,
		"game_time": game_time,
		"pattern_history": pattern_history,
		"choice_history": choice_history,
		"settings": settings
	}
	
	# Add emotional state data if available
	if emotional_state:
		save_dict["emotional_data"] = {
			"rage_level": emotional_state.rage_level if "rage_level" in emotional_state else 0,
			"reservoir_level": emotional_state.reservoir_level if "reservoir_level" in emotional_state else 0,
			"overwhelm_level": emotional_state.overwhelm_level if "overwhelm_level" in emotional_state else 0
		}
	
	var save_file = FileAccess.open("user://savegame_" + save_name + ".save", FileAccess.WRITE)
	if save_file:
		save_file.store_var(save_dict)
		save_file.close()
		print("Game saved: ", save_name)
		return true
	return false

func load_game(save_name: String = "autosave"):
	if not FileAccess.file_exists("user://savegame_" + save_name + ".save"):
		print("Save file not found: ", save_name)
		return false
		
	var save_file = FileAccess.open("user://savegame_" + save_name + ".save", FileAccess.READ)
	if save_file:
		var save_dict = save_file.get_var()
		save_file.close()
		
		# Restore game state
		current_day = save_dict.get("current_day", 1)
		current_phase = save_dict.get("current_phase", "none")
		game_time = save_dict.get("game_time", 0.0)
		pattern_history = save_dict.get("pattern_history", {})
		choice_history = save_dict.get("choice_history", [])
		settings = save_dict.get("settings", settings)
		
		# Restore emotional state if available
		if emotional_state and "emotional_data" in save_dict:
			var emo_data = save_dict["emotional_data"]
			if "rage_level" in emotional_state:
				emotional_state.rage_level = emo_data.get("rage_level", 0)
			if "reservoir_level" in emotional_state:
				emotional_state.reservoir_level = emo_data.get("reservoir_level", 0)
			if "overwhelm_level" in emotional_state:
				emotional_state.overwhelm_level = emo_data.get("overwhelm_level", 0)
		
		print("Game loaded: ", save_name)
		return true
	return false

func get_next_scene() -> String:
	var current_index = SCENE_ORDER.find(current_phase)
	if current_index >= 0 and current_index < SCENE_ORDER.size() - 1:
		return SCENE_ORDER[current_index + 1]
	return ""

func reset_game():
	current_day = 1
	current_phase = "none"
	game_time = 0.0
	pattern_history = {}
	choice_history = []
	
	if emotional_state:
		if "rage_level" in emotional_state:
			emotional_state.rage_level = 0
		if "reservoir_level" in emotional_state:
			emotional_state.reservoir_level = 0
		if "overwhelm_level" in emotional_state:
			emotional_state.overwhelm_level = 0
