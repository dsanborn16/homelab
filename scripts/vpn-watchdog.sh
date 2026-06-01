#!/usr/bin/env bash
# vpn-watchdog.sh — Gluetun port-forward health watchdog
#
# Problem: ProtonVPN NAT-PMP silently fails to renew port-forward assignments,
# leaving the forwarded port stuck at 0 with no error in Gluetun logs or UI.
# qBittorrent continues running but becomes unconnectable.
#
# Fix: poll Gluetun's internal API every 5 minutes. Two consecutive port=0
# readings trigger an automatic recovery sequence.
#
# Cron (on CT315): */5 * * * * /usr/local/bin/vpn-watchdog.sh
# Max recovery time: ~10 minutes

set -euo pipefail

LOGFILE="/var/log/vpn-watchdog.log"
STATE_FILE="/tmp/vpn-watchdog-fail-count"
FAIL_THRESHOLD=2
GLUETUN_API="http://localhost:8000/v1/openvpn/portforwarded"

# -- Containers to restart on recovery
VPN_CONTAINER="gluetun"
DOWNLOAD_CONTAINERS=("qbittorrent" "qb-port-sync")

# -- VPN reconnect wait time (seconds) after restarting Gluetun
VPN_RECONNECT_WAIT=15

log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') [vpn-watchdog] $*" | tee -a "$LOGFILE"
}

get_forwarded_port() {
    curl -sf --max-time 5 "$GLUETUN_API" \
        | python3 -c "import sys, json; print(json.load(sys.stdin).get('port', 0))" \
        2>/dev/null || echo "0"
}

reset_fail_count() {
    echo "0" > "$STATE_FILE"
}

increment_fail_count() {
    local count
    count=$(cat "$STATE_FILE" 2>/dev/null || echo "0")
    count=$((count + 1))
    echo "$count" > "$STATE_FILE"
    echo "$count"
}

# ---- Main ----

port=$(get_forwarded_port)
log "Forwarded port: ${port}"

if [[ "$port" == "0" ]]; then
    count=$(increment_fail_count)
    log "Port=0 detected (consecutive failures: ${count}/${FAIL_THRESHOLD})"

    if [[ "$count" -ge "$FAIL_THRESHOLD" ]]; then
        log "ALERT: threshold reached — initiating recovery"
        reset_fail_count

        log "Restarting ${VPN_CONTAINER}..."
        docker restart "$VPN_CONTAINER"

        log "Waiting ${VPN_RECONNECT_WAIT}s for VPN to reconnect..."
        sleep "$VPN_RECONNECT_WAIT"

        log "Restarting download containers: ${DOWNLOAD_CONTAINERS[*]}"
        docker restart "${DOWNLOAD_CONTAINERS[@]}"
        sleep 5

        new_port=$(get_forwarded_port)
        if [[ "$new_port" != "0" ]]; then
            log "Recovery successful — new forwarded port: ${new_port}"
        else
            log "WARNING: port still 0 after recovery — manual investigation required"
        fi
    fi
else
    reset_fail_count
fi
