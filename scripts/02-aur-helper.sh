#!/usr/bin/env bash
# Detect or build AUR helper (configurable)
set -euo pipefail

# shellcheck source=lib/helpers.sh
source "${SEWERWAVE_REPO_ROOT}/scripts/lib/helpers.sh"

PREFERENCE="${SEWER_AUR_HELPER:-auto}"

if [[ "$PREFERENCE" == "yay" ]]; then
    if command -v yay &>/dev/null; then
        log_ok "AUR helper: yay"
        exit 0
    fi
    log_error "Forzaste yay pero no está instalado. Instalalo manualmente o usá --profile con aur_helper=auto"
    exit 1
fi

if [[ "$PREFERENCE" == "paru" ]] && command -v paru &>/dev/null; then
    log_ok "AUR helper: paru"
    exit 0
fi

if helper="$(detect_aur_helper)"; then
    log_ok "AUR helper found: $helper"
    [[ "$PREFERENCE" == "paru" && "$helper" != "paru" ]] && \
        log_warn "Preferiste paru pero se detectó ${helper}"
    exit 0
fi

log_info "No AUR helper detected — building paru from source..."

require_command git
require_command makepkg

BUILD_DIR="${HOME}/.cache/sewerwave/paru-build"
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"

git clone https://aur.archlinux.org/paru.git "$BUILD_DIR/paru"
cd "$BUILD_DIR/paru"

if [[ "$SEWERWAVE_NONINTERACTIVE" -eq 1 ]]; then
    makepkg -si --noconfirm
else
    makepkg -si
fi

command -v paru &>/dev/null || { log_error "paru build failed"; exit 1; }
log_ok "paru installed successfully"
