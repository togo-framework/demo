#!/bin/sh
set -e
mkdir -p /data
demo-migrate || true
demo-seed || true          # seed sample data so the dashboard has content
demo-api &                 # API on :8080
exec nginx -g 'daemon off;'
