"""
Pixel-art generator for the Hicks Center lobby project.

Every PNG in res://art and the bitmap font in res://fonts is produced by this
script, so you can tweak a colour or a shape here and re-run:

    python3 tools/generate_art.py

Requires Pillow (pip install pillow). Godot re-imports the files automatically.
"""
import os
import random
from PIL import Image, ImageDraw

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
ART = os.path.join(ROOT, "art")
FONTS = os.path.join(ROOT, "fonts")
os.makedirs(ART, exist_ok=True)
os.makedirs(FONTS, exist_ok=True)

W, H = 320, 180  # base game resolution

# ---------------------------------------------------------------- palette
SKY_TOP = (104, 170, 226)
SKY_BOT = (190, 226, 244)
CLOUD = (246, 251, 255)
CLOUD_SH = (214, 233, 246)
WHITE = (242, 240, 233)
WHITE_SH = (214, 210, 200)
WHITE_DK = (178, 172, 160)
BRICK = (163, 78, 60)
BRICK_LT = (184, 96, 74)
MORTAR = (122, 58, 46)
SLATE = (88, 104, 122)
SLATE_LT = (108, 126, 145)
SLATE_DK = (64, 76, 92)
GLASS = (40, 56, 74)
GLASS_MID = (54, 74, 96)
GLASS_HI = (96, 128, 156)
GLASS_WARM = (238, 196, 112)
MULLION = (126, 138, 150)
GRASS = (84, 156, 64)
GRASS_LT = (104, 176, 76)
GRASS_DK = (62, 124, 50)
STONE = (202, 196, 182)
STONE_SH = (176, 170, 156)
STONE_DK = (150, 144, 132)
TRUNK = (92, 64, 44)
TRUNK_DK = (66, 46, 32)
LEAF_G = (62, 128, 56)
LEAF_G2 = (82, 150, 66)
LEAF_O = (218, 140, 48)
LEAF_O2 = (236, 172, 72)
LEAF_R = (186, 84, 46)
INK = (34, 30, 30)
K_DISC = (28, 26, 28)
ORANGE = (232, 119, 34)
ORANGE_DK = (186, 88, 22)
ORANGE_LT = (248, 156, 70)
WOOD = (132, 84, 52)
WOOD_LT = (160, 108, 68)
WOOD_DK = (96, 60, 38)
FLOOR_A = (226, 214, 190)
FLOOR_B = (210, 196, 170)
FLOOR_LINE = (190, 176, 150)
WALL = (232, 222, 200)
WALL_SH = (212, 200, 176)
RUG = (40, 36, 40)
RUG_BORDER = (232, 119, 34)
SOFA = (54, 66, 92)
SOFA_LT = (74, 90, 122)
SOFA_DK = (38, 46, 66)
POT = (196, 112, 70)
POT_DK = (150, 82, 52)


def R(d, x, y, w, h, c):
    """Filled rectangle using x, y, width, height."""
    if w <= 0 or h <= 0:
        return
    d.rectangle([x, y, x + w - 1, y + h - 1], fill=c)


def P(d, x, y, c):
    d.point((x, y), fill=c)


# ---------------------------------------------------------------- fonts
# Tiny 3x5 font used for signage baked into the art.
F3 = {
    "A": [".#.", "#.#", "###", "#.#", "#.#"], "B": ["##.", "#.#", "##.", "#.#", "##."],
    "C": [".##", "#..", "#..", "#..", ".##"], "D": ["##.", "#.#", "#.#", "#.#", "##."],
    "E": ["###", "#..", "##.", "#..", "###"], "F": ["###", "#..", "##.", "#..", "#.."],
    "G": [".##", "#..", "#.#", "#.#", ".##"], "H": ["#.#", "#.#", "###", "#.#", "#.#"],
    "I": ["###", ".#.", ".#.", ".#.", "###"], "K": ["#.#", "#.#", "##.", "#.#", "#.#"],
    "L": ["#..", "#..", "#..", "#..", "###"], "M": ["#...#", "##.##", "#.#.#", "#...#", "#...#"],
    "N": ["#..#", "##.#", "#.##", "#..#", "#..#"], "O": [".#.", "#.#", "#.#", "#.#", ".#."],
    "P": ["##.", "#.#", "##.", "#..", "#.."], "R": ["##.", "#.#", "##.", "#.#", "#.#"],
    "S": [".##", "#..", ".#.", "..#", "##."], "T": ["###", ".#.", ".#.", ".#.", ".#."],
    "U": ["#.#", "#.#", "#.#", "#.#", "###"], "V": ["#.#", "#.#", "#.#", "#.#", ".#."],
    "W": ["#...#", "#...#", "#.#.#", "##.##", "#...#"], "Y": ["#.#", "#.#", ".#.", ".#.", ".#."],
    ".": [".", ".", ".", ".", "#"], "!": ["#", "#", "#", ".", "#"], " ": ["..", "..", "..", "..", ".."],
}


def text3_width(s):
    return sum(len(F3[ch][0]) + 1 for ch in s) - 1


def text3(d, x, y, s, c):
    for ch in s:
        g = F3[ch]
        for gy, row in enumerate(g):
            for gx, v in enumerate(row):
                if v == "#":
                    P(d, x + gx, y + gy, c)
        x += len(g[0]) + 1


