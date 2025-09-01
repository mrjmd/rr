# Player System Setup Guide

## Overview
The player system is a complete CharacterBody2D controller with state machine integration, emotional state support, and proper Godot 4.4 architecture patterns.

## Files Created

### Scripts
- `player_controller.gd` - Main player controller with movement and emotional integration
- `states/player_idle_state.gd` - Idle state behavior
- `states/player_walk_state.gd` - Walking state behavior  
- `states/player_jump_state.gd` - Jumping state behavior
- `states/player_fall_state.gd` - Falling state behavior

### Scene Templates
- `../../../scenes/entities/player/player.tscn.template` - Player scene structure
- `../../../scenes/shared/player_test_scene.tscn.template` - Test scene setup

## Setup Instructions

### 1. Create Player Scene
1. Open Godot editor
2. Create new Scene
3. Add CharacterBody2D as root, rename to "Player"
4. Attach `player_controller.gd` script to root
5. Add child nodes as shown in template:
   ```
   Player (CharacterBody2D) + player_controller.gd
   ├── CollisionShape2D (CapsuleShape2D: radius=16, height=64)
   ├── Sprite2D (PlaceholderTexture2D: 32x64)
   ├── AnimationPlayer 
   └── StateMachine (Node) + state_machine.gd
       ├── PlayerIdleState (Node) + player_idle_state.gd
       ├── PlayerWalkState (Node) + player_walk_state.gd  
       ├── PlayerJumpState (Node) + player_jump_state.gd
       └── PlayerFallState (Node) + player_fall_state.gd
   ```
6. In StateMachine inspector, set initial_state to PlayerIdleState
7. Save as `src/scenes/entities/player/player.tscn`

### 2. Configure Input Actions
Input actions are already configured in project.godot:
- `move_left` - A key / Left Arrow
- `move_right` - D key / Right Arrow  
- `jump` - Space / Up Arrow
- `debug_increase_rage` - 1 key
- `debug_suppress` - 2 key
- `debug_overwhelm` - 3 key

### 3. Create Test Scene
1. Create new Scene with Node2D root
2. Instance player.tscn as child
3. Add StaticBody2D floor for testing
4. Save as test scene

## Features

### Movement System
- **Speed**: 300 pixels/second (configurable)
- **Jump**: -400 velocity with coyote time and jump buffering
- **Gravity**: 980 (project default)
- **Variable jump height**: Release jump button to cut jump short

### State Machine Integration
- **Idle**: Standing still, can transition to walk/jump
- **Walk**: Moving horizontally, can jump while walking  
- **Jump**: Rising after jump, transitions to fall when velocity >= 0
- **Fall**: Falling through air, lands to idle or walk based on input

### Emotional State Integration
- Automatically connects to GameManager.emotional_state
- Movement speed/jump modified by emotional state:
  - Calm: Normal (1.0x speed)
  - Stressed: Faster (1.1x speed) 
  - Overwhelmed: Slower (0.8x speed)
  - Angry: Much faster (1.3x speed)
  - Breaking: Very slow (0.6x speed)
  - Suppressed: Slightly slow (0.9x speed)

### Event System
- Emits player_moved, player_jumped, player_landed signals
- Automatically connects to EventBus for decoupled communication
- State changes broadcast through state machine

### Debug Features
- Debug movement controls (when enabled)
- Emotional state testing with number keys
- Debug prints for state transitions

## API Reference

### Public Methods
```gdscript
func get_movement_direction() -> Vector2  # Current input direction
func is_moving() -> bool                  # True if moving horizontally
func is_grounded() -> bool               # True if on floor
func is_jumping() -> bool                # True if rising
func is_falling() -> bool                # True if falling
func get_current_emotional_state() -> String  # Current emotional state
func trigger_rage_increase(amount: float) -> void     # Add rage externally
func trigger_suppression() -> void       # Trigger suppression externally
func set_movement_enabled(enabled: bool) -> void      # Enable/disable movement
```

### Signals
```gdscript
signal emotional_state_changed(new_state: String)
signal player_moved(direction: Vector2)  
signal player_jumped()
signal player_landed()
```

## Integration with Existing Systems

### GameManager
- Automatically connects to GameManager.emotional_state
- Respects GameManager settings and state

### EventBus  
- Broadcasts all player actions through EventBus
- Listens for relevant global events

### State Machine Framework
- Uses existing src/core/state_machine/ classes
- Follows established state patterns

### EmotionalState Resource
- Directly integrates with rage/reservoir/overwhelm systems
- Responds to emotional threshold changes

## Testing

### Manual Testing
1. Load player_test_scene.tscn
2. Test movement with A/D keys
3. Test jumping with Space
4. Test emotional state changes with 1/2/3 keys
5. Verify state transitions in debug output

### Integration Testing
- Verify emotional state affects movement speed
- Test state machine transitions
- Confirm EventBus signal emission
- Check GameManager integration

## Performance Notes
- Uses move_and_slide() for physics
- Minimal allocations in physics loop
- Efficient state machine updates
- Debug features only active in debug builds

## Future Enhancements
- Animation system integration
- Audio feedback for actions
- Particle effects for emotional states
- More complex movement abilities
- Interaction system integration