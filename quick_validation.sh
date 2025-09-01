#!/bin/bash

# Quick Project Validation Script
# Verifies project can load and dialogue system exists

echo "=== Quick Project Validation ==="

GODOT="/Applications/Godot.app/Contents/MacOS/Godot"
PROJECT_PATH="/Users/matt/Projects/randos-reservoir"

echo "Checking project validation..."

# Run headless validation
"$GODOT" --headless --quit --check-only --path "$PROJECT_PATH" 2>&1

echo ""
echo "Validation completed. Check above for any errors."