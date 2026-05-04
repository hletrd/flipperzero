# TPMS (Tire Pressure Monitoring System)

Direct TPMS sensors broadcast tire pressure + temperature + sensor ID over Sub-GHz radio. The Flipper Zero's CC1101 + Momentum's protocol decoders read these in real time.

## Protocols seen on cars (relevant for the owner's Kia K5)

| Protocol | Frequency | Modulation | Manufacturer |
|---|---|---|---|
| Schrader | 433.92 MHz | FSK | Most Hyundai/Kia, GM, BMW (older), VAG (newer) |
| Schrader OEM-G | 433.92 / 315 | FSK | Newer Hyundai-Kia (Kia EV6, Ioniq 5/6) |
| Renault | 433.92 | FSK | Renault, Dacia |
| Toyota A | 315 / 433.92 | FSK | Toyota, Lexus |
| Citroen | 433.92 | FSK | Citroen, Peugeot |
| Subaru G3 | 315 | FSK | Subaru |
| Ford / Sigma | 315 | FSK | Ford, Lincoln |
| GM / Schrader | 315 | FSK | older GM |
| Continental / VW | 433.92 | FSK | newer VAG |

For Korean-market Kia K5 DL3 (2022): expect **Schrader OEM at 433.92 MHz**. Each tire has its own sensor with a unique 32-bit ID.

## Reading TPMS on Flipper Zero (Momentum)

Built-in to Momentum's Sub-GHz reader since mntm-005:

1. Sub-GHz → **Reader** → Configure → Hopping: `433.92` (or set explicit frequency)
2. Drive the car ~5 minutes. Sensors transmit every 30–60 seconds while moving (some only at speed; some periodically when stationary)
3. Reader shows live entries:

```
Schrader OEM
ID: 0x12345678
PSI: 32.5
Temp: 22.0 °C
RSSI: -54 dBm
```

Captures save to `/ext/subghz/` with the protocol name. Each sensor has stable ID — you can label them per-tire after first capture.

## Reading TPMS without Momentum's built-in (apps/tpms/)

The standalone `tpms.fap` (built from `apps/tpms/` in this repo) provides a focused TPMS-only UI:

- Apps → Sub-GHz → TPMS
- Same protocol decoders, dedicated screen with PSI/temp focus
- Useful when you want pure TPMS without the rest of Sub-GHz reader's UI

Both work fine on Momentum.

## Frequency selection

The K5's TPMS is at 433.92 MHz nominally but sensors can drift by ~50 kHz. Use:

- **Frequency Analyzer** first to find the actual transmit frequency of YOUR car's sensors (drive a few minutes; sensors transmit when wheels rotate)
- Then **Reader** at that exact frequency for clean reception

## What you can do with a captured TPMS ID

Each sensor's 32-bit ID is unique to that physical sensor. Useful for:

- **Verifying replacement sensors** — when you replace a tire, the new sensor has a different ID; the car's ECU needs to learn it (some cars auto-learn after driving; others require a TPMS programming tool)
- **Tracking which tire moved** — if you rotate tires, IDs let you confirm which physical sensor is now where
- **Detecting spoofed sensors** — in pentesting, an attacker could broadcast a fake sensor ID to confuse the car. Capturing legitimate IDs lets you spot spoofing

## What you CAN'T do

- **You can't program the car's ECU to accept a new sensor.** That requires OBD-II + a TPMS programmer (Autel TS401, ATEQ VT55, etc.).
- **You can't make the car ignore real sensors via Flipper.** Even if you transmit fake "all good" packets, the car prefers real sensors and will fault when the legitimate sensor is silent.
- **You can't break the protocol crypto.** Schrader and most modern TPMS use simple checksums, not encryption — but that means the crypto isn't the obstacle; lack of write-access to the ECU is.

## TPMS attack surface (academic)

Several papers have demonstrated:

- **Spoofing low-pressure warnings** to make a car alarm constantly (DoS attack, harassment)
- **Tracking vehicles by sensor ID** — passively-collected TPMS broadcasts at toll plazas, parking lots can fingerprint specific cars over time. **GDPR concern.**
- **Eavesdropping on TPMS to determine car location** — works at distances of 1–40 meters depending on antenna

The Flipper Zero is plenty capable of these attacks technically; whether they're legal/ethical depends entirely on context (your own car: fine; someone else's: criminal).

## Pulling sensor data over time

For long-term analysis (e.g., monitoring tire pressure trends):

```python
# pseudocode — would need the storage.py or a CLI poll
import serial
s = serial.Serial('/dev/cu.usbmodemflip_*')
# launch tpms reader
# poll storage for new captures every minute
# parse .sub or app data files for PSI/temp/timestamp
```

Or run the `tpms` app standalone, periodically pull saved captures via `storage.py receive`.

## See also

- [sub-ghz.md](sub-ghz.md) — general Sub-GHz workflow
- [../cars/kia-k5-dl3.md](../cars/kia-k5-dl3.md) — owner's car specifics
- [rtl_433 TPMS docs](https://github.com/merbanan/rtl_433/blob/master/docs/) — alternative reader if you have an RTL-SDR
