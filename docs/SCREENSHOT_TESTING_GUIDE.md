# Screenshot Testing Guide for Rando's Reservoir

## ✅ USE GODOT'S BUILT-IN SCREENSHOTS ONLY

**DO NOT USE OS SCREENSHOTS (screencapture, etc.)** - They capture the entire desktop which makes it impossible to see what's actually happening in the game.

## Godot Viewport Screenshot Methods

### Method 1: Automated Script Capture
```gdscript
# Create a script that captures the viewport
extends SceneTree

func _init() -> void:
    await process_frame
    await create_timer(1.0).timeout  # Wait for scene to load
    
    var viewport = get_root()
    var image = viewport.get_texture().get_image()
    image.save_png("res://testing/screenshots/current/capture.png")
    print("Screenshot saved!")
    quit()
```

Run with:
```bash
/Applications/Godot.app/Contents/MacOS/Godot --path /Users/matt/Projects/randos-reservoir --script testing/scripts/capture_screenshot.gd [scene_path]
```

### Method 2: In-Game Screenshot Function
Add to any script:
```gdscript
func take_screenshot() -> void:
    var image = get_viewport().get_texture().get_image()
    var timestamp = Time.get_unix_time_from_system()
    var filename = "res://testing/screenshots/current/game_%d.png" % timestamp
    image.save_png(filename)
    print("Screenshot saved to: " + filename)
```

### Method 3: Screenshot Manager Integration
The project already has a ScreenshotManager that can be called:
```gdscript
var screenshot_path = dialogue_system.take_screenshot("test_name", "session")
```

## Screenshot Organization

### Directory Structure
```
testing/screenshots/
├── current/          # Latest test screenshots
│   └── LATEST_CAPTURE.png  # Always the most recent
├── reference/        # Known good screenshots
├── automated/        # Auto-generated during tests
└── archive/          # Old screenshots organized by date
```

### Naming Convention
- `LATEST_CAPTURE.png` - Always overwritten with most recent
- `godot_capture_[timestamp].png` - Timestamped captures
- `[feature]_[state].png` - Descriptive names (e.g., `dialogue_active.png`)

## Current Testing Scripts

Located in `/testing/scripts/`:
- `capture_game_screenshot.gd` - Basic viewport capture
- `test_dialogue_trigger.gd` - Triggers dialogue and captures
- `dialogue_visual_proof.gd` - Comprehensive dialogue testing

## Why Godot Screenshots Only?

1. **Shows ONLY the game window** - No desktop clutter
2. **Exact pixel data** - Can verify UI positioning precisely
3. **Consistent resolution** - Always captures at game resolution
4. **Automated testing** - Can be triggered programmatically
5. **No OS permissions needed** - Works on all platforms

## Quick Test Commands

```bash
# Capture current game state
/Applications/Godot.app/Contents/MacOS/Godot --path /Users/matt/Projects/randos-reservoir --script testing/scripts/capture_game_screenshot.gd

# Test dialogue with screenshot
/Applications/Godot.app/Contents/MacOS/Godot --path /Users/matt/Projects/randos-reservoir --script testing/scripts/test_dialogue_trigger.gd src/scenes/demo/dialogue_demo.tscn

# View latest capture
open testing/screenshots/current/LATEST_CAPTURE.png
```

## Current Issue Status

As of testing, the dialogue system components are:
- ✅ DialogueSystem initialized and visible
- ✅ Character portrait showing (cyan square)
- ✅ Character name showing ("Rando")
- ❌ **Dialogue box panel NOT visible despite StyleBoxFlat being added**

The dialogue box positioning and styling need further investigation to determine why the panel background isn't rendering.