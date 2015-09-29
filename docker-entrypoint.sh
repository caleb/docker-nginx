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

  # If the upstream link contains a dot, assume it's a domain name and not a link
  if [[ ! "${upstream_link}" =~ \. ]]; then
    upstream_prefix="${upstream_link^^}"
    port_var="${upstream_prefix}_PORT"
    addr_var="${upstream_prefix}_ADDR"

    if [ -n "${upstream_port}" ]; then
      read-link "${upstream_prefix}" "${upstream_link}" "${upstream_port}" tcp
    else
      read-link "${upstream_prefix}" "${upstream_link}"
    fi

    if [ -z "${!addr_var}" ] && [ -z "${!port_var}" ]; then
      echo "You specified an upstream ${var} but a link by the name ${upstream_link} doesn't exist, or doesn't expose any ports" >&2
      exit 1
    else
      # Read the port from the link
      upstream_port="${!port_var}"
    fi
  fi

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
