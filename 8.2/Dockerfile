# Dev image containing phpfpm and nginx
# Start with official php fpm
FROM php:8.2.30-fpm-alpine

# Add mlocatis php extension installer
ADD https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/
# Make it executable
RUN chmod +x /usr/local/bin/install-php-extensions \
# Add PHP extensions using mlocatis script
# PHP  extensions and composer using mlocati/docker-php-extension-installer
  && install-php-extensions @composer \
  exif \
  gd \
  imagick \
  json_post \
  mysqli \
  opcache \
  pdo_mysql \
  sodium \
  xdebug \
  zip \
  bcmath \
  imap
# Install NGINX
RUN apk update && apk add --no-cache nginx curl
# Install supervisor for process management
RUN apk add --no-cache supervisor 
RUN apk add --no-cache \
  bash ca-certificates git github-cli ripgrep jq python3 py3-pip \
  openssh-client-default rsync sqlite zip unzip tar gzip \
  coreutils findutils grep sed diffutils patch procps-ng

# Copy default Xdebug configuration
COPY ./config-default/docker-php-ext-xdebug.ini /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
# Copy default Nginx configuration
COPY ./config-default/nginx-main.conf /etc/nginx/nginx.conf
COPY ./config-default/nginx.conf /etc/nginx/conf.d/default.conf
COPY ./config-default/zz-healthcheck.conf /usr/local/etc/php-fpm.d/zz-healthcheck.conf
# Copy default Supervisord configuration
COPY ./config-default/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
# Copy test index.php file to server root
COPY ./index.php /var/www/html/index.php

# Ensure www-data user has access to all required files
RUN chown -R www-data:www-data /var/www/html /run /var/lib/nginx /var/log/nginx
# Switch user to www-data, we don't need root anymore
USER www-data
EXPOSE 80

# Start PHP-FPM and NGINX via supervisord
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]

# Configure a healthcheck to validate that everything is up&running
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
  CMD response="$(curl --silent --show-error --fail --max-time 5 http://127.0.0.1:80/fpm-ping)" && [ "$response" = pong ]