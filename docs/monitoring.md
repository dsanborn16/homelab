# Monitoring

---

## Stack

- **Prometheus** — metrics collection from Proxmox cluster, all containers, and host-level exporters
- **Grafana** — dashboards for cluster health, per-container CPU/RAM/network, ZFS pool status
- **Scrutiny** — SMART drive health aggregation with per-device pass/fail thresholds
- **PVE Exporter** — Proxmox-native metrics (VM/CT status, resource usage, storage)
- **node_exporter** — OS-level metrics running on each host
- **InfluxDB** — long-term metrics retention

---

## What's Monitored

**Proxmox cluster:**
- Per-container and per-VM CPU, memory, disk I/O, and network
- ZFS pool health (used/free/status)
- Node-level resource usage and uptime

**Drive health:**
Scrutiny polls all drives for SMART attributes and runs analysis against known device-specific failure thresholds. It caught the currently-critical drive (215 grown defects) before any visible symptoms.

**Homepage dashboard:**
A second surface aggregating live API data from 14 services — Proxmox cluster status, Immich photo counts, Scrutiny drive health, Sonarr/Radarr queue depth, active Plex streams, pending Jellyseerr requests, Navidrome streams. 5 tabs covering Media, Music, Photos, Infrastructure, and Gaming.

---

## Alerting

Currently dashboard-driven — no automated alerting configured. This is an identified gap. Planned:
- Scrutiny webhook alerts for drive SMART failures
- Prometheus Alertmanager → Discord for container-down events
- Uptime Kuma for external service availability (Phase 4)
