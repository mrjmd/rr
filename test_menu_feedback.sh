#!/bin/bash
# Test script for menu audio and visual feedback system

GODOT_PATH="/Applications/Godot.app/Contents/MacOS/Godot"
PROJECT_PATH="/Users/matt/Projects/randos-reservoir"
TEST_SCRIPT="testing/scripts/test_menu_feedback.gd"
DEMO_SCENE="src/scenes/demo/menu_feedback_demo.tscn"

echo "🎮 Menu Feedback System Test"
echo "============================="

# Check if Godot exists
if [ ! -f "$GODOT_PATH" ]; then
    echo "❌ Error: Godot not found at $GODOT_PATH"
    exit 1
fi

# Check if project exists
if [ ! -f "$PROJECT_PATH/project.godot" ]; then
    echo "❌ Error: Project not found at $PROJECT_PATH"
    exit 1
fi

# Ensure screenshot directory exists
mkdir -p "$PROJECT_PATH/testing/screenshots/current"

echo "📁 Project: $PROJECT_PATH"
echo "🎯 Demo Scene: $DEMO_SCENE"
echo "🧪 Test Script: $TEST_SCRIPT"
echo ""

# Run automated feedback test
echo "🤖 Running automated feedback tests..."
echo "----------------------------------------"
"$GODOT_PATH" --headless --path "$PROJECT_PATH" --script "$TEST_SCRIPT"

TEST_RESULT=$?

echo ""
echo "📊 Test Results:"
echo "=================="

if [ $TEST_RESULT -eq 0 ]; then
    echo "✅ Automated tests passed!"
else
    echo "❌ Automated tests failed (exit code: $TEST_RESULT)"
fi

# Show screenshot files created
echo ""
echo "📸 Screenshots captured:"
SCREENSHOT_COUNT=$(find "$PROJECT_PATH/testing/screenshots/current" -name "feedback_*.png" 2>/dev/null | wc -l)
if [ "$SCREENSHOT_COUNT" -gt 0 ]; then
    echo "   Found $SCREENSHOT_COUNT feedback test screenshots"
    ls -la "$PROJECT_PATH/testing/screenshots/current/feedback_"*.png 2>/dev/null | head -10
    
    # Show latest screenshot if available  
    LATEST_SCREENSHOT=$(ls -t "$PROJECT_PATH/testing/screenshots/current/feedback_"*.png 2>/dev/null | head -1)
    if [ -n "$LATEST_SCREENSHOT" ]; then
        echo ""
        echo "💡 To view latest screenshot:"
        echo "   open \"$LATEST_SCREENSHOT\""
    fi
else
    echo "   ⚠️ No screenshots found"
fi

echo ""
echo "🎮 Manual Testing Available:"
echo "============================"
echo "Run the interactive demo:"
echo "   $GODOT_PATH --path \"$PROJECT_PATH\" \"$DEMO_SCENE\""
echo ""
echo "🎯 Demo Features:"
echo "• Hover effects (scaling + glow)"
echo "• Press animations"
echo "• Audio feedback for all interactions"
echo "• Different sound types (click, back, confirm, error)"
echo "• Slider and checkbox audio feedback"
echo "• Visual error feedback (red flash)"
echo ""

if [ $TEST_RESULT -eq 0 ]; then
    echo "✅ Menu feedback system test completed successfully!"
    exit 0
else
    echo "❌ Menu feedback system test failed"
    exit 1
fi