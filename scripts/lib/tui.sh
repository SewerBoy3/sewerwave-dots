#!/usr/bin/env bash
# sewerdots — TUI del instalador (multi-paso, configurable)
# shellcheck shell=bash

readonly TUI_PURPLE="B79CED"
readonly TUI_FG="E8E1F5"
readonly TUI_MUTED="9C90B5"
readonly TUI_BG="1A1626"
readonly TUI_BG_ALT="221D33"
readonly TUI_BORDER="3A3354"
readonly TUI_WIZARD_STEPS=5

tui_gum_ready() {
    [[ -n "${SEWERWAVE_NONINTERACTIVE:-}" && "$SEWERWAVE_NONINTERACTIVE" -eq 1 ]] && return 1
    command -v gum &>/dev/null && [[ -e /dev/tty ]]
}

tui_configure_gum() {
    export GUM_INPUT_CURSOR_FOREGROUND="#${TUI_PURPLE}"
    export GUM_INPUT_PROMPT_FOREGROUND="#${TUI_PURPLE}"
    export GUM_INPUT_PLACEHOLDER_FOREGROUND="#${TUI_MUTED}"
}

tui_tty() {
    local action="$1"
    shift
    "$action" "$@" >/dev/tty 2>&1
}

tui_clear() {
    if tui_gum_ready; then
        gum clear >/dev/tty 2>/dev/null || clear
    else
        clear
    fi
}

tui_colorize_logo() {
    local line="$1"
    line="${line//\$\{c1\}/$(_sw_fg "$SW_COLOR_PURPLE")}"
    line="${line//\$\{c2\}/$(_sw_fg "$SW_COLOR_FG")}"
    line="${line//\$\{c3\}/$(_sw_fg "$SW_COLOR_PURPLE")}"
    line="${line//\$\{c4\}/$(_sw_fg "$SW_COLOR_FG_MUTED")}"
    printf '%b\n' "${line}${_SW_RESET}"
}

tui_print_logo() {
    local logo_file="${1:-${SEWERWAVE_REPO_ROOT}/assets/branding/installer-logo.txt}"
    [[ -f "$logo_file" ]] || logo_file="${SEWERWAVE_REPO_ROOT}/assets/branding/banner.txt"
    if [[ ! -f "$logo_file" ]]; then
        printf '%b%s%b\n' "$(_sw_fg "$SW_COLOR_PURPLE")" "  SEWERDOTS" "$_SW_RESET"
        return
    fi
    while IFS= read -r line || [[ -n "$line" ]]; do
        [[ -z "${line// }" ]] && printf '\n' && continue
        tui_colorize_logo "$line"
    done < "$logo_file"
}

tui_print_banner() { tui_print_logo "${SEWERWAVE_REPO_ROOT}/assets/branding/banner.txt"; }

tui_print_logo_tty() {
    if tui_gum_ready; then tui_print_logo >/dev/tty; else tui_print_logo; fi
}

tui_ensure_gum() {
    command -v gum &>/dev/null && return 0
    command -v pacman &>/dev/null || return 1
    if ! sudo -n true 2>/dev/null; then
        printf '%b\n' "$(_sw_fg "$SW_COLOR_FG")sudo necesario para gum…${_SW_RESET}" >/dev/tty 2>&1 || true
        sudo -v || return 1
    fi
    sudo pacman -S --needed --noconfirm gum >/dev/tty 2>&1 || return 1
}

tui_preflight_minimal() {
    [[ "${EUID:-$(id -u)}" -eq 0 ]] && { log_error "No ejecutes install.sh como root."; return 1; }
    command -v pacman &>/dev/null || { log_error "Se requiere Arch Linux (pacman)."; return 1; }
    return 0
}

tui_detect_ram() { free -h 2>/dev/null | awk '/^Mem:/ {print $2}' || echo "?"; }
tui_detect_cpu() {
    grep -m1 'model name' /proc/cpuinfo 2>/dev/null | cut -d: -f2- | sed 's/^ //' | cut -c1-40 || echo "?"
}

