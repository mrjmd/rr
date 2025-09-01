#!/bin/bash

# Session recovery hook - runs at session start

CURRENT_MD=".claude/todos/current.md"
CLAUDE_MD="CLAUDE.md"

echo "🚀 Starting session recovery..."

# Check if CLAUDE.md exists
if [ -f "$CLAUDE_MD" ]; then
    echo "✓ Found CLAUDE.md - Remember to read it"
else
    echo "⚠️ CLAUDE.md not found - Project setup may be incomplete"
fi

# Check if current todos exist
if [ -f "$CURRENT_MD" ]; then
    echo "✓ Found current todos at $CURRENT_MD"
    echo "📋 Remember to:"
    echo "  1. Read CLAUDE.md for project rules"
    echo "  2. Read $CURRENT_MD for current tasks"
    echo "  3. Continue with pending work"
else
    echo "ℹ️ No current todos found - Starting fresh session"
    # Create initial todo file
    mkdir -p .claude/todos
    cat > "$CURRENT_MD" << 'EOF'
# Rando's Reservoir - Current Session TODOs
*Last Updated: New Session*
*Session Started: Now*
*Project Phase: Development*

## 🚀 Current Sprint Goal
[Define session goal]

## 🔄 IN PROGRESS (Max 1 item)
(None)

## ✅ COMPLETED THIS SESSION
(None)

## 📋 PENDING (Priority Order)
1. [ ] Read CLAUDE.md to understand project rules
2. [ ] Define session goals
3. [ ] Begin implementation

## 🔍 RECOVERY CONTEXT
### Currently Working On
- **Task**: Session initialization
- **File**: N/A
- **Status**: Starting fresh

## 📝 Session Notes
- Session initialized

## ⚠️ Blockers & Issues
(None)

## 🔜 Next Session Priority
To be determined
EOF
    echo "✓ Created initial todo file"
fi

echo "✅ Session recovery complete"
exit 0