# 5x7 UI font, exported as a BMFont (.fnt) that Godot imports natively.
F5 = {
    "A": [".###.", "#...#", "#...#", "#####", "#...#", "#...#", "#...#"],
    "B": ["####.", "#...#", "#...#", "####.", "#...#", "#...#", "####."],
    "C": [".###.", "#...#", "#....", "#....", "#....", "#...#", ".###."],
    "D": ["####.", "#...#", "#...#", "#...#", "#...#", "#...#", "####."],
    "E": ["#####", "#....", "#....", "####.", "#....", "#....", "#####"],
    "F": ["#####", "#....", "#....", "####.", "#....", "#....", "#...."],
    "G": [".###.", "#...#", "#....", "#.###", "#...#", "#...#", ".###."],
    "H": ["#...#", "#...#", "#...#", "#####", "#...#", "#...#", "#...#"],
    "I": ["###", ".#.", ".#.", ".#.", ".#.", ".#.", "###"],
    "J": ["..###", "...#.", "...#.", "...#.", "#..#.", "#..#.", ".##.."],
    "K": ["#...#", "#..#.", "#.#..", "##...", "#.#..", "#..#.", "#...#"],
    "L": ["#....", "#....", "#....", "#....", "#....", "#....", "#####"],
    "M": ["#...#", "##.##", "#.#.#", "#.#.#", "#...#", "#...#", "#...#"],
    "N": ["#...#", "##..#", "#.#.#", "#..##", "#...#", "#...#", "#...#"],
    "O": [".###.", "#...#", "#...#", "#...#", "#...#", "#...#", ".###."],
    "P": ["####.", "#...#", "#...#", "####.", "#....", "#....", "#...."],
    "Q": [".###.", "#...#", "#...#", "#...#", "#.#.#", "#..#.", ".##.#"],
    "R": ["####.", "#...#", "#...#", "####.", "#.#..", "#..#.", "#...#"],
    "S": [".####", "#....", "#....", ".###.", "....#", "....#", "####."],
    "T": ["#####", "..#..", "..#..", "..#..", "..#..", "..#..", "..#.."],
    "U": ["#...#", "#...#", "#...#", "#...#", "#...#", "#...#", ".###."],
    "V": ["#...#", "#...#", "#...#", "#...#", "#...#", ".#.#.", "..#.."],
    "W": ["#...#", "#...#", "#...#", "#.#.#", "#.#.#", "#.#.#", ".#.#."],
    "X": ["#...#", "#...#", ".#.#.", "..#..", ".#.#.", "#...#", "#...#"],
    "Y": ["#...#", "#...#", ".#.#.", "..#..", "..#..", "..#..", "..#.."],
    "Z": ["#####", "....#", "...#.", "..#..", ".#...", "#....", "#####"],
    "0": [".###.", "#...#", "#..##", "#.#.#", "##..#", "#...#", ".###."],
    "1": [".#.", "##.", ".#.", ".#.", ".#.", ".#.", "###"],
    "2": [".###.", "#...#", "....#", "...#.", "..#..", ".#...", "#####"],
    "3": ["####.", "....#", "....#", ".###.", "....#", "....#", "####."],
    "4": ["...#.", "..##.", ".#.#.", "#..#.", "#####", "...#.", "...#."],
    "5": ["#####", "#....", "####.", "....#", "....#", "#...#", ".###."],
    "6": [".###.", "#....", "#....", "####.", "#...#", "#...#", ".###."],
    "7": ["#####", "....#", "...#.", "..#..", ".#...", ".#...", ".#..."],
    "8": [".###.", "#...#", "#...#", ".###.", "#...#", "#...#", ".###."],
    "9": [".###.", "#...#", "#...#", ".####", "....#", "....#", ".###."],
    ".": [".", ".", ".", ".", ".", ".", "#"],
    ",": [".", ".", ".", ".", ".", "#", "#"],
    "!": ["#", "#", "#", "#", "#", ".", "#"],
    "?": [".###.", "#...#", "....#", "...#.", "..#..", ".....", "..#.."],
    ":": [".", "#", ".", ".", ".", "#", "."],
    "'": ["#", "#", ".", ".", ".", ".", "."],
    '"': ["#.#", "#.#", "...", "...", "...", "...", "..."],
    "-": ["...", "...", "...", "###", "...", "...", "..."],
    "+": [".....", "..#..", "..#..", "#####", "..#..", "..#..", "....."],
    "=": [".....", ".....", "#####", ".....", "#####", ".....", "....."],
    "_": [".....", ".....", ".....", ".....", ".....", ".....", "#####"],
    "/": ["....#", "...#.", "...#.", "..#..", ".#...", ".#...", "#...."],
    "(": [".#", "#.", "#.", "#.", "#.", "#.", ".#"],
    ")": ["#.", ".#", ".#", ".#", ".#", ".#", "#."],
    "[": ["##", "#.", "#.", "#.", "#.", "#.", "##"],
    "]": ["##", ".#", ".#", ".#", ".#", ".#", "##"],
    ">": ["#...", ".#..", "..#.", "...#", "..#.", ".#..", "#..."],
    "<": ["...#", "..#.", ".#..", "#...", ".#..", "..#.", "...#"],
    "#": [".#.#.", ".#.#.", "#####", ".#.#.", "#####", ".#.#.", ".#.#."],
    "*": [".....", "#.#.#", ".###.", "#####", ".###.", "#.#.#", "....."],
    "|": ["#", "#", "#", "#", "#", "#", "#"],
    "&": [".##..", "#..#.", "#.#..", ".#...", "#.#.#", "#..#.", ".##.#"],
    "%": ["##..#", "##.#.", "...#.", "..#..", ".#...", ".#.##", "#..##"],
    "@": [".###.", "#...#", "#.###", "#.#.#", "#.###", "#....", ".###."],
}


