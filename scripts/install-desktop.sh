#!/usr/bin/env sh
# Legt einen Startmenue-Eintrag mit Icon fuer dieses Caprice32-Paket an (Linux, nur fuer den aktuellen Benutzer).
DIR="$(cd "$(dirname "$0")" && pwd)"
APPS="${XDG_DATA_HOME:-$HOME/.local/share}/applications"
mkdir -p "$APPS"
cat > "$APPS/caprice32-winape.desktop" <<DESK
[Desktop Entry]
Type=Application
Name=Caprice32 (WinApe-Erweiterungen)
Comment=Amstrad CPC Emulator
Exec=$DIR/cap32
Path=$DIR
Icon=$DIR/resources/caprice32.png
Terminal=false
Categories=Game;Emulator;
StartupWMClass=cap32.bin
DESK
chmod +x "$APPS/caprice32-winape.desktop"
echo "Eintrag angelegt: $APPS/caprice32-winape.desktop"
