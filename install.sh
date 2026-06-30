#!/usr/bin/env bash
# sewerwave-dots — one-shot Arch Linux + i3wm environment installer
# Inspired by Omakub/Omarchy philosophy; i3/X11 for low-resource hardware.
set -euo pipefail

SEWERWAVE_REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export SEWERWAVE_REPO_ROOT
export SEWERWAVE_NONINTERACTIVE=0

INSTALL_LOG="${HOME}/.sewerwave-install.log"

_on_error() {
    local line="$1"
    local cmd="$2"
    echo "[sewerwave-dots] ERROR at line ${line}: ${cmd}" >&2
    echo "See full log: ${INSTALL_LOG}" >&2
    exit 1
}
trap '_on_error "${LINENO}" "${BASH_COMMAND}"' ERR

# Duplicate all output to persistent log
exec > >(tee -a "$INSTALL_LOG") 2>&1

usage() {
    cat <<'EOF'
Usage: ./install.sh [OPTIONS]

Options:
  -y, --yes    Non-interactive mode (accept defaults)
  -h, --help   Show this help

Transforms a minimal Arch Linux install into the Sewerwave i3 desktop.
Log file: ~/.sewerwave-install.log
EOF
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        -y | --yes)
            SEWERWAVE_NONINTERACTIVE=1
            export SEWERWAVE_NONINTERACTIVE
            shift
            ;;
        -h | --help)
            usage
            exit 0
            ;;
        *)
            echo "Unknown option: $1" >&2
            usage
            exit 1
            ;;
    esac
done

# shellcheck source=scripts/lib/helpers.sh
source "${SEWERWAVE_REPO_ROOT}/scripts/lib/helpers.sh"

banner_section "sewerwave-dots installer"
log_info "Repository: ${SEWERWAVE_REPO_ROOT}"
log_info "Log file: ${INSTALL_LOG}"
log_info "Mode: $([[ "$SEWERWAVE_NONINTERACTIVE" -eq 1 ]] && echo non-interactive || echo interactive)"

SCRIPTS=(
    "00-preflight.sh"
    "01-pacman-base.sh"
    "02-aur-helper.sh"
    "03-aur-packages.sh"
    "04-zram-setup.sh"
    "05-symlink-dotfiles.sh"
    "06-shell-setup.sh"
    "07-workflow-webdev.sh"
    "08-workflow-gamedev.sh"
    "09-workflow-audio-content.sh"
    "10-services-enable.sh"
    "11-branding-assets.sh"
)

for script in "${SCRIPTS[@]}"; do
    script_path="${SEWERWAVE_REPO_ROOT}/scripts/${script}"
    if [[ ! -f "$script_path" ]]; then
        log_error "Missing script: ${script_path}"
        exit 1
    fi
    banner_section "Running ${script}"
    # shellcheck source=/dev/null
    bash "$script_path"
done

banner_section "Installation complete"
log_ok "sewerwave-dots setup finished"
cat <<EOF

Summary:
  • Dotfiles symlinked under ~/.config (ZDOTDIR → ~/.config/zsh)
  • i3 + picom + polybar + rofi + kitty configured (Synthwave Pastel palette)
  • zRAM swap via zram-generator (zstd)
  • Workflows: ~/Developer, ~/GameDev, ~/Studio
  • Services: NetworkManager + PipeWire/WirePlumber (user)
  • MariaDB installed but NOT enabled by default

Next steps:
  1. Log out and back in (or reboot) to start the graphical session
  2. Verify baseline RAM: free -h
     Target: ~300 MB at idle (i3 + picom + polybar + wallpaper, no apps)
  3. Launch apps on demand — Antigravity, Godot, LMMS are heavy by design

Full log: ${INSTALL_LOG}
EOF
