#!/bin/bash
# Phase 5 Cron Scheduler
# Schedule security analysis for Mon/Wed/Fri at midnight
# Usage: ./phase5-schedule.sh

CRON_SCRIPT="/home/clawbotpi/.openclaw/workspace/cron/phase5-security-analysis.py"
CRON_LOG="/home/clawbotpi/.openclaw/cron/phase5.log"

# Ensure script is executable
chmod +x "$CRON_SCRIPT"

# Create log directory
mkdir -p /home/clawbotpi/.openclaw/cron

# Create crontab entry (runs Mon/Wed/Fri at 00:00)
# Format: minute hour day-of-month month day-of-week command
# 0 0 * * 1,3,5 = Monday, Wednesday, Friday at midnight

CRON_ENTRY="0 0 * * 1,3,5 /usr/bin/python3 $CRON_SCRIPT >> $CRON_LOG 2>&1"

# Add to crontab (if not already present)
(crontab -l 2>/dev/null | grep -v "phase5-security-analysis" ; echo "$CRON_ENTRY") | crontab -

echo "✅ Phase 5 scheduled for Mon/Wed/Fri at midnight"
echo "   Script: $CRON_SCRIPT"
echo "   Log: $CRON_LOG"
echo "   Schedule: 0 0 * * 1,3,5 (Mon/Wed/Fri at 00:00)"
echo ""
echo "To verify, run: crontab -l | grep phase5"
