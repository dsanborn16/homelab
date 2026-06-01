# Roadmap

5-phase plan to build out the homelab into a full self-hosted platform for ~15 users, replacing all remaining commercial services and targeting ~335 TiB total storage capacity.

---

## Vision

Replace: Google Photos, Spotify/Apple Music, cloud backup, password manager, remote access VPN, and file sync — all self-hosted, for family use.

---

## Phases

### Phase 1 — Stability (~$65)

- Replace the failing drive (215 grown defects, 10 uncorrected errors) — top priority before pool expansion is complete
- Migrate the OS pool to a SATA SSD, freeing up drive bays for high-density drives
- Complete ReadMeABook validation and decommission the legacy audiobook stack

### Phase 2 — Storage Expansion (~$2,400, 1–3 months)

- 8× 8 TB drives → new RAIDZ1 group in the media pool (+~51 TiB)
- Sun NDS-4600 60-bay JBOD — 60 drives included; ~109 TiB usable as-is, grows as drives are upgraded to 8 TB over time
- External SAS HBA for JBOD connectivity
- UPS for battery backup

### Phase 3 — Compute Upgrade (~$750, 2–4 months)

- RTX A2000 12 GB — replace Quadro P1000; more VRAM for Immich ML inference and future workloads
- Expand RAM from 64→128 GB

### Phase 4 — Services ($0, 3–6 months)

| Service | Priority | Replaces |
|---------|----------|---------|
| Vaultwarden | High | Commercial password manager |
| Headscale | High | Commercial Tailscale control plane |
| Nextcloud | Medium | Google Drive / file sync |
| Kavita | Medium | Comic/ebook library |
| Lidarr | Medium | Music library automation |
| Uptime Kuma | Medium | External service monitoring |
| TubeArchivist | Low | YouTube archival |

### Phase 5 — Infrastructure (~$2,000, 6–12 months)

- Convert media pool to RAIDZ2 (double-parity) for better fault tolerance at scale
- 10 GbE networking (server NIC + switch upgrade)
- Second server for redundancy and compute separation
- OPNsense to replace the ISP gateway

---

## Storage Target

| Source | Capacity |
|--------|----------|
| R530 (RAIDZ2) | ~44 TiB |
| NDS-4600 at 8 TB drives | ~291 TiB |
| **Total** | **~335 TiB** |
