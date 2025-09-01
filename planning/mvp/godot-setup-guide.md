# Godot 4.4 Project Setup Guide
## Rando's Reservoir - Complete Configuration

### Document Version: 1.0.0
### Date: January 2025
### Engine Version: Godot 4.4

---

## 1. Initial Project Configuration

### 1.1 Project Settings Setup

Open `Project Settings` and configure the following:

#### Application Settings
```
Application > Config:
- Name: "Rando's Reservoir"
- Description: "A narrative exploration of family dynamics and emotional suppression"
- Version: "0.1.0-mvp"
- Icon: res://icon.svg (update with custom icon later)

Application > Run:
- Main Scene: res://src/scenes/main_menu.tscn (will create later)
- Disable stdout: Off (for development)
```

#### Display Settings
```
Display > Window:
- Viewport Width: 1920
- Viewport Height: 1080
- Mode: Windowed
- Resizable: On
- Borderless: Off
- Always on Top: Off
- Transparent: Off
- Extend to Title: Off
- No Focus: Off

Display > Window > Stretch:
- Mode: viewport
- Aspect: keep
- Scale: 1.0
```

#### Rendering Settings
```
Rendering > Renderer:
- Rendering Method: mobile (for wider compatibility)

Rendering > Textures:
- Canvas Textures > Default Texture Filter: Linear
- Default Texture Repeat: Disabled

Rendering > Anti-Aliasing:
- MSAA 2D: Disabled (for pixel art)
- MSAA 3D: Disabled

Rendering > Environment:
- Default Clear Color: #1a1a1a (dark gray)
```

### 1.2 Input Map Configuration

Create the following input actions:

```
Input Map:

# Movement (if needed)
move_left:
  - Key: A
  - Key: Left Arrow
  
move_right:
  - Key: D
  - Key: Right Arrow
  
move_up:
  - Key: W
  - Key: Up Arrow
  
move_down:
  - Key: S
  - Key: Down Arrow

# Interaction
interact:
  - Key: E
  - Key: Space
  - Mouse Button: Left Click

# UI Navigation
ui_select:
  - Key: Enter
  - Key: Space
  
ui_cancel:
  - Key: Escape
  
ui_up:
  - Key: W
  - Key: Up Arrow
  
ui_down:
  - Key: S
  - Key: Down Arrow

# Emotional Mechanics
suppress_rage:
  - Key: R (Hold)
  - Key: Space (Hold) - Alternative

# Dialogue
dialogue_advance:
  - Key: Space
  - Mouse Button: Left Click
  
dialogue_choice_1:
  - Key: 1
  
dialogue_choice_2:
  - Key: 2
  
dialogue_choice_3:
  - Key: 3
  
dialogue_choice_4:
  - Key: 4

# System
pause_menu:
  - Key: Escape
  - Key: P
  
quick_save:
  - Key: F5
  
quick_load:
  - Key: F9

# Debug (Development Only)
debug_toggle:
  - Key: F3
  
debug_rage_increase:
  - Key: F6
  
debug_rage_decrease:
  - Key: F7
  
debug_skip_scene:
  - Key: F10
```

### 1.3 Audio Bus Configuration

Set up the audio buses for dynamic mixing:

1. Open `Project > Project Settings > Audio > Buses`
2. Create the following bus layout:

```
Master
├── Music
│   ├── Ambient
│   ├── Tense
│   └── Emotional
├── SFX
│   ├── UI
│   ├── Environment
│   └── Character
└── Voice
    └── Narration
```

**Bus Settings:**
- Master: 0 dB
- Music: -6 dB (default)
- SFX: -3 dB (default)
- Voice: 0 dB (if used)

### 1.4 Layer Configuration

#### Physics Layers (2D)
```
Layer 1: World
Layer 2: Player
Layer 3: NPCs
Layer 4: Interactables
Layer 5: UI_Blocking
Layer 6: Triggers
Layer 7: Boundaries
```

#### Render Layers
```
Layer 1: Background
Layer 2: Environment
Layer 3: Characters
Layer 4: Foreground
Layer 5: UI
Layer 6: Overlay_Effects
Layer 7: Debug
```

---

## 2. Folder Structure Creation

### 2.1 Directory Setup Script

Create this structure in your project root:

