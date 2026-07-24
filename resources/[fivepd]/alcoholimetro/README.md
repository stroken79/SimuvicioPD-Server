# Swift Studios — Alcotest 7510 Breathalyzer

A standalone FiveM resource that recreates the **Dräger Alcotest 7510** handheld breathalyzer for immersive police roleplay.

Officers can pull out the device, test the closest nearby player, and receive realistic passive or evidential readings — complete with device UI, subject prompts, proximity audio, and configurable permissions.

![FiveM](https://img.shields.io/badge/FiveM-Standalone-blue)
![Lua](https://img.shields.io/badge/Lua-5.4-purple)
![Version](https://img.shields.io/badge/version-1.0.0-green)

---

## Features

- **Authentic device UI** — Dräger-style handheld interface with live clock, passive/evidential modes, and animated screen states
- **Two test modes**
  - **Passive** — subject selects **PASS** or **FAIL**
  - **Evidential** — subject enters a numeric reading (default legal limit: **0.250 mcg**)
- **Closest-player detection** — automatically targets the nearest player within range
- **Subject overlay** — tilted bottom-right prompt on the testee's screen
- **Proximity audio** — beeps and analyzing sounds originate from the tester and fade with distance
- **Fully configurable** — commands, keybind, distances, limits, audio, permissions, and more
- **Permission system** — open access, ACE permissions, or a custom hook for framework integration

---

## Requirements

- FiveM server (Cerulean+)
- No framework required — **standalone**

---

## Installation

1. Download the latest release
2. Place the resource in your `resources` folder
3. Add to your `server.cfg`:

```cfg
ensure SwiftDUI
```

4. Restart your server

---

## Usage

| Input | Action |
|-------|--------|
| `/bt` or `/breathalyzer` | Open / close the breathalyzer |
| Keybind | Bindable in **Settings → Key Bindings → FiveM** (no default key) |
| **Down arrow** | Switch between Passive and Evidential mode |
| **OK** | Start test / confirm result |
| **Escape / Backspace** | Close the device |

### Test flow

1. Officer opens the device and selects test mode
2. Officer presses **OK** — closest player is selected
3. Subject enters their result (PASS/FAIL or BAC reading)
4. Both screens show **Wait / Analyzing** with testing audio
5. Results display on both devices; officer confirms to finish

---

## Configuration

All options are in `config.lua`.

| Section | Description |
|---------|-------------|
| `Config.Permissions` | `open`, `ace`, or `custom` permission modes |
| `Config.Commands` | Enable/disable chat commands and suggestion text |
| `Config.Keybind` | Keybind command name and optional default key |
| `Config.Testing` | Subject distance, analyzing duration, default mode |
| `Config.Evidential` | Legal limit, max input, decimal places, unit label |
| `Config.Audio` | Proximity sound toggle and hear distance |
| `Config.UpdateChecker` | GitHub release checker and startup banner |

### ACE permissions example

```cfg
add_ace group.police sstudios.breathalyzer.use allow
add_principal identifier.license:YOUR_LICENSE group.police
```

Set `Config.Permissions.Mode = 'ace'` in `config.lua`.

### Custom permissions

Set `Config.Permissions.Mode = 'custom'` and edit `CustomCanUseBreathalyzer()` in `server/permissions.lua`.

---

## Exports

```lua
exports['SwiftDUI']:CanUseBreathalyzer(source)
```

---

## Support

- **GitHub Issues** — bug reports and feature requests
- **Discord** — [Swift Studios](https://discord.gg/cSVeQcAVH3)

---

## Credits

**Swift Studios**

Licensed for use on FiveM servers. Do not redistribute without permission.
