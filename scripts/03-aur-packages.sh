#!/usr/bin/env bash
# AUR packages: LMMS and optional fallbacks
set -euo pipefail

# shellcheck source=lib/helpers.sh
source "${SEWERWAVE_REPO_ROOT}/scripts/lib/helpers.sh"

helper="$(detect_aur_helper)"
if [[ -z "$helper" ]]; then
    log_error "AUR helper required — run 02-aur-helper.sh first"
    exit 1
fi

AUR_PACKAGES=(lmms)

# Godot 4 fallback if official package missing or not 4.x
if ! require_pacman_pkg godot; then
    log_info "godot not in official repos — trying godot4-bin from AUR"
    AUR_PACKAGES+=(godot4-bin)
else
    godot_version="$(pacman -Qi godot 2>/dev/null | awk -F': ' '/^Version/ {print $2}' | cut -d- -f1 || true)"
    if [[ -n "$godot_version" && ! "$godot_version" =~ ^4\. ]]; then
        log_warn "Installed godot is not 4.x ($godot_version) — installing godot4-bin"
        AUR_PACKAGES+=(godot4-bin)
    fi
fi

for pkg in "${AUR_PACKAGES[@]}"; do
    install_aur_pkg "$pkg"
done

log_ok "AUR packages processed"
