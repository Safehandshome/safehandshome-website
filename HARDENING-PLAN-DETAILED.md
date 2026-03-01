# Detailed Hardening Plan – Pi5 Clawbot

**No secrets included. Ready for step-by-step implementation.**

---

## Current Security Posture (No Secrets)

### 1. Linux User
**Running as:** `clawbotpi` (UID 1000)
**Groups:** sudo, docker, adm, audio, video, gpio, i2c, spi, plugdev, etc.

### 2. Systemd & Docker Sandbox
**Systemd:** None (user process, no sandboxing)
- ProtectSystem: **OFF**
- ProtectHome: **OFF**
- PrivateTmp: **OFF**
- NoNewPrivileges: **OFF**
- CapabilityBoundingSet: **ALL** (unrestricted)

**Docker:** User in docker group (can run containers as root equivalent)

### 3. Firewall Status
**UFW:** NOT enabled (no rules in place)

### 4. Inbound Ports (Open Now)
| Port | Interface | Service | Risk |
|------|-----------|---------|------|
| 22 | 0.0.0.0 | SSH | ⚠️ HIGH — world-accessible |
| 8080 | 0.0.0.0 | Unknown | ⚠️ HIGH — world-accessible |
| 18789/91/92 | 127.0.0.1 | OpenClaw Gateway | ✅ GOOD — localhost only |
| 631 | 127.0.0.1 | CUPS | ✅ GOOD — localhost only |

### 5. External Services & API Scopes

**Home Network (192.168.x.x):**
- Synology HA (192.168.1.162:8123) — Full read/write token
- Ollama (192.168.1.89:11434) — No auth required
- PiHole DNS (192.168.1.x) — DNS queries
- Smart home devices — Control via HA

**Tailscale VPN (100.x.x.x):**
- Vermont HA (100.80.46.65:8123) — Full read/write token
- Nvidia LLM (100.105.19.99:11434) — HTTP API
- Tailscale DNS — Encrypted DNS

**Internet (External APIs):**
- api.anthropic.com:443 — Claude LLM (inference only)
- api.search.brave.com:443 — Web search (rate-limited)
- api.open-meteo.com:443 — Weather data (no auth)
- github.com:443 — Public docs/code

**Blocked:**
- wttr.in — Filtered by PiHole

---

## Step-by-Step Hardening Plan

### STEP 1: Close SSH to Localhost Only

**Why needed:**
SSH on port 22 is world-accessible and the #1 target for brute-force attacks. Restricting it to localhost (127.0.0.1) means only local access is allowed. For remote access, Tailscale VPN is safer.

**Commands to run:**
```bash
# Edit SSH config
sudo nano /etc/ssh/sshd_config

# Find this line:
# #ListenAddress 0.0.0.0

# Change it to:
ListenAddress 127.0.0.1
ListenAddress ::1

# Save (Ctrl+O, Enter, Ctrl+X)

# Test syntax (IMPORTANT - don't lock yourself out!)
sudo sshd -t

# If OK, restart SSH
sudo systemctl restart sshd

# Verify it's listening only on localhost
sudo ss -tulpn | grep ssh
# Should show: 127.0.0.1:22 and [::1]:22 only
```

**Questions for you:**
- [ ] Do you need SSH access from outside your home network? (If yes, use Tailscale + port forward instead)
- [ ] Have you tested SSH key-based auth already? (Recommended before locking down)
- [ ] Do you have a backup way to access the Pi if something breaks?

---

### STEP 2: Enable UFW with Minimal Allow List

**Why needed:**
UFW (Uncomplicated Firewall) blocks all inbound traffic by default and restricts outbound to only what you need. This prevents random attacks and reduces attack surface.

**Outbound rules you need:**
- DNS (port 53) — For PiHole and Tailscale
- HTTPS (port 443) — For APIs (Anthropic, Brave, Open-Meteo)
- HTTP (port 80) — For Open-Meteo (if used)
- Home LAN (192.168.1.0/24) — For Synology HA, Ollama, smart devices
- Tailscale (41641/udp) — For VPN
- Tailscale interface (100.x.x.x) — For Vermont HA, Nvidia LLM

