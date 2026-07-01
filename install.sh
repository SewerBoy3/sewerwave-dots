#!/usr/bin/env bash
# sewerdots — one-shot Arch Linux + i3wm environment installer
set -euo pipefail

SEWERWAVE_REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export SEWERWAVE_REPO_ROOT
export SEWERWAVE_NONINTERACTIVE=0
export SEWER_PROFILE="${SEWER_PROFILE:-default}"
export SEWER_CONFIG_FILE="${SEWER_CONFIG_FILE:-}"

INSTALL_LOG="${HOME}/.sewerwave-install.log"

usage() {
    cat <<'EOF'
Usage: ./install.sh [OPTIONS]

Options:
  -y, --yes              No interactivo (usa perfil/config cargada)
  --profile NAME         default | minimal | full
  --config FILE          Archivo .conf adicional
  --configure            Solo abrir hub de config (guarda local.conf)
  --export-config FILE   Exportar config y salir
  -h, --help

Config: config/installer/local.conf · docs: config/installer/CONFIG.md
Hub standalone: ./scripts/sewer-config
EOF
}

CONFIGURE_ONLY=0
EXPORT_CONFIG=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        -y | --yes) SEWERWAVE_NONINTERACTIVE=1; export SEWERWAVE_NONINTERACTIVE; shift ;;
        --profile) SEWER_PROFILE="${2:?}"; export SEWER_PROFILE; shift 2 ;;
        --config) SEWER_CONFIG_FILE="${2:?}"; export SEWER_CONFIG_FILE; shift 2 ;;
        --configure) CONFIGURE_ONLY=1; shift ;;
        --export-config) EXPORT_CONFIG="${2:?}"; shift 2 ;;
        -h | --help) usage; exit 0 ;;
        *) echo "Opción desconocida: $1" >&2; usage; exit 1 ;;
    esac
done

source "${SEWERWAVE_REPO_ROOT}/scripts/lib/helpers.sh"
source "${SEWERWAVE_REPO_ROOT}/scripts/lib/installer-config.sh"
source "${SEWERWAVE_REPO_ROOT}/scripts/lib/tui.sh"
source "${SEWERWAVE_REPO_ROOT}/scripts/lib/installer-menu.sh"

installer_config_init

if [[ -n "$EXPORT_CONFIG" ]]; then
    installer_config_export_file "$EXPORT_CONFIG" >/dev/null
    echo "Exportado → $EXPORT_CONFIG"
    exit 0
fi

if [[ "$CONFIGURE_ONLY" -eq 1 ]]; then
    bash "${SEWERWAVE_REPO_ROOT}/scripts/sewer-config" ${SEWER_PROFILE:+--profile "$SEWER_PROFILE"}
    exit 0
fi

tui_preflight_minimal

if [[ "$SEWERWAVE_NONINTERACTIVE" -eq 1 ]]; then
    installer_config_apply_to_env
else
    sewer_installer_wizard
    installer_config_apply_to_env
fi

tui_log_wizard_choices

_on_error() { echo "[sewerdots] ERROR L${1}: ${2}" >&2; exit 1; }
trap '_on_error "${LINENO}" "${BASH_COMMAND}"' ERR
exec > >(tee -a "$INSTALL_LOG") 2>&1

SCRIPTS=(
    00-preflight.sh 01-pacman-base.sh 02-aur-helper.sh 03-aur-packages.sh
    04-zram-setup.sh 05-symlink-dotfiles.sh 06-shell-setup.sh
    07-workflow-webdev.sh 08-workflow-gamedev.sh 09-workflow-audio-content.sh
    10-services-enable.sh 11-branding-assets.sh 12-apply-installer-choices.sh
)

total="${#SCRIPTS[@]}" idx=0
for script in "${SCRIPTS[@]}"; do
    idx=$((idx + 1))
    script_path="${SEWERWAVE_REPO_ROOT}/scripts/${script}"
    [[ -f "$script_path" ]] || { log_error "Falta ${script_path}"; exit 1; }
    tui_run_phase "$script" "$script_path" "$idx" "$total"
done

log_ok "sewerdots setup finished"
tui_finish_screen
