# Home Automation

Two Home Assistant instances, one per physical site.

---

## Instances

| Instance | Host | IP | Site |
|----------|------|----|------|
| VM102 (primary) | Proxmox VM — HAOS 17.2 | `192.168.50.111` | Maine |
| HA Pi (secondary) | Raspberry Pi 4 | `10.0.0.155` | Hampton |

The Maine instance is the primary hub. The Hampton Pi serves as both a local HA controller for that site and a Tailscale exit node.

Public access: `ha.donovanshome.systems` → HA Pi via SSH reverse tunnel; `homeha.donovanshome.systems` → VM102 via NPM + Authentik OAuth.

---

## Entity Inventory

306 entities across integrations:

| Integration | Entities | Examples |
|-------------|----------|---------|
| TP-Link / Kasa | Smart plugs, switches | Lamps, appliances, monitors |
| Nanoleaf | LED panels | `10.0.0.129` — 4 panels |
| Chromecast | Media players | TV, speakers |
| Apple devices | Device trackers | iPhones, iPad (presence detection) |
| ASUS router | Device trackers | WiFi client presence |
| Tapo cameras | Camera entities | go2rtc relay → HA |
| Climate sensors | Temperature, humidity | Multiple rooms |
| Xfinity gateway | Network entities | Connected devices |

---

## Lovelace Dashboard

Custom "My Home" dashboard at `192.168.50.111:8123/my-home` — 7 views:

| View | Contents |
|------|----------|
| Overview | At-a-glance status cards for all areas |
| Lights | All smart lighting controls |
| Climate | Temperature + humidity sensors |
| Media | Chromecast + speaker controls |
| Cameras | go2rtc live streams |
| Energy | Power monitoring |
| Presence | Family device tracker map |

---

## Camera Integration

go2rtc (CT311, `192.168.50.208`) relays 2× Tapo IP cameras:

- Ingests RTSP streams from the cameras
- Re-encodes via NVENC (hardware) for low-latency HLS/WebRTC
- HA consumes the go2rtc WebRTC stream for the cameras view
- Result: smooth camera feeds in the HA dashboard without taxing the Pi or HA VM

---

## Automations

Key automations (illustrative, not exhaustive):

- **Presence-based lighting**: lights turn on/off based on who's home (Apple + ASUS device trackers)
- **Media-triggered scene**: Nanoleaf panels dim + color-shift when Chromecast starts playback
- **Smart plug scheduling**: monitors + peripherals off overnight via TP-Link schedules
- **Hampton ↔ Maine sync**: shared entities exposed between the two HA instances via HA Cloud or direct webhook

---

## MQTT

IoT messaging broker at `10.0.0.1:1883` (Xfinity gateway). Used for devices that publish sensor data over MQTT (temperature sensors, some TP-Link devices in older firmware). HA subscribes as an MQTT client.
