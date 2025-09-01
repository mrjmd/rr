#!/bin/bash

# Cleanup Script: Remove Orphaned .import Files from Project Root
# Purpose: Clean up Godot .import files for removed/relocated screenshot files

PROJECT_ROOT="/Users/matt/Projects/randos-reservoir"
cd "$PROJECT_ROOT"

echo "🧹 Cleaning up orphaned .import files from project root..."
echo "========================================================"

# Files to remove (orphaned .import files for screenshots)
IMPORT_FILES=(
    "dialogue_after.png.import"
    "dialogue_before.png.import"
    "dialogue_center_test.png.import"
    "dialogue_choices_working.png.import"
    "dialogue_demo_test.png.import"
    "dialogue_final_demo.png.import"
    "dialogue_final_working.png.import"
    "dialogue_fixed_after.png.import"
    "dialogue_fixed_before.png.import"
    "dialogue_test_basic.png.import"
    "dialogue_verification_final.png.import"
    "test_screenshot_current.png.import"
)

# Remove orphaned .import files
echo "Removing orphaned .import files..."
for file in "${IMPORT_FILES[@]}"; do
    if [ -f "$file" ]; then
        echo "  ❌ Removing: $file"
        rm "$file"
    else
        echo "  ✅ Already gone: $file"
    fi
done

# Additional cleanup of any remaining orphaned .import files
echo ""
echo "Checking for any remaining dialogue/test screenshot .import files..."
find . -maxdepth 1 -name "dialogue_*.import" -o -name "test_screenshot_*.import" | while read -r file; do
    echo "  ❌ Found and removing: $file"
    rm "$file"
done

# Clean up other test-related files in root that shouldn't be there
echo ""
echo "Cleaning up additional test files in root..."
TEST_FILES=(
    "capture_dialogue_proof.gd"
    "capture_dialogue_proof.gd.uid"
    "dialogue_test_log.txt"
    "test_dialogue_demo.sh"
    "test_dialogue_visual.sh"
    "run_screenshot_test.sh"
)

for file in "${TEST_FILES[@]}"; do
    if [ -f "$file" ]; then
        echo "  🗂️ Moving to testing/: $file"
        # Create testing directory if it doesn't exist
        mkdir -p testing/scripts
        mv "$file" testing/scripts/
    fi
done

echo ""
echo "✅ Cleanup complete!"
echo ""
echo "📊 Summary:"
echo "  - Removed orphaned .import files for deleted screenshots"
echo "  - Moved test scripts to testing/scripts/ directory"
echo "  - Project root is now clean"
echo ""
echo "🎯 Next steps:"
echo "  1. Update .gitignore to prevent future issues"
echo "  2. Use organized testing/screenshots/ directory for future screenshots"
echo "  3. Commit changes to maintain clean project structure"