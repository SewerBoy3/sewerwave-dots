#!/usr/bin/env bash
# Audio/content workflow (granular)
set -euo pipefail

source "${SEWERWAVE_REPO_ROOT}/scripts/lib/helpers.sh"
source "${SEWERWAVE_REPO_ROOT}/scripts/lib/installer-config.sh"
installer_config_init
installer_config_apply_to_env

[[ "${SEWER_INSTALL_AUDIO:-0}" == "1" ]] || { log_info "Audio desactivado"; exit 0; }

STUDIO_ROOT="${SEWER_STUDIO_DIR:-${HOME}/Studio}"

install_pacman_pkgs pipewire pipewire-pulse pipewire-alsa pipewire-jack wireplumber

if [[ "${SEWER_WORKFLOWS_AUDIO_LMMS:-1}" == "1" ]]; then
    install_aur_pkg lmms
fi

if [[ "${SEWER_WORKFLOWS_CREATE_WORKDIRS:-1}" == "1" ]]; then
    ensure_dir "${STUDIO_ROOT}/music/lmms-projects"
    ensure_dir "${STUDIO_ROOT}/music/samples"
    ensure_dir "${STUDIO_ROOT}/content/guiones"
    ensure_dir "${STUDIO_ROOT}/content/videos/raw"
fi

log_ok "Audio/content workflow ready"
