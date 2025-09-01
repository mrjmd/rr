# Current TODOs
*Updated: 2025-09-01 16:15*
*Session: Dialogue Bug Fix*

## 🚨 CRITICAL BUG - DIALOGUE PANEL INVISIBLE
- **Problem**: Dialogue box panel completely invisible
- **Symptoms**: Only portrait (cyan) and name text render
- **Evidence**: `testing/screenshots/current/02_dialogue_active.png`
- **Files**: `src/scenes/ui/dialogue/dialogue_box.tscn`, `dialogue_box.gd`
- **Next**: Debug StyleBoxFlat rendering on BackgroundPanel

## 🔄 IN PROGRESS
- [ ] Fix invisible dialogue box panel
  - Started: 15:52
  - Issue: StyleBoxFlat configured but not rendering
  
## 📋 PENDING
1. [ ] Test save/load system functionality
2. [ ] Implement debug overlay with sliders
3. [ ] Begin Week 5-6 menu systems

## ✅ TODAY'S COMPLETED
- [x] Document dialogue bug (15:50)
- [x] Screenshot organization system (15:25)
- [x] Dialogue system status corrected (14:15)

## 🔑 KEY CONTEXT
- Previous "working" claims were incorrect
- Dialogue system exists but panel won't render
- Debug state documented in: `.claude/todos/dialogue_system_debug_state.md`

## ⚡ QUICK COMMANDS
```bash
# Test dialogue demo
/Applications/Godot.app/Contents/MacOS/Godot --path /Users/matt/Projects/randos-reservoir src/scenes/demo/dialogue_demo.tscn

# Capture screenshot proof
/Applications/Godot.app/Contents/MacOS/Godot --path /Users/matt/Projects/randos-reservoir --script testing/scripts/capture_game_screenshot.gd
```

## 📊 DEVELOPMENT STATUS
- Week 1-2: Foundation ✅
- Week 3-4: Scenes/Dialogue ⚠️ (panel bug)
- Week 5-6: Menus 📋 (pending)