#!/usr/bin/env bash
set -e
shopt -s globstar

export NGINX_PHP_CLIENT_MAX_BODY_SIZE

. /helpers/links.sh
require-link PHP_FPM php-fpm 9000 tcp

if [ -z "${NGINX_PHP_CLIENT_MAX_BODY_SIZE}" ]; then
  NGINX_PHP_CLIENT_MAX_BODY_SIZE="${PHP_FPM_ENV_PHP_FPM_UPLOAD_MAX_FILESIZE:-8m}"
fi

# Downcase the size (php uses uppercase postfixes and nginx uses lowercase)
NGINX_PHP_CLIENT_MAX_BODY_SIZE="${NGINX_PHP_CLIENT_MAX_BODY_SIZE,,}"

exec /nginx-entrypoint.sh "$@"
