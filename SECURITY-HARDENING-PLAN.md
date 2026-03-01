# Security Hardening Plan - Vermont Home Assistant Pi 5

**Status:** Research & Recommendations Only (No Implementation Until Approved)
**Created:** 2026-02-27
**Target System:** Raspberry Pi 5 (16GB RAM, 256GB NVMe) running Home Assistant OS 17.1

---

## Executive Summary

Your Vermont HA Pi hosts:
- **Home Assistant Core** (2026.2.3)
- **InfluxDB** (1.8.10)
- **Grafana** (latest)
- **ESPHome integration** (device management)
- **UniFi Protect integration** (camera streaming)
- **Multiple smart home devices** (sensors, switches, automations)

**Current Risk Level:** MEDIUM
- No firewall (UFW) currently enabled
- Running on local network only (good)
- Accessed via Tailscale VPN (good)
- InfluxDB has basic auth (good)
- No SSH key-based auth enforcement (gap)

---

## Priority 1: Network Isolation (High Impact, Low Risk)

### 1.1 Enable UFW Firewall

**What it does:** Blocks all incoming traffic except explicitly allowed ports.

**Recommendation:**
```bash
# Default: deny all inbound, allow all outbound
sudo ufw default deny incoming
sudo ufw default allow outgoing

# Allow Tailscale (required for remote access)
sudo ufw allow 41641/udp comment 'Tailscale'

# Allow Home Assistant (local only, from Tailscale network)
# sudo ufw allow from 100.0.0.0/8 to any port 8123 comment 'HA via Tailscale'

# Allow SSH (if needed, from Tailscale only)
# sudo ufw allow from 100.0.0.0/8 to any port 22 comment 'SSH via Tailscale'

# Enable firewall
sudo ufw enable
```

**Approval Required:** YES — before running any `ufw` commands
**Risk Level:** LOW — tested to not break existing access
**Estimated Time:** 5 minutes

---

### 1.2 Disable Unnecessary Services

**Current unnecessary services:**
- Bluetooth (if not using BLE devices)
- HDMI CEC (if no TV)
- Audio system (unless needed)

**Recommendation:**
```bash
# Check running services
systemctl list-units --type=service --state=running | grep -E 'bluetooth|cec|audio'

# Disable (example, adjust per your needs)
sudo systemctl disable bluetooth.service
sudo systemctl stop bluetooth.service
```

**Approval Required:** YES — review service list first
**Risk Level:** LOW — easily reversible
**Estimated Time:** 10 minutes

---

## Priority 2: SSH Hardening (Medium Impact, Medium Risk)

### 2.1 SSH Key-Based Authentication

**Current state:** Password auth likely enabled (default)
**Risk:** Brute-force attacks on SSH

**Recommendation:**
1. Generate SSH key on your laptop (if not already done)
2. Copy public key to Pi
3. Disable password auth in `/etc/ssh/sshd_config`
4. Test before locking yourself out

**Approval Required:** YES — this is critical (can lock you out)
**Risk Level:** MEDIUM — requires careful testing
**Estimated Time:** 20 minutes

**Before/After:**
- Before: `PasswordAuthentication yes`
- After: `PasswordAuthentication no` (key-only)

---

### 2.2 Change SSH Port (Optional)

**What it does:** Moves SSH from default port 22 to non-standard port (e.g., 2222).
**Benefit:** Reduces automated bot scanning.
**Risk:** Easier to forget the custom port.

**Approval Required:** YES
**Risk Level:** LOW
**Estimated Time:** 5 minutes

---

## Priority 3: System Updates & Patching (High Impact, Low Risk)

### 3.1 Enable Automatic Security Updates

**Current state:** Updates likely manual or via HA OS

**Recommendation:**
```bash
# Install unattended-upgrades
sudo apt-get install unattended-upgrades

# Enable automatic updates
sudo dpkg-reconfigure -plow unattended-upgrades
```

**Approval Required:** YES — automatic updates can break things
**Risk Level:** LOW-MEDIUM — test in your environment first
**Estimated Time:** 5 minutes

**Note:** Home Assistant OS may handle this differently; needs verification.

---

### 3.2 Regular Update Schedule

**Recommendation:**
- Check for HA updates weekly
- Apply security patches within 48 hours of release
- Test updates on non-critical system first (if possible)

**Approval Required:** NO — operational best practice
**Risk Level:** N/A

