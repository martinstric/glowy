# Glowy

Control the glowing Apple logo on your new MacBook Pro, right from Control Center. No extra menu bar icon.

<!-- Add media -->

**[Download Glowy](https://github.com/martinstric/glowy/releases/latest/download/Glowy.dmg)** · Requires a MacBook Pro with PROLED XDR display and macOS 27.2 or later

## Features

- **Logo Glow in Control Center.** Turn the logo's glow on or off with one click, without adding another icon to your crowded menu bar. Want one-click access anyway? Drag the control onto your menu bar.
- **Guided setup.** Two quick steps, and Glowy checks each one off by itself as you go.
- **No password prompts.** Approve Glowy once, and every toggle after that just works.
- **Clean uninstall.** One button restores Apple's default glow, removes Glowy's helper, and moves the app to the Trash.
- **Available in 15 languages:** Arabic, Chinese (Simplified and Traditional), Dutch, English, French, German, Italian, Japanese, Korean, Polish, Portuguese (Brazil), Russian, Slovak, Spanish and Turkish.

## Requirements

- A MacBook Pro with PROLED XDR display. Glowy has no effect on other Macs.
- macOS 27.2 or later.

## Installation

1. Download **Glowy.dmg** from the [latest release](https://github.com/martinstric/glowy/releases/latest), open it, and drag Glowy to your **Applications** folder.
2. Open Glowy from Applications and click **Get Started**.
3. **Let Glowy run in the background.** Click **Approve Glowy**. macOS shows a notification. Click it, switch on Glowy under **Background App Activity**, and confirm with Touch ID or your password. If you miss the notification, click **Open Login Items** to go straight there.
4. **Add Glowy to Control Center.** Open Control Center, click **Edit Controls**, search for **Glowy**, and drag **Logo Glow** into place.

When Glowy says **You're all set**, close the window. Glowy doesn't need to stay open: the Control Center toggle works on its own.

> [!NOTE]
> Run Glowy from your Applications folder. macOS ties the background helper to the app's location, so moving Glowy after setup can break the toggle.

## How it works

Apple doesn't offer a setting for the glowing logo, but it documents a pair of Terminal commands in its [support article](https://support.apple.com/en-us/149248):

```sh
# Turn the logo off
sudo defaults write com.apple.CoreBrightness LEBacklightMode -int 0

# Turn it back on (Apple's default)
sudo defaults delete com.apple.CoreBrightness LEBacklightMode
```

Glowy runs exactly these commands for you. Because they need administrator rights, Glowy includes a small helper, **GlowyHelper**, which macOS registers as a background item when you approve Glowy during setup. launchd starts it on demand when you use the toggle.

### What the helper can and can't do

GlowyHelper runs with system privileges, so it's deliberately narrow:

- It only reads, sets or removes one preference: `LEBacklightMode` in `com.apple.CoreBrightness`, using `/usr/bin/defaults`.
- It only accepts connections from Glowy and its Control Center extension, and only when they're signed by Glowy's developer team.
- It has no other commands and makes no network connections.

The whole helper is in [`GlowyHelper/LogoService.swift`](GlowyHelper/LogoService.swift) if you'd like to check.

## Uninstalling

Open Glowy and click **Uninstall**. Glowy turns the logo's glow back on, removes the helper from Login Items, moves itself to the Trash, and quits.

If you've already deleted Glowy another way:

- Restore the glow with `sudo defaults delete com.apple.CoreBrightness LEBacklightMode`.
- Switch off any leftover Glowy entry in **System Settings › General › Login Items & Extensions**.

## Building from source

Requires Xcode 27.3 or later.

| Target | What it is |
|---|---|
| **Glowy** | The app: welcome screen, setup, the in-app toggle and uninstall |
| **GlowyControlExtension** | The Logo Glow Control Center toggle (WidgetKit) |
| **GlowyHelper** | The privileged launch daemon that changes the preference, reached over XPC |

### Signing with your own team

The helper checks exactly who is calling it, so the team ID and identifiers appear in a few places. To build with your own Apple Developer team, update all of them:

1. **Signing & Capabilities:** set your team, and your own bundle identifiers, on all three targets.
2. **`GlowyHelper/LogoService.swift`:** the team ID and bundle identifiers in `codeSigningRequirement`.
3. **`Glowy/Shared/GlowyHelperProtocol.swift`:** `machServiceName`, `plistName` and `controlKind`.
4. **`Glowy/ca.martinstric.Glowy.helper.plist`:** `Label`, `MachServices` and `AssociatedBundleIdentifiers`. Rename the file to match `plistName`.
5. **`GlowyControl/GlowyControl.entitlements`:** the mach service name.

### Development tips

- Debug builds add **Show Welcome Screen** to the app menu so you can replay onboarding.
- macOS remembers that you approved the helper, even after you delete the app, so reinstalling won't show the approval notification again. To test the first-run experience, run `sfltool resetbtm` and restart. This resets background items for **all** apps, so a macOS virtual machine is the more comfortable way to test it repeatedly.

## Contributing

Bug reports and pull requests are welcome. Please open an issue first for larger changes.

## License

Glowy is available under the MIT License. See [LICENSE](LICENSE) for details.

---

Glowy is not affiliated with or endorsed by Apple Inc. Apple and MacBook Pro are trademarks of Apple Inc., registered in the U.S. and other countries.
