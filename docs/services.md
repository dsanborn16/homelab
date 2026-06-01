# Services

26+ self-hosted services across 10 LXC containers and 2 VMs on Proxmox VE. Grouped by function below.

---

## Media Automation

A fully automated media pipeline running inside a dedicated LXC container with Docker Compose:

- **Gluetun** — ProtonVPN WireGuard gateway with kill-switch; all download traffic routes through it
- **qBittorrent v5** — torrent client inside the VPN network namespace
- **qb-port-sync** — syncs Gluetun's NAT-PMP forwarded port to qBittorrent's listen port automatically
- **Prowlarr** — aggregates indexers; single place to manage all sources for Sonarr and Radarr
- **Sonarr** — TV library management: monitors, grabs, renames, and imports new episodes
- **Radarr** — same for movies
- **Recyclarr** — syncs TRaSH-guide quality profiles to Sonarr and Radarr on a schedule
- **FlareSolverr** — Cloudflare challenge bypass for indexers that need it
- **Bazarr** — subtitle automation synced to both Sonarr and Radarr
- **Jellyseerr** — Plex-integrated request portal for family members
- **Tautulli** — Plex activity monitoring and analytics
- **cross-seed** — cross-seeding automation
- **Watchtower** — automated Docker image updates

Hardlinks connect the download path to the Plex media path — no storage duplication between download client and media server.

---

## Audiobooks

- **Audiobookshelf** — audiobook server with streaming player
- **ReadMeABook** — audiobook request UI + automation (integrates Prowlarr, qBittorrent, and ABS natively; handles M4B chapter merging)
- **Readarr** — legacy audiobook automation, running in parallel during ReadMeABook validation

---

## Media Server

**Plex Media Server** with NVENC hardware transcode. Library lives on the ZFS media pool. Family members access via Jellyseerr for requests and Plex native apps for playback.

**MediaSite** — custom Python/gunicorn media indexer (v1.1) running alongside Plex.

---

## Photos

**Immich** — self-hosted Google Photos replacement. 193,933 photos + 3,156 videos, 2007–2026. GPU ML active for face recognition and CLIP semantic search. ML inference cache on NVMe for performance.

---

## Music

- **Navidrome** — Subsonic-compatible music server; accessible from any Subsonic client
- **Maloja** — Last.fm-compatible scrobbler; full listening history, charts, and statistics
- **SpotiFLAC** — Spotify-to-FLAC acquisition pipeline

---

## Home Automation

- **Home Assistant OS** — primary automation hub (VM for full add-on support)
- **go2rtc** — camera stream relay with NVENC hardware transcode; HA consumes the streams

---

## Infrastructure

- **Authentik** — SSO/identity provider; OIDC + forward auth for all public services
- **Nginx Proxy Manager** — public reverse proxy on Oracle Cloud VPS
- **Prometheus + Grafana** — metrics and dashboards
- **Scrutiny** — SMART drive health monitoring
- **Syncthing** — Obsidian vault sync between server and workstation
- **Samba** — SMB file shares from the media pool
- **Homepage** — unified dashboard, 26 services, 14 live API widgets across 5 tabs
- **Tailscale / WireGuard** — mesh VPN and site-to-site tunnel

---

## Other

- **Minecraft Java** — survival server running Temurin 25 JDK with Aikar's JVM flags
- **Obedience** — Node.js app exposed via Cloudflare Tunnel with Google OAuth
- **Howelllabs Job Watcher** — hourly cron on the hypervisor host; Discord webhook alert for new EE job postings
