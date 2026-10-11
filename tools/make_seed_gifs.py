#!/usr/bin/env python3
"""The store's first GIFs, drawn here: seamless loops (the last frame leads
back to the first). Cross ones keep every lit color at 90+ of 255: the cross
runs at 4 bits a color, under 77 is black.

    python3 tools/make_seed_gifs.py   # writes gif/*.gif
"""
import colorsys
from pathlib import Path

import numpy as np
from PIL import Image

OUT = Path(__file__).resolve().parent.parent / "gif"
TAU = 2 * np.pi


def hsv(h, s, v):
    """Arrays of hue (turns), saturation, value (0..1) -> uint8 RGB."""
    h = np.mod(h, 1.0)
    i = np.floor(h * 6).astype(int) % 6
    f = h * 6 - np.floor(h * 6)
    p, q, t = v * (1 - s), v * (1 - s * f), v * (1 - s * (1 - f))
    r = np.choose(i, [v, q, p, p, t, v])
    g = np.choose(i, [t, v, v, q, p, p])
    b = np.choose(i, [p, p, t, v, v, q])
    return (np.stack([r, g, b], -1) * 255).clip(0, 255).astype(np.uint8)


def save(name, frames, ms):
    imgs = [Image.fromarray(f, "RGB").quantize(256, dither=Image.Dither.NONE) for f in frames]
    imgs[0].save(OUT / name, save_all=True, append_images=imgs[1:], duration=ms, loop=0, disposal=1)
    print(name, (OUT / name).stat().st_size, "bytes", len(frames), "frames")


def plasma(w=64, h=32, n=40):
    y, x = np.mgrid[0:h, 0:w].astype(float)
    frames = []
    for k in range(n):
        t = TAU * k / n  # every term turns a whole number of times: a loop
        v = (np.sin(x / 7 + t) + np.sin(y / 5 - 2 * t) + np.sin((x + y) / 9 + t)
             + np.sin(np.hypot(x - w / 2, y - h / 2) / 4 - 3 * t)) / 4
        frames.append(hsv(v * 0.6 + k / n, 1.0, 0.75 + 0.25 * np.cos(v * 4)))
    save("plasma_64x32.gif", frames, 40)


def tunnel(w=64, h=32, n=48):
    y, x = np.mgrid[0:h, 0:w].astype(float)
    dx, dy = x - w / 2 + 0.5, (y - h / 2 + 0.5) * 1.6
    d = np.hypot(dx, dy) + 0.5
    a = np.arctan2(dy, dx) / TAU  # turns
    depth = 24 / d
    frames = []
    for k in range(n):
        f = k / n
        u = depth + f  # one ring period per loop
        stripes = (np.floor(u * 4) + np.floor((a + f / 4) * 8)) % 2
        light = np.clip(d / 18, 0.25, 1.0) * (0.55 + 0.45 * stripes)
        frames.append(hsv(u / 2 + a, 1.0, light))
    save("tunnel_64x32.gif", frames, 40)


def cross_mask(s=96):
    y, x = np.mgrid[0:s, 0:s]
    third = s // 3
    return ((x >= third) & (x < 2 * third)) | ((y >= third) & (y < 2 * third))


def cross_rings(s=96, n=48):
    y, x = np.mgrid[0:s, 0:s].astype(float)
    dx, dy = np.abs(x - s / 2 + 0.5), np.abs(y - s / 2 + 0.5)
    lo, hi = np.minimum(dx, dy), np.maximum(dx, dy)
    plus = np.maximum(hi, 3 * lo)  # plus-shaped distance: 48 = the cross's edge
    frames = []
    for k in range(n):
        f = k / n
        u = np.log(plus + 1) * 3 - f  # rings on a log scale: an endless zoom out
        band = np.floor(u * 2) % 2
        rgb = hsv(np.floor(u * 2) / 7 + f, 1.0, 0.35 + 0.65 * band)  # 90+ of 255
        rgb[~cross_mask(s)] = 0
        frames.append(rgb)
    save("cross_rings_96x96.gif", frames, 40)


def cross_pulse(s=96, n=40):
    """The pharmacy cross beating like a heart, green to white, sparks out."""
    y, x = np.mgrid[0:s, 0:s].astype(float)
    dx, dy = np.abs(x - s / 2 + 0.5), np.abs(y - s / 2 + 0.5)
    plus = np.maximum(np.maximum(dx, dy), 3 * np.minimum(dx, dy))
    frames = []
    for k in range(n):
        f = k / n
        beat = np.exp(-((f % 0.5) * 14))  # two beats a loop
        wave = np.cos((plus / 48 - f * 2) * TAU * 2) * 0.5 + 0.5
        v = 0.35 + 0.65 * np.clip(wave * 0.6 + beat * (plus < 12 + 30 * beat), 0, 1)
        sat = 1 - 0.8 * beat * (plus < 20)
        rgb = hsv(np.full_like(v, 0.36), sat, v)
        rgb[~cross_mask(s)] = 0
        frames.append(rgb)
    save("cross_pulse_96x96.gif", frames, 40)


if __name__ == "__main__":
    OUT.mkdir(exist_ok=True)
    plasma()
    tunnel()
    cross_rings()
    cross_pulse()
