#!/usr/bin/env bash
# sewerdots — carga, exportación y helpers de configuración del instalador
# shellcheck shell=bash

INSTALLER_CFG_DIR="${SEWERWAVE_REPO_ROOT}/config/installer"
INSTALLER_PROFILE="${SEWER_PROFILE:-default}"
INSTALLER_CUSTOM_CONFIG="${SEWER_CONFIG_FILE:-}"

declare -A INSTALLER_CFG=()

# Defaults centralizados (key sin sección → fallback en installer_cfg_get)
readonly -A INSTALLER_DEFAULTS=(
    [workflows.webdev]=1
    [workflows.gamedev]=1
    [workflows.audio]=1
    [workflows.webdev_antigravity]=1
    [workflows.webdev_nodejs]=1
    [workflows.webdev_mariadb]=1
    [workflows.webdev_sqlite]=1
    [workflows.gamedev_godot]=1
    [workflows.gamedev_mesa]=1
    [workflows.audio_lmms]=1
    [workflows.create_workdirs]=1
    [system.login_method]=startx
    [system.zram_size]=ram/2
    [system.zram_swappiness]=180
    [system.zram_algorithm]=zstd
    [system.aur_helper]=auto
    [system.change_shell]=1
    [system.default_editor]=nano
    [system.timezone]=auto
    [browser.browser]=brave
    [desktop.terminal]=kitty
    [desktop.enable_picom]=1
    [desktop.enable_polybar]=1
    [desktop.enable_rofi]=1
    [desktop.enable_dunst]=1
    [desktop.fastfetch_on_terminal]=1
    [desktop.zellij_autostart]=1
    [desktop.starship_prompt]=1
    [desktop.wallpaper_regenerate]=1
    [i3.gaps_inner]=8
    [i3.gaps_outer]=4
    [i3.godot_workspace]=3
    [i3.focus_follows_mouse]=0
    [polybar.height]=27
    [polybar.show_cpu]=1
    [polybar.show_memory]=1
    [polybar.show_network]=1
    [polybar.show_pulseaudio]=1
    [polybar.show_date]=1
    [picom.corner_radius]=10
    [picom.shadows]=1
    [picom.blur]=0
    [picom.inactive_opacity]=0.95
    [audio.pipewire_latency]=balanced
    [packages.htop]=1
    [packages.btop]=1
    [packages.pavucontrol]=1
    [packages.imagemagick]=1
    [packages.zellij]=1
    [packages.starship]=1
    [packages.fastfetch]=1
    [packages.gum]=1
    [packages.lxappearance]=1
    [services.networkmanager]=1
    [services.pipewire]=1
    [services.bluetooth]=0
    [services.cups]=0
    [services.avahi]=0
    [services.mariadb_autostart]=0
    [paths.developer_dir]=~/Developer
    [paths.gamedev_dir]=~/GameDev
    [paths.studio_dir]=~/Studio
    [ui.show_banner]=1
    [ui.wizard_mode]=hub
)

installer_cfg_set() { INSTALLER_CFG["$1"]="$2"; }

installer_cfg_get() {
    local key="$1"
    local fallback="${2:-}"
    if [[ -n "${INSTALLER_CFG[$key]+x}" ]]; then
        echo "${INSTALLER_CFG[$key]}"
        return
    fi
    if [[ -n "${INSTALLER_DEFAULTS[$key]+x}" ]]; then
        echo "${INSTALLER_DEFAULTS[$key]}"
        return
    fi
    echo "$fallback"
}

installer_cfg_bool() {
    [[ "$(installer_cfg_get "$1" "${2:-0}")" == "1" ]]
}

