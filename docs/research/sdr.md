# SDR Integration

The Flipper Zero is great for capture-replay and protocol decode in known bands, but its CC1101 is limited to ~3 KHz of instantaneous bandwidth and 300/315/433/868/915 MHz coverage. For wider-band investigation, IQ recording, or anything outside the CC1101's range, pair the Flipper with a software-defined radio (SDR).

## SDR options

| SDR | Range | TX? | Bandwidth | Cost | Best for |
|---|---|---|---|---|---|
| **RTL-SDR v3 / v4** | 24 MHz – 1.7 GHz (with HF mod down to 500 kHz) | ❌ | 2.4 MHz | ~$30 | Sniff/decode/learn |
| **HackRF One** | 1 MHz – 6 GHz | ✅ +15 dBm | 20 MHz | ~$300 | Full-duplex research, replay, jamming |
| **HackRF + Portapack H4M** | same | ✅ | same | ~$500 | Standalone, no laptop needed |
| **LimeSDR Mini 2.0** | 10 MHz – 3.5 GHz | ✅ | 30.72 MHz | ~$400 | Better sensitivity, MIMO |
| **BladeRF 2.0 micro** | 47 MHz – 6 GHz | ✅ | 61.44 MHz | $480+ | High-end research |
| **PlutoSDR** | 70 MHz – 6 GHz (hackable to 30 MHz – 6 GHz) | ✅ | 56 MHz | ~$200 | Cheap full-duplex |

**Recommended starter combo**: RTL-SDR v4 ($30) for receive-only learning + HackRF One when you want to transmit.

## Software stack on macOS

```bash
# Install via Homebrew
brew install rtl-sdr hackrf gqrx urh

# RTL-SDR test
rtl_test -t   # detect device

# HackRF test
hackrf_info

# GUI tools
gqrx          # waterfall + audio demod
URH.app       # protocol reverse engineering (also installable as Python pkg)
```

Other useful:

```bash
brew install gnuradio multimon-ng dump1090   # GNU Radio + decoders + ADS-B
pip install --user --break-system-packages \
  scapy rtl_433-style-decoders                # rtl_433 has its own brew install
brew install rtl_433
```

## Workflow: Flipper + RTL-SDR + URH

This is the standard pipeline for Sub-GHz protocol research:

1. **Flipper Sub-GHz → Read RAW** captures the *signal* on the device
2. Save the `.sub` file to `/ext/subghz/<your>/<file>.sub`
3. Pull SD card or use `storage.py` to transfer to Mac
4. **URH** opens the `.sub` directly (Universal Radio Hacker has Flipper format support)
5. URH lets you: visualize timing, find preamble, identify modulation, find sync words, decode bits, fuzz

For wider-band scenarios where Flipper's narrow bandwidth misses the signal:

1. **RTL-SDR + GQRX** to find what frequency the target actually uses (waterfall view shows all activity in 2.4 MHz around tuned frequency)
2. **RTL-SDR + rtl_433** to auto-decode 200+ known protocols (TPMS, weather, alarms, etc.) — better than Flipper for some
3. Once frequency confirmed, **Flipper Read RAW** at exact frequency for a clean signal-strength capture
4. Move to URH for analysis

## Workflow: Flipper + HackRF (active research)

When you need to *transmit* something the Flipper can't reach:

1. **HackRF + GNU Radio Companion** to build a custom transmitter for the protocol
2. Capture with Flipper or HackRF
3. Replay/transmit via HackRF (when Flipper's CC1101 can't do the modulation/timing)

Common HackRF use cases:

- **HackRF + GPS spoofing** (`gps-sdr-sim`) — generate a fake GPS signal to test receivers (illegal in public)
- **HackRF + IMSI catcher detection** — passive monitoring of cellular sync channels
- **HackRF + LoRa** (LimeSDR or BladeRF better for LoRaWAN, but HackRF works for short-range)
- **HackRF + ADS-B receive** (1090 MHz aircraft transponders) — `dump1090 --interactive`
- **HackRF + AIS receive** (162 MHz ship transponders)
- **HackRF + POCSAG/FLEX paging** at 138/152/451 MHz

## Where Flipper outperforms SDRs

For day-to-day field work:

- Pocket-portable, runs on battery hours
- Standalone UI (no laptop needed)
- Dedicated CC1101 outperforms RTL-SDR at the bands it covers (better filtering, narrower IF)
- Built-in protocol decoders match well-tuned `rtl_433` for common targets
- 125 kHz LF is a Flipper-only feature among consumer-priced devices

For desk research:

- SDR has 100x more bandwidth (2.4 MHz vs ~25 kHz)
- HackRF transmits with proper modulation control vs Flipper's narrow toolkit
- GUI tools (GQRX, URH, GNU Radio) are vastly more capable

## Where SDR outperforms Flipper

- Bands outside CC1101: <300 MHz, 350-380 MHz (500 MHz?), 1+ GHz
- Wide-band capture (whole 433 MHz band at once vs Flipper's 25 kHz IF)
- Continuous TX/RX (Flipper switches between modes; HackRF can do duplex with Portapack)
- IQ recording — Flipper's `.sub` is timing-based (decoded), SDR captures raw IQ
- Anything WiFi-band (2.4 GHz / 5 GHz) — Flipper's BLE radio doesn't reach WiFi, SDRs above 2 GHz do

## Specific projects worth knowing

- **ShinySDR** — web-based SDR receiver
- **CubicSDR** — cross-platform SDR GUI
- **SDR++** — modern SDR receiver, includes plugins for Flipper integration
- **SatNOGS** — distributed satellite ground station network (volunteer-run; uses RTL-SDR)
- **Maia SDR** — embedded SDR for SBCs

## Practical setup for the K5 case

If the owner wants to seriously study their Kia K5 fob beyond what Flipper alone provides:

1. **RTL-SDR v4** ($30) plus **GQRX** to see the full 433 MHz band when the fob transmits
2. Capture with **Flipper Read RAW** for clean timing
3. Compare RTL-SDR IQ recording (in URH) to the Flipper's decoded `.sub` to see if any structure is missed
4. Eventually, with **HackRF + Portapack**, do live transmit experiments at higher fidelity

Each step adds capability; none of them break Hyundai-Kia's rolling code crypto. See [smart-keys.md](../cars/smart-keys.md) for the why.
