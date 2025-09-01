# Rando's Reservoir - Technical Specification Document
## MVP Version 1.0

### Document Version: 1.0.0
### Date: January 2025
### Engine: Godot 4.4

---

## 1. Executive Summary

### 1.1 Project Overview
**Rando's Reservoir** is a narrative-driven, psychological exploration game that examines family dynamics, emotional suppression, and the cost of maintaining peace. The game follows Rando, a father navigating a week-long family gathering while managing his emotional state through a unique "rage suppression" mechanic.

### 1.2 Technical Goals
- Create a scalable, maintainable architecture suitable for narrative-heavy gameplay
- Implement robust state management for complex emotional and dialogue systems
- Design modular, reusable systems that can be extended throughout development
- Establish clear separation between game logic and presentation layers
- Build with performance optimization for low-spec machines in mind

### 1.3 MVP Scope
The MVP encompasses the complete Day 1 experience:
- Opening airport montage (Phase 0)
- Airport parking garage scene (Phase 1-4)
- The two-hour drive dialogue system (Phase 5)
- Arrival at the family home (Phase 6)

---

## 2. Architecture Overview

### 2.1 Core Design Patterns

#### 2.1.1 Finite State Machine (FSM)
**Purpose**: Manage complex character behaviors and game states
**Implementation**: Node-based state machine for visual debugging and modularity

**Primary Use Cases**:
- Player emotional states (Calm, Stressed, Overwhelmed, Rage)
- Scene flow management (Cutscene, Interactive, Dialogue, MiniGame)
- Baby states (Content, Fussy, Crying)
- Dialogue system states (Listening, Choosing, Speaking)

#### 2.1.2 Model-View-Controller (MVC)
**Purpose**: Separate game data from presentation for easy save/load and testing
**Implementation**: Resource-based Models with Signal-driven View updates

**Components**:
- **Model**: Custom Resource classes for game state data
- **View**: Scene nodes that observe and display Model data
- **Controller**: Input handlers and game logic processors

#### 2.1.3 Entity-Component Pattern
**Purpose**: Create flexible, reusable game objects through composition
**Implementation**: Node-based components attached to entity scenes

**Key Components**:
- EmotionalComponent (tracks emotional states)
- DialogueComponent (handles conversation logic)
- InteractableComponent (manages object interactions)
- MeterComponent (displays various UI meters)

### 2.2 Project Structure

```
/randos-reservoir/
├── /src/
│   ├── /core/
│   │   ├── /state_machine/
│   │   │   ├── state_machine.gd
│   │   │   ├── state.gd
│   │   │   └── state_transition.gd
│   │   ├── /event_bus/
│   │   │   └── event_bus.gd
│   │   └── /save_system/
│   │       ├── save_manager.gd
│   │       └── save_data.gd
│   ├── /player/
│   │   ├── player.tscn
│   │   ├── player_controller.gd
│   │   ├── /states/
│   │   │   ├── player_calm.gd
│   │   │   ├── player_stressed.gd
│   │   │   ├── player_overwhelmed.gd
│   │   │   └── player_rage.gd
│   │   └── /components/
│   │       ├── emotional_component.tscn
│   │       └── emotional_component.gd
│   ├── /npcs/
│   │   ├── /mother/
│   │   ├── /father/
│   │   ├── /brother/
│   │   └── /baby/
│   │       ├── baby.tscn
│   │       ├── baby_controller.gd
│   │       └── /states/
│   ├── /ui/
│   │   ├── /hud/
│   │   │   ├── hud.tscn
│   │   │   ├── hud_controller.gd
│   │   │   └── /meters/
│   │   │       ├── rage_meter.tscn
│   │   │       ├── reservoir_meter.tscn
│   │   │       └── fuss_meter.tscn
│   │   ├── /dialogue/
│   │   │   ├── dialogue_box.tscn
│   │   │   ├── dialogue_controller.gd
│   │   │   └── choice_button.tscn
│   │   └── /menus/
│   ├── /scenes/
│   │   ├── /day1/
│   │   │   ├── /airport_montage/
│   │   │   ├── /parking_garage/
│   │   │   ├── /car_drive/
│   │   │   └── /family_home/
│   │   └── /shared/
│   ├── /minigames/
│   │   ├── /car_seat/
│   │   │   ├── car_seat_game.tscn
│   │   │   └── car_seat_controller.gd
│   │   └── /balancing/
│   ├── /dialogue/
│   │   ├── dialogue_database.tres
│   │   └── /day1/
│   │       ├── airport_dialogues.json
│   │       └── drive_dialogues.json
│   └── /resources/
│       ├── /game_data/
│       │   ├── player_data.gd
│       │   ├── emotional_state.gd
│       │   └── relationship_data.gd
│       └── /themes/
├── /assets/
│   ├── /sprites/
│   ├── /audio/
│   ├── /fonts/
│   └── /shaders/
├── /globals/
│   ├── game_manager.gd
│   ├── audio_manager.gd
│   └── scene_manager.gd
└── /tests/
```

