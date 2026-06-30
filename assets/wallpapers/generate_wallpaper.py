#!/usr/bin/env python3
"""Generate sewerwave-dots default wallpaper (Synthwave Pastel, no external deps at install)."""

from __future__ import annotations

import sys
from pathlib import Path

try:
    from PIL import Image, ImageDraw
except ImportError:
    Image = None  # type: ignore

# Palette tokens
BG = (0x1A, 0x16, 0x26)
BG_ALT = (0x22, 0x1D, 0x33)
BORDER = (0x3A, 0x33, 0x54)
PURPLE = (0xB7, 0x9C, 0xED)
CYAN = (0x8F, 0xD3, 0xE8)
PINK = (0xF0, 0xB8, 0xD0)


def lerp(a: int, b: int, t: float) -> int:
    return int(a + (b - a) * t)


def vertical_gradient(width: int, height: int) -> Image.Image:
    img = Image.new("RGB", (width, height))
    px = img.load()
    for y in range(height):
        t = y / max(height - 1, 1)
        r = lerp(BG_ALT[0], BG[0], t)
        g = lerp(BG_ALT[1], BG[1], t)
        b = lerp(BG_ALT[2], BG[2], t)
        for x in range(width):
            px[x, y] = (r, g, b)
    return img


def draw_synthwave_grid(draw: ImageDraw.ImageDraw, width: int, height: int) -> None:
    horizon = int(height * 0.62)
    sun_y = horizon - 40

    # Pastel sun
    draw.ellipse(
        (width // 2 - 90, sun_y - 90, width // 2 + 90, sun_y + 90),
        fill=PINK,
        outline=PURPLE,
        width=2,
    )

    # Horizon line
    draw.line([(0, horizon), (width, horizon)], fill=PURPLE, width=2)

    # Perspective grid below horizon
    vanish_x = width // 2
    for i in range(-12, 13):
        x_base = vanish_x + i * 55
        draw.line([(vanish_x, horizon), (x_base, height)], fill=BORDER, width=1)

    for j in range(1, 9):
        y = horizon + j * ((height - horizon) // 9)
        draw.line([(0, y), (width, y)], fill=BORDER, width=1)

    # Subtle top accent lines
    for offset in (40, 55, 70):
        draw.line([(0, offset), (width, offset)], fill=(*CYAN, ), width=1)


def generate(output: Path, width: int = 1920, height: int = 1080) -> None:
    if Image is None:
        raise SystemExit("Pillow required: pip install pillow OR use imagemagick fallback script")

    img = vertical_gradient(width, height)
    draw = ImageDraw.Draw(img)
    draw_synthwave_grid(draw, width, height)
    output.parent.mkdir(parents=True, exist_ok=True)
    img.save(output, "PNG")
    print(f"Wallpaper written to {output}")


def main() -> None:
    out = Path(sys.argv[1]) if len(sys.argv) > 1 else Path(__file__).parent / "sewerwave-default.png"
    generate(out)


if __name__ == "__main__":
    main()
