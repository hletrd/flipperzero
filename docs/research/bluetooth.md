# Bluetooth

The Flipper Zero's STM32WB55 has a Cortex-M0+ "Core 2" co-processor running a Bluetooth Low Energy (BLE) stack. Flipper exposes this via a few apps, but the underlying stack only supports BLE — **no Classic Bluetooth, no audio (A2DP / HFP), no BR/EDR pairing.**

## What Flipper can do

| Feature | Where |
|---|---|
| **BLE Mobile App link** | Companion phone app (Flipper Mobile) for sub-GHz/IR/NFC remote control |
| **BLE HID** (`bad_kb` app) | Pair with target as a BLE keyboard, run BadUSB payloads wirelessly |
| **BLE Spam** (built into Momentum, also `ble_spam.fap`) | Flood BLE advertisements that trigger UI popups on iOS/Android/Windows |
| **GATT Discovery** (`gatt_explorer` app) | Scan and read GATT services/characteristics from nearby BLE devices |
| **`apple_ble_spam`** subset | Specifically targeting iOS proximity actions (AirPods, AppleTV, etc.) |

## What Flipper cannot do

- Sniff BLE traffic (no promiscuous mode in stock stack)
- Decrypt encrypted BLE links
- Operate as Bluetooth Classic device (no SPP, A2DP, HFP, etc.)
- Be a BLE peripheral and central simultaneously (single-role at any moment)

For real BLE research (sniffing, MITM, fuzzing), reach for:
- **Ubertooth One** — passive BLE/Classic sniffer
- **Nordic nRF52840 dongle + Wireshark** — BLE 5 sniff
- **TI SmartRF Sniffer** — TI-flavored
- **Sniffle** ([github](https://github.com/nccgroup/Sniffle)) — works with TI CC26x2 boards

## BLE Spam

`ble_spam.fap` (built from `apps/ble-spam/` against Momentum SDK) and Momentum's built-in BLE Spam menu generate malicious BLE advertisements that exploit OS-level pairing/notification UX:

- **Apple proximity actions** — fake AirPods, fake Apple Watch, fake AppleTV all triggering modal popups on iPhones in range
- **Android Fast Pair** — fake Pixel Buds, Sony WH-1000xMx, etc.
- **Microsoft Swift Pair** — fake Surface Pen, Surface Mouse
- **Samsung EasySetup** — Galaxy device pairing prompts

Effects on bystanders:

- iOS pop-up storms (every 1–2 seconds)
- Forced app launches in some cases (vulnerabilities in older OS versions)
- Device crashes (older iOS pre-17.x had a kernel bug exposed by malformed advertisements)

**Legal status: ambiguous-to-bad.** Sending unsolicited BLE advertisements is technically transmitting on Bluetooth's licensed spectrum without authorization in some jurisdictions. Beyond regulation, it's a clear nuisance for everyone in range.

**Use only on devices you own, in a faraday-style isolated environment.** Don't use in cafés, airports, public transit, etc. People will hate you and you may have a chat with law enforcement.

## BLE HID (`bad_kb`)

Wireless BadUSB. Pair the Flipper with a target as a BLE keyboard. Once paired, every DuckyScript payload runs over BLE — no USB connection needed.

Pairing works on:
- macOS (System Preferences → Bluetooth → "Flipper [name] BLE")
- Windows (Settings → Bluetooth → Add device)
- Linux (`bluetoothctl pair <mac>`)
- iOS / Android — usually as an external keyboard for the device

Payloads run identically to USB BadUSB. See [badusb.md](badusb.md).

## GATT Explorer

Most BLE devices (smartwatches, sensors, headphones, IoT gadgets) expose **GATT services** — a hierarchy of services and characteristics with UUIDs. The `gatt_explorer.fap` app:

1. Scans for advertising BLE devices
2. Connects to a target
3. Lists all services and characteristics
4. Reads characteristic values
5. Subscribes to notifications

Useful for understanding how a device works before more involved reverse engineering.

## Companion mobile app pairing

The official Flipper Mobile app (iOS / Android) pairs over BLE for:

- File browser (read/write SD card from phone)
- Sub-GHz / IR / NFC remote operation
- Firmware updates over the air

This is the same BLE stack — just used as a peripheral with a custom GATT service.

## Power & range

BLE TX power configurable in Settings → Bluetooth → Power Output:

- `Off` — BLE disabled (saves battery, no bricks)
- `Low` (-12 dBm) — ~2 m range
- `Mid` (-3 dBm) — ~10 m range
- `High` (+3 dBm) — ~20–30 m range

For BLE Spam, low power is more polite (only spams the immediate area).

## Useful apps

In Momentum's bundled `/apps/Bluetooth/`:

- `bad_kb` — BLE HID keyboard (BadUSB over BLE)
- `ble_spam` — universal BLE spam (multiple OS targets)
- `bt_trigger` — proximity-triggered actions (use Flipper as a BLE button)
- `findmy` — Apple FindMy network research (set Flipper as a fake AirTag)
- `pc_monitor` — BLE pairing with custom Windows/macOS daemon for system stats
