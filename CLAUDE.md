# CLAUDE.md - Rando's Reservoir Development Rules & Architecture

## 🚀 SESSION START PROTOCOL 🚀

**EVERY new session MUST begin with:**
1. Read this CLAUDE.md file completely
2. Read `.claude/todos/current.md` for current state and pending tasks
3. Continue with pending tasks using appropriate agents

**Single Source of Truth**: `.claude/todos/current.md` contains ALL current context

## 🚨 MANDATORY AGENT-BASED WORKFLOW 🚨

### ⚠️ AUTOMATIC WORKFLOW - ENFORCED BY HOOKS ⚠️

**EVERY feature request MUST automatically trigger this workflow:**

1. **todo-manager agent** → Track task and persist to disk (BLOCKS code without this!)
2. **deep-research agent** → Analyze existing code and patterns first
3. **godot-specialist agent** → Implement Godot-specific features
4. **scene-builder agent** → Handle scene composition and node hierarchies
5. **shader-specialist agent** → Create visual effects when needed

**ENFORCEMENT HOOKS ACTIVE:**
- **enforce-todo-tracking.sh** - BLOCKS Write/Edit if todo-manager not invoked recently
- **check-godot-patterns.sh** - Ensures GDScript conventions are followed
- Todo tracking is MANDATORY - you cannot write code without it

### 🤖 AGENT INVOCATION IS MANDATORY

When user requests ANY feature or fix:
```
1. IMMEDIATELY invoke todo-manager to track
2. IMMEDIATELY invoke appropriate specialist agent
3. DO NOT write any code yourself without agent guidance
4. DO NOT proceed without proper analysis
```

## 🤖 AGENT SELECTION MATRIX

### Which Agent to Use When:

| Task Type | Primary Agent | Support Agent |
|-----------|--------------|---------------|
| Game Logic | godot-specialist | deep-research |
| Scene Creation | scene-builder | godot-specialist |
| Visual Effects | shader-specialist | godot-specialist |
| UI/Menus | godot-specialist | scene-builder |
| Physics/Collision | godot-specialist | deep-research |
| Save System | godot-specialist | deep-research |
| Audio | godot-specialist | scene-builder |
| Animation | godot-specialist | scene-builder |
| Complex Analysis | deep-research | claude-code-expert |
| Project Setup | claude-code-expert | todo-manager |

## 🎮 Godot 4 Project Architecture

