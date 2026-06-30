# sewerwave-dots — zprofile (autologin tty + startx on X11)

# Start X11 session on first login to tty1 (no display manager)
if [[ -z "${DISPLAY:-}" ]] && [[ "$(tty)" == "/dev/tty1" ]]; then
    if command -v startx &>/dev/null; then
        exec startx
    fi
fi

# Default editor
export EDITOR="${EDITOR:-nano}"
export VISUAL="${VISUAL:-$EDITOR}"

# XDG
export XDG_CURRENT_DESKTOP=i3
export XDG_SESSION_TYPE=x11
