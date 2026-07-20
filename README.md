<!-- markdownlint-disable MD004 MD033 -->

<div align="center">

**English** | [Русский](README_RU.md)

# LagBar

![Lua 5.1](https://img.shields.io/badge/Lua-5.1-2C2D72?style=flat-square&logo=lua&logoColor=white)
![WoW 3.3.5a](https://img.shields.io/badge/WoW-3.3.5a-C79C6E?style=flat-square)
[![License](https://img.shields.io/github/license/darhanger/LagBar?style=flat-square)](https://github.com/darhanger/LagBar/blob/master/LICENSE)
[![Last Release](https://img.shields.io/github/v/release/darhanger/LagBar?style=flat-square)](https://github.com/darhanger/LagBar/releases/latest)
[![Release Downloads](https://img.shields.io/github/downloads/darhanger/LagBar/1.5/total?style=flat-square)](https://github.com/darhanger/LagBar/releases)
[![All Downloads](https://img.shields.io/github/downloads/darhanger/LagBar/total?style=flat-square)](https://github.com/darhanger/LagBar/releases)
[![Discord Server](https://img.shields.io/badge/Discord-7289DA?style=flat-square&logo=discord&logoColor=white)](https://discord.gg/ZKFkvrzaU4)

**LagBar** is a lightweight and movable World of Warcraft information bar that displays your current FPS, latency, network traffic and total addon memory usage.

Designed for **World of Warcraft 3.3.5a**.

</div>

## Features

LagBar provides a compact overview of the game client's current performance and network state.

The addon can display:

- **FPS** — the current number of rendered frames per second.
- **Latency** — the current connection latency in milliseconds.
- **Incoming traffic** — the current download rate in KB/s.
- **Outgoing traffic** — the current upload rate in KB/s.
- **Addon memory** — total memory currently used by loaded non-Blizzard addons.
- **Dynamic colors** — values change from green to yellow and red depending on their quality.
- **Automatic width** — the frame expands when optional information is enabled.
- **Saved settings** — position, scale, lock state, background and display options are restored between sessions.

FPS and latency are always visible. Network traffic and addon memory can be enabled separately.

## Addon usage tooltip

When addon memory display is enabled, move the cursor over LagBar to open a detailed tooltip.

The tooltip shows:

- the **15 addons using the most memory**;
- memory usage in KB or MB;
- addon CPU usage when WoW script profiling is enabled.

CPU information is available only when the client CVar `scriptProfile` is enabled.

> Enabling script profiling can reduce game performance. Use it only when profiling addons.

## Movable frame

LagBar can be placed anywhere on the screen.

- Drag the frame with the **left mouse button** while it is unlocked.
- Click the frame with the **right mouse button** to lock or unlock it.
- Use `/lagbar reset` to return it to the center of the screen.
- Use `/lagbar scale` to change its size.

The selected position, scale and lock state are saved automatically.

## Display example

Depending on the enabled options, LagBar may display information similar to:

```text
FPS 60 | Ms 45
```

```text
FPS 60 | Ms 45 | In: 4.25 KB/s | Out: 1.10 KB/s
```

```text
FPS 60 | Ms 45 | In: 4.25 KB/s | Out: 1.10 KB/s | Mem: 18.7 MB
```

<div align="center">

![LagBar preview](https://i.ibb.co/RyY0wJJ/image.png)

</div>

## Slash commands

Use `/lagbar` without arguments to display the available commands in chat.

| Command | Description |
| --- | --- |
| `/lagbar reset` | Reset the frame position to the center of the screen. |
| `/lagbar bg` | Show or hide the frame background. |
| `/lagbar scale <value>` | Change the frame scale. |
| `/lagbar memory` | Enable or disable total addon memory display. |
| `/lagbar net` | Enable or disable incoming and outgoing network traffic. |

Scale examples:

```text
/lagbar scale 0.75
/lagbar scale 1
/lagbar scale 1.25
/lagbar scale 1.5
```

## Installation

1. Download the latest version from the [Releases](https://github.com/darhanger/LagBar/releases) page.
2. Extract the downloaded archive.
3. Copy the `LagBar` addon folder into:

```text
World of Warcraft\Interface\AddOns\
```

4. Make sure the resulting folder structure looks similar to:

```text
World of Warcraft
└── Interface
    └── AddOns
        └── LagBar
            ├── LagBar.toc
            ├── LagBar.xml
            ├── LagBar.lua
            ├── Locales
            ├── AceLocale-3.0
            └── LibStub
```

5. Restart the game client.
6. Enable **LagBar** in the character selection addon list.

## Usage

LagBar starts automatically after logging into the game.

A typical setup process:

1. Right-click LagBar to unlock it.
2. Drag it to the desired position.
3. Right-click it again to lock the frame.
4. Enable optional information using `/lagbar memory` and `/lagbar net`.
5. Adjust its size using `/lagbar scale <value>`.

No external libraries or separate configuration addon is required.

## Performance

LagBar updates displayed statistics once per second.

The addon avoids rebuilding the displayed text when its values have not changed. Loaded addons are cached, and the memory tooltip only calculates its detailed ranking when it is opened.

Memory monitoring itself requires WoW to refresh addon memory statistics, so keeping `/lagbar memory` enabled has more overhead than displaying only FPS and latency.

## ElvUI support

LagBar automatically detects ElvUI and adjusts its frame border to better match an ElvUI-based interface.

ElvUI is optional and is not required for the addon to work.

## Compatibility

- World of Warcraft **3.3.5a**
- Interface version **30300**
- Lua **5.1**
- Standard Blizzard UI
- Optional ElvUI integration
- AceLocale-3.0 localization framework

Behavior on heavily modified custom clients may vary if their implementations of `GetNetStats`, addon profiling or saved variables differ from the original client.

## Why use LagBar?

LagBar gives you essential performance information without opening the default system menu or installing a large monitoring package.

It can be useful for:

- monitoring FPS during raids and battlegrounds;
- identifying latency spikes;
- observing incoming and outgoing network traffic;
- checking total addon memory usage;
- finding addons with unusually high memory consumption;
- profiling addon CPU usage during development;
- testing performance changes after modifying the UI.

## Support

For bug reports, feature requests and suggestions, use:

- [GitHub Issues](https://github.com/darhanger/LagBar/issues)

When reporting a problem, include:

- the game client or server name;
- the LagBar version;
- the command or action that caused the issue;
- Lua error text, when available;
- a screenshot of the LagBar frame;
- whether ElvUI or script profiling is enabled.

## Credits

Original LagBar by **Derkyle**.

Modified and maintained by **DarhangeR**.

## Contributing

Contributions are welcome.

You can help by:

- reporting bugs;
- testing the addon on different 3.3.5a servers;
- improving localization;
- improving performance monitoring;
- submitting pull requests;
- updating documentation.

## License

This project is distributed under the terms of the [MIT License](https://github.com/darhanger/LagBar/blob/master/LICENSE).

---

<div align="center">

Made for World of Warcraft 3.3.5a

[Download](https://github.com/darhanger/LagBar/releases) ·
[Report an issue](https://github.com/darhanger/LagBar/issues) ·
[Discord](https://discord.gg/ZKFkvrzaU4)

</div>