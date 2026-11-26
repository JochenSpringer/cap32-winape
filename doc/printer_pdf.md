# PDF-Druckeremulation (Caprice32)

Der CPC-Druckerport kann statt in eine Rohdatei direkt in **PDF-Dateien** ausgegeben werden. Die Seiten werden von der Druckerengine „pe“ gerechnet, die auch in der WinApe-Erweiterung und im Hatari-Projekt läuft: Text in der Druckerschrift (NEC P6: Prestige, Letter Quality, 24 Nadeln), Grafikdaten Punkt für Punkt als Vektoren.

## Einschalten (`cap32.cfg`)

```
[system]
printer=1                 # Drucker angeschlossen (auch Haken "Capture printer output" in den Optionen)
printer_pdf=1             # statt printer.dat PDF-Dateien erzeugen
printer_pdf_model=p6      # p6, eplq, lq800, fx80, kxp2023, lc24, nlq401, nlq401d
printer_pdf_paper=a4      # a4 | fanfold (Endlos mit Lochrand) | green (Endlos grün-weiß)
printer_pdf_idle=5        # Sekunden ohne Daten, danach endet ein Druckauftrag (2..3600)
[file]
printer_pdf_dir=./printer # Ausgabeordner, Datei je Auftrag: CPC_JJJJMMTT_HHMMSS.pdf
```

Ein Druckauftrag = eine PDF-Datei. Er endet nach `printer_pdf_idle` Sekunden ohne Daten, beim Abschalten des Druckers in den Optionen und beim Beenden des Emulators. Die Datei ist nach jeder Seite ein gültiges PDF.

## Technik

* `src/printer_pdf.{h,cpp}`: Verbindung Druckerport → Engine. Das Datenbyte (Bit 0–6) wird wie bei WinAPE mit der **steigenden Flanke von Bit 7** (Strobe) übernommen; mehrfaches `OUT` mit gesetztem Strobe ergibt nur ein Zeichen.
* `src/pe/`: Druckerengine (reines C, unverändert aus dem Hatari-/WinApe-Projekt), vom `makefile` mitgebaut (zlib wird bereits benutzt).
* `cap32.cpp`: Port-Ausgabe, `printer_start()`/`printer_stop()`, Konfiguration.

## Noch nicht enthalten

Druckgeräusch, 8-Bit-Druckerumbau, Auswahl im Optionsmenü (derzeit nur über `cap32.cfg`).

## Drucker-Geräusch und 8-Bit-Umbau
- **Geräusch** (Einstellungen > Sound > Other Sounds > Printer, `printer_sound=1`): Nadelgeräusch (dieselbe Aufnahme wie bei Hatari/WinApe) als Schleife ab dem ersten gedruckten Zeichen, bis 1,5 s nach dem letzten. Eigenes Audiogerät, unabhängig vom CPC-Ton. Wirkt bei PDF- und Datei-Ausgabe.
- **8-bit (HW mod)** (Einstellungen > Other > Printer, `printer_8bit=1`): Umbau nach „8-Bit-Drucker am CPC 464“ (Happy Computer 7/1986). Das 8. Datenbit kommt von PPI-Port C, Bit 5 und wird an der Strobe-Flanke abgetastet. Damit kommen Zeichen 128–255 und 8-Bit-Grafik an.
