#!/usr/bin/env python3
"""Generate the black launch images. No dependencies.

Card art lives in Resources/Cards and the app icon is built from Resources/Icon/icon-1024.png
by scripts/make-icons.sh, so neither is generated here.
"""
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


for name, width, height in [("Launch-Landscape", 1024, 768), ("Launch-Portrait", 768, 1024)]:
    for scale, suffix in [(1, ""), (2, "@2x")]:
        png(ROOT / (name + suffix + ".png"), width*scale, height*scale, lambda x, y: (0, 0, 0))
