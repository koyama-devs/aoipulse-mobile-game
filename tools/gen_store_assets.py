"""Generate Google Play feature graphic + phone store screenshot mockups."""
from __future__ import annotations

from pathlib import Path
from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "assets" / "store"
ICONS = ROOT / "assets" / "icons"

BG = (15, 18, 32)
PANEL = (26, 31, 51)
ACCENT = (74, 212, 235)
WHITE = (245, 248, 255)
MUTED = (170, 180, 200)
COLORS = [
    (41, 212, 235),
    (245, 204, 51),
    (169, 90, 224),
    (82, 199, 102),
    (230, 62, 95),
    (67, 128, 230),
    (244, 148, 56),
]

# Sample board states for screenshots (piece index or -1)
BOARD_A = [[-1] * 10 for _ in range(20)]
for x in range(10):
    BOARD_A[19][x] = x % 7
for x in range(8):
    BOARD_A[18][x] = (x + 2) % 7
BOARD_A[17][3] = 2
BOARD_A[17][4] = 2
BOARD_A[17][5] = 2
BOARD_A[16][4] = 2

BOARD_B = [row[:] for row in BOARD_A]
for x in range(10):
    BOARD_B[15][x] = 0  # full flash row feel
BOARD_B[14][1] = 4
BOARD_B[14][2] = 4
BOARD_B[13][2] = 4


def font(size: int) -> ImageFont.ImageFont:
    for name in ("segoeui.ttf", "arial.ttf", "DejaVuSans.ttf"):
        try:
            return ImageFont.truetype(name, size)
        except OSError:
            continue
    return ImageFont.load_default()


def rounded(draw: ImageDraw.ImageDraw, xy, r: int, fill):
    draw.rounded_rectangle(xy, radius=r, fill=fill)


