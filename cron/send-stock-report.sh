#!/bin/bash

# Send Stock Reports to Telegram
# This script runs at 6:35 AM Mon-Fri
# It sends both the regular and after-hours stock reports

# Run the after-hours report (generated at 6:30 AM)
AFTERHOURS_REPORT=$(bash /home/clawbotpi/.openclaw/workspace/cron/stock-afterhours.sh 2>&1)

# Run the regular market report  
MARKET_REPORT=$(bash /home/clawbotpi/.openclaw/workspace/cron/stock-report.sh 2>&1)

# Combine reports with separator
COMBINED_REPORT="$AFTERHOURS_REPORT

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

$MARKET_REPORT"

# Get Telegram bot token and chat ID from environment or config
# You'll need to set these in your shell or cron environment
TELEGRAM_BOT_TOKEN=${TELEGRAM_BOT_TOKEN:-""}
TELEGRAM_CHAT_ID=${TELEGRAM_CHAT_ID:-""}

# Try to send to Telegram if credentials are available
if [ ! -z "$TELEGRAM_BOT_TOKEN" ] && [ ! -z "$TELEGRAM_CHAT_ID" ]; then
    # Send to Telegram
    curl -s -X POST "https://api.telegram.org/bot$TELEGRAM_BOT_TOKEN/sendMessage" \
        -d "chat_id=$TELEGRAM_CHAT_ID" \
        -d "text=$COMBINED_REPORT" \
        -d "parse_mode=HTML" > /dev/null 2>&1
    
    echo "✅ Stock reports sent to Telegram at $(date '+%I:%M %p')"
else
    # No Telegram credentials, just log the report
    echo "⚠️  Telegram not configured"
    echo "To send reports to Telegram:"
    echo "1. Create a bot: @BotFather on Telegram"
    echo "2. Get your chat ID: Use @userinfobot"
    echo "3. Set environment variables:"
    echo "   export TELEGRAM_BOT_TOKEN='your_bot_token'"
    echo "   export TELEGRAM_CHAT_ID='your_chat_id'"
    echo "4. Add to ~/.bashrc for permanent setup"
fi

# Always log the report
echo "$COMBINED_REPORT" >> /tmp/stock-reports.log
