#!/bin/bash
# Wait for a pull request review from a specific author
# Uses gh CLI to poll the reviews endpoint
# Includes json-repair for handling malformed Copilot JSON output

set -e

AUTHOR=""
TIMEOUT=900
INTERVAL=10
PR=""
OUTPUT_FILE=""

usage() {
    echo "Usage: $0 --author <login> [--timeout <seconds>] [--pr <number>] [--output <file>]"
    echo ""
    echo "Options:"
    echo "  --author     GitHub login of the reviewer to wait for (required)"
    echo "  --timeout    Maximum time to wait in seconds (default: 900)"
    echo "  --pr         Pull request number (default: current branch PR)"
    echo "  --interval   Polling interval in seconds (default: 10)"
    echo "  --output     Output file for the review JSON (optional)"
    exit 1
}

repair_json() {
    python3 -c "
import sys
try:
    from json_repair import repair_json
    input_data = sys.stdin.read()
    repaired = repair_json(input_data)
    print(repaired)
except Exception as e:
    print('Error repairing JSON:', e, file=sys.stderr)
    sys.exit(1)
"
}

while [[ $# -gt 0 ]]; do
    case $1 in
        --author)
            AUTHOR="$2"
            shift 2
            ;;
        --timeout)
            TIMEOUT="$2"
            shift 2
            ;;
        --pr)
            PR="$2"
            shift 2
            ;;
        --interval)
            INTERVAL="$2"
            shift 2
            ;;
        --output)
            OUTPUT_FILE="$2"
            shift 2
            ;;
        *)
            usage
            ;;
    esac
done

if [[ -z "$AUTHOR" ]]; then
    echo "Error: --author is required"
    usage
fi

PR_ARG=""
if [[ -n "$PR" ]]; then
    PR_ARG="$PR"
fi

echo "Waiting for review from @$AUTHOR (timeout: ${TIMEOUT}s)..."

START_TIME=$(date +%s)
END_TIME=$((START_TIME + TIMEOUT))

while true; do
    CURRENT_TIME=$(date +%s)
    if [[ $CURRENT_TIME -ge $END_TIME ]]; then
        echo "Error: Timeout waiting for review from @$AUTHOR"
        exit 1
    fi

    REVIEW=$(gh pr view $PR_ARG --json reviews --jq "[.reviews[] | select(.author.login == \"$AUTHOR\" and .submittedAt != null)] | sort_by(.submittedAt) | last" 2>/dev/null || echo "")
    
    if [[ -n "$REVIEW" && "$REVIEW" != "null" ]]; then
        echo "Review found from @$AUTHOR"
        
        REPAIRED_JSON=$(echo "$REVIEW" | repair_json)
        if [[ $? -ne 0 ]]; then
            echo "Warning: JSON repair failed, using original"
            REPAIRED_JSON="$REVIEW"
        fi
        
        BODY=$(echo "$REPAIRED_JSON" | jq -r '.body // ""' 2>/dev/null || echo "$REVIEW" | jq -r '.body // ""')
        STATE=$(echo "$REPAIRED_JSON" | jq -r '.state // ""' 2>/dev/null || echo "$REVIEW" | jq -r '.state // ""')
        
        echo "State: $STATE"
        
        if [[ -n "$OUTPUT_FILE" ]]; then
            echo "$REPAIRED_JSON" > "$OUTPUT_FILE"
            echo "Review JSON saved to: $OUTPUT_FILE"
        fi
        
        if [[ "$BODY" == *"Pull request overview"* ]]; then
            echo "✓ Copilot review overview detected"
            exit 0
        else
            echo "Note: Review body does not contain 'Pull request overview'"
            exit 0
        fi
    fi
    
    sleep $INTERVAL
done
