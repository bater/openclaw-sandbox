#!/bin/bash
# Stop OpenClaw in the sandbox VM
set -euo pipefail

echo "=== Stopping OpenClaw ==="
echo ""

# Check if Lima is installed
if ! command -v limactl &> /dev/null; then
    echo "Lima is not installed. Nothing to stop."
    exit 0
fi

# Check if VM exists and is running
if ! limactl list 2>/dev/null | grep -q "openclaw.*Running"; then
    echo "VM is not running. Nothing to stop."
    exit 0
fi

# Find and kill OpenClaw processes in VM
echo "Stopping OpenClaw processes..."
limactl shell openclaw -- pkill -f "openclaw" 2>/dev/null || true
limactl shell openclaw -- pkill -f "node.*openclaw" 2>/dev/null || true

echo ""
echo "OpenClaw stopped."
echo ""
echo "The VM is still running. Options:"
echo "  - Start OpenClaw again: make start"
echo "  - Stop the VM:          make vm-stop"
echo "  - Destroy everything:   make destroy"