---

## 3. Core Systems Design

### 3.1 Emotional State System

#### 3.1.1 Data Model
```gdscript
# emotional_state.gd
extends Resource
class_name EmotionalState

@export var rage_level: float = 0.0 # 0-100
@export var reservoir_level: float = 0.0 # 0-100
@export var overwhelm_level: float = 0.0 # 0-100
@export var suppression_count: int = 0

signal rage_changed(new_value: float)
signal reservoir_changed(new_value: float)
signal rage_threshold_reached()
signal emotional_breaking_point()
```

#### 3.1.2 State Transitions
- **Calm** → **Stressed**: rage_level > 25%
- **Stressed** → **Overwhelmed**: rage_level > 50% OR overwhelm_level > 60%
- **Overwhelmed** → **Rage**: rage_level > 90%
- **Any** → **Suppressed**: Player holds suppression key
- **Suppressed** → **Calm**: Release key (transfers rage to reservoir)

### 3.2 Dialogue System

#### 3.2.1 Architecture
- **DialogueDatabase**: Central Resource containing all dialogue trees
- **DialogueController**: Manages conversation flow and state
- **ChoiceProcessor**: Evaluates player choices and triggers consequences
- **PatternTracker**: Records and analyzes player behavior patterns

#### 3.2.2 Dialogue Tree Structure
```json
{
  "dialogue_id": "car_drive_01",
  "speaker": "mother",
  "text": "So how is work going?",
  "choices": [
    {
      "id": "choice_01",
      "text": "It's good. Busy, but good.",
      "pattern": "PEACEMAKER",
      "emotional_impact": { "rage": 0, "reservoir": 5 },
      "next": "dialogue_02a"
    },
    {
      "id": "choice_02",
      "text": "It's actually really challenging...",
      "pattern": "VULNERABLE",
      "emotional_impact": { "rage": -5, "reservoir": 0 },
      "next": "dialogue_02b"
    }
  ]
}
```

### 3.3 Mini-Game System

#### 3.3.1 Base Mini-Game Class
```gdscript
# mini_game_base.gd
extends Node
class_name MiniGameBase

signal game_completed(success: bool)
signal difficulty_adjusted(new_level: int)

@export var base_difficulty: int = 1
@export var rage_difficulty_modifier: float = 0.1

func start_game():
    pass # Override in child classes
    
func calculate_difficulty() -> int:
    var rage_factor = GameManager.player_data.rage_level * rage_difficulty_modifier
    return base_difficulty + int(rage_factor)
```

### 3.4 UI Meter System

#### 3.4.1 Base Meter Component
```gdscript
# meter_base.gd
extends Control
class_name MeterBase

@export var data_source: Resource
@export var property_name: String
@export var min_value: float = 0.0
@export var max_value: float = 100.0
@export var lerp_speed: float = 2.0

@onready var progress_bar: ProgressBar = $ProgressBar
@onready var animator: AnimationPlayer = $AnimationPlayer

var target_value: float = 0.0
var current_value: float = 0.0
```

---

## 4. Scene Implementation Details

### 4.1 Airport Montage (Phase 0)

#### 4.1.1 Technical Requirements
- Sequential vignette system with transitions
- Micro-interaction input handlers
- Progressive rage accumulation
- Visual and audio feedback systems

#### 4.1.2 Scene Structure
```
/airport_montage/
├── montage_controller.tscn
├── montage_controller.gd
├── /vignettes/
│   ├── vignette_base.gd
│   ├── curbside_chaos.tscn
│   ├── security_line.tscn
│   ├── gate_delay.tscn
│   └── flight_turbulence.tscn
└── /transitions/
    ├── fade_transition.tscn
    └── text_overlay.tscn
```