```bash
# Run this in terminal at project root
mkdir -p src/core/state_machine
mkdir -p src/core/event_bus
mkdir -p src/core/save_system
mkdir -p src/core/pattern_system

mkdir -p src/player/states
mkdir -p src/player/components

mkdir -p src/npcs/mother
mkdir -p src/npcs/father
mkdir -p src/npcs/brother
mkdir -p src/npcs/baby/states

mkdir -p src/ui/hud/meters
mkdir -p src/ui/dialogue
mkdir -p src/ui/menus
mkdir -p src/ui/transitions

mkdir -p src/scenes/day1/airport_montage/vignettes
mkdir -p src/scenes/day1/parking_garage
mkdir -p src/scenes/day1/car_drive
mkdir -p src/scenes/day1/family_home
mkdir -p src/scenes/shared

mkdir -p src/minigames/car_seat
mkdir -p src/minigames/balancing

mkdir -p src/dialogue/day1
mkdir -p src/resources/game_data
mkdir -p src/resources/themes

mkdir -p assets/sprites/characters
mkdir -p assets/sprites/environments
mkdir -p assets/sprites/ui
mkdir -p assets/audio/music/ambient
mkdir -p assets/audio/music/emotional
mkdir -p assets/audio/sfx/ui
mkdir -p assets/audio/sfx/environment
mkdir -p assets/audio/sfx/character
mkdir -p assets/fonts
mkdir -p assets/shaders

mkdir -p globals
mkdir -p tests/unit
mkdir -p tests/integration
```

---

## 3. Core System Files

### 3.1 Autoload Singletons

Create these singleton scripts and add them to Autoload:

#### Event Bus (`globals/event_bus.gd`)
```gdscript
extends Node

# Emotional events
signal rage_threshold_reached()
signal rage_updated(new_value: float)
signal reservoir_updated(new_value: float)
signal suppression_activated()
signal suppression_released()
signal emotional_breaking_point()
signal pattern_detected(pattern_type: String)

# Dialogue events
signal dialogue_started(dialogue_id: String)
signal dialogue_ended()
signal choice_made(choice_data: Dictionary)
signal dialogue_interrupted()

# Scene events
signal scene_transition_requested(scene_path: String)
signal scene_loaded(scene_name: String)
signal minigame_started(game_type: String)
signal minigame_completed(success: bool, game_type: String)

# Game state events
signal game_paused()
signal game_resumed()
signal save_requested()
signal load_requested()

# Debug events (remove in production)
signal debug_message(message: String)
```

#### Game Manager (`globals/game_manager.gd`)
```gdscript
extends Node

# Game state
var current_day: int = 1
var current_phase: String = "airport_montage"
var game_time: float = 0.0
var is_paused: bool = false

# Player data reference
var player_data: PlayerData
var emotional_state: EmotionalState

# Settings
var settings: Dictionary = {
    "master_volume": 1.0,
    "music_volume": 1.0,
    "sfx_volume": 1.0,
    "text_speed": 1.0,
    "auto_advance": false,
    "skip_seen_dialogue": false
}

func _ready():
    # Initialize player data
    player_data = preload("res://src/resources/game_data/player_data.tres")
    emotional_state = preload("res://src/resources/game_data/emotional_state.tres")
    
    # Connect to critical events
    EventBus.rage_threshold_reached.connect(_on_rage_threshold)
    EventBus.emotional_breaking_point.connect(_on_breaking_point)

func _process(delta):
    if not is_paused:
        game_time += delta

func _on_rage_threshold():
    print("Rage threshold reached!")
    # Handle rage threshold logic

func _on_breaking_point():
    print("Emotional breaking point!")
    # Handle breaking point logic
```

#### Scene Manager (`globals/scene_manager.gd`)
```gdscript
extends Node

var current_scene: Node
var scene_stack: Array[String] = []

# Scene paths
const SCENES = {
    "main_menu": "res://src/scenes/main_menu.tscn",
    "airport_montage": "res://src/scenes/day1/airport_montage/montage_controller.tscn",
    "parking_garage": "res://src/scenes/day1/parking_garage/parking_garage.tscn",
    "car_drive": "res://src/scenes/day1/car_drive/car_drive.tscn",
    "family_home": "res://src/scenes/day1/family_home/home_arrival.tscn"
}

# Transition scenes
var fade_transition = preload("res://src/ui/transitions/fade_transition.tscn")

func change_scene(scene_key: String, use_transition: bool = true):
    if not scene_key in SCENES:
        push_error("Scene key not found: " + scene_key)
        return
    
    var scene_path = SCENES[scene_key]
    
    if use_transition:
        await _transition_to_scene(scene_path)
    else:
        _load_scene(scene_path)
    
    EventBus.scene_loaded.emit(scene_key)

func _transition_to_scene(scene_path: String):
    var transition = fade_transition.instantiate()
    get_tree().root.add_child(transition)
    
    await transition.fade_in()
    _load_scene(scene_path)
    await transition.fade_out()
    
    transition.queue_free()

func _load_scene(scene_path: String):
    if current_scene:
        current_scene.queue_free()
    
    var new_scene = load(scene_path)
    if new_scene:
        current_scene = new_scene.instantiate()
        get_tree().root.add_child(current_scene)
        scene_stack.append(scene_path)
```

