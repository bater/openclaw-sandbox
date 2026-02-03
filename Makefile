.PHONY: setup create start stop shell status destroy vm-start vm-stop update backup snapshots proxy proxy-stop all help

# Default target
help:
	@echo "OpenClaw Sandbox VM Management"
	@echo ""
	@echo "Usage: make <target>"
	@echo ""
	@echo "Setup & Creation:"
	@echo "  setup     - Install Lima on macOS (one-time)"
	@echo "  create    - Create the sandbox VM"
	@echo ""
	@echo "Daily Usage:"
	@echo "  start     - Start OpenClaw in the VM"
	@echo "  proxy     - Start Caddy proxy (enables https://openclaw.dev)"
	@echo "  stop      - Stop OpenClaw (keep VM running)"
	@echo "  proxy-stop - Stop Caddy proxy"
	@echo "  shell     - Open a shell in the VM"
	@echo "  status    - Show VM status and ports"
	@echo ""
	@echo "VM Management:"
	@echo "  vm-start  - Start the VM (without OpenClaw)"
	@echo "  vm-stop   - Stop the VM entirely"
	@echo "  destroy   - Delete VM and ALL data"
	@echo ""
	@echo "Maintenance:"
	@echo "  update    - Update OpenClaw to latest version"
	@echo "  backup    - Create a VM snapshot"
	@echo "  snapshots - List all snapshots"
	@echo ""
	@echo "Quick Start:"
	@echo "  make setup && make create && make start"
	@echo ""
	@echo "Access via custom domain:"
	@echo "  make proxy   # then visit https://openclaw.dev"

# One-time setup - install Lima
setup:
	@chmod +x scripts/*.sh
	@./scripts/setup-host.sh

# Create the sandbox VM
create:
	@chmod +x scripts/*.sh
	@./scripts/create-vm.sh

# Start OpenClaw in the VM
start:
	@chmod +x scripts/*.sh
	@./scripts/start-openclaw.sh

# Stop OpenClaw (keep VM running)
stop:
	@chmod +x scripts/*.sh
	@./scripts/stop-openclaw.sh

# Open a shell in the VM
shell:
	@limactl shell openclaw

# Show VM status
status:
	@echo "=== VM Status ==="
	@limactl list 2>/dev/null || echo "Lima not installed"
	@echo ""
	@echo "=== Access URLs ==="
	@echo "If VM is running, OpenClaw is available at:"
	@echo "  http://localhost:18789"
	@echo "  https://openclaw.dev (if proxy is running)"

# Start Caddy reverse proxy
proxy:
	@chmod +x scripts/*.sh
	@./scripts/start-proxy.sh

# Stop Caddy reverse proxy
proxy-stop:
	@chmod +x scripts/*.sh
	@./scripts/stop-proxy.sh

# Destroy VM and all data
destroy:
	@chmod +x scripts/*.sh
	@./scripts/destroy-vm.sh

# Stop the VM entirely
vm-stop:
	@echo "Stopping VM..."
	@limactl stop openclaw 2>/dev/null || echo "VM not running"

# Start the VM (without starting OpenClaw)
vm-start:
	@echo "Starting VM..."
	@limactl start openclaw

# Update OpenClaw to latest version
update:
	@echo "Updating OpenClaw in VM..."
	@limactl shell openclaw -- npm update -g openclaw@latest
	@echo "Done. Restart OpenClaw to use the new version."

# Create a VM snapshot for backup
backup:
	@echo "Creating VM snapshot..."
	@limactl snapshot create openclaw --tag backup-$$(date +%Y%m%d-%H%M%S)
	@echo "Snapshot created."

# List all snapshots
snapshots:
	@limactl snapshot list openclaw 2>/dev/null || echo "No snapshots or VM doesn't exist"

# Run onboarding inside VM (after VM is created)
onboard:
	@echo "Running OpenClaw onboarding..."
	@limactl shell openclaw -- openclaw onboard

# Check isolation is working
verify-isolation:
	@echo "=== Verifying Isolation ==="
	@echo ""
	@echo "Attempting to access Mac files from VM..."
	@if limactl shell openclaw -- ls /Users 2>/dev/null; then \
		echo "WARNING: VM can access /Users"; \
	else \
		echo "PASS: VM cannot access Mac files"; \
	fi
	@echo ""
	@echo "Checking port bindings..."
	@netstat -an 2>/dev/null | grep -E "18789|18790" || echo "Ports not in use (VM may not be running)"