### 4.2 Parking Garage Scene (Phase 1-4)

#### 4.2.1 Core Mechanics
- Car seat installation mini-game
- Dynamic difficulty based on failure count
- Rage suppression choice system
- Environmental heat effects

#### 4.2.2 Interaction Flow
1. Player approaches car (proximity trigger)
2. Dialogue initiates with Mother
3. Mini-game launches on interaction
4. Failure states trigger emotional responses
5. Critical choice at rage threshold
6. Resolution and scene transition

### 4.3 Car Drive Dialogue (Phase 5)

#### 4.3.1 Dynamic Dialogue System
- Time-based conversation progression
- Interruption mechanics (baby fussing)
- Pattern recognition and feedback
- Choice consequences affecting future dialogues

### 4.4 Family Home Arrival (Phase 6)

#### 4.4.1 Environmental Systems
- Clutter-based overwhelm accumulation
- Object interaction with internal monologue
- Multi-NPC greeting sequence
- Safe space establishment (guest room)

---

## 5. Technical Specifications

### 5.1 Performance Targets
- **Frame Rate**: Stable 60 FPS on mid-range hardware
- **Resolution Support**: 1920x1080 native, scalable to 4K
- **Memory Usage**: < 2GB RAM
- **Load Times**: < 3 seconds between scenes

### 5.2 Platform Requirements
- **Minimum OS**: Windows 10, macOS 10.15, Ubuntu 20.04
- **Graphics**: OpenGL ES 3.0 / Vulkan 1.0 support
- **Storage**: 500MB available space
- **Input**: Keyboard & Mouse (controller support planned)

### 5.3 Asset Pipeline

#### 5.3.1 Art Assets
- **Style**: 2D pixel art or stylized low-poly 3D
- **Character Sprites**: 128x128 base resolution
- **Tilesets**: 32x32 or 64x64 grid
- **UI Elements**: Vector-based, scalable

#### 5.3.2 Audio Assets
- **Format**: OGG Vorbis for music, WAV for SFX
- **Music**: Ambient, atmospheric tracks
- **SFX**: Reactive to emotional states
- **Voice**: Text-to-speech or minimal voice acting

### 5.4 Data Management

#### 5.4.1 Save System
```gdscript
# save_data.gd
extends Resource
class_name SaveData

@export var current_scene: String = ""
@export var player_data: PlayerData
@export var emotional_history: Array[EmotionalState] = []
@export var dialogue_history: Dictionary = {}
@export var pattern_counts: Dictionary = {}
@export var playtime: float = 0.0
```

#### 5.4.2 Settings Management
- Graphics quality presets
- Audio volume controls
- Accessibility options
- Control remapping

---

## 6. Development Milestones

### 6.1 Phase 1: Foundation (Week 1-2)
- [ ] Core project structure setup
- [ ] Base state machine implementation
- [ ] Player controller and movement
- [ ] Basic UI framework

### 6.2 Phase 2: Core Systems (Week 3-4)
- [ ] Emotional state system
- [ ] Dialogue system foundation
- [ ] Save/load functionality
- [ ] Scene management

### 6.3 Phase 3: Airport Montage (Week 5-6)
- [ ] Vignette framework
- [ ] Micro-interactions
- [ ] Transition system
- [ ] Initial rage mechanics

### 6.4 Phase 4: Parking Garage (Week 7-8)
- [ ] Car seat mini-game
- [ ] Suppression mechanics
- [ ] Environmental effects
- [ ] Mother NPC interactions

### 6.5 Phase 5: Dialogue & Drive (Week 9-10)
- [ ] Full dialogue tree implementation
- [ ] Pattern recognition system
- [ ] Dynamic conversation flow
- [ ] Baby interruption mechanics

### 6.6 Phase 6: Home Arrival (Week 11-12)
- [ ] Environmental interaction system
- [ ] Multiple NPC handling
- [ ] Overwhelm mechanics
- [ ] Scene completion

### 6.7 Phase 7: Polish & Testing (Week 13-14)
- [ ] Bug fixing and optimization
- [ ] Balance adjustments
- [ ] Audio implementation
- [ ] Playtesting and iteration

---

## 7. Risk Assessment & Mitigation

### 7.1 Technical Risks

