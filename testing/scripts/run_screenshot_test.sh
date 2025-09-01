#!/bin/bash

echo "Running automated dialogue system screenshot test..."
echo "This will capture visual proof of the dialogue system functionality"

# Run the screenshot capture script
/Applications/Godot.app/Contents/MacOS/Godot --headless --path /Users/matt/Projects/randos-reservoir --script capture_dialogue_proof.gd

echo "Test complete! Screenshots saved to testing/screenshots/verification/"
ls -la testing/screenshots/verification/*.png 2>/dev/null || echo "No screenshots found - checking for errors"