# Storage

All storage on the R530 is managed through ZFS (native Proxmox ZFS integration).

---

## ZFS Pools

### `rpool` — OS and VM/Container Disks

| | |
|---|---|
| **Type** | 2-way mirror |
| **Drives** | 2× Seagate ST600MM0006 600 GB SAS 10K RPM |
| **Total** | 556 GB usable |
| **Used** | ~34% |
| **Compression** | LZ4 — 2.11× ratio |
| **Purpose** | Proxmox OS, VM disk images, CT root filesystems |

### `datapool` — Media and Data

| | |
|---|---|
| **Type** | RAIDZ1 (4+1 drives) |
| **Drives** | 4× Hitachi HUS724020ALS640 2 TB SAS 7.2K RPM |
| **Usable** | ~7.27 TiB (after parity + overhead) |
| **Used** | ~80% |
| **Purpose** | Media library, photos, music, audiobooks, obsidian vault, SMB shares |

**In-progress:** expanding to 5-drive RAIDZ1 by attaching a 6th bay drive (scsi-35000c500427abac3). ZFS RAIDZ expansion is a native ZFS feature (available since OpenZFS 2.2) — online, no data loss, no unmount required.

---

## NVMe Cache / Scratch

| | |
|---|---|
| **Device** | Samsung SM961 (MZVLW512HMJP) 512 GB NVMe |
| **Filesystem** | ext4 |
| **Total** | 469 GB |
| **Used** | ~38% |
| **Purpose** | Plex transcode scratch, Immich ML cache, Minecraft world, Proxmox dump/images/templates |

---

## Drive Health

All drives monitored by Scrutiny (SMART) with Grafana dashboards:

| Drive | Model | Size | Health | Grown Defects | Uncorrected |
|-------|-------|------|--------|---------------|-------------|
| sdc (bay 2) | Hitachi HUS724020ALS640 | 2 TB | ✅ Healthy | 0 | 0 |
| sdd (bay 3) | Hitachi HUS724020ALS640 | 2 TB | ⚠️ Watch | 56 | 2 |
| sde (bay 4) | Hitachi HUS724020ALS640 | 2 TB | 🔴 Replace | **215** | **10** |
| sdf (bay 5) | Hitachi HUS724020ALS640 | 2 TB | ⚠️ Watch | 3 | 2 |
| sdh (bay 6) | WD 2 TB | 2 TB | ✅ Healthy | 0 | 0 |
| NVMe | Samsung SM961 | 512 GB | ✅ Healthy | — | — |

`sde` is a known failure risk — 215 grown defects and 10 uncorrected read errors. Scheduled for replacement immediately after the RAIDZ expansion completes (replacing a RAIDZ1 member drive while online is a standard ZFS resilver operation).

---

## SMB Shares

Samba runs on the PVE host, sharing `datapool` sub-paths to the LAN:

| Share | Path |
|-------|------|
| `datapool` | `/datapool` |
| `photos` | `/datapool/photos` |
| `obsidian-vault` | `/datapool/obsidian-vault` |
| `homeassistant` | `/datapool` |
| `+ 5 photo sub-shares` | per-family-member photo archives |

---

## Syncthing

`/datapool/obsidian-vault` is kept in sync with `C:\Users\donov\Documents\Obsidian Vault` on the Windows workstation via Syncthing. Folder ID: `obsidian-vault`, both peers set to SendReceive. This is how the homelab wiki stays consistent across machines.

---

## Backup Strategy

No automated backup currently configured — identified as a gap. Planned:
- ZFS snapshots via `zfs-auto-snapshot` or custom cron
- Offsite copy for irreplaceable data (photos) — candidates: Backblaze B2, or a second server in Phase 5
- `rpool` is already mirrored (hardware redundancy), but not backed up offsite

---

## Roadmap (Storage)

| Phase | Action |
|-------|--------|
| 1 | Replace `sde` (215 defects) after RAIDZ expansion |
| 1 | Migrate `rpool` to 500 GB SATA SSD (free up 2 SAS bays) |
| 2 | Add 8× 8 TB drives → second RAIDZ1 group in `datapool` (~+51 TiB) |
| 2 | Sun NDS-4600 60-bay JBOD via LSI 9207-8e HBA (~+109 TiB) |
| 5 | Convert R530 pool to RAIDZ2 for double-parity (~44 TiB) |
