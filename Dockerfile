# Etapa de construcción
FROM php:8.3-apache AS builder

WORKDIR /var/www/html

# Instala las dependencias necesarias
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        git \
        zip \
        unzip \
        curl \
    && curl -sSL https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions -o /usr/local/bin/install-php-extensions \
    && chmod +x /usr/local/bin/install-php-extensions \
    && install-php-extensions curl gd intl ldap mbstring mysqli odbc pdo pdo_mysql soap sockets xml zip xdebug exif sqlite3 gettext bcmath csv event imap inotify mcrypt redis \
    && docker-php-ext-enable xdebug \
    && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
    && curl -sLS https://deb.nodesource.com/setup_18.x | bash - \
    && apt-get install -y nodejs \
    && npm install -g npm

# Clona el repositorio y ejecuta las instalaciones de Composer y NPM
RUN git clone https://github.com/alextselegidis/easyappointments.git reservas 

WORKDIR /var/www/html/reservas
RUN composer install
RUN npm install
RUN npm run build && rm -rf node_modules

# Etapa de producción
FROM php:8.3-apache

WORKDIR /var/www/html

# Copia el script de entrada
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Instala y habilita `mysqli`, `pdo`, y `pdo_mysql` en la etapa de producción
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        ssmtp \
        mailutils \
        curl \
    && docker-php-ext-install mysqli pdo pdo_mysql \
    && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Configura Apache y SSMTP para correos sin autenticación ni TLS
RUN a2enmod rewrite \
    && echo "hostname=localhost.localdomain" > /etc/ssmtp/ssmtp.conf \
    && echo "root=${ROOT_EMAIL}" >> /etc/ssmtp/ssmtp.conf \
    && echo "mailhub=correos.uca.edu.sv:25" >> /etc/ssmtp/ssmtp.conf \
    && echo "FromLineOverride=YES" >> /etc/ssmtp/ssmtp.conf \
    && echo "sendmail_path=/usr/sbin/ssmtp -t" >> /usr/local/etc/php/conf.d/php-sendmail.ini \
    && echo "alias ll=\"ls -al\"" >> /root/.bashrc \
    && echo "export XDEBUG_TRIGGER=1" >> /root/.bashrc \
    && echo "export PHP_IDE_CONFIG=\"serverName=host.docker.internal\"" >> /root/.bashrc

# Copia los archivos necesarios desde la etapa de construcción
COPY --from=builder /var/www/html/reservas /var/www/html/reservas

# Define variables de entorno para la configuración
ENV BASE_URL="http://localhost"
ENV LANGUAGE="english"
ENV DEBUG_MODE="false"
ENV DB_HOST="mysql"
ENV DB_NAME="easyappointments"
ENV DB_USERNAME="user"
ENV DB_PASSWORD="password"
ENV GOOGLE_SYNC_FEATURE="false"
ENV GOOGLE_CLIENT_ID=""
ENV GOOGLE_CLIENT_SECRET=""
ENV ROOT_EMAIL="root@example.org"

# Exponer el puerto 80 para Apache
EXPOSE 80

# Usa el script de inicio como punto de entrada
ENTRYPOINT ["/entrypoint.sh"]
