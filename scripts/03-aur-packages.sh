#!/usr/bin/env bash
# AUR packages — conditional on workflows
set -euo pipefail

source "${SEWERWAVE_REPO_ROOT}/scripts/lib/helpers.sh"
source "${SEWERWAVE_REPO_ROOT}/scripts/lib/installer-config.sh"
installer_config_init
installer_config_apply_to_env

helper="$(detect_aur_helper)"
[[ -n "$helper" ]] || { log_error "AUR helper required"; exit 1; }

AUR_PACKAGES=()

if [[ "${SEWER_WORKFLOWS_GAMEDEV_GODOT:-1}" == "1" ]] && [[ "${SEWER_INSTALL_GAMEDEV:-0}" == "1" ]]; then
    if ! require_pacman_pkg godot; then AUR_PACKAGES+=(godot4-bin); fi
fi

if [[ "${SEWER_WORKFLOWS_AUDIO_LMMS:-1}" == "1" ]] && [[ "${SEWER_INSTALL_AUDIO:-0}" == "1" ]]; then
    AUR_PACKAGES+=(lmms)
fi

for pkg in "${AUR_PACKAGES[@]}"; do
    install_aur_pkg "$pkg"
done

log_ok "AUR packages processed"
