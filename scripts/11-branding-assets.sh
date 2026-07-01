#!/usr/bin/env bash
# Generate branding assets and wallpaper
set -euo pipefail

source "${SEWERWAVE_REPO_ROOT}/scripts/lib/helpers.sh"
source "${SEWERWAVE_REPO_ROOT}/scripts/lib/installer-config.sh"
installer_config_init
installer_config_apply_to_env

ASSETS="${SEWERWAVE_REPO_ROOT}/assets"
WALLPAPER="${ASSETS}/wallpapers/sewerwave-default.png"
GENERATOR="${ASSETS}/wallpapers/generate_wallpaper.py"

if [[ "${SEWER_DESKTOP_WALLPAPER_REGENERATE:-1}" == "1" ]] || [[ ! -f "$WALLPAPER" ]]; then
    if [[ -f "$GENERATOR" ]]; then
        log_info "Generating wallpaper..."
        if python3 -c "import PIL" 2>/dev/null; then
            python3 "$GENERATOR" "$WALLPAPER"
        elif command -v convert &>/dev/null; then
            bash "${ASSETS}/wallpapers/generate_wallpaper.sh" "$WALLPAPER"
        fi
    fi
else
    log_ok "Wallpaper exists (regenerate off)"
fi

WALLPAPER_DEST="${HOME}/.local/share/sewerwave/wallpaper.png"
mkdir -p "$(dirname "$WALLPAPER_DEST")"
[[ -f "$WALLPAPER" ]] && ln -sfn "$WALLPAPER" "$WALLPAPER_DEST"
log_ok "Branding assets processed"
