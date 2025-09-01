#!/bin/bash

# Session save hook - runs at session end

CURRENT_MD=".claude/todos/current.md"
ARCHIVE_DIR=".claude/todos/archive/$(date +%Y-%m)"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

echo "💾 Saving session..."

# Create archive directory if needed
mkdir -p "$ARCHIVE_DIR"

# Archive current todos if they exist
if [ -f "$CURRENT_MD" ]; then
    ARCHIVE_FILE="$ARCHIVE_DIR/session-$TIMESTAMP.md"
    cp "$CURRENT_MD" "$ARCHIVE_FILE"
    echo "✓ Archived current session to $ARCHIVE_FILE"
else
    echo "ℹ️ No current todos to archive"
fi

# Log session end
echo "Session ended at $(date)" >> .claude/todos/session.log

echo "✅ Session saved successfully"
exit 0