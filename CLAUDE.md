# CLAUDE.md - Rando's Reservoir Development Rules

## 🚀 SESSION START PROTOCOL
1. Read this CLAUDE.md file completely
2. Read `.claude/todos/current.md` for current state
3. Use agents for ALL implementation work

**Single Source of Truth**: `.claude/todos/current.md`

## 🎯 GET SHIT DONE PROTOCOL
1. Stop making excuses
2. Run the actual tests
3. Read the actual screenshots
4. Fix what's broken
5. Move on to real features

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

### SCREENSHOT VERIFICATION PROTOCOL - ENFORCED
**CRITICAL: You MUST actually READ and ANALYZE each screenshot**

#### Step 1: TAKE Screenshot
- Use GODOT viewport captures ONLY (NOT OS screenshots)
- Save to `testing/screenshots/current/`
- Note the filename for verification

#### Step 2: READ Screenshot (MANDATORY)
```bash
# You MUST use Read tool to view EVERY screenshot you take
# NEVER claim verification without this step
Read /Users/matt/Projects/randos-reservoir/testing/screenshots/current/[screenshot.png]
```

#### Step 3: ANALYZE Screenshot
Before claiming success, confirm:
- [ ] Screenshot is NOT black/empty (file size > 10KB typically)
- [ ] UI elements are VISIBLE and match expectations
- [ ] No grey boxes or missing content
- [ ] Screenshot actually shows what you claim it shows

#### Step 4: REPORT Screenshot
ALWAYS include in your response:
- Exact filename: `testing/screenshots/current/[specific_file.png]`
- What the screenshot ACTUALLY shows (not what you hope it shows)
- File size as verification: "22KB file confirms non-empty content"

### Quick Verification Commands:
```bash
# WORKING APPROACH - Use System Events, NOT cliclick for keyboard input!
# Launch Godot maximized for consistent positioning
/Applications/Godot.app/Contents/MacOS/Godot --path /Users/matt/Projects/randos-reservoir --maximized 2>&1 | tee /tmp/godot_output.log &
GODOT_PID=$!
TEE_PID=$(jobs -p | tail -1)

# Wait for load and activate
sleep 5
osascript -e 'tell application "Godot" to activate'
sleep 2

# Send F9 via System Events (key code 101)
osascript -e 'tell application "System Events" to tell process "Godot" to key code 101'

# Other useful key codes:
# ESC = 53, P = 35, Return = 36, Space = 49
# Arrow keys: Left = 123, Right = 124, Up = 126, Down = 125

# IMPORTANT: Kill BOTH processes when done
kill $GODOT_PID $TEE_PID

# NEVER use --headless for UI testing!
# NEVER use --script (forbidden, doesn't work properly)
# cliclick DOES NOT WORK for Godot keyboard input - use System Events!

# View captures in user data (where Godot saves them):
open ~/Library/Application\ Support/Godot/app_userdata/Rando\'s\ Reservoir/testing/screenshots/current/
```

**NO CLAIMING SUCCESS WITHOUT READING THE ACTUAL SCREENSHOT**

### COMPLETION REPORT REQUIREMENTS
Every task completion MUST include:

1. **Screenshot Evidence List**
   ```
   Verification Screenshots:
   - [filename1.png] (size): [what it ACTUALLY shows]
   - [filename2.png] (size): [what it ACTUALLY shows]
   ```

2. **Manual Testing Instructions**
   ```bash
   # Step-by-step commands for user verification
   # Include expected results for each step
   ```

3. **Verification Checklist**
   - [ ] All screenshots viewed with Read tool
   - [ ] Screenshots show expected content (not black)
   - [ ] Console output matches visual state
   - [ ] Manual testing steps provided
   - [ ] No false claims made

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

## 🖱️ INPUT AUTOMATION - CRITICAL RULES
```bash
# ⚠️ IMPORTANT: Different tools for different inputs!
# - System Events: ONLY for keyboard input (F9, ESC, P, etc.)
# - cliclick: ONLY for mouse clicks and movement
# - This split is odd but CONFIRMED through extensive testing

# KEYBOARD INPUT - Use System Events ONLY
osascript -e 'tell application "System Events" to tell process "Godot" to key code 101'  # F9
osascript -e 'tell application "System Events" to tell process "Godot" to key code 53'   # ESC
osascript -e 'tell application "System Events" to tell process "Godot" to key code 35'   # P

# Key codes reference:
# F9 = 101, ESC = 53, P = 35, Return = 36, Space = 49
# Arrows: Left = 123, Right = 124, Up = 126, Down = 125

# MOUSE CLICKS - Use cliclick ONLY
cliclick c:400,350  # Settings button in pause menu (when maximized)
cliclick c:.        # Click at current position

# COORDINATES:
# - Desktop-relative (entire screen, not window-relative)
# - ALWAYS use --maximized for consistent positioning
# - Settings button confirmed at 400,350 when maximized

# COMPLETE WORKING SEQUENCE:
/Applications/Godot.app/Contents/MacOS/Godot --path /Users/matt/Projects/randos-reservoir --maximized 2>&1 | tee /tmp/godot.log &
GODOT_PID=$!
TEE_PID=$(jobs -p | tail -1)
sleep 5
osascript -e 'tell application "Godot" to activate'
sleep 2
osascript -e 'tell application "System Events" to tell process "Godot" to key code 53'  # Open pause
sleep 2
cliclick c:400,350  # Click Settings button
# CLEANUP: Must kill BOTH processes
kill $GODOT_PID $TEE_PID
```

