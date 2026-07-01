#!/usr/bin/env bash
# sewerdots — hub de personalización del instalador (gum)
# shellcheck shell=bash

installer_menu_toggle_bool() {
    local key="$1"
    local cur
    cur="$(installer_cfg_get "$key")"
    installer_cfg_set "$key" "$([[ "$cur" == "1" ]] && echo 0 || echo 1)"
}

installer_menu_pick_one() {
    local key="$1" header="$2"
    shift 2
    local choice picked val
    choice="$(gum choose --height 10 --header "$header" "$@" </dev/tty)" || return 0
    picked="${choice%%|*}"
    installer_cfg_set "$key" "$picked"
}

installer_menu_pick_multi_bools() {
    local header="$1" preselected="$2"
    shift 2
    local -a items=("$@") keys=() labels=() sel item k lab pre="" s
    for item in "${items[@]}"; do
        k="${item%%|*}"
        lab="${item#*|}"
        keys+=("$k")
        labels+=("$lab")
        installer_cfg_bool "$k" 0 && pre+="${lab},"
    done
    pre="${pre#,}"
    sel="$(gum choose --no-limit --height 12 \
        --header "$header" --selected "$pre" \
        "${labels[@]}" </dev/tty)" || return 0
    for item in "${items[@]}"; do
        k="${item%%|*}"
        lab="${item#*|}"
        if grep -qxF "$lab" <<< "$sel" 2>/dev/null; then
            installer_cfg_set "$k" 1
        else
            installer_cfg_set "$k" 0
        fi
    done
}

installer_menu_sub_workflows() {
    tui_clear
    tui_step_pill "·" "Workflows"
    installer_menu_pick_multi_bools "Flujos principales" "" \
        "workflows.webdev|Desarrollo web" \
        "workflows.gamedev|Desarrollo de juegos" \
        "workflows.audio|Audio y contenido"

    installer_menu_pick_multi_bools "Componentes web" "" \
        "workflows.webdev_nodejs|Node.js + npm + git" \
        "workflows.webdev_antigravity|Antigravity IDE" \
        "workflows.webdev_sqlite|SQLite" \
        "workflows.webdev_mariadb|MariaDB (sin autostart)"

    installer_menu_pick_multi_bools "Componentes gamedev / audio" "" \
        "workflows.gamedev_godot|Godot 4" \
        "workflows.gamedev_mesa|Mesa (drivers)" \
        "workflows.audio_lmms|LMMS"
}

installer_menu_sub_system() {
    tui_clear
    tui_step_pill "·" "Sistema"
    installer_menu_pick_one system.login_method "Login gráfico" \
        "startx|Autologin tty1 + startx (liviano)" \
        "ly|ly — display manager TUI" \
        "manual|Manual — no modificar login"

    installer_menu_pick_one system.zram_size "Tamaño zRAM" \
        "ram/4|Conservador (ram/4)" \
        "ram/2|Equilibrado (ram/2)" \
        "ram/1.5|Agresivo (ram/1.5)"

    installer_menu_pick_one system.zram_swappiness "Swappiness" \
        "120|120 — conservador" \
        "180|180 — recomendado con zram" \
        "200|200 — agresivo"

    installer_menu_pick_one system.aur_helper "Helper AUR" \
        "auto|Auto detectar / compilar paru" \
        "paru|Forzar paru" \
        "yay|Forzar yay"

    installer_menu_pick_one system.change_shell "Shell por defecto" \
        "1|Cambiar a zsh" \
        "0|Mantener shell actual"

    installer_menu_pick_one browser.browser "Navegador (workflow web)" \
        "brave|Brave" \
        "chromium|Chromium" \
        "chrome|Google Chrome (AUR)" \
        "none|No instalar navegador"
}

