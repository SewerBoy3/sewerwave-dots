#!/usr/bin/env bash
# Audio/content production: PipeWire tuning, LMMS, Studio dirs
set -euo pipefail

# shellcheck source=lib/helpers.sh
source "${SEWERWAVE_REPO_ROOT}/scripts/lib/helpers.sh"

if ! confirm_or_skip "Install audio/content workflow (LMMS, Studio dirs)?"; then
    log_info "Skipping audio/content workflow"
    exit 0
fi

install_pacman_pkgs pipewire pipewire-pulse pipewire-alsa pipewire-jack wireplumber

if ! require_aur_pkg lmms; then
    install_aur_pkg lmms
fi

STUDIO_DIRS=(
    "${HOME}/Studio/music/lmms-projects"
    "${HOME}/Studio/music/samples"
    "${HOME}/Studio/music/soundfonts"
    "${HOME}/Studio/content/guiones"
    "${HOME}/Studio/content/videos/raw"
    "${HOME}/Studio/content/videos/editados"
    "${HOME}/Studio/content/miniaturas"
)

for dir in "${STUDIO_DIRS[@]}"; do
    ensure_dir "$dir"
done

log_ok "Audio/content workflow ready"
log_info "PipeWire low-latency config at ~/.config/pipewire/pipewire.conf.d/99-lowlatency.conf"
