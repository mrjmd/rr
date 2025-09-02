extends Node
## Manages all audio playback including music, SFX, and ambience

# Audio buses
const BUS_MASTER = "Master"
const BUS_MUSIC = "Music"
const BUS_SFX = "SFX"
const BUS_VOICE = "Voice"
const BUS_AMBIENT = "Ambient"

# Audio players
var music_players: Dictionary = {}
var sfx_pool: Array[AudioStreamPlayer] = []
var ambient_player: AudioStreamPlayer
var voice_player: AudioStreamPlayer

# Current state
var current_music: String = ""
var current_ambient: String = ""
var music_volume: float = 1.0
var sfx_volume: float = 1.0
var voice_volume: float = 1.0

# Music tracks
const MUSIC = {
	"menu": "res://assets/audio/music/menu.ogg",
	"ambient_calm": "res://assets/audio/music/ambient/calm.ogg",
	"ambient_tense": "res://assets/audio/music/ambient/tense.ogg",
	"emotional_rage": "res://assets/audio/music/emotional/rage.ogg",
	"emotional_sad": "res://assets/audio/music/emotional/sad.ogg",
	"emotional_overwhelm": "res://assets/audio/music/emotional/overwhelm.ogg"
}

# Sound effects
const SFX = {
	# UI
	"ui_click": "res://assets/audio/sfx/ui/click.wav",
	"ui_hover": "res://assets/audio/sfx/ui/hover.wav",
	"ui_back": "res://assets/audio/sfx/ui/back.wav",
	"ui_confirm": "res://assets/audio/sfx/ui/confirm.wav",
	"ui_error": "res://assets/audio/sfx/ui/error.wav",
	"ui_transition": "res://assets/audio/sfx/ui/transition.wav",
	
	# Character
	"rage_pulse": "res://assets/audio/sfx/character/rage_pulse.wav",
	"inhale_sharp": "res://assets/audio/sfx/character/inhale_sharp.wav",
	"exhale_controlled": "res://assets/audio/sfx/character/exhale_controlled.wav",
	"heartbeat_slow": "res://assets/audio/sfx/character/heartbeat_slow.wav",
	"heartbeat_fast": "res://assets/audio/sfx/character/heartbeat_fast.wav",
	
	# Baby
	"baby_coo": "res://assets/audio/sfx/character/baby_coo.wav",
	"baby_fuss": "res://assets/audio/sfx/character/baby_fuss.wav",
	"baby_cry": "res://assets/audio/sfx/character/baby_cry.wav",
	
	# Environment
	"car_door": "res://assets/audio/sfx/environment/car_door.wav",
	"metal_bang": "res://assets/audio/sfx/environment/metal_bang.wav",
	"airport_ambience": "res://assets/audio/sfx/environment/airport_ambience.wav",
	"cicadas": "res://assets/audio/sfx/environment/cicadas.wav",
	"house_ambience": "res://assets/audio/sfx/environment/house_ambience.wav",
	"refrigerator_hum": "res://assets/audio/sfx/environment/refrigerator_hum.wav"
}

# Ambient tracks
const AMBIENT = {
	"airport": "res://assets/audio/sfx/environment/airport_ambience.wav",
	"parking_garage": "res://assets/audio/sfx/environment/parking_garage.wav",
	"car_interior": "res://assets/audio/sfx/environment/car_interior.wav",
	"florida_exterior": "res://assets/audio/sfx/environment/florida_exterior.wav",
	"house_interior": "res://assets/audio/sfx/environment/house_interior.wav"
}

# SFX pool size
const SFX_POOL_SIZE = 8

func _ready():
	# Set as singleton
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	# Initialize audio players
	_setup_music_players()
	_setup_sfx_pool()
	_setup_ambient_player()
	_setup_voice_player()
	
	# Connect to audio events
	EventBus.music_transition_requested.connect(play_music)
	EventBus.sfx_requested.connect(play_sfx)
	EventBus.ambience_change.connect(play_ambient)
	
	# Load settings
	_load_audio_settings()
	
	if OS.is_debug_build():
		print("AudioManager initialized")

func _setup_music_players():
	# Create two music players for crossfading
	for i in range(2):
		var player = AudioStreamPlayer.new()
		player.bus = BUS_MUSIC
		add_child(player)
		music_players["player_" + str(i)] = player

func _setup_sfx_pool():
	# Create a pool of SFX players
	for i in range(SFX_POOL_SIZE):
		var player = AudioStreamPlayer.new()
		player.bus = BUS_SFX
		add_child(player)
		sfx_pool.append(player)

func _setup_ambient_player():
	ambient_player = AudioStreamPlayer.new()
	ambient_player.bus = BUS_AMBIENT if AudioServer.get_bus_index(BUS_AMBIENT) >= 0 else BUS_MUSIC
	add_child(ambient_player)

func _setup_voice_player():
	voice_player = AudioStreamPlayer.new()
	voice_player.bus = BUS_VOICE if AudioServer.get_bus_index(BUS_VOICE) >= 0 else BUS_SFX
	add_child(voice_player)

func _load_audio_settings():
	if GameManager and GameManager.settings:
		set_master_volume(GameManager.settings.get("master_volume", 1.0))
		set_music_volume(GameManager.settings.get("music_volume", 1.0))
		set_sfx_volume(GameManager.settings.get("sfx_volume", 1.0))