### Tech Stack
- **Engine**: Godot 4.3+ (GDScript primary, C# support)
- **Version Control**: Git with LFS for assets
- **Testing**: GUT (Godot Unit Testing) framework
- **Assets**: Organized by type (sprites, audio, fonts, etc.)
- **Scenes**: Component-based architecture

### Directory Structure
```
randos-reservoir/
├── project.godot        # Project configuration
├── scenes/             # Scene files (.tscn)
│   ├── main/          # Main game scenes
│   ├── ui/            # UI scenes and components
│   ├── entities/      # Reusable entity scenes
│   └── levels/        # Level scenes
├── scripts/           # GDScript files (.gd)
│   ├── systems/       # Core game systems
│   ├── components/    # Reusable components
│   ├── ui/           # UI controllers
│   └── autoload/     # Singleton scripts
├── resources/        # Resource files (.tres)
│   ├── themes/       # UI themes
│   ├── materials/    # Materials and shaders
│   └── data/         # Game data resources
├── assets/           # Raw assets
│   ├── sprites/      # Image files
│   ├── audio/        # Sound and music
│   ├── fonts/        # Font files
│   └── models/       # 3D models (if applicable)
├── addons/           # Godot plugins
└── tests/            # GUT test files
```

### Core Principles
1. **Scene Inheritance**: Use scene inheritance for variants
2. **Signals over Direct Calls**: Decouple with signals
3. **Resource-Based Data**: Use .tres files for configuration
4. **Autoload for Singletons**: Global systems as autoloads
5. **Node Groups for Queries**: Use groups for efficient lookups
6. **Component Pattern**: Small, reusable scene components

## 🧪 Testing Strategy

### GUT Testing Framework
```gdscript
# Test file structure
extends GutTest

func before_each():
    # Setup for each test
    pass

func test_example():
    assert_eq(2 + 2, 4)
    
func test_signal_emission():
    watch_signals(node)
    node.do_something()
    assert_signal_emitted(node, "signal_name")
```

### Test Categories
1. **Unit Tests** - Individual functions and classes
2. **Integration Tests** - System interactions
3. **Scene Tests** - Scene loading and behavior
4. **Performance Tests** - Frame rate and memory

## 📝 GDScript Conventions

### Code Style
```gdscript
# Class naming: PascalCase
class_name PlayerController
extends CharacterBody2D

# Constants: UPPER_SNAKE_CASE
const MAX_SPEED = 300.0
const JUMP_VELOCITY = -400.0

# Variables: snake_case
var health: int = 100
var is_jumping: bool = false

# Private variables: _prefixed
var _internal_state: Dictionary = {}

# Signals: snake_case
signal health_changed(new_health: int)
signal player_died

# Functions: snake_case
func take_damage(amount: int) -> void:
    health -= amount
    health_changed.emit(health)
    
# Private functions: _prefixed
func _ready() -> void:
    _initialize_components()
    
# Static typing always
func calculate_damage(base: float, multiplier: float) -> int:
    return int(base * multiplier)
```

### Node Path Best Practices
```gdscript
# Use @onready for node references
@onready var sprite: Sprite2D = $Sprite2D
@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var anim_player: AnimationPlayer = $AnimationPlayer

# Use NodePath exports for flexibility
@export var target_path: NodePath
@onready var target = get_node(target_path)

# Group nodes for batch operations
func _ready():
    add_to_group("enemies")
    
func damage_all_enemies():
    for enemy in get_tree().get_nodes_in_group("enemies"):
        enemy.take_damage(10)
```

## 🎯 Performance Guidelines

### Optimization Rules
1. **Object Pooling**: Reuse frequently spawned objects
2. **LOD System**: Use visibility ranges for complex scenes
3. **Texture Atlases**: Combine small textures
4. **Occlusion Culling**: Hide off-screen elements
5. **Signal Caching**: Store signal connections
6. **Physics Optimization**: Use Area2D over RigidBody2D when possible

### Performance Monitoring
```gdscript
# Monitor performance in debug builds
func _ready():
    if OS.is_debug_build():
        Performance.add_custom_monitor("game/entities", _get_entity_count)
        
func _get_entity_count():
    return get_tree().get_nodes_in_group("entities").size()
```

## 🔄 Save System Architecture

### Save Data Structure
```gdscript
# Save game resource
class_name SaveGame
extends Resource

@export var player_data: Dictionary = {}
@export var level_progress: Array = []
@export var timestamp: float = 0.0

func save_to_file(path: String) -> void:
    ResourceSaver.save(self, path)
    
static func load_from_file(path: String) -> SaveGame:
    if ResourceLoader.exists(path):
        return ResourceLoader.load(path) as SaveGame
    return null
```

## 🎨 Shader Development

### Shader Template
```shader
shader_type canvas_item;

uniform float intensity : hint_range(0.0, 1.0) = 0.5;
uniform sampler2D noise_texture;

void fragment() {
    vec4 tex = texture(TEXTURE, UV);
    vec4 noise = texture(noise_texture, UV);
    COLOR = mix(tex, noise, intensity);
}
```

## 🚀 Build & Export

### Export Presets
- **Windows**: 64-bit, embed PCK
- **Mac**: Universal binary, sign and notarize
- **Linux**: 64-bit AppImage
- **Web**: HTML5 with threads disabled
- **Mobile**: Separate APK/AAB for Android, IPA for iOS

### Build Commands
```bash
# Debug build
godot --export-debug "Windows Desktop" builds/windows/game.exe

# Release build
godot --export-release "Windows Desktop" builds/windows/game.exe

# Run tests
godot -s addons/gut/gut_cmdln.gd -gtest=res://tests/
```

## 🔴 INSTANT FAILURE CONDITIONS

If you do ANY of these, STOP immediately:
- Writing GDScript without type hints
- Not using signals for decoupling
- Creating scenes without proper node structure
- Ignoring Godot's node lifecycle
- Not using @onready for node references
- Direct node access instead of groups/signals
- **NOT USING AGENTS FOR IMPLEMENTATION**

## 📊 Performance Standards

### Target Metrics
- Frame Rate: 60 FPS stable (30 FPS minimum)
- Load Time: <3 seconds for any scene
- Memory: <500MB for 2D games, <2GB for 3D
- Input Latency: <16ms response time

## 🔒 Security & Best Practices

### Input Validation
```gdscript
# Sanitize all user input
func set_player_name(name: String) -> void:
    # Remove special characters
    var sanitized = name.strip_edges()
    sanitized = sanitized.substr(0, min(20, sanitized.length()))
    player_name = sanitized
```

### Network Security (if multiplayer)
- Validate all RPC calls
- Never trust client data
- Use encryption for sensitive data
- Implement rate limiting

## 🔄 Session Recovery

### Todo Persistence
All todos are automatically saved to `.claude/todos/current.md` after every update. If session crashes:
1. Read `.claude/todos/current.md`
2. Check "Working On" section
3. Resume from last known state
4. Continue with pending items

### Context Files to Read on Session Start:
- This file (CLAUDE.md)
- `.claude/todos/current.md`
- Current feature's script files
- Related scene files

## 🏁 Quick Start Checklist

When implementing a new feature:
- [ ] Read this CLAUDE.md file
- [ ] Use todo-manager agent to track tasks
- [ ] Use deep-research agent to understand existing patterns
- [ ] Use appropriate specialist agent for implementation
- [ ] Follow GDScript conventions with type hints
- [ ] Create reusable scene components
- [ ] Add to appropriate node groups
- [ ] Write GUT tests if applicable
- [ ] Profile performance impact
- [ ] Update documentation
- [ ] Commit with descriptive message

## 📊 Metrics We Track

### Code Quality:
- Type hint coverage (target: 100%)
- Signal usage vs direct calls
- Scene inheritance depth (max: 3)
- Script line count (target: <200 per file)

### Performance:
- Frame time (target: <16ms)
- Draw calls (target: <1000 for 2D)
- Physics bodies active (target: <100)
- Memory allocation per frame

---

**Remember**: The goal is to build performant, maintainable Godot games that follow engine best practices and leverage its powerful scene system.