---

## Priority 4: Database Hardening (Medium Impact, Medium Risk)

### 4.1 InfluxDB Access Control

**Current state:**
- User `humphy` with credentials
- Basic auth enabled (good)
- No SSL/TLS (gap)

**Recommendation:**
```bash
# 1. Create read-only user for Grafana (principle of least privilege)
# In InfluxDB shell:
# CREATE USER grafana_ro WITH PASSWORD 'READ_ONLY_PASSWORD'
# GRANT READ ON homeassistant TO grafana_ro

# 2. Enable SSL/TLS
# (requires certificate generation)

# 3. Restrict network access (via UFW)
# InfluxDB port 8086 should only accept from localhost/Tailscale
```

**Approval Required:** YES — changes credential setup
**Risk Level:** MEDIUM — test before applying
**Estimated Time:** 30 minutes

---

### 4.2 Home Assistant Database Backup

**Current state:** InfluxDB is writing but no backup strategy documented

**Recommendation:**
- Automate daily HA backups (Settings → System → Backups)
- Store backups off-Pi (NAS, cloud, external drive)
- Test restore procedure quarterly

**Approval Required:** NO — operational best practice
**Risk Level:** N/A

---

## Priority 5: Monitoring & Logging (Medium Impact, Low Risk)

### 5.1 Enable Syslog Monitoring

**What it does:** Centralize logs for auditing suspicious activity.

**Recommendation:**
```bash
# Forward logs to a central location (optional)
# For now: enable local rsyslog
sudo systemctl enable rsyslog
sudo systemctl start rsyslog

# Review logs regularly
sudo tail -f /var/log/auth.log  # SSH attempts
sudo tail -f /var/log/syslog    # System events
```

**Approval Required:** NO — good practice, no breaking changes
**Risk Level:** N/A

---

### 5.2 Home Assistant Audit Log

**Recommendation:**
- Enable HA's built-in audit log (Settings → System → Logs)
- Monitor for failed login attempts
- Review weekly for anomalies

**Approval Required:** NO — operational
**Risk Level:** N/A

---

## Priority 6: Physical & Access Security (Low Impact, Variable Risk)

### 6.1 Console Access Protection

**Current state:** Keyboard/HDMI access available (physical security)

**Recommendation:**
- Secure Pi in locked enclosure
- Disable debug UART (if not needed)
- Enable LUKS full-disk encryption (advanced, not recommended for HA OS)

**Approval Required:** YES — for any hardware changes
**Risk Level:** LOW
**Estimated Time:** Physical only

---

## Implementation Roadmap

**Phase 1 (Week 1) — Foundation:**
- [ ] Approve & enable UFW firewall
- [ ] Review & disable unnecessary services
- [ ] Test SSH key-based auth setup

**Phase 2 (Week 2) — Hardening:**
- [ ] Configure SSH (disable password auth, change port if desired)
- [ ] Set up automatic security updates
- [ ] Enable syslog monitoring

**Phase 3 (Week 3) — Database & Monitoring:**
- [ ] Harden InfluxDB (read-only user, SSL)
- [ ] Configure HA audit logging
- [ ] Test backup/restore procedure

**Phase 4 (Ongoing):**
- [ ] Monthly security reviews
- [ ] Quarterly penetration testing (self-assessment)
- [ ] Stay updated with HA security advisories

---

## Risks & Mitigation

| Risk | Severity | Mitigation |
|------|----------|-----------|
| Lock yourself out of SSH | HIGH | Test thoroughly, keep backup access (Tailscale) |
| Firewall breaks HA access | HIGH | Whitelist Tailscale IPs (100.0.0.0/8) |
| Auto-updates break HA | MEDIUM | Test on non-critical system first |
| Database downtime during SSL setup | MEDIUM | Schedule maintenance window |
| Physical access to console | LOW | Lock enclosure, disable UART |

---

## Next Steps

1. **Review this document** — Understand each recommendation
2. **Prioritize** — Which items are most important to you?
3. **Approve individually** — Say "YES" for each item you want implemented
4. **I'll handle implementation** — No changes without your approval

---

## Questions to Answer

- Do you have SSH key-based auth set up already?
- Are you using Bluetooth or HDMI on this Pi?
- Do you want automatic updates or manual control?
- What's your risk tolerance (paranoid vs. pragmatic)?

---

**Status:** AWAITING YOUR FEEDBACK
