#!/usr/bin/env python3
"""items.json (written by hand) -> catalog.json (what the app reads).

Adds each file's size and CRC-32 (the app can tell what is installed and
current), and a GIF's size and frame count. Fails on anything wrong: a
missing file, a file not listed, a bad field, a Lua script too big for the
matrix's 30 KB.

    python3 tools/build_catalog.py           # writes catalog.json
    python3 tools/build_catalog.py --check   # CI: fails if catalog.json is stale
"""
import json
import re
import sys
import zlib
from datetime import datetime, timezone
from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parent.parent
KINDS = {".lua": "lua", ".gif": "gif"}
LAYOUTS = {"cross"}  # a layout an item needs; none: any board
LUA_MAX = 4096  # bytes: bigger scripts tend to run out of memory compiling (30 KB in all)
GIF_MAX = 300_000
# needs: what a script uses beyond the panel, found in its code
NEEDS = {
    "mic": r"\bget(FFT|Wave)\s*\(",  # the microphone
    "time": r"\bgetTime\s*\(",  # the time of day (from the app or NTP)
}


def fail(msg):
    sys.exit(f"build_catalog: {msg}")


def build():
    items = json.loads((ROOT / "items.json").read_text())
    out, seen = [], set()
    for it in items:
        f = it.get("file", "")
        path = ROOT / f
        kind = KINDS.get(path.suffix)
        if not kind or not f.startswith(kind + "/"):
            fail(f"{f!r}: files go in lua/*.lua or gif/*.gif")
        if not path.is_file():
            fail(f"{f}: no such file")
        if f in seen:
            fail(f"{f}: listed twice")
        seen.add(f)
        for key in ("name", "author", "description"):
            if not isinstance(it.get(key), str) or not it[key].strip():
                fail(f"{f}: needs a {key}")
        if it.get("layout") not in (None, *LAYOUTS):
            fail(f"{f}: layout is one of {sorted(LAYOUTS)} or none")
        data = path.read_bytes()
        entry = {
            "id": path.stem,
            "kind": kind,
            "file": f,
            "name": it["name"].strip(),
            "author": it["author"].strip(),
            "description": it["description"].strip(),
            "tags": sorted({t.strip().lower() for t in it.get("tags", []) if t.strip()}),
            "size": len(data),
            "crc32": zlib.crc32(data),
        }
        if it.get("layout"):
            entry["layout"] = it["layout"]
        if kind == "lua":
            if len(data) > LUA_MAX:
                fail(f"{f}: {len(data)} B, keep Lua scripts under {LUA_MAX} B (30 KB to compile and run)")
            # what it prints: plain ASCII (the matrix's font); comments can be anything
            code = "\n".join(line.split("--", 1)[0] for line in data.decode("utf-8", "replace").splitlines())
            if any(ord(c) > 126 for c in code):
                fail(f"{f}: non-ASCII outside comments (the matrix's font is plain ASCII)")
            # what it uses beyond the panel (the app shows a badge): found in the code
            needs = [n for n, pat in NEEDS.items() if re.search(pat, code)]
            if needs:
                entry["needs"] = needs
        else:
            if len(data) > GIF_MAX:
                fail(f"{f}: {len(data)} B, keep GIFs under {GIF_MAX} B")
            with Image.open(path) as img:
                entry["width"], entry["height"] = img.size
                entry["frames"] = getattr(img, "n_frames", 1)
        out.append(entry)
    for kind in KINDS.values():
        for path in sorted((ROOT / kind).glob("*")):
            if f"{kind}/{path.name}" not in seen:
                fail(f"{kind}/{path.name}: not listed in items.json")
    ids = [e["id"] for e in out]
    if len(set(ids)) != len(ids):
        fail("two files with the same name (lua/x.lua and gif/x.gif): they'd collide on the matrix")
    return out


def main():
    items = build()
    target = ROOT / "catalog.json"
    old = json.loads(target.read_text()) if target.exists() else None
    if old and old.get("items") == items:
        updated = old["updated"]  # nothing changed: same file, same date
    else:
        updated = datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")
    text = json.dumps({"version": 1, "updated": updated, "items": items}, indent=1) + "\n"
    if "--check" in sys.argv:
        if not target.exists() or target.read_text() != text:
            fail("catalog.json is stale: run python3 tools/build_catalog.py")
        print(f"catalog.json ok, {len(items)} items")
        return
    target.write_text(text)
    print(f"catalog.json: {len(items)} items")


if __name__ == "__main__":
    main()
