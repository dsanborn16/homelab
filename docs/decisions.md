# Architecture Decisions

Key technical decisions made during the homelab's design and operation, with rationale.

---

## WireGuard Site-to-Site to Oracle VPS (instead of port-forwarding)

**Choice:** Route all public traffic through an Oracle Cloud Always Free VPS via WireGuard, rather than opening ports on the home router.

**Why:**
- Dynamic residential IP — DDNS updates lag and break TLS cert issuance
- ISP (Comcast) blocks common inbound ports (80, 443) on residential plans
- Zero open ports on the home router dramatically reduces attack surface
- Oracle Always Free VPS costs nothing and provides a stable public IP

**How it works:** The R530 establishes an outbound WireGuard tunnel to the VPS. NPM on the VPS has a route into `192.168.50.0/24` and reverse-proxies all traffic. No inbound rule on the home firewall required.

---

## Authentik Forward Auth (instead of per-service OAuth)

**Choice:** Central SSO via Authentik with NPM forward auth, rather than configuring OAuth on each service individually.

**Why:**
- Many services in the arr stack don't support OAuth — they have basic auth or no auth
- Forward auth lets NPM gate any service without the service knowing
- Single login session → all protected services, one place to revoke access
- Easier to onboard family members (one account, one IdP)

**Trade-off:** Forward auth adds a round-trip to Authentik on every request. For LAN users accessing via Tailscale this is bypassed.

---

## ZFS RAIDZ1 for `datapool`

**Choice:** ZFS RAIDZ1 across 4 drives instead of RAID5/LVM mirroring or hardware RAID.

**Why:**
- RAIDZ eliminates the RAID5 write hole (ZFS write atomicity)
- Native Proxmox integration — no separate RAID controller, no firmware lock-in
- ZFS features: compression (saves ~20% on media), checksumming (silent corruption detection), snapshots
- RAIDZ1 can be expanded online (OpenZFS 2.2+) without downtime — currently expanding from 4→5 drives

**Known limitation:** RAIDZ1 only survives 1 drive failure at a time. With `sde` at 215 grown defects, there is a current single-point-of-failure risk. Mitigation: replace `sde` immediately; long-term plan is RAIDZ2 in Phase 5.

---

## ReadMeABook replaces Readarr + Bookworm (2026-05-31)

**Choice:** Replace the Readarr + Bookworm stack with ReadMeABook for audiobook automation.

**Why:**
- Readarr path handling is fragile — three separate path configuration fields that must all align (download dir, media dir, import category), and a bug in Readarr's import logic caused failed imports even with correct paths
- Bookworm is a custom SPA wrapping Readarr's API — double the moving parts
- ReadMeABook integrates Prowlarr + qBit + Audiobookshelf natively, handles M4B chapter merging, and exposes a clean request UI

**Status:** Parallel validation in progress. Readarr (`:8787`) and Bookworm (`:8484`) remain running until ReadMeABook completes one full end-to-end acquisition. After ~1 week clean operation, Readarr and Bookworm will be decommissioned and the Homepage widget updated.

---

## Proxmox LXC for most services (instead of Docker on a VM)

**Choice:** Run services in LXC containers directly on Proxmox rather than installing Docker on a VM and running everything there.

**Why:**
- LXC containers are closer to the metal — lower overhead than VMs
- Each service grouping gets its own container with independent resource limits (CPU cores, RAM, disk quotas) enforced at the hypervisor level
- Snapshot, backup, and restore at the container level via Proxmox
- Exception: CT315 (arr-stack) uses Docker Compose inside LXC because the arr services are tightly networked and docker-compose is the standard deployment method for that stack

---

## Gluetun VPN Kill-Switch in CT315

**Choice:** Route all download traffic through a Gluetun VPN container rather than installing a VPN at the host or VM level.

**Why:**
- Granular — only CT315 traffic is VPN-routed; other containers have direct internet access
- Kill-switch is enforced at the container network namespace level — if Gluetun stops, qBittorrent loses network entirely rather than leaking
- Port forwarding (NAT-PMP) is handled by Gluetun and synced to qBittorrent automatically via `qb-port-sync`
- ProtonVPN WireGuard provides fast, low-overhead tunneling

**Operational note:** ProtonVPN NAT-PMP can silently fail (port=0) without any error in logs or UI. This was discovered after a 36-hour undetected outage. VPN watchdog script now detects and auto-recovers within ~10 min.
