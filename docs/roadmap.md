# Roadmap

5-phase plan to build out the homelab into a full self-hosted platform for ~15 users, replacing commercial cloud services and targeting ~335 TiB total storage capacity.

---

## Vision

Replace: Google Photos, Spotify/Apple Music, Plex Pass, cloud backup, password manager (Bitwarden), and remote access VPN (commercial) — all for family use.

---

## Phases

### Phase 1 — Stability ($65, Now)

- [ ] Replace `sde` (bay 4) — 215 grown defects, 10 uncorrected errors. Highest risk drive, needs to go before the 5th drive attach completes
- [ ] Migrate `rpool` to 500 GB SATA SSD on onboard AHCI — frees up 2 SAS bays (0+1) for future high-density drives
- [ ] Verify ReadMeABook end-to-end, decommission Readarr + Bookworm

### Phase 2 — Storage Expansion (~$2,400, 1–3 months)

- [ ] 8× 8 TB SAS/SATA drives → new RAIDZ1 group in `datapool` (+~51 TiB)
- [ ] Sun NDS-4600 60-bay JBOD (~$1,300–1,400 on eBay) — 60× 3 TB drives included
  - As-is: ~109 TiB usable in RAIDZ2 groups
  - Long-term: replace dead 3 TB drives with 8 TB → grows to ~291 TiB
- [ ] LSI 9207-8e external SAS HBA (~$50) to connect NDS-4600
- [ ] APC UPS — battery backup for server + JBOD

### Phase 3 — Compute Upgrade (~$750, 2–4 months)

- [ ] RTX A2000 12 GB — replaces Quadro P1000; more VRAM for Immich ML, larger batch inference, game streaming (Sunshine/Moonlight)
- [ ] 2× 32 GB ECC DIMMs — expand RAM from 64→128 GB (fill channel B on the E5-2680 v4)

### Phase 4 — Services ($0, 3–6 months)

- [ ] **Vaultwarden** (P1) — self-hosted Bitwarden-compatible password manager
- [ ] **Headscale** (P1) — self-hosted Tailscale control plane (replace commercial Tailscale)
- [ ] **Scrutiny alerts** (P1) — email/webhook on drive health failures
- [ ] **Nextcloud** (P2) — file sync + collaboration (Google Drive replacement)
- [ ] **Kavita** (P2) — self-hosted comic/ebook library
- [ ] **Lidarr** (P2) — music library automation
- [ ] **Uptime Kuma** (P2) — external service monitoring + status page
- [ ] **TubeArchivist** (P3) — YouTube channel archival

### Phase 5 — Infrastructure Upgrade (~$2,000, 6–12 months)

- [ ] R530 `datapool` → RAIDZ2 (double parity) for ~44 TiB usable with better fault tolerance
- [ ] 10 GbE networking (R530 NIC + UniFi switch upgrade)
- [ ] Second server for redundancy / compute separation
- [ ] OPNsense firewall to replace Xfinity gateway

---

## Combined Storage Target

| Source | Capacity | Type |
|--------|----------|------|
| R530 (Phase 5) | ~44 TiB | RAIDZ2 |
| NDS-4600 at 8 TB (Phase 2) | ~291 TiB | RAIDZ2 groups |
| **Total** | **~335 TiB** | |

At ~335 TiB, this covers: full family photo + video library at original quality, complete music collection in FLAC, full TV/movie library, game backups, VM storage, and significant headroom for growth.

---

## Current Status

As of 2026-06-01:
- Phase 1: In progress (RAIDZ expansion running, sde replacement queued)
- Phase 2: Researching NDS-4600 listings on eBay
- Phases 3–5: Planned
