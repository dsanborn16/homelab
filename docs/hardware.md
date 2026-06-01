# Hardware

## Primary Server — Dell PowerEdge R530

Enterprise 2U rack server, acquired used and repurposed as a home server.

| Component | Detail |
|-----------|--------|
| **CPU** | Intel Xeon E5-2680 v4 · 14 cores / 28 threads · 2.4 GHz base / 3.3 GHz boost |
| **RAM** | 64 GB DDR4 ECC RDIMM · expandable to 128 GB |
| **GPU** | NVIDIA Quadro P1000 4 GB |
| **Remote mgmt** | Dell iDRAC 8 Express — out-of-band KVM, IPMI, hardware monitoring |
| **Hypervisor** | Proxmox VE 9.1.7 |
| **Idle power** | ~98 W |

### GPU Passthrough

The Quadro P1000 is passed through to four containers simultaneously via VFIO, with `nvidia-persistenced` running on the host for persistence across container restarts. Containers using hardware acceleration:

- **Plex** — NVENC video transcode
- **Immich** — GPU ML inference (face recognition, CLIP embeddings)
- **Music stack** — audio processing
- **Camera relay (go2rtc)** — NVENC stream transcode

All four share the GPU concurrently without conflicts.

### iDRAC

Out-of-band management independent of the OS. Used for initial Proxmox installation (virtual media mount), emergency recovery without physical access, and ongoing hardware sensor monitoring. SMART data visible at the hardware layer, separate from OS-level tools.

---

## Edge Node — Oracle Cloud VPS

Oracle Cloud Always Free ARM instance — cost $0, runs permanently as the public edge proxy (Nginx Proxy Manager + WireGuard server).

---

## Second Site — Raspberry Pi 4

Runs Home Assistant OS at a separate physical location. Connected to the primary network via Tailscale. Configured as a Tailscale exit node. Exposed publicly via SSH reverse tunnel to the VPS.

---

## Planned Upgrades

| Item | Purpose | Phase |
|------|---------|-------|
| 500 GB SATA SSD | Migrate OS pool — free up SAS drive bays | 1 |
| 8× 8 TB drives | Expand media pool | 2 |
| Sun NDS-4600 60-bay JBOD | ~109 TiB external expansion chassis | 2 |
| LSI HBA | External SAS connectivity for JBOD | 2 |
| APC UPS | Battery backup | 2 |
| RTX A2000 12 GB | Replace Quadro P1000 — more VRAM for ML | 3 |
| 2× 32 GB ECC DIMMs | 64→128 GB RAM | 3 |
