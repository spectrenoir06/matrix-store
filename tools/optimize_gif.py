#!/usr/bin/env python3
"""Make GIFs smaller without changing a pixel, in a way the matrix plays.

- identical frames in a row become one (their delays added)
- one palette for the whole file when the colors fit (not one per frame)
- each frame keeps only the rectangle that changed, unchanged pixels in it
  transparent: smaller, and faster to decode on the matrix
- every frame "keeps the previous one" (disposal 1): the matrix's player
  wipes the whole screen on "restore background" (2), so that is never used

Checked: the result decodes to the same frames for the same time, else the
file is left as it was.

    python3 tools/optimize_gif.py gif/*.gif          # in place, when smaller
    python3 tools/optimize_gif.py --dry-run gif/*.gif
"""
import io
import struct
import sys
from pathlib import Path

import numpy as np
from PIL import Image


def frames_of(path):
    """Composited RGB frames (as the matrix shows them) with their delays (ms), and the loop count."""
    im = Image.open(path)
    loop = im.info.get("loop", 0)
    out = []
    for k in range(getattr(im, "n_frames", 1)):
        im.seek(k)
        out.append((np.asarray(im.convert("RGB")).copy(), im.info.get("duration", 100)))
    return out, loop


def merge_same(frames):
    merged = []
    for rgb, ms in frames:
        if merged and np.array_equal(merged[-1][0], rgb):
            merged[-1][1] += ms
        else:
            merged.append([rgb, ms])
    return merged


def packed(rgb):
    return (rgb[..., 0].astype(np.uint32) << 16) | (rgb[..., 1].astype(np.uint32) << 8) | rgb[..., 2]


def lzw(indices, bits):
    """GIF LZW of a frame's color indices (a table of 2**bits colors): the data sub-blocks."""
    min_size = max(2, bits)
    clear, end = 1 << min_size, (1 << min_size) + 1
    out, acc, nacc = bytearray(), 0, 0
    size, nxt, table = min_size + 1, end + 1, {}

    def put(code):
        nonlocal acc, nacc
        acc |= code << nacc
        nacc += size
        while nacc >= 8:
            out.append(acc & 255)
            acc >>= 8
            nacc -= 8

    put(clear)
    data = indices.astype(np.uint8).tobytes()
    cur = data[0]
    for k in data[1:]:
        key = (cur << 8) | k
        code = table.get(key)
        if code is not None:
            cur = code
            continue
        put(cur)
        if nxt < 4096:
            table[key] = nxt
            nxt += 1
            if nxt > (1 << size) and size < 12:
                size += 1
        else:  # table full: start over
            put(clear)
            table.clear()
            size, nxt = min_size + 1, end + 1
        cur = k
    put(cur)
    put(end)
    if nacc:
        out.append(acc & 255)
    blocks = bytearray([min_size])
    for i in range(0, len(out), 255):
        chunk = out[i:i + 255]
        blocks += bytes([len(chunk)]) + chunk
    return bytes(blocks + b"\x00")


def bits_for(n):
    return max(1, int(np.ceil(np.log2(max(n, 2)))))


def color_table(palette, bits):
    out = bytearray()
    for c in palette:
        out += bytes(((c >> 16) & 255, (c >> 8) & 255, c & 255))
    return bytes(out) + bytes(3 * (1 << bits) - len(out))