func play_music(track_name: String, fade_duration: float = 2.0, loop: bool = true):
	if not track_name in MUSIC:
		push_error("Music track not found: " + track_name)
		return
	
	if current_music == track_name:
		return  # Already playing
	
	var track_path = MUSIC[track_name]
	if not ResourceLoader.exists(track_path):
		push_error("Music file not found: " + track_path)
		return
	
	# Crossfade between two players
	var old_player = _get_active_music_player()
	var new_player = _get_inactive_music_player()
	
	if new_player:
		# Load and setup new track
		var stream = load(track_path)
		if stream:
			new_player.stream = stream
			if stream is AudioStreamOggVorbis or stream is AudioStreamMP3:
				stream.loop = loop
			new_player.volume_db = -80.0
			new_player.play()
			
			# Create crossfade
			var tween = create_tween()
			tween.set_parallel(true)
			
			if old_player and old_player.playing:
				tween.tween_property(old_player, "volume_db", -80.0, fade_duration)
			
			tween.tween_property(new_player, "volume_db", 0.0, fade_duration)
			
			await tween.finished
			
			if old_player:
				old_player.stop()
			
			current_music = track_name

func play_sfx(sfx_name: String, volume_offset: float = 0.0, pitch: float = 1.0):
	if not sfx_name in SFX:
		if OS.is_debug_build():
			print("AudioManager: SFX not found: " + sfx_name + " (placeholder)")
		return
	
	var sfx_path = SFX[sfx_name]
	if not ResourceLoader.exists(sfx_path):
		if OS.is_debug_build():
			print("AudioManager: SFX file not found: " + sfx_path + " (using placeholder)")
		return
	
	# Find available player
	var player = _get_available_sfx_player()
	if player:
		var stream = load(sfx_path)
		if stream:
			player.stream = stream
			player.volume_db = volume_offset
			player.pitch_scale = pitch
			player.play()

# Safe audio method that works even without actual audio files
func play_ui_sound(sound_name: String, volume_offset: float = 0.0) -> void:
	if OS.is_debug_build():
		print("AudioManager: Playing UI sound: " + sound_name)
	
	# Try to play the actual sound
	play_sfx(sound_name, volume_offset)
	
	# Note: In production, this would always play the sound
	# For development, we gracefully handle missing files

func play_ambient(ambient_name: String, fade_duration: float = 1.0):
	if not ambient_name in AMBIENT:
		push_error("Ambient track not found: " + ambient_name)
		return
	
	if current_ambient == ambient_name:
		return
	
	var ambient_path = AMBIENT[ambient_name]
	if not ResourceLoader.exists(ambient_path):
		push_error("Ambient file not found: " + ambient_path)
		return
	
	var stream = load(ambient_path)
	if stream:
		if ambient_player.playing:
			# Fade out current
			var tween = create_tween()
			tween.tween_property(ambient_player, "volume_db", -80.0, fade_duration * 0.5)
			await tween.finished
			ambient_player.stop()
		
		# Play new ambient
		ambient_player.stream = stream
		if stream is AudioStreamOggVorbis or stream is AudioStreamMP3:
			stream.loop = true
		ambient_player.volume_db = -80.0
		ambient_player.play()
		
		# Fade in
		var tween = create_tween()
		tween.tween_property(ambient_player, "volume_db", 0.0, fade_duration * 0.5)
		
		current_ambient = ambient_name

func stop_music(fade_duration: float = 1.0):
	var player = _get_active_music_player()
	if player and player.playing:
		var tween = create_tween()
		tween.tween_property(player, "volume_db", -80.0, fade_duration)
		await tween.finished
		player.stop()
		current_music = ""

func stop_ambient(fade_duration: float = 1.0):
	if ambient_player.playing:
		var tween = create_tween()
		tween.tween_property(ambient_player, "volume_db", -80.0, fade_duration)
		await tween.finished
		ambient_player.stop()
		current_ambient = ""

func _get_active_music_player() -> AudioStreamPlayer:
	for player in music_players.values():
		if player.playing:
			return player
	return null

func _get_inactive_music_player() -> AudioStreamPlayer:
	for player in music_players.values():
		if not player.playing:
			return player
	return music_players.values()[0]  # Fallback to first

func _get_available_sfx_player() -> AudioStreamPlayer:
	for player in sfx_pool:
		if not player.playing:
			return player
	# All players busy, use first one
	return sfx_pool[0]

func set_master_volume(value: float):
	var bus_idx = AudioServer.get_bus_index(BUS_MASTER)
	if bus_idx >= 0:
		AudioServer.set_bus_volume_db(bus_idx, linear_to_db(value))

func set_music_volume(value: float):
	music_volume = value
	var bus_idx = AudioServer.get_bus_index(BUS_MUSIC)
	if bus_idx >= 0:
		AudioServer.set_bus_volume_db(bus_idx, linear_to_db(value))

func set_sfx_volume(value: float):
	sfx_volume = value
	var bus_idx = AudioServer.get_bus_index(BUS_SFX)
	if bus_idx >= 0:
		AudioServer.set_bus_volume_db(bus_idx, linear_to_db(value))

func set_voice_volume(value: float):
	voice_volume = value
	var bus_idx = AudioServer.get_bus_index(BUS_VOICE)
	if bus_idx >= 0:
		AudioServer.set_bus_volume_db(bus_idx, linear_to_db(value))

# Play a one-shot sound at a specific position (for 2D games)
func play_sfx_at_position(sfx_name: String, global_pos: Vector2, volume_offset: float = 0.0):
	if not sfx_name in SFX:
		return
	
	# This would require AudioStreamPlayer2D setup
	# For now, just play regular SFX
	play_sfx(sfx_name, volume_offset)
