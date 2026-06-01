# Scripts

Custom scripts for homelab automation and reliability.

---

## vpn-watchdog.sh

**Purpose:** Detect and auto-recover silent Gluetun port-forward failures.

**Background:** ProtonVPN NAT-PMP can refuse to renew port-forward assignments on token expiry. When this happens, Gluetun's forwarded port silently drops to `0` — no error is logged, qBittorrent keeps running, but it stops receiving inbound connections. This was discovered after a 36-hour undetected outage.

**How it works:**
1. Cron runs the script every 5 minutes on CT315
2. Script polls Gluetun's internal REST API for the current forwarded port
3. Two consecutive `port=0` readings → recovery sequence:
   - Restart `gluetun`
   - Wait for VPN reconnect (~15s)
   - Restart `qbittorrent` + `qb-port-sync`
   - Verify new port is non-zero
4. All events logged to `/var/log/vpn-watchdog.log`

**Result:** Max undetected downtime reduced from 36+ hours to ~10 minutes.

**Install:**
```bash
cp vpn-watchdog.sh /usr/local/bin/vpn-watchdog.sh
chmod +x /usr/local/bin/vpn-watchdog.sh

# Add to crontab (as root in CT315):
echo "*/5 * * * * root /usr/local/bin/vpn-watchdog.sh" > /etc/cron.d/vpn-watchdog
```

---

## howelllabs-watcher (cron)

**Purpose:** Monitor Howelllabs Engineering job postings and alert on new listings.

**Implementation:** Hourly cron on the PVE host. Fetches the job listings page, compares against a cached last-seen state, and fires a Discord webhook if new EE postings are found.

**Dependencies:** `curl`, `jq` — no external runtime required.
