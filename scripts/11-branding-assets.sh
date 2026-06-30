#!/usr/bin/env bash
# Generate branding assets and wallpaper if missing
set -euo pipefail

# shellcheck source=lib/helpers.sh
source "${SEWERWAVE_REPO_ROOT}/scripts/lib/helpers.sh"

ASSETS="${SEWERWAVE_REPO_ROOT}/assets"
WALLPAPER="${ASSETS}/wallpapers/sewerwave-default.png"
GENERATOR="${ASSETS}/wallpapers/generate_wallpaper.py"

if [[ ! -f "$WALLPAPER" ]]; then
    if [[ -f "$GENERATOR" ]]; then
        log_info "Generating default wallpaper..."
        if python3 -c "import PIL" 2>/dev/null; then
            python3 "$GENERATOR" "$WALLPAPER"
        elif command -v convert &>/dev/null; then
            bash "${ASSETS}/wallpapers/generate_wallpaper.sh" "$WALLPAPER"
        else
            log_warn "Install python-pillow or imagemagick to generate wallpaper"
        fi
    fi
else
    log_ok "Wallpaper already exists: $WALLPAPER"
fi

# Install wallpaper where i3 expects it
WALLPAPER_DEST="${HOME}/.local/share/sewerwave/wallpaper.png"
mkdir -p "$(dirname "$WALLPAPER_DEST")"
if [[ -f "$WALLPAPER" ]]; then
    ln -sfn "$WALLPAPER" "$WALLPAPER_DEST"
    log_ok "Wallpaper linked to $WALLPAPER_DEST"
else
    log_warn "Wallpaper missing — i3 feh will fail until generated"
fi

log_ok "Branding assets processed"
