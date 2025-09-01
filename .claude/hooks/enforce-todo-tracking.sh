#!/bin/bash

# Check if todo-manager agent was invoked recently
TODO_LOG=".claude/todos/session.log"
CURRENT_TIME=$(date +%s)
TIMEOUT=300  # 5 minutes

if [ ! -f "$TODO_LOG" ]; then
    echo "⚠️ WARNING: No todo tracking detected!"
    echo "Please use the todo-manager agent to track your tasks."
    exit 0  # Warning only, don't block
fi

LAST_UPDATE=$(stat -f %m "$TODO_LOG" 2>/dev/null || stat -c %Y "$TODO_LOG" 2>/dev/null)
TIME_DIFF=$((CURRENT_TIME - LAST_UPDATE))

if [ $TIME_DIFF -gt $TIMEOUT ]; then
    echo "⚠️ Todo tracking is stale (last update: $((TIME_DIFF / 60)) minutes ago)"
    echo "Consider using the todo-manager agent to update task status."
fi

exit 0