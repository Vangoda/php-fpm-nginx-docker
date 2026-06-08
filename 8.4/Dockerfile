# vangoda/php-fpm-alpine-8.4.Dockerfile
# Base PHP-FPM 8.4 + nginx + supervisord image

# =========================
# Stage 1: build extensions
# =========================
ARG PHP_FPM_TAG=8.4-fpm-alpine
FROM php:${PHP_FPM_TAG} AS php-build

# mlocati installer
ADD https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/
RUN chmod +x /usr/local/bin/install-php-extensions

# Install extensions (same list you use now)
RUN install-php-extensions @composer \
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
# Stage 1: runtime
# =========================
FROM php:${PHP_FPM_TAG} AS php-runtime

# Runtime OS deps only (no build deps)
RUN apk add --no-cache \
    nginx \
    supervisor \
    git \
    bash \
    curl

# Copy PHP extensions + ini from build stage
COPY --from=php-build /usr/local/lib/php/extensions/ /usr/local/lib/php/extensions/
COPY --from=php-build /usr/local/etc/php/conf.d/ /usr/local/etc/php/conf.d/

# Configs (same locations as now)
COPY ./config-default/docker-php-ext-xdebug.ini /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
COPY ./config-default/nginx.conf /etc/nginx/conf.d/default.conf
COPY ./config-default/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Example app file
COPY ./index.php /var/www/html/index.php

# Permissions and user (same as now)
RUN chown -R www-data:www-data /var/www/html /run /var/lib/nginx /var/log/nginx
USER www-data

WORKDIR /var/www/html
EXPOSE 80

# Supervisor runs php-fpm + nginx
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]

# Optional: fix your healthcheck URL (missing colon in current file)
HEALTHCHECK --timeout=10s CMD curl --silent --fail http://127.0.0.1:80/fpm-ping || exit 1