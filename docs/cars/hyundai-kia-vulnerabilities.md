# Hyundai / Kia Smart-Key Vulnerabilities

Two distinct attack vectors exist as of 2024–2026. Neither uses a Flipper Zero (despite media coverage suggesting otherwise).

## 1. "Game Boy" emulator boxes

A piece of bespoke criminal hardware sold (mostly in Eastern Europe) for €15,000–€30,000.

### How it works

1. Thief approaches the target car (Ioniq 5, EV6, GV60, K5 DL3, Niro, Forte, possibly more)
2. Touches door handle to wake the car's keyless system
3. The car emits its 125 kHz LF challenge from the door antenna
4. The emulator listens for that challenge, identifies the protocol variant, and computes a valid response
5. The emulator transmits the response on UHF; the car interprets it as the key
6. Door unlocks; thief gets in
7. Touching START (or wireless charging pad for cards) gets a fresh challenge for engine start
8. Same game; engine cranks; thief drives off

### What's broken

The Hyundai-Kia keyless protocol uses a static cryptographic seed plus a counter, with insufficient validation of what's "physically possible" timing-wise. The emulator can pre-compute or cleverly elicit the key generation enough times to produce valid responses.

This is **not** a generic relay attack and **not** rolling-code replay. It's protocol-specific cryptanalysis that the criminal market discovered (or paid to acquire) and productized.

### Hyundai's response

UK Ioniq 5 owners were offered a **paid £49 update** that patches the keyless ECU to require additional validation. Customer pushback was significant (paying for a security fix). Hyundai has not extended this to all markets or all DL3-platform vehicles.

### Affected (per circulating infographic)

- Hyundai: Ioniq 5, Ioniq 6, Tucson, Sonata, Elantra (some MY)
- Kia: EV6, Niro, K5, Forte, Sportage (some MY)
- Genesis: GV60, GV70 (some MY)

Korean-spec DL3 (the owner's K5) is potentially affected but no targeted reports as of mid-2026.

## 2. "RollBack" — rolling-code RKE bypass (button fobs only)

A separate, older attack chain. Targets the **button-press RKE** side, not the proximity PKES side.

### How it works

1. Capture a rolling-code emission from the target's button press (Lock/Unlock)
2. Use a flaw in the rolling-code state-tracking implementation to find a code that *appears* to be earlier in the sequence than the latest one received
3. Re-transmit a captured-but-not-yet-used code
4. Many implementations accept "back in time" codes within a window, opening doors

This was published as **CrySys Lab's "RollBack" attack (2022)** — academic paper. Subsequently weaponized into custom Flipper Zero firmwares circulating on dark-web markets.

### Affected

Per the circulated lists: **Chrysler, Dodge, Fiat, Ford, Hyundai, Jeep, Kia, Mitsubishi, Subaru** (many models pre-2020). Vehicles from 2020+ have generally been patched.

### What it does NOT enable

- It only opens doors. It does not start the engine.
- It does not work on PKES smart keys (those don't use button-press codes).
- It does not work on cars that fully validate rolling-code state.

### Flipper involvement

Custom Flipper firmwares (sold on criminal forums) implement the RollBack attack. **They are NOT in Momentum, Unleashed, or RogueMaster.** The custom firmware required is closed-source criminal tooling, distributed through paid private channels. The owner of this repo does not have it and isn't seeking it.

## What this means for the K5 DL3 owner

- The Game Boy emulator threat is real but you need to be specifically targeted (high-value vehicle in a region where these tools are circulating)
- The RollBack attack on Korean-spec K5 DL3 — unclear if Hyundai-Kia's keyless ECU on Korean cars validates rolling state more strictly than the patched-elsewhere variants
- **Practical defenses**: Faraday pouch for the key when at home, garage parking, disable proximity unlock if comfortable losing the convenience

## Sources

- [InsideEVs: Game Boy hack on Hyundai/Kia](https://insideevs.com/news/724328/hyundai-kia-ioniq-5-gameboy/)
- [autoevolution: Hyundai £49 fix](https://www.autoevolution.com/news/hyundai-forces-ioniq-5-owners-to-pay-for-closing-the-game-boy-security-loophole-it-created-255765.html)
- [SAN: Flipper Zero key fob risk reporting](https://san.com/cc/millions-of-cars-at-risk-from-flipper-zero-key-fob-hack-experts-warn/)
- [CrySys Lab RollBack paper (2022)](https://www.crysys.hu/research/publications/) — original academic source
- [RTL-SDR: Dark Web Flipper firmware bypassing rolling codes](https://www.rtl-sdr.com/flipperzero-darkweb-firmware-bypasses-rolling-code-security/)