tui_step_pill() {
    local step="$1" title="$2"
    if tui_gum_ready; then
        gum style --border rounded --border-foreground "#${TUI_PURPLE}" \
            --foreground "#${TUI_FG}" --bold --margin "0 0 1 0" \
            " Paso ${step}/${TUI_WIZARD_STEPS} — ${title} " >/dev/tty
    else
        printf '%b── Paso %s/%s: %s ──%b\n\n' \
            "$(_sw_fg "$SW_COLOR_PURPLE")" "$step" "$TUI_WIZARD_STEPS" "$title" "$_SW_RESET"
    fi
}

tui_panel() {
    local content="$1"
    if tui_gum_ready; then
        gum style --border double --border-foreground "#${TUI_PURPLE}" \
            --background "#${TUI_BG_ALT}" --foreground "#${TUI_FG}" \
            --padding "1 2" --width 70 "$content" >/dev/tty
    else
        printf '%b┌%s┐%b\n' "$(_sw_fg "$SW_COLOR_BORDER")" "$(printf '─%.0s' {1..68})" "$_SW_RESET"
        printf '%b│%b %s\n' "$(_sw_fg "$SW_COLOR_BORDER")" "$_SW_RESET" "$content"
        printf '%b└%s┘%b\n' "$(_sw_fg "$SW_COLOR_BORDER")" "$(printf '─%.0s' {1..68})" "$_SW_RESET"
    fi
}

tui_gum_choose_one() {
    local header="$1"
    shift
    gum choose --height 8 \
        --cursor.foreground "#${TUI_PURPLE}" \
        --header.foreground "#${TUI_MUTED}" \
        --header "$header" "$@" </dev/tty
}

tui_gum_choose_multi() {
    local header="$1"
    local preselected="$2"
    shift 2
    gum choose --no-limit --height 8 \
        --cursor.foreground "#${TUI_PURPLE}" \
        --selected.foreground "#${TUI_FG}" \
        --header.foreground "#${TUI_MUTED}" \
        --header "$header" \
        --selected "$preselected" "$@" </dev/tty
}

tui_draw_table_fallback() {
    local -a rows=("$@")
    local border fg muted
    border="$(_sw_fg "$SW_COLOR_BORDER")"
    fg="$(_sw_fg "$SW_COLOR_FG")"
    muted="$(_sw_fg "$SW_COLOR_FG_MUTED")"
    printf '%b┌──────────────────────────────────────────────────────────────┐%b\n' "$border" "$_SW_RESET"
    printf '%b│%b  %-22s %b│%b  %-36s %b│%b\n' \
        "$border" "$muted" "Campo" "$border" "$muted" "Valor" "$border" "$_SW_RESET"
    printf '%b├────────────────────────┬─────────────────────────────────────┤%b\n' "$border" "$_SW_RESET"
    local row label value
    for row in "${rows[@]}"; do
        label="${row%%|*}"
        value="${row#*|}"
        printf '%b│%b  %-22s %b│%b  %-36s %b│%b\n' \
            "$border" "$fg" "$label" "$border" "$muted" "$value" "$border" "$_SW_RESET"
    done
    printf '%b└────────────────────────┴─────────────────────────────────────┘%b\n' "$border" "$_SW_RESET"
}

tui_summary_rows_extended() {
    installer_config_apply_to_env
    cat <<EOF
Usuario|$(whoami)
Perfil|${SEWER_PROFILE:-default}
Workflows|$(tui_workflows_label) ($(installer_workflows_detail_label))
Login|$(installer_login_method_label)
Swap|$(installer_zram_label)
AUR|${SEWER_AUR_HELPER:-auto}
Shell zsh|${SEWER_CHANGE_SHELL:-1}
Browser|${SEWER_BROWSER:-chromium}
Escritorio|$(installer_desktop_label)
i3 gaps|inner ${SEWER_I3_GAPS_INNER:-8} / outer ${SEWER_I3_GAPS_OUTER:-4}
Polybar|${SEWER_POLYBAR_HEIGHT:-27}px · módulos configurables
Picom|radio ${SEWER_PICOM_CORNER_RADIUS:-10} · blur ${SEWER_PICOM_BLUR:-0}
Audio|PipeWire $(installer_cfg_get audio.pipewire_latency balanced)
Paths|$(basename "${SEWER_DEVELOPER_DIR:-~/Developer}"), $(basename "${SEWER_GAMEDEV_DIR:-~/GameDev}"), $(basename "${SEWER_STUDIO_DIR:-~/Studio}")
Servicios|NM=${SEWER_SERVICES_NETWORKMANAGER:-1} BT=${SEWER_SERVICES_BLUETOOTH:-0}
EOF
}

