# CRON JOBS COMPREHENSIVE GUIDE
**Last Updated:** 2026-03-02 08:00 EST  
**Machine:** raspberrypi (Local Pi5 - Warren, NJ)  
**User:** clawbotpi  

---

## TABLE OF CONTENTS
1. [Current Cron Jobs (All 6)](#current-cron-jobs-all-6)
2. [How to Modify Cron Jobs](#how-to-modify-cron-jobs)
3. [How to Add New Cron Jobs](#how-to-add-new-cron-jobs)
4. [How to Troubleshoot](#how-to-troubleshoot)
5. [Cron Syntax Reference](#cron-syntax-reference)
6. [Quick Reference Table](#quick-reference-table)

---

## CURRENT CRON JOBS (All 6)

### 1. PHASE 5 SECURITY ANALYSIS
**Schedule:** 6:30 AM EST, every day  
**Cron:** `30 6 * * *`  
**Script:** `/home/clawbotpi/security-analysis-6am.sh`  
**Log:** `/tmp/security-analysis-cron.log`  
**Purpose:** Daily security audit and analysis  
**Deliverability:** Telegram alerts  
**Status:** ✅ Active

**What it does:**
- Analyzes system security posture
- Checks for vulnerabilities
- Sends alerts via Telegram if issues found

**View output:**
```bash
tail -f /tmp/security-analysis-cron.log
```

---

### 2. HOME ASSISTANT ERROR LOGS EMAIL
**Schedule:** 6:30 AM EST, every day  
**Cron:** `30 6 * * *`  
**Script:** `python3 /home/clawbotpi/send-ha-error-logs-email.py`  
**Log:** `/tmp/ha-error-logs-cron.log`  
**Purpose:** Collect and email HA errors from Synology & Vermont instances  
**Deliverability:** Email to pi5-clawbot@proton.me  
**Status:** ✅ Active

**What it does:**
- Pulls error logs from Synology HA (192.168.1.162)
- Pulls error logs from Vermont HA (100.80.46.65 via Tailscale)
- Compiles report and sends via email

**View output:**
```bash
tail -f /tmp/ha-error-logs-cron.log
```

---

### 3. MORNING WEATHER ALERT
**Schedule:** 6:45 AM EST, every day  
**Cron:** `45 6 * * *`  
**Script:** `/home/clawbotpi/.openclaw/workspace/cron/weather-alert.sh`  
**Log:** `/tmp/weather-cron.log`  
**Purpose:** Weather forecast for Warren, NJ and Windham, VT  
**Deliverability:** Telegram  
**Status:** ✅ Active

**Locations monitored:**
- Warren, NJ (40.6562, -74.2808)
- Windham, VT (44.3956, -72.4275)

**What it does:**
- Fetches current conditions (temp, humidity, wind)
- Gets daily high/low forecast
- Reports precipitation probability
- Uses Open-Meteo API (free, no credits)

**View output:**
```bash
tail -f /tmp/weather-cron.log
```

---

### 4. INTRADAY WEATHER ALERTS
**Schedule:** 1 PM, 4 PM, 7 PM, 10 PM EST, every day  
**Cron:** `0 13,16,19,22 * * *`  
**Script:** `/home/clawbotpi/.openclaw/workspace/cron/weather-alert.sh`  
**Log:** `/tmp/weather-cron.log` (same as #3)  
**Purpose:** Temperature/weather updates throughout the day  
**Deliverability:** Telegram  
**Status:** ✅ Active

**What it does:**
- Same as morning alert, but runs 4 additional times
- Provides real-time weather updates for planning

**View output:**
```bash
tail -f /tmp/weather-cron.log
```

---

### 5. STOCK MARKET AFTER-HOURS ANALYSIS
**Schedule:** 6:30 AM EST, Monday-Friday only  
**Cron:** `30 6 * * 1-5`  
**Script:** `/home/clawbotpi/.openclaw/workspace/cron/stock-afterhours.sh`  
**Log:** `/tmp/stock-afterhours.log`  
**Purpose:** Analyze after-hours trading from previous night  
**Deliverability:** Local file (used by job #6)  
**Status:** ✅ Active

**What it does:**
- Fetches after-hours market data
- Analyzes trends from previous trading session
- Generates data for email report

**View output:**
```bash
tail -f /tmp/stock-afterhours.log
```

---

### 6. STOCK MARKET REPORT EMAIL
**Schedule:** 6:35 AM EST, Monday-Friday only  
**Cron:** `35 6 * * 1-5`  
**Script:** `/home/clawbotpi/.openclaw/workspace/cron/send-stock-report.sh`  
**Log:** `/tmp/send-stock-report.log`  
**Purpose:** Generate and email stock report summary  
**Deliverability:** Email to pi5-clawbot@proton.me  
**Status:** ✅ Active

**What it does:**
- Uses data from job #5
- Compiles formatted stock report
- Sends via email with key metrics

**View output:**
```bash
tail -f /tmp/send-stock-report.log
```

---

## HOW TO MODIFY CRON JOBS

### Step 1: Open the Crontab Editor
```bash
crontab -e
```

This opens the crontab file in your default text editor (usually `nano` or `vi`).

### Step 2: Understand the Format
Each cron line has this format:
```
MINUTE HOUR DAY_OF_MONTH MONTH DAY_OF_WEEK COMMAND
```

Example:
```
30 6 * * * bash /home/clawbotpi/security-analysis-6am.sh >> /tmp/security-analysis-cron.log 2>&1
```

Breakdown:
- `30` = minute (30th minute of the hour)
- `6` = hour (6 AM)
- `*` = any day of month
- `*` = any month
- `*` = any day of week
- `bash /home/clawbotpi/security-analysis-6am.sh >> /tmp/security-analysis-cron.log 2>&1` = command to run

### Step 3: Make Your Change

**Example 1: Change security analysis to run at 7 AM instead of 6:30 AM**

Find this line:
```
30 6 * * * bash /home/clawbotpi/security-analysis-6am.sh >> /tmp/security-analysis-cron.log 2>&1
```

Change to:
```
0 7 * * * bash /home/clawbotpi/security-analysis-6am.sh >> /tmp/security-analysis-cron.log 2>&1
```

**Example 2: Change weather to run only on weekdays (Mon-Fri)**

Find this line:
```
0 13,16,19,22 * * * bash /home/clawbotpi/.openclaw/workspace/cron/weather-alert.sh >> /tmp/weather-cron.log 2>&1
```

Change to:
```
0 13,16,19,22 * * 1-5 bash /home/clawbotpi/.openclaw/workspace/cron/weather-alert.sh >> /tmp/weather-cron.log 2>&1
```

**Example 3: Change weather to run every 2 hours instead of specific times**

Find this line:
```
0 13,16,19,22 * * * bash /home/clawbotpi/.openclaw/workspace/cron/weather-alert.sh >> /tmp/weather-cron.log 2>&1
```

Change to:
```
0 */2 * * * bash /home/clawbotpi/.openclaw/workspace/cron/weather-alert.sh >> /tmp/weather-cron.log 2>&1
```

### Step 4: Save and Exit
- **nano editor:** Press `Ctrl+X`, then `Y`, then `Enter`
- **vi editor:** Press `Esc`, type `:wq`, press `Enter`

### Step 5: Verify the Change
```bash
crontab -l
```

This shows all current cron jobs. You should see your modification.

### Step 6: Check the Log
After the scheduled time arrives, check the log to verify it ran:
```bash
tail -f /tmp/weather-cron.log
```

---

## HOW TO ADD NEW CRON JOBS

### Method 1: Direct Crontab Edit (Recommended)

**Step 1:** Open crontab editor
```bash
crontab -e
```

**Step 2:** Go to the end of the file and add a new line
```
# My new job - Description
0 8 * * * bash /path/to/script.sh >> /tmp/my-job.log 2>&1
```

**Step 3:** Save and exit (Ctrl+X or :wq)

**Step 4:** Verify
```bash
crontab -l | grep "my-job"
```

---

### Method 2: Add via Command Line

**Example: Add a job to run every day at 9 AM**

First, save your current crontab to a file:
```bash
crontab -l > /tmp/mycron.txt
```

Then add your new job:
```bash
echo "0 9 * * * bash /home/clawbotpi/.openclaw/workspace/cron/my-script.sh >> /tmp/my-script.log 2>&1" >> /tmp/mycron.txt
```

Then reload:
```bash
crontab /tmp/mycron.txt
```

Verify:
```bash
crontab -l
```

---

### Method 3: Using a Helper Script

Create a script like `/home/clawbotpi/add-cron.sh`:
```bash
#!/bin/bash
# Helper to add cron jobs safely

MINUTE=${1:-0}
HOUR=${2:-9}
DAY_OF_MONTH=${3:-*}
MONTH=${4:-*}
DAY_OF_WEEK=${5:-*}
SCRIPT_PATH=$6
LOG_PATH=${7:-/tmp/cron-job.log}

if [[ -z "$SCRIPT_PATH" ]]; then
    echo "Usage: $0 <minute> <hour> <day> <month> <weekday> <script_path> [log_path]"
    echo "Example: $0 0 9 '*' '*' '*' /home/clawbotpi/my-script.sh /tmp/my-script.log"
    exit 1
fi

CRON_LINE="${MINUTE} ${HOUR} ${DAY_OF_MONTH} ${MONTH} ${DAY_OF_WEEK} bash ${SCRIPT_PATH} >> ${LOG_PATH} 2>&1"

crontab -l > /tmp/mycron-temp.txt
echo "$CRON_LINE" >> /tmp/mycron-temp.txt
crontab /tmp/mycron-temp.txt

echo "✅ Added cron job:"
echo "$CRON_LINE"
crontab -l | tail -1
```

Use it:
```bash
chmod +x /home/clawbotpi/add-cron.sh
./add-cron.sh 0 9 '*' '*' '*' /home/clawbotpi/my-script.sh /tmp/my-script.log
```

---

## HOW TO TROUBLESHOOT

### Issue 1: Cron Job Not Running

**Check 1: Is cron service running?**
```bash
sudo systemctl status cron
```

If not running:
```bash
sudo systemctl start cron
sudo systemctl enable cron
```

**Check 2: Is the job in crontab?**
```bash
crontab -l
```

Should show your job.

**Check 3: Is the script executable?**
```bash
ls -la /home/clawbotpi/security-analysis-6am.sh
```

If not executable (no `x`):
```bash
chmod +x /home/clawbotpi/security-analysis-6am.sh
```

**Check 4: Check the log file**
```bash
tail -50 /tmp/security-analysis-cron.log
```

Look for errors.

**Check 5: Run the script manually**
```bash
bash /home/clawbotpi/security-analysis-6am.sh
```

If it fails manually, it will fail in cron too.

**Check 6: Check system logs**
```bash
journalctl -u cron --since "1 hour ago"
```

Shows cron errors from the system log.

---

### Issue 2: Cron Job Running But Not Producing Output

**Check 1: Verify the log path is writable**
```bash
touch /tmp/test-write.log && rm /tmp/test-write.log
```

**Check 2: Check if the script has errors but doesn't output them**

Add `set -x` to the top of your script to debug:
```bash
#!/bin/bash
set -x  # Enable debug mode
# ... rest of script
```

**Check 3: Test with a simple job**

Add this test cron job:
```
*/5 * * * * echo "$(date)" >> /tmp/cron-test.log
```

Wait 5 minutes. If it works, your cron is OK but the script has issues.

---

### Issue 3: Cron Job Running But Email Not Sending

**Check 1: Is Hydroxide SMTP running?**
```bash
ps aux | grep hydroxide
```

Should see hydroxide process.

**Check 2: Can you send email manually?**
```bash
/home/clawbotpi/.openclaw/workspace/send-email.sh "your@email.com" "Test" "This is a test"
```

**Check 3: Check SMTP logs**
```bash
journalctl -u hydroxide --since "10 minutes ago"
```

**Check 4: Test with telnet**
```bash
timeout 5 telnet 127.0.0.1 1025
```

Should connect without error.

---

### Issue 4: Cron Job Runs but Script Fails with "Command Not Found"

**Problem:** The script uses commands that cron can't find.

**Solution:** Use full paths in your scripts.

**Bad:**
```bash
curl http://example.com
python3 script.py
```

**Good:**
```bash
/usr/bin/curl http://example.com
/usr/bin/python3 /full/path/script.py
```

Find full paths:
```bash
which curl
which python3
which bash
```

---

### Issue 5: Environmental Variables Not Working in Cron

**Problem:** Your script uses `$HOME` or `$PATH` but cron runs in minimal environment.

**Solution:** Set variables in crontab.

```bash
# At the top of crontab:
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
HOME=/home/clawbotpi
SHELL=/bin/bash

# Then your jobs:
0 6 * * * bash $HOME/.openclaw/workspace/cron/weather-alert.sh
```

---

### Debugging Checklist

Run through this in order:

```bash
# 1. Check cron service
sudo systemctl status cron

# 2. List all cron jobs
crontab -l

# 3. Check if script exists
ls -la /path/to/script.sh

# 4. Check if script is executable
chmod +x /path/to/script.sh

# 5. Test script manually
bash /path/to/script.sh

# 6. Check logs
tail -50 /tmp/your-job.log

# 7. Check system cron logs
journalctl -u cron --since "2 hours ago"

# 8. Add test job (runs every minute)
# In crontab -e, add:
# * * * * * echo "$(date)" >> /tmp/test-cron.log

# 9. Wait 1-2 minutes and check
tail /tmp/test-cron.log
```

---

## CRON SYNTAX REFERENCE

### Field Order
```
┌─────────────── minute (0 - 59)
│ ┌───────────── hour (0 - 23)
│ │ ┌─────────── day of month (1 - 31)
│ │ │ ┌───────── month (1 - 12 or JAN-DEC)
│ │ │ │ ┌─────── day of week (0 - 7, 0 and 7 = Sunday)
│ │ │ │ │
│ │ │ │ │
* * * * * command_to_run
```

### Special Symbols

| Symbol | Meaning | Example |
|--------|---------|---------|
| `*` | Any value | `* * * * *` = every minute |
| `,` | Multiple values | `0,30 * * * *` = at :00 and :30 |
| `-` | Range | `0-15 * * * *` = minutes 0-15 |
| `/` | Step values | `*/5 * * * *` = every 5 minutes |

### Common Examples

| Schedule | Cron | Purpose |
|----------|------|---------|
| Every minute | `* * * * *` | Test jobs |
| Every 5 minutes | `*/5 * * * *` | Frequent checks |
| Every hour | `0 * * * *` | Hourly tasks |
| Every day at 6 AM | `0 6 * * *` | Daily reports |
| Every Monday at 9 AM | `0 9 * * 1` | Weekly tasks |
| Every weekday at 8 AM | `0 8 * * 1-5` | Work-week only |
| Every 1st of month at midnight | `0 0 1 * *` | Monthly tasks |
| Every quarter (Jan, Apr, Jul, Oct) | `0 0 1 1,4,7,10 *` | Quarterly reports |

### Day of Week Reference
- `0` = Sunday
- `1` = Monday
- `2` = Tuesday
- `3` = Wednesday
- `4` = Thursday
- `5` = Friday
- `6` = Saturday
- `7` = Sunday (also valid)

---

## QUICK REFERENCE TABLE

| Job | Time | Frequency | Script | Log |
|-----|------|-----------|--------|-----|
| Security Analysis | 6:30 AM | Daily | `/home/clawbotpi/security-analysis-6am.sh` | `/tmp/security-analysis-cron.log` |
| HA Error Logs | 6:30 AM | Daily | `python3 /home/clawbotpi/send-ha-error-logs-email.py` | `/tmp/ha-error-logs-cron.log` |
| Weather (Morning) | 6:45 AM | Daily | `/home/clawbotpi/.openclaw/workspace/cron/weather-alert.sh` | `/tmp/weather-cron.log` |
| Weather (Intraday) | 1/4/7/10 PM | Daily | `/home/clawbotpi/.openclaw/workspace/cron/weather-alert.sh` | `/tmp/weather-cron.log` |
| Stock Analysis | 6:30 AM | Mon-Fri | `/home/clawbotpi/.openclaw/workspace/cron/stock-afterhours.sh` | `/tmp/stock-afterhours.log` |
| Stock Report Email | 6:35 AM | Mon-Fri | `/home/clawbotpi/.openclaw/workspace/cron/send-stock-report.sh` | `/tmp/send-stock-report.log` |

---

## COMMON MISTAKES

| ❌ Wrong | ✅ Correct | Why |
|---------|-----------|-----|
| `*/5 6-9 * * *` | `*/5 6-9 * * *` | This is correct, but beware: runs every 5 min 6-9 AM |
| `0 6:30 * * *` | `30 6 * * *` | Cron doesn't use colons; use separate fields |
| `bash script.sh` | `bash /full/path/script.sh` | Cron doesn't have $PATH; use full paths |
| `0 6 * * *` (no redirection) | `0 6 * * * bash script.sh >> /tmp/log.log 2>&1` | Without redirection, output goes nowhere |
| `0 6 * * *` (script not executable) | `chmod +x script.sh` first | Cron may fail silently if script can't execute |

---

## USEFUL COMMANDS

### View Cron Jobs
```bash
crontab -l              # View all jobs
crontab -l -u username # View another user's jobs
```

### Edit Cron Jobs
```bash
crontab -e              # Edit in default editor
```

### Remove All Cron Jobs
```bash
crontab -r              # WARNING: Deletes ALL jobs!
```

### Check Cron Service
```bash
sudo systemctl status cron
sudo systemctl restart cron
sudo systemctl enable cron
```

### Test a Script Before Adding to Cron
```bash
bash /home/clawbotpi/script.sh          # Run manually
bash -x /home/clawbotpi/script.sh       # Run with debug output
```

### Check System Cron Logs
```bash
journalctl -u cron --since "1 hour ago"
grep CRON /var/log/syslog              # Alternative
```

### Find Cron Related Files
```bash
ls -la /var/spool/cron/crontabs/        # System cron jobs
ls -la /etc/cron.d/                     # System cron files
ls -la /etc/cron.daily/                 # Daily scripts
```

---

## NEXT STEPS

**To modify a cron job:**
```bash
crontab -e
# Make your changes
# Save and exit
crontab -l  # Verify
```

**To add a new cron job:**
```bash
crontab -e
# Add new line at the end
# Example: 0 9 * * * bash /home/clawbotpi/new-script.sh >> /tmp/new-script.log 2>&1
```

**To debug a failing job:**
1. Check if job is in `crontab -l`
2. Check if script is executable: `chmod +x script.sh`
3. Run script manually: `bash script.sh`
4. Check logs: `tail -50 /tmp/job.log`
5. Check system logs: `journalctl -u cron --since "1 hour ago"`

---

**Questions?** Check the logs, Google the error, or run the debugging checklist!
