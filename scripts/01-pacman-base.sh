#!/usr/bin/env bash
# Core system packages: i3/X11 stack, terminals, utilities
set -euo pipefail

# shellcheck source=lib/helpers.sh
source "${SEWERWAVE_REPO_ROOT}/scripts/lib/helpers.sh"

PACMAN_PACKAGES=(
    # Build tools
    base-devel
    git

    # X11 + i3 (official i3-wm includes gaps since 4.22)
    xorg-server
    xorg-xinit
    xorg-xrandr
    xorg-xsetroot
    i3-wm
    i3status
    picom
    polybar
    rofi
    feh
    dunst
    lxappearance
    gtk3
    adwaita-icon-theme
    papirus-icon-theme

    # Fonts
    ttf-jetbrains-mono-nerd
    noto-fonts
    noto-fonts-emoji

    # Terminal + shell
    kitty
    zsh
    zsh-autosuggestions
    zsh-syntax-highlighting

    # Multiplexer + prompt + sysinfo
    zellij
    starship
    fastfetch

    # Audio (PipeWire stack)
    pipewire
    pipewire-pulse
    pipewire-alsa
    pipewire-jack
    wireplumber
    pavucontrol

    # Networking
    networkmanager

    # zRAM
    zram-generator

    # Monitoring
    htop
    btop

    # Image tools (wallpaper generation)
    imagemagick

    # Workflow base deps (lightweight; heavy apps in workflow scripts)
    nodejs
    npm
    sqlite
    mariadb
    mesa
    chromium
)

log_info "Installing core pacman packages..."
install_pacman_pkgs "${PACMAN_PACKAGES[@]}"

# Godot from official repos if available as 4.x
if pacman -Ss '^extra/godot$' &>/dev/null || pacman -Ss '^community/godot$' &>/dev/null; then
    install_pacman_pkg godot || log_warn "Could not install godot from official repos — AUR fallback in workflow script."
fi

log_ok "Pacman base packages installed"
