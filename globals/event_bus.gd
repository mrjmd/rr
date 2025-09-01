extends Node
## Global event bus for decoupled communication between systems

# Emotional events
signal rage_threshold_reached()
signal rage_updated(new_value: float)
signal reservoir_updated(new_value: float)
signal overwhelm_updated(new_value: float)
signal suppression_activated()
signal suppression_released()
signal emotional_breaking_point()
signal pattern_detected(pattern_type: String)

# Dialogue events
signal dialogue_started(dialogue_id: String)
signal dialogue_ended()
signal choice_made(choice_data: Dictionary)
signal dialogue_interrupted()
signal monologue_triggered(text: String)

# Scene events
signal scene_transition_requested(scene_path: String)
signal scene_loaded(scene_name: String)
signal minigame_started(game_type: String)
signal minigame_completed(success: bool, game_type: String)
signal vignette_completed(vignette_name: String)

# Player events
signal player_moved(direction: Vector2)
signal player_direction_changed(new_direction: Vector2)

# NPC events
signal npc_interaction_started(npc_name: String)
signal npc_interaction_ended(npc_name: String)
signal npc_reaction(npc_name: String, reaction_type: String)

# Game state events
signal game_paused()
signal game_resumed()
signal save_requested()
signal load_requested()
signal checkpoint_reached(checkpoint_name: String)

# Audio events
signal music_transition_requested(track_name: String)
signal sfx_requested(sfx_name: String)
signal ambience_change(ambience_type: String)

# Debug events (remove in production)
signal debug_message(message: String)
signal debug_rage_modified(amount: float)

func _ready():
	# Set as singleton
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	if OS.is_debug_build():
		print("EventBus initialized")