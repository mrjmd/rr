#!/bin/bash

# Test script for pause menu standalone functionality

echo "=== Testing Pause Menu Standalone Functionality ==="

# Test 1: Run the standalone scene to verify it works
echo "1. Running standalone pause menu scene..."
timeout 10s /Applications/Godot.app/Contents/MacOS/Godot --path /Users/matt/Projects/randos-reservoir src/scenes/testing/pause_menu_standalone.tscn &

# Wait a moment for it to load
sleep 3

# Test 2: Capture a screenshot using the existing capture script
echo "2. Capturing screenshot for visual verification..."
/Applications/Godot.app/Contents/MacOS/Godot --headless --path /Users/matt/Projects/randos-reservoir --script testing/scripts/capture_game_screenshot.gd

# Kill the background process
pkill -f "Godot.*pause_menu_standalone" 2>/dev/null

echo "3. Test completed - check testing/screenshots/current/ for results"
echo "   Scene: pause_menu_standalone.tscn"
echo "   Scripts: pause_menu_simple.gd (EventBus optional)"
echo "   Status: EventBus dependencies made optional"

ls -la testing/screenshots/current/ 2>/dev/null | tail -3