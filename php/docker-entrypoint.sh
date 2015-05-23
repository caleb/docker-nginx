#!/usr/bin/env bash
set -e
shopt -s globstar

. /helpers/vars.sh
. /helpers/links.sh
require-link PHP_FPM php-fpm 9000 tcp

read-var NGINX_PHP_CLIENT_MAX_BODY_SIZE @PHP_FPM \
         PHP_FPM_UPLOAD_MAX_FILESIZE \
         -- 8m

# Downcase the size (php uses uppercase postfixes and nginx uses lowercase)
NGINX_PHP_CLIENT_MAX_BODY_SIZE="${NGINX_PHP_CLIENT_MAX_BODY_SIZE,,}"

exec /nginx-entrypoint.sh "$@"
