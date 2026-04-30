# iButton

iButton (also called 1-Wire or "touch memory") is Maxim/Dallas's contact-based ID protocol. The "buttons" are stainless-steel canisters touched against a reader. Found in:

- Russian/Eastern European apartment intercoms (most common use today)
- Pre-2010 access cards and time-clocks in Western enterprise
- Some pet/livestock identification

## Common chip families

| Family | Bits | Read-only? | Notes |
|---|---|---|---|
| **DS1990A** | 64 | RO | Original "iButton" — most common |
| **Cyfral** | 16 | RO | Russian-originated, used in Soviet-era intercoms |
| **Metakom** | 32 | RO | Russian, intercom systems |
| **DS1996** / others | varies | RW | Newer with rewriteable memory |

Flipper supports reading and emulating all of these.

## Workflow on Flipper

### 1. Read

iButton → **Read** → touch the original key to the GPIO pin pads on the top edge of the Flipper (specifically the dedicated 1-Wire pad — labeled, near the GPIO connector).

Flipper detects family + ID. Display shows raw hex.

### 2. Save & emulate

Saved as `.ibtn` in `/ibutton/`. Emulation: select saved → **Emulate** → touch the Flipper's pad to the reader.

Almost all iButton readers are unauthenticated — they accept any matching ID. Cloning works perfectly for these.

### 3. Write to a blank

iButton → saved file → **Write** → touch a writeable iButton blank (RW1990 or similar). Now the blank acts as the original.

Many sites that sell "iButton blanks" sell rewritable RW1990 / TM2004 chips that look identical to the read-only original. Often used in apartment intercom services to issue replacement keys.

## Collections in this repo

`/Volumes/Flipper SD/ibutton/Starnew/` (deployed) has:
- StarButton/ — random key collection from the glutesha/Flipper-Starnew repo
- OfficeMet.ibtn, Kondor.ibtn, VizOff.ibtn — specific Russian intercom keys

These are mostly useful as illustrative examples / curiosities. Don't expect them to open YOUR building's intercom (each apartment building has its own keys).

## Why iButton at all in 2026

iButton is genuinely 1980s tech. It persists because:

1. **Apartment building intercoms in Eastern Europe** standardized on iButton in the 1990s and never moved off
2. The hardware is dead-simple (one wire, one VCC/GND pair), reliable in cold/dusty environments
3. Replacing the entire intercom system is expensive

If your building uses RFID cards or NFC fobs for the entry phone, you have a more modern setup. iButton is dying out except in legacy installations.

## Hardware

The Flipper's iButton interface uses GPIO pin 17 (1-Wire data) with internal pull-up to 3.3V. The pad on the device is a metallic contact — touch the iButton to it for both read and emulation.

For Proxmark3 RDV4: it doesn't natively support iButton (different physical interface). Flipper is the right tool here.
