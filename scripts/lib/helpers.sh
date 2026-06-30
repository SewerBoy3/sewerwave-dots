#!/usr/bin/env bash
# sewerwave-dots — shared helpers (logging, idempotency, prompts)
# shellcheck shell=bash

# ── Brand palette (truecolor ANSI) ──────────────────────────────────────────
readonly SW_COLOR_BG="#1A1626"
readonly SW_COLOR_BG_ALT="#221D33"
readonly SW_COLOR_BORDER="#3A3354"
readonly SW_COLOR_FG="#E8E1F5"
readonly SW_COLOR_FG_MUTED="#9C90B5"
readonly SW_COLOR_PURPLE="#B79CED"
readonly SW_COLOR_RED="#D98C8C"
readonly SW_COLOR_CYAN="#8FD3E8"
readonly SW_COLOR_PINK="#F0B8D0"
readonly SW_COLOR_GREEN="#A8D9B0"
readonly SW_COLOR_YELLOW="#E8D9A0"

# Global flags (set by install.sh)
SEWERWAVE_NONINTERACTIVE="${SEWERWAVE_NONINTERACTIVE:-0}"
SEWERWAVE_REPO_ROOT="${SEWERWAVE_REPO_ROOT:-}"

_hex_to_rgb() {
    local hex="${1#\#}"
    printf '%d;%d;%d' "0x${hex:0:2}" "0x${hex:2:2}" "0x${hex:4:2}"
}

_sw_fg() {
    local rgb
    rgb="$(_hex_to_rgb "$1")"
    printf '\033[38;2;%sm' "$rgb"
}

_sw_bg() {
    local rgb
    rgb="$(_hex_to_rgb "$1")"
    printf '\033[48;2;%sm' "$rgb"
}

readonly _SW_RESET=$'\033[0m'
readonly _SW_BOLD=$'\033[1m'

log_info() {
    printf '%b%b[INFO]%b %s\n' "$(_sw_fg "$SW_COLOR_CYAN")" "$_SW_BOLD" "$_SW_RESET" "$*"
}

log_ok() {
    printf '%b%b[ OK ]%b %s\n' "$(_sw_fg "$SW_COLOR_GREEN")" "$_SW_BOLD" "$_SW_RESET" "$*"
}

log_warn() {
    printf '%b%b[WARN]%b %s\n' "$(_sw_fg "$SW_COLOR_YELLOW")" "$_SW_BOLD" "$_SW_RESET" "$*"
}

log_error() {
    printf '%b%b[ERR ]%b %s\n' "$(_sw_fg "$SW_COLOR_RED")" "$_SW_BOLD" "$_SW_RESET" "$*" >&2
}

banner_section() {
    local title="$1"
    local width=60
    local line
    line="$(printf '─%.0s' $(seq 1 "$width"))"
    printf '\n%b%s%b\n' "$(_sw_fg "$SW_COLOR_PURPLE")" "$line" "$_SW_RESET"
    printf '%b  %s%b\n' "$(_sw_fg "$SW_COLOR_FG")" "$title" "$_SW_RESET"
    printf '%b%s%b\n\n' "$(_sw_fg "$SW_COLOR_BORDER")" "$line" "$_SW_RESET"
}

confirm_or_skip() {
    local prompt="$1"
    if [[ "$SEWERWAVE_NONINTERACTIVE" -eq 1 ]]; then
        return 0
    fi
    local reply
    read -r -p "$(printf '%b%s [Y/n]: %b' "$(_sw_fg "$SW_COLOR_PURPLE")" "$prompt" "$_SW_RESET")" reply
    reply="${reply:-Y}"
    [[ "$reply" =~ ^[Yy]$ ]]
}

require_command() {
    local cmd="$1"
    if ! command -v "$cmd" &>/dev/null; then
        log_error "Required command not found: $cmd"
        return 1
    fi
}

require_pacman_pkg() {
    local pkg="$1"
    pacman -Qi "$pkg" &>/dev/null
}

install_pacman_pkg() {
    local pkg="$1"
    if require_pacman_pkg "$pkg"; then
        log_ok "Already installed: $pkg"
        return 0
    fi
    log_info "Installing $pkg..."
    sudo pacman -S --needed --noconfirm "$pkg"
}

