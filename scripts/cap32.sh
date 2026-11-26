#!/usr/bin/env sh
# Startet Caprice32 aus seinem eigenen Ordner (dort liegen cap32.cfg, resources/, rom/, m4sd/ und die PDF-Ausgabe).
cd "$(dirname "$(readlink -f "$0")")" || exit 1
exec ./cap32.bin "$@"
