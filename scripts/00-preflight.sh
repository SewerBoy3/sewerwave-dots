#!/usr/bin/env bash
# Preflight checks: Arch, non-root, internet, sudo
set -euo pipefail

# shellcheck source=lib/helpers.sh
source "${SEWERWAVE_REPO_ROOT}/scripts/lib/helpers.sh"

log_info "Running preflight checks..."

if [[ "${EUID:-$(id -u)}" -eq 0 ]]; then
    log_error "Do not run install.sh as root. Use a normal user with sudo."
    exit 1
fi

if ! command -v pacman &>/dev/null; then
    log_error "pacman not found — this installer requires Arch Linux (or an Arch-based distro with pacman)."
    exit 1
fi

if ! command -v sudo &>/dev/null; then
    log_error "sudo is required but not installed."
    exit 1
fi

if ! sudo -n true 2>/dev/null; then
    log_info "sudo credentials required..."
    if ! sudo -v; then
        log_error "Could not obtain sudo privileges."
        exit 1
    fi
fi

if ! ping -c1 -W5 archlinux.org &>/dev/null; then
    log_error "No internet connectivity (could not reach archlinux.org)."
    exit 1
fi

if ! pacman -Sy --noconfirm &>/dev/null; then
    log_warn "Could not refresh pacman databases — continuing anyway."
else
    log_ok "Pacman databases refreshed"
fi

if ! pacman -Qi base-devel &>/dev/null; then
    log_warn "base-devel not installed — will be installed in next step."
fi

log_ok "Preflight passed"
