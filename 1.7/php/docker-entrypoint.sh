#!/usr/bin/env bash
set -e
shopt -s globstar

export PHP_FPM_CLIENT_MAX_BODY_SIZE

. /helpers/links.sh
require_link PHP_FPM php-fpm 9000 tcp

PHP_FPM_CLIENT_MAX_BODY_SIZE="${PHP_FPM_ENV_PHP_FPM_UPLOAD_MAX_FILESIZE:-}"
# Downcase the size (php uses uppercase postfixes and nginx uses lowercase)
PHP_FPM_CLIENT_MAX_BODY_SIZE="${PHP_FPM_CLIENT_MAX_BODY_SIZE,,}"

exec /nginx-entrypoint.sh "$@"
