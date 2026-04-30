# Firmware Installation

Three ways to install a firmware on the Flipper Zero.

## Method A — `fbt flash_usb_full` (recommended for source-builds)

Build and flash in one shot from the firmware's source directory:

```bash
cd forks/momentum                    # or any other firmware fork
FBT_NO_SYNC=1 ./fbt FORCE=1 flash_usb_full
```

Sequence the script performs:

1. Downloads ARM toolchain to `forks/<fw>/toolchain/` (~600 MB) on first run
2. Compiles the firmware + all bundled external apps
3. Builds the update bundle (TGZ with `firmware.dfu`, `radio.bin`, `resources.tar.gz`, `update.fuf`)
4. Pushes the bundle to `/ext/update/<version>/` on the Flipper via USB CDC
5. Sends the "start update" command — Flipper reboots into its updater UI

**Critical**: when the on-device updater UI appears asking "Press OK to start", you must press the round center button on the Flipper. fbt blocks waiting for this confirmation; if you don't see your build progressing, look at the device.

After OK, the Flipper progresses through:
- Bootloader update → reboot
- Radio coprocessor (Core2 / WPAN stack) update → reboot
- Main firmware update → reboot
- Resources install → final reboot to dolphin desktop

Total time: ~3–5 minutes after OK. **Do not unplug.**

## Method B — qFlipper (recommended for prebuilt + recovery)

```bash
brew install --cask qflipper
open -a qFlipper
```

qFlipper auto-detects the device (in normal mode OR DFU mode) and offers:

- "Update" — installs latest official Stock firmware from the cloud
- "Install from file" — accepts a custom firmware TGZ (drag `.tgz` from any fork's `dist/f7-C/flipper-z-f7-update-*.tgz`)
- "Repair" — recovers a bricked device (Flipper stuck in DFU)

This is the only method that works when the Flipper is bricked / stuck in DFU. `fbt flash_usb_full` requires the device booted to normal Flipper OS — it will hang if the Flipper is in DFU.

## Method C — Web Updater (browser, fastest for casual use)

For Stock and Momentum, both publish web installers using the Web Serial API:

- Stock: https://lab.flipper.net/
- Momentum: https://momentum-fw.dev/update

Open in **Chrome or Edge** (Web Serial isn't supported in Safari or Firefox). Plug in the Flipper, click "Connect", select the right serial port. The web app handles the rest.

Limitation: web updater requires the Flipper to boot to normal mode. It can't recover from DFU.

## Building specific targets

| Target | Result |
|---|---|
| `./fbt firmware_all` | Compile firmware only (no flash) |
| `./fbt updater_package` | Build full TGZ (firmware + radio + resources) |
| `./fbt updater_minpackage` | Build minimal TGZ (firmware only) |
| `./fbt fap_dist` | Build all `applications_user/`/external apps as `.fap` |
| `./fbt flash_usb` | Push *minimal* bundle (firmware only, no radio/resources) |
| `./fbt flash_usb_full` | Push *full* bundle (recommended) |
| `./fbt flash` | Flash via SWD (requires hardware probe — Black Magic / J-Link) |
| `./fbt jflash` | Flash via J-Link probe |
| `./fbt copro_dist` | Bundle Core2 (radio coprocessor) firmware separately |

## Forcing things

`FORCE=1` bypasses some sanity checks (e.g., refusing to flash a debug build). Use it when you know what you're doing.

`FBT_NO_SYNC=1` skips the "git submodule update --init" that fbt runs on every invocation. Useful when net is slow or you've already synced.

## Verifying

After flash completes and Flipper reboots:

```bash
# Re-enumerated device
ls /dev/cu.usbmodemflip_*

# Read firmware version via CLI
python3 -c "
import serial
s = serial.Serial('/dev/cu.usbmodemflip_<id>', timeout=2)
s.write(b'firmware_version\r\n')
print(s.read(2048).decode(errors='replace'))
"
```

Or just check the device — Settings → About → Firmware. Momentum shows "mntm-XXX" branding; Unleashed shows "unlshd-XXX"; stock shows "0.X.Y".
