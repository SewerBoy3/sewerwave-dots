#!/usr/bin/env bash
# Game development workflow (granular)
set -euo pipefail

source "${SEWERWAVE_REPO_ROOT}/scripts/lib/helpers.sh"
source "${SEWERWAVE_REPO_ROOT}/scripts/lib/installer-config.sh"
installer_config_init
installer_config_apply_to_env

[[ "${SEWER_INSTALL_GAMEDEV:-0}" == "1" ]] || { log_info "Gamedev desactivado"; exit 0; }

GAME_ROOT="${SEWER_GAMEDEV_DIR:-${HOME}/GameDev}"

[[ "${SEWER_WORKFLOWS_GAMEDEV_MESA:-1}" == "1" ]] && install_pacman_pkg mesa

if [[ "${SEWER_WORKFLOWS_GAMEDEV_GODOT:-1}" == "1" ]]; then
    if ! require_pacman_pkg godot && ! require_aur_pkg godot4-bin; then
        install_aur_pkg godot4-bin
    fi
fi

if [[ "${SEWER_WORKFLOWS_CREATE_WORKDIRS:-1}" == "1" ]]; then
    for dir in \
        "${GAME_ROOT}/the-last-crumb/project" \
        "${GAME_ROOT}/the-last-crumb/assets/sprites" \
        "${GAME_ROOT}/dreamfall/project" \
        "${GAME_ROOT}/shared-resources/godot-addons"; do
        ensure_dir "$dir"
    done
fi

log_ok "Game development workflow ready"
