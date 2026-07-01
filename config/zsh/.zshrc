# sewerwave-dots — zsh (no Oh My Zsh; fast startup)

# History
HISTFILE="${HOME}/.cache/zsh/history"
HISTSIZE=5000
SAVEHIST=5000
setopt HIST_IGNORE_DUPS HIST_IGNORE_ALL_DUPS HIST_REDUCE_BLANKS SHARE_HISTORY INC_APPEND_HISTORY

# Completion
autoload -Uz compinit
if [[ -n ${ZDOTDIR}/.zcompdump(#qN.mh+24) ]]; then
    compinit
else
    compinit -C
fi
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

# Plugins (pacman packages, sourced directly)
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# Starship prompt
if [[ "${SEWER_STARSHIP_PROMPT:-1}" == "1" ]] && command -v starship &>/dev/null; then
    eval "$(starship init zsh)"
fi

# Aliases
alias ls='ls --color=auto'
alias ll='ls -lah'
alias ff='fastfetch'
alias gs='git status -sb'
alias gc='git commit'
alias gp='git push'

# sewerdots — opciones del instalador
[[ -f "${HOME}/.config/sewerdots/installer.env" ]] && source "${HOME}/.config/sewerdots/installer.env"

# Launch fastfetch on new interactive terminals
if [[ -o interactive ]] && [[ -z "${FASTFETCH_SKIP:-}" ]]; then
    if [[ "${SEWER_FASTFETCH_TERMINAL:-1}" == "1" ]] && command -v fastfetch &>/dev/null; then
        fastfetch
    fi
fi

# Zellij in kitty — avoid nested sessions
if [[ "${SEWER_ZELLIJ_AUTOSTART:-1}" == "1" ]]; then
    if [[ -n "${KITTY_WINDOW_ID:-}" && -z "${ZELLIJ:-}" ]] && command -v zellij &>/dev/null; then
        export ZELLIJ_AUTO_ATTACH=1
        eval "$(zellij setup --generate-auto-start zsh)"
    fi
fi

# PATH additions
export PATH="${HOME}/.local/bin:/usr/local/bin:${PATH}"
