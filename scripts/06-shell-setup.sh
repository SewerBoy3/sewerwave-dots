#!/usr/bin/env bash
# Shell setup: zsh as default, starship init, no Oh My Zsh
set -euo pipefail

# shellcheck source=lib/helpers.sh
source "${SEWERWAVE_REPO_ROOT}/scripts/lib/helpers.sh"

ZSH_PATH="$(command -v zsh)"

if [[ -z "$ZSH_PATH" ]]; then
    log_error "zsh not installed"
    exit 1
fi

current_shell="$(getent passwd "$USER" | cut -d: -f7)"
if [[ "$current_shell" == "$ZSH_PATH" ]]; then
    log_ok "Default shell already zsh"
else
    if confirm_or_skip "Change default shell to zsh?"; then
        chsh -s "$ZSH_PATH"
        log_ok "Default shell changed to zsh (effective after next login)"
    else
        log_warn "Skipped chsh — run manually: chsh -s $ZSH_PATH"
    fi
fi

# Enable corepack for optional pnpm/yarn
if command -v corepack &>/dev/null; then
    corepack enable 2>/dev/null || log_warn "corepack enable failed — optional"
fi

log_ok "Shell setup complete"
