# U2F / FIDO

The Flipper Zero implements the **U2F (Universal 2nd Factor)** authenticator protocol. With U2F enabled, your Flipper can be a hardware security key for compatible services (Google, GitHub, Cloudflare, etc.).

## What U2F is (briefly)

A challenge-response cryptographic protocol where:

1. You register your Flipper with a service (one-time)
2. Service stores a public key + a key handle
3. On login, service sends a challenge; Flipper signs it with the private key (which never leaves the device)
4. Browser receives signed challenge, forwards to service, login proceeds

The private key is generated per-service and **stored on the Flipper's SD card** at `/ext/u2f/`. If the SD card is destroyed, your registrations are gone (you'd need to re-register or use a backup 2FA method).

## Enabling U2F

1. Settings → System → U2F → enable
2. Connect Flipper to computer via USB
3. Open browser → security settings → add new security key
4. Browser prompts for activation; press the round button on Flipper when it's the "blinking key" state

Works in: Chrome, Edge, Firefox, Safari (desktop). Mobile is hit-or-miss.

## Where Flipper U2F shines

- **Multi-account use** — unlike many U2F keys, Flipper supports unlimited registrations (limited only by SD space)
- **Backup option** — register both Flipper and a hardware key (YubiKey, etc.) on the same account; either works
- **Visual confirmation** — Flipper screen shows the service hostname when challenged, harder to phish

## Where Flipper U2F is weak

- **Less robust than purpose-built keys** — Flipper isn't FIDO-certified. Some services may reject it.
- **No PIN/biometric protection** — anyone with physical access to your Flipper + SD card can use your registrations. **A real YubiKey requires PIN; Flipper does not.**
- **No FIDO2 / WebAuthn** — Flipper supports only legacy U2F. FIDO2 (passkeys) requires a separate authenticator.
- **SD card backup is your responsibility** — losing/wiping SD means losing all registrations
- **Some browser quirks** — older Firefox required `securitykey.fido2-extension` set; newer should work out of the box

## Recommended setup

1. **Don't use Flipper as your ONLY 2FA.** Use it as a backup, with a YubiKey (or Apple/Google passkey) as primary.
2. **Backup `/ext/u2f/` regularly.** Copy the contents to encrypted storage. Treat them like any other crypto material.
3. **Don't lend your Flipper to anyone with U2F enabled.** Disable U2F when handing it to a friend.
4. For high-security accounts (banking, primary email, server SSH): use a real hardware key. Flipper U2F is convenient but isn't certified.

## File format

U2F registrations live in:

```
/ext/u2f/
├── cnt.u2f         (counter file — tracks login count, replay prevention)
├── key.u2f         (master device key — the seed for derived per-service keys)
└── reg.u2f         (registrations — each service's key handle and pub key)
```

These are binary files. Don't edit by hand. Backup as a unit.

## Disabling

Settings → System → U2F → disable. The files in `/ext/u2f/` stay on disk; re-enabling restores all your registrations.

## Practical tip

For SSH key authentication (with FIDO-style SSH `-sk` keys):

- Flipper does NOT support SSH `-sk` keys (those need FIDO2, not U2F)
- For SSH: use a YubiKey 5 series, or a hardware key with FIDO2 support

## See also

- [Flipper U2F docs](https://docs.flipper.net/basics/u2f)
- [FIDO Alliance U2F spec](https://fidoalliance.org/specs/u2f-specs-master/fido-u2f-overview.html)
