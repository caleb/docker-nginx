#!/usr/bin/env bash
set -e
shopt -s globstar nullglob

. /helpers/vars.sh
. /helpers/links.sh
. /helpers/auto-symlink.sh
auto-symlink

read-var NGINX_ROOT             -- /srv
read-var NGINX_SERVER_NAME      -- localhost
read-var NGINX_WORKER_PROCESSES -- 3
read-var NGINX_MAX_BODY_SIZE    -- 1m
read-var NGINX_BODY_TIMEOUT     -- 60s
read-var NGINX_SENDFILE         -- off
read-var NGINX_AUTOINDEX        -- off

read-var NGINX_CANONICAL_NAME   --

if [ "${WITH_RSYSLOG,,}" = "true" ] || [ "${WITH_RSYSLOG,,}" = "yes" ]; then
  require-link RSYSLOG rsyslog 514 udp
fi

# Look for upstreams and link them for easy access
if [ -n "${UPSTREAM}" ]; then
  # the upstream name will be __default__, which is why we have 3 underscores
  export UPSTREAM___DEFAULT__="${UPSTREAM}"
fi

for var in ${!UPSTREAM_*}; do
  upstream_name="${var#UPSTREAM_}"
  upstream_name="${upstream_name,,}"

  upstream_value="${!var}"
  upstream_link="${upstream_value%% *}"

  # If length of the whole value is the same as the link name part, then the user
  # didn't provide any extra arguments
  if [ "${#upstream_link}" -ne "${#upstream_value}" ]; then
    upstream_args=" ${upstream_value#* }"
  else
    upstream_args=""
  fi

  # Extract the port out of the link_name if specified
  if [[ "${upstream_link}" =~ ^([^:]*):([[:digit:]]+)$ ]]; then
    upstream_link="${BASH_REMATCH[1]}"
    upstream_port="${BASH_REMATCH[2]}"
  fi

  upstream_prefix="${upstream_name^^}"
  require-link "${upstream_prefix}" "${upstream_link}" "${upstream_port}" tcp

  # Create the upstream in sites-available
  cat > "/etc/nginx/upstreams-enabled/${upstream_name,,}.conf" <<EOF
upstream ${upstream_name} {
  server ${upstream_link}:${upstream_port}${upstream_args};
}
EOF
done

if [ -z "${NGINX_CANONICAL_NAME}" ]; then
  # Grab the first server name to use as the canonical name
  NGINX_CANONICAL_NAME="${NGINX_SERVER_NAME%% *}"
fi

# Fill out the templates
for f in /etc/nginx/**/*.mo; do
  # Don't overwrite files that already exist
  if [ ! -f "${f%.mo}" ]; then
    /usr/local/bin/mo "${f}" > "${f%.mo}"
  fi

  rm "${f}"
done

if [ -z "${NGINX_SKIP_DEFAULT_SITE}" ]; then
  # if the user has ssl keys, configure nginx with ssl
  if [ -f /etc/nginx/certs/ssl.key ] && [ -f /etc/nginx/certs/ssl.crt ]; then
    ln -sf /etc/nginx/sites-available/ssl.conf /etc/nginx/sites-enabled/ssl.conf
  else
    ln -sf /etc/nginx/sites-available/default.conf /etc/nginx/sites-enabled/default.conf
  fi
fi

exec "$@"
