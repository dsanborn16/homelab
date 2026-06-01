# Storage

All storage on the R530 is managed through ZFS (native Proxmox integration).

---

## Pools

### Media and Data Pool — ZFS RAIDZ1

- Single-parity redundancy across 4 SAS drives (~7.3 TiB usable)
- Contains: media library, photos, music, audiobooks, Obsidian vault, SMB file shares
- Currently ~80% utilized — expansion in progress

### OS and VM Pool — ZFS Mirror

- 2-way mirror across 2 SAS drives
- LZ4 compression: 2.11× ratio
- Contains: Proxmox OS, VM disk images, container root filesystems

### NVMe Scratch

- 512 GB NVMe, ext4
- Contains: Plex transcode scratch, Immich ML cache, Minecraft world, Proxmox dump/templates

---

## Why ZFS

- **RAIDZ eliminates the RAID-5 write hole** — ZFS write atomicity means no corruption window during a power failure
- **Per-block checksumming** catches silent data corruption (bit rot) that RAID controllers and LVM miss entirely
- **Online RAIDZ expansion** — actively using OpenZFS 2.2's RAIDZ expansion feature to add a 5th drive without downtime or a resilver-and-recreate
- **Compression** is transparent and reduces actual I/O — 2.11× ratio on the OS pool

---

## Drive Health

Scrutiny monitors all drives via SMART, running pass/fail analysis against device-specific thresholds. Current status:

| Health | Count |
|--------|-------|
| Healthy | 3 drives |
| Watch | 2 drives (elevated reallocated sectors) |
| Replace | 1 drive (215 grown defects, 10 uncorrected read errors) — queued for replacement after RAIDZ expansion |

The failing drive represents a real single-point-of-failure risk on a RAIDZ1 array. Replacement is the top infrastructure priority.

---

## File Shares

Samba shares from the media pool are used by Home Assistant, other containers, and workstations on the LAN. Syncthing keeps the Obsidian wiki in sync between the server and the Windows workstation.

---

## Backup Status

No automated offsite backup currently configured — identified gap. Planned:
- ZFS snapshots via cron
- Offsite copy for irreplaceable data (photos) via Backblaze B2 or a second server (Phase 5)