installer_cfg_load_file() {
    local file="$1"
    local section="" line key val

    [[ -f "$file" ]] || return 0

    while IFS= read -r line || [[ -n "$line" ]]; do
        line="${line%%#*}"
        line="${line#"${line%%[![:space:]]*}"}"
        line="${line%"${line##*[![:space:]]}"}"
        [[ -z "$line" ]] && continue
        if [[ "$line" =~ ^\[(.+)\]$ ]]; then
            section="${BASH_REMATCH[1]}"
            continue
        fi
        [[ "$line" != *"="* ]] && continue
        key="${line%%=*}"
        val="${line#*=}"
        key="${key%"${key##*[![:space:]]}"}"
        val="${val#"${val%%[![:space:]]*}"}"
        installer_cfg_set "${section}.${key}" "$val"
    done < "$file"
}

installer_config_init() {
    INSTALLER_CFG=()
    installer_cfg_load_file "${INSTALLER_CFG_DIR}/default.conf"
    if [[ "$INSTALLER_PROFILE" != "default" && -f "${INSTALLER_CFG_DIR}/profiles/${INSTALLER_PROFILE}.conf" ]]; then
        installer_cfg_load_file "${INSTALLER_CFG_DIR}/profiles/${INSTALLER_PROFILE}.conf"
    fi
    if [[ -f "${INSTALLER_CFG_DIR}/local.conf" ]]; then
        installer_cfg_load_file "${INSTALLER_CFG_DIR}/local.conf"
    fi
    if [[ -n "$INSTALLER_CUSTOM_CONFIG" && -f "$INSTALLER_CUSTOM_CONFIG" ]]; then
        installer_cfg_load_file "$INSTALLER_CUSTOM_CONFIG"
    fi
}

installer_config_apply_to_env() {
    local k v
    for k in "${!INSTALLER_DEFAULTS[@]}"; do
        v="$(installer_cfg_get "$k")"
        k="${k//./_}"
        k="SEWER_${k^^}"
        export "$k=$v"
    done
    # Aliases legibles usados en scripts existentes
    export SEWER_INSTALL_WEBDEV="$(installer_cfg_get workflows.webdev 1)"
    export SEWER_INSTALL_GAMEDEV="$(installer_cfg_get workflows.gamedev 1)"
    export SEWER_INSTALL_AUDIO="$(installer_cfg_get workflows.audio 1)"
    export SEWER_LOGIN_METHOD="$(installer_cfg_get system.login_method startx)"
    export SEWER_ZRAM_SIZE="$(installer_cfg_get system.zram_size ram/2)"
    export SEWER_ZRAM_SWAPPINESS="$(installer_cfg_get system.zram_swappiness 180)"
    export SEWER_ZRAM_ALGORITHM="$(installer_cfg_get system.zram_algorithm zstd)"
    export SEWER_AUR_HELPER="$(installer_cfg_get system.aur_helper auto)"
    export SEWER_CHANGE_SHELL="$(installer_cfg_get system.change_shell 1)"
    export SEWER_BROWSER="$(installer_cfg_get browser.browser brave)"
    export SEWER_ENABLE_PICOM="$(installer_cfg_get desktop.enable_picom 1)"
    export SEWER_ENABLE_POLYBAR="$(installer_cfg_get desktop.enable_polybar 1)"
    export SEWER_FASTFETCH_TERMINAL="$(installer_cfg_get desktop.fastfetch_on_terminal 1)"
    export SEWER_ZELLIJ_AUTOSTART="$(installer_cfg_get desktop.zellij_autostart 1)"
    export SEWER_UI_SHOW_BANNER="$(installer_cfg_get ui.show_banner 1)"
    export SEWER_WIZARD_MODE="$(installer_cfg_get ui.wizard_mode hub)"
    SEWER_DEVELOPER_DIR="$(installer_cfg_expand_path "$(installer_cfg_get paths.developer_dir ~/Developer)")"
    SEWER_GAMEDEV_DIR="$(installer_cfg_expand_path "$(installer_cfg_get paths.gamedev_dir ~/GameDev)")"
    SEWER_STUDIO_DIR="$(installer_cfg_expand_path "$(installer_cfg_get paths.studio_dir ~/Studio)")"
    export SEWER_DEVELOPER_DIR SEWER_GAMEDEV_DIR SEWER_STUDIO_DIR
}

installer_cfg_expand_path() {
    local p="$1"
    p="${p/#\~/$HOME}"
    echo "$p"
}

installer_config_export_file() {
    local dest="${1:-${HOME}/.config/sewerdots/installer/choices.conf}"
    mkdir -p "$(dirname "$dest")"
    {
        echo "# sewerdots installer config — $(date -Iseconds)"
        echo "# Reinstalar: ./install.sh --config ${dest} -y"
        echo
        for section in workflows system browser desktop i3 polybar picom audio packages services paths ui; do
            echo "[${section}]"
            local k full
            for k in "${!INSTALLER_DEFAULTS[@]}"; do
                [[ "$k" != "${section}."* ]] && continue
                full="${k#${section}.}"
                echo "${full}=$(installer_cfg_get "$k")"
            done
            echo
        done
    } > "$dest"
    echo "$dest"
}

installer_config_save() {
    local dest
    dest="$(installer_config_export_file "${HOME}/.config/sewerdots/installer/choices.conf")"
    installer_config_apply_to_env
    cat > "${HOME}/.config/sewerdots/installer.env" <<EOF
export SEWER_LOGIN_METHOD="${SEWER_LOGIN_METHOD:-startx}"
export SEWER_FASTFETCH_TERMINAL="${SEWER_FASTFETCH_TERMINAL:-1}"
export SEWER_ZELLIJ_AUTOSTART="${SEWER_ZELLIJ_AUTOSTART:-1}"
export SEWER_STARSHIP_PROMPT="${SEWER_DESKTOP_STARSHIP_PROMPT:-1}"
export SEWER_DEFAULT_EDITOR="${SEWER_SYSTEM_DEFAULT_EDITOR:-nano}"
EOF
    log_ok "Config guardada en ${dest}"
}

installer_login_method_label() {
    case "${SEWER_LOGIN_METHOD:-startx}" in
        startx) echo "tty1 + startx" ;;
        ly) echo "ly (TUI DM)" ;;
        manual) echo "manual" ;;
        *) echo "${SEWER_LOGIN_METHOD}" ;;
    esac
}

