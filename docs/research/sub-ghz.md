# Sub-GHz

The Flipper Zero's CC1101 transceiver covers 300–348 MHz, 387–464 MHz, 779–928 MHz with multiple modulations (OOK, 2-FSK, 4-FSK, GFSK, MSK, ASK).

## Common bands

| Band | Use |
|---|---|
| 300 MHz | Older garage doors (Linear, Chamberlain, Multicode) |
| 315 MHz | North-American keyless entry, garages, Holtek HT-12 family |
| 390 MHz | Some North-American garages (Genie) |
| 433.05–434.79 MHz | Europe/Asia ISM (most popular for RKE, gates, weather, TPMS) |
| 868.0–868.6 MHz | Europe SRD (newer gates) |
| 915 MHz | North-American ISM (telemetry, TPMS in US) |

## Modulations

| Mod | When | Notes |
|---|---|---|
| **OOK** (On-Off Keying / ASK) | Most cheap remotes, garage gates | Carrier on/off; easy to capture/replay |
| **2-FSK / GFSK** | TPMS, modern keyfobs, weather stations | Two-frequency shift; harder to bruteforce |
| **MSK** | Some industrial protocols | Phase-continuous |

## Workflow on Flipper

### 1. Find the frequency

Sub-GHz → **Frequency Analyzer** → hold the Flipper near the transmitter and trigger it. The display shows the strongest detected frequency in real-time.

Korean/EU keyfobs are ~433.92 MHz. NA fobs are ~315 MHz. Korean K5 DL3 is **433.92 MHz** (FCC ID `CQOFD00790`).

### 2. Read the protocol

Sub-GHz → **Read** → set the frequency from step 1. Trigger the transmitter. Possible outcomes:

- **Recognized protocol** (KeeLoq, CAME, Princeton, Came TWIN, Holtek, Linear, etc.) → Flipper decodes button id + serial; saves as `.sub`. Replay works on **fixed-code** protocols.
- **"RAW"** → Flipper didn't recognize. Use Read RAW instead.

### 3. Read RAW (always-works fallback)

Sub-GHz → **Read RAW** → set frequency → record. Captures the entire waveform as timing intervals. Saves as `.sub` with `Protocol: RAW`. Replay sends the exact captured bits — works on fixed-code; **does not work on rolling code** (the captured payload is single-use).

### 4. Save & replay

Sub-GHz → **Saved** → select your capture → **Send**. Or set as a Favorite for quick access.

### 5. Brute force (fixed-code only)

For unknown fixed-code transmitters, use [`apps/bruteforce/`](../../apps/bruteforce/) to generate `.sub` files covering the full keyspace of common protocols (CAME, NICE, Holtek, Linear, etc.). Drop them in `/subghz/bruteforce/` on the SD card and play them sequentially.

## Rolling codes — what does and doesn't work

| Protocol | Replay attack? | Why |
|---|---|---|
| CAME, NICE, Princeton fixed-code, Holtek HT-12 | ✅ | Same code every press |
| KeeLoq with public manufacturer key (some old gates) | partial | Capture 2+ presses → derive the device key → emulate. UL/RM/Momentum support a list of known public keys |
| KeeLoq with secret manufacturer key (most cars) | ❌ | Manufacturer key is the secret; can't be recovered from captures |
| Modern car RKE (Hyundai, Kia, Toyota, etc.) | ❌ | Proprietary rolling code; one-shot codes; capture desyncs the real key |
| PKES (passive smart keys) | ❌ | Bidirectional challenge-response; key only transmits when challenged via 125 kHz LF |

See [cars/smart-keys.md](../cars/smart-keys.md) for the deep dive.

## Useful tools

- **URH (Universal Radio Hacker)** — desktop app for offline `.sub` analysis, signal decoding, protocol reverse engineering. https://github.com/jopohl/urh
- **`flipperzero-bruteforce`** ([cloned](../../apps/bruteforce/)) — Python script to generate brute-force `.sub` files
- **rtl_433** — runs on RTL-SDR; decodes 200+ Sub-GHz protocols (TPMS, weather, alarms). Cross-reference against Flipper captures
- **Inspectrum** — visual signal analysis for IQ recordings (not raw `.sub`, but useful with HackRF)

## Built-in Momentum decoders

Beyond standard remote protocols, Momentum's Sub-GHz reader auto-decodes:

- TPMS (Schrader, Renault, Toyota, Citroen, Ford, GM, Hyundai/Kia, Subaru)
- Weather stations (Acurite, Ambient, LaCrosse, Oregon, Auriol, Nexus, etc.)
- POCSAG pager messages
- NMEA GPS (when paired with a GPS module on GPIO)

Live data shown in the SubGHz reader screen — no separate app required.

## Frequency restrictions

Stock OFW respects regional band lists (set via `Settings → System → Region`). Unleashed/Momentum/RogueMaster all remove this limit (you can transmit on any frequency the CC1101 supports).

**Don't transmit illegally.** Each country has different ISM allocations and out-of-band transmission can violate local radio regulations (KCC in Korea, FCC in US, CE/RED in EU).
