#!/bin/bash
# Stop Caddy reverse proxy
set -euo pipefail

echo "=== Stopping Caddy Reverse Proxy ==="

pkill -f "caddy run" 2>/dev/null || true

echo "Caddy stopped."
