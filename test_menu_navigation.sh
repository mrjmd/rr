#!/bin/bash
# Test script for menu navigation and transition system

echo "========================================="
echo "Menu Navigation and Transition System Test"
echo "========================================="

PROJECT_PATH="/Users/matt/Projects/randos-reservoir"
GODOT_PATH="/Applications/Godot.app/Contents/MacOS/Godot"
SCREENSHOT_DIR="$PROJECT_PATH/testing/screenshots/current"

# Create screenshot directory
mkdir -p "$SCREENSHOT_DIR"

echo "Testing menu navigation system..."

# Test 1: Run the basic functionality test
echo "1. Running menu navigation test..."
"$GODOT_PATH" --headless --path "$PROJECT_PATH" --script testing/scripts/test_menu_navigation.gd

TEST_RESULT=$?

if [ $TEST_RESULT -eq 0 ]; then
    echo "✅ Menu navigation test PASSED"
else
    echo "❌ Menu navigation test FAILED"
    exit 1
fi

echo ""
echo "========================================="
echo "Menu Navigation Test Complete"
echo "========================================="

# Test 2: Visual verification with screenshots
echo "2. Running visual verification test..."
"$GODOT_PATH" --path "$PROJECT_PATH" --script testing/scripts/test_visual_menu_navigation.gd

echo "Visual verification test completed"

# Show results
echo ""
echo "Test Results:"
echo "- Basic functionality: ✅ PASSED"
echo "- Visual verification: ✅ COMPLETED"
echo ""
echo "Screenshots saved to: $SCREENSHOT_DIR"

if ls "$SCREENSHOT_DIR"/*.png 1> /dev/null 2>&1; then
    echo "Screenshots captured:"
    ls -la "$SCREENSHOT_DIR"/*.png | tail -10
else
    echo "No screenshots found - check screenshot capture system"
fi

echo ""
echo "Menu navigation system implementation complete! 🎉"