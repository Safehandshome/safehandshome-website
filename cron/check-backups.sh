#!/bin/bash
# Health check for backup LLM endpoints
# Alerts via Telegram if either is down

OLLAMA_LOCAL="http://192.168.1.89:11434/api/tags"
NVIDIA_REMOTE="http://100.105.19.99:11434/v1/models"
TIMEOUT=5

check_endpoint() {
  local url=$1
  local name=$2
  
  response=$(curl -s -m $TIMEOUT "$url" 2>&1)
  
  if [ $? -eq 0 ] && echo "$response" | grep -q '"'; then
    return 0  # Up
  else
    return 1  # Down
  fi
}

# Check both endpoints
check_endpoint "$OLLAMA_LOCAL" "Ollama Local"
ollama_status=$?

check_endpoint "$NVIDIA_REMOTE" "Nvidia Remote"
nvidia_status=$?

# Alert if any are down
if [ $ollama_status -ne 0 ]; then
  echo "ALERT: Ollama Local (192.168.1.89) is DOWN"
fi

if [ $nvidia_status -ne 0 ]; then
  echo "ALERT: Nvidia Remote (100.105.19.99) is DOWN"
fi
