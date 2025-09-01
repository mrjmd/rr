# CLAUDE.md - Rando's Reservoir Development Rules

## 🚀 SESSION START PROTOCOL
1. Read this CLAUDE.md file completely
2. Read `.claude/todos/current.md` for current state
3. Use agents for ALL implementation work

**Single Source of Truth**: `.claude/todos/current.md`

## 🚨 MANDATORY AGENT WORKFLOW - ENFORCED BY HOOKS
**EVERY feature request MUST trigger:**
1. **todo-manager** → Track task (BLOCKS without this!)
2. **deep-research** → Analyze existing patterns
3. **[specialist]** → Implement per matrix below
4. **godot-tester** → Verify with SCREENSHOTS (AUTOMATIC!)

**Hooks will BLOCK progress without proper agent usage and testing**

## 🤖 AGENT SELECTION
| Task Type | Primary Agent | Testing |
|-----------|--------------|---------|
| Game Logic | godot-specialist | godot-tester |
| Scene Creation | scene-builder | godot-tester |
| Visual Effects | shader-specialist | godot-tester |
| UI/Menus | godot-specialist | godot-tester |
| Bug Fixing | godot-tester → specialist | REQUIRED |

## ✅ VERIFICATION IS MANDATORY

### MUST PROVIDE SCREENSHOT PROOF
**See SCREENSHOT_TESTING_GUIDE.md for methods**
- Use GODOT viewport captures ONLY (NOT OS screenshots)
- Capture at key points: before/during/after changes
- Save to `testing/screenshots/current/`

### Quick Verification Commands:
```bash
# Capture viewport screenshot
/Applications/Godot.app/Contents/MacOS/Godot --path /Users/matt/Projects/randos-reservoir --script testing/scripts/capture_game_screenshot.gd

# Test with automated screenshots
/Applications/Godot.app/Contents/MacOS/Godot --path /Users/matt/Projects/randos-reservoir --script testing/scripts/test_dialogue_trigger.gd [scene]

# View latest capture
open testing/screenshots/current/LATEST_CAPTURE.png
```

**NO CLAIMING SUCCESS WITHOUT VISUAL PROOF**

## 📝 GDSCRIPT CONVENTIONS
```gdscript
# MANDATORY:
- Type hints ALWAYS: var health: int = 100
- Signals over direct: signal health_changed(new_health: int)
- @onready for nodes: @onready var sprite: Sprite2D = $Sprite2D
- Private with _: var _internal_state: Dictionary
- Groups for queries: add_to_group("enemies")
- Scene inheritance for variants
- Component-based architecture
```

## 🎮 ESSENTIAL COMMANDS
```bash
# Run game
/Applications/Godot.app/Contents/MacOS/Godot --path /Users/matt/Projects/randos-reservoir

# Debug with output
/Applications/Godot.app/Contents/MacOS/Godot --verbose --path /Users/matt/Projects/randos-reservoir --log-file debug.log

# Quick validation
/Applications/Godot.app/Contents/MacOS/Godot --headless --quit --check-only

# Run specific scene
/Applications/Godot.app/Contents/MacOS/Godot --path /Users/matt/Projects/randos-reservoir res://scenes/[scene].tscn
```

## 📊 PERFORMANCE TARGETS
- 60 FPS stable (30 FPS minimum)
- <16ms frame time
- <500MB memory (2D)
- 100% type hint coverage
- <200 lines per script

## 🔴 INSTANT FAILURE CONDITIONS
- No type hints in GDScript
- No signals for decoupling
- Direct node access instead of groups
- Not using @onready for nodes
- **NOT USING AGENTS**
- **NO SCREENSHOT VERIFICATION**
- **CLAIMING SUCCESS WITHOUT PROOF**

## 🔄 SESSION RECOVERY
1. Read `.claude/todos/current.md`
2. Check "IN PROGRESS" section
3. Resume from last state
4. Continue pending tasks

## 📁 PROJECT STRUCTURE
```
src/
├── scenes/     # .tscn files
├── scripts/    # .gd files  
├── resources/  # .tres files
assets/         # sprites, audio, fonts
testing/        # tests and screenshots
```

## ✅ DEFINITION OF DONE
- [ ] Feature implemented via agents
- [ ] Type hints 100%
- [ ] Signals used for decoupling
- [ ] Screenshot proof captured
- [ ] Tests pass (if applicable)
- [ ] No console errors
- [ ] Performance targets met

---
**For detailed references see:**
- `SCREENSHOT_TESTING_GUIDE.md` - Testing methods
- `godot-commands-reference.md` - Full command list
- `architecture-reference.md` - Detailed structure