# PHP 8.2 image healthcheck

## Development tools

The runtime includes GitHub CLI (`gh`), Git, Bash, curl, CA certificates,
ripgrep, jq, Python 3 with pip and venv, SSH clients, rsync, SQLite,
zip/unzip/tar/gzip, GNU coreutils/findutils/grep/sed/diffutils, patch, and
procps. These are installed system-wide before switching to `www-data`, so
noninteractive agents can use them without shell initialization.

Create a Python virtual environment with `python3 -m venv /path/to/venv`;
do not install Python packages into Alpine's system-managed Python.
GitHub/SSH credentials are not included: authenticate at runtime and persist
credentials only in an appropriate private volume.

Node/npm/pnpm belong to downstream WebBaseDev images, not this PHP base.
The unfinished PHP 8.4 and legacy PHP versions are unchanged.

## Healthcheck

The image checks `http://127.0.0.1:80/fpm-ping` for the exact response `pong`.
PHP-FPM enables this endpoint through `config-default/zz-healthcheck.conf`.
Both supplied nginx configurations forward it to PHP-FPM and restrict access
to loopback. Project nginx overrides must retain this route.

The check allows 60 seconds for startup, runs every 30 seconds, and marks the
container unhealthy after three failures. It tests nginx and PHP-FPM, not the
application database.

Rebuild and publish this image, then rebuild downstream images with `--pull`.
Verify the running container becomes healthy and that stopping PHP-FPM causes
the check to fail in a disposable test container.

## Local tooling validation

The updated PHP base and downstream WebBaseDev, Perfex, WordPress 8.2, and
Lampioni images build locally. CLI access, Python venv creation, and PHP
extensions were checked, including tool access as `www-data`. The PHP base
contains no Node/npm/pnpm.

The image supplies `config-default/nginx-main.conf` as `/etc/nginx/nginx.conf`.
It includes `/etc/nginx/conf.d/*.conf` inside `http`, matching the supplied
server block and preserving the existing server-override path. This corrects
the Alpine package default's root-level `conf.d` include, which prevented
bare images from starting. The package's `http.d` default site is not included.

Existing Compose/Swarm mounts that replace `/etc/nginx/nginx.conf` continue
to replace the complete configuration; keep their `/fpm-ping` route.

With this fix, all five local images return exact `pong` with their default
configuration. Pausing PHP-FPM in each disposable container makes the
healthcheck command fail within its five-second request timeout.
