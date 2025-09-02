# POC Integration with Existing Systems

## What We Already Have

### ✅ Working Menu System
- Main menu at `src/scenes/ui/menus/main_menu.tscn`
- Pause menu system
- Settings menu
- Scene transition system (SceneManager)

### ✅ Working UI Components  
- Rage and Reservoir meters (we won't use these in POC)
- Dialogue system (we won't use this in POC)
- HUD system (we won't use this in POC)

### ✅ Core Infrastructure
- EventBus for signals
- GameManager for game state
- SceneManager for transitions
- MenuManager for menu navigation

## Integration Points for POC

### 1. Modify Main Menu Start Button (5 minutes)

In `src/scripts/ui/menus/main_menu.gd`, change line 176:
```gdscript
# OLD:
SceneManager.change_scene("airport_montage", SceneManager.TransitionType.FADE_BLACK)

# NEW (for POC):
get_tree().change_scene_to_file("res://src/scenes/poc/kitchen.tscn")
```

Or if you want to keep using SceneManager, register your scene first.

### 2. Create Simple Kitchen Scene Controller

Create `src/scripts/poc/kitchen_controller.gd`:
```gdscript
extends Node2D

func _ready() -> void:
    print("Kitchen POC loaded!")
    # Hide any HUD elements that might auto-load
    if has_node("/root/GameHUD"):
        get_node("/root/GameHUD").hide()

func _input(event: InputEvent) -> void:
    # ESC returns to main menu
    if event.is_action_pressed("ui_cancel"):
        # Use SceneManager if available
        if has_node("/root/SceneManager"):
            get_node("/root/SceneManager").change_scene("main_menu")
        else:
            get_tree().change_scene_to_file("res://src/scenes/ui/menus/main_menu.tscn")
    
    # P opens pause menu (optional for POC)
    if event.is_action_pressed("pause"):
        if has_node("/root/MenuManager"):
            get_node("/root/MenuManager").open_menu("pause_menu")
```

### 3. Project Settings Check (2 minutes)

Make sure these inputs are configured in Project Settings > Input Map:
- `ui_left` (Left Arrow, A)
- `ui_right` (Right Arrow, D)  
- `ui_up` (Up Arrow, W)
- `ui_down` (Down Arrow, S)
- `ui_cancel` (ESC)
- `pause` (P) - optional

### 4. Scene Registration (Optional)

If you want to use the fancy SceneManager transitions:

In `globals/scene_manager.gd`, add your scene:
```gdscript
var scenes: Dictionary = {
    "main_menu": "res://src/scenes/ui/menus/main_menu.tscn",
    "kitchen_poc": "res://src/scenes/poc/kitchen.tscn",  # ADD THIS
    # ... other scenes
}
```

Then in main_menu.gd:
```gdscript
SceneManager.change_scene("kitchen_poc", SceneManager.TransitionType.FADE_BLACK)
```

## What NOT to Connect (Yet)

For the POC, DO NOT integrate:
- ❌ Save/Load system
- ❌ Emotional meters
- ❌ Dialogue system
- ❌ Settings persistence
- ❌ Audio system
- ❌ Achievement system
- ❌ Any other game systems

Just menu → kitchen → menu. That's it.

## Testing the Integration

### Quick Test (1 minute)
1. Run game
2. Main menu appears
3. Click "Start Game"
4. Kitchen loads
5. Walk around
6. Press ESC
7. Back at main menu

If that works, integration is complete!

## File Structure After Integration

```
src/
  scenes/
    poc/
      kitchen.tscn        # Your new scene
      player.tscn         # Player prefab
    ui/
      menus/
        main_menu.tscn    # Existing, modified
  scripts/
    poc/
      kitchen_controller.gd  # Scene management
      player_movement.gd     # Movement logic
    ui/
      menus/
        main_menu.gd      # Modified line 176
```

## Common Integration Issues

### "Scene won't load from menu"
```gdscript
# Debug: Add print statement before scene change
print("Attempting to load kitchen POC...")
print("File exists: ", FileAccess.file_exists("res://src/scenes/poc/kitchen.tscn"))
```

### "Can't return to menu"
```gdscript
# Make sure ui_cancel is mapped to ESC in Project Settings
# Or use direct key check:
if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
```

### "Other systems interfering"
```gdscript
# In kitchen_controller.gd _ready():
# Disable all unnecessary autoloads
if has_node("/root/GameHUD"):
    get_node("/root/GameHUD").queue_free()
if has_node("/root/DialogueSystem"):
    get_node("/root/DialogueSystem").set_process(false)
```

## The Minimal Integration Approach

If you want ZERO integration complexity:

1. **Don't modify anything existing**
2. **Run kitchen.tscn directly from Godot editor**
3. **Use F6 to test the scene in isolation**
4. **Add menu integration later**

This is actually the smartest approach for POC!

## Development Order for Today

1. **Build kitchen scene first** (1 hour)
2. **Test it works in isolation** (F6 in editor)
3. **Add player movement** (1 hour)
4. **Test movement works**
5. **Only then integrate with menu** (15 minutes)

Don't integrate until the scene works standalone!

## Your Integration Checklist

- [ ] Kitchen scene runs standalone (F6)
- [ ] Player moves correctly
- [ ] Walls have collision
- [ ] ESC input detected (just print for now)
- [ ] Modify main_menu.gd line 176
- [ ] Test menu → kitchen transition
- [ ] Test kitchen → menu return
- [ ] Commit working POC

That's literally all the integration needed. Keep it simple!