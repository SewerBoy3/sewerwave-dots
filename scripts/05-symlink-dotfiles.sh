#!/usr/bin/env bash
# Symlink dotfiles from repo to ~/.config (and XDG exceptions)
set -euo pipefail

# shellcheck source=lib/helpers.sh
source "${SEWERWAVE_REPO_ROOT}/scripts/lib/helpers.sh"

CONFIG_ROOT="${SEWERWAVE_REPO_ROOT}/config"

# Standard config directories → ~/.config/<name>
CONFIG_DIRS=(
    i3
    picom
    polybar
    rofi
    kitty
    zellij
    fastfetch
)

for dir in "${CONFIG_DIRS[@]}"; do
    symlink_config_dir "${CONFIG_ROOT}/${dir}" "${HOME}/.config/${dir}"
done

# starship.toml is a single file, not a directory
symlink_config_file "${CONFIG_ROOT}/starship/starship.toml" "${HOME}/.config/starship.toml"

# Zsh via ZDOTDIR
symlink_config_dir "${CONFIG_ROOT}/zsh" "${HOME}/.config/zsh"

# Configure ZDOTDIR system-wide
ZSENV="/etc/zsh/zshenv"
ZSENV_MARKER="# sewerwave-dots ZDOTDIR"
if [[ -f "$ZSENV" ]] && grep -q "$ZSENV_MARKER" "$ZSENV" 2>/dev/null; then
    log_ok "ZDOTDIR already configured in $ZSENV"
else
    log_info "Setting ZDOTDIR in $ZSENV"
    echo "" | sudo tee -a "$ZSENV" >/dev/null
    cat <<EOF | sudo tee -a "$ZSENV" >/dev/null
${ZSENV_MARKER}
export ZDOTDIR="\${HOME}/.config/zsh"
EOF
fi

# PipeWire low-latency drop-in (user config, versioned in repo copy)
PIPEWIRE_SRC="${CONFIG_ROOT}/pipewire/pipewire.conf.d/99-lowlatency.conf"
PIPEWIRE_DEST="${HOME}/.config/pipewire/pipewire.conf.d/99-lowlatency.conf"
if [[ -f "$PIPEWIRE_SRC" ]]; then
    mkdir -p "$(dirname "$PIPEWIRE_DEST")"
    if [[ -f "$PIPEWIRE_DEST" && ! -L "$PIPEWIRE_DEST" ]]; then
        backup_path_if_real "$PIPEWIRE_DEST"
    fi
    if [[ ! -L "$PIPEWIRE_DEST" ]]; then
        ln -sfn "$PIPEWIRE_SRC" "$PIPEWIRE_DEST"
        log_ok "Linked pipewire low-latency config"
    else
        log_ok "Pipewire config already linked"
    fi
fi

# X11 autostart via startx in .zprofile (handled in zsh config)
# Copy xinit if needed
XINIT="${HOME}/.xinitrc"
if [[ ! -e "$XINIT" ]]; then
    cat > "$XINIT" <<'XINITRC'
#!/bin/sh
# sewerwave-dots — start i3 on X11
exec i3
XINITRC
    chmod +x "$XINIT"
    log_ok "Created ~/.xinitrc"
else
    log_ok "~/.xinitrc already exists (not overwritten)"
fi

mkdir -p "${HOME}/.config/sewerdots"
for seed in polybar-overrides.ini; do
    src="${CONFIG_ROOT}/sewerdots/${seed}"
    dest="${HOME}/.config/sewerdots/${seed}"
    if [[ -f "$src" && ! -e "$dest" ]]; then
        cp "$src" "$dest"
        log_ok "Seeded ${dest}"
    fi
done

log_ok "Dotfile symlinks complete"
