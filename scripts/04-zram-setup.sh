#!/usr/bin/env bash
# zRAM swap via zram-generator + swappiness tuning
set -euo pipefail

# shellcheck source=lib/helpers.sh
source "${SEWERWAVE_REPO_ROOT}/scripts/lib/helpers.sh"

ZRAM_CONF="/etc/systemd/zram-generator.conf"
ZRAM_CONTENT='# sewerwave-dots — compressed swap for 4 GB RAM systems
[zram0]
zram-size = ram / 2
compression-algorithm = zstd
swap-priority = 100
'

if [[ -f "$ZRAM_CONF" ]] && grep -q 'sewerwave-dots' "$ZRAM_CONF" 2>/dev/null; then
    log_ok "zram-generator already configured"
else
    log_info "Writing $ZRAM_CONF"
    echo "$ZRAM_CONTENT" | sudo tee "$ZRAM_CONF" >/dev/null
fi

SYSCTL_DROPIN="/etc/sysctl.d/99-sewerwave-swappiness.conf"
SYSCTL_CONTENT='# sewerwave-dots — higher swappiness for zram (standard practice)
vm.swappiness = 180
'

if [[ -f "$SYSCTL_DROPIN" ]]; then
    log_ok "Swappiness drop-in already present"
else
    echo "$SYSCTL_CONTENT" | sudo tee "$SYSCTL_DROPIN" >/dev/null
    sudo sysctl --system >/dev/null 2>&1 || sudo sysctl -p "$SYSCTL_DROPIN" 2>/dev/null || true
fi

sudo systemctl daemon-reload
sudo systemctl restart systemd-zram-setup@zram0.service 2>/dev/null || \
    sudo systemctl start systemd-zram-setup@zram0.service 2>/dev/null || \
    log_warn "zram service will activate after reboot"

log_ok "zRAM configured (zstd, swappiness=180)"
