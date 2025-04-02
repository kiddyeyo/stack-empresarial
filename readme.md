
# Infraestructura Dockerizada - Erick Castillo

Este repositorio contiene un stack Docker que incluye:

- WordPress con base de datos MySQL
- Odoo con base de datos PostgreSQL
- Nginx como reverse proxy
- Certbot para certificados SSL Let's Encrypt
- Fail2ban para proteger Odoo
- Netdata para monitoreo del sistema
- Backups y Recertificacion automaticos 
---
## Descarga con el siguiente comando
```bash
cd ~
git clone https://github.com/kiddyeyo/stack-empresarial ~/infraestructura
```
---
## Instrucciones para el primer despliegue

> **Importante:** antes de iniciar el servidor por primera vez, sigue estos pasos para evitar errores y asegurar una configuración correcta.

---

### 1. Crear carpetas y archivos necesarios

```bash
mkdir -p backups/mysql
mkdir -p backups/postgres
touch odoo-logs/odoo.log
```

---

### 2. Configurar los archivos `.env` y `odoo.conf`

Edita `.env` y reemplaza los valores de las variables según tu configuración:

- `DOMAIN=erickhomelab.org`
- `LOCAL_IP=192.168.1.178`
- `PUBLIC_IP=189.x.x.x`
```bash
cp .env.example .env
nano .env
```
Copia los ejemplos y edítalos con tus valores personalizados:
```bash
cp odoo.conf.ejemplo odoo.conf
nano odoo.conf
```
```bash
cd nginx-conf
cp default.conf.ejemplo default.conf
nano defaul.conf
```
---

### 3. Comentar todo el bloque del puerto **443 y SSL** en `nginx-conf/default.conf`

Antes de generar los certificados SSL, debes comentar **todo el segundo bloque `server`** en `default.conf`:

```nginx
# server {
#     listen 443 ssl http2;
#     ...
# }
```

Esto evita que NGINX intente levantar el servicio SSL sin que existan los certificados.

---

### 4. Editar `docker-compose.yml`

Asegúrate de:

- Que el servicio `webserver` solo tenga expuesto el puerto 80:

```yaml
ports:
  - "80:80"
  # - "443:443"  # ← COMENTAR ESTA LÍNEA
```

- Que `certbot` tenga el flag `--staging`:

```yaml
command: certonly --webroot --webroot-path=/var/www/certbot --staging --email tuemail@example.com --agree-tos --no-eff-email -d tu.dominio.com -d www.tu.dominio.com
```

---

### 5. Levantar el stack por primera vez

```bash
docker compose up -d
```

Esto iniciará WordPress, Odoo, y Certbot en modo de prueba.
### 6. Verifica
Verifica que todos los procesos esten iniciados correctamente
```bash
docker ps
docker logs service_name
```
---

## Emisión del certificado real

### 7. Modificar Certbot para producción

Reemplaza `--staging` por `--force-renewal`:

```yaml
command: certonly --webroot --webroot-path=/var/www/certbot --force-renewal --email tuemail@example.com --agree-tos --no-eff-email -d tu.dominio.com -d www.tu.dominio.com
```

---

### 8. Forzar recreación de Certbot

```bash
docker compose up --force-recreate --no-deps certbot
```
---

### 9. Descomentar el bloque de SSL en `nginx-conf/default.conf`

Descomenta todo el bloque `server { ... }` con puerto `443` que antes comentaste.

---

### 10. Volver a habilitar el puerto 443 en `docker-compose.yml`

```yaml
ports:
  - "80:80"
  - "443:443"  # ← ACTIVAR ESTA LÍNEA
```

---

### 11. Reiniciar `webserver` con certificados reales

```bash
docker compose up -d --force-recreate --no-deps webserver
```
---
### 12. Modificar certbot para futuros reinicios

Elimina `--force-renewal`:
```yaml
command: certonly --webroot --webroot-path=/var/www/certbot --email tuemail@example.com --agree-tos --no-eff-email -d tu.dominio.com -d www.tu.dominio.com
```
---
## Configuración adicional

### 12. Activar puertos en UFW

```bash
sudo ufw allow 80
sudo ufw allow 443
sudo ufw enable
```
---

### 13. Configurar respaldo automático

Edita el crontab:

```bash
crontab -e
```
Recuerda poner tu path correcto con `tu_usuario` y agrega:

```bash
0 2 * * * /bin/bash /home/tu_usuario/infraestructura/certbot-renew.sh >> /home/tu_usuario/infraestructura/backups/certbot-renew.log 2>&1

0 3 * * * /bin/bash /home/tu_usuario/infraestructura/backups/backup_mysql.sh >> /home/tu_usuario/infraestructura/backups/mysql/backup.log 2>&1

0 4 * * * /bin/bash /home/tu_usuario/infraestructura/backups/backup_postgres.sh >> /home/tu_usuario/infraestructura/backups/postgres/backup.log 2>&1
```
---

## Licencia

Este proyecto es libre de usar y modificar.
