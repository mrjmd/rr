# What to Build TODAY - Quick Reference

## Hour 1: Create the Kitchen Scene

### Step 1: Create Scene Structure
```
1. Open Godot
2. Right-click in FileSystem → New Scene → 2D Scene
3. Save as: src/scenes/poc/kitchen.tscn
4. Rename root node to "Kitchen"
```

### Step 2: Add Floor and Walls
```
Kitchen (Node2D)
├── Floor (ColorRect)
│   └── Size: 800x600
│   └── Color: #8B4513 (brown)
│   └── Position: Center it
│
├── Walls (Node2D)
│   ├── TopWall (StaticBody2D)
│   │   └── ColorRect (800x20, dark brown)
│   │   └── CollisionShape2D (Rectangle)
│   │
│   ├── BottomWall (StaticBody2D)
│   │   └── ColorRect (800x20, dark brown)
│   │   └── CollisionShape2D (Rectangle)
│   │
│   ├── LeftWall (StaticBody2D)
│   │   └── ColorRect (20x600, dark brown)
│   │   └── CollisionShape2D (Rectangle)
│   │
│   └── RightWall (StaticBody2D)
│       └── ColorRect (20x600, dark brown)
│       └── CollisionShape2D (Rectangle)
```

### Step 3: Add Camera
```
├── Camera2D
    └── Position: Center of room
    └── Enabled: true
```

## Hour 2: Create the Player

### Step 1: Create Player Scene
```
1. New Scene → Other Node → CharacterBody2D
2. Save as: src/scenes/poc/player.tscn
3. Structure:

Player (CharacterBody2D)
├── Sprite2D
│   └── Texture: Use icon.svg for now
│   └── Scale: (0.5, 0.5)
│
├── CollisionShape2D
    └── Shape: RectangleShape2D
    └── Size: Match sprite
```

### Step 2: Add Movement Script
Create `src/scripts/poc/player_movement.gd`:
```gdscript
extends CharacterBody2D

const SPEED = 200.0

func _physics_process(_delta):
    var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
    velocity = input_dir * SPEED
    move_and_slide()
```

### Step 3: Add Player to Kitchen
```
1. Open kitchen.tscn
2. Instance player.tscn (drag from FileSystem)
3. Position in center of room
```

## Hour 3: Test and Polish

### Test Checklist
- [ ] Press F6 to run kitchen scene
- [ ] Arrow keys move player
- [ ] Can't walk through walls
- [ ] Movement feels good

### Quick Polish (If Time)
- [ ] Adjust player speed constant
- [ ] Center camera properly
- [ ] Add a table ColorRect (just decoration)
- [ ] Add a crib ColorRect (just decoration)

## Integration (Only After It Works)

### Minimal Integration
In `src/scripts/ui/menus/main_menu.gd` line 176:
```gdscript
# Change from:
SceneManager.change_scene("airport_montage", SceneManager.TransitionType.FADE_BLACK)
# To:
get_tree().change_scene_to_file("res://src/scenes/poc/kitchen.tscn")
```

### Add ESC to Return
In player_movement.gd:
```gdscript
func _input(event):
    if event.is_action_pressed("ui_cancel"):
        get_tree().change_scene_to_file("res://src/scenes/ui/menus/main_menu.tscn")
```

## Commands You'll Need

### In Godot Editor
- `F6` - Run current scene
- `F5` - Run project from main
- `Ctrl+S` - Save scene
- `Ctrl+Shift+S` - Save all

### Scene Tree Right-Click Menu
- "Add Child Node" - Add nodes
- "Instance Child Scene" - Add player.tscn to kitchen
- "Change Type" - Convert node types

## If You Get Stuck

### Movement Not Working?
1. Check Input Map in Project Settings
2. Make sure player has CollisionShape2D
3. Check script is attached to player

### Can Walk Through Walls?
1. Walls need StaticBody2D
2. StaticBody2D needs CollisionShape2D child
3. CollisionShape2D needs actual shape resource

### Scene Won't Load?
1. Check file path is correct
2. Make sure scene is saved
3. Check console for errors

## Time Estimate

**If you focus:**
- 30 min: Empty room with walls
- 30 min: Player that moves
- 30 min: Testing and fixing
- **Total: 1.5 hours to working POC**

**If you get distracted by features:**
- ∞ hours

## The Only Goal Today

✅ **Success**: A character walks around an empty room
❌ **Failure**: Anything more complex than that

Keep it simple. Ship it today.