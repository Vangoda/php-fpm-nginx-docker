# vangoda/php-fpm-alpine-8.4.Dockerfile
# Base PHP-FPM 8.4 + nginx + supervisord image

ARG PHP_FPM_TAG=8.4-fpm-alpine


# =========================
# Stage 1: build extensions
# =========================
FROM php:${PHP_FPM_TAG} AS php-build

RUN apk add --no-cache curl ca-certificates \
        && update-ca-certificates

# mlocati installer
ADD https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/
RUN chmod +x /usr/local/bin/install-php-extensions

# Install extensions (same list you use now)
RUN install-php-extensions \
        @composer \
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

# =========================
# Stage 2: runtime
# =========================
FROM php:${PHP_FPM_TAG} AS php-runtime

# Runtime OS deps only (no build deps)
RUN apk add --no-cache \
        nginx \
        supervisor \
        git \
        bash \
        gettext \
        ca-certificates \
        && update-ca-certificates \
        && mkdir -p /run/nginx /var/log/supervisor

# Copy PHP extensions + ini from build stage
COPY --from=php-build /usr/local/lib/php/extensions/ /usr/local/lib/php/extensions/
COPY --from=php-build /usr/local/etc/php/conf.d/ /usr/local/etc/php/conf.d/

# --------------------------------------------------------------------
# nginx + PHP config layout
# - /opt/config-custom: per-project overrides (bind-mounted from host)
# --------------------------------------------------------------------
RUN mkdir -p /opt/config-custom

# Copy default configs to default locations
COPY ./config-default/nginx.conf /etc/nginx/http.d/default.conf
COPY ./config-default/docker-php-ext-xdebug.ini /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
COPY ./config-default/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY ./config-default/php.ini /usr/local/etc/php/conf.d/php.ini

# Example app file
COPY ./index.php /var/www/html/index.php

# entrypoint to expose/apply configs
COPY ./config-default/entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# Permissions and user (same as now)
RUN chown -R www-data:www-data /var/www/html /run /var/lib/nginx /var/log/nginx

WORKDIR /var/www/html
EXPOSE 80

# Run the entrypont script. Copies default configs to custom dir and starts 
# supervisor.
CMD ["/usr/local/bin/docker-entrypoint.sh"]

# PING the server to check health
HEALTHCHECK --timeout=10s CMD wget -qO- http://127.0.0.1:80/fpm-ping || exit 1