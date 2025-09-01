#!/bin/bash
# Enforcement hook: Automatic testing after task completion
# This hook triggers when todos are marked as completed

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if a task was just completed
LAST_TODO_ACTION=$(grep -E "completed|in_progress" .claude/todos/session.log | tail -1)

if [[ "$LAST_TODO_ACTION" == *"completed"* ]]; then
    echo -e "${YELLOW}🔍 Task completed - triggering automatic verification...${NC}"
    
    # Extract task description
    TASK_DESC=$(echo "$LAST_TODO_ACTION" | sed 's/.*content":"\([^"]*\).*/\1/')
    echo -e "${GREEN}Testing: $TASK_DESC${NC}"
    
    # Force testing requirement
    cat << 'EOF'
    
⚠️  AUTOMATED TESTING REQUIRED ⚠️
════════════════════════════════════════════
A task has been marked as completed. You MUST now:

1. Launch the game to verify the implementation
2. Take screenshots proving functionality
3. Check for errors in the console output
4. Generate a test report

Use the godot-tester agent to perform verification:
claude-chat godot-tester "Verify the completed task: $TASK_DESC"

Testing is MANDATORY before proceeding to the next task.
════════════════════════════════════════════
EOF
    
    # Return non-zero to block further actions until testing is done
    exit 1
fi

exit 0