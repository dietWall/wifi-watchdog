#!/usr/bin/env bash
set -euo pipefail

CONFIG_FILE="${1:-}"

if [ -z "$CONFIG_FILE" ]; then
    echo "Usage: $0 -c /path/to/config" >&2
    exit 1
fi

if [ ! -f "$CONFIG_FILE" ]; then
    echo "Config file not found: $CONFIG_FILE" >&2
    exit 1
fi

source "$CONFIG_FILE"
INTERFACE="${WATCHDOG_INTERFACE:-wlan0}"
INTERVAL="${WATCHDOG_INTERVAL:-60}"

log() {
    logger -t "wifi-watchdog" "$@"
}

is_connected() {
    iw dev "$INTERFACE" link 2>/dev/null | grep -q 'SSID'
}

reset_and_reconnect() {
    ip link set "$INTERFACE" down
    sleep 2
    ip link set "$INTERFACE" up
    sleep 3
    nmcli device reconnect "$INTERFACE" 2>/dev/null || true
    log "Interface $INTERFACE reset and reconnected."
}

log "WiFi Watchdog started on interface $INTERFACE"

while true; do
    if ! is_connected; then
        log "WiFi not connected. Resetting interface $INTERFACE..."
        reset_and_reconnect
    fi
    sleep "$INTERVAL"
done
