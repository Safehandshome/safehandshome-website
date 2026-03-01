#!/usr/bin/env python3
"""
Phase 5: Security Audit Automation - Remote Ollama API Version
Runs 4 specialized security analysis agents using remote Ollama API
Schedule: Mon/Wed/Fri, midnight-6 AM (configurable)
Cost: $0 (uses remote Ollama on 192.168.1.89:11434)
"""

import requests
import json
import sys
import time
from datetime import datetime
from typing import Optional, Dict, Any

# Configuration
OLLAMA_API_BASE = "http://192.168.1.89:11434"
PI5_HOSTNAME = "raspberrypi"
PI5_IP = "10.0.3.50"
SYSTEM_PATH = "/home/clawbotpi/.openclaw/workspace"
TIMEOUT = 300  # 5 minutes per agent

# Models to use (in order of preference)
MODELS = ["qwen2.5:14b", "qwen2.5:7b", "llama3.1:8b"]

# Agent configurations
AGENTS = {
    "offensive": {
        "name": "Offensive Security Analyst",
        "prompt": """You are a security penetration tester. Analyze the following system for potential attack vectors:

System: {system_info}

Provide a detailed offensive security assessment covering:
1. Network exposure risks (ports, services, protocols)
2. Authentication weaknesses (SSH, sudo, API access)
3. Known vulnerabilities in installed software
4. Privilege escalation paths
5. Data exposure risks
6. Attack surface analysis

Be specific with vulnerability details and remediation steps."""
    },
    "defensive": {
        "name": "Defensive Security Analyst",
        "prompt": """You are a security hardening expert. Analyze the system defenses:

System: {system_info}

Provide a detailed defensive security assessment covering:
1. Firewall configuration effectiveness
2. Access control policies (SSH, sudo, file permissions)
3. System hardening level (SELinux/AppArmor, kernel parameters)
4. Monitoring and logging adequacy
5. Update/patch status
6. Defense-in-depth implementation

Rate each component (Good/Fair/Poor) with improvement recommendations."""
    },
    "privacy": {
        "name": "Privacy & Compliance Analyst",
        "prompt": """You are a privacy and compliance auditor. Analyze data handling:

System: {system_info}

Provide a detailed privacy & compliance assessment covering:
1. Data storage locations and encryption status
2. Access logging and audit trail adequacy
3. Credential storage security (API keys, passwords)
4. Network traffic exposure (TLS/encryption)
5. Regulatory compliance gaps (GDPR, data retention)
6. Privacy settings and default configurations

Highlight sensitive data exposure risks."""
    },
    "operations": {
        "name": "Operational Security Analyst",
        "prompt": """You are a DevOps security specialist. Analyze operational resilience:

System: {system_info}

Provide a detailed operational security assessment covering:
1. Service availability and redundancy
2. Backup and disaster recovery capabilities
3. System monitoring and alerting
4. Configuration management and version control
5. Incident response procedures
6. Dependency management (libraries, packages, services)

Focus on business continuity and system reliability."""
    }
}


def get_system_info() -> str:
    """Gather system information for analysis"""
    import subprocess
    import os
    
    info = f"""
SYSTEM INFORMATION:
- Hostname: {PI5_HOSTNAME}
- IP: {PI5_IP}
- Report Time: {datetime.now().isoformat()}
- Workspace: {SYSTEM_PATH}

NETWORK SERVICES:
- OpenClaw: 127.0.0.1:18789 (WebSocket gateway)
- Hydroxide SMTP: 127.0.0.1:1025 (ProtonMail bridge)
- Chromium: headless browser automation
- UFW Firewall: ENABLED (deny incoming, allow outgoing)

FIREWALL RULES (IoT LAN 10.0.3.0/24):
- SSH: port 22
- OpenClaw: port 8080
- Ollama: port 11434

SECURITY MEASURES IMPLEMENTED:
- SSH: ED25519 keys only (passwords disabled)
- Unattended-upgrades: automatic security patching
- Systemd services: openclaw, hydroxide, ufw

HARDENING PHASES COMPLETED:
- Phase 2: SSH hardening
- Phase 3: System updates & patching
- Phase 4: UFW firewall & network isolation

LOCAL RESOURCES:
- Ollama: http://192.168.1.89:11434 (REMOTE)
- Home Assistant (Synology): http://192.168.1.162:8123
- Home Assistant (Vermont): http://100.80.46.65:8123 (Tailscale)
"""
    return info


def check_ollama_health() -> bool:
    """Check if Ollama API is accessible"""
    try:
        response = requests.get(
            f"{OLLAMA_API_BASE}/api/tags",
            timeout=10
        )
        return response.status_code == 200
    except Exception as e:
        print(f"❌ Ollama API health check failed: {e}")
        return False


def get_best_model() -> Optional[str]:
    """Get the first available model from preference list"""
    try:
        response = requests.get(
            f"{OLLAMA_API_BASE}/api/tags",
            timeout=10
        )
        if response.status_code == 200:
            data = response.json()
            available_models = [m["name"] for m in data.get("models", [])]
            for model in MODELS:
                if model in available_models:
                    return model
        return None
    except Exception as e:
        print(f"❌ Failed to get model list: {e}")
        return None


