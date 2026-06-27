#!/usr/bin/env bash
# Symlink the dapper tools into ~/.local/bin (must be on your PATH).
set -e
DIR="$(cd "$(dirname "$0")" && pwd)"
DEST="${1:-$HOME/.local/bin}"
mkdir -p "$DEST"
for s in "$DIR"/bin/*; do
  ln -sf "$s" "$DEST/$(basename "$s")"
  echo "linked $(basename "$s") -> $DEST"
done
echo "Done. Ensure $DEST is on your PATH."
