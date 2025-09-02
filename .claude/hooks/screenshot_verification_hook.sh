#!/bin/bash
# Screenshot Verification Hook - Enforces proper screenshot analysis

# This hook monitors for screenshot captures and enforces verification
# It will BLOCK progress if screenshots aren't properly verified

SCREENSHOT_DIR="/Users/matt/Projects/randos-reservoir/testing/screenshots/current"
VERIFICATION_LOG="$SCREENSHOT_DIR/.verification_log"

# Function to check if a screenshot was verified
check_screenshot_verification() {
    local screenshot_file="$1"
    local file_size=$(stat -f%z "$screenshot_file" 2>/dev/null)
    
    # Check if file is suspiciously small (likely black/empty)
    if [ "$file_size" -lt 10000 ]; then
        echo "⚠️ WARNING: Screenshot $screenshot_file is only $file_size bytes - likely black/empty!"
        echo "❌ BLOCKED: You must investigate why screenshots are black before claiming success"
        return 1
    fi
    
    # Log verification requirement
    echo "📸 Screenshot captured: $screenshot_file ($file_size bytes)"
    echo "📋 REQUIRED: You must now use Read tool to verify this screenshot shows expected content"
    echo "$screenshot_file|PENDING_VERIFICATION|$(date)" >> "$VERIFICATION_LOG"
    
    return 0
}

# Monitor screenshot creation
if [[ "$1" == "screenshot_created" ]]; then
    check_screenshot_verification "$2"
fi

# Block false success claims
if [[ "$1" == "success_claimed" ]]; then
    # Check for unverified screenshots
    if [ -f "$VERIFICATION_LOG" ]; then
        unverified=$(grep "PENDING_VERIFICATION" "$VERIFICATION_LOG" | wc -l)
        if [ "$unverified" -gt 0 ]; then
            echo "❌ BLOCKED: $unverified screenshots haven't been verified with Read tool!"
            echo "You must READ and ANALYZE all screenshots before claiming success"
            exit 1
        fi
    fi
fi