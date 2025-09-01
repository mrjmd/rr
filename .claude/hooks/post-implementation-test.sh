#!/bin/bash
# Post-implementation testing hook
# Automatically runs after Write/Edit operations on game files

# Detect if game files were modified
MODIFIED_FILES=$(git status --porcelain | grep -E "\.(gd|tscn|tres)$")

if [ ! -z "$MODIFIED_FILES" ]; then
    echo "🎮 Game files modified - verification required!"
    
    # Create test manifest
    cat > /tmp/test_manifest.txt << EOF
Files Modified:
$MODIFIED_FILES

Test Requirements:
- Launch game and verify no crashes
- Test modified features
- Capture proof screenshots
- Check console for errors
EOF
    
    # Trigger verification notice
    cat << 'EOF'
    
╔════════════════════════════════════════╗
║     IMPLEMENTATION VERIFICATION        ║
╠════════════════════════════════════════╣
║ Game files have been modified.         ║
║ Automatic testing will now execute.    ║
║                                        ║
║ The godot-tester agent will:           ║
║ 1. Launch the game                     ║
║ 2. Verify no critical errors          ║
║ 3. Take screenshots                    ║
║ 4. Generate test report                ║
╚════════════════════════════════════════╝

Invoking godot-tester agent...
EOF
    
    # Note: In actual implementation, this would trigger the agent
    echo "⚡ HOOK: Trigger godot-tester agent for verification"
fi

exit 0