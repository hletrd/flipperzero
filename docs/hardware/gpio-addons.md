# GPIO Add-ons

The Flipper Zero exposes 18 GPIO pins on the top edge. They're the Flipper's expansion path — most non-trivial radios, sensors, and peripherals attach here.

## Pinout

```
  1 (3.3V)  ●  ●  18 (GND)
  2 (SWC)   ●  ●  17 (PA15) — also iButton 1-Wire data
  3 (SWD)   ●  ●  16 (PB14) — RFID (LF) Pull
  4 (NRST)  ●  ●  15 (PC0)  — RFID Carrier
  5 (PA7)   ●  ●  14 (USART1 RX, PB7)
  6 (PA6)   ●  ●  13 (USART1 TX, PB6)
  7 (PA4)   ●  ●  12 (PB3)  — SPI MOSI for ext devices
  8 (PB3 alt) ●  ●  11 (PB2)
  9 (5V switched) ●  ●  10 (PC1)
```

(Labels approximate; consult the [Flipper GPIO docs](https://docs.flipper.net/development/hardware/gpio) for the exact mapping.)

Pin 1 (3.3V) and pin 9 (5V switched, controllable via `power 5v 1`) are the main power outputs. Pin 18 (GND).

## Common add-on boards

### WiFi Dev Board (ESP32-S2)

Official Flipper Devices accessory. ESP32-S2 with antenna, 3-pin connector that plugs into Flipper's USART (TX/RX/GND).

| Use case | Firmware |
|---|---|
| WiFi Marauder (deauth, beacon spam, sniffing) | https://github.com/0xchocolate/flipperzero-wifi-marauder |
| EvilPortal (WiFi captive portal phishing) | https://github.com/bigbrodude6119/flipper-zero-evil-portal |
| ESPHome / WLED gateway | Custom flash with esphome.io |
| BadBLE (BLE keyboard) | Already covered by Flipper's built-in BLE — board is more for WiFi |

Flash with esp-idf or via `forks/momentum/scripts/wifi_dev_board_update.py`.

### NRF24L01 module

Cheap 2.4 GHz transceiver, often used for old wireless mice/keyboards.

| Use case | App |
|---|---|
| MouseJack (Logitech wireless mouse hijack) | `nrf24_mousejack` (in Momentum-Apps) |
| Keyjack (wireless keyboard sniff) | `nrf24scan` |
| Custom 2.4 GHz protocol research | `nrf24batch` for batch test |

Connection: NRF24 MISO/MOSI/SCK/CSN/CE → Flipper SPI pins (PA6/PA7/PB3/PA4).

### GPS module (NEO-6M / NEO-M8N)

UART-connected GPS receiver. Connects to USART1 (TX/RX) and 3.3V power.

| Use case | App |
|---|---|
| GPS NMEA decoder | `gps_nmea_uart` (built-in to Momentum) |
| Sub-GHz georeferenced captures | `subghz_gps` (Momentum-Apps — overlays GPS on Sub-GHz reader) |
| Wardriving / RF surveying | combine with WiFi Marauder for geolocated scans |

Wiring (NEO-6M):
```
NEO-6M VCC  → Flipper 3.3V (pin 1)
NEO-6M GND  → Flipper GND (pin 18)
NEO-6M TX   → Flipper RX (pin 14)
NEO-6M RX   → Flipper TX (pin 13)
```

Open `gps_nmea_uart` app, set baud (typically 9600), wait for fix (~30 sec outdoor first time).

### External CC1101 (extended Sub-GHz)

For longer Sub-GHz range or dual-radio operation:

- **Generic CC1101 module** (~$5) wired to Flipper's SPI + custom GPIO pins
- **EvilCrow-RF v2** purpose-built dual-CC1101 board — see [`forks/evilcrowrf/`](../../forks/evilcrowrf/) for the firmware that drives it

External CC1101 doesn't replace Flipper's internal — it augments. Use it to listen on one frequency while internal scans another, or for higher TX power with a directional antenna.

### Logic analyzer / Bus Pirate alternatives

GPIO can be commandeered for logic-level signaling research:

- **Saleae Logic clone** — connect 8 GPIO pins to a bus, sniff with `pulseview` on Mac
- **Bus Pirate emulation** — the `bus_pirate.fap` app turns Flipper into a poor-man's Bus Pirate (I2C/SPI/UART/JTAG bit-banging)

### iCSP (in-circuit programmer)

`avr_isp.fap` (in `/apps/GPIO/Debug/`) makes the Flipper an Arduino ISP programmer. Wire up:

```
Flipper PA7 → AVR MOSI
Flipper PA6 → AVR MISO  
Flipper PB3 → AVR SCK
Flipper PA4 → AVR RESET
GND/3.3V    → AVR GND/VCC
```

Then use avrdude with `-c arduino -P /dev/cu.usbmodemflip_*` to flash AVR chips.

### SPI memory dumper

`spi_mem_manager.fap` (in `/apps/GPIO/Debug/`) reads/writes 25-series SPI flash chips. Useful for:

- Dumping firmware from IoT devices, routers
- Backing up BIOS chips before risky reflash
- Cloning game cartridge ROMs (where SPI flash is used)

### I2C Tools

`i2ctools.fap` — scan I2C bus, read/write registers. Pair with cheap I2C sensor breakouts (BME280 weather, MPU6050 IMU) for quick experiments.

### USB-to-Serial bridge

Flipper can act as a USB-to-USART bridge (Apps → GPIO → USB-UART Bridge). Connect to UART pins on a router/embedded device, get serial console on Mac via `screen /dev/cu.usbmodemflip_* 115200`.

### Servo / PWM driver

`Servo Tester` and `pwm_generator` apps drive servos or PWM-controlled devices on any GPIO pin.

## Power budget

The Flipper's 5V output (pin 9, `power 5v 1`) is current-limited:

- ~150 mA continuous
- Cannot drive heavy WiFi (ESP32 can spike to 500 mA on TX)
- For high-current loads (motors, big LEDs, RPi Zero), use external power and just use Flipper for signaling

3.3V output (pin 1):

- ~50 mA recommended
- For sensors and small modules

## Don't

- **Don't** apply more than 3.3V to GPIO inputs (PA15 etc) — STM32 isn't 5V-tolerant on most pins. SPI/UART are 3.3V logic.
- **Don't** short power rails — protection is minimal; you'll PCB-damage the Flipper
- **Don't** plug add-ons in while powered if you're unsure of pinout — power down first

## Wiring guide

The Flipper GPIO pads accept 0.1" (2.54mm) Dupont jumpers. Most add-on boards come with Dupont cables. For permanent installs, solder a header.

Reference card (printable): [Flipper GPIO pinout](https://docs.flipper.net/gpio-and-modules)
