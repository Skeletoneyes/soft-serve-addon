#!/bin/sh
set -e

OPTIONS=/data/options.json

# Soft Serve reads initial admin keys from SOFT_SERVE_INITIAL_ADMIN_KEYS as a
# NEWLINE-separated list (config struct tag envSeparator:"\n"). The HA add-on
# stores the user's admin_keys array in /data/options.json — translate it here.
# Initial admin keys are applied when Soft Serve first initializes its data dir.
if [ -f "$OPTIONS" ]; then
  echo "run.sh: found $OPTIONS"
  ADMIN_KEYS="$(jq -r '(.admin_keys // []) | join("\n")' "$OPTIONS")"
  KEYCOUNT="$(printf '%s\n' "$ADMIN_KEYS" | grep -c 'ssh-' || true)"
  echo "run.sh: parsed $KEYCOUNT admin key(s) from options"
  if [ -n "$ADMIN_KEYS" ]; then
    export SOFT_SERVE_INITIAL_ADMIN_KEYS="$ADMIN_KEYS"
    echo "run.sh: exported SOFT_SERVE_INITIAL_ADMIN_KEYS"
  fi
else
  echo "run.sh: $OPTIONS NOT FOUND — starting with no admin keys"
fi

exec /usr/local/bin/soft serve
