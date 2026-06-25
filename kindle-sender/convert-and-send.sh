#!/bin/bash
set -euo pipefail

FILE="${WATCHEXEC_WRITTEN_PATH:-}"
LOG=/var/log/kindle-sender.log

log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG"; }

if [ -z "$FILE" ] || [ ! -f "$FILE" ]; then
  log "⏭️  Nenhum arquivo detectado"
  exit 0
fi

if ! grep -q '^kindle: true' "$FILE" 2>/dev/null; then
  log "⏭️  Ignorando (sem kindle: true): $(basename "$FILE")"
  exit 0
fi

BASENAME=$(basename "$FILE" .md)
TITLE=$(grep '^title:' "$FILE" | head -1 | sed 's/title: *//' | tr -d '"' || echo "$BASENAME")
TITLE="${TITLE:-$BASENAME}"

log "📖 Processando: $TITLE"

TMP=$(mktemp -d)
EPUB="$TMP/${BASENAME}.epub"

pandoc "$FILE" \
  --output "$EPUB" \
  --from  markdown+yaml_metadata_block \
  --to    epub3 \
  --metadata title="$TITLE" \
  --epub-chapter-level=2 \
  --standalone \
  2>>"$LOG"

if [ ! -f "$EPUB" ]; then
  log "❌ Falha na conversão: $FILE"
  rm -rf "$TMP"
  exit 1
fi

log "✅ EPUB criado: ${BASENAME}.epub ($(du -h "$EPUB" | cut -f1))"

python3 - <<PYTHON
import os, sys, subprocess
from email.mime.multipart import MIMEMultipart
from email.mime.base      import MIMEBase
from email.mime.text      import MIMEText
from email                import encoders

kindle = os.environ.get('KINDLE_EMAIL')
sender = os.environ.get('FROM_EMAIL')
title  = "${TITLE}"
epub   = "${EPUB}"
name   = "${BASENAME}.epub"

msg            = MIMEMultipart()
msg['From']    = sender
msg['To']      = kindle
msg['Subject'] = f"[Kindle] {title}"
msg.attach(MIMEText("Enviado pelo Obsidian Kindle Sender.", 'plain'))

with open(epub, 'rb') as f:
    part = MIMEBase('application', 'epub+zip')
    part.set_payload(f.read())
    encoders.encode_base64(part)
    part.add_header('Content-Disposition', f'attachment; filename="{name}"')
    msg.attach(part)

r = subprocess.run(['msmtp', '-t'], input=msg.as_bytes(), capture_output=True)
if r.returncode != 0:
    print("ERRO msmtp:", r.stderr.decode())
    sys.exit(1)
print("📬 E-mail enviado!")
PYTHON

STATUS=$?
rm -rf "$TMP"

if [ $STATUS -eq 0 ]; then
  log "📬 Enviado para Kindle: $TITLE → ${KINDLE_EMAIL}"
else
  log "❌ Falha no envio: $TITLE"
  exit 1
fi