installer_menu_sub_desktop() {
    tui_clear
    tui_step_pill "·" "Escritorio"
    installer_menu_pick_multi_bools "Componentes" "" \
        "desktop.enable_picom|picom (compositor)" \
        "desktop.enable_polybar|polybar (barra)" \
        "desktop.enable_rofi|rofi (launcher)" \
        "desktop.enable_dunst|dunst (notificaciones)" \
        "desktop.fastfetch_on_terminal|fastfetch al abrir terminal" \
        "desktop.zellij_autostart|zellij en kitty" \
        "desktop.starship_prompt|starship prompt" \
        "desktop.wallpaper_regenerate|Regenerar wallpaper"
}

installer_menu_sub_i3() {
    tui_clear
    tui_step_pill "·" "i3 · polybar · picom"
    local gaps
    gaps="$(gum input --placeholder "gaps inner (ej. 8)" --value "$(installer_cfg_get i3.gaps_inner 8)" </dev/tty)" || true
    [[ -n "$gaps" ]] && installer_cfg_set i3.gaps_inner "$gaps"
    gaps="$(gum input --placeholder "gaps outer (ej. 4)" --value "$(installer_cfg_get i3.gaps_outer 4)" </dev/tty)" || true
    [[ -n "$gaps" ]] && installer_cfg_set i3.gaps_outer "$gaps"

    installer_menu_pick_one polybar.height "Altura polybar (px)" \
        "24|24px compacta" \
        "27|27px default" \
        "32|32px cómoda"

    installer_menu_pick_multi_bools "Módulos polybar" "" \
        "polybar.show_cpu|CPU" \
        "polybar.show_memory|RAM" \
        "polybar.show_network|Red" \
        "polybar.show_pulseaudio|Volumen" \
        "polybar.show_date|Fecha/hora"

    installer_menu_pick_one picom.corner_radius "Radio esquinas picom" \
        "0|Sin redondeo" \
        "10|10px default" \
        "16|16px suave"

    installer_menu_pick_one picom.blur "Blur picom" \
        "0|Desactivado (recomendado)" \
        "1|Activar dual_kawase (más pesado)"
}

installer_menu_sub_audio() {
    tui_clear
    tui_step_pill "·" "Audio"
    installer_menu_pick_one audio.pipewire_latency "Latencia PipeWire" \
        "minimal|256 — equilibrado" \
        "balanced|256 — default" \
        "low|128 — baja latencia (puede xrun)"
}

installer_menu_sub_packages() {
    tui_clear
    tui_step_pill "·" "Paquetes opcionales"
    installer_menu_pick_multi_bools "Herramientas" "" \
        "packages.htop|htop" \
        "packages.btop|btop" \
        "packages.pavucontrol|pavucontrol" \
        "packages.imagemagick|ImageMagick (wallpaper)" \
        "packages.zellij|zellij" \
        "packages.starship|starship" \
        "packages.fastfetch|fastfetch" \
        "packages.lxappearance|lxappearance"
}

installer_menu_sub_services() {
    tui_clear
    tui_step_pill "·" "Servicios"
    installer_menu_pick_multi_bools "Habilitar" "" \
        "services.networkmanager|NetworkManager" \
        "services.pipewire|PipeWire + WirePlumber"

    installer_menu_pick_multi_bools "Mantener desactivados (recomendado)" "" \
        "services.bluetooth|Bluetooth" \
        "services.cups|CUPS (impresoras)" \
        "services.avahi|Avahi (mDNS)" \
        "services.mariadb_autostart|MariaDB autostart"
}

installer_menu_sub_paths() {
    tui_clear
    tui_step_pill "·" "Rutas"
    local p
    p="$(gum input --header "Carpeta Developer" --value "$(installer_cfg_get paths.developer_dir ~/Developer)" </dev/tty)" || true
    [[ -n "$p" ]] && installer_cfg_set paths.developer_dir "$p"
    p="$(gum input --header "Carpeta GameDev" --value "$(installer_cfg_get paths.gamedev_dir ~/GameDev)" </dev/tty)" || true
    [[ -n "$p" ]] && installer_cfg_set paths.gamedev_dir "$p"
    p="$(gum input --header "Carpeta Studio" --value "$(installer_cfg_get paths.studio_dir ~/Studio)" </dev/tty)" || true
    [[ -n "$p" ]] && installer_cfg_set paths.studio_dir "$p"
}

