# Fade Transition Implementation Plan for Rando's Reservoir

## Executive Summary
Our current fade transition implementation is failing because the ColorRect is likely not properly configured within the CanvasLayer hierarchy. Based on 2025 best practices and working examples from successful Godot 4.4 projects, we need to restructure our approach.

## Why The Current Implementation Fails

### Root Causes
1. **Layer Ordering Issue**: The ColorRect may be rendering behind other elements
2. **Anchor/Size Configuration**: ColorRect might not be covering the full viewport
3. **Initial State Problem**: The ColorRect's initial visibility/alpha may be incorrect
4. **Mouse Filter**: ColorRect might be blocking input even when transparent

### Specific Issues in Our Code
- Using `modulate.a` on ColorRect within CanvasLayer (this works, but setup might be wrong)
- No explicit `visible = true` or size configuration in _ready()
- Missing mouse_filter settings to prevent input blocking

## Best Practice Solution (2025)

### Proven Working Structure
Based on successful implementations (Transit, GET, Universal Fade):

```
CanvasLayer (layer = 128)
└── ColorRect (Full Rect anchors)
    Properties:
    - color = Color.BLACK
    - mouse_filter = MOUSE_FILTER_IGNORE
    - visible = true
    - modulate.a starts at 0.0
```

### Implementation Steps

#### 1. Fix the Scene Structure
```gdscript
# fade_transition.tscn structure
[node name="FadeTransition" type="CanvasLayer"]
layer = 128  # Higher than any UI (typically UI is at 1-10)

[node name="ColorRect" type="ColorRect" parent="."]
anchor_right = 1.0
anchor_bottom = 1.0
mouse_filter = 2  # MOUSE_FILTER_IGNORE
color = Color(0, 0, 0, 1)  # Full black
```

#### 2. Update the Script with Signals
```gdscript
class_name FadeTransition
extends CanvasLayer

# Testing signals for precise screenshot timing
signal transition_started
signal transition_halfway  
signal transition_completed

@onready var color_rect: ColorRect = $ColorRect

func _ready():
    # Ensure starting state
    color_rect.visible = true
    color_rect.modulate.a = 0.0  # Start invisible
    color_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
    
func fade_in():
    emit_signal("transition_started")
    color_rect.visible = true
    
    var tween = create_tween()
    tween.tween_property(color_rect, "modulate:a", 1.0, fade_duration/2)
    await tween.finished
    
    emit_signal("transition_halfway")

func fade_out():
    var tween = create_tween()
    tween.tween_property(color_rect, "modulate:a", 0.0, fade_duration/2)
    await tween.finished
    
    emit_signal("transition_completed")
```

#### 3. Signal-Based Testing
```gdscript
# test_fade_with_signals.gd
extends Node

func _ready():
    var fade = preload("res://src/scenes/transitions/fade_transition.tscn").instantiate()
    get_tree().root.add_child(fade)
    
    # Connect signals for precise timing
    fade.transition_started.connect(_on_transition_started)
    fade.transition_halfway.connect(_on_transition_halfway)
    fade.transition_completed.connect(_on_transition_completed)
    
    # Start test
    fade.transition()

func _on_transition_started():
    _save_screenshot("01_fade_started.png")
    
func _on_transition_halfway():
    _save_screenshot("02_fade_black.png")
    
func _on_transition_completed():
    _save_screenshot("03_fade_completed.png")
    
func _save_screenshot(filename: String):
    var img = get_viewport().get_texture().get_image()
    img.save_png("res://test_screenshots/" + filename)
    print("Screenshot saved: ", filename)
```

## Common Pitfalls to Avoid

1. **Don't animate `color.a`** - Use `modulate.a` instead
2. **Don't forget mouse_filter** - Set to IGNORE or it blocks input
3. **Don't use low layer values** - Use 100+ to ensure it's on top
4. **Don't skip initial state setup** - Explicitly set visibility and alpha
5. **Don't use external screencapture** - Use Godot's internal screenshot

## Alternative: Use Proven Addon

If custom implementation continues to fail, consider using the **Transit** addon:
- GitHub: backwardspy/transit
- Godot Asset Library: "Transit (Godot 4)"
- One-line usage: `Transit.change_scene("res://scene.tscn", 0.5)`

## Verification Checklist

- [ ] ColorRect covers full screen (check in editor)
- [ ] CanvasLayer.layer > 100
- [ ] mouse_filter = MOUSE_FILTER_IGNORE
- [ ] Initial modulate.a = 0.0
- [ ] Signals emit at correct times
- [ ] Screenshots show black overlay
- [ ] No input blocking when transparent

## Expected Timeline

1. **Immediate Fix** (5 minutes): Update scene structure and properties
2. **Signal Integration** (10 minutes): Add testing signals
3. **Verification** (5 minutes): Run signal-based test with screenshots
4. **Total**: 20 minutes to working fade transition

## Conclusion

The fade transition should be simple. Our implementation is overcomplicated. Following the proven structure above from successful Godot 4.4 projects will resolve the issue immediately. If not, use the Transit addon which is battle-tested and works out of the box.