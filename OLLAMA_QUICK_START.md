# Ollama on Pi 5: Quick Start Guide

## TL;DR: What You Need to Know

Your Pi 5 can run **multiple high-quality LLMs locally**:

| Priority | Model | Size | Speed | Best For |
|---|---|---|---|---|
| 🔴 Primary | Qwen 2.5 14B | 3.8 GB | ~18 tok/s | Complex reasoning, coding, analysis |
| 🟡 Secondary | Mistral 7B | 3.0 GB | ~32 tok/s | General chat, balanced |
| 🟢 Fallback | TinyLlama 1.1B | 1.2 GB | ~92 tok/s | Quick answers, emergency fallback |

**Total memory if all 3 loaded:** ~8 GB (fits exactly in your 8 GB Pi 5!)

---

## Quick Commands

### Check Current Status
```bash
# From any machine on your LAN:
curl http://192.168.1.89:11434/api/tags

# Should return JSON with installed models
```

### Add a New Model (Quick)
```bash
# Add TinyLlama (700 MB, fastest)
curl -X POST http://192.168.1.89:11434/api/pull \
  -H "Content-Type: application/json" \
  -d '{"name": "tinyllama"}'

# Add Mistral 7B (if you want a mid-tier option)
curl -X POST http://192.168.1.89:11434/api/pull \
  -H "Content-Type: application/json" \
  -d '{"name": "mistral"}'
```

### Test a Model
```bash
curl -X POST http://192.168.1.89:11434/api/generate \
  -H "Content-Type: application/json" \
  -d '{
    "model": "tinyllama",
    "prompt": "Why is the sky blue?",
    "stream": false
  }' | grep -o '"response":"[^"]*"'
```

---

## One-Time Setup (If Ollama Not Running)

### Install (if needed)
```bash
# Download Ollama for arm64
curl -L https://ollama.ai/download/ollama-linux-arm64.tgz | tar -xzf -

# Make executable
chmod +x ./ollama/bin/ollama

# Create service
sudo ./ollama/bin/ollama serve &
```

### Configure to Run on Startup
```bash
# Create systemd service
sudo tee /etc/systemd/system/ollama.service > /dev/null <<EOF
[Unit]
Description=Ollama AI
After=network.target

[Service]
User=clawbotpi
ExecStart=/path/to/ollama/bin/ollama serve
Restart=always
Environment="OLLAMA_HOST=0.0.0.0:11434"
Environment="OLLAMA_NUM_THREAD=3"

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable ollama
sudo systemctl start ollama
```

---

## Performance Tuning (Optional)

### Reduce CPU Usage (Leave Room for OS)
```bash
# Edit systemd service or startup script:
export OLLAMA_NUM_THREAD=3  # Use 3 of 4 cores
ollama serve
```

### Keep Models in Memory Longer (Faster Switching)
```bash
# Don't unload after 5 min, keep for 10 min
export OLLAMA_KEEP_ALIVE=10m
ollama serve
```

### Monitor Resources
```bash
# Watch CPU/memory while models run
watch -n 1 "free -h && ps aux | grep ollama | grep -v grep"
```

---

## Integration with Your Fallback Chain

Current chain (good):
1. Anthropic Claude Haiku
2. Claude Sonnet
3. Ollama Qwen 2.5 14B ← Already implemented
4. Nvidia Mistral 7B

**Potential improvement:**
1. Claude Haiku (cloud)
2. **Ollama TinyLlama** (instant local fallback)
3. **Ollama Qwen 14B** (if small model fails)
4. Claude Sonnet (if local fails)
5. Nvidia Mistral (final fallback)

This gives you sub-second fallback for simple queries without hitting APIs.

---

## When to Use Each Model

### Qwen 2.5 14B (Currently Running)
Use when:
- ✅ Complex problem-solving needed
- ✅ Code generation/review
- ✅ Multi-step reasoning
- ✅ Detailed explanations
- ❌ Don't use for: "What time is it?" (overkill)

### Mistral 7B (Add if needed)
Use when:
- ✅ Balanced, general chat
- ✅ Faster response needed (32 tok/s vs 18)
- ✅ Lighter reasoning
- ✅ Less hallucination than small models
- ❌ Not as good as 14B for complex tasks

### TinyLlama 1.1B (Recommended to add)
Use when:
- ✅ Quick answer needed (<1 sec)
- ✅ Simple factual questions
- ✅ Summaries, classification
- ✅ Fallback when others busy
- ❌ Not for: Complex reasoning, code

---

## Storage Check
```bash
# Current model storage
ls -lh ~/.ollama/models/blobs/ | tail

# Available space
df -h / | tail -1

# Budget:
# - Qwen 14B: 7.9 GB (existing)
# - TinyLlama: 0.7 GB (add)
# - Mistral: 3.8 GB (optional)
# Total: 12.4 GB / 235 GB available ✅
```

---

## Troubleshooting

### Model won't load ("CUDA out of memory")
- Pi 5 doesn't have CUDA. Check that Ollama is using CPU mode.
- If still failing: Reduce `OLLAMA_NUM_THREAD` to 2

### Slow inference (< 10 tokens/sec)
- Check CPU isn't throttled: `vcgencmd measure_temp`
- Check no other heavy processes: `top`
- Verify model is correct quantization (should be Q4_K_M for 14B)

### Can't reach 192.168.1.89:11434
- Check Pi is online: `ping 192.168.1.89`
- Check Ollama running: `systemctl status ollama`
- Check firewall: `sudo ufw allow 11434`

---

## Next Steps (Recommendation)

1. **Today:** Add TinyLlama (command above, takes ~5 min)
2. **Optional:** Add Mistral if you want variety
3. **Monitor:** Watch performance for 1 week
4. **Tune:** Adjust `OLLAMA_NUM_THREAD` if needed based on thermal/performance

That's it! You now have a fully-capable local LLM setup.

---

**Setup Date:** 2026-02-26
**Pi 5 Status:** Ready for multi-model expansion
**Current Capacity:** 3 models simultaneously (conservative)
