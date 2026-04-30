# Recovery from DFU / Brick

A "bricked" Flipper that boots only into DFU (STMicroelectronics "DFU in FS Mode" appears in `system_profiler SPUSBDataType`) is fully recoverable. The CC1101, ST25R3916, and the SD card filesystem are untouched — only the STM32WB55's flash is suspect.

## How DFU mode is entered

Three ways:

1. **Intentional**: hold `LEFT + BACK` while pressing `BACK` (reboot). Used to flash via dfu-util or qFlipper.
2. **Failed update**: an interrupted firmware install can leave the device in a half-state where the bootloader falls into DFU.
3. **Hard hang**: ultra-rare; pressing LEFT + BACK forces it.

In all cases, the **STM32 ROM bootloader** takes over USB and exposes the standard DFU interface (VID 0x0483, PID 0xDF11).

## Symptom check

```bash
system_profiler SPUSBDataType | grep -B1 -A4 "STMicroelectronics"
```

Expected when in DFU:

```
USB Product Name: DFU in FS Mode
USB Vendor Name: STMicroelectronics
```

`/dev/cu.usbmodemflip_*` will **not** be present in DFU. The device only exposes the DFU interface, not USB CDC.

## Recovery method 1 — qFlipper (recommended)

qFlipper is purpose-built for this exact case. Install:

```bash
brew install --cask qflipper
```

Open the app. With the Flipper plugged in (DFU mode):

1. qFlipper detects the device
2. Header shows the device serial and "Recovery" button
3. Click **Repair** → the app downloads the latest stock firmware bundle and walks the device through:
   - Bootloader install via DFU
   - Radio coprocessor install
   - Main firmware install
   - Resource extraction to SD card
4. After ~2 minutes, dolphin reappears and the Flipper is fully restored

If you want to recover to a **specific** firmware (e.g., Momentum), use "Install from file" and point at a `.tgz` from `forks/<fw>/dist/f7-C/flipper-z-f7-update-*.tgz`.

## Recovery method 2 — `fbt` (only after device exits DFU)

Once the device is out of DFU and back in normal mode:

```bash
cd forks/momentum
./fbt FORCE=1 flash_usb_full
```

fbt **cannot recover from DFU directly** because `flash_usb_full` uses the qFlipper protocol over USB CDC, which only exists in normal-mode firmware. Use Method 1 first to get out of DFU, then Method 2 to install your preferred firmware.

## Recovery method 3 — `dfu-util` manual

Lower-level fallback. Requires `dfu-util`:

```bash
brew install dfu-util
```

Build the firmware:

```bash
cd forks/momentum
./fbt updater_package
```

Identify the dfu file (in `dist/f7-C/`) and flash:

```bash
dfu-util -a 0 -s 0x08000000:leave \
  -D dist/f7-C/flipper-z-f7-full-mntm-dev-*.dfu
```

This flashes only the main firmware. **It does NOT install the radio coprocessor stack or extract resources to SD.** You'll have a barely-functional device. Use only as a last resort. For full recovery, use qFlipper.

## Forcing exit from DFU

If you're in DFU and just want out (no firmware change):

- Hold `BACK` for ~10 seconds → Flipper reboots; if firmware is intact, it boots normally
- Or: power off (`POWER + BACK` for 10 sec), then press `POWER` to boot

If neither works, the firmware itself is corrupt — go to Method 1.

## Worst case — hardware-level recovery

If qFlipper can't see the device at all (no DFU enumeration even though the Flipper is plugged in):

- Try a different USB cable (data cable, not charge-only)
- Try a different USB port (USB 2.0 hub helps with marginal signals)
- Reset by holding all buttons for 30 seconds
- If still nothing: SWD recovery via Black Magic Probe, J-Link, or a Raspberry Pi running OpenOCD. Connect to TP1/TP2 (SWDIO/SWCLK) on the Flipper's PCB. This is a soldering iron / TC2030 probe job — requires opening the case.

The owner has not had to go this deep yet.
