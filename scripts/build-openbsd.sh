#!/bin/sh
# Baut Caprice32 + WinApe-Erweiterungen auf OpenBSD (wie das Original unter Unix: GNU make + SDL2).
# Einmalig als root:  pkg_add git gmake sdl2 freetype libpng
# Aufruf (im Repo-Ordner):  sh scripts/build-openbsd.sh   -> out/cap32-winape-<version>-openbsd-<arch>/
set -eu

HERE="$(cd "$(dirname "$0")/.." && pwd)"
REPO="${CAP32_REPO:-https://github.com/ColinPitrat/caprice32.git}"
COMMIT="$(tr -d '[:space:]' < "$HERE/UPSTREAM_COMMIT")"
WORK="$HERE/build"
OUT="$HERE/out"
VERSION="$(sed -n 's/^+#define VERSION_STRING "\(.*\)"/\1/p' "$HERE/patches/0001-winape-erweiterungen.patch" | head -n1)"
VERSION="${VERSION:-$(date +%Y%m%d)}"
NAME="cap32-winape-${VERSION}-openbsd-$(uname -m)"
JOBS="$(sysctl -n hw.ncpuonline 2>/dev/null || echo 2)"

for t in git gmake sdl2-config pkg-config; do
  command -v "$t" >/dev/null 2>&1 || { echo "Fehlt: $t  (pkg_add git gmake sdl2 freetype libpng)" >&2; exit 1; }
done

rm -rf "$WORK" "$OUT"
mkdir -p "$OUT"

echo "==> Caprice32 holen ($COMMIT)"
git clone --quiet "$REPO" "$WORK"
git -C "$WORK" checkout --quiet "$COMMIT"

echo "==> Patch anwenden"
git -C "$WORK" apply --check "$HERE/patches/0001-winape-erweiterungen.patch"
git -C "$WORK" apply "$HERE/patches/0001-winape-erweiterungen.patch"

echo "==> Kompilieren"
export PKG_CONFIG_PATH="/usr/local/lib/pkgconfig:/usr/X11R6/lib/pkgconfig:${PKG_CONFIG_PATH:-}"
gmake -C "$WORK" -j"$JOBS" WITHOUT_GL=1 CXX=c++ CC=cc \
  CFLAGS="-I/usr/local/include -I/usr/X11R6/include" \
  LDFLAGS="-L/usr/local/lib -L/usr/X11R6/lib" cap32

echo "==> Paket $NAME"
PKG="$OUT/$NAME"
mkdir -p "$PKG/doc"
cp "$WORK/cap32" "$PKG/cap32.bin"
cp -R "$WORK/resources" "$WORK/rom" "$WORK/licenses" "$PKG/"
cp "$WORK/cap32.cfg" "$WORK/cap32.cfg.tmpl" "$WORK/COPYING.txt" "$WORK/README.md" "$PKG/"
cp "$HERE"/doc/*.md "$PKG/doc/"
cp "$HERE/scripts/cap32.sh" "$PKG/cap32" && chmod 755 "$PKG/cap32"
echo "Fertig: $PKG   (starten: $PKG/cap32)"