| Risk | Probability | Impact | Mitigation Strategy |
|------|------------|--------|-------------------|
| State machine complexity | Medium | High | Implement incremental testing, use visual debugging tools |
| Dialogue tree management | High | Medium | Use external tools (Yarn, Dialogic), implement robust testing |
| Performance on low-end hardware | Medium | Medium | Profile early and often, implement quality settings |
| Save system corruption | Low | High | Implement backup saves, extensive testing |

### 7.2 Design Risks

| Risk | Probability | Impact | Mitigation Strategy |
|------|------------|--------|-------------------|
| Emotional mechanics not resonating | Medium | High | Early playtesting, iterate based on feedback |
| Pacing issues | High | Medium | Implement time controls, adjustable difficulty |
| Narrative coherence | Medium | High | Regular narrative review sessions, maintain design bible |

---

## 8. Tools & Resources

### 8.1 Development Tools
- **Engine**: Godot 4.4
- **Version Control**: Git with GitHub/GitLab
- **Project Management**: Trello/Linear
- **Art Pipeline**: Aseprite (pixel art) or Blender (3D)
- **Audio**: Audacity, FMOD/Wwise integration

### 8.2 Asset Resources
- **Kenney Game Assets**: CC0 licensed assets for prototyping
- **OpenGameArt**: Additional free assets
- **Freesound.org**: Sound effects library
- **Incompetech**: Royalty-free music

### 8.3 Godot-Specific Resources
- **Dialogic Plugin**: Dialogue system management
- **GodotSteam**: Steam integration (future)
- **Godot Jolt**: Physics optimization
- **Debug Draw 3D**: Visual debugging tools

---

## 9. Code Standards & Conventions

### 9.1 GDScript Style Guide
```gdscript
# Class documentation
## Brief description of the class purpose
class_name ClassName
extends BaseClass

# Signals (alphabetical)
signal example_signal(parameter: Type)

# Enums (SCREAMING_SNAKE_CASE)
enum StateType {
    IDLE,
    ACTIVE,
    DISABLED
}

# Constants (SCREAMING_SNAKE_CASE)
const MAX_RAGE: float = 100.0

# Export variables (snake_case)
@export var example_export: int = 0

# Public variables (snake_case)
var public_var: String = ""

# Private variables (_snake_case)
var _private_var: bool = false

# Onready variables (snake_case)
@onready var child_node: Node = $ChildNode

# Virtual methods (override parent)
func _ready() -> void:
    pass

# Public methods (snake_case)
func public_method(param: Type) -> ReturnType:
    pass

# Private methods (_snake_case)
func _private_method() -> void:
    pass
```

### 9.2 Scene Organization
- One scene per major game object
- Components as child scenes
- Consistent naming hierarchy
- Clear node purposes

### 9.3 Resource Management
- Resources for data models
- Proper preloading for performance
- Clear resource dependencies
- Avoid circular references

---

## 10. Testing Strategy

### 10.1 Unit Testing
- Test core systems in isolation
- Automated test suite for critical paths
- Mock objects for dependencies

### 10.2 Integration Testing
- Scene transition testing
- Save/load verification
- Dialogue flow validation

### 10.3 Playtesting Protocol
- Weekly internal playtests
- Documented feedback forms
- A/B testing for critical mechanics
- Analytics integration for metrics

---

## Appendices

### A. Emotional State Formulas
```gdscript
# Rage accumulation
rage_delta = base_rage * (1 + overwhelm_modifier) * time_delta

# Suppression transfer
reservoir_increase = rage_level * suppression_efficiency
rage_decrease = rage_level

# Pattern influence
pattern_modifier = 1.0 + (pattern_count * 0.1)
```

### B. Dialogue Pattern Definitions
- **PEACEMAKER**: Avoiding conflict, managing others' emotions
- **INTELLECTUAL**: Deflecting to logic, avoiding emotional content
- **JUDGE**: Direct criticism, confrontational
- **VULNERABLE**: Genuine emotional expression
- **DEFLECTOR**: Changing subject, avoiding engagement

### C. Mini-Game Difficulty Curves
```
Base Difficulty: 1.0
Rage Modifier: +0.1 per 10% rage
Failure Modifier: +0.5 per failure
Max Difficulty: 3.0
```

---

*End of Technical Specification Document v1.0*