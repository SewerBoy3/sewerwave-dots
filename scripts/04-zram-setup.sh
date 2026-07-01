#!/usr/bin/env bash
# zRAM — size, algorithm, swappiness from config
set -euo pipefail

source "${SEWERWAVE_REPO_ROOT}/scripts/lib/helpers.sh"
source "${SEWERWAVE_REPO_ROOT}/scripts/lib/installer-config.sh"
installer_config_init
installer_config_apply_to_env

ZRAM_SIZE="${SEWER_ZRAM_SIZE:-ram/2}"
ZRAM_SWAPPINESS="${SEWER_ZRAM_SWAPPINESS:-180}"
ZRAM_ALGO="${SEWER_ZRAM_ALGORITHM:-zstd}"

cat <<EOF | sudo tee /etc/systemd/zram-generator.conf >/dev/null
# sewerdots zRAM
[zram0]
zram-size = ${ZRAM_SIZE}
compression-algorithm = ${ZRAM_ALGO}
swap-priority = 100
EOF

cat <<EOF | sudo tee /etc/sysctl.d/99-sewerdots-swappiness.conf >/dev/null
vm.swappiness = ${ZRAM_SWAPPINESS}
EOF

sudo sysctl --system >/dev/null 2>&1 || true
sudo systemctl daemon-reload
sudo systemctl restart systemd-zram-setup@zram0.service 2>/dev/null || true
log_ok "zRAM: ${ZRAM_SIZE}, ${ZRAM_ALGO}, swappiness ${ZRAM_SWAPPINESS}"
