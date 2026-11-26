# Zeichenmodus (PC-Tastatur schreibt Zeichen)

Einschalten: Einstellungen > Input > "Character mode" (oder `char_mode=1` in `[input]` der cap32.cfg).

Statt Taste-für-Taste zu übersetzen, wird das Zeichen getippt, das die PC-Taste erzeugt (mit Shift, AltGr usw.).
Der Emulator sucht dazu in den **aktuellen Tastentabellen des CPC** (normal / Shift / Control, im RAM der Firmware)
die Tastenkombination, die dieses Zeichen liefert, und drückt sie. Dadurch gelten auch KEY DEF und die
Tabellen deutscher Software (z. B. Context). PC-Tasten ohne CPC-Gegenstück bleiben unbelegt.

Nicht betroffen (laufen weiter als normale Tasten): Cursor, Funktionstasten, Enter, Backspace, Tab, Esc,
Leertaste, Ziffernblock, sowie alles mit Strg / linkem Alt.

## Umlaute (`char_umlauts=1`)
| PC | CPC-Zeichen | PC | CPC-Zeichen |
|----|-------------|----|-------------|
| ä  | `{`         | Ä  | `[`         |
| ö  | `|`         | Ö  | `\`         |
| ü  | `}`         | Ü  | `]`         |
| ß  | `~`         |    |             |

`~` ist in den Standardtabellen nur über Strg + Taste erreichbar. Für ß am CPC eine freie Taste belegen,
z. B. `KEY DEF 78,0,126` (Matrixposition 78 ist unbelegt); Umlaut-Tabellen deutscher Software erledigen das teilweise selbst.

## Grenzen
- Die Tabellen werden im RAM an der Standardstelle der Firmware gesucht (Ähnlichkeitsvergleich mit der ROM-Tabelle).
  Software, die die Tabellen an eine andere Stelle verlegt, wird nicht erkannt – dann passiert beim Tippen nichts.
- Nur ASCII und die oben genannten Umlaute; keine weiteren Sonderzeichen.
