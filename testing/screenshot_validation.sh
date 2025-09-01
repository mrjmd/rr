#!/bin/bash
## Screenshot validation and organization script
## Standardizes all screenshot locations to testing/screenshots/verification/

echo "=== Screenshot Standardization Script ==="
echo "Moving all scattered screenshots to standard location..."

PROJECT_DIR="/Users/matt/Projects/randos-reservoir"
STANDARD_DIR="$PROJECT_DIR/testing/screenshots/verification"
TIMESTAMP=$(date "+%Y%m%d_%H%M%S")

# Create standard directory
mkdir -p "$STANDARD_DIR"

# Function to move screenshots with validation
move_screenshots() {
    local source_dir="$1"
    local description="$2"
    
    if [ -d "$source_dir" ]; then
        local count=$(find "$source_dir" -name "*.png" 2>/dev/null | wc -l)
        if [ "$count" -gt 0 ]; then
            echo "Found $count screenshots in $description"
            
            # Move screenshots with timestamp prefix
            find "$source_dir" -name "*.png" -exec bash -c '
                filename=$(basename "$0")
                mv "$0" "'"$STANDARD_DIR"'/'"$TIMESTAMP"'_$filename"
                echo "  Moved: $filename -> '"$TIMESTAMP"'_$filename"
            ' {} \;
        else
            echo "No screenshots in $description"
        fi
    else
        echo "Directory not found: $source_dir"
    fi
}

# Move screenshots from various locations
echo "Checking project root..."
move_screenshots "$PROJECT_DIR" "project root"

echo "Checking test_screenshots..."
move_screenshots "$PROJECT_DIR/test_screenshots" "test_screenshots directory"

echo "Checking old testing locations..."
move_screenshots "$PROJECT_DIR/testing/screenshots/current" "testing/screenshots/current"
move_screenshots "$PROJECT_DIR/testing/screenshots/automated" "testing/screenshots/automated"

# Clean up empty directories
echo "Cleaning up empty directories..."
find "$PROJECT_DIR" -type d -name "*screenshot*" -empty -delete 2>/dev/null

# Create .gitkeep for standard directory
touch "$STANDARD_DIR/.gitkeep"

# Report final state
echo "=== Standardization Complete ==="
final_count=$(find "$STANDARD_DIR" -name "*.png" 2>/dev/null | wc -l)
echo "Total screenshots in standard location: $final_count"
echo "Standard directory: $STANDARD_DIR"

# List all screenshots for verification
if [ "$final_count" -gt 0 ]; then
    echo "Screenshots found:"
    ls -la "$STANDARD_DIR"/*.png
fi

echo "=== Screenshot Validation ==="
echo "Standard screenshot directory established: testing/screenshots/verification/"
echo "All future screenshots should go here only."
echo "Use this path in all scripts: /Users/matt/Projects/randos-reservoir/testing/screenshots/verification/"