#!/bin/sh
set -e
mkdir -p /data
# Production refuses to start without AUTH_SECRET: keep one in the volume so
# sessions survive restarts when the host does not pass its own.
if [ -z "$AUTH_SECRET" ]; then
  [ -s /data/.auth_secret ] || head -c 32 /dev/urandom | od -An -tx1 | tr -d ' \n' > /data/.auth_secret
  AUTH_SECRET="$(cat /data/.auth_secret)"; export AUTH_SECRET
fi
demo-migrate || true
demo-seed || true          # seed sample data so the dashboard has content
demo-api &                 # API on :8080
exec nginx -g 'daemon off;'
