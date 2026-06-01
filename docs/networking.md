# Networking

## Physical Layer

- **Switching / WiFi**: Ubiquiti UniFi — managed switching with VLAN tagging, UniFi APs for wireless
- **ISP**: Comcast Xfinity cable (residential, dynamic IP)
- **Gateway**: Xfinity DOCSIS gateway at `10.0.0.1`

---

## VLANs

Three isolated network segments:

| VLAN | Subnet | Hosts | Purpose |
|------|--------|-------|---------|
| Main LAN | `10.0.0.0/24` | PC, HA Pi, UniFi controller, IoT gateway | Primary workstation + IoT entry point |
| Server VLAN | `192.168.50.0/24` | All Proxmox VMs and containers | Isolated server traffic |
| IoT VLAN | `192.168.20.0/24` | Smart home devices | Isolated from LAN — cannot reach servers |

IoT devices (TP-Link, Amazon Echo, ASUS clients) are segmented from the Server VLAN. Home Assistant bridges the IoT and Server VLANs via MQTT at `10.0.0.1:1883`.

---

## Public Exposure — Oracle Cloud VPS

The home router has no inbound port-forwards. All public traffic routes through an Oracle Cloud Always Free VPS:

```
Internet :443
    │
    └─► Nginx Proxy Manager (VPS: 141.148.70.220)
            │  WireGuard tunnel (10.0.0.1/8 → 192.168.50.0/24)
            └─► Backend services on 192.168.50.x
```

This means:
- Zero open ports on the home router
- TLS terminates at NPM on the VPS, not at home
- WireGuard gives the VPS a routed path into the server VLAN
- SSH reverse tunnels handle the few services that can't be proxied directly (Home Assistant at Hampton, MediaSite)

### WireGuard Site-to-Site

- **Server**: VPS (`wg0`, listens on UDP `51820`)
- **Peer**: R530 PVE host — establishes outbound tunnel
- VPS has `AllowedIPs = 192.168.50.0/24` → routes server VLAN traffic through the tunnel
- Used exclusively for NPM → backend proxying; no client traffic goes through it

---

## Remote Access

### Tailscale

Mesh VPN with 8 nodes: workstation, laptop, phones, iPad, HA Pi, VPS.

- Tailnet: `tail00fe43.ts.net`
- Used for direct admin access to Proxmox, containers, and other internal services without going through the public proxy
- HA Pi configured as a Tailscale exit node — allows routing all internet traffic through home when remote

### SSH Reverse Tunnels

For services at the Hampton site (behind a different ISP connection), SSH reverse tunnels are established from the HA Pi to the VPS:

| Port on VPS | Forwards to |
|-------------|-------------|
| `8124` | HA Pi `:8123` (Home Assistant) |
| `5001` | MediaSite `:5000` |
| `25565` | Minecraft `:25565` |

---

## DNS

- **Public DNS**: Cloudflare — authoritative for `donovanshome.systems`
- 12 A records pointing to VPS `141.148.70.220`
- Wildcard cert `*.donovanshome.systems` via Let's Encrypt DNS-01 challenge, automated through NPM
- Cert expires 2026-07-16, auto-renewed

Internal DNS resolution is handled by the local resolver; no split-horizon DNS configured (services are accessed by IP internally).

---

## Subdomains

| Subdomain | Backend | Auth |
|-----------|---------|------|
| `auth.donovanshome.systems` | CT304 `:9000` | Authentik native |
| `photos.donovanshome.systems` | CT300 `:2283` | Immich native |
| `music.donovanshome.systems` | CT140 `:4533` | Navidrome native |
| `ha.donovanshome.systems` | VPS `:8124` (SSH tunnel) | HA native |
| `homeha.donovanshome.systems` | CT111 `:8123` | Authentik OAuth |
| `stats.donovanshome.systems` | CT140 `:42010` | None (open) |
| `sonarr.donovanshome.systems` | CT315 `:8989` | Authentik forward auth |
| `radarr.donovanshome.systems` | CT315 `:7878` | Authentik forward auth |
| `prowlarr.donovanshome.systems` | CT315 `:9696` | Authentik forward auth |
| `bazarr.donovanshome.systems` | CT315 `:6767` | Authentik forward auth |
| `jellyseerr.donovanshome.systems` | CT315 `:5055` | Plex OAuth |
| `tautulli.donovanshome.systems` | CT315 `:8181` | Authentik forward auth |

---

## VPN Kill-Switch (Gluetun)

All outbound traffic from the download containers in CT315 is routed through a Gluetun container running ProtonVPN WireGuard:

- Gluetun acts as a network gateway for qBittorrent, cross-seed, and indexer containers
- If the VPN drops, traffic is blocked (kill-switch) rather than leaking over the clearnet
- Port forwarding via ProtonVPN NAT-PMP, monitored by the VPN watchdog script (see [scripts](../scripts/vpn-watchdog.sh))

---

## Cloudflare Tunnel

CT106 (Obedience) runs `cloudflared` to expose the Node.js app at `obedience.donovanshome.systems` through Cloudflare's zero-trust tunnel — no VPS proxy needed for that service, and Google OAuth is the auth layer.
