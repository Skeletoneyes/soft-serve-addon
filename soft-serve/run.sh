#!/bin/sh
set -e

OPTIONS=/data/options.json
CONFIG=/data/config.yaml
DB=/data/soft-serve.db

echo "run.sh: DATA_PATH=$SOFT_SERVE_DATA_PATH CONFIG_LOCATION=${SOFT_SERVE_CONFIG_LOCATION:-unset}"
echo "run.sh: existing $CONFIG:"; cat "$CONFIG" 2>/dev/null || echo "(none yet)"

# Seed Soft Serve's admin keys from the HA add-on's admin_keys option by writing
# its native config file (ConfigPath = $SOFT_SERVE_DATA_PATH/config.yaml). A
# compact JSON array is a valid YAML flow-sequence. Written once, before first
# DB init, so the create-tables migration seeds the admin from these keys.
if [ -f "$OPTIONS" ] && [ ! -f "$CONFIG" ]; then
  KEYS_JSON="$(jq -c '.admin_keys // []' "$OPTIONS")"
  if [ -n "$KEYS_JSON" ] && [ "$KEYS_JSON" != "[]" ]; then
    printf '# Generated from the HA add-on admin_keys option.\ninitial_admin_keys: %s\n' "$KEYS_JSON" > "$CONFIG"
    echo "run.sh: wrote $CONFIG"
  else
    echo "run.sh: no admin_keys set in options"
  fi
fi

# Diagnostic: if the DB already exists (a prior start), dump seeded admins/keys.
if [ -f "$DB" ]; then
  echo "run.sh: --- DB users ---"
  sqlite3 "$DB" "SELECT id,username,admin FROM users;" 2>&1 || true
  echo "run.sh: --- DB public_keys (truncated) ---"
  sqlite3 "$DB" "SELECT user_id,substr(public_key,1,50) FROM public_keys;" 2>&1 || true
fi

exec /usr/local/bin/soft serve
