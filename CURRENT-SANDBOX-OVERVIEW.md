# Current Sandbox Configuration - OpenClaw Pi 5

**Generated:** 2026-02-27
**System:** Raspberry Pi 5 (8GB RAM, 256GB NVMe)
**OS:** Debian GNU/Linux 12 (bookworm), Kernel 6.12.62+rpt-rpi-2712

---

## User & Process Information

### Running User
- **User:** `clawbotpi` (UID 1000)
- **Groups:** 
  - Primary: `clawbotpi` (GID 1000)
  - Secondary: `adm`, `dialout`, `cdrom`, `sudo`, `audio`, `video`, `plugdev`, `games`, `users`, `input`, `render`, `netdev`, `lpadmin`, `docker`, `gpio`, `i2c`, `spi`

**Security Note:** User is in `sudo` group (can escalate to root) and `docker` group (can run containers).

### Active OpenClaw Processes
```
openclaw (PID 212734)         - Main agent process
openclaw-gateway (PID 212741) - Gateway daemon
```

---

## Systemd Sandbox Configuration

### Current Status
**No dedicated systemd service found** — OpenClaw runs as a user process, not as a managed systemd service.

### Capabilities (CapabilityBoundingSet)
OpenClaw inherits **all standard Linux capabilities** (no restrictions):
```
cap_chown, cap_dac_override, cap_dac_read_search, cap_fowner, cap_fsetid, 
cap_kill, cap_setgid, cap_setuid, cap_setpcap, cap_net_bind_service, 
cap_net_broadcast, cap_net_admin, cap_net_raw, cap_sys_admin, cap_sys_module, 
cap_sys_rawio, cap_sys_ptrace, cap_sys_time, cap_mknod, cap_audit_write, etc.
```

**Implication:** No capability restrictions. OpenClaw can theoretically access kernel interfaces.

### Systemd Sandbox Features
- ❌ `ProtectSystem=` — NOT enabled (can write to entire filesystem)
- ❌ `ProtectHome=` — NOT enabled (can read/write home directory)
- ❌ `PrivateTmp=` — NOT enabled (uses shared /tmp)
- ❌ `PrivateNetwork=` — NOT enabled (can access all network interfaces)
- ❌ `PrivateDevices=` — NOT enabled (can access all /dev/ devices)
- ❌ `NoNewPrivileges=` — NOT enabled (can gain new privileges)
- ❌ `RestrictRealtime=` — NOT enabled
- ❌ `RestrictNamespaces=` — NOT enabled
- ❌ `MemoryDenyWriteExecute=` — NOT enabled
- ❌ `LockPersonality=` — NOT enabled

**Summary:** Zero systemd sandbox constraints. This is typical for user processes but not ideal for security-sensitive applications.

---

## Docker Sandbox Configuration

### Docker Group Membership
User `clawbotpi` is in the `docker` group, which means:
- **Can run Docker containers** without `sudo`
- **Can access the Docker daemon**
- **Can mount volumes** from the host
- **Effectively has root access** (Docker socket = root escalation)

⚠️ **Security Risk:** Being in the `docker` group is equivalent to having root access.

---

## Firewall Configuration

### Current State
**UFW is NOT enabled** — No firewall rules in place.

### Open Ports
The system is listening on:

| Port | Interface | Process | Accessibility |
|------|-----------|---------|----------------|
| **18789** (tcp/ipv4) | 127.0.0.1 | openclaw-gateway | Localhost only (GOOD) |
| **18791** (tcp/ipv4) | 127.0.0.1 | openclaw-gateway | Localhost only (GOOD) |
| **18792** (tcp/ipv4) | 127.0.0.1 | openclaw-gateway | Localhost only (GOOD) |
| **22** (SSH) | 0.0.0.0 | sshd | **All interfaces (RISK)** |
| **631** (CUPS) | 127.0.0.1 | cups | Localhost only (printer service) |
| **8080** | 0.0.0.0 | Unknown | All interfaces (likely Maple?) |
| **36710** (Tailscale) | 100.102.5.7 | - | Tailscale VPN only |

