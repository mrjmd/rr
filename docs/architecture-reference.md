# Architecture Reference

## Directory Structure
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

## Save System Architecture

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

### Save File Locations
- User saves: `user://saves/`
- Quick saves: `user://quicksave.tres`
- Auto saves: `user://autosave.tres`
- Settings: `user://settings.cfg`

## Shader Development

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

### Common Shader Effects
- Screen transitions (fade, wipe, dissolve)
- UI effects (glow, pulse, shake)
- Environmental effects (rain, fog, heat distortion)
- Post-processing (color grading, vignette)

## Node Path Best Practices

### Proper Node References
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

## Canvas Layer Structure
```
Layer Hierarchy:
├── FadeTransition (Layer 1000) - Scene transitions
├── HUD (Layer 200) - Game UI elements  
├── DialogueSystem (Layer 150) - Dialogue interface
└── Game World (Layer 0) - Main game content
```

## Signal Architecture

### EventBus Pattern
```gdscript
# Centralized signal hub
extends Node

# Game events
signal level_started(level_name: String)
signal level_completed()
signal game_paused()
signal game_resumed()

# Dialogue events
signal dialogue_started(dialogue_id: String)
signal dialogue_ended()
signal choice_made(choice_data: Dictionary)

# Player events
signal player_damaged(amount: int)
signal player_died()
signal emotional_state_changed(new_state: Dictionary)
```

## Performance Guidelines

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

## Security & Best Practices

### Input Validation
```gdscript
# Sanitize all user input
func set_player_name(name: String) -> void:
    var sanitized = name.strip_edges()
    sanitized = sanitized.substr(0, min(20, sanitized.length()))
    player_name = sanitized
```

### Network Security (if multiplayer)
- Validate all RPC calls
- Never trust client data
- Use encryption for sensitive data
- Implement rate limiting

## Export Presets

### Platform Configurations
- **Windows**: 64-bit, embed PCK
- **Mac**: Universal binary, sign and notarize
- **Linux**: 64-bit AppImage
- **Web**: HTML5 with threads disabled
- **Mobile**: Separate APK/AAB for Android, IPA for iOS

### Export Settings
```
Windows:
- Architecture: x86_64
- Embed PCK: true
- Console: false

macOS:
- Universal Binary: true
- Code Signing: required
- Notarization: required

Linux:
- Format: AppImage
- Architecture: x86_64
```