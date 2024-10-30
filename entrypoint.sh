#!/bin/bash
set -e

# Reemplazo de variables de entorno en config.php
sed -i "s|const BASE_URL = 'http://localhost';|const BASE_URL = '${BASE_URL}';|" /var/www/html/reservas/config-sample.php
sed -i "s|const LANGUAGE = 'english';|const LANGUAGE = '${LANGUAGE}';|" /var/www/html/reservas/config-sample.php
sed -i "s|const DEBUG_MODE = false;|const DEBUG_MODE = ${DEBUG_MODE};|" /var/www/html/reservas/config-sample.php
sed -i "s|const DB_HOST = 'mysql';|const DB_HOST = '${DB_HOST}';|" /var/www/html/reservas/config-sample.php
sed -i "s|const DB_NAME = 'easyappointments';|const DB_NAME = '${DB_NAME}';|" /var/www/html/reservas/config-sample.php
sed -i "s|const DB_USERNAME = 'user';|const DB_USERNAME = '${DB_USERNAME}';|" /var/www/html/reservas/config-sample.php
sed -i "s|const DB_PASSWORD = 'password';|const DB_PASSWORD = '${DB_PASSWORD}';|" /var/www/html/reservas/config-sample.php
sed -i "s|const GOOGLE_SYNC_FEATURE = false;|const GOOGLE_SYNC_FEATURE = ${GOOGLE_SYNC_FEATURE};|" /var/www/html/reservas/config-sample.php
sed -i "s|const GOOGLE_CLIENT_ID = '';|const GOOGLE_CLIENT_ID = '${GOOGLE_CLIENT_ID}';|" /var/www/html/reservas/config-sample.php
sed -i "s|const GOOGLE_CLIENT_SECRET = '';|const GOOGLE_CLIENT_SECRET = '${GOOGLE_CLIENT_SECRET}';|" /var/www/html/reservas/config-sample.php

# Copia el archivo actualizado
cp /var/www/html/reservas/config-sample.php /var/www/html/reservas/config.php

chown -R www-data:www-data /var/www/html/reservas

# Ejecuta Apache en primer plano
exec apache2-foreground
