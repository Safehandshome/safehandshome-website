# Security Summary – Pi5 Clawbot

**No tokens, passwords, or private keys included.**

---

## 1. User & Process

**Running as:** `clawbotpi` (UID 1000, GID 1000)

**Group memberships:**
- `sudo` — Can escalate to root ⚠️
- `docker` — Can run containers (= root access) ⚠️
- `adm`, `audio`, `video`, `gpio`, `i2c`, `spi` — Hardware access

**Active processes:**
- `openclaw` (agent)
- `openclaw-gateway` (gateway daemon on 127.0.0.1:18789, 18791, 18792)

---

## 2. Sandbox Configuration

### Systemd
❌ **Currently:** No systemd service (user process, no restrictions)
- ProtectSystem: **OFF**
- ProtectHome: **OFF**
- PrivateTmp: **OFF**
- PrivateNetwork: **OFF**
- NoNewPrivileges: **OFF**
- CapabilityBoundingSet: **ALL capabilities** (unrestricted)

### Docker
✅ User `clawbotpi` in `docker` group — can run containers without sudo
⚠️ **Risk:** Docker socket = root access equivalent

---

## 3. Firewall & Network Access

### Current State
**UFW:** NOT enabled (no rules)

### Open Ports (What Can Accept Inbound)
| Port | Interface | Service | Current Access |
|------|-----------|---------|-----------------|
| 22 | 0.0.0.0 (ALL) | SSH | ⚠️ World-accessible |
| 8080 | 0.0.0.0 (ALL) | Unknown | ⚠️ World-accessible |
| 18789/18791/18792 | 127.0.0.1 | OpenClaw Gateway | ✅ Localhost only |
| 631 | 127.0.0.1 | CUPS | ✅ Localhost only |

### Outbound Traffic (What I Can Reach)
**Currently:** All outbound allowed (no restrictions)

**Destinations I Actually Use:**

**Home Network (192.168.x.x):**
- 192.168.1.162:8123 → Synology Home Assistant
- 192.168.1.89:11434 → Ollama (local LLM)
- 192.168.1.x → PiHole DNS
- 192.168.1.x → Home network devices (lights, switches, sensors)

**Tailscale VPN (100.x.x.x):**
- 100.80.46.65:8123 → Vermont Home Assistant
- 100.105.19.99:11434 → Nvidia remote LLM
- Tailscale DNS

**Internet (External APIs):**
- api.anthropic.com:443 → Claude LLM (HTTPS)
- api.search.brave.com:443 → Brave Search (HTTPS)
- api.open-meteo.com:443 → Weather data (HTTPS)
- github.com:443 → Docs/code (HTTPS)
- Standard DNS (port 53)

**Blocked/Filtered:**
- wttr.in → Blocked by PiHole

---

## 4. External Services & API Scopes

### Home Assistant (Synology & Vermont)
**Access:** Full read/write via long-lived tokens
- Can query entity states
- Can trigger automations
- Can control devices
- Can read/write history

**Scope:** Broad (equivalent to owner access)

### Ollama (Local & Remote)
**Access:** HTTP API, no authentication
- Can run inference
- Can pull/push models
- Local: unlimited (on LAN)
- Remote: via Tailscale only

**Scope:** Broad (no restrictions)

### InfluxDB (Vermont HA)
**Access:** Database credentials (humphy user)
- Can write time-series data
- Can query historical data
- Database: homeassistant

**Scope:** Read/write on one database

### Anthropic Claude API
**Access:** API key from `openclaw.json`
- Claude Haiku (primary)
- Claude Sonnet (fallback)
- Token-based billing

**Scope:** Inference only (cannot manage billing, API keys, or org)

### Brave Search API
**Access:** API key from `openclaw.json`
- Web search queries
- Max 5 searches per batch

**Scope:** Search only (limited rate)

### Synology Backup System
**Access:** File monitoring via cron job
- Health checks on Ollama
- Health checks on Nvidia remote
- Alerts via Telegram

**Scope:** Read-only status checks

---

## Summary: Current Attack Surface

**Highest Risk:**
1. SSH (port 22) open to world
2. Port 8080 open to world (purpose unclear)
3. No firewall rules
4. Docker group = root access
5. No systemd sandboxing

**Medium Risk:**
1. Ollama accessible from LAN without auth
2. No capability dropping
3. Full filesystem access

**Lower Risk:**
1. OpenClaw Gateway bound to localhost ✅
2. Tailscale for remote access ✅
3. Running as non-root user ✅

---

## Ready for Hardening

Next steps when approved:
1. ✅ SSH → localhost only (127.0.0.1:22)
2. ✅ Enable UFW with minimal outbound rules
3. ✅ Remove docker group membership
4. ✅ Bind Ollama to 127.0.0.1 or add API key auth
5. ✅ Add systemd sandbox (ProtectSystem, NoNewPrivileges, CapabilityBoundingSet)

**No secrets in this document. Ready to implement when you approve each item.**
