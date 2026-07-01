#!/usr/bin/env bash
# Aplica toda la configuración del instalador a dotfiles en runtime
set -euo pipefail

source "${SEWERWAVE_REPO_ROOT}/scripts/lib/helpers.sh"
source "${SEWERWAVE_REPO_ROOT}/scripts/lib/installer-config.sh"

installer_config_init
installer_config_apply_to_env

SEWERDOTS_CFG="${HOME}/.config/sewerdots"
mkdir -p "$SEWERDOTS_CFG"

# i3 autostart
I3_AUTO="${SEWERDOTS_CFG}/i3-autostart.conf"
{
    echo "# sewerdots — $(date -Iseconds)"
    [[ "${SEWER_ENABLE_PICOM:-1}" == "1" ]] && \
        echo "exec --no-startup-id picom --config ~/.config/picom/picom.conf"
    [[ "${SEWER_ENABLE_POLYBAR:-1}" == "1" ]] && \
        echo "exec --no-startup-id ~/.config/polybar/launch.sh"
    echo "exec --no-startup-id dbus-update-activation-environment --systemd DISPLAY XDG_CURRENT_DESKTOP"
} > "$I3_AUTO"
log_ok "i3 autostart → ${I3_AUTO}"

# i3 overrides (gaps, workspace Godot)
I3_OVR="${SEWERDOTS_CFG}/i3-overrides.conf"
{
    echo "# sewerdots i3 overrides"
    echo "gaps inner ${SEWER_I3_GAPS_INNER:-8}"
    echo "gaps outer ${SEWER_I3_GAPS_OUTER:-4}"
    echo "assign [class=\"Godot\"] → ${SEWER_I3_GODOT_WORKSPACE:-3}"
    [[ "${SEWER_I3_FOCUS_FOLLOWS_MOUSE:-0}" == "1" ]] && echo "focus_follows_mouse yes"
} > "$I3_OVR"
log_ok "i3 overrides → ${I3_OVR}"

# picom overrides snippet
PICOM_OVR="${SEWERDOTS_CFG}/picom-overrides.conf"
{
    echo "# sewerdots picom overrides"
    echo "corner-radius = ${SEWER_PICOM_CORNER_RADIUS:-10};"
    echo "inactive-opacity = ${SEWER_PICOM_INACTIVE_OPACITY:-0.95};"
    if [[ "${SEWER_PICOM_BLUR:-0}" == "1" ]]; then
        echo 'blur-method = "dual_kawase";'
        echo "blur-strength = 2;"
    else
        echo 'blur-method = "none";'
    fi
    if [[ "${SEWER_PICOM_SHADOWS:-1}" != "1" ]]; then
        echo "shadow = false;"
    fi
} > "$PICOM_OVR"

# polybar overrides
POLY_OVR="${SEWERDOTS_CFG}/polybar-overrides.ini"
{
    echo "; sewerdots polybar overrides"
    echo "[bar/sewerwave]"
    echo "height = ${SEWER_POLYBAR_HEIGHT:-27}"
    mods=()
    [[ "${SEWER_POLYBAR_SHOW_PULSEAUDIO:-1}" == "1" ]] && mods+=(pulseaudio)
    [[ "${SEWER_POLYBAR_SHOW_NETWORK:-1}" == "1" ]] && mods+=(network)
    [[ "${SEWER_POLYBAR_SHOW_MEMORY:-1}" == "1" ]] && mods+=(memory)
    [[ "${SEWER_POLYBAR_SHOW_CPU:-1}" == "1" ]] && mods+=(cpu)
    [[ "${SEWER_POLYBAR_SHOW_DATE:-1}" == "1" ]] && mods+=(date)
    echo "modules-right = ${mods[*]:-date}"
} > "$POLY_OVR"

# PipeWire latency
PW_DIR="${HOME}/.config/pipewire/pipewire.conf.d"
mkdir -p "$PW_DIR"
quantum="$(installer_pipewire_quantum)"
cat > "${PW_DIR}/99-sewerdots-latency.conf" <<EOF
# sewerdots — latencia $(installer_cfg_get audio.pipewire_latency balanced)
context.properties = {
    default.clock.rate        = 48000
    default.clock.quantum     = ${quantum}
    default.clock.min-quantum = ${quantum}
    default.clock.max-quantum = 1024
}
EOF

# ly login
if [[ "${SEWER_LOGIN_METHOD:-startx}" == "ly" ]]; then
    install_pacman_pkg ly
    sudo systemctl enable ly.service 2>/dev/null || true
fi

installer_config_save
log_ok "Configuración del instalador aplicada"
