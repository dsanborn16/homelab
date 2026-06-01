# Networking

## Design Goals

- No open ports on the home router
- All public services behind SSO
- IoT devices isolated from the server subnet
- Remote access that works without depending on dynamic residential IP

---

## VLAN Segmentation

Three isolated segments managed by Ubiquiti UniFi:

| VLAN | Purpose |
|------|---------|
| Main LAN | Workstations, HA hub, IoT gateway |
| Server VLAN | All Proxmox VMs and containers |
| IoT VLAN | Smart home devices — cannot reach server subnet |

IoT devices are isolated at the switch level. Home Assistant bridges the IoT and server subnets via MQTT for device control without opening the full subnet.

---

## Public Exposure via Oracle Cloud

The home router has no inbound port-forwards. All public traffic flows through an Oracle Cloud Always Free VPS:

```
Internet :443
    │
    └─► Nginx Proxy Manager (Oracle Cloud VPS)
         │  WireGuard site-to-site tunnel
         └─► Backend services on server VLAN
```

The server establishes an outbound WireGuard tunnel to the VPS. The VPS has a routed path into the server subnet and reverse-proxies all traffic through Nginx Proxy Manager. TLS terminates at the VPS — home never terminates public TLS.

This means:
- No firewall rules needed on the home router
- Stable public IP regardless of residential ISP dynamic IP
- Single chokepoint for all inbound traffic

---

## Remote Access

**WireGuard site-to-site:** Used exclusively for the proxy path. The VPS routes service traffic through the tunnel to the server subnet.

**Tailscale mesh (8 nodes):** Direct private access for admin use — workstation, laptop, phones, HA hub, VPS. Used to reach Proxmox, containers, and other non-public services without going through the public proxy. HA hub is configured as a Tailscale exit node.

**SSH reverse tunnels:** Used for services at the second physical site that can't be proxied through WireGuard (different ISP, no control of that router). Established outbound from the remote device to the VPS.

---

## DNS and TLS

- Domain managed on Cloudflare
- Wildcard Let's Encrypt cert covering all public subdomains, auto-renewed via DNS-01 challenge through Nginx Proxy Manager
- All 12 public subdomains point to the VPS; no DNS records expose internal addresses

---

## Authentication

All public-facing services are behind Authentik forward auth. Nginx Proxy Manager checks the Authentik endpoint before passing any request to a backend — services without native OAuth are protected without any changes to the service itself. One login session covers all protected services.

Exceptions: Immich and Navidrome use their own native auth; Jellyseerr uses Plex OAuth.

---

## VPN Kill-Switch (Download Stack)

All download traffic in the media stack is routed through a Gluetun container running ProtonVPN WireGuard:

- Acts as a network gateway for the torrent client and indexer containers
- Kill-switch enforced at the container network namespace level — if the VPN drops, containers lose network entirely rather than routing over clearnet
- Port forwarding via ProtonVPN NAT-PMP, monitored by the VPN watchdog script
