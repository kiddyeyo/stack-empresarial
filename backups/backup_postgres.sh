#!/bin/bash

set +e

# Cargar variables desde el .env
source "$(realpath "$(dirname "$0")/../.env")"

DATE=$(date +%F_%H-%M-%S)
BACKUP_DIR="$(realpath "$(dirname "$0")")/postgres"
CONTAINER=db_odoo

# Asegurar que el directorio existe
mkdir -p "$BACKUP_DIR"

# Realizar el backup
docker exec -e PGPASSWORD=$POSTGRES_PASSWORD $CONTAINER pg_dump -U $POSTGRES_USER -d $POSTGRES_DB > $BACKUP_DIR/odoo_db_$DATE.sql
STATUS=$?

set -e

if [ $STATUS -eq 0 ]; then
    tar -czf "$BACKUP_DIR/odoo_db_$DATE.tar.gz" -C "$BACKUP_DIR" "odoo_db_$DATE.sql"
    rm "$BACKUP_DIR/odoo_db_$DATE.sql"
    find "$BACKUP_DIR" -type f -name "*.tar.gz" -mtime +7 -exec rm {} \;

    curl -H "Content-Type: application/json" \
         -X POST \
         -d "{\"content\": \"✅ Backup PostgreSQL (Odoo) completado exitosamente: $DATE\"}" \
         "$WEBHOOK_URL"
else
    curl -H "Content-Type: application/json" \
         -X POST \
         -d "{\"content\": \"❌ ERROR: Backup PostgreSQL (Odoo) falló a las $DATE\"}" \
         "$WEBHOOK_URL"
fi