**Commands to run:**
```bash
# Reset UFW to defaults (if previously configured)
sudo ufw reset

# Set default policies: deny inbound, allow outbound
sudo ufw default deny incoming
sudo ufw default allow outgoing

# Allow SSH from localhost only
sudo ufw allow from 127.0.0.1 to any port 22 comment 'SSH from localhost'
sudo ufw allow from ::1 to any port 22 comment 'SSH from localhost IPv6'

# Allow DNS (required for all internet access)
sudo ufw allow out to any port 53 comment 'DNS outbound'

# Allow HTTPS (APIs + HA + VPN)
sudo ufw allow out to any port 443 comment 'HTTPS outbound'

# Allow HTTP (Open-Meteo, etc.)
sudo ufw allow out to any port 80 comment 'HTTP outbound'

# Allow home LAN traffic (both directions)
sudo ufw allow from 192.168.1.0/24 comment 'Home LAN inbound'
sudo ufw allow to 192.168.1.0/24 comment 'Home LAN outbound'

# Allow Tailscale VPN
sudo ufw allow 41641/udp comment 'Tailscale VPN'

# Allow Tailscale network (100.x.x.x)
sudo ufw allow from 100.0.0.0/8 comment 'Tailscale peers inbound'
sudo ufw allow to 100.0.0.0/8 comment 'Tailscale peers outbound'

# Enable firewall (last!)
sudo ufw enable

# Check rules
sudo ufw status verbose
```

**Questions for you:**
- [ ] Do you need HTTP (port 80) or just HTTPS?
- [ ] Are there other services on home LAN you need to reach (Plex, NAS, etc.)?
- [ ] Do you need ICMP (ping)? (Optional: `sudo ufw allow out to any protocol icmp`)

---

### STEP 3: Remove clawbotpi from Docker Group

**Why needed:**
Being in the docker group gives `clawbotpi` root-equivalent access. If OpenClaw is compromised, an attacker can escape to root via Docker. This removes that escalation path.

**Note:** You can still run Docker with `sudo docker` if needed.

**Commands to run:**
```bash
# Remove docker group membership
sudo delgroup clawbotpi docker

# Verify it's removed
id clawbotpi
# Should NOT show "docker" in groups

# Test: try to run docker without sudo (should fail)
docker ps
# Error: "permission denied" — this is correct!

# If you need docker access later, use sudo:
sudo docker ps
```

**Questions for you:**
- [ ] Do you currently use Docker? (If no, this is safe)
- [ ] Would you rather use `sudo docker` instead?
- [ ] Are there Docker containers you need to manage regularly?

---

### STEP 4: Bind Ollama to Localhost (or Add Basic Auth)

**Why needed:**
Ollama on port 11434 is accessible from entire home LAN without authentication. Anyone on your WiFi (guest network, neighbors with weak router) could use it and burn resources or tokens. Binding to localhost (127.0.0.1) requires local access or SSH tunnel.

**Option A: Bind to Localhost Only (Recommended)**

```bash
# Stop Ollama if running
pkill -f ollama

# Edit Ollama startup (if using systemd)
sudo nano /etc/systemd/system/ollama.service
# OR if Docker: edit docker-compose.yml

# For systemd service, add to [Service] section:
# Environment="OLLAMA_HOST=127.0.0.1:11434"

# For Docker:
# ports:
#   - "127.0.0.1:11434:11434"

# Reload and restart
sudo systemctl daemon-reload
sudo systemctl restart ollama

# Verify listening on localhost only
sudo ss -tulpn | grep 11434
# Should show: 127.0.0.1:11434 only
```

