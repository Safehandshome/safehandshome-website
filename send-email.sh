#!/bin/bash
# ProtonMail (Hydroxide) Email Sending Utility
# Source: MEMORY.md - Email Configuration
# Usage: ./send-email.sh <to_email> <subject> <body_file_or_text>

set -euo pipefail

# Configuration (from MEMORY.md)
FROM_EMAIL="pi5-clawbot@proton.me"
SMTP_HOST="127.0.0.1"
SMTP_PORT="1025"
SMTP_USERNAME="pi5-clawbot@proton.me"
SMTP_PASSWORD="5GJdVrVMEbMJoud2AtAU7s7bqDiXv+3nnTehI7LLQRo="

# Arguments
TO_EMAIL="${1:-}"
SUBJECT="${2:-}"
BODY="${3:-}"

# Validate arguments
if [[ -z "$TO_EMAIL" || -z "$SUBJECT" || -z "$BODY" ]]; then
    cat << EOF
Usage: $0 <to_email> <subject> <body_file_or_text>

Examples:
  # Send with text body
  $0 "user@example.com" "Subject Line" "Email body text here"

  # Send with file body
  $0 "user@example.com" "Subject Line" "/path/to/email-body.txt"

Configuration (from MEMORY.md):
  From: $FROM_EMAIL
  SMTP: $SMTP_HOST:$SMTP_PORT
EOF
    exit 1
fi

# Check if body is a file or text
if [[ -f "$BODY" ]]; then
    BODY_CONTENT=$(<"$BODY")
else
    BODY_CONTENT="$BODY"
fi

# Create email via Python
python3 << PYTHON_EOF
import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart

SMTP_HOST = "$SMTP_HOST"
SMTP_PORT = $SMTP_PORT
FROM_EMAIL = "$FROM_EMAIL"
SMTP_USERNAME = "$SMTP_USERNAME"
SMTP_PASSWORD = "$SMTP_PASSWORD"

TO_EMAIL = "$TO_EMAIL"
SUBJECT = "$SUBJECT"
BODY = """$BODY_CONTENT"""

# Create message
msg = MIMEMultipart()
msg['From'] = FROM_EMAIL
msg['To'] = TO_EMAIL
msg['Subject'] = SUBJECT
msg.attach(MIMEText(BODY, 'plain'))

# Send email
try:
    server = smtplib.SMTP(SMTP_HOST, SMTP_PORT, timeout=10)
    server.login(SMTP_USERNAME, SMTP_PASSWORD)
    server.sendmail(FROM_EMAIL, TO_EMAIL, msg.as_string())
    server.quit()
    print("✅ Email sent successfully!")
    print(f"   From: {FROM_EMAIL}")
    print(f"   To: {TO_EMAIL}")
    print(f"   Subject: {SUBJECT}")
except Exception as e:
    print(f"❌ Error sending email: {e}")
    exit(1)
PYTHON_EOF