installer_zram_label() {
    echo "${SEWER_ZRAM_SIZE:-ram/2} · swapp ${SEWER_ZRAM_SWAPPINESS:-180} · ${SEWER_ZRAM_ALGORITHM:-zstd}"
}

installer_desktop_label() {
    local parts=()
    [[ "${SEWER_ENABLE_PICOM:-1}" == "1" ]] && parts+=("picom")
    [[ "${SEWER_ENABLE_POLYBAR:-1}" == "1" ]] && parts+=("polybar")
    installer_cfg_bool desktop.enable_dunst 1 && parts+=("dunst")
    [[ "${SEWER_FASTFETCH_TERMINAL:-1}" == "1" ]] && parts+=("fastfetch")
    [[ "${SEWER_ZELLIJ_AUTOSTART:-1}" == "1" ]] && parts+=("zellij")
    local IFS=' + '
    echo "${parts[*]:-base}"
}

installer_workflows_detail_label() {
    local parts=()
    if installer_cfg_bool workflows.webdev 0; then
        installer_cfg_bool workflows.webdev_nodejs 1 && parts+=("node")
        installer_cfg_bool workflows.webdev_antigravity 1 && parts+=("antigravity")
    fi
    if installer_cfg_bool workflows.gamedev 0; then
        installer_cfg_bool workflows.gamedev_godot 1 && parts+=("godot")
    fi
    if installer_cfg_bool workflows.audio 0; then
        installer_cfg_bool workflows.audio_lmms 1 && parts+=("lmms")
    fi
    local IFS=','
    echo "${parts[*]:-—}"
}

installer_pipewire_quantum() {
    case "$(installer_cfg_get audio.pipewire_latency balanced)" in
        low)     echo "128" ;;
        minimal) echo "256" ;;
        *)       echo "256" ;;
    esac
}

installer_list_profiles() {
    echo "default minimal full"
    for f in "${INSTALLER_CFG_DIR}"/profiles/*.conf; do
        [[ -f "$f" ]] && basename "$f" .conf
    done | sort -u
}
