#!/bin/bash
# Start OpenClaw in the sandbox VM
set -euo pipefail

echo "=== Starting OpenClaw in Sandbox VM ==="
echo ""

# Check if Lima is installed
if ! command -v limactl &> /dev/null; then
    echo "Error: Lima is not installed."
    echo "Run: make setup"
    exit 1
fi

# Check if VM exists
if ! limactl list 2>/dev/null | grep -q "openclaw"; then
    echo "Error: VM 'openclaw' does not exist."
    echo "Run: make create"
    exit 1
fi

# Check if VM is running, start if not
if ! limactl list 2>/dev/null | grep -q "openclaw.*Running"; then
    echo "Starting VM..."
    limactl start openclaw
    sleep 5
fi

# Check if OpenClaw is installed
if ! limactl shell openclaw -- which openclaw &> /dev/null; then
    echo "OpenClaw not found in VM. Installing..."
    limactl shell openclaw -- npm install -g openclaw@latest
fi

echo ""
echo "============================================"
echo "Starting OpenClaw..."
echo ""
echo "OpenClaw will be available at:"
echo "  http://localhost:18789"
echo "  http://localhost:18790"
echo ""
echo "Press Ctrl+C to stop OpenClaw"
echo "============================================"
echo ""

# Run OpenClaw gateway in foreground
limactl shell openclaw -- openclaw gateway
