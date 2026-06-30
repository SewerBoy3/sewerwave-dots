# sewerwave-dots

**Synthwave Pastel dotfiles for Arch Linux + i3wm — built for Sewer boy.**

> One command turns a minimal Arch install into a complete, opinionated desktop — light on RAM, heavy on vibe.

Inspired philosophically by [Omakub](https://omakub.org) and [Omarchy](https://omarchy.org): a single entry point, zero manual ricing afterward. Unlike Omarchy (Hyprland/Wayland), **sewerwave-dots uses i3wm on X11** — deliberate choice for old integrated GPUs and 4 GB RAM machines.

<!-- TODO: screenshot -->

## Features

- **i3-wm** (official package, native gaps — no `i3-gaps` fork)
- **Synthwave Pastel** palette across i3, picom, polybar, rofi, kitty, starship, zellij, fastfetch
- **~300 MB idle target** (i3 + picom + polybar + wallpaper, no apps open)
- **TTY autologin + startx** — no GDM/SDDM/LightDM bloat (`ly` documented as optional alternative)
- **zRAM** via `zram-generator` (zstd, swappiness 180)
- **Workflow dirs:** `~/Developer`, `~/GameDev`, `~/Studio`
- **Heavy apps on demand:** Antigravity, Godot 4, LMMS — never autostarted

## Prerequisites

- Fresh **Arch Linux** base install (no desktop meta-package)
- Internet connection
- Non-root user with **sudo**
- **base-devel** (installed automatically if missing)

## Installation

```bash
git clone https://github.com/SewerBoy3/sewerwave-dots.git ~/sewerwave-dots
cd ~/sewerwave-dots
./install.sh
```

Non-interactive:

```bash
./install.sh --yes
```

### One-liner (review before running)

```bash
curl -fsSL https://raw.githubusercontent.com/SewerBoy3/sewerwave-dots/main/install.sh | bash
```

> **Security:** piping curl to bash skips your chance to audit the script. Clone the repo and read `install.sh` + `scripts/` first.

Log file: `~/.sewerwave-install.log`

After install, **log out and back in** (or reboot), then verify baseline RAM:

```bash
free -h
```

## Optional: graphical login with `ly`

If you prefer a TUI display manager over tty autologin:

```bash
sudo pacman -S ly
sudo systemctl enable ly.service
```

Comment out the `startx` block in `~/.config/zsh/.zprofile`.

## Repository structure

```
sewerwave-dots/
├── install.sh              # Orchestrator (runs scripts/ in order)
├── config/                 # Symlinked to ~/.config/*
├── scripts/                # Modular install steps
├── assets/                 # Wallpaper, palette, branding
└── workspace/              # Docs for ~/Developer, ~/GameDev, ~/Studio
```

## Palette (Synthwave Pastel)

| Token | Hex | Use |
|-------|-----|-----|
| bg | `#1A1626` | Main background |
| bg-alt | `#221D33` | Panels, bars |
| border-inactive | `#3A3354` | Inactive borders |
| fg | `#E8E1F5` | Primary text |
| fg-muted | `#9C90B5` | Secondary text |
| accent-purple | `#B79CED` | Focus, active borders |
| accent-red | `#D98C8C` | Secondary accent |
| accent-cyan | `#8FD3E8` | Secondary accent |
| accent-pink | `#F0B8D0` | Tertiary accent |
| accent-green | `#A8D9B0` | Terminal success only |
| accent-yellow | `#E8D9A0` | Terminal warnings only |

Machine-readable: `assets/branding/palette.json`

## Keybindings (i3)

| Keys | Action |
|------|--------|
| `Mod+Return` | Terminal (kitty) |
| `Mod+d` | App launcher (rofi drun) |
| `Mod+Shift+q` | Kill window |
| `Mod+1–0` | Switch workspace |
| `Mod+Shift+1–0` | Move window to workspace |

## Services

**Enabled:** NetworkManager, PipeWire, WirePlumber (user)

**Disabled by default:** CUPS, Avahi, Bluetooth, MariaDB (installed but not running — start with `sudo systemctl start mariadb` when needed)

## Workflows

See [workspace/README.md](workspace/README.md) for directory layouts.

### Web dev
Antigravity (AUR or official tarball), Chromium, Node.js, npm, git, SQLite, MariaDB.

### Game dev
Godot 4.x, Mesa — use **Compatibility (GLES3)** renderer on integrated graphics.

### Audio / content
LMMS, PipeWire low-latency config. Tune `min-quantum` in `99-lowlatency.conf` if your interface allows.

## picom notes

- Blur **off** by default (`blur-method = "none"`)
- `corner-radius = 10`
- Backend `glx`; switch to `xrender` in `~/.config/picom/picom.conf` if unstable

## Hardware assumptions

Designed for **2-core Celeron + 4 GB RAM**. If idle RAM exceeds ~300 MB after login, check for autostart apps or user services.

## Credits

Built for **Sewer boy** — synthwave pastel ricing for the underground.

## License

MIT — see [LICENSE](LICENSE).
