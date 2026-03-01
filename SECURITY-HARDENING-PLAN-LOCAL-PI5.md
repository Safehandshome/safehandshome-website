# Security Hardening Plan - Local OpenClaw Pi 5

**Status:** Research & Recommendations Only (No Implementation Until Approved)
**Created:** 2026-02-27
**Target System:** Raspberry Pi 5 (8GB RAM) running OpenClaw at home (Warren, NJ)

---

## Executive Summary

Your local OpenClaw Pi 5 hosts:
- **OpenClaw agent** (main session)
- **Ollama LLM server** (http://192.168.1.89:11434)
- **OpenClaw Gateway** (port 18789, loopback only)
- **Cron jobs** (backup health checks, weather alerts)
- **Tailscale VPN client** (for remote access to Vermont HA)

**Current Risk Level:** LOW-MEDIUM
- Gateway bound to loopback (localhost only) — good
- On home LAN behind router/firewall — good
- No SSH hardening documented — gap
- Ollama accessible on LAN without auth — gap
- PiHole DNS active (good DNS filtering)

---

## Priority 1: Network Isolation (High Impact, Low Risk)

### 1.1 Enable UFW Firewall

**What it does:** Restrict which machines on your LAN can access OpenClaw services.

**Current Situation:**
- Ollama: `http://192.168.1.89:11434` (LAN-accessible, no password)
- OpenClaw Gateway: `localhost:18789` (loopback only, good)
- SSH: Unknown if enabled

**Recommendation:**
```bash
# Default: deny all inbound, allow all outbound
sudo ufw default deny incoming
sudo ufw default allow outgoing

# Allow SSH from home machines only
sudo ufw allow from 192.168.1.0/24 to any port 22 comment 'SSH from home LAN'

# Allow Ollama from home LAN only
sudo ufw allow from 192.168.1.0/24 to any port 11434 comment 'Ollama from home LAN'

# Allow Tailscale (for remote access)
sudo ufw allow 41641/udp comment 'Tailscale'

# BLOCK Ollama from external networks (not in UFW; Tailscale VPN is separate)

# Enable firewall
sudo ufw enable
```

**Approval Required:** YES
**Risk Level:** LOW — tested on home LAN
**Estimated Time:** 5 minutes

**Rationale:** This prevents devices from your guest WiFi or neighbors' networks from accessing Ollama.

---

### 1.2 Secure Ollama Access

**Current Problem:** Ollama has no authentication; anyone on your LAN can use it (and burn tokens if misconfigured).

**Option A: Add API Key (Recommended)**
```bash
# Set environment variable before running Ollama
export OLLAMA_API_KEY="your-secret-key-here"

# Then clients must pass:
# Authorization: Bearer your-secret-key-here
```

**Option B: Bind Ollama to localhost only**
```bash
# Edit Ollama startup config to bind to 127.0.0.1:11434
# (Won't be accessible from other machines)
```

**Approval Required:** YES
**Risk Level:** LOW
**Estimated Time:** 5 minutes

---

## Priority 2: SSH Hardening (Medium Impact, Medium Risk)

### 2.1 Check if SSH is Enabled

**First step:**
```bash
sudo systemctl status ssh
```

If SSH is running:

### 2.2 SSH Key-Based Authentication

**Current state:** Likely password-based (default)
**Risk:** Brute-force attacks on SSH

**Recommendation:**
1. Generate SSH key on your laptop (if not already done)
2. Copy public key to Pi: `ssh-copy-id -i ~/.ssh/id_rsa.pub clawbotpi@192.168.1.XXX`
3. Disable password auth in `/etc/ssh/sshd_config`
4. Test before fully disabling

**Approval Required:** YES — can lock you out
**Risk Level:** MEDIUM
**Estimated Time:** 15 minutes

---

### 2.3 Change SSH Port (Optional)

**Recommendation:** Change from default 22 to 2222 (reduces automated scanning)

**Approval Required:** YES
**Risk Level:** LOW
**Estimated Time:** 5 minutes

---

## Priority 3: OpenClaw Gateway Security (Medium Impact, Low Risk)

### 3.1 Gateway Token Rotation

**Current state:** Token stored in `openclaw.json` — check if it's still valid

**Recommendation:**
```bash
# Rotate Gateway token regularly (monthly)
# Store new token securely (password manager)
# Update config: ~/.openclaw/openclaw.json
```

**Approval Required:** NO — operational best practice
**Risk Level:** N/A

---

### 3.2 Disable Gateway Telemetry (Optional)

**What it does:** Stops OpenClaw from sending usage data (if enabled).

**Recommendation:**
```bash
# Check current telemetry setting
cat ~/.openclaw/openclaw.json | grep -i telemetry

# If present, disable:
# "telemetry": false
```

**Approval Required:** NO
**Risk Level:** N/A

---

## Priority 4: File System & Backups (Medium Impact, Low Risk)

### 4.1 Enable LUKS Full-Disk Encryption (Advanced, NOT Recommended for Pi)

**Why not:** LUKS on SD card/NVMe slows performance significantly on ARM.
**Alternative:** Encrypt sensitive files only (e.g., `MEMORY.md`, API keys).

**Approval Required:** NO — not recommended
**Risk Level:** N/A

---

### 4.2 Backup Sensitive Files

**Recommendation:**
```bash
# Backup API keys, tokens, passwords
# Store encrypted on external drive or NAS

# Files to backup:
# - ~/.openclaw/openclaw.json (contains API keys!)
# - ~/.openclaw/workspace/MEMORY.md (personal data)
# - ~/.ssh/ (SSH keys)

# Example: encrypted tar
tar czf - ~/.openclaw/openclaw.json | gpg --encrypt > backup.tar.gz.gpg
```

**Approval Required:** NO — operational best practice
**Risk Level:** N/A

---

## Priority 5: System Updates & Patching (High Impact, Low Risk)

### 5.1 Enable Automatic Security Updates

**Recommendation:**
```bash
sudo apt-get install unattended-upgrades apt-listchanges

sudo dpkg-reconfigure -plow unattended-upgrades

# Configure to auto-reboot if needed
sudo nano /etc/apt/apt.conf.d/50unattended-upgrades
# Set: Unattended-Upgrade::Automatic-Reboot "true";
```

**Approval Required:** YES — auto-reboot can interrupt work
**Risk Level:** LOW-MEDIUM
**Estimated Time:** 10 minutes

---

### 5.2 Regular Manual Updates

**Recommendation:**
```bash
# Weekly check
sudo apt update && sudo apt list --upgradable

# Monthly full upgrade
sudo apt upgrade -y
sudo apt full-upgrade -y
```

**Approval Required:** NO — operational
**Risk Level:** N/A

---

## Priority 6: Monitoring & Logging (Medium Impact, Low Risk)

### 6.1 Monitor OpenClaw Logs

**Recommendation:**
```bash
# Check for errors or anomalies
tail -f ~/.openclaw/workspace/memory/$(date +%Y-%m-%d).md

# Monitor system logs for suspicious activity
sudo tail -f /var/log/auth.log | grep -E "Failed|Accepted"
```

**Approval Required:** NO
**Risk Level:** N/A

---

### 6.2 Setup Log Rotation

**Recommendation:**
```bash
# Ensure logs don't fill up disk
# Check logrotate config
cat /etc/logrotate.d/rsyslog
```

**Approval Required:** NO
**Risk Level:** N/A

---

## Priority 7: Malware & Intrusion Detection (Medium Impact, Low Risk)

### 7.1 Install ClamAV (Optional, Minimal Overhead)

**What it does:** Scans for malware on a schedule.

**Recommendation:**
```bash
sudo apt-get install clamav clamav-daemon

# Update virus database
sudo freshclam

# Scan home directory weekly
0 2 * * 0 clamscan -r -i /home/clawbotpi >> /var/log/clamav-scan.log
```

**Approval Required:** NO — optional, non-intrusive
**Risk Level:** N/A
**Estimated Time:** 10 minutes

---

## Priority 8: Incident Response Plan (N/A, Planning)

### 8.1 If You Suspect Compromise

**Steps:**
1. **Isolate the Pi** (unplug network)
2. **Revoke API keys** (Anthropic, Brave, Home Assistant tokens)
3. **Check for unauthorized SSH keys** (`cat ~/.ssh/authorized_keys`)
4. **Review logs** (`sudo journalctl -u sshd`)
5. **Reflash OS** if necessary (full reset)

**Approval Required:** NO — emergency procedure
**Risk Level:** N/A

---

## Implementation Roadmap

**Phase 1 (Week 1) — Foundation:**
- [ ] Approve & enable UFW firewall
- [ ] Secure Ollama access (API key or localhost-only)
- [ ] Test SSH key-based auth

**Phase 2 (Week 2) — Hardening:**
- [ ] Configure SSH (disable password auth, change port)
- [ ] Enable automatic security updates
- [ ] Rotate OpenClaw Gateway token

**Phase 3 (Week 3) — Monitoring:**
- [ ] Set up log monitoring
- [ ] Backup sensitive files (encrypted)
- [ ] (Optional) Install ClamAV

**Phase 4 (Ongoing):**
- [ ] Monthly security updates
- [ ] Quarterly token/key rotation
- [ ] Review logs monthly

---

## Risks & Mitigation

| Risk | Severity | Mitigation |
|------|----------|-----------|
| Lock yourself out of SSH | HIGH | Test thoroughly, keep Tailscale as backup |
| Firewall breaks OpenClaw | MEDIUM | Gateway is loopback-only, shouldn't break |
| Auto-updates break system | LOW | Test on non-critical Pi first |
| Ollama unauthorized access | MEDIUM | Add API key or bind to localhost |
| API keys exposed | HIGH | Store in encrypted backup, rotate regularly |

---

## Questions to Answer

1. Do you currently use SSH to access this Pi? (If yes, from where?)
2. Do you want automatic system updates or manual control?
3. Should Ollama be accessible from other home devices, or localhost-only?
4. Do you have automated backups of `openclaw.json` (contains API keys)?
5. What's your risk tolerance — paranoid (maximum security) or pragmatic (usability-balanced)?

---

**Status:** AWAITING YOUR FEEDBACK & APPROVAL
