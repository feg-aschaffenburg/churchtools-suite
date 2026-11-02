# ChurchTools Integration Suite – Entwicklungsplan

Stand: 01.11.2026. Basis Repo-Code (feg-aschaffenburg/churchtools-suite).

## Funktionen des Hauptplugins (Ist-Stand)

- **Sync:** Kalender, Termine, Dienste, Gruppen, Gruppenposts. Automatischer Sync über WP-Cron (`churchtools_suite_auto_sync`, `..._calendar_reconcile`, `..._session_keepalive`).
- **Shortcodes:** `churchtools_events`, `cts_list`, `cts_grid`, `cts_calendar`, `cts_carousel`, `cts_countdown`, `cts_event`.
- **Gutenberg:** Block `churchtools-suite/events`.
- **Admin:** Dashboard, Logs, Sync-Verlauf, Presets, Custom CSS pro Shortcode/Preset, Rollen.
- **Bilder:** Import und Deduplizierung bei wiederkehrenden Terminen.
- **Updates:** GitHub-Auto-Updater, lädt nur geprüfte Release-ZIPs; Addon-Installation und -Update über AJAX.
- **Reset/Wartung:** Reset, Rebuild, Cron-Bereinigung, Log-Export.
- **Elementor:** Integrationsordner `includes/elementor`.

## 0. Aufräumen

Erledigt (Branch `devin/aufraeumen`, PR gegen main):
- `templates/views/event-countdown/classic.php.backup` gelöscht.
- `admin/views/tab-debug.php` gelöscht (nicht eingebunden). Aktive Oberfläche ist `admin/views/debug/` (4 Subtabs).
- `scripts/create-wp-zip.ps1` und `scripts/auto-create-releases.ps1` gelöscht.
- Elementor-Repo: 2 Backup-Dateien `class-cts-elementor-events-widget.php.backup-*` gelöscht.

Geprüft / erledigt (02.11.2026):
- `includes/view-feature-matrix.php`, `class-churchtools-suite-calendar-image-templates.php`, `class-churchtools-suite-cron-display.php`: alle drei aktiv eingebunden (Blocks, Elementor-Widget, tab-calendars.php, tab-dashboard.php, tab-debug-minimal.php). Kein Löschkandidat.
- `deploy-scp.ps1`: dokumentiertes Deploy-Skript zum Testsystem (SSH-Alias `plugin-test`, siehe README). Behalten. `wp-env-setup.ps1`: Setup-/Diagnose-Helfer zu den `env:*`-Scripts. Behalten.
- ROADMAP `Z:\dev`-Pfade → auf `C:\laragon\www\dev-churchtools-suite\...` aktualisiert; Produktion auf `\\NB_KAI_NAUMANN\SharedDrive\feg\...` (UNC). Persönlicher PHP-Pfad in README entfernt.
- CI: `.github/workflows/php-lint.yml` angelegt (`php -l` über alle PHP-Dateien, PHP 8.2). Lokal verifiziert: 101 Dateien fehlerfrei.
- Nonce- und Rechteprüfung der `wp_ajax_*`-Handler verifiziert: alle 38 Handler prüfen Nonce (vor jeder Aktion); Capability-Checks überall vorhanden außer den 3 `nopriv`-Handlern (`get_event_details`, `get_modal_template`, `load_calendar_month` – öffentlich, by design, prüfen `churchtools_suite_public`-Nonce).

Außerdem erledigt (02.11.2026, Details in `docs/GITHUB-UND-ZUGAENGE.md`):
- Addon-Repos mit GitHub verknüpft und lokale Stände gepusht (elementor v1.0.0.3, posts-sync v0.2.0.3, presentations v0.1.3).
- Demo-Repo `churchtools-suite-demos`: divergente Historie via `--allow-unrelated-histories` gemergt, 5 lose Dev-Skripte entfernt, gepusht.
- `inject_addon_updates()`: Presentations-Addon ergänzt (WP-Auto-Updates).
- SSH-Zugänge `plugin-test`/`feg-aschaffenburg.de` (web73.feg.de:22073) eingerichtet und getestet; `deploy-scp.ps1` lauffähig.
- Fallback `plugin.feg-aschaffenburg.de/download/` mit Release-ZIPs befüllt (alle 200).
- Server aufgeräumt: `wp-config.php.backup`, 5 Dev-Dateien (web2980) und 4 Strato-Altdateien (web2738) nach `private/server-cleanup-20261102/` verschoben.
- `ajax_load_calendar_month` loggt nur noch `array_keys($_POST)` statt Nonce-Wert.
- Verwaister Clone-Rest `churchtools-suite-demo` in dev-Site gelöscht.

Offen:
- Alte Cron-Hooks `puc_cron_check_updates-*` nach Übergangszeit entfernen. Cleanup-Mechanismus existiert bereits (`cleanup_legacy_cronjobs()` im Activator seit v1.0.6.0 + AJAX-Handler im Debug-Tab). Offen ist die Entscheidung, ab wann der Übergangs-Code selbst entfernt werden kann.
- `plugin-feg-db-dump.sql` (67 MB) im Home von web2738 prüfen – Löschung oder als Backup aufheben.
- Addon-Repo-Mapping steht an 3 Stellen in `class-churchtools-suite-admin.php` + `addons-page.php` – ggf. zentralisieren.

## 1. Verifizieren (nächste Version v1.3.x)

1. **Frontend-Filter** für Event-Listen (Hauptplugin + Elementor) gegen echte Daten prüfen.
2. **Sync-Bereinigung**: Löschung von Terminen/Appointments per Vollsync gegen Testsystem verifizieren.

## 2. Doku v1.3.x

- Schnellstart: Verbindung, Kalenderauswahl, erster Shortcode.
- `calendar_ids="1,2,3"` mit gültigem/ungültigem Beispiel.
- FAQ: Cache, WP-Cron, Berechtigungen, Addon-Abhängigkeiten.
- Versionsstände angleichen (README 1.3.0.11 vs. Code 1.3.0.14).

## 3. Custom CSS Nacharbeiten (niedrig)

- CodeMirror-Editor, Vorschau, CSS-Validierung.

## 4. Mittelfristig

- **v1.4.0:** Sync-Status/Betriebsstabilität; Posts-Sync komplett im Admin konfigurierbar (Mapping, Testlauf ohne Schreiben, Fehlerprotokoll).
- **v1.5.0:** Design-Presets (Modern, Klassisch, Minimal, Dark, Church), responsive 320px-Test.
- **v2.0.0:** Plugin-API für externe Entwickler.
- **Builder-Addons:** WPBakery und Divi nach Stabilisierung der Kern-API.
