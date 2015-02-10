#!/usr/bin/env bash
set -e
shopt -s globstar

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

if [ -n "${NGINX_SHARED_LINK}" ]; then
  NGINX_SHARED_LINK_DEFAULT="${NGINX_SHARED_LINK}"
fi

# Link shared directories (like uploads)
for link_var in ${!NGINX_SHARED_LINK_*}; do
  link="${!link_var}"
  if [ -n "${link}" ]; then
    from="${link%%:*}"
    to="${link#*:}"
    if [ -z "${from}" ] || [ -z "${to}" ]; then
      echo "A link must be in the form <from>:<to>"
      exit 1
    else
      ln -f -s -T "${from}" "${to}"
    fi
  fi
done

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
