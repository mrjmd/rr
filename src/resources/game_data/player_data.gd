class_name PlayerData
extends Resource
## Stores persistent player data and choices

@export var player_name: String = "Rando"
@export var current_emotional_state: String = "calm"
@export var dialogue_history: Array[String] = []
@export var choices_made: Dictionary = {}
@export var patterns_detected: Dictionary = {}
@export var relationships: Dictionary = {
	"mother": 0,
	"father": 0,
	"brother": 0,
	"sister": 0
}

# Tracking specific behaviors
@export var suppressions_count: int = 0
@export var rage_releases_count: int = 0
@export var times_overwhelmed: int = 0

signal data_changed()
signal pattern_recorded(pattern_type: String)
signal choice_recorded(dialogue_id: String, choice_id: String)

func record_choice(dialogue_id: String, choice_id: String):
	choices_made[dialogue_id] = choice_id
	dialogue_history.append(dialogue_id)
	choice_recorded.emit(dialogue_id, choice_id)
	data_changed.emit()

func add_pattern(pattern_type: String):
	if not pattern_type in patterns_detected:
		patterns_detected[pattern_type] = 0
	patterns_detected[pattern_type] += 1
	pattern_recorded.emit(pattern_type)
	data_changed.emit()

func get_pattern_count(pattern_type: String) -> int:
	return patterns_detected.get(pattern_type, 0)

func modify_relationship(npc_name: String, amount: int):
	if npc_name in relationships:
		relationships[npc_name] += amount
		data_changed.emit()

func get_relationship(npc_name: String) -> int:
	return relationships.get(npc_name, 0)

func has_made_choice(dialogue_id: String) -> bool:
	return dialogue_id in choices_made

func get_choice(dialogue_id: String) -> String:
	return choices_made.get(dialogue_id, "")

func reset_data():
	dialogue_history.clear()
	choices_made.clear()
	patterns_detected.clear()
	suppressions_count = 0
	rage_releases_count = 0
	times_overwhelmed = 0
	relationships = {
		"mother": 0,
		"father": 0,
		"brother": 0,
		"sister": 0
	}
	data_changed.emit()