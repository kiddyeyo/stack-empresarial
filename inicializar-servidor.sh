#!/bin/bash

# Generar archivo nginx final desde plantilla
envsubst < nginx-conf/default.conf.template > nginx-conf/default.conf

# Levantar los servicios Docker
docker compose up -d

# Ejecutar script Certbot para renovar certificados
bash certbot-renew.sh