install_pacman_pkgs() {
    local pkgs=("$@")
    local missing=()
    local pkg
    for pkg in "${pkgs[@]}"; do
        if ! require_pacman_pkg "$pkg"; then
            missing+=("$pkg")
        fi
    done
    if ((${#missing[@]} == 0)); then
        log_ok "All pacman packages already present (${#pkgs[@]} checked)"
        return 0
    fi
    log_info "Installing pacman packages: ${missing[*]}"
    sudo pacman -S --needed --noconfirm "${missing[@]}"
}

require_aur_pkg() {
    local pkg="$1"
    if require_pacman_pkg "$pkg"; then
        return 0
    fi
    if command -v yay &>/dev/null && yay -Qi "$pkg" &>/dev/null 2>&1; then
        return 0
    fi
    if command -v paru &>/dev/null && paru -Qi "$pkg" &>/dev/null 2>&1; then
        return 0
    fi
    return 1
}

install_aur_pkg() {
    local pkg="$1"
    if require_aur_pkg "$pkg"; then
        log_ok "Already installed (AUR/pacman): $pkg"
        return 0
    fi
    local helper
    helper="$(detect_aur_helper)"
    if [[ -z "$helper" ]]; then
        log_error "No AUR helper available to install $pkg"
        return 1
    fi
    log_info "Installing AUR package $pkg via $helper..."
    if [[ "$SEWERWAVE_NONINTERACTIVE" -eq 1 ]]; then
        "$helper" -S --needed --noconfirm "$pkg"
    else
        "$helper" -S --needed "$pkg"
    fi
}

detect_aur_helper() {
    if command -v paru &>/dev/null; then
        echo paru
    elif command -v yay &>/dev/null; then
        echo yay
    fi
}

backup_path_if_real() {
    local target="$1"
    if [[ -e "$target" && ! -L "$target" ]]; then
        local backup_root="${HOME}/.config-backup-$(date +%Y%m%d%H%M%S)"
        mkdir -p "$backup_root"
        log_warn "Backing up existing $target → $backup_root/"
        cp -a "$target" "$backup_root/"
        rm -rf "$target"
    fi
}

symlink_config_dir() {
    local src="$1"
    local dest="$2"
    backup_path_if_real "$dest"
    mkdir -p "$(dirname "$dest")"
    if [[ -L "$dest" ]]; then
        local current
        current="$(readlink -f "$dest")"
        local expected
        expected="$(readlink -f "$src")"
        if [[ "$current" == "$expected" ]]; then
            log_ok "Symlink already correct: $dest"
            return 0
        fi
        rm "$dest"
    fi
    ln -sfn "$src" "$dest"
    log_ok "Linked $dest → $src"
}

symlink_config_file() {
    local src="$1"
    local dest="$2"
    backup_path_if_real "$dest"
    mkdir -p "$(dirname "$dest")"
    if [[ -L "$dest" ]]; then
        local current expected
        current="$(readlink -f "$dest")"
        expected="$(readlink -f "$src")"
        if [[ "$current" == "$expected" ]]; then
            log_ok "Symlink already correct: $dest"
            return 0
        fi
        rm "$dest"
    fi
    ln -sfn "$src" "$dest"
    log_ok "Linked $dest → $src"
}

ensure_dir() {
    local dir="$1"
    if [[ -d "$dir" ]]; then
        log_ok "Directory exists: $dir"
    else
        mkdir -p "$dir"
        log_ok "Created directory: $dir"
    fi
}

service_is_enabled() {
    local unit="$1"
    systemctl is-enabled --quiet "$unit" 2>/dev/null
}

service_is_active_user() {
    local unit="$1"
    systemctl --user is-active --quiet "$unit" 2>/dev/null
}

disable_system_service() {
    local unit="$1"
    if systemctl list-unit-files "$unit" &>/dev/null; then
        if service_is_enabled "$unit"; then
            log_info "Disabling system service: $unit"
            sudo systemctl disable --now "$unit" 2>/dev/null || sudo systemctl disable "$unit" 2>/dev/null || true
        else
            log_ok "Already disabled: $unit"
        fi
    fi
}

enable_user_service() {
    local unit="$1"
    systemctl --user enable "$unit" 2>/dev/null || true
    systemctl --user start "$unit" 2>/dev/null || true
    log_ok "User service enabled: $unit"
}
