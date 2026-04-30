# Kia K5 DL3 (2022) — Owner's Vehicle

The owner drives a Kia K5 (DL3 chassis) 2022 Korean-market spec. This page collects what's known about its keyless system.

## Smart key

| Spec | Value |
|---|---|
| OEM part numbers | 95440-L3010 / 95440-L3020 / 95440-L3430 |
| FCC ID (5-button) | `CQOFD00790` |
| FCC ID (4-button flip) | `CQOTD00660` |
| IC | 1551E-FD00790 |
| Frequency | 433.92 MHz |
| Modulation | FSK (proprietary rolling) |
| Buttons (5-btn) | Lock, Unlock, Trunk, Panic, Remote Start |
| Buttons (7-btn Korean spec) | Above + 2 more (likely summon / remote start variants) |
| Battery | CR2032 |
| Transponder chip | 4A (Hyundai-Kia proprietary, AES-based immobilizer) |

## NFC card key (Kia Digital Key 2 Touch)

Optional accessory. Not all DL3 trims include it.

- Card-format secure element
- Tapped to driver's door handle for >2 seconds to unlock
- Placed on wireless charging pad inside cabin to start engine
- Encrypted, paired to vehicle VIN at registration time
- Cannot be cloned (secure element + crypto challenge-response)

## What works on Flipper

| Goal | Capability |
|---|---|
| Capture button-press RKE at 433.92 MHz | ✅ Frequency Analyzer + Read RAW |
| Decode the captured RKE protocol | partial — likely shows as RAW or unknown rolling. URH may decode the manchester / FSK structure |
| Replay captured codes to unlock car | ❌ rolling code, will desync your real key |
| Read NFC card UID | ✅ |
| Clone NFC card key | ❌ secure element |
| Detect 125 kHz LF wakeup at door handle | weak — Flipper LF coil isn't tuned for the high-power car-emitted field |
| Read 4A transponder chip in fob | ❌ AES-based, no public crack |

## What works on Proxmark3 RDV4

| Goal | Capability |
|---|---|
| Sniff 125 kHz LF challenge at door handle | ✅ `lf sniff` with antenna near handle |
| Read NFC card protocol info | ✅ `hf 14a info`, `hf 14a sniff` |
| Crack 4A transponder | ❌ same crypto barrier |

## Realistic exercises

If the owner wants to learn from their own car:

1. **Frequency analyzer at 433.92** — confirm exact transmit frequency of each button. Korean fobs sometimes drift slightly off the nominal value.
2. **Read RAW captures** — record 5 button presses each of Lock and Unlock. Compare in URH to see how the rolling code changes between captures.
3. **TPMS reader** — Momentum has a built-in TPMS decoder. Drive with the Flipper in the cabin's Sub-GHz Reader → TPMS, watch the four wheels' pressures appear (Hyundai/Kia uses Schrader OEM sensors).
4. **NFC card read** — tap card to Flipper. Get UID and ATQA/SAK. That's all you'll get.

## What if I lose the key?

Three options, in order of cost:

1. **Kia dealer** — programs a new fob to your VIN. Requires both existing keys present (for pairing protocol) + diagnostic tool. Cost: ~150,000–300,000 KRW.
2. **Locksmith with VVDI / Lonsdor / Autel** — cheaper for many Hyundai/Kia models. Cost: ~80,000–200,000 KRW. Find one familiar with DL3.
3. **Used fob from junkyard + reprogramming** — risk that the chip is permanently paired to a different VIN. Don't recommend.

The Flipper Zero plays no role in any of these. It cannot generate a working clone of a 4A-chip immobilizer.

## Has Hyundai/Kia patched the "Game Boy" attack on K5?

The Game Boy emulator devices (see [hyundai-kia-vulnerabilities.md](hyundai-kia-vulnerabilities.md)) currently target Ioniq 5, EV6, Genesis GV60, and reportedly K5/Niro/Forte. Hyundai issued a UK-only paid ($65) anti-emulator firmware update for affected Ioniq 5 models in 2024. Korean-market K5 DL3 owners have not received a comparable update as of mid-2026. If you're worried, mitigations:

- Faraday pouch for the key when at home
- Park in a garage / camera-monitored space
- Disable proximity unlock entirely (Vehicle settings — leaves only button-press unlock, eliminates PKES attack surface)
- Tracker (AirTag, Bluelink/Kia Connect)
