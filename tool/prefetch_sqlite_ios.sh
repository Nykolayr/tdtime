#!/usr/bin/env bash
# Скачивает libsqlite3 для iOS в tool/ (hooks: test-sqlite3, directory: tool/).
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEST_DIR="$SCRIPT_DIR"
TAG="sqlite3-3.2.0"
BASE_URL="https://github.com/simolus3/sqlite3.dart/releases/download/${TAG}"

assets=(
  "libsqlite3.arm64.ios.dylib"
  "libsqlite3.arm64.ios_sim.dylib"
  "libsqlite3.x64.ios_sim.dylib"
)

mkdir -p "$DEST_DIR"

for name in "${assets[@]}"; do
  dest="$DEST_DIR/$name"
  tmp="$(mktemp)"
  echo "Downloading $name ..."
  curl -L --connect-timeout 60 --max-time 600 -o "$tmp" "$BASE_URL/$name"
  size=$(stat -f%z "$tmp" 2>/dev/null || stat -c%s "$tmp")
  if [ "$size" -lt 1000 ]; then
    echo "Download failed or empty: $name ($size bytes)" >&2
    exit 1
  fi
  mv "$tmp" "$dest"
  echo "Saved -> $dest ($size bytes)"
done

echo "Done. Prebuilt libs: $DEST_DIR"
