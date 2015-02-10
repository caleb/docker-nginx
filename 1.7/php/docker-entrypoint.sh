#!/usr/bin/env bash
set -e
shopt -s globstar

export PHP_FPM_ADDR
export PHP_FPM_CLIENT_MAX_BODY_SIZE

: ${PHP_FPM_LINK:=php-fpm}

function get_link_prefix {
  prefix=""
  linked_variable="${1}"
  compgen -v | while read name; do
                 prefix="${name%_ENV_$linked_variable}"
                 if [ "${prefix}" != "${name}" ]; then
                   break;
                 fi
               done
  echo "${prefix}"
}

php_fpm_prefix=""
if [ -z "${PHP_FPM_LINK}" ] && [ -z "${PHP_FPM_ADDR}" ]; then
  php_fpm_prefix="$(get_link_prefix PHP_FPM_PORT)"
elif [ -n "${PHP_FPM_LINK}" ]; then
  php_fpm_prefix="${PHP_FPM_LINK//-/_}"
  php_fpm_prefix="${php_fpm_prefix^^}"
fi

if [ -n "${php_fpm_prefix}" ] && [ -z "${PHP_FPM_ADDR}" ]; then
  var="${php_fpm_prefix}_PORT"
  PHP_FPM_ADDR="${!var}"
  PHP_FPM_ADDR="${PHP_FPM_ADDR#tcp://}"
fi

# If the user hasn't explicitly overrode the upload size, read the upload size
# from the php-fpm container
if [ -z "${PHP_FPM_CLIENT_MAX_BODY_SIZE}" ] && [ -n "${php_fpm_prefix}"  ]; then
  php_var="${php_fpm_prefix}_ENV_PHP_FPM_UPLOAD_MAX_FILESIZE"
  upload_size="${!php_var}"

  if [ -n "${upload_size}" ]; then
    # Downcase the size (php uses uppercase postfixes and nginx uses lowercase)
    PHP_FPM_CLIENT_MAX_BODY_SIZE="${upload_size,,}"
  fi
fi

exec /nginx-entrypoint.sh "$@"
