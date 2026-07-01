#!/usr/bin/env bash
# Web development workflow (granular)
set -euo pipefail

source "${SEWERWAVE_REPO_ROOT}/scripts/lib/helpers.sh"
source "${SEWERWAVE_REPO_ROOT}/scripts/lib/installer-config.sh"
installer_config_init
installer_config_apply_to_env

[[ "${SEWER_INSTALL_WEBDEV:-0}" == "1" ]] || { log_info "Webdev desactivado"; exit 0; }

DEV_ROOT="${SEWER_DEVELOPER_DIR:-${HOME}/Developer}"

if [[ "${SEWER_WORKFLOWS_WEBDEV_NODEJS:-1}" == "1" ]]; then
    install_pacman_pkgs nodejs npm git
fi
[[ "${SEWER_WORKFLOWS_WEBDEV_SQLITE:-1}" == "1" ]] && install_pacman_pkg sqlite
if [[ "${SEWER_WORKFLOWS_WEBDEV_MARIADB:-1}" == "1" ]]; then
    install_pacman_pkg mariadb
    disable_system_service mariadb.service
fi

case "${SEWER_BROWSER:-brave}" in
    chrome) install_aur_pkg google-chrome ;;
    chromium) install_pacman_pkg chromium ;;
    brave) install_aur_pkg brave-bin ;;
    none) log_info "Navegador omitido (config)" ;;
esac

if [[ "${SEWER_WORKFLOWS_CREATE_WORKDIRS:-1}" == "1" ]]; then
    ensure_dir "${DEV_ROOT}/crumbskate-ecommerce"
    ensure_dir "${DEV_ROOT}/sewer-world-dashboard"
    ensure_dir "${DEV_ROOT}/sandbox"
fi

if [[ "${SEWER_WORKFLOWS_WEBDEV_ANTIGRAVITY:-1}" == "1" ]]; then
    ANTIGRAVITY_OPT="/opt/antigravity"
    if require_aur_pkg antigravity-bin; then
        install_aur_pkg antigravity-bin
    else
        log_info "Antigravity: instalación manual si hace falta — https://antigravity.google/download"
    fi
fi

log_ok "Web development workflow ready"
