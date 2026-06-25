#!/bin/bash
set -euo pipefail

LOG=/var/log/kindle-sender.log
mkdir -p /var/log

log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG"; }

log "🚀 Kindle Sender iniciado"
log "📂 Monitorando: /vault/Faculdade/Resumos e /vault/Faculdade/CheatSheets"

watchexec \
  --watch /vault/Faculdade/Resumos \
  --watch /vault/Faculdade/CheatSheets \
  --exts md \
  --debounce 3000 \
  --on-busy-update queue \
  --emit-events-to environment \
  -- bash -c 'env | grep -i watchexec >> /var/log/kindle-sender.log; /usr/local/bin/convert-and-send.sh'
