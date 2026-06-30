#!/usr/bin/env bash
# Game development workflow: Godot 4, mesa, project directories
set -euo pipefail

# shellcheck source=lib/helpers.sh
source "${SEWERWAVE_REPO_ROOT}/scripts/lib/helpers.sh"

if ! confirm_or_skip "Install game development workflow (Godot, GameDev dirs)?"; then
    log_info "Skipping gamedev workflow"
    exit 0
fi

install_pacman_pkg mesa

if ! require_pacman_pkg godot && ! require_aur_pkg godot4-bin; then
    install_aur_pkg godot4-bin
fi

GAMEDEV_DIRS=(
    "${HOME}/GameDev/the-last-crumb/project"
    "${HOME}/GameDev/the-last-crumb/assets/sprites"
    "${HOME}/GameDev/the-last-crumb/assets/tilesets"
    "${HOME}/GameDev/the-last-crumb/assets/audio"
    "${HOME}/GameDev/the-last-crumb/design-docs"
    "${HOME}/GameDev/dreamfall/project"
    "${HOME}/GameDev/dreamfall/assets/sprites"
    "${HOME}/GameDev/dreamfall/assets/tilesets"
    "${HOME}/GameDev/dreamfall/assets/audio"
    "${HOME}/GameDev/dreamfall/design-docs"
    "${HOME}/GameDev/shared-resources/pixel-art-refs"
    "${HOME}/GameDev/shared-resources/godot-addons"
)

for dir in "${GAMEDEV_DIRS[@]}"; do
    ensure_dir "$dir"
done

log_ok "Game development workflow ready"
log_info "Tip: use Godot Renderer = Compatibility (GLES3) on integrated graphics"
