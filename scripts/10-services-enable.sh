#!/usr/bin/env bash
# Enable minimal services; disable bloat
set -euo pipefail

# shellcheck source=lib/helpers.sh
source "${SEWERWAVE_REPO_ROOT}/scripts/lib/helpers.sh"

# Enable NetworkManager
if ! service_is_enabled NetworkManager.service; then
    log_info "Enabling NetworkManager"
    sudo systemctl enable --now NetworkManager.service
else
    log_ok "NetworkManager already enabled"
fi

# User-level PipeWire / WirePlumber
enable_user_service pipewire.service
enable_user_service pipewire-pulse.service
enable_user_service wireplumber.service

# Disable unnecessary daemons (idempotent)
UNWANTED_SERVICES=(
    cups.service
    avahi-daemon.service
    bluetooth.service
    mariadb.service
)

for svc in "${UNWANTED_SERVICES[@]}"; do
    disable_system_service "$svc"
done

# Ensure no nm-applet autostart (polybar handles network module)
NM_AUTOSTART="${HOME}/.config/autostart/nm-applet.desktop"
if [[ -f "$NM_AUTOSTART" ]]; then
    rm -f "$NM_AUTOSTART"
    log_ok "Removed nm-applet autostart"
fi

log_ok "Services configured (NetworkManager + PipeWire only)"
