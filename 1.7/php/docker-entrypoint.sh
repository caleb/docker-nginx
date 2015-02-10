#!/usr/bin/env bash
set -e
shopt -s globstar

export NGINX_PHP_FPM_ADDR
export NGINX_PHP_FPM_PORT
export NGINX_PHP_FPM_CLIENT_MAX_BODY_SIZE

: ${NGINX_PHP_FPM_ADDR:=php-fpm}
: ${NGINX_PHP_FPM_PORT:=9000}
: ${NGINX_PHP_FPM_LINK_NAME=php-fpm}

# If the user hasn't explicitly overrode the upload size, read the upload size
# from the php-fpm container
if [ -z "${PHP_FPM_CLIENT_MAX_BODY_SIZE}" ]; then
  php_var="${PHP_FPM_LINK_NAME}_ENV_PHP_FPM_UPLOAD_MAX_FILESIZE"
  upload_size="${!php_var}"
  if [ -n "${upload_size}" ]; then
    # Downcase the size (php uses uppercase postfixes and nginx uses lowercase)
    PHP_FPM_CLIENT_MAX_BODY_SIZE="${upload_size,,}"
  fi
fi

exec /nginx-entrypoint.sh "$@"