#### Audio Manager (`globals/audio_manager.gd`)
```gdscript
extends Node

# Audio players
var music_player: AudioStreamPlayer
var sfx_player: AudioStreamPlayer
var voice_player: AudioStreamPlayer

# Current music state
var current_music: String = ""
var music_volume: float = 1.0
var sfx_volume: float = 1.0

# Music tracks
const MUSIC = {
    "ambient_calm": "res://assets/audio/music/ambient/calm.ogg",
    "ambient_tense": "res://assets/audio/music/ambient/tense.ogg",
    "emotional_rage": "res://assets/audio/music/emotional/rage.ogg",
    "emotional_sad": "res://assets/audio/music/emotional/sad.ogg"
}

# Sound effects
const SFX = {
    "ui_click": "res://assets/audio/sfx/ui/click.wav",
    "ui_hover": "res://assets/audio/sfx/ui/hover.wav",
    "rage_pulse": "res://assets/audio/sfx/character/rage_pulse.wav",
    "baby_cry": "res://assets/audio/sfx/character/baby_cry.wav",
    "car_door": "res://assets/audio/sfx/environment/car_door.wav"
}

func _ready():
    # Create audio players
    music_player = AudioStreamPlayer.new()
    sfx_player = AudioStreamPlayer.new()
    voice_player = AudioStreamPlayer.new()
    
    add_child(music_player)
    add_child(sfx_player)
    add_child(voice_player)
    
    # Set bus assignments
    music_player.bus = "Music"
    sfx_player.bus = "SFX"
    voice_player.bus = "Voice"

func play_music(track_name: String, fade_duration: float = 1.0):
    if not track_name in MUSIC:
        push_error("Music track not found: " + track_name)
        return
    
    if current_music == track_name:
        return
    
    # Fade out current music
    if music_player.playing:
        var tween = create_tween()
        tween.tween_property(music_player, "volume_db", -80.0, fade_duration)
        await tween.finished
        music_player.stop()
    
    # Load and play new music
    music_player.stream = load(MUSIC[track_name])
    music_player.volume_db = -80.0
    music_player.play()
    
    # Fade in new music
    var tween = create_tween()
    tween.tween_property(music_player, "volume_db", 0.0, fade_duration)
    
    current_music = track_name

func play_sfx(sfx_name: String, volume: float = 0.0):
    if not sfx_name in SFX:
        push_error("SFX not found: " + sfx_name)
        return
    
    sfx_player.stream = load(SFX[sfx_name])
    sfx_player.volume_db = volume
    sfx_player.play()

func set_music_volume(value: float):
    music_volume = value
    AudioServer.set_bus_volume_db(
        AudioServer.get_bus_index("Music"),
        linear_to_db(value)
    )

func set_sfx_volume(value: float):
    sfx_volume = value
    AudioServer.set_bus_volume_db(
        AudioServer.get_bus_index("SFX"),
        linear_to_db(value)
    )
```

### 3.2 Adding Autoloads

1. Go to `Project > Project Settings > Autoload`
2. Add the following scripts:

| Name | Path | Order |
|------|------|-------|
| EventBus | res://globals/event_bus.gd | 1 |
| GameManager | res://globals/game_manager.gd | 2 |
| SceneManager | res://globals/scene_manager.gd | 3 |
| AudioManager | res://globals/audio_manager.gd | 4 |

---

## 4. Resource Templates

