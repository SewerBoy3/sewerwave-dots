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
eval "$(starship init zsh)"

# Aliases
alias ls='ls --color=auto'
alias ll='ls -lah'
alias ff='fastfetch'
alias gs='git status -sb'
alias gc='git commit'
alias gp='git push'

# Launch fastfetch on new interactive terminals (skip in subshells/ssh)
if [[ -o interactive ]] && [[ -z "${FASTFETCH_SKIP:-}" ]]; then
    if command -v fastfetch &>/dev/null; then
        fastfetch
    fi
fi

# Zellij in kitty — avoid nested sessions
if [[ -n "${KITTY_WINDOW_ID:-}" && -z "${ZELLIJ:-}" ]]; then
    if command -v zellij &>/dev/null; then
        export ZELLIJ_AUTO_ATTACH=1
        eval "$(zellij setup --generate-auto-start zsh)"
    fi
fi

# PATH additions
export PATH="${HOME}/.local/bin:/usr/local/bin:${PATH}"