def draw_board(img: Image.Image, origin, cell: int, board, ghost=None, active=None):
    draw = ImageDraw.Draw(img)
    cols, rows = 10, 20
    bw, bh = cell * cols, cell * rows
    x0, y0 = origin
    rounded(draw, (x0 - 6, y0 - 6, x0 + bw + 6, y0 + bh + 6), 12, PANEL)
    draw.rectangle((x0 - 6, y0 - 6, x0 + bw + 6, y0 + bh + 6), outline=ACCENT + (0,), width=2)
    # approximate outline
    draw.rounded_rectangle((x0 - 6, y0 - 6, x0 + bw + 6, y0 + bh + 6), radius=12, outline=ACCENT, width=2)
    for y in range(rows):
        for x in range(cols):
            v = board[y][x]
            if v < 0:
                continue
            px = x0 + x * cell
            py = y0 + y * cell
            c = COLORS[v]
            draw.rectangle((px + 1, py + 1, px + cell - 2, py + cell - 2), fill=c)
            draw.rectangle((px + 1, py + 1, px + cell - 2, py + int(cell * 0.28)), fill=tuple(min(255, i + 40) for i in c))
    if ghost:
        gpos, gtype = ghost
        for cx, cy in gpos:
            if cy < 0:
                continue
            px = x0 + cx * cell
            py = y0 + cy * cell
            c = COLORS[gtype] + (55,)
            # PIL RGB only for main image; blend manually
            base = img.getpixel((px + cell // 2, py + cell // 2))
            blend = tuple(int(base[i] * 0.7 + COLORS[gtype][i] * 0.3) for i in range(3))
            draw.rectangle((px + 1, py + 1, px + cell - 2, py + cell - 2), fill=blend)
    if active:
        apos, atype = active
        for cx, cy in apos:
            if cy < 0:
                continue
            px = x0 + cx * cell
            py = y0 + cy * cell
            c = COLORS[atype]
            draw.rectangle((px + 1, py + 1, px + cell - 2, py + cell - 2), fill=c)
            draw.rectangle((px + 1, py + 1, px + cell - 2, py + int(cell * 0.28)), fill=tuple(min(255, i + 40) for i in c))


def t_cells(offsets, pos):
    return [(pos[0] + o[0], pos[1] + o[1]) for o in offsets]


T = [(1, 0), (0, 1), (1, 1), (2, 1)]


def phone_frame(w=720, h=1280) -> Image.Image:
    img = Image.new("RGB", (w, h), BG)
    draw = ImageDraw.Draw(img)
    # ambient
    for i in range(6):
        x = 40 + i * 110
        y = 80 + (i % 3) * 180
        c = COLORS[i % 7]
        draw.rectangle((x, y, x + 28, y + 28), fill=tuple(int(v * 0.25) for v in c))
    return img


def shot_menu():
    img = phone_frame()
    d = ImageDraw.Draw(img)
    d.text((360, 260), "AOIPULSE", font=font(64), fill=ACCENT, anchor="mm")
    d.text((360, 330), "by Aoitex", font=font(22), fill=MUTED, anchor="mm")
    d.text((360, 390), "Best score  12840", font=font(26), fill=WHITE, anchor="mm")
    for i, label in enumerate(("PLAY", "SETTINGS", "HOW TO PLAY")):
        y = 480 + i * 90
        rounded(d, (180, y, 540, y + 70), 16, (30, 107, 132) if i == 0 else (36, 46, 72))
        d.text((360, y + 35), label, font=font(28), fill=WHITE, anchor="mm")
    d.text((360, 780), "Swipe to move · Tap to rotate", font=font(18), fill=MUTED, anchor="mm")
    return img


def shot_play():
    img = phone_frame()
    d = ImageDraw.Draw(img)
    d.text((24, 18), "Score 2460", font=font(30), fill=WHITE)
    d.text((24, 52), "Best 12840", font=font(18), fill=MUTED)
    d.text((24, 78), "Lv 3    Lines 24", font=font(18), fill=MUTED)
    rounded(d, (640, 16, 696, 72), 12, (36, 46, 72))
    d.text((668, 44), "II", font=font(22), fill=WHITE, anchor="mm")
    cell = 36
    ox = (720 - cell * 10) // 2
    oy = 150
    active = (t_cells(T, (3, 4)), 2)
    ghost = (t_cells(T, (3, 15)), 2)
    draw_board(img, (ox, oy), cell, BOARD_A, ghost=ghost, active=active)
    # pad
    labels = ["◀", "H", "⟳", "▼", "⤓", "▶"]
    for i, lab in enumerate(labels):
        x = 48 + i * 110
        rounded(d, (x, 1120, x + 90, 1220), 14, (36, 46, 72))
        d.text((x + 45, 1170), lab, font=font(28), fill=WHITE, anchor="mm")
    return img


def shot_combo():
    img = shot_play()
    d = ImageDraw.Draw(img)
    d.text((360, 520), "COMBO x3  +1350", font=font(32), fill=WHITE, anchor="mm")
    # flash row
    cell = 36
    ox = (720 - cell * 10) // 2
    oy = 150
    y = oy + 15 * cell
    d.rectangle((ox, y, ox + cell * 10, y + cell), fill=(74, 212, 235, 120) if False else (74, 212, 235))
    return img


def shot_gameover():
    img = shot_play()
    overlay = Image.new("RGBA", img.size, (0, 0, 0, 150))
    img = img.convert("RGBA")
    img.alpha_composite(overlay)
    img = img.convert("RGB")
    d = ImageDraw.Draw(img)
    d.text((360, 520), "GAME OVER", font=font(48), fill=WHITE, anchor="mm")
    d.text((360, 590), "Score 2460   •   Best 12840", font=font(22), fill=MUTED, anchor="mm")
    d.text((360, 640), "Tap to play again", font=font(20), fill=MUTED, anchor="mm")
    rounded(d, (220, 700, 500, 760), 14, (36, 46, 72))
    d.text((360, 730), "MAIN MENU", font=font(24), fill=WHITE, anchor="mm")
    return img


def feature_graphic() -> Image.Image:
    img = Image.new("RGB", (1024, 500), BG)
    d = ImageDraw.Draw(img)
    # decorative blocks
    for i, (x, y, c) in enumerate([
        (40, 60, 0), (100, 60, 1), (100, 120, 2), (160, 120, 3),
        (40, 180, 5), (100, 180, 4), (820, 80, 6), (880, 80, 2),
        (820, 140, 0), (880, 140, 3), (940, 140, 1),
    ]):
        col = COLORS[c]
        d.rounded_rectangle((x, y, x + 52, y + 52), radius=8, fill=col)
    icon_path = ICONS / "icon_256.png"
    if icon_path.exists():
        icon = Image.open(icon_path).convert("RGBA").resize((180, 180))
        img.paste(icon, (70, 160), icon)
    d.text((290, 170), "AOIPULSE", font=font(72), fill=ACCENT)
    d.text((290, 260), "Stack. Clear. Pulse.", font=font(36), fill=WHITE)
    d.text((290, 330), "A modern falling-blocks puzzle by Aoitex", font=font(24), fill=MUTED)
    d.text((290, 390), "Offline · Combos · Local high scores", font=font(22), fill=MUTED)
    return img


def main() -> None:
    OUT.mkdir(parents=True, exist_ok=True)
    shots = {
        "screenshot_01_menu.png": shot_menu(),
        "screenshot_02_play.png": shot_play(),
        "screenshot_03_combo.png": shot_combo(),
        "screenshot_04_gameover.png": shot_gameover(),
        "feature_graphic_1024x500.png": feature_graphic(),
    }
    for name, im in shots.items():
        path = OUT / name
        im.save(path, "PNG")
        print(f"wrote {path} {im.size}")


if __name__ == "__main__":
    main()
