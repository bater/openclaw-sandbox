#!/bin/bash
# Start Caddy reverse proxy for openclaw.dev
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

echo "=== Starting Caddy Reverse Proxy ==="
echo ""

# Check if Caddy is installed
if ! command -v caddy &> /dev/null; then
    echo "Error: Caddy is not installed."
    echo "Run: brew install caddy"
    exit 1
fi

# Check if openclaw.dev is in /etc/hosts
if ! grep -q "openclaw.dev" /etc/hosts; then
    echo "Error: openclaw.dev not found in /etc/hosts"
    echo "Run: sudo sh -c 'echo \"127.0.0.1 openclaw.dev\" >> /etc/hosts'"
    exit 1
fi

# Check if Caddyfile exists
if [[ ! -f "$PROJECT_DIR/Caddyfile" ]]; then
    echo "Error: Caddyfile not found in $PROJECT_DIR"
    exit 1
fi

echo "Starting Caddy..."
echo ""
echo "OpenClaw will be available at:"
echo "  https://openclaw.dev"
echo ""
echo "Press Ctrl+C to stop"
echo ""

cd "$PROJECT_DIR"
caddy run --config Caddyfile
