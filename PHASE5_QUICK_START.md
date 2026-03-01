# Phase 5 Security Audit Automation - Quick Start Guide

## Overview
Phase 5 automatically runs 4 specialized security analysis agents on your Pi5:
- 🚨 **Offensive Security** - Attack surface & vulnerability assessment
- 🛡️ **Defensive Security** - Hardening & defense-in-depth review
- 🔐 **Privacy & Compliance** - Data protection & regulatory gaps
- ⚙️ **Operational Security** - Resilience & disaster recovery

**Schedule:** Mon/Wed/Fri at midnight (runs until ~6 AM)
**Cost:** $0 (uses existing Ollama on 192.168.1.89)
**Impact on Pi5:** Zero (remote API calls only)

---

## Installation

### 1. Enable Automated Scheduling
```bash
cd /home/clawbotpi/.openclaw/workspace
./cron/phase5-schedule.sh
```

This adds Phase 5 to your crontab to run automatically Mon/Wed/Fri at midnight.

### 2. Verify Installation
```bash
crontab -l | grep phase5
```

You should see:
```
0 0 * * 1,3,5 /usr/bin/python3 /home/clawbotpi/.openclaw/workspace/cron/phase5-security-analysis.py >> /home/clawbotpi/.openclaw/cron/phase5.log 2>&1
```

---

## Running Phase 5

### Manual Test Run
```bash
python3 /home/clawbotpi/.openclaw/workspace/cron/phase5-security-analysis.py
```

Expected output:
```
================================================================================
🔒 PHASE 5: SECURITY AUDIT AUTOMATION (Remote Ollama API)
================================================================================
Start time: 2026-03-01T07:30:00.000000

📡 Checking Ollama API health...
✅ Ollama API is healthy

🤖 Selecting analysis model...
✅ Using model: qwen2.5:14b

================================================================================
RUNNING SECURITY ANALYSIS AGENTS
================================================================================

🔍 Running Offensive Security Analyst...
✅ Offensive Security Analyst completed

🔍 Running Defensive Security Analyst...
✅ Defensive Security Analyst completed

🔍 Running Privacy & Compliance Analyst...
✅ Privacy & Compliance Analyst completed

🔍 Running Operational Security Analyst...
✅ Operational Security Analyst completed

================================================================================
SAVING REPORT
================================================================================

📄 Report saved to: /home/clawbotpi/.openclaw/workspace/security-reports/phase5-report-2026-03-01_07-30-45.md

================================================================================
✅ PHASE 5 ANALYSIS COMPLETE
================================================================================
```

### Automatic Scheduled Runs
Phase 5 will run automatically:
- **Monday** at 00:00 (midnight)
- **Wednesday** at 00:00 (midnight)
- **Friday** at 00:00 (midnight)

Logs are saved to:
```
/home/clawbotpi/.openclaw/cron/phase5.log
```

---

## Viewing Reports

### List All Reports
```bash
ls -lh /home/clawbotpi/.openclaw/workspace/security-reports/
```

### View Latest Report
```bash
cat /home/clawbotpi/.openclaw/workspace/security-reports/$(ls -t /home/clawbotpi/.openclaw/workspace/security-reports/ | head -1)
```

### View Specific Report
```bash
cat /home/clawbotpi/.openclaw/workspace/security-reports/phase5-report-2026-03-01_07-30-45.md
```

---

## Understanding the Reports

Each report contains:

1. **Executive Summary**
   - Status of all 4 agents
   - Model used for analysis
   - Analysis scope

2. **Agent Findings** (4 sections)
   - Full analysis from each specialized agent
   - Specific vulnerabilities identified
   - Recommendations for remediation

3. **Metadata**
   - Hostname, IP address
   - Report timestamp
   - File location

---

## Troubleshooting

### Phase 5 Fails to Run
**Error:** `Ollama API is unreachable`

**Solution:**
1. Check if 192.168.1.89 is reachable:
   ```bash
   ping 192.168.1.89
   ```
2. Check if Ollama is running:
   ```bash
   curl http://192.168.1.89:11434/api/tags
   ```
3. If Ollama is down, start it and retry Phase 5

### Phase 5 Timeout
**Error:** `timeout after 300s`

**Cause:** Ollama is very busy or network is slow

**Solution:**
- Increase `TIMEOUT` in the script (line ~28): Change `300` to `600`
- Wait for other Ollama tasks to complete
- Run manually during off-peak hours

### No Models Available
**Error:** `No suitable models found on Ollama`

**Solution:**
1. SSH to 192.168.1.89
2. Pull a model:
   ```bash
   ollama pull qwen2.5:14b
   ```
3. Retry Phase 5

### Report Not Generated
**Check logs:**
```bash
tail -50 /home/clawbotpi/.openclaw/cron/phase5.log
```

---

## Performance Impact

**On Pi5 (local):**
- CPU: Minimal (just making HTTP requests)
- Memory: Negligible (<50MB)
- Disk: 1-2MB per report
- Network: ~10MB total (API calls)

**On 192.168.1.89 (Ollama):**
- CPU: High during analysis
- Memory: Model loaded into RAM
- Disk: None (inference only)

---

## Customization

### Change Schedule
Edit `/home/clawbotpi/.openclaw/workspace/cron/phase5-schedule.sh`

Examples:
- Daily: `0 0 * * *`
- Every hour: `0 * * * *`
- Sunday + Wednesday: `0 0 * * 0,3`

### Change Model
Edit `/home/clawbotpi/.openclaw/workspace/cron/phase5-security-analysis.py`

Line ~19:
```python
MODELS = ["qwen2.5:14b", "qwen2.5:7b", "llama3.1:8b"]
```

Change to your preferred models from `192.168.1.89:11434/api/tags`

### Change Analysis Prompts
Edit the AGENTS dict in phase5-security-analysis.py (~line 33)

Each agent has a "prompt" field you can customize.

---

## Support

### View Full Documentation
```bash
cat /home/clawbotpi/.openclaw/workspace/MEMORY.md | grep -A 20 "Phase 5"
```

### Check Script Source
```bash
less /home/clawbotpi/.openclaw/workspace/cron/phase5-security-analysis.py
```

---

## Notes

- Phase 5 was implemented using **Option C** (Remote Ollama API)
- This keeps your Pi5 lightweight and stable
- Reports are generated in Markdown for easy reading
- Telegram integration is ready (pending final setup)

**First run recommendation:** Run manually during daytime to verify it works, then enable cron for automatic overnight runs.
