#!/bin/bash

WEBHOOK_URL="https://discord.com/api/webhooks/1354553827482927104/gbmxxqFnmHgKOWL2DDCxUm-L1i02J082tVNYF_qG4VroDzP48qCTtkWNBz35HB_Ow9mR"
DATE=$(date +%F_%H-%M-%S)
LOGFILE="/tmp/certbot_renew_$DATE.log"

# Ejecutar renovación y guardar salida en variable
RENEW_OUTPUT=$(docker run --rm \
  -v certbot-etc:/etc/letsencrypt \
  -v certbot-webroot:/var/www/certbot \
  certbot/certbot renew --webroot --webroot-path=/var/www/certbot 2>&1)

echo "$RENEW_OUTPUT" > "$LOGFILE"

# Ver si hubo alguna renovación
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
     $WEBHOOK_URL

# Recargar nginx de todos modos (solo si está corriendo)
docker exec webserver nginx -s reload 2>/dev/null
