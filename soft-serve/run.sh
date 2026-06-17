#!/bin/sh
set -e

OPTIONS=/data/options.json

# Soft Serve reads initial admin keys from SOFT_SERVE_INITIAL_ADMIN_KEYS as a
# NEWLINE-separated list (config struct tag envSeparator:"\n"). The HA add-on
# stores the user's admin_keys array in /data/options.json — translate it here.
# Applied on every start; Soft Serve treats it idempotently (ensures admin).
if [ -f "$OPTIONS" ]; then
  ADMIN_KEYS="$(jq -r '(.admin_keys // []) | join("\n")' "$OPTIONS")"
  if [ -n "$ADMIN_KEYS" ]; then
    export SOFT_SERVE_INITIAL_ADMIN_KEYS="$ADMIN_KEYS"
  fi
fi

exec /usr/local/bin/soft serve
