# Hardware

## Primary Server — Dell PowerEdge R530

Enterprise 2U rack server, acquired used and repurposed as a home server.

### Specs

| Component | Detail |
|-----------|--------|
| **CPU** | Intel Xeon E5-2680 v4 (Broadwell-EP) |
| | 14 cores / 28 threads · 2.4 GHz base / 3.3 GHz boost |
| **RAM** | 64 GB DDR4 ECC RDIMM (8× 8 GB) |
| | Channel B empty → expandable to 128 GB |
| **GPU** | NVIDIA Quadro P1000 4 GB (PCIe slot) |
| **Storage** | See [Storage docs](storage.md) |
| **NICs** | Dual onboard 1 GbE (Broadcom) |
| **Remote Mgmt** | Dell iDRAC 8 Express — `192.168.50.50` |
| **Expansion** | 10 empty onboard AHCI ports (ata1–ata10) for future SATA SSDs |
| **OS** | Proxmox VE 9.1.7 · kernel 6.14.11-6-pve |
| **Idle Power** | ~98 W |
| **CPU Temp** | 36°C package, 19°C inlet at idle |

### iDRAC / Out-of-Band Management

Dell iDRAC 8 provides full out-of-band management:
- Virtual KVM console (no monitor needed)
- IPMI power control (remote power cycle, graceful shutdown)
- Hardware sensor monitoring (temps, fan speeds, PSU status)
- SMART drive data visible at hardware level, independent of OS
- Used for initial Proxmox installation and emergency recovery

### GPU Passthrough

The Quadro P1000 is used for hardware-accelerated encoding/decoding across multiple containers simultaneously:

| Container | Use |
|-----------|-----|
| CT150 (Plex) | NVENC video transcode |
| CT300 (Immich) | ML inference — face recognition, CLIP embeddings |
| CT140 (Music) | Audio processing |
| CT311 (go2rtc) | NVENC camera stream transcode |

GPU passthrough via VFIO with `nvidia-persistenced` running on the PVE host for persistence across container restarts. All four containers can use NVENC concurrently without conflicts.

---

## Edge Node — Oracle Cloud VPS

Oracle Cloud Always Free ARM instance. Runs permanently as the public edge.

| | |
|---|---|
| **IP** | `141.148.70.220` |
| **Role** | Nginx Proxy Manager, WireGuard server, SSH tunnel endpoint |
| **Cost** | $0 (Always Free tier) |

---

## Networking Hardware

- **Ubiquiti UniFi** — managed switch + APs
- Handles VLAN tagging for Server VLAN (`192.168.50.0/24`) and IoT VLAN (`192.168.20.0/24`)
- UniFi controller at `10.0.0.84`

---

## Hampton Site

- **Raspberry Pi 4** running Home Assistant OS — secondary HA instance
- Physically at a different location (Hampton) on a separate ISP connection (`71.235.120.164`)
- Connected to the Maine network via Tailscale; exposes HA to public via SSH reverse tunnel → VPS
- Configured as Tailscale exit node

---

## Planned Upgrades

| Item | Purpose | Phase |
|------|---------|-------|
| 500 GB SATA SSD | `rpool` mirror replacement (free up SAS bays 0+1) | Phase 1 |
| 8× 8 TB SAS/SATA | Expand `datapool` (new RAIDZ1 group) | Phase 2 |
| Sun NDS-4600 JBOD | 60-bay expansion chassis (~109 TiB as-is) | Phase 2 |
| LSI 9207-8e HBA | External SAS for NDS-4600 | Phase 2 |
| APC UPS | Battery backup for R530 + NDS-4600 | Phase 2 |
| RTX A2000 12 GB | Replace Quadro P1000 — more VRAM for ML workloads | Phase 3 |
| 2× 32 GB ECC DIMMs | 64→128 GB RAM (fill channel B) | Phase 3 |
