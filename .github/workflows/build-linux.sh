#!/usr/bin/env bash
# Baut Caprice32 + WinApe-Erweiterungen (PDF-Drucker, Einstellungsfenster, Zeichenmodus, M4, Drucker-Sound).
# Aufruf:  scripts/build.sh            -> out/cap32-winape-linux-x86_64.tar.gz
# Optional: CAP32_REPO=<url oder Pfad>  (Standard: github.com/ColinPitrat/caprice32)
set -euo pipefail

HERE="$(cd "$(dirname "$0")/.." && pwd)"
REPO="${CAP32_REPO:-https://github.com/ColinPitrat/caprice32.git}"
COMMIT="$(tr -d '[:space:]' < "$HERE/UPSTREAM_COMMIT")"
WORK="$HERE/build"
OUT="$HERE/out"
VERSION="${VERSION:-$(grep -ho '^+#define VERSION_STRING "[^"]*"' "$HERE"/patches/*.patch | sed 's/.*"\(.*\)"/\1/' | head -n1)}"
VERSION="${VERSION:-$(date +%Y%m%d)}"
ARCH="$(uname -m)"
NAME="cap32-winape-${VERSION}-linux-${ARCH}"

rm -rf "$WORK" "$OUT"
mkdir -p "$OUT"

echo "==> Caprice32 holen ($COMMIT)"
git clone --quiet "$REPO" "$WORK"
git -C "$WORK" checkout --quiet "$COMMIT"

echo "==> Patches anwenden"
for p in "$HERE"/patches/*.patch; do
  git -C "$WORK" apply --check "$p"
  git -C "$WORK" apply "$p"
done

echo "==> Kompilieren"
make -C "$WORK" -j"$(nproc)" WITHOUT_GL=1 cap32

echo "==> Paket $NAME"
PKG="$OUT/$NAME"
mkdir -p "$PKG"
cp "$WORK/cap32" "$PKG/cap32.bin"
cp -r "$WORK/resources" "$WORK/rom" "$WORK/licenses" "$PKG/"
cp "$WORK/cap32.cfg" "$WORK/cap32.cfg.tmpl" "$WORK/COPYING.txt" "$WORK/README.md" "$PKG/"
mkdir -p "$PKG/doc" && cp "$HERE"/doc/*.md "$PKG/doc/"
install -m 755 "$HERE/scripts/cap32.sh" "$PKG/cap32"
tar -C "$OUT" -czf "$OUT/$NAME.tar.gz" "$NAME"
( cd "$OUT" && sha256sum "$NAME.tar.gz" > "$NAME.tar.gz.sha256" )
echo "Fertig: $OUT/$NAME.tar.gz"
