# Proxmark3 RDV4

The owner has a Proxmark3 RDV4. This page covers when to use it instead of (or alongside) the Flipper Zero.

## What Proxmark3 RDV4 is

A purpose-built RFID/NFC research tool by RFID Research Group / Proxmark.org. Open hardware + open firmware, full-stack — host-side CLI, device firmware, multiple FPGA-driven antenna paths.

## Key strengths over Flipper Zero

| Capability | Flipper | Proxmark3 RDV4 |
|---|---|---|
| 125 kHz LF analysis depth | basic | extensive (custom commands, sniff mode, all attack chains) |
| Hitag2 crypto attacks | ❌ | ✅ (Tillich/Aumasson + brute) |
| iCLASS / SEOS attack chains | partial (apps) | ✅ (built-in) |
| Mifare DESFire research | UID only | UID + protocol details |
| Mifare Classic fast attacks | dictionary | Dictionary + Hardnested + DarkSide + StaticNonce |
| Live HF sniff (card↔reader) | ❌ | ✅ (`hf 14a sniff`) |
| Live LF sniff (immobilizer) | ❌ | ✅ (`lf sniff`) |
| Standalone mode | ✅ (Flipper UI) | ✅ (button-controlled) |
| Bluetooth-controlled mode | optional via app | optional via Blue Shark module |
| Antenna swap-ability | fixed | swappable for tuned LF/HF/Magnetic |
| Hardware-accelerated crypto | no | yes (FPGA assists Mifare math) |

## When to reach for Proxmark over Flipper

1. **Cracking Mifare Classic with stuck/non-default keys** — Proxmark's hardnested attack is purpose-built for this; Flipper can do dictionary but not hardnested
2. **Sniffing live transactions** — Proxmark's `hf 14a sniff` captures the full reader↔card exchange in real time; Flipper has no equivalent
3. **iCLASS Elite / SEOS** — Proxmark has the full attack chain (Mickey/Megamos style)
4. **Hitag2 / Hitag-S immobilizer research** — Proxmark exposes deep LF protocol commands; Flipper just reads UIDs
5. **Antenna performance matters** — Proxmark's RDV4 with a tuned antenna reads from 5–10 cm; Flipper from 1–3 cm
6. **Scripting** — Proxmark client is a full CLI with Lua scripting; great for batch operations

## When Flipper is fine (or better)

1. **EM4100 / HID Prox / Indala read+write** — Flipper does this with one tap, no host computer needed
2. **NTAG / Mifare Ultralight** — Flipper handles these as well as anything
3. **Field portability** — Flipper is pocket-size; Proxmark needs a host computer (or Blue Shark + phone)
4. **iButton (1-Wire)** — Proxmark doesn't natively support this; Flipper does
5. **Sub-GHz, IR, BadUSB** — Proxmark has none of these; Flipper has all
6. **General "show off" demos** — Flipper UI > Proxmark CLI for non-technical audiences

## Combined workflow

For deep RFID research on a target the owner has authorization for:

1. **Flipper**: quick read + identify protocol (EM4100 vs HID vs unknown)
2. **Proxmark**: if unknown or encrypted, sniff + attack
3. **Flipper or Proxmark**: write recovered key to T5577 blank for testing
4. **Flipper**: deploy the cloned key in the field (more portable)

## Setup notes

```bash
# macOS install (Homebrew)
brew tap RfidResearchGroup/proxmark3
brew install --HEAD proxmark3

# Connect Proxmark via USB-C
pm3                    # auto-detects port
# or specify
pm3 -p /dev/cu.usbmodem<id>
```

Inside the `pm3>` shell:

```
hw status              # Show device info
lf search              # Auto-detect LF tag at antenna
hf search              # Auto-detect HF tag at antenna
hf mf chk *1 ?         # Mifare key check with default dictionary
lf hitag info          # Hitag specifics
```

## Antennas

The RDV4 has swappable antennas via the antenna-extension port:

- **LF coil** — standard 125 kHz, larger than Flipper's
- **HF antenna** — 13.56 MHz, larger surface area
- **High-power LF antenna** — designed to drive immobilizer-strength fields (for sniffing car↔key exchanges)
- **Long-range LF antenna** — 5–10 cm read range vs ~3 cm

## Sources

- [Proxmark3 RDV4 official](https://lab401.com/products/proxmark-3-rdv4)
- [RfidResearchGroup/proxmark3 repo](https://github.com/RfidResearchGroup/proxmark3)
- [Proxmark3 wiki](https://github.com/RfidResearchGroup/proxmark3/wiki)
