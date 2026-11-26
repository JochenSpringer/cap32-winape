# Caprice32 mit WinApe-Erweiterungen (Linux)

Caprice32 (nativer CPC-Emulator für Linux) plus die Erweiterungen aus dem WinApe-Projekt:

- PDF-Drucker-Emulation (Druckerengine „pe“, mehrere Druckermodelle, Papierarten)
- Einstellungsfenster im WinApe-Stil (Seiten General, Display, Sound, Memory, Input, Other)
- Zeichenmodus der PC-Tastatur mit Umlauten (ä ö ü ß)
- M4-Board (SD-Ordner, Netz, HTTP)
- Drucker-Geräusch und 8-Bit-Druckerumbau

Dieses Repository enthält **keinen** Caprice32-Quelltext, sondern nur den Patch (`patches/`), den festgelegten
Originalstand (`UPSTREAM_COMMIT`) und die Build-Automatik. GitHub Actions holt Caprice32, wendet den Patch an,
baut und legt das fertige Paket zum Download bereit.

Beschreibung der Funktionen: `doc/`.

## Schritt für Schritt: Repository anlegen

1. **Auf GitHub:** oben rechts *+* › *New repository*. Name z. B. `cap32-winape`, *Private* oder *Public*,
   **ohne** README/.gitignore/Lizenz anlegen (leeres Repository). *Create repository*.
2. **Auf deinem Rechner** (Linux/WSL/macOS, `git` installiert; einmalig `git config --global user.name "Dein Name"` und `user.email`):
   ```bash
   unzip cap32-winape-repo.zip      # ergibt den Ordner cap32-winape
   cd cap32-winape
   git init -b main
   git add .
   git commit -m "Caprice32 + WinApe-Erweiterungen"
   git remote add origin https://github.com/<DEIN-NAME>/cap32-winape.git
   git push -u origin main
   ```
   (Beim Push fragt GitHub nach Benutzername und einem *Personal Access Token* als Passwort:
   github.com › Settings › Developer settings › Personal access tokens › *Generate new token*, Recht `repo` bzw. `contents: write`.)
3. **Build beobachten:** Im Repository auf den Reiter *Actions*. Der Lauf „Linux-Build“ startet automatisch
   (ca. 3–5 Minuten, je einmal für Ubuntu 22.04 und 24.04).
4. **Paket holen:** Lauf anklicken › unten bei *Artifacts* `cap32-winape-linux-ubuntu-22.04` herunterladen
   (ZIP mit der `.tar.gz` und der Prüfsumme).
5. **Fertige Version als Release (dauerhafter Download-Link):**
   ```bash
   git tag v1.0
   git push origin v1.0
   ```
   Der Build legt danach unter *Releases* die Datei `cap32-winape-v1.0-linux-x86_64.tar.gz` an.
   Neue Version = neuer Tag (`v1.1` …). Wenn der Release-Job „Resource not accessible“ meldet:
   *Settings › Actions › General › Workflow permissions › Read and write permissions*.

## Installieren und starten (Linux)

```bash
sudo apt install libsdl2-2.0-0 libfreetype6 libpng16-16 zlib1g     # einmalig (Debian/Ubuntu/Mint)
tar xzf cap32-winape-*-linux-x86_64.tar.gz
cd cap32-winape-*/
./cap32                       # Menü: F1; Einstellungen: Menü › Options
```

Alles liegt im Programmordner: `cap32.cfg`, `rom/`, `m4sd/` (M4-„SD-Karte“), PDF-Ausgabe.
Der Ordner lässt sich verschieben. Für M4: `M4ROM.BIN` nach `rom/` legen (siehe `doc/m4.md`).
CPC-ROMs liegen für Caprice bei; Original-Firmware-Dateien (z. B. OS6128.ROM) lassen sich dort austauschen.

## Lokal bauen (ohne GitHub)

```bash
sudo apt install build-essential git pkg-config libsdl2-dev libfreetype6-dev zlib1g-dev libpng-dev
bash scripts/build.sh         # Ergebnis: out/cap32-winape-<datum>-linux-<arch>.tar.gz
```

## Auf neuen Caprice32-Stand umstellen

In `UPSTREAM_COMMIT` einen anderen Commit von https://github.com/ColinPitrat/caprice32 eintragen. Schlägt der Build bei
„Patches anwenden“ fehl, hat sich Quelltext geändert, den der Patch berührt; dann den Patch gegen den neuen Stand neu erzeugen
(`git diff` im geklonten Caprice32-Ordner nach manueller Anpassung, Datei in `patches/` ersetzen).

## Fehlersuche

| Meldung | Ursache / Lösung |
|---|---|
| `git apply --check` schlägt fehl | Patch passt nicht zum Commit in `UPSTREAM_COMMIT` (siehe oben) |
| `Package sdl2 was not found` | `libsdl2-dev` fehlt (nur lokaler Build) |
| Start: `error while loading shared libraries: libSDL2…` | Laufzeitpakete aus „Installieren“ nachinstallieren |
| Kein Ton / kein Druckergeräusch | `SDL_AUDIODRIVER=pulseaudio ./cap32` bzw. `pipewire` versuchen |
| Release-Job schlägt fehl | Workflow-Berechtigungen auf *Read and write* stellen |