def encode(frames, loop):
    h, w = frames[0][0].shape[:2]
    colors = np.unique(np.concatenate([packed(f).ravel() for f, _ in frames]))
    glob = len(colors) <= 255  # one palette for all, with a spare index for transparent
    gpal = colors.tolist() if glob else None
    gindex = {c: i for i, c in enumerate(gpal)} if glob else None
    gtrans = len(gpal) if glob else None

    body = bytearray()
    prev = None
    gbits = 1
    for rgb, ms in frames:
        cur = packed(rgb)
        if prev is None:
            x0, y0, x1, y1 = 0, 0, w, h
            changed = np.ones((h, w), bool)
        else:
            changed = cur != prev
            ys, xs = np.nonzero(changed)
            if len(xs) == 0:  # can't happen after merge_same, but a GIF needs a frame
                ys, xs = np.array([0]), np.array([0])
            x0, x1, y0, y1 = xs.min(), xs.max() + 1, ys.min(), ys.max() + 1
        region, mask = cur[y0:y1, x0:x1], changed[y0:y1, x0:x1]
        if glob:
            pal, index, trans = gpal + [0], gindex, gtrans
        else:
            own = np.unique(region[mask]).tolist()
            trans = len(own) if len(own) < 256 and not mask.all() else None
            pal = own + ([0] if trans is not None else [])
            if trans is None and len(np.unique(region)) > 256:
                raise ValueError("a frame with more than 256 colors")
            if trans is None:
                pal = np.unique(region).tolist()
                mask = np.ones_like(mask)
            # from the real colors only: the transparent slot's placeholder (0, black)
            # must not take black's index
            index = {c: i for i, c in enumerate(pal[:trans] if trans is not None else pal)}
        lut = np.vectorize(index.__getitem__, otypes=[np.int32])
        ids = np.full(region.shape, trans if trans is not None else 0, np.int32)
        ids[mask] = lut(region[mask])
        use_trans = trans is not None and not mask.all()
        bits = bits_for(len(pal))
        data = lzw(ids, bits)
        delay = max(1, round(ms / 10))
        flags = (1 << 2) | (1 if use_trans else 0)  # disposal 1: keep this frame
        body += b"\x21\xF9\x04" + bytes([flags]) + struct.pack("<H", delay) + bytes([trans if use_trans else 0]) + b"\x00"
        if glob:
            gbits = max(gbits, bits)
            body += b"\x2C" + struct.pack("<HHHH", x0, y0, x1 - x0, y1 - y0) + b"\x00"
        else:
            body += b"\x2C" + struct.pack("<HHHH", x0, y0, x1 - x0, y1 - y0) + bytes([0x80 | (bits - 1)])
            body += color_table(pal, bits)
        body += data
        prev = cur
    if glob:
        gbits = bits_for(len(gpal) + 1)
    head = b"GIF89a" + struct.pack("<HH", w, h)
    head += bytes([(0x80 | 0x70 | (gbits - 1)) if glob else 0x70, 0, 0])
    if glob:
        head += color_table(gpal + [0], gbits)
    head += b"\x21\xFF\x0BNETSCAPE2.0\x03\x01" + struct.pack("<H", loop) + b"\x00"
    return head + bytes(body) + b"\x3B"


def same(a, b):
    """Same frames for the same time (delays rounded to the GIF's 10 ms)."""
    def timeline(frames):
        out = []
        for rgb, ms in merge_same(frames):
            out.append((rgb, round(ms / 10)))
        return out
    ta, tb = timeline(a), timeline(b)
    return len(ta) == len(tb) and all(np.array_equal(x[0], y[0]) and x[1] == y[1] for x, y in zip(ta, tb))


def main():
    dry = "--dry-run" in sys.argv
    for name in [a for a in sys.argv[1:] if not a.startswith("--")]:
        path = Path(name)
        frames, loop = frames_of(path)
        merged = merge_same(frames)
        try:
            data = encode(merged, loop)
        except ValueError as e:
            print(f"{path.name}: skipped ({e})")
            continue
        check, _ = frames_of(io.BytesIO(data))
        old = path.stat().st_size
        if not same(frames, check):
            print(f"{path.name}: NOT identical after optimizing, left as it was")
            continue
        verdict = f"{old // 1024} KB -> {len(data) // 1024} KB ({100 - 100 * len(data) // old}% less), {len(frames)} -> {len(merged)} frames"
        if len(data) >= old:
            print(f"{path.name}: already optimal ({old // 1024} KB)")
        elif dry:
            print(f"{path.name}: would be {verdict}")
        else:
            path.write_bytes(data)
            print(f"{path.name}: {verdict}")


if __name__ == "__main__":
    main()
