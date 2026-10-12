# PrimeHelp - ThePrimeagen / Lenno Neovim Hotkeys

Hier ist eine vollständige Übersicht aller konfigurierten Hotkeys und der wichtigsten Neovim-Befehle, damit du das Setup meistern kannst!

**Leader Key (`<leader>`) = Leertaste (Space)**

---

## 🚀 Navigation & Editieren (Allgemein)
- `<leader>pv`: Öffnet den Dateimanager (Netrw) im aktuellen Verzeichnis.
- `J` (im Normalmodus): Verbindet die Zeile darunter mit der aktuellen Zeile (Cursor bleibt stehen!).
- `<C-d>` / `<C-u>`: Scrollt eine halbe Seite nach unten (`<C-d>`) oder oben (`<C-u>`) und hält den Cursor dabei in der Mitte des Bildschirms.
- `n` / `N`: Springt zum nächsten (`n`) oder vorherigen (`N`) Suchergebnis und hält den Cursor in der Mitte.
- `<leader>s`: Suchen & Ersetzen für das Wort, auf dem der Cursor gerade steht (im gesamten Dokument).
- `<leader><leader>`: Lädt die aktuelle Datei neu ein (`:so`).

## ✂️ Copy & Paste & Löschen
- `<leader>p` (im visuellen Modus): Fügt Text ein, **ohne** den überschriebenen Text in die Zwischenablage zu packen (greatest remap ever!).
- `<leader>y` (Normal/Visuell): Kopiert den Text in die System-Zwischenablage (`+` Register).
- `<leader>Y` (Normal): Kopiert die ganze Zeile in die System-Zwischenablage.
- `<leader>d` (Normal/Visuell): Löscht Text ins "schwarze Loch"-Register (ohne die Zwischenablage zu verändern).

## 🚚 Textblöcke verschieben
- `J` (im visuellen Modus): Verschiebt den markierten Block eine Zeile nach unten.
- `K` (im visuellen Modus): Verschiebt den markierten Block eine Zeile nach oben.

---

## 🔍 Suchen & Dateien finden (Telescope)
- `<leader>pf`: Sucht nach Dateien im Projekt.
- `<C-p>`: Sucht nach Dateien, die in Git versioniert sind (sehr schnell).
- `<leader>ps`: Öffnet eine Suche im gesamten Projekt ("Grep > ").
- `<leader>pws`: Sucht im Projekt nach dem Wort, auf dem der Cursor gerade steht.
- `<leader>vh`: Sucht in den Hilfe-Tags (Neovim Dokumentation).

---

## ⚓ Harpoon (Schneller Datei-Wechsel)
Harpoon ist perfekt, um zwischen 2-4 Dateien extrem schnell hin- und herzuspringen.
- `<leader>a`: Fügt die aktuelle Datei zu Harpoon hinzu.
- `<C-e>`: Öffnet das Harpoon-Schnellmenü (Quick Menu).
- `<M-1>` bis `<M-4>`: Springt sofort zur Datei 1, 2, 3 oder 4 in Harpoon. *(Hinweis: `<M-1>` bedeutet Alt+1)*.

---

## 🧠 LSP (Autovervollständigung, Fehler & Code-Analyse)
Diese Hotkeys funktionieren automatisch, sobald Neovim die Sprache erkannt hat (LSP aktiv).
- `K`: Zeigt Dokumentation/Hover für das Element unter dem Cursor.
- `gd`: Go to Definition (Springt zur Definition von Variablen/Funktionen).
- `<leader>vrr`: Zeigt alle Referenzen (wo wird diese Funktion überall genutzt?).
- `<leader>vrn`: Variable/Funktion projektweit umbenennen (Rename).
- `<leader>vca`: Öffnet die "Code Actions" (z.B. für Auto-Imports).
- `<leader>vd`: Öffnet die Fehlermeldung unter dem Cursor in einem schwebenden Fenster.
- `[d` / `]d`: Springt zum vorherigen / nächsten Fehler im Code.
- `<C-Space>` (Insert): Öffnet das Autocompletion-Menü manuell.
- `<C-n>` (Insert): Wählt den **nächsten** Vorschlag im Menü aus (nach unten).
- `<C-p>` (Insert): Wählt den **vorherigen** Vorschlag im Menü aus (nach oben).
- `<C-y>` (Insert): Bestätigt den ausgewählten Vorschlag.

---

## 🛠️ Quickfix-Liste & Fehler-Menüs (Trouble)
Die Quickfix-Liste sammelt Suchergebnisse von Telescope, Compiler-Errors oder Linter-Warnungen.
- **` :copen `**: Öffnet die Quickfix-Liste (Standard Neovim Befehl).
- **` :cclose `**: Schließt die Quickfix-Liste.
- `<C-k>` / `<C-j>`: Springt extrem schnell zum nächsten (`<C-k>`) oder vorherigen (`<C-j>`) Fehler/Ergebnis in der Quickfix-Liste!
- `<leader>k` / `<leader>j`: Das Gleiche für die Location-Liste.

**Zusätzlich mit dem "Trouble" Plugin (hübschere Fehler-Liste):**
- `<leader>xq`: Öffnet die Quickfix-Liste in Trouble.
- `<leader>xw`: Öffnet alle Fehler (Diagnostics) im Projekt.
- `<leader>xd`: Öffnet alle Fehler in der aktuellen Datei.

---

## ⏪ Zeitreise (Undotree)
- `<leader>u`: Öffnet Undotree. Zeigt dir den kompletten Änderungsverlauf einer Datei grafisch an. Du kannst beliebig weit in der Zeit zurückspringen, selbst wenn du zwischendurch gespeichert hast.

---

## 🌳 Git (Fugitive)
- `<leader>gs`: Öffnet das Git-Menü. Hier kannst du mit `s` Dateien stagen und mit `cc` einen Commit schreiben.

---

## ⚙️ Sonstige Helfer
- `<leader>x`: Macht die aktuelle Datei ausführbar (führt `chmod +x` aus).
- `<C-c>` (Insert): Funktioniert exakt wie `<Esc>`.
- `<leader>ca`: "Make it rain" Animation (für Pausen).

*Tipp: Schließe dieses Fenster einfach mit `:q`!*