### 4.1 Player Data Resource (`src/resources/game_data/player_data.gd`)
```gdscript
class_name PlayerData
extends Resource

@export var player_name: String = "Rando"
@export var current_emotional_state: String = "calm"
@export var dialogue_history: Array[String] = []
@export var choices_made: Dictionary = {}
@export var patterns_detected: Dictionary = {}

signal data_changed()

func record_choice(dialogue_id: String, choice_id: String):
    choices_made[dialogue_id] = choice_id
    data_changed.emit()

func add_pattern(pattern_type: String):
    if not pattern_type in patterns_detected:
        patterns_detected[pattern_type] = 0
    patterns_detected[pattern_type] += 1
    data_changed.emit()
```

### 4.2 Emotional State Resource (`src/resources/game_data/emotional_state.gd`)
```gdscript
class_name EmotionalState
extends Resource

@export_range(0.0, 100.0) var rage_level: float = 0.0
@export_range(0.0, 100.0) var reservoir_level: float = 0.0
@export_range(0.0, 100.0) var overwhelm_level: float = 0.0
@export var suppression_count: int = 0
@export var rage_releases: int = 0

# Thresholds
const RAGE_THRESHOLD_STRESSED = 25.0
const RAGE_THRESHOLD_OVERWHELMED = 50.0
const RAGE_THRESHOLD_BREAKING = 90.0

signal rage_changed(new_value: float)
signal reservoir_changed(new_value: float)
signal overwhelm_changed(new_value: float)
signal threshold_reached(threshold_type: String)

func increase_rage(amount: float):
    var old_rage = rage_level
    rage_level = clamp(rage_level + amount, 0.0, 100.0)
    
    rage_changed.emit(rage_level)
    EventBus.rage_updated.emit(rage_level)
    
    # Check thresholds
    if old_rage < RAGE_THRESHOLD_BREAKING and rage_level >= RAGE_THRESHOLD_BREAKING:
        threshold_reached.emit("breaking")
        EventBus.rage_threshold_reached.emit()
    elif old_rage < RAGE_THRESHOLD_OVERWHELMED and rage_level >= RAGE_THRESHOLD_OVERWHELMED:
        threshold_reached.emit("overwhelmed")
    elif old_rage < RAGE_THRESHOLD_STRESSED and rage_level >= RAGE_THRESHOLD_STRESSED:
        threshold_reached.emit("stressed")

func suppress_rage():
    reservoir_level = clamp(reservoir_level + rage_level * 0.1, 0.0, 100.0)
    rage_level = 0.0
    suppression_count += 1
    
    rage_changed.emit(rage_level)
    reservoir_changed.emit(reservoir_level)
    EventBus.rage_updated.emit(rage_level)
    EventBus.reservoir_updated.emit(reservoir_level)
    EventBus.suppression_activated.emit()

func release_rage():
    rage_level = 0.0
    rage_releases += 1
    
    rage_changed.emit(rage_level)
    EventBus.rage_updated.emit(rage_level)
```

---

## 5. Editor Configuration

### 5.1 Editor Settings

Go to `Editor > Editor Settings` and configure:

```
Text Editor > Theme:
- Color Theme: Choose your preference
- Line Numbers: On
- Highlight Current Line: On

Text Editor > Indent:
- Type: Tabs
- Size: 4

Text Editor > Code Folding:
- Enable: On

Text Editor > Completion:
- Auto Brace Complete: On
- Code Complete Delay: 0.3

Network > Debug:
- Remote Port: 6007 (default)
- Max Remote FPS: 60

Filesystem > Import:
- Blender Path: [Set if using 3D]
- Aseprite Path: [Set if using for sprites]
```

### 5.2 Project Organization Tips

1. **Scene Naming Convention:**
   - Scenes: `snake_case.tscn`
   - Scripts: `snake_case.gd`
   - Resources: `snake_case.tres`

2. **Node Naming in Scenes:**
   - Use PascalCase for nodes
   - Be descriptive: `PlayerCharacter`, not `Player`
   - Group related nodes under empty Node containers

3. **Script Templates:**
   Create a script template at `res://script_templates/Node/default.gd`:

```gdscript
extends _BASE_

## Brief description of what this script does

# Signals

# Enums

# Constants

# Export variables

# Public variables

# Private variables

# Onready variables

func _ready() -> void:
    pass

func _process(_delta: float) -> void:
    pass

# Public methods

# Private methods
```

---

## 6. Version Control Setup

### 6.1 Git Configuration