tui_summary_rows() {
    tui_summary_rows_extended
}

tui_workflows_label() {
    local parts=()
    parts+=("base")
    [[ "${SEWER_INSTALL_WEBDEV:-0}" == "1" ]] && parts+=("web")
    [[ "${SEWER_INSTALL_GAMEDEV:-0}" == "1" ]] && parts+=("gamedev")
    [[ "${SEWER_INSTALL_AUDIO:-0}" == "1" ]] && parts+=("audio")
    local IFS=' + '
    echo "${parts[*]}"
}

tui_wizard_apply_workflows() {
    local selection="$1"
    installer_cfg_set workflows.webdev 0
    installer_cfg_set workflows.gamedev 0
    installer_cfg_set workflows.audio 0
    grep -q "Desarrollo web" <<< "$selection" && installer_cfg_set workflows.webdev 1
    grep -q "Desarrollo de juegos" <<< "$selection" && installer_cfg_set workflows.gamedev 1
    grep -q "Audio y contenido" <<< "$selection" && installer_cfg_set workflows.audio 1
}

tui_wizard_step_welcome() {
    tui_step_pill 1 "Bienvenida"
    [[ "$(installer_cfg_get ui.show_banner 1)" == "1" ]] && { tui_print_logo_tty; printf '\n' >/dev/tty; }
    tui_panel "Entorno underground para Arch + i3wm
Synthwave Pastel · optimizado para hardware modesto
Usuario: $(whoami) · RAM: $(tui_detect_ram) · CPU: $(tui_detect_cpu)" 
    printf '\n' >/dev/tty
    gum style --foreground "#${TUI_MUTED}" --margin "1 0 0 0" \
        "Enter para continuar · Ctrl+C para salir" >/dev/tty
    read -r </dev/tty || true
}

tui_wizard_step_workflows() {
    tui_clear
    tui_step_pill 2 "Workflows"
    local pre="" opts=() sel
    [[ "$(installer_cfg_get workflows.webdev 0)" == "1" ]] && pre="Desarrollo web,"
    [[ "$(installer_cfg_get workflows.gamedev 0)" == "1" ]] && pre+="Desarrollo de juegos,"
    [[ "$(installer_cfg_get workflows.audio 0)" == "1" ]] && pre+="Audio y contenido,"
    pre="${pre%,}"

    sel="$(tui_gum_choose_multi \
        "Marcá lo que vas a usar (espacio = toggle, enter = continuar)" \
        "$pre" \
        "Desarrollo web (Antigravity, Node, ~/Developer)" \
        "Desarrollo de juegos (Godot 4, ~/GameDev)" \
        "Audio y contenido (LMMS, ~/Studio)" || true)"
    tui_wizard_apply_workflows "${sel:-}"
}

tui_wizard_step_system() {
    tui_clear
    tui_step_pill 3 "Sistema"

    local login zram aur shell browser
    login="$(tui_gum_choose_one "Método de login gráfico" \
        "startx|Autologin tty1 + startx (recomendado, liviano)" \
        "ly|ly — display manager TUI mínimo" \
        "manual|Manual — no tocar login" || echo "startx|Autologin tty1 + startx (recomendado, liviano)")"
    installer_cfg_set system.login_method "${login%%|*}"

    zram="$(tui_gum_choose_one "Perfil de memoria (zRAM)" \
        "balanced|Equilibrado — ram/2 · swappiness 180" \
        "conservative|Conservador — ram/4 · swappiness 120" \
        "aggressive|Agresivo — ram/2 · swappiness 200" || echo "balanced|Equilibrado — ram/2 · swappiness 180")"
    case "${zram%%|*}" in
        conservative) installer_cfg_set system.zram_size "ram/4"; installer_cfg_set system.zram_swappiness 120 ;;
        aggressive)   installer_cfg_set system.zram_size "ram/2"; installer_cfg_set system.zram_swappiness 200 ;;
        *)              installer_cfg_set system.zram_size "ram/2"; installer_cfg_set system.zram_swappiness 180 ;;
    esac

    aur="$(tui_gum_choose_one "Helper AUR" \
        "auto|Auto — detectar paru/yay o compilar paru" \
        "paru|Forzar paru" \
        "yay|Forzar yay" || echo "auto|Auto")"
    installer_cfg_set system.aur_helper "${aur%%|*}"

    shell="$(tui_gum_choose_one "Shell por defecto" \
        "yes|Cambiar a zsh (recomendado)" \
        "no|Mantener shell actual" || echo "yes|Cambiar")"
    installer_cfg_set system.change_shell "$([[ "${shell%%|*}" == yes ]] && echo 1 || echo 0)"

    browser="$(tui_gum_choose_one "Navegador web" \
        "chromium|Chromium (liviano)" \
        "chrome|Google Chrome (AUR, si lo necesitás)" || echo "chromium|Chromium")"
    installer_cfg_set system.browser "${browser%%|*}"
}

