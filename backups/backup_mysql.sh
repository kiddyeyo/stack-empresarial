#!/bin/bash
set -e

# Cargar variables desde el .env
source "$(dirname "$0")/../../.env"

DATE=$(date +%F_%H-%M-%S)
BACKUP_DIR=~/proyectos/backups/mysql
CONTAINER=db_wordpress

# Realizar el backup
docker exec -e MYSQL_PWD=$MYSQL_PASSWORD $CONTAINER mysqldump -u $MYSQL_USER $MYSQL_DATABASE > $BACKUP_DIR/wordpress_db_$DATE.sql

# Verificar resultado
if [ $? -eq 0 ]; then
    tar -czf $BACKUP_DIR/wordpress_db_$DATE.tar.gz -C $BACKUP_DIR wordpress_db_$DATE.sql
    rm $BACKUP_DIR/wordpress_db_$DATE.sql
    find $BACKUP_DIR -type f -name "*.tar.gz" -mtime +7 -exec rm {} \;

    curl -H "Content-Type: application/json" \
         -X POST \
         -d "{\"content\": \"✅ Backup MySQL (WordPress) completado exitosamente: $DATE\"}" \
         $WEBHOOK_URL
else
    curl -H "Content-Type: application/json" \
         -X POST \
         -d "{\"content\": \"❌ ERROR: Backup MySQL (WordPress) falló a las $DATE\"}" \
         $WEBHOOK_URL
fi
