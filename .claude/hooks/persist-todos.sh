#!/bin/bash

# Persist todos to file after TodoWrite
# Note: Hooks can't access todo content directly, so this is a reminder

echo "📝 Todo list updated at $(date)" >> .claude/todos/session.log

# Create a marker file to indicate todos need persisting
touch .claude/todos/.needs_persist

echo "✓ Todo persistence triggered. Remember to save to current.md"

exit 0