tui_wizard_step_desktop() {
    tui_clear
    tui_step_pill 4 "Escritorio"
    local pre="" sel
    [[ "$(installer_cfg_get desktop.enable_picom 1)" == "1" ]] && pre="picom,"
    [[ "$(installer_cfg_get desktop.enable_polybar 1)" == "1" ]] && pre+="polybar,"
    [[ "$(installer_cfg_get desktop.fastfetch_on_terminal 1)" == "1" ]] && pre+="fastfetch,"
    [[ "$(installer_cfg_get desktop.zellij_autostart 1)" == "1" ]] && pre+="zellij,"
    pre="${pre%,}"

    sel="$(tui_gum_choose_multi \
        "Componentes del escritorio base" "$pre" \
        "picom|Compositor (esquinas redondeadas, sombras)" \
        "polybar|Barra superior (workspaces, red, RAM)" \
        "fastfetch|Banner al abrir terminal" \
        "zellij|Multiplexor al abrir kitty" || true)"

    installer_cfg_set desktop.enable_picom "$([[ "$sel" == *picom* ]] && echo 1 || echo 0)"
    installer_cfg_set desktop.enable_polybar "$([[ "$sel" == *polybar* ]] && echo 1 || echo 0)"
    installer_cfg_set desktop.fastfetch_on_terminal "$([[ "$sel" == *fastfetch* ]] && echo 1 || echo 0)"
    installer_cfg_set desktop.zellij_autostart "$([[ "$sel" == *zellij* ]] && echo 1 || echo 0)"
}

tui_wizard_step_confirm() {
    tui_clear
    tui_step_pill 5 "Confirmar"
    installer_config_apply_to_env

    gum style --foreground "#${TUI_PURPLE}" --bold --margin "0 0 1 0" \
        "¿Te cierra este plan?" >/dev/tty

    local rows=()
    while IFS= read -r line; do [[ -n "$line" ]] && rows+=("$line"); done < <(tui_summary_rows)
    tui_draw_table_fallback "${rows[@]}" >/dev/tty
    printf '\n' >/dev/tty

    if ! gum confirm --default=true \
        --prompt.foreground "#${TUI_FG}" \
        --selected.background "#${TUI_PURPLE}" \
        --selected.foreground "#${TUI_BG}" \
        "¿Arrancamos la instalación?" </dev/tty >/dev/tty; then
        gum style --foreground "#${TUI_MUTED}" "Instalación cancelada." >/dev/tty
        exit 0
    fi
}

tui_wizard_fallback() {
    tui_print_logo
    installer_config_apply_to_env
    local rows=()
    while IFS= read -r line; do [[ -n "$line" ]] && rows+=("$line"); done < <(tui_summary_rows)
    tui_draw_table_fallback "${rows[@]}"
    confirm_or_skip "¿Arrancamos la instalación?" || exit 0
}

sewer_installer_wizard() {
    tui_ensure_gum || true
    tui_configure_gum
    tui_clear

    local mode
    mode="$(installer_cfg_get ui.wizard_mode hub)"

    if tui_gum_ready; then
        case "$mode" in
            off)
                return 0
                ;;
            guided)
                tui_wizard_step_welcome
                tui_wizard_step_workflows
                tui_wizard_step_system
                tui_wizard_step_desktop
                tui_wizard_step_confirm
                ;;
            hub | *)
                installer_menu_hub
                tui_clear
                tui_wizard_step_confirm
                ;;
        esac
        return 0
    fi
    tui_wizard_fallback
}

