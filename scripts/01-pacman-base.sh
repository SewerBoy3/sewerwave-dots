#!/usr/bin/env bash
# Core packages — driven by installer config
set -euo pipefail

source "${SEWERWAVE_REPO_ROOT}/scripts/lib/helpers.sh"
source "${SEWERWAVE_REPO_ROOT}/scripts/lib/installer-config.sh"

installer_config_init
installer_config_apply_to_env

CORE=(
    base-devel git
    xorg-server xorg-xinit xorg-xrandr xorg-xsetroot
    i3-wm i3status feh
    zsh zram-generator networkmanager
    pipewire pipewire-pulse pipewire-alsa pipewire-jack wireplumber
    kitty noto-fonts noto-fonts-emoji ttf-jetbrains-mono-nerd
    gtk3 adwaita-icon-theme papirus-icon-theme
)

OPTIONAL=(
    picom:desktop.enable_picom
    polybar:desktop.enable_polybar
    rofi:desktop.enable_rofi
    dunst:desktop.enable_dunst
    zellij:packages.zellij
    starship:packages.starship
    fastfetch:packages.fastfetch
    gum:packages.gum
    htop:packages.htop
    btop:packages.btop
    pavucontrol:packages.pavucontrol
    imagemagick:packages.imagemagick
    lxappearance:packages.lxappearance
)

install_pacman_pkgs "${CORE[@]}"

local pkg key
for entry in "${OPTIONAL[@]}"; do
    pkg="${entry%%:*}"
    key="${entry#*:}"
    if installer_cfg_bool "$key" 1; then
        install_pacman_pkg "$pkg"
    else
        log_ok "Omitido (config): $pkg"
    fi
done

log_ok "Pacman base packages installed"
