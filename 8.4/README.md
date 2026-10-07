# PHP 8.4 image healthcheck

The image checks `http://127.0.0.1:80/fpm-ping` for the exact response `pong`.
PHP-FPM enables this endpoint through `config-default/zz-healthcheck.conf`.
The supplied nginx configuration forwards it to PHP-FPM and restricts access
to loopback. Overrides supplied through `/opt/config-custom/nginx.conf` must
retain this route; existing overrides are not overwritten by the entrypoint.

The check allows 60 seconds for startup, runs every 30 seconds, and marks the
container unhealthy after three failures. It tests nginx and PHP-FPM, not the
application database.

Rebuild and publish this image, then rebuild downstream images with `--pull`.
Verify the running container becomes healthy and that stopping PHP-FPM causes
the check to fail in a disposable test container.
