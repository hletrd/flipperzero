# Car Key Fobs: RKE / PKES / Immobilizer

This document explains the layered RF systems modern cars use for keyless access and engine start, and what (and what not) you can do with a Flipper Zero.

## Three independent RF systems

Modern cars typically use **three** distinct RF systems at the same time:

### 1. RKE (Remote Keyless Entry) — UHF Sub-GHz

The "press a button on the fob to lock/unlock" system.

- **Direction**: key → car (one-way)
- **Frequency**: 315 MHz (NA), 433.92 MHz (EU/Asia/Korea)
- **Modulation**: OOK or FSK
- **Encoding**: rolling code (HCS, KEELOQ, or proprietary AES-CMAC)
- **Range**: 5–30 m

### 2. PKES (Passive Keyless Entry & Start) — LF + UHF bidirectional

The "key in pocket, touch door handle" system.

- **Wakeup**: car emits 125 kHz LF challenge from antennas inside door handles + cabin
- **Response**: key replies on 315/433 MHz UHF with authenticated answer
- **Crypto**: bidirectional challenge-response with rolling counter, AES or proprietary
- **Range**: ~30 cm at door handles (LF physics-limited); ~1 m for "approach lights" features (long-range LF or UHF beacon)

### 3. Immobilizer — 134 kHz LF transponder embedded in key

Authenticates the **physical key** before allowing the engine to crank.

- **Direction**: ignition coil ↔ key transponder (RFID-like)
- **Standards**: Hitag2, Hitag-AES, Megamos, proprietary
- **Range**: contactless, but only inches from the ignition coil (for traditional keys) or the wireless charging pad (for newer push-start cars)

The key fob contains chips for **all three** systems. Each is independent of the others.

## What Flipper Zero can do

| System | Flipper capability | Outcome |
|---|---|---|
| **RKE** (button presses) | Sub-GHz Read RAW, Frequency Analyzer | ✅ Capture, ✅ Decode protocol, ❌ Replay (rolling code) |
| **PKES** (proximity) | Sub-GHz Frequency Analyzer near door handle | ✅ See key's UHF response burst, ❌ Capture LF wakeup, ❌ Replay (challenge-response) |
| **Immobilizer** (Hitag2) | 125 kHz Read | ✅ Read UID, ❌ Crack crypto |
| **Immobilizer** (Hitag-AES, Megamos AES, modern proprietary) | None | ❌ |

## Why cloning a modern fob is hopeless on Flipper

1. **Rolling codes** — every press generates a new one-time code. Capturing one captures one use. Replaying it desyncs your real key (or fails outright if the car uses a strict counter window).
2. **Manufacturer secret keys** — the encryption key is burned into the fob's tamper-resistant chip and never exposed in radio. Without that key, you can't generate valid future codes.
3. **PKES challenge-response** — the key only transmits when challenged with a specific LF nonce. There's no "passively capture and replay" — the responses are bound to challenges.
4. **Hitag2-AES / Megamos AES immobilizers** — used in cars from ~2010+. AES-128 with no public attacks.

The Flipper Zero is the wrong tool for this job. There is no firmware fork, custom build, or app that changes this — the constraints are physical (no LF wakeup transmit, single CC1101 with no antenna for low-distance LF challenge generation) and cryptographic (the secrets aren't in the radio).

## What can attack a modern car

The criminal market uses **purpose-built emulator devices** ($16k–30k) with:

- Bidirectional 125 kHz LF transmitter (high-power coil) AND 315/433 MHz UHF transceiver
- Implementation of the manufacturer-specific challenge-response protocol (Hyundai/Kia, BMW, Tesla, etc. — each has its own)
- Sometimes a recovered manufacturer key (leaked or extracted from junkyard fobs)
- A "scanner" mode that probes the car to identify model/year and select the right protocol

These are **not** Flipper Zeros. They're not Flipper firmware. The "Game Boy" devices stealing Hyundai Ioniq 5s in Europe are bespoke criminal hardware.

For legitimate research, you'd build your own with:

- **HackRF One + PortaPack** for full-duplex SDR coverage
- **Proxmark3 RDV4** for the LF side
- **Custom firmware** implementing the manufacturer protocol

This is a substantial project for serious researchers.

## Relay attacks (the only Flipper-adjacent pseudo-attack)

The classic PKES attack is a *relay attack*: extend the radio range so the key thinks it's at the car when it's actually 100 m away inside the owner's house.

- Two devices needed: one near the key (extends LF), one near the car (re-emits UHF response)
- Real-time, low-latency RF link between the two devices
- **Doesn't break crypto** — the key really does authenticate, just from far away

Flipper alone can't relay because:
- It has only one radio
- No high-power 125 kHz LF transmit chain
- No low-latency cross-device link mode

You'd need two HackRFs, custom software, and a 5.8 GHz mesh between them. Academic papers (Francillon et al. NDSS 2011) demonstrated this — it's not new, but it's not Flipper either.

## What Flipper IS useful for, automotively

- **Capturing your own button-press RKE for analysis** — confirm frequency, modulation, observe rolling-code structure
- **Reading TPMS sensors** — Momentum's Sub-GHz reader has built-in decoders for Schrader, Renault, GM, Hyundai, Toyota, Citroen, Subaru, Ford TPMS
- **Studying 125 kHz LF immobilizer ID** — read your own Hitag chip's UID
- **Detecting the welcome-light beacon** — Frequency Analyzer near the door catches the UHF burst when handle is touched

All of these are diagnostic. None of them produce a clone or unauthorized access.

## See also

- [kia-k5-dl3.md](kia-k5-dl3.md) — owner's specific car details
- [hyundai-kia-vulnerabilities.md](hyundai-kia-vulnerabilities.md) — what the criminal market is actually doing
