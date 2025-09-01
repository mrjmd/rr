#!/bin/bash

# Check GDScript files for proper patterns
# This hook runs before Write/Edit operations

# Get the file being modified (this is a placeholder - hooks can't access params directly)
# In practice, this would need to be tracked differently
FILE_PATH="${1:-}"

# Only check .gd files
if [[ "$FILE_PATH" == *".gd" ]]; then
    echo "🔍 Checking GDScript patterns..."
    
    # Check for type hints (simplified check)
    # In a real implementation, we'd analyze the actual file content
    echo "✓ Remember to use type hints for all variables and functions"
    echo "✓ Use @onready for node references"
    echo "✓ Prefer signals over direct node access"
fi

# Only check .tscn files
if [[ "$FILE_PATH" == *".tscn" ]]; then
    echo "🔍 Checking scene structure..."
    echo "✓ Ensure proper node hierarchy"
    echo "✓ Use descriptive node names"
fi

exit 0