installer_menu_show_summary() {
    tui_clear
    installer_config_apply_to_env
    tui_step_pill "·" "Resumen completo"
    local rows=()
    while IFS= read -r line; do [[ -n "$line" ]] && rows+=("$line"); done < <(tui_summary_rows_extended)
    tui_draw_table_fallback "${rows[@]}" >/dev/tty
    printf '\n' >/dev/tty
    gum style --foreground "#${TUI_MUTED}" "Enter para volver al menú" >/dev/tty
    read -r </dev/tty || true
}

installer_menu_pick_profile() {
    tui_clear
    local profiles sel name
    profiles="$(installer_list_profiles)"
    sel="$(gum choose --header "Perfil base (se fusiona con tu config)" $profiles </dev/tty)" || return 0
    INSTALLER_PROFILE="$sel"
    export SEWER_PROFILE="$sel"
    installer_config_init
    gum style --foreground "#${TUI_FG}" "Perfil activo: ${sel}" >/dev/tty
    sleep 0.5
}

installer_menu_export() {
    local dest
    dest="$(gum input --header "Exportar config a:" --value "${HOME}/sewerdots.conf" </dev/tty)" || return 0
    [[ -z "$dest" ]] && return 0
    installer_config_export_file "$dest" >/dev/null
    gum style --foreground "#${TUI_PURPLE}" "Exportado → ${dest}" >/dev/tty
    sleep 0.8
}

installer_menu_import() {
    local src
    src="$(gum input --header "Importar config desde:" --value "${HOME}/sewerdots.conf" </dev/tty)" || return 0
    [[ -f "$src" ]] || { gum style --foreground "#${TUI_MUTED}" "Archivo no encontrado" >/dev/tty; sleep 0.8; return 0; }
    installer_cfg_load_file "$src"
    gum style --foreground "#${TUI_PURPLE}" "Importado ← ${src}" >/dev/tty
    sleep 0.8
}

installer_menu_hub() {
    local choice
    while true; do
        tui_clear
        [[ "$(installer_cfg_get ui.show_banner 1)" == "1" ]] && { tui_print_logo_tty; printf '\n' >/dev/tty; }
        gum style --foreground "#${TUI_FG}" --bold \
            "Centro de configuración · perfil: ${SEWER_PROFILE:-default}" >/dev/tty
        printf '\n' >/dev/tty

        choice="$(gum choose --height 14 --header "¿Qué querés ajustar?" \
            "Instalación rápida (perfil actual → instalar)" \
            "Elegir perfil base (default / minimal / full)" \
            "Workflows y componentes" \
            "Sistema (login, zRAM, AUR, shell)" \
            "Escritorio (picom, bar, terminal)" \
            "i3 · polybar · picom (detalle)" \
            "Audio (PipeWire)" \
            "Paquetes opcionales" \
            "Servicios" \
            "Rutas de proyectos" \
            "Ver resumen completo" \
            "Exportar configuración" \
            "Importar configuración" \
            "Instalar ahora" \
            "Salir sin instalar" </dev/tty)" || exit 0

        case "$choice" in
            "Instalación rápida"*) return 0 ;;
            "Elegir perfil"*) installer_menu_pick_profile ;;
            "Workflows"*) installer_menu_sub_workflows ;;
            "Sistema"*) installer_menu_sub_system ;;
            "Escritorio"*) installer_menu_sub_desktop ;;
            "i3"*) installer_menu_sub_i3 ;;
            "Audio"*) installer_menu_sub_audio ;;
            "Paquetes"*) installer_menu_sub_packages ;;
            "Servicios"*) installer_menu_sub_services ;;
            "Rutas"*) installer_menu_sub_paths ;;
            "Ver resumen"*) installer_menu_show_summary ;;
            "Exportar"*) installer_menu_export ;;
            "Importar"*) installer_menu_import ;;
            "Instalar ahora") return 0 ;;
            "Salir"*) exit 0 ;;
        esac
    done
}
