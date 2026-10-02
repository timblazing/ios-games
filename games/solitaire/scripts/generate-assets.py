#!/usr/bin/env python3
"""Generate the bundled geometric artwork and black launch images. No dependencies."""
from pathlib import Path
import struct
import zlib

ROOT = Path(__file__).resolve().parent.parent / "Resources"


def png(path, width, height, pixel):
    def chunk(kind, data):
        return (struct.pack(">I", len(data)) + kind + data
                + struct.pack(">I", zlib.crc32(kind + data) & 0xffffffff))
    rows = b"".join(b"\0" + bytes(v for x in range(width) for v in pixel(x, y))
                    for y in range(height))
    path.write_bytes(b"\x89PNG\r\n\x1a\n"
                     + chunk(b"IHDR", struct.pack(">IIBBBBB", width, height, 8, 2, 0, 0, 0))
                     + chunk(b"IDAT", zlib.compress(rows, 9)) + chunk(b"IEND", b""))


png(ROOT / "CardBacks/default.png", 240, 336,
    lambda x, y: (67, 87, 109) if ((x+y) % 32 < 2 or (x-y) % 32 < 2) else (28, 41, 58))
png(ROOT / "CardBacks/graphite.png", 240, 336,
    lambda x, y: (91, 94, 98) if x % 24 in (11, 12) and y % 24 in (11, 12) else (35, 37, 40))
png(ROOT / "CardBacks/burgundy.png", 240, 336,
    lambda x, y: (126, 75, 83) if abs(x % 40-20)+abs(y % 40-20) in (18, 19) else (62, 29, 37))
for scale, suffix in [(1, ""), (2, "@2x")]:
    png(ROOT / ("Launch-Landscape" + suffix + ".png"), 1024*scale, 768*scale, lambda x, y: (0, 0, 0))


def icon_pixel(x, y):
    # An ivory card with a single black spade, on black.
    dx, dy = max(abs(x-.5)-.205, 0), max(abs(y-.5)-.285, 0)
    card = dx*dx+dy*dy < .045**2
    lobes = ((x-.435)**2+(y-.5)**2 < .085**2 or
             (x-.565)**2+(y-.5)**2 < .085**2)
    tip = .31 <= y <= .51 and abs(x-.5) <= (y-.31)*.72
    stem = .50 <= y <= .67 and abs(x-.5) <= .015 + (y-.50)*.24
    return 18 if card and (lobes or tip or stem) else 237 if card else 0


for points, scale in [(29, 1), (29, 2), (40, 1), (40, 2), (76, 1), (76, 2), (83.5, 2)]:
    size = int(points*scale)
    name = f"Icon-{points:g}" + ("@2x" if scale == 2 else "") + ".png"
    def sample(x, y):
        value = round(sum(icon_pixel((x+(sx+.5)/3)/size, (y+(sy+.5)/3)/size)
                          for sy in range(3) for sx in range(3))/9)
        return (value, value, value)
    png(ROOT / name, size, size, sample)