def build_font():
    glyphs = []
    for ch, g in F5.items():
        glyphs.append((ord(ch), g))
        if ch.isalpha():  # all-caps font: lowercase shares the capitals
            glyphs.append((ord(ch.lower()), g))
    cols, cell_w, cell_h = 16, 7, 9
    rows = (len(glyphs) + cols - 1) // cols
    img = Image.new("RGBA", (128, 128), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    lines = []
    for i, (code, g) in enumerate(glyphs):
        cx, cy = (i % cols) * cell_w + 1, (i // cols) * cell_h + 1
        gw = len(g[0])
        for gy, row in enumerate(g):
            for gx, v in enumerate(row):
                if v == "#":
                    P(d, cx + gx, cy + gy, (255, 255, 255, 255))
        lines.append(
            f"char id={code} x={cx} y={cy} width={gw} height=7 xoffset=0 yoffset=1 "
            f"xadvance={gw + 1} page=0 chnl=15"
        )
    lines.append("char id=32 x=0 y=0 width=0 height=0 xoffset=0 yoffset=0 xadvance=4 page=0 chnl=15")
    img.save(os.path.join(FONTS, "hicks_pixel.png"))
    head = [
        'info face="HicksPixel" size=8 bold=0 italic=0 charset="" unicode=1 stretchH=100 '
        "smooth=0 aa=1 padding=0,0,0,0 spacing=1,1 outline=0",
        "common lineHeight=10 base=8 scaleW=128 scaleH=128 pages=1 packed=0",
        'page id=0 file="hicks_pixel.png"',
        f"chars count={len(lines)}",
    ]
    with open(os.path.join(FONTS, "hicks_pixel.fnt"), "w") as f:
        f.write("\n".join(head + lines) + "\n")


# ---------------------------------------------------------------- shared bits
K_GLYPH = ["##..#", "##.##", "####.", "###..", "####.", "##.##", "##..#"]


def k_disc(d, cx, cy, r, disc=K_DISC, ring=WHITE, letter=WHITE):
    d.ellipse([cx - r - 1, cy - r - 1, cx + r + 1, cy + r + 1], fill=ring)
    d.ellipse([cx - r, cy - r, cx + r, cy + r], fill=disc)
    # bold pixel "K", scaled up for larger discs
    s = 1 if r < 10 else 2
    x0 = cx - (5 * s) // 2 + (0 if s == 1 else 1)
    y0 = cy - (7 * s) // 2
    for gy, row in enumerate(K_GLYPH):
        for gx, v in enumerate(row):
            if v == "#":
                R(d, x0 + gx * s, y0 + gy * s, s, s, letter)


def foliage(d, cx, cy, rx, ry, cols, rnd, n=90):
    for _ in range(n):
        a = rnd.uniform(-1, 1)
        b = rnd.uniform(-1, 1)
        if a * a + b * b > 1:
            continue
        x = int(cx + a * rx)
        y = int(cy + b * ry)
        r = rnd.randint(2, 4)
        c = cols[0] if b > 0.25 else rnd.choice(cols)
        d.ellipse([x - r, y - r, x + r, y + r], fill=c)


def brick_wall(d, x, y, w, h):
    R(d, x, y, w, h, BRICK)
    for row in range(0, h, 3):
        R(d, x, y + row + 2, w, 1, MORTAR)
        off = 0 if (row // 3) % 2 == 0 else 3
        for bx in range(x + off, x + w, 6):
            P(d, bx, y + row, MORTAR)
            P(d, bx, y + row + 1, MORTAR)
        for bx in range(x + off + 1, x + w, 12):
            R(d, bx, y + row, 2, 1, BRICK_LT)


def window(d, x, y, w, h, lit=False):
    R(d, x - 1, y - 1, w + 2, h + 2, WHITE)
    R(d, x, y, w, h, GLASS_MID)
    R(d, x, y, w, 1, GLASS)
    if lit:
        R(d, x + 1, y + 1, w - 2, h - 2, GLASS_WARM)
    else:
        P(d, x + 1, y + 1, GLASS_HI)
        P(d, x + 2, y + 1, GLASS_HI)
    R(d, x + w // 2, y, 1, h, WHITE_SH)
    R(d, x, y + h // 2, w, 1, WHITE_SH)
    R(d, x - 1, y + h + 1, w + 2, 1, WHITE_SH)


# ---------------------------------------------------------------- exterior
def exterior():
    rnd = random.Random(7)
    img = Image.new("RGB", (W, H), SKY_TOP)
    d = ImageDraw.Draw(img)

    # sky gradient in bands (pixel-art dithered steps)
    for y in range(0, 100):
        t = y / 100
        c = tuple(int(SKY_TOP[i] + (SKY_BOT[i] - SKY_TOP[i]) * t) for i in range(3))
        c = tuple((v // 6) * 6 for v in c)
        R(d, 0, y, W, 1, c)
    for cx, cy, s in [(46, 18, 1.0), (262, 26, 1.2), (150, 12, 0.7)]:
        for dx, dy, r in [(0, 0, 7), (9, -3, 8), (18, 0, 6), (-8, 2, 5), (26, 3, 4)]:
            rr = int(r * s)
            d.ellipse([cx + dx * s - rr, cy + dy * s - rr, cx + dx * s + rr, cy + dy * s + rr], fill=CLOUD)
        R(d, int(cx - 10 * s), int(cy + 3 * s), int(40 * s), 2, CLOUD_SH)

    # distant trees behind the building
    for x in range(-10, W + 20, 18):
        cols = rnd.choice([[LEAF_G, LEAF_G2], [LEAF_O, LEAF_O2], [LEAF_G, LEAF_O], [LEAF_R, LEAF_O]])
        foliage(d, x + rnd.randint(-4, 4), 78 + rnd.randint(-6, 4), 14, 12, cols, rnd, 40)

    # ---- wings (brick, slate roof)
    for (x0, x1, chimney) in [(0, 112, False), (208, 320, True)]:
        # roof
        d.polygon([(x0 - 2, 84), (x0 + 6, 70), (x1 - 6, 70), (x1 + 2, 84)], fill=SLATE)
        for ry in range(72, 84, 3):
            R(d, x0, ry, x1 - x0, 1, SLATE_DK)
        R(d, x0 + 6, 70, x1 - x0 - 12, 1, SLATE_LT)
        if chimney:
            brick_wall(d, 286, 56, 10, 18)
            R(d, 285, 55, 12, 2, WHITE_SH)
            brick_wall(d, 268, 60, 8, 14)
            R(d, 267, 59, 10, 2, WHITE_SH)
        brick_wall(d, x0, 84, x1 - x0, 46)
        R(d, x0, 84, x1 - x0, 3, WHITE)       # cornice
        R(d, x0, 87, x1 - x0, 1, WHITE_DK)
        R(d, x0, 105, x1 - x0, 2, WHITE_SH)   # belt course
        for wx in range(x0 + 8, x1 - 8, 16):
            window(d, wx, 91, 8, 10)
            window(d, wx, 111, 8, 13, lit=(wx // 16) % 3 == 1)
        R(d, x0, 128, x1 - x0, 2, STONE_DK)   # foundation

    # ---- central hall: two-storey glass curtain wall
    R(d, 104, 70, 112, 60, WHITE)
    R(d, 108, 76, 104, 52, GLASS)
    for gx in range(108, 212, 8):
        R(d, gx, 76, 1, 52, MULLION)
    R(d, 108, 100, 104, 3, WHITE_SH)          # floor slab line
    for gx in range(110, 210, 8):              # sky reflections
        P(d, gx + 1, 78, GLASS_HI)
        P(d, gx + 2, 78, GLASS_HI)
        P(d, gx + 1, 79, GLASS_HI)
        R(d, gx + 1, 105, 6, 1, GLASS_MID)
    # warm interior glimpse on the ground floor
    R(d, 116, 112, 88, 2, (70, 78, 84))
    for lx in (124, 160, 196):
        R(d, lx - 1, 104, 3, 1, GLASS_WARM)

    # front doors
    R(d, 150, 104, 20, 24, MULLION)
    R(d, 151, 105, 8, 23, GLASS_HI)
    R(d, 161, 105, 8, 23, GLASS_HI)
    R(d, 151, 105, 8, 2, (130, 160, 184))
    R(d, 161, 105, 8, 2, (130, 160, 184))
    R(d, 158, 113, 1, 6, WHITE)
    R(d, 161, 113, 1, 6, WHITE)
    R(d, 148, 102, 24, 2, WHITE)

    # entablature with the building name
    R(d, 100, 62, 120, 12, WHITE)
    R(d, 100, 62, 120, 1, WHITE_SH)
    R(d, 100, 73, 120, 1, WHITE_DK)
    R(d, 98, 61, 124, 1, WHITE_SH)
    name = "WEIMER K. HICKS CENTER"
    text3(d, 160 - text3_width(name) // 2, 65, name, (70, 66, 64))

    # pediment
    d.polygon([(96, 61), (160, 28), (224, 61)], fill=WHITE)
    d.polygon([(104, 58), (160, 34), (216, 58)], fill=WHITE_SH)
    d.line([(96, 61), (160, 28)], fill=WHITE_DK)
    d.line([(160, 28), (224, 61)], fill=WHITE_DK)
    R(d, 98, 59, 124, 2, WHITE)
    k_disc(d, 160, 48, 7)

    # columns
    for cx in (116, 140, 180, 204):
        R(d, cx - 4, 74, 9, 3, WHITE)         # capital
        R(d, cx - 3, 77, 7, 47, WHITE)        # shaft
        R(d, cx + 2, 77, 2, 47, WHITE_SH)     # shading
        R(d, cx - 3, 77, 1, 47, (252, 252, 248))
        R(d, cx - 4, 124, 9, 4, WHITE_SH)     # base
        R(d, cx - 4, 124, 9, 1, WHITE)

    # entry steps / plaza
    R(d, 98, 128, 124, 3, STONE)
    R(d, 98, 128, 124, 1, (222, 218, 206))
    R(d, 98, 131, 124, 2, STONE_SH)

    # ---- ground
    R(d, 0, 130, W, H - 130, GRASS)
    for _ in range(420):
        x, y = rnd.randrange(W), rnd.randrange(131, H)
        P(d, x, y, rnd.choice([GRASS_LT, GRASS_DK, GRASS_DK]))
        if rnd.random() < 0.3:
            P(d, x, y - 1, GRASS_LT)
    # path from the doors down to the sidewalk
    R(d, 98, 131, 124, 2, STONE_SH)
    R(d, 98, 133, 124, 6, STONE)              # plaza
    for px in range(98, 222, 8):
        R(d, px, 133, 1, 6, STONE_SH)
    R(d, 98, 139, 124, 1, STONE_DK)
    d.polygon([(146, 139), (174, 139), (178, 148), (142, 148)], fill=STONE)
    # sidewalk
    R(d, 0, 148, W, 9, STONE)
    R(d, 0, 148, W, 1, (222, 218, 206))
    R(d, 0, 156, W, 1, STONE_DK)
    for sx in range(0, W, 12):
        R(d, sx, 149, 1, 7, STONE_SH)
    # path continues to the bottom of the screen
    d.polygon([(142, 157), (178, 157), (186, 180), (134, 180)], fill=STONE)
    for py in range(162, 180, 6):
        R(d, 140, py, 40, 1, STONE_SH)

    # brick planters with shrubs along the façade
    for (x0, x1) in [(10, 96), (224, 312)]:
        brick_wall(d, x0, 131, x1 - x0, 6)
        R(d, x0, 130, x1 - x0, 1, BRICK_LT)
        for sx in range(x0 + 4, x1 - 2, 9):
            d.ellipse([sx - 5, 122, sx + 5, 133], fill=GRASS_DK)
            d.ellipse([sx - 4, 122, sx + 3, 130], fill=LEAF_G)
            P(d, sx - 1, 124, LEAF_G2)
            P(d, sx, 125, LEAF_G2)

    img.save(os.path.join(ART, "exterior.png"))


def tree_big():
    rnd = random.Random(3)
    img = Image.new("RGBA", (60, 84), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    d.ellipse([16, 78, 44, 83], fill=(0, 0, 0, 60))
    R(d, 26, 40, 8, 41, TRUNK)
    R(d, 31, 40, 3, 41, TRUNK_DK)
    R(d, 24, 78, 12, 3, TRUNK)
    d.line([(29, 50), (18, 36)], fill=TRUNK, width=2)
    d.line([(31, 46), (42, 33)], fill=TRUNK, width=2)
    foliage(d, 30, 26, 26, 22, [LEAF_O, LEAF_O2, LEAF_R, LEAF_G2], rnd, 160)
    img.save(os.path.join(ART, "tree_big.png"))


def tree_small():
    rnd = random.Random(11)
    img = Image.new("RGBA", (40, 58), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    d.ellipse([10, 53, 30, 57], fill=(0, 0, 0, 60))
    R(d, 18, 28, 4, 28, TRUNK)
    R(d, 20, 28, 2, 28, TRUNK_DK)
    foliage(d, 20, 20, 16, 16, [LEAF_G, LEAF_G2, LEAF_O], rnd, 100)
    img.save(os.path.join(ART, "tree_small.png"))


def lamp():
    img = Image.new("RGBA", (10, 34), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    d.ellipse([1, 31, 8, 33], fill=(0, 0, 0, 60))
    R(d, 4, 8, 2, 25, (40, 40, 44))
    R(d, 3, 30, 4, 3, (40, 40, 44))
    R(d, 1, 3, 8, 6, (40, 40, 44))
    R(d, 2, 4, 6, 4, (252, 236, 180))
    R(d, 3, 1, 4, 2, (40, 40, 44))
    img.save(os.path.join(ART, "lamp.png"))


def bench():
    img = Image.new("RGBA", (28, 16), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    d.ellipse([1, 12, 26, 15], fill=(0, 0, 0, 60))
    R(d, 2, 2, 24, 2, WOOD_LT)
    R(d, 2, 5, 24, 2, WOOD)
    R(d, 1, 8, 26, 3, WOOD_LT)
    R(d, 1, 10, 26, 1, WOOD_DK)
    for x in (3, 23):
        R(d, x, 2, 2, 12, (40, 40, 44))
    img.save(os.path.join(ART, "bench.png"))


# ---------------------------------------------------------------- characters
def draw_char(d, ox, oy, direction, frame, pal):
    """16x24 cell, feet on row 22. direction: 0 down, 1 left, 2 right, 3 up."""
    skin, hair, top, top_dk, pants, shoes = pal
    step = [0, 1, 0, -1][frame]  # leg swing
    bob = 1 if frame in (1, 3) else 0
    y = oy - bob

    d.ellipse([ox + 3, oy + 20, ox + 12, oy + 23], fill=(0, 0, 0, 70))

    if direction in (0, 3):
        # legs
        lh_l = 4 - (1 if step > 0 else 0)
        lh_r = 4 - (1 if step < 0 else 0)
        R(d, ox + 5, y + 17, 3, lh_l, pants)
        R(d, ox + 8, y + 17, 3, lh_r, pants)
        R(d, ox + 5, y + 17 + lh_l, 3, 1, shoes)
        R(d, ox + 8, y + 17 + lh_r, 3, 1, shoes)
        # torso
        R(d, ox + 4, y + 11, 8, 7, top)
        R(d, ox + 4, y + 17, 8, 1, top_dk)
        # arms swing opposite to legs
        R(d, ox + 3, y + 12 + max(0, -step), 1, 5, top_dk)
        R(d, ox + 12, y + 12 + max(0, step), 1, 5, top_dk)
        P(d, ox + 3, y + 17 + max(0, -step), skin)
        P(d, ox + 12, y + 17 + max(0, step), skin)
        # head
        R(d, ox + 4, y + 3, 8, 8, skin)
        R(d, ox + 5, y + 2, 6, 1, skin)
        if direction == 0:
            R(d, ox + 4, y + 2, 8, 3, hair)
            R(d, ox + 5, y + 1, 6, 1, hair)
            P(d, ox + 4, y + 5, hair)
            P(d, ox + 11, y + 5, hair)
            P(d, ox + 6, y + 7, INK)
            P(d, ox + 9, y + 7, INK)
            P(d, ox + 5, y + 9, (236, 160, 140))
            P(d, ox + 10, y + 9, (236, 160, 140))
            # hoodie strings + pocket
            R(d, ox + 6, y + 11, 1, 3, WHITE)
            R(d, ox + 9, y + 11, 1, 3, WHITE)
            R(d, ox + 5, y + 15, 6, 1, top_dk)
        else:
            R(d, ox + 4, y + 1, 8, 9, hair)
            R(d, ox + 5, y + 10, 6, 1, top_dk)  # hood
    else:
        flip = direction == 2
        def X(x):
            return ox + (15 - x if flip else x)
        # legs (profile)
        front = 1 if step != 0 else 0
        R2 = lambda x, yy, w, h, c: R(d, min(X(x), X(x + w - 1)), yy, w, h, c)
        R2(6 - front, y + 17, 3, 4, pants)
        R2(7 + front, y + 17, 3, 4, pants)
        R2(5 - front, y + 21, 4, 1, shoes)
        R2(7 + front, y + 21, 4, 1, shoes)
        # torso
        R2(5, y + 11, 6, 7, top)
        R2(5, y + 17, 6, 1, top_dk)
        # arm
        R2(7 + (step if step else 0), y + 12, 2, 5, top_dk)
        R2(7 + (step if step else 0), y + 17, 2, 1, skin)
        # head
        R2(5, y + 3, 7, 8, skin)
        R2(5, y + 1, 7, 3, hair)
        R2(8, y + 3, 4, 5, hair)
        P(d, X(5), y + 7, INK)
        P(d, X(4), y + 8, skin)
        P(d, X(6), y + 9, (236, 160, 140))


def characters():
    player_pal = ((241, 194, 140), (58, 40, 30), ORANGE, ORANGE_DK, (44, 58, 90), (30, 30, 34))
    img = Image.new("RGBA", (16 * 4, 24 * 4), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    for direction in range(4):
        for frame in range(4):
            draw_char(d, frame * 16, direction * 24, direction, frame, player_pal)
    img.save(os.path.join(ART, "player.png"))

    staff_pal = ((198, 140, 100), (24, 22, 24), (36, 36, 42), (22, 22, 26), (36, 36, 42), (20, 20, 22))
    img = Image.new("RGBA", (32, 24), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    draw_char(d, 0, 0, 0, 0, staff_pal)
    draw_char(d, 16, 0, 0, 0, staff_pal)
    R(d, 16 + 6, 6, 1, 1, staff_pal[0])  # blink frame: eyes closed
    R(d, 16 + 9, 6, 1, 1, staff_pal[0])
    P(d, 16 + 6, 7, staff_pal[0]); P(d, 16 + 9, 7, staff_pal[0])
    R(d, 16 + 6, 7, 1, 1, (150, 100, 70)); R(d, 16 + 9, 7, 1, 1, (150, 100, 70))
    # orange name badge
    R(d, 9, 13, 2, 1, ORANGE); R(d, 25, 13, 2, 1, ORANGE)
    img.save(os.path.join(ART, "receptionist.png"))


# ---------------------------------------------------------------- interior
def interior():
    img = Image.new("RGB", (W, H), FLOOR_A)
    d = ImageDraw.Draw(img)

    # floor: polished stone tiles
    for ty in range(48, 172, 12):
        for tx in range(0, W, 12):
            c = FLOOR_A if ((tx // 12) + (ty // 12)) % 2 == 0 else FLOOR_B
            R(d, tx, ty, 12, 12, c)
            R(d, tx, ty, 12, 1, FLOOR_LINE)
            R(d, tx, ty, 1, 12, FLOOR_LINE)
            P(d, tx + 3, ty + 3, (240, 232, 214))
            P(d, tx + 4, ty + 3, (240, 232, 214))

    # back wall
    R(d, 0, 0, W, 50, WALL)
    R(d, 0, 0, W, 4, WHITE)
    R(d, 0, 4, W, 1, WALL_SH)
    R(d, 0, 36, W, 12, WOOD)                   # wainscot
    R(d, 0, 36, W, 1, WOOD_LT)
    for px in range(4, W, 16):
        R(d, px, 39, 12, 7, WOOD_LT)
        R(d, px, 45, 12, 1, WOOD_DK)
    R(d, 0, 48, W, 2, WOOD_DK)                 # baseboard
    R(d, 0, 50, W, 1, (170, 156, 130))         # floor shadow

    # tall windows on the left of the back wall
    for wx in (20, 54, 88):
        R(d, wx - 1, 7, 22, 30, WHITE)
        R(d, wx, 8, 20, 28, (150, 200, 232))
        R(d, wx, 26, 20, 10, (98, 160, 82))    # lawn outside
        R(d, wx, 22, 20, 4, (140, 170, 110))
        R(d, wx + 9, 8, 2, 28, WHITE)
        R(d, wx, 20, 20, 1, WHITE)
        P(d, wx + 2, 10, (220, 240, 250)); P(d, wx + 3, 10, (220, 240, 250))

    # game hall doors (the "start game" spot)
    R(d, 134, 6, 52, 44, WOOD_DK)
    R(d, 136, 8, 48, 42, (60, 40, 30))
    R(d, 138, 18, 21, 32, WOOD)
    R(d, 161, 18, 21, 32, WOOD)
    for dx in (138, 161):
        R(d, dx + 3, 21, 15, 11, WOOD_LT)
        R(d, dx + 3, 35, 15, 12, WOOD_LT)
        R(d, dx + 3, 31, 15, 1, WOOD_DK)
        R(d, dx + 3, 46, 15, 1, WOOD_DK)
    R(d, 157, 32, 2, 5, (230, 190, 90))
    R(d, 161, 32, 2, 5, (230, 190, 90))
    R(d, 138, 9, 44, 8, K_DISC)                 # sign
    sign = "GAME HALL"
    text3(d, 160 - text3_width(sign) // 2, 11, sign, ORANGE)

    # right side of back wall: welcome screen + notice board
    R(d, 206, 8, 46, 26, (30, 30, 34))
    R(d, 208, 10, 42, 22, (24, 40, 62))
    text3(d, 229 - text3_width("WELCOME") // 2, 13, "WELCOME", WHITE)
    text3(d, 229 - text3_width("PLAYERS!") // 2, 21, "PLAYERS!", ORANGE)
    R(d, 262, 10, 40, 24, (150, 110, 70))
    R(d, 264, 12, 36, 20, (196, 160, 112))
    for nx, ny, c in [(266, 14, WHITE), (276, 13, (250, 230, 130)), (288, 15, (170, 210, 240)),
                      (268, 23, (250, 180, 150)), (282, 22, WHITE), (292, 24, (250, 230, 130))]:
        R(d, nx, ny, 8, 7, c)
        P(d, nx + 3, ny, (200, 40, 40))

    # side walls (seen from above)
    R(d, 0, 50, 6, 122, WALL_SH)
    R(d, 6, 50, 1, 122, (190, 176, 150))
    R(d, 314, 50, 6, 122, WALL_SH)
    R(d, 313, 50, 1, 122, (190, 176, 150))

    # central rug with the K seal
    R(d, 116, 84, 88, 56, RUG_BORDER)
    R(d, 118, 86, 84, 52, RUG)
    R(d, 121, 89, 78, 46, (52, 46, 50))
    R(d, 122, 90, 76, 44, RUG)
    k_disc(d, 160, 112, 12, disc=RUG, ring=ORANGE, letter=ORANGE)

    # front glass wall at the bottom with the entrance gap
    R(d, 0, 168, W, 12, GLASS)
    for gx in range(0, W, 10):
        R(d, gx, 168, 1, 12, MULLION)
    R(d, 0, 168, W, 2, WHITE)
    R(d, 0, 170, W, 1, GLASS_HI)
    R(d, 144, 168, 32, 12, FLOOR_B)            # doorway
    R(d, 144, 174, 32, 6, (150, 140, 120))     # door mat
    for mx in range(146, 174, 3):
        R(d, mx, 175, 1, 4, (130, 120, 100))
    R(d, 142, 166, 2, 14, WHITE)
    R(d, 176, 166, 2, 14, WHITE)

    img.save(os.path.join(ART, "interior.png"))


def desk():
    img = Image.new("RGBA", (64, 28), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    d.ellipse([2, 22, 61, 27], fill=(0, 0, 0, 50))
    R(d, 2, 4, 60, 6, WHITE)                    # counter top
    R(d, 2, 4, 60, 1, (255, 255, 255))
    R(d, 2, 10, 60, 14, WOOD)                   # front panel
    R(d, 2, 10, 60, 1, WOOD_DK)
    for x in range(6, 60, 10):
        R(d, x, 13, 6, 8, WOOD_LT)
    R(d, 23, 12, 18, 9, K_DISC)
    text3(d, 25, 14, "INFO", ORANGE)
    R(d, 2, 23, 60, 1, WOOD_DK)
    # stuff on the counter
    R(d, 8, 1, 8, 4, (60, 60, 66)); R(d, 9, 2, 6, 2, (120, 180, 220))   # monitor
    R(d, 46, 2, 4, 3, WHITE); R(d, 47, 1, 2, 1, (120, 80, 50))          # mug
    R(d, 52, 3, 7, 2, (250, 240, 200))                                  # papers
    img.save(os.path.join(ART, "desk.png"))


def sofa(facing_down=True):
    img = Image.new("RGBA", (44, 22), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    d.ellipse([1, 17, 42, 21], fill=(0, 0, 0, 50))
    if facing_down:
        R(d, 2, 2, 40, 8, SOFA_DK)              # backrest
        R(d, 3, 3, 38, 6, SOFA)
        R(d, 2, 9, 40, 9, SOFA)                 # seat
        R(d, 4, 10, 17, 6, SOFA_LT); R(d, 23, 10, 17, 6, SOFA_LT)
        R(d, 0, 6, 4, 13, SOFA_DK); R(d, 40, 6, 4, 13, SOFA_DK)
        R(d, 30, 5, 7, 5, ORANGE); R(d, 31, 6, 5, 3, ORANGE_LT)  # cushion
    else:
        R(d, 2, 3, 40, 8, SOFA)                 # seat seen behind
        R(d, 4, 4, 17, 5, SOFA_LT); R(d, 23, 4, 17, 5, SOFA_LT)
        R(d, 2, 9, 40, 9, SOFA_DK)              # back of the sofa
        R(d, 3, 10, 38, 1, SOFA)
        R(d, 0, 2, 4, 16, SOFA_DK); R(d, 40, 2, 4, 16, SOFA_DK)
    img.save(os.path.join(ART, "sofa_down.png" if facing_down else "sofa_up.png"))


def coffee_table():
    img = Image.new("RGBA", (30, 14), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    d.ellipse([2, 10, 27, 13], fill=(0, 0, 0, 50))
    R(d, 1, 2, 28, 6, WOOD_LT)
    R(d, 1, 8, 28, 2, WOOD_DK)
    R(d, 3, 10, 2, 2, WOOD_DK); R(d, 25, 10, 2, 2, WOOD_DK)
    R(d, 6, 3, 7, 4, (250, 240, 220)); R(d, 7, 4, 5, 1, ORANGE)  # magazine
    R(d, 19, 3, 3, 3, WHITE)                                      # cup
    img.save(os.path.join(ART, "coffee_table.png"))


def plant():
    rnd = random.Random(5)
    img = Image.new("RGBA", (16, 28), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    d.ellipse([2, 24, 13, 27], fill=(0, 0, 0, 60))
    R(d, 3, 17, 10, 8, POT)
    R(d, 2, 16, 12, 2, POT_DK)
    R(d, 11, 18, 2, 7, POT_DK)
    for _ in range(14):
        x0, y0 = 8, 17
        x1, y1 = rnd.randint(1, 14), rnd.randint(1, 12)
        d.line([(x0, y0), (x1, y1)], fill=rnd.choice([LEAF_G, LEAF_G2, (48, 104, 44)]), width=2)
    img.save(os.path.join(ART, "plant.png"))


def column():
    img = Image.new("RGBA", (14, 50), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    d.ellipse([0, 45, 13, 49], fill=(0, 0, 0, 60))
    R(d, 1, 0, 12, 4, WHITE)
    R(d, 1, 3, 12, 1, WHITE_DK)
    R(d, 2, 4, 10, 40, WHITE)
    R(d, 9, 4, 3, 40, WHITE_SH)
    R(d, 2, 4, 1, 40, (252, 252, 248))
    R(d, 1, 43, 12, 4, WHITE_SH)
    R(d, 1, 43, 12, 1, WHITE)
    img.save(os.path.join(ART, "column.png"))


def arrow():
    img = Image.new("RGBA", (9, 7), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    d.polygon([(0, 1), (8, 1), (4, 5)], fill=ORANGE, outline=INK)
    img.save(os.path.join(ART, "arrow.png"))


def door_glow():
    img = Image.new("RGBA", (52, 46), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    for i, a in enumerate([200, 120, 60]):
        d.rectangle([i, i, 51 - i, 45], outline=(255, 170, 60, a))
    img.save(os.path.join(ART, "door_glow.png"))


def icon():
    img = Image.new("RGBA", (32, 32), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    k_disc(d, 15, 15, 13)
    img = img.resize((128, 128), Image.NEAREST)
    img.save(os.path.join(ROOT, "icon.png"))


if __name__ == "__main__":
    build_font()
    exterior()
    tree_big()
    tree_small()
    lamp()
    bench()
    characters()
    interior()
    desk()
    sofa(True)
    sofa(False)
    coffee_table()
    plant()
    column()
    arrow()
    door_glow()
    icon()
    print("art generated in", ART)
