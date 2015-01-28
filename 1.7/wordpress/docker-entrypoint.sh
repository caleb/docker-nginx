#!/usr/bin/env bash
set -e
shopt -s globstar

export NGINX_ROOT
export NGINX_SERVER_NAME
export NGINX_CANONICAL_NAME
export NGINX_WORKER_PROCESSES
export NGINX_PHP_FPM_ADDR
export NGINX_PHP_FPM_PORT
export NGINX_MEMCACHED_ADDR
export NGINX_MEMCACHED_PORT

: ${NGINX_ROOT:=/srv}
: ${NGINX_SERVER_NAME:=localhost}
: ${NGINX_WORKER_PROCESSES:=3}
: ${NGINX_PHP_FPM_ADDR:=php-fpm}
: ${NGINX_PHP_FPM_PORT:=9000}
: ${NGINX_MEMCACHED_ADDR:=}
: ${NGINX_MEMCACHED_PORT:=11211}

if [ -z "${CANONICAL_NAME}" ]; then
  NGINX_CANONICAL_NAME="$(echo -n "${SERVER_NAME}" | cut -f 1 -d " ")"
fi

# Fill out the templates
for f in /etc/nginx/**/*.mo; do
  /usr/local/bin/mo "${f}" > "${f%.mo}"
  rm "${f}"
done

# if the user has ssl keys, configure nginx with ssl
if [ -f /etc/nginx/certs/ssl.key -a -f /etc/nginx/certs/ssl.crt ]; then
  ln -s /etc/nginx/sites-available/ssl.conf /etc/nginx/sites-enabled/default.conf
else
  ln -s /etc/nginx/sites-available/default.conf /etc/nginx/sites-enabled/default.conf
fi

exec "$@"
