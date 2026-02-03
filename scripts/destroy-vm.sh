#!/bin/bash
# Destroy the OpenClaw sandbox VM and all its data
set -euo pipefail

echo "=== Destroying OpenClaw Sandbox VM ==="
echo ""

# Check if Lima is installed
if ! command -v limactl &> /dev/null; then
    echo "Lima is not installed. Nothing to destroy."
    exit 0
fi

# Check if VM exists
if ! limactl list 2>/dev/null | grep -q "openclaw"; then
    echo "VM 'openclaw' does not exist. Nothing to destroy."
    exit 0
fi

echo "WARNING: This will permanently delete:"
echo "  - The OpenClaw sandbox VM"
echo "  - ALL data inside the VM"
echo "  - All OpenClaw workspace data"
echo ""
echo "This action CANNOT be undone."
echo ""
read -p "Type 'yes' to confirm destruction: " confirm

if [[ "$confirm" != "yes" ]]; then
    echo ""
    echo "Cancelled. VM was not deleted."
    exit 0
fi

echo ""
echo "Stopping VM if running..."
limactl stop openclaw 2>/dev/null || true

echo "Deleting VM..."
limactl delete openclaw --force

echo ""
echo "=== VM destroyed ==="
echo ""
echo "The sandbox has been completely removed."
echo "Your Mac's files were never at risk."
echo ""
echo "To recreate the sandbox: make create"
