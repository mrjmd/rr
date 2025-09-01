# UI Components Setup Guide

This guide explains how to create the scene files for the emotional state UI components in Godot 4.4.

## Overview

The UI system consists of:
- **RageMeter**: Visual progress bar showing current rage level with color-coded thresholds
- **ReservoirMeter**: Appears after first suppression, shows accumulated suppressed emotions
- **GameHUD**: Container for all UI meters with debug controls
- **TestUIScene**: Test scene for validating UI functionality

## Scene Creation Order

1. Create RageMeter scene first
2. Create ReservoirMeter scene
3. Create GameHUD scene (instances the meter scenes)
4. Create TestUI scene (instances GameHUD)

## 1. RageMeter Scene Creation

**File**: `src/scenes/ui/meters/rage_meter.tscn`
**Script**: `src/scripts/ui/meters/rage_meter.gd`

### Scene Hierarchy:
```
RageMeter (Control)
├── VBoxContainer
│   ├── Label
│   └── ProgressContainer (Control)
│       ├── ProgressBar
│       └── ThresholdMarkers (Control)
└── Tween
```

### Setup Steps:
1. Create new Scene → Control (rename to RageMeter)
2. Attach script: `src/scripts/ui/meters/rage_meter.gd`
3. Add VBoxContainer as child
4. Add Label to VBoxContainer (text: "RAGE")
5. Add Control to VBoxContainer (rename to ProgressContainer)
6. Add ProgressBar to ProgressContainer
7. Add Control to ProgressContainer (rename to ThresholdMarkers)
8. Add Tween as direct child of RageMeter

### Key Settings:
- **RageMeter Control**: Size 220x50, Anchor Top Left
- **VBoxContainer**: Full Rect layout, Separation 5
- **Label**: Center alignment, no autowrap
- **ProgressBar**: Min 0, Max 100, Step 0.1, Size 200x20
- **ThresholdMarkers**: Full Rect layout over ProgressBar

## 2. ReservoirMeter Scene Creation

**File**: `src/scenes/ui/meters/reservoir_meter.tscn`
**Script**: `src/scripts/ui/meters/reservoir_meter.gd`

### Scene Hierarchy:
```
ReservoirMeter (Control)
├── VBoxContainer
│   ├── Label
│   └── ProgressContainer (Control)
│       ├── ProgressBar
│       └── WarningIcon (TextureRect)
└── Tween
```

### Setup Steps:
1. Create new Scene → Control (rename to ReservoirMeter)
2. Attach script: `src/scripts/ui/meters/reservoir_meter.gd`
3. Add VBoxContainer as child
4. Add Label to VBoxContainer (text: "RESERVOIR")
5. Add Control to VBoxContainer (rename to ProgressContainer)
6. Add ProgressBar to ProgressContainer
7. Add TextureRect to ProgressContainer (rename to WarningIcon)
8. Add Tween as direct child of ReservoirMeter

### Key Settings:
- **ReservoirMeter Control**: Size 220x50, Initially Visible: false
- **WarningIcon**: Size 16x16, Anchor Center Right, Initially Visible: false

## 3. GameHUD Scene Creation

**File**: `src/scenes/ui/hud/game_hud.tscn`
**Script**: `src/scripts/ui/hud/game_hud.gd`

### Scene Hierarchy:
```
GameHUD (Control)
├── HUDContainer (MarginContainer)
│   └── VBoxContainer
│       ├── RageMeter (instance)
│       └── ReservoirMeter (instance)
└── DebugPanel (Panel)
```

### Setup Steps:
1. Create new Scene → Control (rename to GameHUD)
2. Attach script: `src/scripts/ui/hud/game_hud.gd`
3. Add MarginContainer (rename to HUDContainer)
4. Set HUDContainer margins: Left 20, Top 20, Right 0, Bottom 0
5. Add VBoxContainer to HUDContainer
6. Instance RageMeter scene in VBoxContainer
7. Instance ReservoirMeter scene in VBoxContainer
8. Add Panel (rename to DebugPanel) as direct child of GameHUD

### Key Settings:
- **GameHUD**: Full Rect layout, Mouse Filter: Pass
- **HUDContainer**: Top Left anchor, margins for screen edge spacing
- **VBoxContainer**: Separation 10px between meters
- **DebugPanel**: Top Right anchor, Size 250x300, Initially visible: false

## 4. TestUI Scene Creation

**File**: `src/scenes/ui/test_ui_scene.tscn`
**Script**: `src/scripts/ui/test_ui_scene.gd`

### Scene Hierarchy:
```
TestUIScene (Control)
├── GameHUD (instance)
└── Background (ColorRect) [Optional]
```

### Setup Steps:
1. Create new Scene → Control (rename to TestUIScene)
2. Attach script: `src/scripts/ui/test_ui_scene.gd`
3. Instance GameHUD scene
4. Optional: Add ColorRect for background contrast

## Testing the UI

1. Set TestUI scene as main scene in Project Settings
2. Run the project
3. Use debug controls:
   - **1**: Increase rage by 15 points
   - **2**: Suppress rage (transfers to reservoir)
   - **3**: Increase overwhelm by 20 points
   - **Enter**: Cycle through threshold levels (25→50→75→90→0)
   - **Escape**: Reset all values
   - **F1**: Toggle HUD visibility
   - **F2**: Toggle debug panel

## Visual Features

### RageMeter:
- **Colors**: Green (calm) → Yellow (25%) → Orange (50%) → Red (75%) → Dark Red (90%)
- **Effects**: Pulsing and shaking when rage > 75%
- **Threshold markers**: Vertical lines at 25%, 50%, 75%, 90%
- **Smooth animations**: 0.5s transitions between values

### ReservoirMeter:
- **Visibility**: Only appears after first suppression
- **Colors**: Blue (low) → Orange (medium) → Red (high) → Dark Red (critical)
- **Warning icon**: Appears at 70%+ reservoir level
- **Effects**: Pulsing when in critical state (85%+)

### Debug Controls:
- **HUD Toggle**: F1 to show/hide entire HUD
- **Debug Panel**: F2 to show debug sliders and controls
- **Live sliders**: Real-time adjustment of rage and reservoir values
- **Quick buttons**: Show reservoir, reset all values

## Integration Points

The UI components automatically connect to:
- **GameManager.emotional_state**: Main data source
- **EventBus**: Signal-based updates
- **Input system**: Debug controls and testing

## Troubleshooting

1. **Meters not updating**: Check GameManager.emotional_state is initialized
2. **Reservoir not appearing**: Trigger suppression first (key 2 or call suppress_rage())
3. **No animations**: Ensure Tween nodes are properly added
4. **Debug panel not showing**: Check OS.is_debug_build() returns true

## Next Steps

After creating the scenes:
1. Test all functionality with the test scene
2. Integrate GameHUD into main game scenes
3. Add additional meters (overwhelm, heat, fuss) as needed
4. Create custom StyleBox resources for unique theming
5. Add sound effects for threshold crossings and visual changes