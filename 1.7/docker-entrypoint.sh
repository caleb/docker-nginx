#!/usr/bin/env bash
set -e
shopt -s globstar nullglob

. /helpers/auto_symlink.sh
auto_symlink

export NGINX_ROOT
export NGINX_SERVER_NAME
export NGINX_CANONICAL_NAME
export NGINX_WORKER_PROCESSES
export NGINX_MAX_BODY_SIZE
export NGINX_BODY_TIMEOUT

: ${NGINX_ROOT:=/srv}
: ${NGINX_SERVER_NAME:=localhost}
: ${NGINX_WORKER_PROCESSES:=3}
: ${NGINX_MAX_BODY_SIZE:=1m}
: ${NGINX_BODY_TIMEOUT:=60s}

if [ -z "${NGINX_CANONICAL_NAME}" ]; then
  # Grab the first server name to use as the canonical name
  NGINX_CANONICAL_NAME="${NGINX_SERVER_NAME%% *}"
fi

# Fill out the templates
for f in /etc/nginx/**/*.mo; do
  /usr/local/bin/mo "${f}" > "${f%.mo}"
  rm "${f}"
done

if [ -z "${NGINX_SKIP_DEFAULT_SITE}" ]; then
  # if the user has ssl keys, configure nginx with ssl
  if [ -f /etc/nginx/certs/ssl.key -a -f /etc/nginx/certs/ssl.crt ]; then
    ln -s /etc/nginx/sites-available/ssl.conf /etc/nginx/sites-enabled/ssl.conf
  else
    ln -s /etc/nginx/sites-available/default.conf /etc/nginx/sites-enabled/default.conf
  fi
fi

exec "$@"
