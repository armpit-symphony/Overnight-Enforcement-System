#!/bin/bash
#
# Overnight Work Enforcer Cron Job
# Runs every hour to advance TODO.md tasks
# Produces actual output artifacts
#
# Add to crontab:
# 0 * * * * /home/sparky/.openclaw/scripts/overnight-work-cron.sh
#

LOG_FILE="/home/sparky/.openclaw/workspace/overnight-work.log"
TODO_FILE="/home/sparky/.openclaw/workspace/TODO.md"
TODAY=$(date +%Y-%m-%d)
CURRENT_HOUR=$(date +%H)

echo "" >> "$LOG_FILE"
echo "========================================" >> "$LOG_FILE"
echo "[$(date '+%Y-%m-%d %H:%M:%S')] Overnight work check - Hour $CURRENT_HOUR" >> "$LOG_FILE"
echo "========================================" >> "$LOG_FILE"

# Run overnight work enforcer
cd /home/sparky/.openclaw/workspace
python3 overnight-work.py --run >> "$LOG_FILE" 2>&1

RESULT=$?
echo "[$(date '+%Y-%m-%d %H:%M:%S')] Exit code: $RESULT" >> "$LOG_FILE"

# If exit code indicates failure, this will be caught in morning check
