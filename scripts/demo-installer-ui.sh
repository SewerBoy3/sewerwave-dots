#!/usr/bin/env bash
# Simulación del instalador TUI (5 pasos) — no instala nada
set -euo pipefail

SEWERWAVE_REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export SEWERWAVE_REPO_ROOT
export SEWERWAVE_NONINTERACTIVE=1
export SEWER_PROFILE=default

source "${SEWERWAVE_REPO_ROOT}/scripts/lib/helpers.sh"
source "${SEWERWAVE_REPO_ROOT}/scripts/lib/installer-config.sh"
source "${SEWERWAVE_REPO_ROOT}/scripts/lib/tui.sh"

installer_config_init
installer_config_apply_to_env

pause_demo() {
    [[ "${DEMO_AUTO:-0}" == "1" ]] && sleep 0.8 && return
    read -r -p "$(printf '%b[Enter]%b ' "$(_sw_fg "$SW_COLOR_FG_MUTED")" "$_SW_RESET")"
}

steps=("1:Bienvenida" "2:Workflows" "3:Sistema" "4:Escritorio" "5:Confirmar")
for entry in "${steps[@]}"; do
    step="${entry%%:*}"
    title="${entry#*:}"
    [[ "$step" == "1" ]] || printf '\n'
    tui_step_pill "$step" "$title"
    case "$step" in
        1)
            tui_print_logo
            tui_panel "Entorno underground · Arch + i3wm · Synthwave Pastel"
            ;;
        2)
            printf '\n  ◉ Desarrollo web\n  ◉ GameDev\n  ◉ Audio\n'
            ;;
        3)
            printf '\n  Login: startx · zRAM: equilibrado · AUR: auto · Browser: brave\n'
            ;;
        4)
            printf '\n  ◉ picom  ◉ polybar  ◉ fastfetch  ◉ zellij\n'
            ;;
        5)
            printf '\n'
            rows=()
            while IFS= read -r line; do [[ -n "$line" ]] && rows+=("$line"); done < <(tui_summary_rows)
            tui_draw_table_fallback "${rows[@]}"
            printf '\n  %b[Sí — arrancar instalación]%b\n' \
                "$(_sw_bg "$SW_COLOR_PURPLE")$(_sw_fg "$SW_COLOR_BG")" "$_SW_RESET"
            ;;
    esac
    pause_demo
done

printf '\n%b%s%b\n' "$(_sw_fg "$SW_COLOR_GREEN")" \
    "Simulación lista · wizard real: ./install.sh · perfiles: --profile minimal|full" "$_SW_RESET"
