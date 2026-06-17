#!/bin/sh
set -e

OPTIONS=/data/options.json

# Soft Serve reads initial admin keys from SOFT_SERVE_INITIAL_ADMIN_KEYS as a
# NEWLINE-separated list (config struct tag envSeparator:"\n"). The HA add-on
# stores the user's admin_keys array in /data/options.json — translate it here.
if [ -f "$OPTIONS" ]; then
  ADMIN_KEYS="$(jq -r '(.admin_keys // []) | join("\n")' "$OPTIONS")"
  if [ -n "$ADMIN_KEYS" ]; then
    export SOFT_SERVE_INITIAL_ADMIN_KEYS="$ADMIN_KEYS"
  fi
fi

echo "run.sh: --- SOFT_SERVE_INITIAL_ADMIN_KEYS bytes ---"
printf '%s' "$SOFT_SERVE_INITIAL_ADMIN_KEYS" | od -An -c | head -20
echo "run.sh: --- /data listing ---"
ls -la /data 2>&1
echo "run.sh: --- /data/config.yaml (if any) ---"
[ -f /data/config.yaml ] && cat /data/config.yaml || echo "(no /data/config.yaml)"
echo "run.sh: --- end diag ---"

exec /usr/local/bin/soft serve
