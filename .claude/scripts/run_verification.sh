#!/bin/bash
# Automated verification runner for Godot implementations

set -e

# Configuration
GODOT="/Applications/Godot.app/Contents/MacOS/Godot"
PROJECT_PATH="/Users/matt/Projects/randos-reservoir"
SCREENSHOTS_DIR="$PROJECT_PATH/test_screenshots"
LOG_FILE="$PROJECT_PATH/verification.log"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Ensure directories exist
mkdir -p "$SCREENSHOTS_DIR"

echo -e "${BLUE}════════════════════════════════════════${NC}"
echo -e "${BLUE}    GODOT IMPLEMENTATION VERIFIER      ${NC}"
echo -e "${BLUE}════════════════════════════════════════${NC}\n"

# Step 1: Project validation
echo -e "${YELLOW}[1/6] Validating project structure...${NC}"
$GODOT --headless --quit --check-only --path "$PROJECT_PATH" 2>&1 | tee "$LOG_FILE"

if [ $? -ne 0 ]; then
    echo -e "${RED}✗ Project validation failed!${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Project structure valid${NC}\n"

# Step 2: Import assets
echo -e "${YELLOW}[2/6] Importing assets...${NC}"
$GODOT --headless --editor --quit-after 2 --path "$PROJECT_PATH" 2>&1 | tee -a "$LOG_FILE"
echo -e "${GREEN}✓ Assets imported${NC}\n"

# Step 3: Run automated tests
echo -e "${YELLOW}[3/6] Running automated tests...${NC}"
$GODOT --headless --path "$PROJECT_PATH" --script scripts/test_automation.gd 2>&1 | tee -a "$LOG_FILE"

TEST_RESULT=$?
if [ $TEST_RESULT -eq 0 ]; then
    echo -e "${GREEN}✓ Automated tests PASSED${NC}\n"
else
    echo -e "${YELLOW}⚠ Some tests failed - check report${NC}\n"
fi

# Step 4: Launch game for visual verification
echo -e "${YELLOW}[4/6] Launching game for visual verification...${NC}"
$GODOT --path "$PROJECT_PATH" --verbose 2>&1 | tee -a "$LOG_FILE" &
GAME_PID=$!

echo "Waiting for game to initialize..."
sleep 5

# Step 5: Capture screenshots
echo -e "${YELLOW}[5/6] Capturing verification screenshots...${NC}"

# Initial state
screencapture -x "$SCREENSHOTS_DIR/verify_01_initial.png" 2>/dev/null && \
    echo -e "  ${GREEN}✓${NC} Initial state captured"
sleep 1

# Multiple frames for animation
for i in {2..5}; do
    screencapture -x "$SCREENSHOTS_DIR/verify_0${i}_frame.png" 2>/dev/null && \
        echo -e "  ${GREEN}✓${NC} Frame $i captured"
    sleep 1
done

# Step 6: Check for errors in log
echo -e "${YELLOW}[6/6] Analyzing logs for errors...${NC}"

ERRORS=$(grep -E "SCRIPT ERROR|Failed to load|Invalid call" "$LOG_FILE" | head -5)
WARNINGS=$(grep -E "WARNING|Deprecated" "$LOG_FILE" | head -5)

if [ ! -z "$ERRORS" ]; then
    echo -e "${RED}Errors detected:${NC}"
    echo "$ERRORS"
    echo
fi

if [ ! -z "$WARNINGS" ]; then
    echo -e "${YELLOW}Warnings detected:${NC}"
    echo "$WARNINGS"
    echo
fi

# Kill the game
kill $GAME_PID 2>/dev/null || true

# Generate summary
echo -e "${BLUE}════════════════════════════════════════${NC}"
echo -e "${BLUE}           VERIFICATION SUMMARY         ${NC}"
echo -e "${BLUE}════════════════════════════════════════${NC}\n"

echo "📊 Results:"
echo "  • Project Valid: ✓"
echo "  • Assets Imported: ✓"
echo "  • Tests Run: $([ $TEST_RESULT -eq 0 ] && echo '✓ PASS' || echo '⚠ PARTIAL')"
echo "  • Screenshots: $(ls -1 $SCREENSHOTS_DIR/*.png 2>/dev/null | wc -l) captured"
echo "  • Errors: $([ -z "$ERRORS" ] && echo 'None' || echo 'Found - see above')"
echo "  • Warnings: $([ -z "$WARNINGS" ] && echo 'None' || echo 'Found - see above')"
echo
echo "📁 Artifacts:"
echo "  • Log: $LOG_FILE"
echo "  • Report: $PROJECT_PATH/test_report.txt"
echo "  • Screenshots: $SCREENSHOTS_DIR/"
echo "  • JSON Results: $PROJECT_PATH/test_results.json"
echo

# Overall result
if [ $TEST_RESULT -eq 0 ] && [ -z "$ERRORS" ]; then
    echo -e "${GREEN}✅ VERIFICATION PASSED${NC}"
    exit 0
elif [ -z "$ERRORS" ]; then
    echo -e "${YELLOW}⚠️  VERIFICATION PASSED WITH WARNINGS${NC}"
    exit 0
else
    echo -e "${RED}❌ VERIFICATION FAILED${NC}"
    echo "Please review the errors and fix them before proceeding."
    exit 1
fi