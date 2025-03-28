#!/bin/bash
set -e

# Cargar variables desde el .env
source "$(dirname "$0")/../../.env"

DATE=$(date +%F_%H-%M-%S)
BACKUP_DIR=~/proyectos/backups/postgres
CONTAINER=db_odoo

# Realizar el backup
docker exec -e PGPASSWORD=$PG_PASSWORD $CONTAINER pg_dump -U $PG_USER -d $PG_DATABASE > $BACKUP_DIR/odoo_db_$DATE.sql

# Verificar resultado
if [ $? -eq 0 ]; then
    tar -czf $BACKUP_DIR/odoo_db_$DATE.tar.gz -C $BACKUP_DIR odoo_db_$DATE.sql
    rm $BACKUP_DIR/odoo_db_$DATE.sql
    find $BACKUP_DIR -type f -name "*.tar.gz" -mtime +7 -exec rm {} \;

    curl -H "Content-Type: application/json" \
         -X POST \
         -d "{\"content\": \"✅ Backup PostgreSQL (Odoo) completado exitosamente: $DATE\"}" \
         $WEBHOOK_URL
else
    curl -H "Content-Type: application/json" \
         -X POST \
         -d "{\"content\": \"❌ ERROR: Backup PostgreSQL (Odoo) falló a las $DATE\"}" \
         $WEBHOOK_URL
fi
