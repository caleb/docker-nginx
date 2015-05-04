#!/usr/bin/env bash
set -e
shopt -s globstar

. /helpers/links.sh
read-link UNICORN unicorn 3000 tcp

#
# Look through the upstreams to see if the user provided a definition for "unicorn"
# If they did not, create one, if they did, use theirs
#
found_unicorn=false
if [ -n "${UPSTREAM}" ]; then
  export UPSTREAM__DEFAULT__="${UPSTREAM}"
fi
for var in ${!UPSTREAM_*}; do
  upstream="${!var}"
  if [ "${upstream%% *}" = "unicorn" ]; then
    found_unicorn=true
    break
  fi
done

if [ "${found_unicorn}" = false ]; then
  export UPSTREAM__UNICORN__="unicorn"
fi

exec /nginx-entrypoint.sh "$@"
