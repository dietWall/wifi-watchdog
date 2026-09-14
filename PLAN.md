# WiFi Watchdog - Project Plan

## Overview
A Debian service that maintains an active WiFi connection by periodically checking the interface and resetting it when disconnected. This addresses intermittent WiFi disconnections caused by driver issues.

## Architecture

### Component 1: Watchdog Script (`/usr/local/bin/wifi-watchdog.sh`)
A bash daemon that runs continuously in a loop:
1. **Check connection status** using `iwgetid -r <interface>` — returns the ESSID if connected, exits non-zero if not
2. **If connected**: sleep 60 seconds, then re-check
3. **If not connected**: reset the interface (`ip link set <iface> down/up`) and reconnect via `nmcli`
4. Log actions to syslog only when something is wrong
5. Accepts `-c CONFIG_FILE` argument to specify the configuration file

### Component 2: Systemd Service (`/etc/systemd/system/wifi-watchdog.service`)
- **Type**: `simple` — runs the script as a long-lived daemon
- **Restart**: `always` — ensures the service recovers if it crashes
- **ExecStart**: `/usr/local/bin/wifi-watchdog.sh -c /etc/default/wifi-watchdog`
- `%i` placeholder replaced with config file path during packaging

### Component 3: Debian Packaging
- `debian/control` — package metadata and dependencies
- `debian/postinst` — enables and starts the service after install
- `debian/prerm` — stops and disables the service before removal
- `Makefile` — builds the `.deb` package using `dpkg-deb`

### Component 4: GitHub Actions CI/CD (`.github/workflows/`)
- **build.yml** — builds `.deb` and uploads artifact on push to all branches
- **release.yml** — creates GitHub release with `.deb` on tag push (`v*`)

## Connection Management Strategy

| Step | Action | Command |
|------|--------|---------|
| Check | Verify WiFi is associated | `iwgetid -r <iface>` |
| Reset | Bring interface down/up | `ip link set <iface> down && ip link set <iface> up` |
| Reconnect | Trigger NetworkManager | `nmcli device reconnect <iface>` |
| Sleep | Wait before next cycle | `sleep 60` |

## Configuration
Config file at `/etc/default/wifi-watchdog`:
- `WATCHDOG_INTERFACE` — WiFi interface name (default: `wlan0`)
- `WATCHDOG_INTERVAL` — Sleep seconds in the check loop (default: `60`)

## Files
```
wifi-watchdog/
├── PLAN.md
├── README.md
├── wifi-watchdog.sh          # Main daemon script (accepts -c CONFIG_FILE)
├── wifi-watchdog.service     # systemd unit (%i replaced during build)
├── Makefile                  # Build .deb package
├── .gitignore
├── .github/
│   └── workflows/
│       ├── build.yml         # Build on push
│       └── release.yml       # Release on tag
├── etc/
│   └── default/
│       └── wifi-watchdog     # Config file
└── debian/
    ├── control
    ├── postinst
    └── prerm
```

## Dependencies
- `network-manager` (provides `nmcli`)
- `wireless-tools` (provides `iwgetid`)
- `iproute2` (provides `ip`) — usually pre-installed

## Further Steps
1. Build `.deb` package: `make deb`
2. Install on target machine: `sudo dpkg -i wifi-watchdog_1.0.0_all.deb`
3. Verify service: `systemctl status wifi-watchdog && journalctl -u wifi-watchdog -f`
