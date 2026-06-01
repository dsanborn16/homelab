# Monitoring

All monitoring infrastructure runs in CT310 (`192.168.50.198`).

---

## Stack

| Component | Role |
|-----------|------|
| **Prometheus** | Metrics collection and storage |
| **Grafana** | Dashboards and visualization |
| **Scrutiny** | SMART drive health monitoring |
| **InfluxDB** | Long-term metrics retention |
| **PVE Exporter** | Proxmox cluster metrics (VMs, CTs, storage, CPU) |
| **node_exporter** | Host-level OS metrics (per host) |

---

## Metrics Coverage

### Proxmox Cluster (via PVE Exporter)
- Per-VM/CT CPU usage, memory, disk I/O, network
- ZFS pool status (used/free/health)
- Node-level CPU, memory, uptime
- API token `root@pam!homepage` used for read-only scraping

### Host Level (via node_exporter)
- CPU, memory, disk, network interfaces
- Load average, filesystem usage
- Running on PVE host (`192.168.50.107:9100`)

### Drive Health (via Scrutiny)
- Polls all 6 drives for SMART data on a schedule
- Runs failure analysis against device-specific thresholds
- Flagged `sde` (bay 4) as critical: 215 grown defects, 10 uncorrected read errors
- Results surfaced in Grafana and Scrutiny's web UI

---

## Homepage Dashboard

A second monitoring surface: Homepage dashboard in CT315 aggregates live API data from:

| Widget | Data |
|--------|------|
| Proxmox | 1/2 VMs running, 9/12 LXC running, 5% CPU, 37% MEM |
| Immich | 193,933 photos, 3,156 videos |
| Scrutiny | 6/6 drives healthy |
| Sonarr | Queue depth, wanted, upcoming |
| Radarr | Queue depth, wanted |
| Prowlarr | Active indexers |
| Tautulli | Active Plex streams |
| Jellyseerr | Pending requests |
| Navidrome | Active streams |

5 tabs: Media, Music, Photos, Infrastructure, Gaming. 14 live API widgets total.

---

## Alerting

Currently no automated alerting configured — monitoring is dashboard-driven (manual review).

Planned:
- Scrutiny email/webhook alerts for drive failures
- Prometheus Alertmanager → Discord webhook for node-down events
- Uptime Kuma for external service availability monitoring (Phase 4)