tui_phase_label() {
    case "$1" in
        00-preflight.sh) echo "Verificando sistema…" ;;
        01-pacman-base.sh) echo "Instalando paquetes base…" ;;
        02-aur-helper.sh) echo "Configurando AUR…" ;;
        03-aur-packages.sh) echo "Paquetes AUR…" ;;
        04-zram-setup.sh) echo "Activando zRAM…" ;;
        05-symlink-dotfiles.sh) echo "Enlazando dotfiles…" ;;
        06-shell-setup.sh) echo "Configurando shell…" ;;
        07-workflow-webdev.sh) echo "Workflow web…" ;;
        08-workflow-gamedev.sh) echo "Workflow gamedev…" ;;
        09-workflow-audio-content.sh) echo "Workflow audio…" ;;
        10-services-enable.sh) echo "Servicios…" ;;
        11-branding-assets.sh) echo "Branding…" ;;
        12-apply-installer-choices.sh) echo "Aplicando tu config…" ;;
        *) echo "Ejecutando $1…" ;;
    esac
}

tui_progress_bar() {
    local done="$1" total="$2"
    local width=40 filled empty i bar=""
    filled=$((done * width / total))
    empty=$((width - filled))
    for ((i = 0; i < filled; i++)); do bar+="█"; done
    for ((i = 0; i < empty; i++)); do bar+="░"; done
    printf '%s %s/%s' "$bar" "$done" "$total"
}

tui_run_phase() {
    local script_name="$1" script_path="$2" idx="${3:-0}" total="${4:-0}"
    local label
    label="$(tui_phase_label "$script_name")"
    [[ "$total" -gt 0 ]] && label="[$(tui_progress_bar "$idx" "$total")] ${label}"

    if tui_gum_ready; then
        bash "$script_path" &
        local pid=$!
        gum spin --spinner dot --spinner.foreground "#${TUI_PURPLE}" \
            --title.foreground "#${TUI_FG}" --title "$label" \
            -- bash -c "while kill -0 ${pid} 2>/dev/null; do sleep 0.15; done" </dev/tty >/dev/tty 2>&1
        wait "$pid"
    else
        banner_section "$script_name"
        bash "$script_path"
    fi
}

tui_finish_screen() {
    if ! tui_gum_ready; then banner_section "Instalación completa"; return; fi
    tui_clear
    tui_print_logo_tty
    printf '\n' >/dev/tty
    gum style --foreground "#${TUI_PURPLE}" --bold --margin "0 0 1 0" \
        "Listo. Tu entorno underground te espera." >/dev/tty
    gum format -- <<EOF >/dev/tty
## Próximos pasos

- Cerrá sesión y volvé a entrar (o reiniciá)
- Verificá RAM: \`free -h\` (~300 MB objetivo)
- Config guardada: \`~/.config/sewerdots/installer/choices.conf\`

Log: \`~/.sewerwave-install.log\`
EOF
    gum style --foreground "#${TUI_MUTED}" --margin "1 0 0 0" \
        "sewerdots · synthwave pastel · Sewer boy" >/dev/tty
    printf '\n' >/dev/tty
}

tui_log_wizard_choices() {
    {
        echo "=== sewerdots installer ==="
        echo "profile=${SEWER_PROFILE:-default}"
        echo "webdev=${SEWER_INSTALL_WEBDEV:-?} gamedev=${SEWER_INSTALL_GAMEDEV:-?} audio=${SEWER_INSTALL_AUDIO:-?}"
        echo "login=${SEWER_LOGIN_METHOD:-?} zram=${SEWER_ZRAM_SIZE:-?} swappiness=${SEWER_ZRAM_SWAPPINESS:-?}"
        echo "aur=${SEWER_AUR_HELPER:-?} browser=${SEWER_BROWSER:-?} shell=${SEWER_CHANGE_SHELL:-?}"
        echo "desktop picom=${SEWER_ENABLE_PICOM:-?} polybar=${SEWER_ENABLE_POLYBAR:-?}"
    } >> "${INSTALL_LOG:-${HOME}/.sewerwave-install.log}"
}
