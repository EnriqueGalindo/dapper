#!/usr/bin/env bash
# Symlink the dapper tools into ~/.local/bin and vendor music-weekly's one dep.
set -e
DIR="$(cd "$(dirname "$0")" && pwd)"
DEST="${1:-$HOME/.local/bin}"
mkdir -p "$DEST"
for s in "$DIR"/bin/*; do
  ln -sf "$s" "$DEST/$(basename "$s")"
  echo "linked $(basename "$s") -> $DEST"
done

# music-weekly reads audio tags via mutagen (pure-python). Vendor it locally so
# it works without touching system/global site-packages.
if ! PYTHONPATH="$DIR/vendor" python3 -c 'import mutagen' 2>/dev/null; then
  echo "Installing mutagen into vendor/ ..."
  for PY in /usr/bin/python3 python3 python3.12 python3.11; do
    command -v "$PY" >/dev/null 2>&1 || continue
    "$PY" -m pip install -q --target "$DIR/vendor" mutagen 2>/dev/null && break
  done
fi
PYTHONPATH="$DIR/vendor" python3 -c \
  'import mutagen; print("mutagen", mutagen.version_string, "ready")' \
  || echo "WARN: mutagen not installed; only music-weekly needs it."
echo "Done. Ensure $DEST is on your PATH."
