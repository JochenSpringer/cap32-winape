#!/usr/bin/env bash
# Baut Caprice32 + WinApe-Erweiterungen für Windows (Ausführen in einer MSYS2-Shell: MINGW64 oder MINGW32).
# Aufruf:  bash scripts/build-windows.sh      -> out/cap32-winape-<version>-windows-<x64|x86>.zip
# Voraussetzung (einmalig, in der MSYS2-MINGW64-Shell):
#   pacman -S --needed git make zip diffutils mingw-w64-x86_64-toolchain mingw-w64-x86_64-SDL2 \
#       mingw-w64-x86_64-freetype mingw-w64-x86_64-libpng mingw-w64-x86_64-zlib mingw-w64-x86_64-pkg-config
set -euo pipefail

HERE="$(cd "$(dirname "$0")/.." && pwd)"
REPO="${CAP32_REPO:-https://github.com/ColinPitrat/caprice32.git}"
COMMIT="$(tr -d '[:space:]' < "$HERE/UPSTREAM_COMMIT")"
WORK="$HERE/build"
OUT="$HERE/out"
VERSION="${VERSION:-$(grep -ho '^+#define VERSION_STRING "[^"]*"' "$HERE/patches/0001-winape-erweiterungen.patch" | sed 's/.*"\(.*\)"/\1/' | head -n1 || true)}"
VERSION="${VERSION:-$(date +%Y%m%d)}"

case "${MSYSTEM:-}" in
  MINGW64) ARCH=win64; TAG=x64 ;;
  MINGW32) ARCH=win32; TAG=x86 ;;
  *) echo "Bitte in einer MSYS2-Shell 'MINGW64' (oder 'MINGW32') ausführen, nicht in '${MSYSTEM:-?}'." >&2; exit 1 ;;
esac
NAME="cap32-winape-${VERSION}-windows-${TAG}"

rm -rf "$WORK" "$OUT"
mkdir -p "$OUT"

echo "==> Caprice32 holen ($COMMIT)"
git -c core.autocrlf=false clone --quiet "$REPO" "$WORK"
git -C "$WORK" -c core.autocrlf=false checkout --quiet "$COMMIT"

echo "==> Patches anwenden"
# nur dieses eine Patch (weitere Dateien im Ordner patches/ werden ignoriert)
for p in "$HERE/patches/0001-winape-erweiterungen.patch"; do
  git -C "$WORK" apply --check "$p"
  git -C "$WORK" apply "$p"
done

echo "==> Kompilieren ($ARCH)"
INC="$(cygpath -m "$MINGW_PREFIX")/include"      # zlib.h wird sonst nicht gefunden (pkg-config liefert keine Pfade)
make -C "$WORK" -j"$(nproc)" ARCH="$ARCH" CXX=g++ WINE="" CFLAGS="-I$INC" distrib

echo "==> Paket $NAME"
PKG="$WORK/release/cap32-$ARCH"
# Alle DLLs, die cap32.exe (auch indirekt) braucht, dazulegen - unabhängig davon, wie MSYS2 sie gerade nennt (z. B. libz-1.dll)
ldd "$PKG/cap32.exe" | awk '/=> \/(mingw|ucrt|clang)[0-9]*\/bin\//{print $3}' | while read -r dll; do
  cp -n "$dll" "$PKG/"
done
echo "DLLs im Paket:"; ls "$PKG"/*.dll
mkdir -p "$PKG/doc" && cp "$HERE"/doc/*.md "$PKG/doc/"
cat > "$PKG/START-HIER.txt" <<'TXT'
cap32.exe starten (Doppelklick). F1 = Einstellungen und Befehle (Reiter Commands).
Alles liegt im Programmordner (cap32.cfg, rom\, m4sd\ = M4-"SD-Karte", PDF-Ausgabe).
M4-Board: M4ROM.BIN nach rom\ legen, siehe doc\m4.md.
TXT
rm -rf "$OUT/$NAME" && cp -r "$PKG" "$OUT/$NAME"
( cd "$OUT" && zip -qr "$NAME.zip" "$NAME" && sha256sum "$NAME.zip" > "$NAME.zip.sha256" && rm -rf "$NAME" )
echo "Fertig: $OUT/$NAME.zip"
