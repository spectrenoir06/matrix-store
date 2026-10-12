#!/usr/bin/env bash
# The app's Store reads /matrix/store/: keep it on this repo's main branch.
# Runs from cron on the web server (every 15 min, like the firmware sync);
# does nothing until main has a new commit.
#
#   sync-store.sh [dest]                # main on GitHub
#   STORE_DIR=path sync-store.sh        # a local checkout instead (testing)
set -euo pipefail

REPO=spectrenoir06/spectre-matrix-store
DEST=${1:-/home/docker_data/static-web-server/matrix/store}

if [[ -n ${STORE_DIR:-} ]]; then
  commit=local-$(date +%s)
else
  commit=$(curl -fsL -H "Accept: application/vnd.github.sha" "https://api.github.com/repos/$REPO/commits/main") || exit 0
  [[ $commit == "$(cat "$DEST/.commit" 2>/dev/null || true)" ]] && exit 0
fi

# unpacked next to the old one, checked, then swapped in at once
tmp=$(mktemp -d "$(dirname "$DEST")/.store.XXXXXX")
trap 'rm -rf "$tmp" "$tmp.src"' EXIT
mkdir "$tmp.src"
if [[ -n ${STORE_DIR:-} ]]; then
  cp -r "$STORE_DIR"/. "$tmp.src"
else
  curl -fsSL "https://codeload.github.com/$REPO/tar.gz/$commit" | tar -xz -C "$tmp.src" --strip-components=1
fi
# only what the app reads: the catalog and the files it lists
python3 - "$tmp.src" "$tmp" <<'EOF'
import json, shutil, sys, zlib
from pathlib import Path
src, dst = Path(sys.argv[1]), Path(sys.argv[2])
cat = json.loads((src / "catalog.json").read_text())
for it in cat["items"]:
    f = src / it["file"]
    if zlib.crc32(f.read_bytes()) != it["crc32"]:
        sys.exit(f"{it['file']}: not what catalog.json says (run tools/build_catalog.py)")
    (dst / it["file"]).parent.mkdir(parents=True, exist_ok=True)
    shutil.copy2(f, dst / it["file"])
shutil.copy2(src / "catalog.json", dst / "catalog.json")
EOF
echo "$commit" >"$tmp/.commit"
chmod -R a+rX "$tmp"

if [[ -e $DEST ]]; then mv "$DEST" "$tmp.old"; fi
mv "$tmp" "$DEST"
rm -rf "$tmp.old"
echo "$(date '+%F %T') store $commit -> $DEST"
