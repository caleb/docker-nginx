#!/usr/bin/env bash
set -e
shopt -s globstar

#
# Find the rails upstream to use. Either the user specifies an RAILS_UPSTREAM which indicated
# the upstream to use e.g.
#    RAILS_UPSTREAM=my_upstream
#    UPSTREAM_MY_UPSTREAM="rails:1234 <options>"
#
# Or look for an upstream named one of: rails, unicorn, puma. E.g.
#    UPSTREAM_RAILS=my-container:3000
#    UPSTREAM_UNICORN=my-container:3000
#    UPSTREAM_PUMA=my-container:3000
#
# If no upstream meeting the above criteria is found, use the default upstream. E.g.
#    UPSTREAM=my-container:3000
#
. /helpers/vars.sh

read-var RAILS_UPSTREAM --

if [ -z "${RAILS_UPSTREAM}" ]; then
  if [ -n "${UPSTREAM_RAILS}" ]; then
    RAILS_UPSTREAM=rails
  elif [ -n "${UPSTREAM_UNICORN}" ]; then
    RAILS_UPSTREAM=unicorn
  elif [ -n "${UPSTREAM_PUMA}" ]; then
    RAILS_UPSTREAM=puma
  elif [ -n "${UPSTREAM}" ]; then
    RAILS_UPSTREAM=__default__
  fi
else
  # our upstream name is what the user specified, underscorized and lowercased
  RAILS_UPSTREAM="${RAILS_UPSTREAM//-/_}"
  RAILS_UPSTREAM="${RAILS_UPSTREAM,,}"

  upstream_var="UPSTREAM_${RAILS_UPSTREAM^^}"
  if [ -z "${!upstream_var}" ]; then
    echo "You specified the upstream for rails as ${RAILS_UPSTREAM}, but no UPSTREAM_${RAILS_UPSTREAM^^} upstream was defined." >&2
    exit 1
  fi
fi

exec /nginx-entrypoint.sh "$@"
