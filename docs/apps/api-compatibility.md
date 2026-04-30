# App API Compatibility (the `.fap` ABI problem)

## The mechanism

Each Flipper firmware version has a numbered API revision (e.g., `87.1`). When you build a `.fap` file with `ufbt build`, the resulting binary embeds the API version it was compiled against. The Flipper firmware loader checks this on launch:

- API matches: app loads ✅
- API differs: "API version mismatch" error, app refuses to load ❌

This is intentional — it prevents old apps using removed/renamed APIs from crashing the device.

## Where each firmware sits

As of mid-2026:

| Firmware | API | Notes |
|---|---|---|
| Stock OFW | 87.x (latest 87.1) | Reference |
| Momentum (mntm-012) | 87.1 | Tracks stock closely |
| Momentum-Apps | 87.1 | Same as Momentum |
| Unleashed (unlshd-015) | own UL ABI | Diverges from stock |
| RogueMaster (RM0422) | tracks UL | Diverges from stock |
| SyberxSpace (RM-derived) | tracks RM | Diverges from stock |

## Practical compatibility matrix

| App built for → Run on ↓ | Stock | Momentum | Unleashed | RogueMaster |
|---|---|---|---|---|
| **Stock** | ✅ | ✅ usually | ❌ | ❌ |
| **Momentum** | ✅ usually | ✅ | ❌ | ❌ |
| **Unleashed** | ❌ | ❌ | ✅ | ✅ usually |
| **RogueMaster** | ❌ | ❌ | ✅ usually | ✅ |

The "usually" cases: stock and Momentum diverge slightly. Apps using only common APIs work both ways. Apps using Momentum-specific extensions (extra Sub-GHz protocols, BLE Spam infrastructure) won't work on stock.

## Where to get apps that "just work"

For Momentum (current firmware): use **`forks/momentum-apps/`** — every app there is Momentum-tested. Built into Momentum's `resources.tar.gz` so deploying the firmware update bundle includes them.

For Stock OFW: use **Flipper App Lab** — https://lab.flipper.net/ — official catalog. Web-based installer.

For Unleashed/RogueMaster: each firmware bundles its preferred apps. They aren't generally available standalone.

## What about the UberGuidoZ Applications/ folder?

`forks/uberguidoz-flipper/Applications/` has 858 pre-compiled `.fap` files. They're organized by firmware target:

```
Applications/
├── Custom (UL, RM)/
│   ├── RogueMaster/        # API: RogueMaster's ABI
│   └── Unleashed/          # API: Unleashed's ABI
├── Official/               # API: older stock versions
└── UberGuidoZ/             # API: varies, often older stock
```

**Most won't load on Momentum.** Some that ARE Momentum-compatible (built against close-enough API) will work — but it's a lottery. The owner removed UberGuidoZ Applications from the SD deployment for this reason.

## Building your own for the current firmware

1. **Confirm SDK target**: `~/Library/Python/3.14/bin/ufbt update --index-url=https://up.momentum-fw.dev/firmware/directory.json --channel=release` (for Momentum)
2. **Build**: `cd <app-source>/ && ufbt build`
3. **Output**: `~/.ufbt/build/<appid>.fap`
4. **Deploy**: copy to `/Volumes/Flipper SD/apps/<Category>/`

The `apps/tpms/` and `apps/ble-spam/` submodules in this repo are examples of apps built from source against Momentum SDK. Both produced working `.fap` files for Momentum.

## What if I really want an old `.fap` to run

Three options:

1. **Find the source** — most apps have a public repo. Check `application.fam` for `fap_weburl`. Build against current Momentum SDK.
2. **Match the firmware** — flash the firmware that the `.fap` was built for. Then flash back when done.
3. **Skip it** — there's almost certainly a Momentum-Apps equivalent.

## Sources

- [Flipper Application development docs](https://docs.flipper.net/development/applications)
- [ufbt user guide](https://github.com/flipperdevices/flipperzero-ufbt)
- [Momentum-Apps repo](https://github.com/Next-Flip/Momentum-Apps)