**Option B: Add Basic Auth (If Localhost Binding Doesn't Work)**

```bash
# Install htpasswd
sudo apt-get install apache2-utils

# Create password file
sudo htpasswd -c /etc/ollama/.htpasswd ollama-user
# Enter password when prompted

# Configure Ollama with basic auth (depends on how it's running)
# For Docker compose, add nginx reverse proxy with auth
# This is more complex — use Option A if possible
```

**Questions for you:**
- [ ] Do other home devices need access to Ollama? (If no, use Option A)
- [ ] Are you running Ollama as systemd service or Docker?
- [ ] Is 127.0.0.1:11434 accessible via SSH tunnel acceptable?

---

### STEP 5: Add Systemd Sandbox Directives

**Why needed:**
Without sandboxing, OpenClaw can:
- Read/write entire filesystem (including /etc, /root, /sys)
- Access all kernel capabilities
- Gain new privileges
- Access all devices (/dev)

Systemd sandbox directives restrict these capabilities.

**Note:** This requires running OpenClaw via systemd service (not just `openclaw` command). I'll show both.

**Commands to run:**

**Option A: Create systemd Service for OpenClaw**

```bash
# Create service file
sudo nano /etc/systemd/system/openclaw.service

# Paste this content:
[Unit]
Description=OpenClaw Agent
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
User=clawbotpi
WorkingDirectory=/home/clawbotpi/.openclaw/workspace
ExecStart=/usr/local/bin/openclaw

# Sandbox directives
ProtectSystem=full
ProtectHome=yes
NoNewPrivileges=true
PrivateTmp=yes
PrivateDevices=yes
RestrictRealtime=yes
RestrictNamespaces=yes
LockPersonality=yes
MemoryDenyWriteExecute=yes
RestrictSUIDSGID=yes

# Capability dropping
CapabilityBoundingSet=CAP_NET_BIND_SERVICE CAP_NET_RAW
AmbientCapabilities=CAP_NET_BIND_SERVICE

# Restart policy
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target

# Save (Ctrl+O, Enter, Ctrl+X)

# Enable and start
sudo systemctl daemon-reload
sudo systemctl enable openclaw.service
sudo systemctl start openclaw.service

# Check status
sudo systemctl status openclaw.service

# View logs
sudo journalctl -u openclaw -f
```

**Option B: If Running as User Process (Keep Current Setup)**

Add sandboxing via bubblewrap (lightweight container):

```bash
# Install bubblewrap
sudo apt-get install bubblewrap

# Create wrapper script
sudo nano /usr/local/bin/openclaw-sandboxed

# Paste:
#!/bin/bash
exec bwrap \
  --ro-bind / / \
  --tmpfs /tmp \
  --tmpfs /run \
  --bind /home/clawbotpi /home/clawbotpi \
  --setenv PATH "$PATH" \
  --setenv HOME "$HOME" \
  /usr/local/bin/openclaw "$@"

# Make executable
sudo chmod +x /usr/local/bin/openclaw-sandboxed

# Use it: openclaw-sandboxed instead of openclaw
```

**Questions for you:**
- [ ] Are you running OpenClaw as a systemd service or user command?
- [ ] Do you need write access to /home/clawbotpi/? (Yes, for workspace)
- [ ] Are there other directories you need to access?
- [ ] Can OpenClaw restart automatically on crash? (systemd enables this)

---

## Implementation Checklist

Complete in this order:

**Phase 1 (Safest First):**
- [ ] Step 1: Close SSH to localhost
- [ ] Step 4: Bind Ollama to localhost

**Phase 2 (Medium Risk):**
- [ ] Step 2: Enable UFW firewall
- [ ] Step 3: Remove docker group

**Phase 3 (High Impact):**
- [ ] Step 5: Add systemd sandbox

---

## Rollback Plan (If Anything Breaks)

```bash
# Restore SSH to all interfaces
sudo nano /etc/ssh/sshd_config
# Change back: ListenAddress 0.0.0.0
sudo systemctl restart sshd

# Disable UFW
sudo ufw disable

# Restore docker group
sudo usermod -aG docker clawbotpi

# Restore Ollama to 0.0.0.0
# (reverse the binding change)
```

---

## Next: Which Step Should We Start With?

Please tell me:
1. Which step would you like to tackle first?
2. For that step, answer the "Questions for you" section
3. I'll guide you through it and verify it worked

**Recommended order:** Step 1 → Step 4 → Step 2 → Step 3 → Step 5

Ready when you are!
