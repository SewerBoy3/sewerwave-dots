# sewerdots — opciones del instalador
[[ -f "${HOME}/.config/sewerdots/installer.env" ]] && source "${HOME}/.config/sewerdots/installer.env"

export EDITOR="${SEWER_DEFAULT_EDITOR:-${EDITOR:-nano}}"
export VISUAL="${VISUAL:-$EDITOR}"
export XDG_CURRENT_DESKTOP=i3
export XDG_SESSION_TYPE=x11

# startx en tty1 (si no usás ly ni login manual)
if [[ "${SEWER_LOGIN_METHOD:-startx}" == "startx" ]]; then
    if [[ -z "${DISPLAY:-}" ]] && [[ "$(tty)" == "/dev/tty1" ]]; then
        command -v startx &>/dev/null && exec startx
    fi
fi
