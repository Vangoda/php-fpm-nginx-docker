# Dev image containing phpfpm and nginx
# Start with official php fpm
FROM php:8.2.28-fpm-alpine

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
  bcmath
# Install NGINX
RUN apk update && apk add --no-cache nginx
# Install supervisor for process management
RUN apk add --no-cache supervisor 
# Install git
RUN apk add --no-cache git
# Install bash
RUN apk add --no-cache bash

# Copy default Xdebug configuration
COPY ./config-default/docker-php-ext-xdebug.ini /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
# Copy default Nginx configuration
COPY ./config-default/nginx.conf /etc/nginx/conf.d/default.conf
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
HEALTHCHECK --timeout=10s CMD curl --silent --fail https//127.0.0.1:80/fpm-ping