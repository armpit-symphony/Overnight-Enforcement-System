#!/bin/bash
#
# Morning Verification Script
# Run at 9 AM to verify overnight work
#
# Usage: ./morning-check.sh
#

TODAY=$(date +%Y-%m-%d)
TODO_FILE="/home/sparky/.openclaw/workspace/TODO.md"
OUTPUT_DIR="/home/sparky/.openclaw/workspace"
LOG_FILE="/home/sparky/.openclaw/workspace/morning-check.log"
ALERT_FILE="/tmp/overnight_failure_alert.txt"

echo "========================================" | tee -a "$LOG_FILE"
echo "Morning Check - $TODAY" | tee -a "$LOG_FILE"
echo "========================================" | tee -a "$LOG_FILE"
echo "" | tee -a "$LOG_FILE"

# Check for overnight work completion
echo "Checking overnight tasks..." | tee -a "$LOG_FILE"

COMPLETE=0
MISSING=0

# Parse TODO.md for today's tasks
while IFS= read -r line; do
    # Skip headers and empty lines
    [[ -z "$line" || "$line" =~ ^# ]] && continue
    
    # Check if today's date
    [[ "$line" =~ ^\|\ *([0-9-]+)\ *\| ]] || continue
    task_date="${BASH_REMATCH[1]}"
    
    [[ "$task_date" != "$TODAY" ]] && continue
    
    # Extract task name and output file
    if [[ "$line" =~ \|[^|]+\|([^|]+)\|([^|]+)\| ]]; then
        task_name="${BASH_REMATCH[1]}"
        output_file="${BASH_REMATCH[2]}"
        task_name=$(echo "$task_name" | xargs)
        output_file=$(echo "$output_file" | xargs)
        
        if [ -f "$output_file" ]; then
            echo "✅ $task_name" | tee -a "$LOG_FILE"
            ((COMPLETE++))
        else
            echo "❌ $task_name - MISSING: $output_file" | tee -a "$LOG_FILE"
            echo "- $task_name: $output_file" >> "$ALERT_FILE"
            ((MISSING++))
        fi
    fi
done < "$TODO_FILE"

echo "" | tee -a "$LOG_FILE"

# Summary
echo "Summary: $COMPLETE complete, $MISSING missing" | tee -a "$LOG_FILE"
echo "" | tee -a "$LOG_FILE"

# Check Token Guardian
echo "Token Guardian Status:" | tee -a "$LOG_FILE"
TG_STATS=$(cat ~/.tokenguardian/stats.json 2>/dev/null)
if [ -n "$TG_STATS" ]; then
    TOKENS=$(echo "$TG_STATS" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('total_tokens','0'))" 2>/dev/null || echo "0")
    echo "  Tokens tracked: $TOKENS" | tee -a "$LOG_FILE"
else
    echo "  Token Guardian not running" | tee -a "$LOG_FILE"
fi

# Alert if failures
if [ -f "$ALERT_FILE" ]; then
    echo "" | tee -a "$LOG_FILE"
    echo "⚠️ OVERNIGHT WORK INCOMPLETE" | tee -a "$LOG_FILE"
    cat "$ALERT_FILE" | tee -a "$LOG_FILE"
    rm -f "$ALERT_FILE"
    exit 1
fi

echo "✅ All overnight work complete" | tee -a "$LOG_FILE"
exit 0
