# Proof of Concept: Walking Around Kitchen

## Goal for Today
**Create a playable scene where you can walk around a kitchen. That's it.**

## What This Proves
- Godot project is properly configured
- Basic scene structure works
- Player movement feels good
- Sprite rendering pipeline works
- Can transition from menu to gameplay

## Scope: 4-6 Hours of Work

### Hour 1-2: Kitchen Scene
- [ ] Create `src/scenes/poc/kitchen.tscn`
- [ ] Add ColorRect for floor (brown/tan)
- [ ] Add walls using StaticBody2D with collision
- [ ] Add a table sprite (just a rectangle)
- [ ] Add a crib sprite (just a rectangle)
- [ ] Position camera to show whole room

### Hour 3-4: Player Movement
- [ ] Create `src/scripts/poc/player_movement.gd`
- [ ] Add CharacterBody2D for player
- [ ] Add placeholder sprite (even just a circle)
- [ ] Implement 8-direction movement
- [ ] Add collision with walls
- [ ] Smooth movement feel (acceleration/deceleration)

### Hour 5-6: Polish & Integration
- [ ] Connect main menu "New Game" to kitchen scene
- [ ] Add ESC to return to menu
- [ ] Add debug text showing position
- [ ] Test build and make sure it runs
- [ ] Take screenshot to celebrate

## File Structure (Minimal)
```
src/
  scenes/
    poc/
      kitchen.tscn       # The main playable scene
      player.tscn        # Player scene (can instantiate in kitchen)
  scripts/
    poc/
      player_movement.gd # Movement logic
      kitchen.gd         # Scene management (if needed)
```

## The Code: player_movement.gd
```gdscript
extends CharacterBody2D

const SPEED: float = 200.0
const ACCELERATION: float = 800.0
const FRICTION: float = 800.0

@onready var sprite: Sprite2D = $Sprite2D

func _physics_process(delta: float) -> void:
    var input_vector: Vector2 = Vector2.ZERO
    
    # Get input
    input_vector.x = Input.get_axis("ui_left", "ui_right")
    input_vector.y = Input.get_axis("ui_up", "ui_down")
    input_vector = input_vector.normalized()
    
    # Apply movement
    if input_vector != Vector2.ZERO:
        velocity = velocity.move_toward(input_vector * SPEED, ACCELERATION * delta)
        # Optional: flip sprite based on direction
        if input_vector.x != 0:
            sprite.flip_h = input_vector.x < 0
    else:
        velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
    
    move_and_slide()
    
func _input(event: InputEvent) -> void:
    if event.is_action_pressed("ui_cancel"):  # ESC key
        get_tree().change_scene_to_file("res://src/scenes/ui/main_menu.tscn")
```

## Connecting to Existing Menu

In your main menu's "New Game" button:
```gdscript
func _on_new_game_pressed() -> void:
    get_tree().change_scene_to_file("res://src/scenes/poc/kitchen.tscn")
```

## What We're NOT Doing Today
- ❌ Baby interaction
- ❌ Any meters
- ❌ Any tasks
- ❌ Animations beyond basic movement
- ❌ Sound effects
- ❌ Multiple rooms
- ❌ Save/load
- ❌ Fancy graphics

## Success Criteria for POC
- [x] Can launch game from menu
- [x] Can walk around kitchen with arrow keys
- [x] Can't walk through walls
- [x] Can press ESC to return to menu
- [x] Movement feels responsive
- [x] No crashes or errors

## Assets Needed (Absolute Minimum)
For today, just use Godot's built-in tools:
- **Floor**: ColorRect (brown: #8B4513)
- **Walls**: ColorRect (darker brown: #654321)  
- **Player**: Icon.svg that comes with Godot (or draw a circle)
- **Table**: ColorRect (wood color: #DEB887)
- **Crib**: ColorRect (white: #FFFFFF)

No need for actual sprites yet!

## Next Steps After POC Works

Only after you can walk around the kitchen:

### Tomorrow (POC+)
- Add actual sprite for player
- Add baby sprite in crib (static)
- Add kitchen appliances (coffee maker, sink)
- Better collision shapes

### Day 3 (Towards MVP)
- Add pickup animation (just sprite change)
- Add interact prompt ("Press E")
- Add one interactive object

### Day 4-5 (MVP Begins)
- Add fuss meter UI
- Add baby pickup mechanic
- Add first task

## Testing the POC

### Manual Test (2 minutes)
1. Launch game
2. Click "New Game"
3. Walk to all four corners of room
4. Try to walk through walls (should fail)
5. Press ESC
6. Verify back at main menu

If all that works, POC is complete!

## Common Issues and Solutions

### "Scene won't load"
- Check file path in change_scene_to_file()
- Make sure scene is saved
- Check console for errors

### "Movement feels bad"
- Adjust SPEED constant
- Try different ACCELERATION values
- Add diagonal movement normalization

### "Can walk through walls"
- Add CollisionShape2D to walls
- Add CollisionShape2D to player
- Make sure walls have StaticBody2D

### "Game crashes on ESC"
- Check main_menu.tscn path
- Make sure main menu scene exists
- Add null check before scene change

## The Development Mantra for Today

**"Can I walk around a room? Yes? Ship it."**

Don't add ANYTHING else until this works perfectly. No features, no polish, just movement in a box.

## Estimated Time Investment

**If you start now:**
- 1 hour: Scene setup
- 1 hour: Movement code  
- 30 min: Menu integration
- 30 min: Testing and fixes
- **Total: 3 hours to playable POC**

**If you get distracted by features:**
- ∞ hours and nothing to show

## Your Checklist for Today

- [ ] Open Godot
- [ ] Create kitchen.tscn
- [ ] Add floor and walls
- [ ] Create player scene
- [ ] Write movement script
- [ ] Connect to menu
- [ ] Test it works
- [ ] Take screenshot
- [ ] Commit to git
- [ ] Feel accomplished

That's it. Don't do anything else. Just make a character walk in a room.

Tomorrow we can add more. Today, just walk.