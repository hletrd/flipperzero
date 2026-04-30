# Flipper Zero hardware

What's actually inside the device.

## Main MCU

**STM32WB55RG** (LQFP64 package)

- **Cortex-M4** primary core @ 64 MHz, 1 MB flash, 256 KB RAM (runs Flipper firmware)
- **Cortex-M0+** secondary core ("Core 2", "WPAN") — runs Bluetooth LE stack from ST (closed-source binary blob)
- Built-in 2.4 GHz radio (BLE 5.0)

The dual-core architecture means BLE runs entirely on Core 2 with its own firmware (the "Radio Stack"); the Flipper firmware on Core 1 talks to it via shared memory IPC. Updates handle both cores separately — that's why a full update has multiple reboots.

## Sub-GHz radio

**Texas Instruments CC1101** (separate IC)

- 300–348 MHz / 387–464 MHz / 779–928 MHz coverage
- TX power +12 dBm, RX sensitivity -116 dBm
- Modulations: 2-FSK, 4-FSK, GFSK, MSK, OOK, ASK
- Data rate up to 600 kbps
- Connected to the STM32 via SPI

The CC1101 is the workhorse for all RKE/garage/TPMS/weather work. It's a 15-year-old chip but still the gold standard for sub-GHz hobbyist work — well-documented, cheap, flexible.

## NFC (HF) radio

**ST ST25R3916**

- 13.56 MHz, full ISO/IEC 14443 A/B / 15693 / 18092 (NFC peer-to-peer)
- Active card emulation (Flipper as a card)
- Reader/writer mode (Flipper reading external cards)
- Connected to STM32 via SPI

Sensitivity is good but limited by the antenna size — ~1–3 cm read range vs a desktop reader's 5–10 cm.

## LF (125 kHz) radio

**Custom analog circuit**, not a discrete IC. The STM32's built-in comparator + a tuned 125 kHz coil + driver transistor. Software-defined modulation/demodulation.

- Reads EM4x, HID Prox, Indala, AWID, Pyramid, IoProx, Hitag, etc.
- Writes T5577 (and similar rewriteable LF chips)
- Range ~3 cm

Limitations vs Proxmark3: no live sniff mode, no Hitag2 crypto attacks, no high-power TX for car-immobilizer-style fields.

## iButton (1-Wire)

**Single GPIO pin** (PA15 / GPIO 17) with a 4.7 kΩ pull-up to 3.3V.

The metallic contact pad on top of the device is the data line; ground is the case.

Software-driven 1-Wire protocol. Reads/emulates DS1990A, Cyfral, Metakom.

## Infrared

- **TX**: 940 nm IR LED, ~10 m line-of-sight range
- **RX**: TSOP-style demodulating receiver tuned for 36–40 kHz carriers
- Both connected to STM32 GPIO pins with PWM control for carrier generation

## Display

**1.4" monochrome LCD**, 128×64 pixels, ST7565R controller. Backlight via a small white LED. No color, no touch.

## SD card

**MicroSD slot** on the right edge. Filesystem: exFAT (default) or FAT32. Maximum tested: 256 GB. Cards above 32 GB usually need exFAT.

## USB

**USB-C 2.0** for charging, host comms (CDC + HID + MSC), DFU recovery (when in DFU mode).

USB CDC throughput is firmware-limited to ~10–30 KB/s. The hardware can do faster but the firmware doesn't optimize for it.

## Battery

**2000 mAh Li-Po**. Charged via USB-C. Real-world life: ~1 week on standby with light use, ~10 hours of continuous Sub-GHz scanning.

Power management IC handles charging and brownout. Battery is replaceable but requires opening the case (4 small Phillips screws).

## GPIO

18 pins on the top edge. Mix of:

- 3.3V power and ground
- USART (UART)
- I2C
- SPI (shared with internal radios — be careful)
- 1-Wire / iButton
- ADC
- PWM
- Generic GPIO (digital in/out)

Used for: external sensors, GPS modules, ESP32 dev boards (WiFi marauder), ESP32-S2 (BLE add-on), display extensions.

## What's NOT in the Flipper Zero

- WiFi — none in stock hardware. Add via ESP32 dev board on GPIO.
- 2.4 GHz Classic Bluetooth (BR/EDR) — only BLE.
- GPS — add module via UART.
- Cellular — never going to happen.
- High-power LF transmitter — limited to ~125 kHz at low TX power, can't drive car immobilizer fields.

## Relevant external add-ons (not in this repo, but commonly paired)

- **Flipper Devices' WiFi Dev Board** — ESP32-S2 board that fits the GPIO header. Marauder/EvilPortal/etc.
- **NRF24 module** — 2.4 GHz custom protocol research, mouse jacking
- **CC1101 external** — boost sub-GHz range with a directional antenna
- **EvilCrow-RF v2** — external sub-GHz analyzer board (the EvilCrowRF firmware fork in this repo targets this)

## References

- [Flipper Zero docs](https://docs.flipper.net/)
- [STM32WB55 datasheet](https://www.st.com/resource/en/datasheet/stm32wb55rg.pdf)
- [CC1101 datasheet](https://www.ti.com/lit/ds/symlink/cc1101.pdf)
- [ST25R3916 datasheet](https://www.st.com/resource/en/datasheet/st25r3916.pdf)