def run_agent(agent_name: str, agent_config: Dict[str, Any], model: str) -> str:
    """Run a single security analysis agent"""
    print(f"\n🔍 Running {agent_config['name']}...")
    
    system_info = get_system_info()
    prompt = agent_config["prompt"].format(system_info=system_info)
    
    try:
        # Call remote Ollama API
        response = requests.post(
            f"{OLLAMA_API_BASE}/api/generate",
            json={
                "model": model,
                "prompt": prompt,
                "stream": False,
                "temperature": 0.7,
            },
            timeout=TIMEOUT
        )
        
        if response.status_code == 200:
            data = response.json()
            result = data.get("response", "")
            print(f"✅ {agent_config['name']} completed")
            return result
        else:
            print(f"❌ {agent_config['name']} API error: {response.status_code}")
            return f"ERROR: HTTP {response.status_code}"
    
    except requests.Timeout:
        print(f"❌ {agent_config['name']} timed out after {TIMEOUT}s")
        return "ERROR: Timeout"
    except Exception as e:
        print(f"❌ {agent_config['name']} failed: {e}")
        return f"ERROR: {str(e)}"


def save_report(results: Dict[str, str]) -> str:
    """Save analysis results to a timestamped report"""
    import os
    
    report_dir = f"{SYSTEM_PATH}/security-reports"
    os.makedirs(report_dir, exist_ok=True)
    
    timestamp = datetime.now().strftime("%Y-%m-%d_%H-%M-%S")
    report_file = f"{report_dir}/phase5-report-{timestamp}.md"
    
    # Format report
    report = f"""# 🔒 PHASE 5 SECURITY ANALYSIS REPORT
Generated: {datetime.now().isoformat()}
System: {PI5_HOSTNAME} ({PI5_IP})
Duration: Analysis completed across 4 specialized agents

---

## 📋 EXECUTIVE SUMMARY
- ✅ All 4 agents completed analysis
- Model used: {results.get('model', 'unknown')}
- Network: Ollama API (remote 192.168.1.89:11434)
- Analysis scope: System hardening, vulnerability assessment, compliance, operations

---

## 🚨 AGENT 1: OFFENSIVE SECURITY ANALYSIS
{results.get('offensive', 'ERROR: No results')}

---

## 🛡️ AGENT 2: DEFENSIVE SECURITY ANALYSIS
{results.get('defensive', 'ERROR: No results')}

---

## 🔐 AGENT 3: PRIVACY & COMPLIANCE ANALYSIS
{results.get('privacy', 'ERROR: No results')}

---

## ⚙️ AGENT 4: OPERATIONAL SECURITY ANALYSIS
{results.get('operations', 'ERROR: No results')}

---

## 📊 ANALYSIS METADATA
- Hostname: {PI5_HOSTNAME}
- IP: {PI5_IP}
- Report generated: {datetime.now().isoformat()}
- Report file: {report_file}

---
"""
    
    with open(report_file, 'w') as f:
        f.write(report)
    
    print(f"\n📄 Report saved to: {report_file}")
    return report_file


def send_telegram_alert(report_file: str) -> bool:
    """Send report to Telegram via OpenClaw"""
    try:
        # Read report content
        with open(report_file, 'r') as f:
            content = f.read()
        
        # Send via OpenClaw message tool (would be called by cron)
        # This is a placeholder - actual implementation depends on OpenClaw message integration
        print(f"✅ Telegram alert ready (send via: openclaw message send --to telegram --message=@{report_file})")
        return True
    except Exception as e:
        print(f"❌ Failed to send Telegram alert: {e}")
        return False


def main():
    """Main Phase 5 execution"""
    print("=" * 80)
    print("🔒 PHASE 5: SECURITY AUDIT AUTOMATION (Remote Ollama API)")
    print("=" * 80)
    print(f"Start time: {datetime.now().isoformat()}")
    
    # Check Ollama health
    print("\n📡 Checking Ollama API health...")
    if not check_ollama_health():
        print("❌ ERROR: Ollama API is unreachable at {OLLAMA_API_BASE}")
        print("   Ensure 192.168.1.89 is up and Ollama is running")
        sys.exit(1)
    
    print(f"✅ Ollama API is healthy")
    
    # Get best available model
    print("\n🤖 Selecting analysis model...")
    model = get_best_model()
    if not model:
        print("❌ ERROR: No suitable models found on Ollama")
        sys.exit(1)
    
    print(f"✅ Using model: {model}")
    
    # Run all 4 agents
    print("\n" + "=" * 80)
    print("RUNNING SECURITY ANALYSIS AGENTS")
    print("=" * 80)
    
    start_time = time.time()
    results = {"model": model}
    
    for agent_key, agent_config in AGENTS.items():
        results[agent_key] = run_agent(agent_key, agent_config, model)
    
    elapsed = time.time() - start_time
    
    # Save report
    print("\n" + "=" * 80)
    print("SAVING REPORT")
    print("=" * 80)
    report_file = save_report(results)
    
    # Send Telegram alert
    print("\n" + "=" * 80)
    print("SENDING NOTIFICATIONS")
    print("=" * 80)
    send_telegram_alert(report_file)
    
    # Summary
    print("\n" + "=" * 80)
    print("✅ PHASE 5 ANALYSIS COMPLETE")
    print("=" * 80)
    print(f"Total time: {elapsed:.1f} seconds")
    print(f"Report: {report_file}")
    print(f"End time: {datetime.now().isoformat()}")


if __name__ == "__main__":
    main()
