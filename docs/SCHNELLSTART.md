# Schnellstart: ChurchTools Integration Suite

Ziel: In wenigen Minuten von der Installation bis zur ersten Event-Ausgabe im Frontend.

## Voraussetzungen

- WordPress >= 6.0, PHP >= 8.2
- ChurchTools-Instanz mit lesendem API-Zugang (Benutzername/Passwort oder Login-Token)
- Plugin `churchtools-suite` installiert und aktiviert

## 1. Verbindung einrichten

1. **ChurchTools Suite → Einstellungen → API** öffnen.
2. **ChurchTools-URL** eintragen, z. B. `https://gemeinde.church.tools`.
3. Authentifizierung wählen:
   - **Benutzername + Passwort**: ChurchTools-Benutzer mit Leserechten auf Kalender, Gruppen und Dienste.
   - **Login-Token**: Alternativ ein Token aus den ChurchTools-Benutzereinstellungen hinterlegen.
4. Speichern und **Verbindung testen** – die Statusmeldung muss grün sein, bevor es weitergeht.

## 2. Kalender synchronisieren

1. **ChurchTools Suite → Kalender** öffnen.
2. **Kalender synchronisieren** klicken – die verfügbaren ChurchTools-Kalender werden geladen.
3. Gewünschte Kalender **auswählen** und Auswahl speichern.
4. Ersten Sync starten (Dashboard oder Sync-Tab). Danach liegen Termine, Dienste und Bilder lokal vor.

## 3. Erste Ausgabe im Frontend

Einen Shortcode in eine Seite oder einen Beitrag setzen:

```
[cts_list]
```

Zeigt die kommenden Termine als Liste an – fertig.

### Kalender filtern mit `calendar_ids`

Nur bestimmte Kalender anzeigen:

```
[cts_list calendar_ids="1,2,3"]
```

- Gültig: `calendar_ids="1,2,3"` – kommagetrennte IDs aus **ChurchTools Suite → Kalender**.
- Ungültig: `calendar_ids="Gottesdienst"` – Namen funktionieren nicht, nur numerische IDs.
- Leer (`calendar_ids=""` oder weggelassen) = alle synchronisierten Kalender.

> Die IDs stehen in der Kalender-Übersicht des Plugins – nicht mit den ChurchTools-internen Kalender-IDs verwechseln.

## Shortcode-Übersicht

| Shortcode | Ausgabe |
|---|---|
| `[churchtools_events]` | Generischer Event-Shortcode (alle Views über `view="…"`) |
| `[cts_list]` | Terminliste |
| `[cts_grid]` | Termin-Raster |
| `[cts_calendar]` | Monatskalender |
| `[cts_carousel]` | Carousel |
| `[cts_countdown]` | Countdown zum nächsten Termin |
| `[cts_event]` | Einzeltermin |

Alle Shortcodes akzeptieren u. a. `calendar_ids`, Filter- und Limit-Parameter sowie `custom_css` (über Presets verwaltbar). Der Gutenberg-Block **ChurchTools Events** bildet dieselben Optionen ab.

## Addons (optional)

Über **ChurchTools Suite → Addons** installierbar und aktualisierbar:

- **Elementor Integration** (erfordert Elementor + Suite >= 1.3.0.6)
- **Posts Sync** (ChurchTools-Berichte als WP-Beiträge)
- **Presentations** (lokale Präsentations-Seiten)

Updates kommen aus den GitHub-Releases (`feg-aschaffenburg`), Fallback: `plugin.feg-aschaffenburg.de/download`.

## Wenn nichts angezeigt wird

1. Verbindungstest in den Einstellungen wiederholen.
2. Prüfen, ob mindestens ein Kalender ausgewählt und synchronisiert ist (**Kalender**-Tab zeigt Termin-Anzahl).
3. **Debug → Logs** auf Fehler prüfen.
4. Details: siehe [FAQ.md](FAQ.md).