**Critical Findings:**
- ✅ OpenClaw Gateway ports bound to **localhost only** (127.0.0.1) — cannot be accessed from network
- ❌ SSH (port 22) accessible from **all interfaces** (0.0.0.0)
- ❌ Port 8080 accessible from **all interfaces** (0.0.0.0)
- ✅ Tailscale traffic isolated to VPN network (100.x.x.x range)

---

## External Services Accessibility

### Services OpenClaw Can Reach

**On Home Network (192.168.x.x):**
- ✅ Synology NAS (192.168.1.162) — Home Assistant
- ✅ Ollama LLM (192.168.1.89:11434) — Local inference
- ✅ PiHole DNS (192.168.1.x) — DNS filtering
- ✅ Home network devices (lights, switches, sensors)

**Via Tailscale VPN (100.x.x.x):**
- ✅ Vermont Home Assistant (100.80.46.65:8123) — Remote HA
- ✅ Nvidia Remote LLM (100.105.19.99:11434) — Remote inference
- ✅ Other Tailscale peers on network

**External (Internet):**
- ✅ Anthropic API (api.anthropic.com) — Claude LLM
- ✅ Brave Search API (api.search.brave.com) — Web search
- ✅ Open-Meteo (api.open-meteo.com) — Weather data
- ✅ GitHub (github.com) — Code/docs access
- ✅ Standard DNS/HTTP/HTTPS ports (53, 80, 443)

**Blocked/Restricted:**
- ❌ wttr.in — Likely blocked by PiHole
- ✅ Everything else on standard ports (depends on router rules)

---

## Attack Surface Summary

### High Risk Areas
1. **SSH (port 22) open to all interfaces**
   - No key-based auth enforcement documented
   - Vulnerable to brute-force attacks

2. **No firewall (UFW)**
   - Any machine on home LAN or WAN can probe open ports
   - No rate limiting or DDoS protection

3. **Port 8080 accessible from all interfaces**
   - Unknown service — needs investigation
   - Could be Maple proxy or other service

4. **Docker group membership**
   - User `clawbotpi` effectively has root access
   - Can escape to host via Docker

5. **No systemd sandboxing**
   - OpenClaw can access entire filesystem
   - Can read/write to kernel interfaces

### Medium Risk Areas
1. **Ollama on LAN without authentication**
   - Any home device can use it
   - Could be abused for inference spam

2. **No LUKS encryption**
   - Physical access = full system access
   - NVMe can be cloned/read

3. **Capabilities not restricted**
   - OpenClaw can theoretically use CAP_SYS_ADMIN, CAP_NET_ADMIN, etc.

### Low Risk Areas
1. **OpenClaw Gateway ports bound to localhost**
   - Cannot be accessed remotely
   - Good isolation

2. **Tailscale VPN for remote access**
   - End-to-end encrypted
   - Better than direct internet exposure

---

## Recommendations for Hardening

**Immediate (High Priority):**
1. Enable UFW firewall, restrict SSH to home LAN only
2. Enforce SSH key-based auth, disable password login
3. Investigate port 8080 — disable if unused
4. Add authentication to Ollama (API key)

**Medium Priority:**
5. Enable systemd sandboxing (ProtectSystem, ProtectHome, etc.)
6. Restrict Docker group membership if not needed
7. Implement capability dropping (CapabilityBoundingSet)
8. Enable automatic security updates

**Long-term:**
9. Consider full-disk LUKS encryption (performance trade-off)
10. Implement intrusion detection (fail2ban, tripwire)
11. Set up centralized logging

---

## Files Containing Sensitive Data

⚠️ **These files have credentials or API keys:**
- `~/.openclaw/openclaw.json` — API keys, Gateway token
- `~/.openclaw/workspace/MEMORY.md` — Personal context (less sensitive)
- `~/.ssh/` — SSH private keys
- `~/.bashrc`, `~/.profile` — Environment variables (may contain secrets)

**Backup Strategy:** Encrypt and backup these files separately from main system.

---

**Status:** Current sandbox is PERMISSIVE (no restrictions). Ready for hardening recommendations when approved.
