"""Generate AOIPulse store / launcher PNG icons."""
from __future__ import annotations

from pathlib import Path
from PIL import Image, ImageDraw

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "assets" / "icons"

BG = (15, 18, 32, 255)
BLOCKS = [
    ((48, 48), (0x29, 0xD4, 0xEB)),
    ((104, 48), (0xF5, 0xCC, 0x33)),
    ((104, 104), (0xA9, 0x5A, 0xE0)),
    ((160, 104), (0x52, 0xC7, 0x66)),
    ((48, 160), (0x43, 0x80, 0xE6)),
    ((104, 160), (0xE6, 0x3E, 0x5F)),
]


def make_icon(size: int) -> Image.Image:
    img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    scale = size / 256.0
    radius = int(48 * scale)
    draw.rounded_rectangle((0, 0, size - 1, size - 1), radius=radius, fill=BG)
    gap = max(1, int(2 * scale))
    for (x, y), color in BLOCKS:
        x0 = int(x * scale)
        y0 = int(y * scale)
        x1 = int((x + 52) * scale) - gap
        y1 = int((y + 52) * scale) - gap
        rr = max(2, int(8 * scale))
        draw.rounded_rectangle((x0, y0, x1, y1), radius=rr, fill=color + (255,))
        # top highlight
        hy = y0 + max(2, int((y1 - y0) * 0.28))
        hi = tuple(min(255, c + 40) for c in color) + (140,)
        draw.rounded_rectangle((x0, y0, x1, hy), radius=rr, fill=hi)
    return img


def main() -> None:
    OUT.mkdir(parents=True, exist_ok=True)
    for size, name in [
        (192, "icon_192.png"),
        (432, "icon_adaptive_fg_432.png"),
        (512, "icon_play_512.png"),
        (1024, "icon_appstore_1024.png"),
    ]:
        path = OUT / name
        make_icon(size).save(path, "PNG")
        print(f"wrote {path}")
    # Also write a square opaque 1024 for Godot project icon override if needed.
    make_icon(256).save(OUT / "icon_256.png", "PNG")
    print("done")


if __name__ == "__main__":
    main()