## 🎮 ESSENTIAL COMMANDS
```bash
# Run game (use --maximized for consistent testing)
/Applications/Godot.app/Contents/MacOS/Godot --path /Users/matt/Projects/randos-reservoir --maximized

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
- **MAKING EXCUSES ABOUT VERIFICATION**
- **NOT RUNNING PROPER GUI TESTS**
- **CLAIMING "CAN'T VERIFY" WHEN YOU CAN**
- **CREATING STANDALONE TEST SCRIPTS**
- **NOT USING F9 IN-GAME TESTING**
- No type hints in GDScript
- No signals for decoupling
- Direct node access instead of groups
- Not using @onready for nodes
- **NOT USING AGENTS**
- **NO SCREENSHOT VERIFICATION**
- **CLAIMING SUCCESS WITHOUT READING SCREENSHOTS**
- **REPORTING BLACK SCREENSHOTS AS WORKING**
- **NOT PROVIDING SCREENSHOT FILENAMES TO USER**
- **NOT PROVIDING MANUAL TEST STEPS**

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
- [ ] Screenshot proof captured AND VERIFIED WITH READ TOOL
- [ ] Screenshot filenames reported to user with descriptions
- [ ] Manual testing steps documented for user
- [ ] Tests pass (if applicable)
- [ ] No console errors
- [ ] Performance targets met
- [ ] NO FALSE CLAIMS - only report what screenshots actually show

---
**For detailed references see:**
- `SCREENSHOT_TESTING_GUIDE.md` - Testing methods
- `godot-commands-reference.md` - Full command list
- `architecture-reference.md` - Detailed structure

## 🧪 NO EXCUSES TESTING RULES

### CRITICAL: HOW TO ACTUALLY VERIFY
1. **ALWAYS capture stderr**: Use `2>&1` in bash commands
2. **CHECK LOG FILES**: Look for .log files in project and user directories
3. **VERIFY TIMESTAMPS**: Use `ls -lat` to see if files were just created
4. **READ THE OUTPUT**: If user shows you console output, that's the truth
5. **NEVER ASSUME**: If you can't see it, ask the user to paste it

### YOU CAN AND MUST:
1. **RUN THE FUCKING GAME** - `/Applications/Godot.app/Contents/MacOS/Godot --path /Users/matt/Projects/randos-reservoir`
2. **USE CLICLICK TO PRESS KEYS** - You have it installed!
   ```bash
   # Press F9 to trigger test
   cliclick kp:f9
   # Press ESC
   cliclick kp:esc
   # Press P
   cliclick kp:p
   ```
3. **NO MORE STANDALONE SCRIPTS** - They don't work with --script
4. **READ SCREENSHOTS** - Use Read tool on EVERY screenshot
5. **VERIFY VISUALLY** - Check the actual screenshots

### STOP DOING THIS SHIT:
- Creating standalone test scripts that need --script
- Making scripts that inherit from MainLoop/SceneTree
- Writing new test harnesses when MenuVerifier EXISTS
- FORGETTING ABOUT CLICLICK - YOU HAVE IT
- THE GAME HAS F9 TESTING BUILT IN - USE IT WITH CLICLICK

### NO EXCUSES ACCEPTED FOR:
- "Can't run in background" - Then DON'T run in background
- "Headless doesn't work" - Then DON'T use headless
- "Can't verify" - YES YOU CAN, use the test scripts
- "Window needs focus" - The test scripts handle this

### VERIFICATION CHECKLIST:
- [ ] Test script written that simulates user actions
- [ ] Run test and WAIT for actual output
- [ ] Check timestamps: `ls -lat [directory]` to verify new files
- [ ] Screenshots captured at each step (check file sizes)
- [ ] Screenshots READ with Read tool (ACTUALLY READ THEM)
- [ ] Screenshots show expected UI (not black, size > 10KB)
- [ ] Console output captured with `2>&1`
- [ ] Manual test instructions provided
- [ ] Actual screenshot filenames reported
- [ ] If test fails, FIX IT AND TEST AGAIN