#!/bin/bash
set +e

source "$(realpath "$(dirname "$0")/.env")"
DATE=$(date +%F_%H-%M-%S)
LOGFILE="/tmp/certbot_renew_$DATE.log"

# Ejecutar renovación de certificados
RENEW_OUTPUT=$(docker run --rm \
  -v certbot-etc:/etc/letsencrypt \
  -v certbot-webroot:/var/www/certbot \
  certbot/certbot renew --webroot --webroot-path=/var/www/certbot 2>&1)

echo "$RENEW_OUTPUT" > "$LOGFILE"

# Evaluar resultado
if echo "$RENEW_OUTPUT" | grep -q "Congratulations"; then
    MSG="✅ Certbot renovó uno o más certificados exitosamente el $DATE"
elif echo "$RENEW_OUTPUT" | grep -q "No renewals were attempted"; then
    MSG="ℹ️ Certbot ejecutado el $DATE - No había certificados por renovar."
else
    MSG="❌ ERROR: Certbot encontró un problema al ejecutar la renovación el $DATE"
fi

# Enviar notificación a Discord
curl -H "Content-Type: application/json" \
     -X POST \
     -d "{\"content\": \"$MSG\"}" \
     "$WEBHOOK_URL"

# Intentar recargar nginx si existe el contenedor
if docker ps --format '{{.Names}}' | grep -q '^webserver$'; then
    docker exec webserver nginx -s reload 2>/dev/null
fi

set -e
