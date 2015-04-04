#!/usr/bin/env bash
set -e
shopt -s globstar nullglob

. /helpers/links.sh
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

# Look for upstreams and link them for easy access
if [ -n "${UPSTREAM}" ]; then
  export UPSTREAM__DEFAULT__="${UPSTREAM}"
fi

for var in ${!UPSTREAM_*}; do
  upstream_value="${!var}"
  upstream_link="${upstream_value%% *}"

  # If length of the whole value is the same as the link name part, then the user
  # didn't provide any extra arguments
  if [ "${#upstream_link}" -ne "${#upstream_value}" ]; then
    upstream_args=" ${upstream_value#* }"
  else
    upstream_args=""
  fi

  upstream_prefix="${upstream_link^^}"

  read_link "${upstream_prefix}" "${upstream_link}"

  if [ -z "${upstream_prefix}_ADDR" ] && [ -z "${upstream_prefix}_PORT" ]; then
    echo "You specified an upstream ${var} but a link by the name ${upstream_link} doesn't exist, or doesn't expose any ports" >&2
    exit 1
  fi

  # Create the upstream in sites-available
  cat > "/etc/nginx/upstreams/${upstream_link}.conf.mo" <<EOF
upstream ${upstream_link} {
  server ${upstream_link}:{{${upstream_prefix}_PORT}}${upstream_args};
}
EOF
done

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
