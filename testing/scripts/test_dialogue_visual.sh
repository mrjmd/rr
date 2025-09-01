#!/bin/bash

# Visual Dialogue System Test Script
# Tests dialogue system and captures fresh screenshots

echo "=== Testing Dialogue System Visual Display ==="
echo "Starting dialogue demo scene..."

GODOT="/Applications/Godot.app/Contents/MacOS/Godot"
PROJECT_PATH="/Users/matt/Projects/randos-reservoir"
DEMO_SCENE="src/scenes/demo/dialogue_demo.tscn"

# Ensure screenshot directory exists
mkdir -p testing/screenshots/current

# Run the dialogue demo scene
echo "Launching Godot with dialogue demo scene..."
echo "Scene: $DEMO_SCENE"
echo ""
echo "INSTRUCTIONS FOR TESTING:"
echo "1. When Godot opens, press ENTER to start guided demo"
echo "2. Or press 1-5 for specific tests"
echo "3. Press 5 to take a screenshot"
echo "4. Close Godot when done testing"
echo ""

# Launch Godot with the demo scene
"$GODOT" --path "$PROJECT_PATH" "$DEMO_SCENE"

echo ""
echo "Dialogue system test completed."
echo "Check testing/screenshots/current/ for new screenshots."