# FAQ: ChurchTools Integration Suite

Häufige Fragen zu Betrieb, Cache, Cron, Rechten und Addons.

## Cache & Datenhaltung

**Wo liegen die synchronisierten Daten?**
In eigenen Tabellen: `{prefix}cts_events`, `{prefix}cts_calendars`, `{prefix}cts_services`, `{prefix}cts_event_services`. Die Ausgabe liest ausschließlich diese lokalen Daten – die ChurchTools-API wird nur beim Sync angefragt.

**Was wird zusätzlich gecacht?**
- Update-/Release-Abfragen als Transients (Addon-Installationsinfos 15 Minuten, Update-Checks bis zum nächsten WP-Update-Lauf).
- Transient `update_plugins` und Plugin-Cache lassen sich über **Addons → Update-Cache leeren** zurücksetzen.

**Die Ausgabe zeigt alte Termine.**
Erst Sync laufen lassen (manuell im Dashboard oder per Cron), dann Browser-/Seiten-Cache leeren. Das Plugin cacht die gerenderte Ausgabe nicht dauerhaft – alte Inhalte kommen fast immer aus WP-Cache-Plugins oder noch nicht gelaufenem Sync.

## WP-Cron

**Welche Cronjobs nutzt das Plugin?**
- `churchtools_suite_auto_sync` – automatischer Sync (Standard: täglich, einstellbar)
- `churchtools_suite_calendar_reconcile` – Abgleich gelöschter/geänderter Termine
- `churchtools_suite_session_keepalive` – hält die ChurchTools-Session aktiv

Die aktuell geplanten Jobs stehen im **Dashboard** (Cron-Übersicht).

**Der Sync läuft nicht automatisch.**
WP-Cron feuert nur bei Seitenaufrufen – bei wenig Traffic oder gecachter Seite bleibt er aus. Lösung: echten System-Cron einrichten, der alle 5–15 Minuten `wp-cron.php` oder `wp cron event run --due-now` aufruft, und `DISABLE_WP_CRON` in `wp-config.php` setzen.

**Verwaiste Cronjobs?**
Im Debug-Tab lassen sich die Plugin-Crons neu planen/bereinigen; ein Reset baut die Zeitpläne neu auf.

## Berechtigungen

| Aktion | Benötigte Capability |
|---|---|
| Sync, Kalender-/Dienst-Auswahl, Presets, Logs | `manage_churchtools_suite` |
| Voll-/Komplett-Reset, DB-Rebuild | `manage_options` |
| Addons installieren | `install_plugins` |
| Addons aktualisieren | `update_plugins` |

`manage_churchtools_suite` kann über die Rollenverwaltung des Plugins vergeben werden (Einstellungen → Benutzer/Rollen).

## Addons & Abhängigkeiten

| Addon | Benötigt |
|---|---|
| Elementor Integration | Suite >= 1.3.0.6, Elementor, WP >= 6.0, PHP >= 8.2 |
| Posts Sync | Suite >= 1.3.0.6, WP >= 5.0, PHP >= 8.2 |
| Presentations | Suite, WP >= 6.0, PHP >= 8.0 |

Addon-ZIPs hängen am Release des Hauptplugins – ein Suite-Release liefert alle Addon-Versionen mit. Updates werden wie WP-Updates im Plugin-Tab und auf der Addons-Seite angeboten.

## Updates & Releases

**Woher kommen Updates?**
Aus den GitHub-Releases von `feg-aschaffenburg/churchtools-suite`. Es werden nur geprüfte Release-ZIPs installiert (keine Branch-Snapshots). Bei API-Problemen/Rate-Limit greift der Fallback `https://plugin.feg-aschaffenburg.de/download/<name>-<version>.zip`.

**GitHub Rate-Limit / Abuse-Meldung beim Update?**
Optional ein GitHub-Token hinterlegen: Option `churchtools_suite_github_token` im Admin oder Konstante `WP_CHURCHTOOLS_SUITE_GITHUB_TOKEN` in `wp-config.php`.

## Sync-Verhalten

**Gelöschte Termine in ChurchTools bleiben in WP sichtbar.**
Nur der Vollsync (bzw. der Reconcile-Job) entfernt Termine, die in ChurchTools nicht mehr existieren. Inkrementelle Syncs prüfen `modified_after` und merken Löschungen nicht zwingend sofort.

**Doppelte Bilder bei Serienterminen?**
Der Bildimport dedupliziert über Quell-ID/Hash – wiederkehrende Termine teilen sich das Bild.

## Fehlersuche

1. **Debug → Logs**: Protokoll pro Kanal (sync, ajax, activator, …), exportierbar.
2. **Dashboard**: Sync-Verlauf und Cron-Status.
3. **Verbindungstest** unter Einstellungen → API.
4. Bekannte Stolpersteine: falscher Kalender-Typ in `calendar_ids` (Namen statt IDs), fehlende Kalenderauswahl, WP-Cache-Plugin hält alte Ausgabe.
