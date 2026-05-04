# Research

Per-protocol deep dives, organized by the Flipper Zero's main capabilities.

| Doc | Band / Interface | Hardware involved |
|---|---|---|
| [sub-ghz.md](sub-ghz.md) | 300–928 MHz radio | CC1101 |
| [nfc.md](nfc.md) | 13.56 MHz HF | ST25R3916 |
| [rfid.md](rfid.md) | 125 kHz LF | LF coil + comparator |
| [infrared.md](infrared.md) | IR (940 nm) | IR LED + receiver |
| [ibutton.md](ibutton.md) | 1-Wire contact | GPIO 17 |
| [badusb.md](badusb.md) | USB HID | USB-C |
| [bluetooth.md](bluetooth.md) | BLE 4.x/5.x | STM32WB55 Core2 |
| [tpms.md](tpms.md) | Sub-GHz (specialized) | CC1101 + Momentum decoders |
| [u2f.md](u2f.md) | USB HID (FIDO U2F) | USB-C |
| [sdr.md](sdr.md) | All bands (external SDR) | RTL-SDR / HackRF / etc. |

For automotive-specific research see [`../cars/`](../cars/) — the car key fob situation needs its own treatment.
