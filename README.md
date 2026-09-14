# WiFi Watchdog

A lightweight Debian service that maintains an active WiFi connection by periodically checking the interface and resetting it when disconnected.

## Problem
WiFi interfaces may disconnect due to driver issues, requiring manual intervention.

## Solution
This service runs as a daemon, checking every minute whether the WiFi interface is connected. If it is not connected, it resets the interface and reconnects to restore the connection.

## Requirements
- Linux system with systemd
- NetworkManager
- `wireless-tools` (for `iwgetid`)
- `iproute2` (for `ip link`)

## Installation
```bash
make deb
sudo dpkg -i wifi-watchdog_1.0.0_all.deb
```

The `%i` placeholder in the systemd service is replaced with `/etc/default/wifi-watchdog` during package build.

## Configuration
Edit `/etc/default/wifi-watchdog`:
- `WATCHDOG_INTERFACE` — WiFi interface name (default: `wlan0`)
- `WATCHDOG_INTERVAL` — Sleep interval in seconds (default: `60`)

## Usage
```bash
sudo systemctl status wifi-watchdog
sudo journalctl -u wifi-watchdog -f
```

The script accepts `-c CONFIG_FILE` to specify the configuration file path.

## Building the .deb package
```bash
make deb
```
