#!/usr/bin/env bash
# Services — driven by installer config
set -euo pipefail

source "${SEWERWAVE_REPO_ROOT}/scripts/lib/helpers.sh"
source "${SEWERWAVE_REPO_ROOT}/scripts/lib/installer-config.sh"
installer_config_init
installer_config_apply_to_env

if [[ "${SEWER_SERVICES_NETWORKMANAGER:-1}" == "1" ]]; then
    if ! service_is_enabled NetworkManager.service; then
        sudo systemctl enable --now NetworkManager.service
    else
        log_ok "NetworkManager already enabled"
    fi
fi

if [[ "${SEWER_SERVICES_PIPEWIRE:-1}" == "1" ]]; then
    enable_user_service pipewire.service
    enable_user_service pipewire-pulse.service
    enable_user_service wireplumber.service
fi

# bluetooth/cups/avahi: config 1 = keep enabled (unusual), 0 = disable
if [[ "${SEWER_SERVICES_BLUETOOTH:-0}" != "1" ]]; then disable_system_service bluetooth.service; fi
if [[ "${SEWER_SERVICES_CUPS:-0}" != "1" ]]; then disable_system_service cups.service; fi
if [[ "${SEWER_SERVICES_AVAHI:-0}" != "1" ]]; then disable_system_service avahi-daemon.service; fi
if [[ "${SEWER_SERVICES_MARIADB_AUTOSTART:-0}" != "1" ]]; then disable_system_service mariadb.service; fi

rm -f "${HOME}/.config/autostart/nm-applet.desktop" 2>/dev/null || true
log_ok "Services configured from installer choices"
