#!/usr/bin/env bash
# Web development workflow: Antigravity, Chromium, dev directories
set -euo pipefail

# shellcheck source=lib/helpers.sh
source "${SEWERWAVE_REPO_ROOT}/scripts/lib/helpers.sh"

if ! confirm_or_skip "Install web development workflow (Antigravity, dev dirs)?"; then
    log_info "Skipping webdev workflow"
    exit 0
fi

install_pacman_pkgs nodejs npm git sqlite mariadb chromium

# MariaDB: install only, do NOT enable service
disable_system_service mariadb.service

# Developer directory tree
DEV_DIRS=(
    "${HOME}/Developer/crumbskate-ecommerce"
    "${HOME}/Developer/sewer-world-dashboard"
    "${HOME}/Developer/sandbox"
)
for dir in "${DEV_DIRS[@]}"; do
    ensure_dir "$dir"
done

# Antigravity IDE
ANTIGRAVITY_OPT="/opt/antigravity"
ANTIGRAVITY_DESKTOP="${HOME}/.local/share/applications/antigravity.desktop"

install_antigravity() {
    if [[ -x "${ANTIGRAVITY_OPT}/antigravity" || -x "${ANTIGRAVITY_OPT}/Antigravity" ]]; then
        log_ok "Antigravity already installed in ${ANTIGRAVITY_OPT}"
        return 0
    fi

    # Check AUR first
    if require_aur_pkg antigravity-bin; then
        log_ok "Antigravity available via AUR (antigravity-bin)"
        install_aur_pkg antigravity-bin
        return 0
    fi

    log_info "antigravity-bin not found in AUR — attempting official tarball..."

    local tmpdir
    tmpdir="$(mktemp -d)"
    local url="https://antigravity.google/download/linux"

    if ! curl -fsSL -o "${tmpdir}/antigravity.tar.gz" "$url" 2>/dev/null; then
        log_warn "Could not download Antigravity from ${url}"
        log_warn "Install manually later: https://antigravity.google/download"
        rm -rf "$tmpdir"
        return 0
    fi

    sudo mkdir -p "$ANTIGRAVITY_OPT"
    sudo tar -xzf "${tmpdir}/antigravity.tar.gz" -C "$ANTIGRAVITY_OPT" --strip-components=1 2>/dev/null || \
        sudo tar -xzf "${tmpdir}/antigravity.tar.gz" -C "$ANTIGRAVITY_OPT"
    rm -rf "$tmpdir"

    local bin_name="antigravity"
    if [[ ! -x "${ANTIGRAVITY_OPT}/${bin_name}" ]]; then
        bin_name="$(find "$ANTIGRAVITY_OPT" -maxdepth 2 -name 'antigravity' -o -name 'Antigravity' 2>/dev/null | head -1)"
        bin_name="$(basename "$bin_name" 2>/dev/null || echo antigravity)"
    fi

    sudo ln -sf "${ANTIGRAVITY_OPT}/${bin_name}" /usr/local/bin/antigravity 2>/dev/null || \
        sudo ln -sf "$(find "$ANTIGRAVITY_OPT" -type f -executable | head -1)" /usr/local/bin/antigravity

    mkdir -p "$(dirname "$ANTIGRAVITY_DESKTOP")"
    cat > "$ANTIGRAVITY_DESKTOP" <<EOF
[Desktop Entry]
Name=Antigravity
Comment=Google Antigravity IDE
Exec=/usr/local/bin/antigravity %F
Icon=${ANTIGRAVITY_OPT}/resources/app/icons/icon.png
Type=Application
Categories=Development;IDE;
StartupNotify=true
EOF
    log_ok "Antigravity installed to ${ANTIGRAVITY_OPT}"
}

install_antigravity

log_ok "Web development workflow ready"
