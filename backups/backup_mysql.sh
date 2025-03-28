#!/bin/bash

DATE=$(date +%F_%H-%M-%S)
BACKUP_DIR=~/proyectos/backups/mysql
CONTAINER=db_wordpress
DB=wordpress
USER=erickcastillo
PASSWORD=Papayaxd2312
WEBHOOK_URL="https://discord.com/api/webhooks/1354553827482927104/gbmxxqFnmHgKOWL2DDCxUm-L1i02J082tVNYF_qG4VroDzP48qCTtkWNBz35HB_Ow9mR"

docker exec $CONTAINER mysqldump --no-tablespaces -u $USER -p$PASSWORD $DB > $BACKUP_DIR/wordpress_db_$DATE.sql

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
