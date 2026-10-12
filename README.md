# Spectre Matrix store

Lua scripts and GIFs for the Spectre Matrix, browsed and installed from the
app's **Store** tab (https://antoine.doussaud.org/matrix/). The web server
follows this repo's `main` branch (`scripts/sync-store.sh`, every 15 min).

## Add something

1. Put the file in `lua/` or `gif/` (a unique name: it keeps it on the matrix).
2. Describe it in `items.json`:
   ```json
   { "file": "lua/my_effect.lua", "name": "My effect", "author": "you",
     "description": "One line.", "tags": ["trippy"], "layout": "cross" }
   ```
   `layout`: only for items made for one panel layout (`cross`: the
   pharmacy cross, 96x96 with no corners). Without it, the item is for any
   board. A GIF fits boards at least as big as it is (the matrix centers it).
3. A GIF: `python3 tools/optimize_gif.py gif/my.gif` makes it smaller
   without changing a pixel (one palette, only the changed part of each
   frame, in a way the matrix plays). Often a lot: 2.9 MB -> 418 KB.
4. `python3 tools/build_catalog.py` (needs Pillow and numpy): checks
   everything and writes `catalog.json`. Commit both, or open a pull request.

Check scripts on a real matrix first: Lua has 30 KB there, compiling
included (keep scripts under 4 KB), and the cross shows 4 bits a color
(values under 77 of 255 are black). The app's Lua API: `src/lua/README.md`
in [spectre-matrix-app](https://github.com/spectrenoir06/spectre-matrix-app).

## Files

- `items.json`: the list, by hand
- `catalog.json`: generated (sizes, CRC-32, GIF sizes), what the app reads
- `tools/build_catalog.py`: items.json -> catalog.json, with checks
- `tools/optimize_gif.py`: lossless GIF shrinking, checked frame by frame
- `tools/make_seed_gifs.py`: how the first GIFs were drawn
- `scripts/sync-store.sh`: the server's cron job
