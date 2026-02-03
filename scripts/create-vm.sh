#!/bin/bash
# Create the OpenClaw sandbox VM
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

echo "=== Creating OpenClaw Sandbox VM ==="
echo ""

# Check if Lima is installed
if ! command -v limactl &> /dev/null; then
    echo "Error: Lima is not installed."
    echo "Run: ./scripts/setup-host.sh first"
    exit 1
fi

# Check if VM already exists
if limactl list 2>/dev/null | grep -q "openclaw"; then
    echo "VM 'openclaw' already exists."
    echo ""
    echo "Options:"
    echo "  - Start it:   limactl start openclaw"
    echo "  - Delete it:  ./scripts/destroy-vm.sh"
    echo ""
    exit 1
fi

# Create the VM
echo "Creating Lima VM from configuration..."
echo "This will take several minutes on first run:"
echo "  - Downloading Ubuntu 24.04 cloud image"
echo "  - Setting up the VM"
echo "  - Installing Node.js 22"
echo "  - Installing OpenClaw"
echo ""

limactl create --name=openclaw "$PROJECT_DIR/lima/openclaw.yaml"

# Start the VM
echo ""
echo "Starting the VM..."
limactl start openclaw

# Wait for VM to be ready
echo ""
echo "Waiting for VM to be fully ready..."
sleep 10

# Verify Node.js installation
echo ""
echo "Verifying installation..."
echo "Node.js version:"
limactl shell openclaw -- node --version

echo ""
echo "npm version:"
limactl shell openclaw -- npm --version

# Verify OpenClaw installation
echo ""
echo "OpenClaw installation:"
limactl shell openclaw -- which openclaw || limactl shell openclaw -- npm list -g openclaw

echo ""
echo "=== VM created successfully ==="
echo ""
echo "VM Status:"
limactl list

echo ""
echo "Security verification - attempting to access Mac files (should fail):"
if limactl shell openclaw -- ls /Users 2>/dev/null; then
    echo "WARNING: VM can access /Users - isolation may not be complete"
else
    echo "PASS: VM cannot access Mac files - isolation is working"
fi

echo ""
echo "============================================"
echo "Your sandbox VM is ready!"
echo ""
echo "To access the VM shell:"
echo "  limactl shell openclaw"
echo ""
echo "To start OpenClaw:"
echo "  ./scripts/start-openclaw.sh"
echo "  or: make start"
echo ""
echo "OpenClaw will be available at:"
echo "  http://localhost:18789"
echo "  http://localhost:18790"
echo "============================================"
