#!/bin/sh
set -e

CUSTOM_ROOT="/opt/custom-config"

# Seed the host-visible config dir with current defaults (first run)
if [ -z "$(ls -A "$CUSTOM_ROOT" 2>/dev/null)" ]; then
  echo "Seeding /opt/custom-config from current defaults..."

  # Copy current in-image configs into custom root
  cp -n /etc/nginx/conf.d/default.conf \
    "$CUSTOM_ROOT/nginx.conf" 2>/dev/null || true

  cp -n /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    "$CUSTOM_ROOT/docker-php-ext-xdebug.ini" 2>/dev/null || true

  cp -n /etc/supervisor/conf.d/supervisord.conf \
    "$CUSTOM_ROOT/supervisord.conf" 2>/dev/null || true
fi

# Now always apply configs from custom root (host edits win)
if [ -f "$CUSTOM_ROOT/nginx.conf" ]; then
  cp "$CUSTOM_ROOT/nginx.conf" /etc/nginx/conf.d/default.conf
fi

if [ -f "$CUSTOM_ROOT/docker-php-ext-xdebug.ini" ]; then
  cp "$CUSTOM_ROOT/docker-php-ext-xdebug.ini" \
    /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
fi

if [ -f "$CUSTOM_ROOT/supervisord.conf" ]; then
  cp "$CUSTOM_ROOT/supervisord.conf" /etc/supervisor/conf.d/supervisord.conf
fi

# Start php-fpm + nginx
exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf