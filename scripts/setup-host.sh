#!/bin/bash
# Setup script for macOS host - installs Lima VM manager
set -euo pipefail

echo "=== OpenClaw Sandbox: Host Setup ==="
echo ""

# Detect OS
if [[ "$(uname)" != "Darwin" ]]; then
    echo "Error: This script is designed for macOS only"
    exit 1
fi

# Check for Homebrew
if ! command -v brew &> /dev/null; then
    echo "Homebrew not found. Installing..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Add Homebrew to PATH for Apple Silicon
    if [[ -f "/opt/homebrew/bin/brew" ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
else
    echo "Homebrew found."
fi

# Install Lima
echo ""
echo "Installing Lima..."
brew install lima

# Verify installation
echo ""
echo "Verifying Lima installation..."
limactl --version

echo ""
echo "=== Host setup complete ==="
echo ""
echo "Lima is installed and ready."
echo ""
echo "Next steps:"
echo "  1. Run: ./scripts/create-vm.sh"
echo "  2. Run: ./scripts/start-openclaw.sh"
echo ""
echo "Or use the Makefile:"
echo "  make create"
echo "  make start"
