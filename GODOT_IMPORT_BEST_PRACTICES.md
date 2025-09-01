# Godot .import Files Best Practices

## What are .import Files?

Godot automatically generates `.import` files for every asset (PNG, OGG, etc.) to store import settings and metadata. These files are essential for the engine to know how to process and display your assets.

## Key Rules for .import Files

### 1. **Never Manually Delete .import Files for Active Assets**
- If you delete a `.import` file for an asset that's still in your project, Godot will regenerate it with default settings
- This can break custom import configurations (texture filters, compression, etc.)

### 2. **Clean Up Orphaned .import Files**
- When you delete/move assets, their `.import` files can become orphaned
- Orphaned `.import` files should be removed to keep the project clean
- **This is what we just did** - removed `.import` files for deleted screenshot files

### 3. **Project Structure Best Practices**

#### ✅ Good Structure:
```
project/
├── assets/
│   ├── sprites/
│   │   ├── player.png
│   │   └── player.png.import    # Automatically generated
│   └── audio/
│       ├── music.ogg
│       └── music.ogg.import     # Automatically generated
├── scenes/
└── scripts/
```

#### ❌ Bad Structure (What We Fixed):
```
project/
├── dialogue_test.png.import     # Orphaned - PNG was deleted
├── screenshot.png.import        # Orphaned - PNG was deleted
├── assets/
└── scenes/
```

## .gitignore Strategy for .import Files

### Current Implementation in This Project:
```gitignore
# Ignore orphaned .import files for screenshots in root
dialogue_*.png.import
test_screenshot_*.png.import

# Keep legitimate .import files for actual assets
# (Don't ignore all *.import files globally)
```

### Why This Approach:
1. **Specific Patterns**: Only ignore known problematic patterns
2. **Preserve Asset Imports**: Don't ignore legitimate `.import` files in `assets/`
3. **Prevent Root Clutter**: Stop test screenshots from creating root-level imports

## When .import Files Become Problems

### Symptoms:
- Clutter in project root directory
- Git tracking many unnecessary import files
- Inconsistent asset import settings across team members

### Solutions:
1. **Organize Assets Properly**: Keep all assets in organized subdirectories
2. **Clean Up Regularly**: Remove orphaned imports when assets are deleted
3. **Use Specific .gitignore Patterns**: Don't ignore all imports, just problematic ones
4. **Establish Team Conventions**: Everyone follows the same asset organization

## Automated Cleanup (What We Implemented)

### Cleanup Script Features:
- **Identifies Orphaned Imports**: Finds `.import` files without corresponding assets
- **Moves Test Files**: Relocates test scripts to organized directories
- **Maintains Clean Root**: Keeps project root focused on core files

### Regular Maintenance:
```bash
# Run cleanup script when needed
./cleanup_import_files.sh

# Check for orphaned imports
find . -name "*.import" -exec test -f "{}" \; -print | while read f; do
    asset="${f%%.import}"
    if [ ! -f "$asset" ]; then
        echo "Orphaned: $f"
    fi
done
```

## Best Practices Summary

### ✅ Do:
- Keep assets organized in proper directories
- Clean up orphaned `.import` files regularly
- Use specific `.gitignore` patterns for problematic imports
- Let Godot manage `.import` files for legitimate assets

### ❌ Don't:
- Manually edit `.import` files (use Godot's import dock instead)
- Delete `.import` files for assets you're still using
- Ignore all `*.import` files globally in `.gitignore`
- Store temporary screenshots/assets in project root

## Result of Today's Cleanup

### Before:
- 12 orphaned `.import` files cluttering project root
- 6 test script files misplaced in root directory
- Inconsistent file organization

### After:
- ✅ Clean project root with only essential files
- ✅ Test scripts organized in `testing/scripts/`
- ✅ `.gitignore` updated to prevent future issues
- ✅ Automated cleanup script for maintenance

### Files Cleaned Up:
```
Removed .import files:
- dialogue_after.png.import
- dialogue_before.png.import
- dialogue_center_test.png.import
- dialogue_choices_working.png.import
- dialogue_demo_test.png.import
- dialogue_final_demo.png.import
- dialogue_final_working.png.import
- dialogue_fixed_after.png.import
- dialogue_fixed_before.png.import
- dialogue_test_basic.png.import
- dialogue_verification_final.png.import
- test_screenshot_current.png.import

Moved test files to testing/scripts/:
- capture_dialogue_proof.gd
- dialogue_test_log.txt
- run_screenshot_test.sh
- test_dialogue_demo.sh
- test_dialogue_visual.sh
```

This cleanup ensures a professional, maintainable project structure that follows Godot best practices.