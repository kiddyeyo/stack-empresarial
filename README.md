\# Infraestructura Dockerizada \- Erick Castillo

Este repositorio contiene un stack Docker que incluye:  
\- WordPress con base de datos MySQL  
\- Odoo con base de datos PostgreSQL  
\- Nginx como reverse proxy  
\- Certbot para certificados SSL Let's Encrypt  
\- Fail2ban para proteger Odoo  
\- Netdata para monitoreo del sistema

\#\# Instrucciones para el primer despliegue

\> \*\*Importante:\*\* antes de iniciar el servidor por primera vez, debes seguir estos pasos para emitir los certificados SSL correctamente usando el entorno de \*\*staging\*\* de Let's Encrypt.

Antes que nada corre
envsubst < nginx-conf/default.conf.template > nginx-conf/default.conf

\#\#\# 1\. Modificar \`docker-compose.yml\`

Ubica el servicio \`certbot:\` y asegúrate que en la línea \`command:\` tenga el flag \`--staging\`. Por ejemplo:

\`\`\`yaml  
command: certonly \--webroot \--webroot-path=/var/www/certbot \--staging \--email tuemail@example.com \--agree-tos \--no-eff-email \-d tu.dominio.com \-d www.tu.dominio.com  
\`\`\`

Esto evitará que uses los límites de certificados reales mientras haces pruebas.

\#\#\# 2\. Eliminar puerto 443 del servicio \`webserver\` temporalmente

Comenta o elimina la línea del puerto 443 para NGINX:

\`\`\`yaml  
	ports:  
  	\- "80:80"  
  	\# \- "443:443" \<- COMENTAR ESTA LÍNEA INICIALMENTE  
\`\`\`

Esto evita conflictos al levantar el stack antes de que existan los certificados SSL.

\#\#\# 3\. Levantar el stack completo en modo prueba

\`\`\`bash  
docker compose up \-d  
\`\`\`

Verifica que todo funcione correctamente.

\#\# Emisión real del certificado

\#\#\# 4\. Cambiar de \`--staging\` a \`--force-renewal\`

En \`docker-compose.yml\`, reemplaza \`--staging\` por:

\`\`\`yaml  
\--force-renewal  
\`\`\`

\#\#\# 5\. Forzar recreación del contenedor \`certbot\`

\`\`\`bash  
docker compose up \--force-recreate \--no-deps certbot  
\`\`\`

\#\#\# 6\. Detener el \`webserver\`

\`\`\`bash  
docker compose stop webserver  
\`\`\`

\#\#\# 7\. Descargar configuración TLS moderna  
\`\`\`bash  
curl \-sSLo nginx-conf/options-ssl-nginx.conf https://raw.githubusercontent.com/certbot/certbot/master/certbot-nginx/certbot\_nginx/\_internal/tls\_configs/options-ssl-nginx.conf

O simplemente pega lo siguiente en el archivo options-ssl-nginx.conf

\# This file contains important security parameters. If you modify this file  
\# manually, Certbot will be unable to automatically provide future security  
\# updates. Instead, Certbot will print and log an error message with a path to  
\# the up-to-date file that you will need to refer to when manually updating  
\# this file. Contents are based on https://ssl-config.mozilla.org

ssl\_session\_cache shared:le\_nginx\_SSL:10m;  
ssl\_session\_timeout 1440m;  
ssl\_session\_tickets off;

ssl\_protocols TLSv1.2 TLSv1.3;  
ssl\_prefer\_server\_ciphers off;

ssl\_ciphers "ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384";  
\#\#\# 8\. Volver a habilitar el puerto 443 en \`docker-compose.yml\`

\`\`\`yaml  
	ports:  
  	\- "80:80"  
  	\- "443:443"  \# ← ACTIVAR ESTA LÍNEA  
\`\`\`

\#\#\# 9\. Levantar el \`webserver\` con certificados reales

\`\`\`bash  
docker compose up \-d \--force-recreate \--no-deps webserver  
\`\`\`

\---

Una vez completado este proceso, tu stack estará corriendo con certificados válidos de Let's Encrypt en producción.

\---

Variables de entorno

Todas las credenciales y configuraciones sensibles están contenidas en el archivo .env. Este archivo no se sube al repositorio por seguridad.

Debes crear un archivo .env en la raíz del proyecto con el siguiente contenido:

MYSQL_DATABASE=
MYSQL_USER=
MYSQL_PASSWORD=
MYSQL_ROOT_PASSWORD=

POSTGRES_DB=
POSTGRES_USER=
POSTGRES_PASSWORD=

DOMAIN= (sin www. ni otro)
LOCAL_IP=
PUBLIC_IP=

WEBHOOK_URL=

\#\# Licencia

Este proyecto es libre de usar y modificar.

