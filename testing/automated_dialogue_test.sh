#!/bin/bash
## Automated dialogue system testing with real interaction
## This script launches the game and actually presses keys to test the dialogue system

set -e

GODOT="/Applications/Godot.app/Contents/MacOS/Godot"
PROJECT_PATH="/Users/matt/Projects/randos-reservoir"
SCENE_PATH="src/scenes/demo/dialogue_demo.tscn"
SCREENSHOT_DIR="/Users/matt/Projects/randos-reservoir/testing/screenshots/verification"
TIMESTAMP=$(date "+%Y%m%d_%H%M%S")

echo "=== AUTOMATED DIALOGUE SYSTEM TEST WITH REAL INTERACTION ==="
echo "Timestamp: $TIMESTAMP"
echo "Screenshot directory: $SCREENSHOT_DIR"
echo

# Ensure screenshot directory exists
mkdir -p "$SCREENSHOT_DIR"

# Function to take screenshot with description
take_screenshot() {
    local name="$1"
    local description="$2"
    local filename="automated_${TIMESTAMP}_${name}.png"
    local path="$SCREENSHOT_DIR/$filename"
    
    screencapture -x "$path"
    echo "📸 Screenshot: $filename - $description"
    
    # Verify screenshot was created and get size
    if [ -f "$path" ]; then
        local size=$(stat -f%z "$path")
        echo "   ✅ Saved successfully (${size} bytes)"
        return 0
    else
        echo "   ❌ Failed to save screenshot"
        return 1
    fi
}

# Function to send keystroke and wait
send_key() {
    local key="$1" 
    local description="$2"
    local wait_time="${3:-1}"
    
    echo "⌨️  Sending key: $key - $description"
    cliclick "kp:$key"
    sleep "$wait_time"
}

# Function to wait with progress
wait_with_progress() {
    local seconds="$1"
    local description="$2"
    
    echo "⏳ Waiting ${seconds}s: $description"
    for i in $(seq 1 "$seconds"); do
        echo -n "."
        sleep 1
    done
    echo " ✅"
}

echo "🚀 Launching Godot dialogue demo..."
"$GODOT" --path "$PROJECT_PATH" "$SCENE_PATH" &
GODOT_PID=$!

echo "   Godot PID: $GODOT_PID"

# Wait for app to launch and initialize
wait_with_progress 5 "App initialization"

# Take initial screenshot
take_screenshot "01_initial" "Initial state after launch"

# Test 1: Start guided demo (ENTER key)
echo
echo "=== TEST 1: GUIDED DEMO ==="
send_key "return" "Start guided demo" 2
take_screenshot "02_guided_demo_started" "After pressing ENTER for guided demo"

wait_with_progress 3 "Guided demo progress"
take_screenshot "03_guided_demo_progress" "Guided demo in progress"

wait_with_progress 5 "More guided demo progress" 
take_screenshot "04_guided_demo_more" "More guided demo progress"

# Test 2: Manual dialogue test (Key 1)
echo
echo "=== TEST 2: MANUAL BASIC DIALOGUE ==="
send_key "r" "Reset demo first" 2
take_screenshot "05_after_reset" "After reset"

send_key "1" "Start basic dialogue test" 2
take_screenshot "06_basic_dialogue" "After pressing 1 for basic dialogue"

wait_with_progress 2 "Basic dialogue display"
take_screenshot "07_basic_dialogue_progress" "Basic dialogue progress"

# Test 3: Advance dialogue (SPACE)
echo
echo "=== TEST 3: ADVANCE DIALOGUE ==="
send_key "space" "Advance dialogue" 2
take_screenshot "08_after_space" "After pressing SPACE to advance"

# Test 4: Choice dialogue (Key 2)
echo
echo "=== TEST 4: CHOICE DIALOGUE ==="
send_key "2" "Start choice dialogue test" 2
take_screenshot "09_choice_dialogue" "After pressing 2 for choice dialogue"

wait_with_progress 3 "Choice dialogue display"
take_screenshot "10_choice_dialogue_display" "Choice dialogue fully displayed"

# Test 5: Select a choice (SPACE again)
echo
echo "=== TEST 5: SELECT CHOICE ==="
send_key "space" "Select first choice" 2
take_screenshot "11_choice_selected" "After selecting choice"

# Final screenshot
wait_with_progress 2 "Final state"
take_screenshot "12_final_state" "Final state"

echo
echo "🔍 Terminating Godot..."
kill $GODOT_PID 2>/dev/null || true
sleep 2

echo
echo "=== TEST COMPLETE ==="
echo "Screenshots saved with timestamp: $TIMESTAMP"
echo "Total screenshots in verification directory:"
ls -la "$SCREENSHOT_DIR"/automated_${TIMESTAMP}_*.png | wc -l

echo
echo "=== SCREENSHOT ANALYSIS SUMMARY ==="
echo "Now I can examine these screenshots to provide HONEST feedback about:"
echo "1. Whether dialogue boxes are actually visible"
echo "2. Whether text is appearing"
echo "3. Whether choice buttons are shown"
echo "4. Whether the UI is positioned correctly"
echo "5. What's actually broken vs what just has console output"

echo
echo "Files created:"
ls -la "$SCREENSHOT_DIR"/automated_${TIMESTAMP}_*.png