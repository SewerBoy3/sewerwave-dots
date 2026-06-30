#!/usr/bin/env bash
# Detect or build AUR helper (paru preferred)
set -euo pipefail

# shellcheck source=lib/helpers.sh
source "${SEWERWAVE_REPO_ROOT}/scripts/lib/helpers.sh"

if helper="$(detect_aur_helper)"; then
    log_ok "AUR helper found: $helper"
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

if command -v paru &>/dev/null; then
    log_ok "paru installed successfully"
else
    log_error "paru build finished but paru is not in PATH"
    exit 1
fi
