# Services

Full inventory of all running services across the homelab. All containers are LXC on Proxmox VE unless noted.

---

## Container Map

| VMID | Hostname | IP | Key Services |
|------|----------|----|-------------|
| VM102 | haos | `192.168.50.111` | Home Assistant OS 17.2 |
| CT106 | obedience | `192.168.50.106` | Node.js app + Cloudflare Tunnel + Glances |
| CT140 | music-stack | `192.168.50.140` | 16-container music ecosystem |
| CT150 | plex | `192.168.50.150` | Plex 1.43.1 + MediaSite |
| CT300 | immich | `192.168.50.110` | Immich photo library |
| CT304 | authentik | `192.168.50.112` | Authentik SSO |
| CT305 | minecraft | `192.168.50.105` | Minecraft Java survival server |
| CT310 | monitoring | `192.168.50.198` | Prometheus + Grafana + Scrutiny |
| CT311 | go2rtc | `192.168.50.208` | Camera streams + NVENC transcode |
| CT315 | arr-stack | `192.168.50.248` | 18 Docker containers (media automation) |

---

## Media Automation — CT315

CT315 runs 18 Docker Compose containers. All download traffic is routed through Gluetun (ProtonVPN WireGuard kill-switch).

```
CT315 (192.168.50.248)
├── gluetun          ProtonVPN WireGuard — VPN gateway + kill-switch
├── qbittorrent      v5.2.1 — torrent client (network namespace: gluetun)
├── qb-port-sync     Syncs Gluetun forwarded port → qBit listen port
├── sonarr           TV show management (:8989)
├── radarr           Movie management (:7878)
├── prowlarr         Indexer aggregator (:9696)
├── bazarr           Subtitle automation (:6767)
├── jellyseerr       Request portal (:5055)
├── tautulli         Plex analytics (:8181)
├── recyclarr        TRaSH guide quality profiles → Sonarr/Radarr sync
├── cross-seed       Cross-seeding automation
├── flareSolverr     Cloudflare challenge bypass for indexers
├── readmeabook      Audiobook request + automation UI (:3031)
├── readarr          Audiobook automation (:8787) — parallel validation
├── audiobookshelf   Audiobook server + player (:13378)
├── bookworm         Audiobook request SPA (:8484) — decommission pending
├── homepage         Unified dashboard (:3000)
└── watchtower       Automated container image updates
```

### Port Forwarding + VPN Watchdog

qBittorrent requires an active forwarded port to be connectable. ProtonVPN provides NAT-PMP port forwarding, but the port assignment can silently fail (token expiry, NAT-PMP refusal). Without detection, this results in stuck downloads and 0-byte connectivity for hours.

The VPN watchdog (`scripts/vpn-watchdog.sh`) runs every 5 min to detect `port=0` and auto-recover within ~10 min. See [Scripts](../scripts/).

---

## Media Server — CT150

| Service | Port | Notes |
|---------|------|-------|
| Plex Media Server 1.43.1 | `:32400` | NVIDIA NVENC hardware transcode |
| MediaSite | `:5000` | Custom Python/gunicorn media indexer (v1.1) |

Plex library lives on `datapool` (`/datapool/media`), hardlinked from the download path — no data duplication between download client and media server.

---

## Photos — CT300

| Service | Port | Notes |
|---------|------|-------|
| Immich | `:2283` | 193,933 photos + 3,156 videos |

GPU ML features active: face recognition, CLIP semantic search, smart albums. Machine learning cache on `nvme-fast` for performance. Library spans 2007–2026 across multiple family members.

---

## Music — CT140

CT140 runs 16 containers for a complete self-hosted music ecosystem:

| Service | Port | Role |
|---------|------|------|
| Navidrome | `:4533` | Subsonic-compatible music server |
| Maloja | `:42010` | Last.fm-compatible scrobbling + statistics |
| SpotiFLAC | — | Spotify → FLAC acquisition via Deemix |

Music library: FLAC files on `datapool/music`, accessible via Navidrome's Subsonic API for any compatible client (Symfonium, Substreamer, etc.). Maloja has been scrobbling since 2025 and provides full listening history, top artists, and charts at `stats.donovanshome.systems`.

---

## Monitoring — CT310

| Service | Port | Role |
|---------|------|------|
| Prometheus | `:9090` | Metrics collection |
| Grafana | `:3000` | Dashboards |
| Scrutiny | — | SMART drive health aggregator |
| InfluxDB | — | Long-term metrics storage |
| PVE Exporter | — | Proxmox cluster metrics |
| node_exporter | `:9100` | Host-level metrics (runs per host) |

Scrutiny polls all 6 drives for SMART data and runs pass/fail analysis against known drive models. Results visible in Grafana and via Scrutiny's own UI.

---

## Identity / Auth — CT304

Authentik running as the homelab SSO provider:

- **OIDC provider**: issues tokens for services that support native OAuth2/OIDC
- **Forward auth**: Nginx Proxy Manager checks Authentik before proxying to 5 arr-stack services
- **Embedded outpost**: runs inside CT304, handles the forward auth endpoint
- **Providers configured**: `homeha`, `sonarr`, `radarr`, `prowlarr`, `bazarr`, `tautulli` (jellyseerr excluded — uses Plex OAuth)

---

## Home Automation — VM102

Home Assistant OS 17.2 in a Proxmox VM (bare-metal-style HAOS install for full add-on support):

- 306 entities across TP-Link, Nanoleaf, Chromecast, ASUS, Apple, climate sensors, cameras
- Custom Lovelace dashboard with 7 views
- Camera integration via go2rtc (CT311) — NVENC hardware transcode for low-latency streams
- Exposed publicly via SSH reverse tunnel → `ha.donovanshome.systems` (Hampton instance)

---

## Camera Streams — CT311

go2rtc handles camera relay and transcoding:

- 2× Tapo cameras (RTSP streams → go2rtc)
- NVENC hardware encoding for HLS/WebRTC output
- Home Assistant consumes the go2rtc streams directly

---

## Other Services

| Service | Container | Notes |
|---------|-----------|-------|
| Syncthing | PVE host | Vault sync PC ↔ R530 |
| Samba | PVE host | SMB file shares from datapool |
| node_exporter | PVE host | Prometheus host metrics |
| Minecraft Java | CT305 | Survival server, Temurin 25 JDK, Aikar's JVM flags |
| Obedience | CT106 | Node.js app at `obedience.donovanshome.systems`, Google OAuth via Cloudflare Tunnel |
| Howelllabs Watcher | PVE host cron | Hourly job-board check → Discord webhook |
| Homepage | CT315 | Unified dashboard, 26 services, 14 live API widgets, 5 tabs |
| Watchtower | CT315 | Automated Docker image updates |
