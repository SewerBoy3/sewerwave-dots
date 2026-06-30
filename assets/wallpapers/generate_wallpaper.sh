#!/usr/bin/env bash
# ImageMagick fallback wallpaper generator (no Pillow required)
set -euo pipefail

OUTPUT="${1:-$(dirname "$0")/sewerwave-default.png}"
W=1920
H=1080

convert -size "${W}x${H}" gradient:'#221D33-#1A1626' \
    -fill none -stroke '#3A3354' -draw "line 0,$((H*62/100)) ${W},$((H*62/100))" \
    -fill '#F0B8D0' -stroke '#B79CED' -strokewidth 2 \
    -draw "circle $((W/2)),$((H*62/100-40)) $((W/2+90)),$((H*62/100-40))" \
    "$OUTPUT"

echo "Wallpaper written to $OUTPUT"
