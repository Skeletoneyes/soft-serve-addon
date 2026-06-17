#!/bin/sh
set -e

OPTIONS=/data/options.json
CONFIG=/data/config.yaml

# Seed Soft Serve's admin keys from the HA add-on's admin_keys option by writing
# its native config file. Soft Serve reads $SOFT_SERVE_DATA_PATH/config.yaml
# (ConfigPath) on startup; a compact JSON array is a valid YAML flow-sequence,
# so we can emit `initial_admin_keys: ["...","..."]` directly with jq -c.
#
# This replaces the SOFT_SERVE_INITIAL_ADMIN_KEYS environment-variable path,
# which did NOT populate the config under caarlos0/env v11 in this image
# (verified: a byte-perfect newline-separated env value yielded zero admin keys).
#
# Written once (when no config exists yet) so the keys land before first DB init
# — the create-tables migration seeds the admin user from these keys.
if [ -f "$OPTIONS" ] && [ ! -f "$CONFIG" ]; then
  KEYS_JSON="$(jq -c '.admin_keys // []' "$OPTIONS")"
  if [ -n "$KEYS_JSON" ] && [ "$KEYS_JSON" != "[]" ]; then
    printf '# Generated from the HA add-on admin_keys option.\ninitial_admin_keys: %s\n' "$KEYS_JSON" > "$CONFIG"
    echo "run.sh: wrote $CONFIG:"
    cat "$CONFIG"
  else
    echo "run.sh: no admin_keys set in options; starting without seeded admin"
  fi
fi

exec /usr/local/bin/soft serve
