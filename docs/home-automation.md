# Home Automation

---

## Setup

Two Home Assistant instances across two physical sites:

- **Primary** — Proxmox VM running HAOS (bare-metal-style install for full add-on support)
- **Secondary** — Raspberry Pi 4 at a remote location, connected via Tailscale; also configured as a Tailscale exit node

306 entities across integrations: TP-Link smart plugs and switches, Nanoleaf LED panels, Chromecast media players, ASUS presence detection, Apple device tracking, climate sensors, and 2 IP cameras.

---

## Camera Integration

Rather than letting Home Assistant pull RTSP streams directly (high CPU, latency issues), go2rtc handles the camera relay:

1. go2rtc ingests RTSP streams from both cameras
2. Re-encodes via NVENC (GPU hardware) to HLS/WebRTC
3. HA consumes the hardware-encoded stream

Result: low-latency, smooth camera feeds in the dashboard without taxing the HA VM or the Pi.

---

## Dashboard

Custom Lovelace "My Home" dashboard with 7 views: Overview, Lights, Climate, Media, Cameras, Energy, Presence.

---

## Automations

Key automations:
- Presence-based lighting using Apple device trackers + ASUS router client tracking
- Media-triggered Nanoleaf scenes (panels dim and shift color when Chromecast starts playback)
- Smart plug schedules for workstation monitors and peripherals
- Cross-site entity sharing between the two HA instances

---

## IoT Isolation

Smart home devices (TP-Link, Echo, sensors) run on an isolated IoT VLAN and cannot reach the server subnet. HA bridges the two networks via MQTT for device control — IoT devices publish state, HA subscribes and controls, but there's no routed path between the subnets.