Create `.gitignore`:
```
# Godot-specific ignores
.import/
.godot/
export.cfg
export_presets.cfg

# Imported translations (automatically generated from CSV files)
*.translation

# Mono-specific ignores
.mono/
data_*/
mono_crash.*.json

# System/tool-specific ignores
.DS_Store
*~
*.tmp

# Project-specific
builds/
logs/
screenshots/
```

Create `.gitattributes`:
```
# Normalize line endings
* text=auto

# Godot files
*.tscn text eol=lf
*.tres text eol=lf
*.gd text eol=lf
*.cfg text eol=lf

# Images
*.png binary
*.jpg binary
*.svg text eol=lf

# Audio
*.ogg binary
*.wav binary
*.mp3 binary
```

---

## 7. Debug Tools Setup

### 7.1 Debug Overlay (`src/ui/debug/debug_overlay.gd`)
```gdscript
extends CanvasLayer

@onready var fps_label = $Panel/VBox/FPSLabel
@onready var rage_label = $Panel/VBox/RageLabel
@onready var state_label = $Panel/VBox/StateLabel
@onready var scene_label = $Panel/VBox/SceneLabel

var visible_debug: bool = false

func _ready():
    visible = false

func _input(event):
    if event.is_action_pressed("debug_toggle"):
        visible_debug = !visible_debug
        visible = visible_debug

func _process(_delta):
    if visible_debug:
        fps_label.text = "FPS: " + str(Engine.get_frames_per_second())
        rage_label.text = "Rage: %.1f" % GameManager.emotional_state.rage_level
        state_label.text = "State: " + GameManager.player_data.current_emotional_state
        scene_label.text = "Scene: " + GameManager.current_phase
```

---

## 8. Build Configuration

### 8.1 Export Presets

Create export presets for target platforms:

#### Windows
```
Platform: Windows Desktop
Architecture: x86_64
Export Path: builds/windows/RandosReservoir.exe
Options:
- Binary Format: 64-bit
- Embed PCK: On
- Console: Off (On for debug builds)
```

#### macOS
```
Platform: macOS
Architecture: Universal
Export Path: builds/mac/RandosReservoir.app
Options:
- Binary Format: Universal
- Code Signing: [Configure if needed]
```

#### Linux
```
Platform: Linux/X11
Architecture: x86_64
Export Path: builds/linux/RandosReservoir.x86_64
Options:
- Binary Format: 64-bit
- Embed PCK: On
```

---

## 9. Testing Framework

### 9.1 Unit Test Setup (`tests/unit/test_emotional_state.gd`)
```gdscript
extends "res://addons/gut/test.gd"

var emotional_state: EmotionalState

func before_each():
    emotional_state = EmotionalState.new()

func test_rage_increase():
    emotional_state.increase_rage(25.0)
    assert_eq(emotional_state.rage_level, 25.0)

func test_rage_threshold():
    emotional_state.increase_rage(90.0)
    assert_eq(emotional_state.rage_level, 90.0)
    # Should have triggered threshold

func test_suppression():
    emotional_state.rage_level = 50.0
    emotional_state.suppress_rage()
    assert_eq(emotional_state.rage_level, 0.0)
    assert_gt(emotional_state.reservoir_level, 0.0)
```

---

## 10. Performance Optimization Settings

### 10.1 Project Settings for Performance

```
Rendering > Limits:
- Max Renderable Elements: 128000
- Max Renderable Lights: 32
- Max Renderable Reflections: 8

Physics > 2D:
- Physics FPS: 60
- Max Physics Steps Per Frame: 8

Application > Boot Splash:
- Show Image: On
- Fullscreen: Off
- Use Filter: On

Debug > Settings:
- Max Error/Warning Lines: 100
- Profiler Enabled: Off (in production)
```

---

## Quick Start Checklist

### Initial Setup
- [ ] Create project in Godot 4.4
- [ ] Configure project settings
- [ ] Set up input map
- [ ] Configure audio buses
- [ ] Create folder structure
- [ ] Add autoload singletons
- [ ] Configure editor settings
- [ ] Initialize version control

### Core Systems
- [ ] Create state machine framework
- [ ] Set up event bus
- [ ] Implement scene manager
- [ ] Configure audio manager
- [ ] Create resource templates

### Testing
- [ ] Set up debug overlay
- [ ] Create test framework
- [ ] Write initial unit tests

### Ready for Development
- [ ] All core systems functional
- [ ] Project structure organized
- [ ] Version control working
- [ ] Ready to begin Phase 1

---

*End of Godot Setup Guide v1.0*