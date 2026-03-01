# Phase 4: Firewall & Network Isolation - Requirements

**Date:** 2026-02-27
**Target:** Local Pi5 (raspberrypi, 192.168.1.x)
**Current UFW Status:** Disabled (ready to configure)

---

## Network Services Currently Running

### Localhost-Only (SAFE - No Firewall Rules Needed)
These are bound to 127.0.0.1 or [::1] — ONLY accessible locally:
- **SSH** (port 22) — key-based auth only (from Phase 2)
- **CUPS printer daemon** (port 631) — local printing only
- **OpenClaw Gateway** (ports 18789, 18791, 18792) — internal IPC only
- **containerd socket** (port 35591) — container runtime only

### Externally Accessible (NEEDS FIREWALL RULES)
- **Docker/Maple Proxy** (port 8080) — listening on 0.0.0.0 and [::]
  - Used for OpenClaw web interface
  - Should be restricted to home network (192.168.1.0/24)

### VPN-Only (Tailscale)
- **tailscaled** (port 36710 UDP on 100.102.5.7)
  - Listens on Tailscale IP address range (100.x.x.x)
  - Should allow only Tailscale VPN traffic (100.0.0.0/8)

---

## External Services We Connect TO (Outbound)

### Home Network (Local LAN - 192.168.1.x)
1. **Synology NAS - Home Assistant**
   - Host: 192.168.1.162
   - Port: 8123 (HTTP)
   - Protocol: TCP
   - Purpose: HA integration, automations, data
   - Frequency: Regular (cron jobs, webhooks)
   - **Action:** ALLOW from local LAN

2. **Ollama LLM Server**
   - Host: 192.168.1.89
   - Port: 11434 (HTTP)
   - Protocol: TCP
   - Purpose: Local inference (fallback, weather, research)
   - Frequency: Regular (cron, on-demand)
   - **Action:** ALLOW from local LAN

3. **PiHole DNS** (optional, if configured)
   - Host: 192.168.1.x
   - Port: 53 (DNS)
   - Protocol: UDP/TCP
   - Purpose: DNS filtering
   - **Action:** ALLOW if using PiHole

### Tailscale VPN (100.x.x.x range)
1. **Vermont Home Assistant**
   - Host: 100.80.46.65
   - Port: 8123 (HTTP)
   - Protocol: TCP
   - Purpose: Remote HA access
   - Frequency: Regular (health checks, weather alerts)
   - **Action:** ALLOW Tailscale (100.0.0.0/8)

2. **Nvidia Remote LLM Server**
   - Host: 100.105.19.99
   - Port: 11434 (HTTP with /v1 API)
   - Protocol: TCP
   - Purpose: Remote inference fallback
   - Frequency: On-demand (weather fallback, research)
   - **Action:** ALLOW Tailscale (100.0.0.0/8)

### Internet (External)
1. **DNS Servers** (system default)
   - Port: 53 (UDP/TCP)
   - Purpose: Name resolution
   - **Action:** ALLOW outbound

2. **NTP (Time Sync)**
   - Port: 123 (UDP)
   - Purpose: System clock sync
   - **Action:** ALLOW outbound (systemd-timesyncd handles)

3. **Anthropic API** (Claude models)
   - HTTPS outbound (port 443)
   - Used by OpenClaw for LLM calls
   - **Action:** ALLOW outbound

4. **Brave Search API** (web searches)
   - HTTPS outbound (port 443)
   - Used for web search queries
   - **Action:** ALLOW outbound

5. **Open-Meteo Weather API** (weather data)
   - HTTPS outbound (port 443)
   - Used for weather cron job
   - **Action:** ALLOW outbound

6. **Other HTTPS services** (Telegram, Slack, etc.)
   - Port: 443
   - Used by message integrations, notifications
   - **Action:** ALLOW outbound

---

## Proposed UFW Rules for Phase 4

### Step 1: Set Default Policies
```bash
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw default deny routed
```

### Step 2: Allow Essential Inbound Traffic

**SSH (local network only)**
```bash
sudo ufw allow from 192.168.1.0/24 to any port 22 comment 'SSH from home LAN'
```

**Docker/OpenClaw Web Interface (local network only)**
```bash
sudo ufw allow from 192.168.1.0/24 to any port 8080 comment 'OpenClaw web from home LAN'
```

**Tailscale VPN (required for remote access)**
```bash
sudo ufw allow from 100.0.0.0/8 to any port 8080 comment 'OpenClaw web from Tailscale'
sudo ufw allow 41641/udp comment 'Tailscale VPN'
```

**Ollama (if others need to query this Pi)**
```bash
sudo ufw allow from 192.168.1.0/24 to any port 11434 comment 'Ollama from home LAN'
```

**DNS (if you want this Pi as DNS server)**
```bash
# Optional - only if needed
# sudo ufw allow from 192.168.1.0/24 to any port 53 comment 'DNS from home LAN'
```

### Step 3: Enable Firewall
```bash
sudo ufw enable
```

### Step 4: Verify Rules
```bash
sudo ufw status verbose
```

---

## Traffic Summary

| Direction | Source | Dest Port | Protocol | Purpose | Action |
|-----------|--------|-----------|----------|---------|--------|
| **INBOUND** | 192.168.1.0/24 | 22 | TCP | SSH access | ALLOW |
| | 192.168.1.0/24 | 8080 | TCP | OpenClaw web | ALLOW |
| | 192.168.1.0/24 | 11434 | TCP | Ollama queries | ALLOW |
| | 100.0.0.0/8 | 8080 | TCP | OpenClaw (Tailscale) | ALLOW |
| | Anywhere | 41641 | UDP | Tailscale VPN | ALLOW |
| | Anywhere | Other | - | - | **DENY** |
| **OUTBOUND** | localhost | * | * | Local apps | ALLOW |
| | 192.168.1.0/24 | 8123 | TCP | Synology HA | ALLOW |
| | 192.168.1.0/24 | 11434 | TCP | Ollama | ALLOW |
| | 100.0.0.0/8 | * | TCP | Tailscale VPN | ALLOW |
| | Anywhere | 443 | TCP | HTTPS (APIs) | ALLOW |
| | Anywhere | 53 | UDP/TCP | DNS | ALLOW |
| | Anywhere | 123 | UDP | NTP | ALLOW |
| | Anywhere | Other | - | - | **DENY** |

---

## Risk Assessment

### Security Gains
✅ Blocks unauthorized inbound traffic
✅ Restricts SSH to home network
✅ Isolates Ollama to trusted hosts
✅ Protects against port scanning from internet
✅ All critical local services still accessible

### Potential Issues to Watch
⚠️ If you add new LAN devices later, may need to add rules
⚠️ If you travel and want to SSH, need to either:
   - Connect via Tailscale VPN first, then SSH
   - Add Tailscale IP range to SSH rule (less restrictive)
⚠️ Docker container-to-host communication should still work (localhost exempt)

---

## Questions Before Implementation

1. **Do you want others on home LAN to access OpenClaw web (port 8080)?**
   - Current rule: Yes (192.168.1.0/24 allowed)

2. **Do you want to SSH from outside home network?**
   - Option A: Connect via Tailscale first (VPN), then SSH
   - Option B: Add Tailscale IP range to SSH rule (less secure)

3. **Should this Pi allow other LAN devices to query Ollama (port 11434)?**
   - Current rule: Yes (192.168.1.0/24 allowed)

4. **Any other services/ports needed?**
   - CUPS printing, Bluetooth, etc.?

---

## Ready for Phase 4?

When you answer the questions above, I'll prepare the exact UFW commands for your approval.
