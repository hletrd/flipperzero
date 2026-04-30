# RFID (125 kHz LF)

Low-frequency RFID. The Flipper Zero has a dedicated 125 kHz coil on the bottom of the device.

## Common protocols

| Protocol | Bits | Use |
|---|---|---|
| **EM4100 / EM410x** | 64 (40 data) | Cheap building access, gym keys, hotel cards |
| **HID Prox** (H10301/H10302/H10304) | 26/35/37 | US enterprise access |
| **Indala** (PSK1, FlexSecur) | 64 / 224 | US enterprise access |
| **AWID** | 26 | US/EU access |
| **Pyramid (Farpointe)** | 26 | Enterprise access |
| **IoProx (Kantech)** | 26 | Canadian enterprise |
| **Hitag1 / Hitag2 / HitagS** | 32–256 | **Car immobilizer chips** (older), some access |
| **T5577 / EM4305** | rewritable | Used as cloner targets |

## Workflow on Flipper

### 1. Detect a card

125 kHz RFID → **Read** → hold the card flush against the bottom of the Flipper. Auto-detection identifies protocol + ID.

### 2. Save & emulate

Saved as `.rfid` files in `/lfrfid/`. Emulation just requires the captured ID — most LF protocols transmit an unauthenticated ID with no rolling component, so emulation works directly.

### 3. Write to a blank

If you have a T5577 blank card, **Write** mode can clone the original. Hold the blank in the Flipper's coil → select the saved card → Write. Now the blank acts as the original.

## Hitag2 (car immobilizers)

Many older cars (early 2000s) use Hitag2 transponders embedded in the key plastic. The transponder authenticates with the car's immobilizer at engine start.

| Hitag2 attack | Feasible on Flipper? |
|---|---|
| Read UID | ✅ |
| Read public memory | ✅ |
| Replay observed authentication | partial — requires sniffing the car↔key exchange |
| Crypto break (Tillich/Aumasson 2012) | ❌ on Flipper; ✅ on Proxmark3 RDV4 |

For Hitag2 cracking, the Proxmark3 has a `lf hitag` command set with all known attacks (Hitag2 cracker, Hitag2 brute, RKF). Flipper's LF firmware doesn't expose this depth.

**Modern cars (2010+) use Hitag-AES or proprietary AES-based immobilizers — neither Flipper nor Proxmark3 can break these.**

## Card collections in this repo

| Source | What's there |
|---|---|
| [`forks/flipperzero-goodies/intercom-keys/`](../../forks/flipperzero-goodies/intercom-keys/) | Russian/Ukrainian apartment intercom (domofon) keys — RFID + iButton |
| [`forks/flipper-starnew/`](../../forks/flipper-starnew/) | Mixed RFID + iButton key collection |
| [`forks/uberguidoz-flipper/`](../../forks/uberguidoz-flipper/) | UberGuidoZ general repo (not LF-specific) |

These contain `.rfid` and `.ibtn` files saved from real intercom/access systems. Useful as a known-good library for testing emulation; not magical "open everything" keys.

## Hardware comparison

| Task | Flipper Zero | Proxmark3 RDV4 |
|---|---|---|
| Read EM4100 / HID / Indala | ✅ | ✅ |
| Write to T5577 | ✅ | ✅ |
| Hitag2 read/replay | ✅ basic | ✅ + crypto attacks |
| Sniff car↔key LF transmission | ❌ (no live sniff mode) | ✅ (`lf sniff`) |
| Antenna sensitivity | ~3 cm read range | ~10 cm read range |

For LF research where you need to sniff a live car immobilizer exchange or attack Hitag2 crypto, use the Proxmark3.

## Frequencies sometimes called "LF" but aren't 125 kHz

- **134.2 kHz** — pet/livestock chips (FDX-B, ISO 11784/11785). Flipper supports these via the 125 kHz coil with auto-tuning
- **134 kHz Hitag-S animal tags** — supported

The Flipper LF coil is tuned wide enough to handle 100–150 kHz with reduced sensitivity at the edges.
