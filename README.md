# OpenClaw Sandbox VM

Run [OpenClaw](https://github.com/openclaw/openclaw) in a completely isolated virtual machine on macOS, protecting your local files and data.

## Security Model

```
┌─────────────────────────────────────────────────────────────┐
│                        macOS Host                           │
│                                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │                 Lima VM (Ubuntu 24.04)               │   │
│  │                                                      │   │
│  │  ┌──────────────────────────────────────────────┐   │   │
│  │  │              OpenClaw Process                 │   │   │
│  │  │                                               │   │   │
│  │  │  Ports: 18789, 18790                         │   │   │
│  │  │  Data:  /home/openclaw/.openclaw/workspace   │   │   │
│  │  └──────────────────────────────────────────────┘   │   │
│  │                                                      │   │
│  │  NO ACCESS to /Users/* or any Mac files             │   │
│  └─────────────────────────────────────────────────────┘   │
│                           │                                 │
│                    Port Forwarding                          │
│                    (localhost only)                         │
│                           │                                 │
│                    localhost:18789                          │
│                    localhost:18790                          │
└─────────────────────────────────────────────────────────────┘
```

This setup provides:

- **Complete filesystem isolation**: The VM has NO access to your Mac's files
- **Network isolation**: OpenClaw is only accessible via localhost (127.0.0.1)
- **Dedicated user**: OpenClaw runs as a non-root user inside the VM
- **Ephemeral by design**: Easy to destroy and recreate from scratch

## Requirements

- macOS (Apple Silicon or Intel)
- Homebrew (will be installed if missing)
- ~10GB free disk space
- 8GB RAM recommended

## Quick Start

```bash
# Clone this repository
git clone <your-repo-url>
cd openclaw-sandbox

# One-time setup: Install Lima
make setup

# Create the sandbox VM (takes 5-10 minutes first time)
make create

# Start OpenClaw
make start
```

OpenClaw will be available at:
- http://localhost:18789
- http://localhost:18790

## Commands

| Command | Description |
|---------|-------------|
| `make setup` | Install Lima on macOS (one-time) |
| `make create` | Create the sandbox VM |
| `make start` | Start OpenClaw in the VM |
| `make stop` | Stop OpenClaw (keep VM running) |
| `make shell` | Open a shell in the VM |
| `make status` | Show VM status |
| `make destroy` | Delete VM and ALL data |
| `make update` | Update OpenClaw to latest version |
| `make backup` | Create a VM snapshot |
| `make verify-isolation` | Verify Mac files are inaccessible |

## Data Persistence

All OpenClaw data is stored INSIDE the VM at:
```
/home/openclaw/.openclaw/workspace
```

This data persists across VM restarts but is destroyed when you run `make destroy`.

### Backing Up Data

```bash
# Create a VM snapshot
make backup

# Or manually copy data out
limactl copy openclaw:/home/openclaw/.openclaw/workspace ./backup/
```

### Restoring Data

```bash
# Copy data into the VM
limactl copy ./backup/workspace openclaw:/home/openclaw/.openclaw/
```

## Customization

### Changing Resources

Edit `lima/openclaw.yaml`:

```yaml
cpus: 4        # Number of CPU cores
memory: "8GiB" # RAM allocation
disk: "50GiB"  # Disk size
```

Then recreate the VM:
```bash
make destroy
make create
```

## Troubleshooting

### VM won't start

```bash
# Check Lima status
limactl list

# Try stopping and starting
limactl stop openclaw
limactl start openclaw
```

### Port conflict

If ports 18789/18790 are in use, edit `lima/openclaw.yaml` to change `hostPort` values, then recreate the VM.

### OpenClaw not found

```bash
# Reinstall OpenClaw in the VM
make shell
npm install -g openclaw@latest
exit
```

### Reset everything

```bash
make destroy
make create
```

## How It Works

1. **Lima** creates a lightweight Linux VM using Apple's Virtualization.framework
2. The VM runs Ubuntu 24.04 with Node.js 22 pre-installed
3. OpenClaw is installed via npm inside the VM
4. Port forwarding exposes OpenClaw to localhost only
5. No host filesystems are mounted (complete isolation)

## Security Notes

- The VM has internet access (required for OpenClaw to function)
- Port forwarding only binds to 127.0.0.1 (not accessible from your network)
- The VM cannot access any Mac files by default
- Run `make destroy` to completely remove all traces

## File Structure

```
openclaw-sandbox/
├── README.md              # This file
├── Makefile               # Command shortcuts
├── lima/
│   └── openclaw.yaml      # VM configuration
└── scripts/
    ├── setup-host.sh      # Install Lima
    ├── create-vm.sh       # Create VM
    ├── start-openclaw.sh  # Start OpenClaw
    ├── stop-openclaw.sh   # Stop OpenClaw
    └── destroy-vm.sh      # Delete VM
```

## License

MIT
