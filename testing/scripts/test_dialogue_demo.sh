#!/bin/bash

# Test script to launch dialogue demo and verify key input
echo "Launching DialogueDemo scene to test key input handling..."
echo "Testing keys: ENTER, ESC, 1-5, R, H, SPACE"
echo "Press CTRL+C to exit when testing is complete"

# Launch the dialogue demo scene
/Applications/Godot.app/Contents/MacOS/Godot --path /Users/matt/Projects/randos-reservoir res://src/scenes/demo/dialogue_demo.tscn

echo "Demo test completed"