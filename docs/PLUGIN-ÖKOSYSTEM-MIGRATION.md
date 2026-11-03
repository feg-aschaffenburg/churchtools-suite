# Plugin-Ökosystem — Globaler Migrationsplan

Ziel: Alle Plugins (ChurchTools Suite + Addons, Demo, VR-Plugins) auf ein
einheitliches Fundament stellen — persönliche Autorschaft, gemeinsamer
Namespace, Shared Design System, einheitliche Release-/Update-Prozesse.

Betroffene Plugins (Stand heute):

| Plugin | Repo | Version | Namespace aktuell |
|---|---|---|---|
| ChurchTools Suite | feg-aschaffenburg/churchtools-suite | 1.3.0.17 | `cts-`, `churchtools-suite`, `ChurchTools_Suite` |
| CTS Elementor | feg-aschaffenburg/churchtools-suite-elementor | 1.0.0.4 | `cts-elementor` |
| CTS Posts Sync | feg-aschaffenburg/churchtools-suite-posts-sync | 0.2.0.4 | `cts-posts-sync` |
| CTS Presentations | feg-aschaffenburg/churchtools-suite-presentations | 0.1.4 | `cts-presentations` |
| CTS Demo | feg-aschaffenburg/churchtools-suite-demos | 1.1.4.3 | `cts-demo` |
| VR-Plugins (Forms u. a.) | lokal/SharedDrive | — | `vr-*` |

---

## Phase 0 — Grundsätzliche Voraussetzungen

### 0.1 Autorschaft & Rechte

- [x] Freigabe geklärt: Autor ist Vorstandsmitglied beider Organisationen —
      keine externen Genehmigungen nötig.
- [ ] **Header in jedem Plugin** auf persönliche Autorschaft umstellen:

  ```php
  /**
   * Plugin Name: ChurchTools Integration Suite
   * Author:      Kai Naumann
   * Author URI:  https://github.com/<persoenlicher-account>
   * License:     GPLv2 or later
   * License URI: https://www.gnu.org/licenses/gpl-2.0.html
   */
  ```

- [ ] `LICENSE`-Datei (GPLv2) in allen Repos prüfen/ergänzen.
- [ ] GPL-**No-Warranty**-Hinweis (§11/12) in README/Header — wichtig,
      da als Privatperson publiziert wird (Haftung minimieren).
- [ ] Prüfen, dass keine Secrets, internen Zugangsdaten oder
      personenbezogenen Daten in den Repos liegen.

### 0.2 Repository-Struktur

**Entschieden (2026-11-02): Option A** — Repos ziehen auf den persönlichen
GitHub-Account (`FEGAschaffenburg`) um. Die Organisationen können bei
Bedarf forken; Autorschaft liegt damit klar bei der Person.

**Geplante Repos (Anlage erfolgt später, siehe Phase 1.x):**

| Repo | Inhalt | Sichtbarkeit |
|---|---|---|
| `<user>/churchtools-suite` | Hauptplugin (Transfer von feg-aschaffenburg) | public |
| `<user>/churchtools-suite-elementor` | Addon | public |
| `<user>/churchtools-suite-posts-sync` | Addon | public |
| `<user>/churchtools-suite-presentations` | Addon | public |
| `<user>/churchtools-suite-demos` | Demo-Plugin | privat oder public |
| `<user>/plugin-design-system` | Shared CSS/JS (vr-Namespace) | public |
| `<user>/cts-demo-theme` | Demo-Theme | TBD |

- [ ] Repo-Transfers durchführen (GitHub Transfer behält Issues/Stars/PRs)
- [ ] `git remote set-url origin` in allen lokalen Checkouts
- [ ] Updater-URLs im Code aktualisieren (siehe 0.4) — **Release erst
      nach Umzug**, sonst zeigt der Updater ins Leere
- [ ] Alte Repo-URLs: GitHub leitet automatisch weiter — trotzdem
      Updater zeitnah patchen

#### Update-Faehigkeit beim Repo-Transfer sichern (Checkliste)

**Mechanismen, die fuer uns arbeiten:**

- GitHub-Transfer richtet automatische Weiterleitungen ein: Web-URL,
  Releases-API (`api.github.com/repos/<alt>/...` → 301),
  Release-Assets, git clone/push. `wp_remote_get` folgt Redirects —
  installierte Plugins mit altem Updater-Code funktionieren weiter.
- Der Fallback `…/download/` ist GitHub-unabhaengig und bleibt
  unveraendert — Sicherheitsnetz falls ein Redirect klemmt.

**Ablauf (Reihenfolge verbindlich):**

1. Repo-Transfer durchfuehren (kein Fork, kein Neu-Anlegen —
   sonst gehen Releases/Assets verloren)
2. Verifizieren: `curl -I api.github.com/repos/feg-aschaffenburg/<repo>`
   muss 301 auf die neue URL liefern; neue URL muss Releases liefern
3. Updater-URLs im Code patchen (`auto-updater`, `update-checker`)
4. Version bump + Release + Fallback-Upload — die neue ZIP traegt
   bereits die neue URL
5. `git remote set-url origin` in allen lokalen Checkouts
6. Auf einer Testinstallation Update-Check ausloesen (Redirect-Test
   aus Sicht einer Bestandsinstallation)

**Fallstricke:**

- ❌ Nach dem Transfer **kein** Repo gleichen Namens in
  `feg-aschaffenburg` neu anlegen — das toetet den Redirect und alle
  alten Installationen verlieren Updates (Org-Kopie nur als Fork
  mit abweichendem Namen)
- ❌ Kein Release zwischen Umzug und URL-Patch — alte ZIP wuerde
  weiterhin auf die alte (dann weitergeleitete) URL zeigen und den
  Patch zunichte machen

### 0.3 Namespace-Strategie (verbindlich)

Zwei Ebenen (siehe STYLE-KONZEPT.md, Abschnitt Namespaces):

| Ebene | Prefix | Gilt für |
|---|---|---|
| Ökosystem (shared) | `vr-` / `vr_` / `VR_` | Shared CSS/JS, gemeinsame Libs |
| Plugin | `vr_cts_`, `vr_forms_` … | Options, AJAX, Cron, Caps, CPTs |

**Festlegungen:**

- CSS: **alle Plugins auf `.vr-`-Namespace** migrieren; Plugin-Identität
  über `--vr-header-gradient` + `.vr-scope-<plugin>`
- PHP: schrittweise auf echte Namespaces (`namespace VR\Forms;`) oder
  `VR_`-Klassenprefix; keine Eile — erst bei größeren Refactorings
- **Textdomain/Slug NICHT ändern** (`churchtools-suite` bleibt —
  Updater-Kompatibilität, installierte Basis)
- **Options-/Settings-Keys NICHT ändern** (Bestandsinstallationen!) —
  nur neue Keys nach neuer Konvention
- AJAX-Actions/Cron-Hooks: bestehende **behalten** (Abwärtskompatibilität),
  neue nach `vr_cts_`-Schema

### 0.4 Update-Kanal & Fallback sichern

**Offen (2026-11-02):** Überlegung läuft, eine eigene Hobby-Domain für
die Plugins einzurichten. Bis dahin bleibt der Fallback auf
`plugin.feg-aschaffenburg.de/download/` bestehen — der ist eingerichtet
und getestet (alle ZIPs erreichbar, HTTP 200).

- [ ] Updater zeigt nach Repo-Umzug auf neue GitHub-URLs
      (`class-churchtools-suite-auto-updater.php`, `update-checker.php`)
- [ ] Fallback-Domain später final festlegen (eigene Domain wäre der
      sauberste Weg — dann Fallback-Base-URL im Code konfigurierbar machen)
- [ ] Release-Prozess bleibt: `build-wp-zips.ps1` → `gh release` →
      Fallback-Upload (`plugin-test`)

### 0.5 Basis-Tooling (vor Plugin-Migration)

- [x] `C:\laragon\www\dev-shared\plugin-design-system/` angelegt
      (2026-11-02): `tokens.css` (Design-Variablen), `vr-admin.css`,
      `vr-public.css`, `vr-single.css` — komplette ChurchTools-CSS-Basis
      auf `vr-`-Namespace übersetzt, plus README mit Einbindungs-Anleitung.
      GitHub-Repo folgt mit den Repo-Transfers (Phase 0.2)
- [ ] Build-Skripte erweitern: Shared-Dateien beim ZIP-Bau in jedes
      Plugin kopieren (Modell A — keine Laufzeit-Abhängigkeit)
- [ ] `check-release.ps1` als Vorlage für alle Plugins
- [ ] CI (php-lint) in allen Repos aktiv

---

## Phase 1 — Quick Wins (pro Plugin ~30–60 min)

Je Plugin, ohne Funktionsänderung:

1. Header: Author/License/URI aktualisieren
2. LICENSE + README-Autorenzeile
3. `.github/workflows/php-lint.yml` einziehen (falls fehlt)
4. Version bump + Release + Fallback-ZIP

Reihenfolge: churchtools-suite → elementor → posts-sync →
presentations → demo → VR-Plugins.

## Phase 2 — Design-System-Einführung

1. Shared CSS in Build-Pipeline einhängen
2. Neues/bestes Plugin zuerst komplett auf `vr-`-Basis setzen
   (Referenz-Implementierung)
3. Bestehende Plugins: neue Komponenten nur noch `vr-`,
   Alt-Klassen (`cts-`) parallel belassen bis Phase 3

## Phase 3 — Namespace-Migration (pro Plugin, eigener Branch)

1. `cts-` → `vr-` in CSS/PHP/JS (Suchen&Ersetzen + Review)
2. `ctsSyncHandler` → `data-vr-*` Guards
3. Bestandstests: Admin-Seiten sichtbar, Buttons klickbar, Frontend-Views
4. Major/Minor-Version bump + Release + Changelog-Hinweis

**Nicht anfassen:** Textdomain, Settings-Keys, AJAX-Action-Namen,
Cron-Hooks, Tabellennamen (Abwärtskompatibilität).

## Phase 4 — Harmonisierung

- Addon-Repo-Mapping an zentraler Stelle bündeln
- Einheitliche Admin-Seitenstruktur (Tabs/Subtabs nach STYLE-KONZEPT)
- Einheitliche Shortcode-/Block-Namensgebung für neue Features
- Doku je Plugin auf einheitliches Gerüst (SCHNELLSTART/FAQ-Struktur)

---

## Offene Entscheidungen

| # | Frage | Status |
|---|---|---|
| 1 | Repo-Ziel | ✅ **entschieden:** persönlicher Account (2026-11-02) |
| 2 | Fallback-Domain | offen: ggf. eigene Hobby-Domain; vorerst plugin.feg-aschaffenburg.de |
| 3 | Migrations-Reihenfolge CSS | offen: Big-Bang pro Plugin vs. inkrementell |
| 4 | VR-Plugin-Liste | offen: welche VR-Plugins kommen ins Ökosystem |
| 5 | Theme `cts-demo-theme` | offen: eigenes Repo? Namespace? |
| 6 | GitHub-Repos anlegen | geplant, Umsetzung mit Phase 0.2/0.5 |

---

## Ideen-Backlog (Umsetzung ab 2027 — erst sammeln, dann priorisieren)

### A. Shared Code (ueber CSS hinaus)

- **A1 `vr-core` Shared-Library:** gemeinsame PHP-Basisklassen —
  Auto-Updater, Settings-Framework, AJAX-Basis (Nonce+Caps),
  Logger, Cron-Helper, Uninstall-Cleanup. Verteilung wie CSS:
  per Build kopiert oder als Mini-Must-Use-Core.
- **A2 `vr-admin.js` Shared-JS:** Fetch-Helper (`vrAjax(action, data)`),
  Result-Renderer, Loading-State, Duplicate-Handler-Guard —
  die Patterns aus STYLE-KONZEPT §8 als wiederverwendbares Modul.
- **A3 Plugin-Boilerplate:** Template-Repo fuer neue Plugins —
  Ordnerstruktur, Enqueue-Geruest, Settings-Page mit vr-Tabs,
  CI-Workflow, Build-Skript. `gh repo create --template`.

### B. Update- & Release-Strategie

- **B1 WP.org-Publikation pruefen:** kostenlose Plugins ueber
  wordpress.org verteilen → eingebauter WP-Updater statt
  GitHub-Fallback. Grosse strategische Frage (Exposure vs.
  Review-Auflagen, Slug-Reservierung).
- **B2 Eigener Update-Server:** falls eigene Domain kommt —
  einfache JSON-API (version, download_url) auf dem Webspace;
  entkoppelt von GitHub-Releases.
- **B3 Release-Konventionen:** einheitliches Versionierungsschema
  (aktuell 4-teilig `1.3.0.17` — beibehalten oder SemVer?),
  Changelog-Format, Release-Notes-Template, Beta-Channel.
- **B4 Kompatibilitaets-Matrix:** WP-Min/PHP-Min/Elementor-Min je
  Plugin dokumentieren + im Header (`Requires at least`, `Requires PHP`).

### C. Qualitaet & Testing

- **C1 PHPCS + WordPress-Coding-Standards** in die CI neben php-lint.
- **C2 Browser-Smoke-Tests (Playwright):** Admin-Seiten laden, Script-
  Tags pruefen, Buttons klicken — haette den Delayed-Dependency-Bug
  (admin.js nie ausgegeben) sofort gefunden.
- **C3 WP-CLI-Testharness:** lokale Admin-Page-Render-Tests wie der
  Debug-Ansatz vom 2026-11-02 verallgemeinern.
- **C4 PHPStan/Psalm** fuer Typfehler in den groesseren Plugins.

### D. Dokumentation & Branding

- **D1 Zentrale Doku-Site:** Demo-Site als Doku-Hub fuer ALLE Plugins
  (heute: nur ChurchTools). Einheitliche Struktur
  Schnellstart/Shortcodes/FAQ je Plugin.
- **D2 Produktfamilien-Name:** gemeinsamer Markenname fuer das
  Oekosystem (Icons, Banner-Assets 772x250/1544x500 fuer WP.org-Stil).
- **D3 Doku-Geruest:** einheitliche Dateien je Repo —
  README / SCHNELLSTART / FAQ / CHANGELOG / CONTRIBUTING / SECURITY.md.
- **D4 i18n-Strategie:** de_DE + en_US Basis, .pot-Generierung
  im Build, Textdomain = Slug.

### E. Architektur & Betrieb

- **E1 Monorepo vs. Polyrepo:** Addons koennten ins Hauptrepo
  (einfacheres gemeinsames Releasen) — oder bleiben getrennt.
  Beim persoenlichen Account neu bewerten.
- **E2 Demo-/Staging-Seite:** demo-Installation als dauerhafte
  Testbuehne fuer alle Plugins (Auto-Deploy bei Release?).
- **E3 Feature-Flags:** neue Funktionen hinter Settings/Constants
  aktivieren — sicherere Releases bei Live-Nutzern.
- **E4 Telemetrie:** bewusst keine — aber als Design-Prinzip
  festhalten (Datensparsamkeit als Feature, passt zu Kirchen-Kontext).
- **E5 Secrets-Handling:** nie Credentials im Repo; zentrale
  Doku wo Zugangsdaten gepflegt werden (kein Klartext).

### F. Community & Wartung

- **F1 Issue/PR-Templates** in allen Repos (Bug-Report mit
  WP/PHP/Plugin-Versionen).
- **F2 Maintenance-Fenster:** fester Rhythmus fuer
  WP-Kompatibilitaets-Updates (nach jedem WP-Core-Release pruefen).
- **F3 Deprecation-Policy:** wie lange alte AJAX-Actions/Shortcodes/
  CSS-Klassen parallel laufen (Vorschlag: 2 Major-Releases).

### G. Sicherheit & Datenschutz

- **G1 Secret-Scanning in CI** (gitleaks o. a.) — verhindert
  versehentlich committete Zugangsdaten in allen Repos.
- **G2 Security-Checkliste als CI:** nonces/caps auf allen AJAX-
  Handlern (das Audit vom 2026-11 automatisieren), esc_*-Ausgabe,
  sanitize_*-Eingabe, prepared Statements.
- **G3 Release-Signierung:** SHA256-Checksums je ZIP im Release +
  in der Fallback-JSON — Updater kann Integritaet pruefen.
- **G4 DSGVO-Bausteine:** je Plugin dokumentierte Datenhaltung
  (welche Daten, wo, wie lange) — Vorbereitung fuer Datenschutz-
  Seiten der Anwender. Cookie-frei by default.
- **G5 Einheitliches Rollen-Modell:** `vr_plugin_manager`-Basisrolle
  + pluginspezifische Caps — User muessen nicht Admins sein.

### H. Developer Experience

- **H1 Einheitliche Local-Dev-Konvention:** Laragon-Setup als Code
  dokumentiert (PHP-Version, Pretty-Permalinks, WP_DEBUG-Preset),
  `.wp-env.json` als Alternative fuer Docker-Nutzer.
- **H2 Editor/IDE-Standards:** `.editorconfig`, PHPCS-Ruleset,
  empfohlene Extensions — gleiche Formatierung auf allen Maschinen.
- **H3 Logging-Standard:** zentraler `vr_log()`-Wrapper
  (WP_DEBUG-aware, in Datei+Option), einheitliche Log-Viewer-Seite
  im Debug-Tab.
- **H4 Debug-Werkzeugkasten:** „System Report"-Seite (WP/PHP/Plugin-
  Versionen, Cron-Status) mit Copy-to-Clipboard fuer Support.
- **H5 WP-CLI-Kommandos:** Sync-Trigger, Cache-Flush, Health-Check
  per CLI statt nur UI-Buttons — automatisierbar, besser testbar.

### I. Performance

- **I1 Conditional Asset Loading:** Frontend-CSS/JS nur laden, wenn
  Shortcode/Block auf der Seite ist (derzeit teils global).
- **I2 Minify-Pipeline im Build:** `.min.css`/`.min.js` erzeugen,
  `SCRIPT_DEBUG`-Umschaltung respektieren.
- **I3 Cache-Konventionen:** Transient-Namen (`vr_<plugin>_…`),
  TTL-Standardwerte, gezielte Invalidierung nach Sync.
- **I4 Lazy-Loading:** Bilder/Iframes in Views, IntersectionObserver.

### J. Daten & Lebenszyklus

- **J1 Sauberes uninstall.php ueberall:** Optionen/Transients/CPTs/
  Cron-Hooks restlos entfernen — definierte Liste je Plugin.
- **J2 Settings Export/Import:** JSON-Export der Konfiguration —
  Migration zwischen Instanzen und Backup.
- **J3 Migrations-Framework:** versionierte DB-/Option-Upgrades
  (`db_version`-Option + Upgrade-Routine statt Inline-Fixes).
- **J4 Rollback-Pfad:** jeweils letzte stabile ZIP im Fallback
  behalten (`-previous.zip`) + „Zurueck zur Vorversion"-Doku.

### K. Editor & Frontend-Zukunft

- **K1 Shared Block Components:** Basis fuer Gutenberg-Bloecke
  (gemeinsame InspectorControls, Preview-Logik) in vr-core.
- **K2 Block Patterns:** fertige Layout-Kombis (Event-Grid +
  Filter + Countdown) als registrierte Patterns.
- **K3 REST-API-Konvention:** `vr/<plugin>/v1`-Routen mit
  einheitlichem Schema/Permissions — ermoeglicht Headless/SPA-
  Nutzung spaeter.
- **K4 Full-Site-Editing:** Templates/Parts kompatibel halten,
  keine harten Theme-Annahmen.

### L. Betrieb & Infrastruktur

- **L1 GitHub-Actions Release-Pipeline:** Tag → Build → Release →
  Fallback-Upload via SSH — heute manuell, spaeter ein Klick.
- **L2 Matrix-CI:** PHP 8.1–8.4 + WP latest-2 — Inkompatibilitaeten
  frueh sichtbar.
- **L3 Monitoring der Demo-Site:** Uptime/HTTP-Check als
  Fruehwarnung (Fallback down = Updates brechen).
- **L4 ADR (Architecture Decision Records):** `docs/decisions/`
  — heutige Entscheidungen (Repo-Ziel, Namespace, Fallback)
  waeren dort dokumentiert worden.
- **L5 Multisite-Tauglichkeit** festlegen: explizit unterstuetzen
  oder dokumentiert ausschliessen.
- **L6 Dependency-Hygiene:** Composer-NPM-Lockfiles committen,
  Renovate/Dependabot fuer Update-PRs.

### M. Inhaltliche Konsolidierung (Code-Dubletten, Analyse 2026-11-02)

Konkret im Code gefundene Duplikate — Kandidaten zum Zusammenfuehren:

- **M1 Auto-Updater existiert 3x mit unterschiedlicher Reife:**
  Hauptplugin 698 Zeilen, Elementor 253, Posts-Sync 342 Zeilen.
  → **Eine** `VR_Auto_Updater`-Klasse in vr-core, konfiguriert ueber
  Slug/Repo/Fallback-URL. Entscheidung welcher Stand die Basis ist
  (Hauptplugin ist am weitesten: Fallback + Token-Slot).
- **M2 Update-Checker-Addon-Mapping an 4 Stellen** (bereits bekannt) —
  in eine zentrale Registry `vr_addon_registry()`.
- **M3 Subtab-View-Boilerplate ~15x** im Hauptplugin
  (`admin/views/settings/subtab-*.php`, `debug/subtab-*.php`):
  gleiches Card-Geruest, gleiche Tab-Nav, gleiche Form-Struktur.
  → **Generischer Subtab-Renderer:** Subtabs als Config-Array
  (slug/titel/capability/callback), ein Loader rendert Nav+Content.
  Neue Subtabs = 1 Array-Eintrag statt Template-Kopie.
- **M4 AJAX-Boilerplate 38x:** `check_ajax_referer` +
  Capability-Check + `wp_send_json_*` immer identisch.
  → `vr_ajax_register(action, cap, callback)`-Helper in vr-core
  (registriert wp_ajax_*, prueft Nonce+Cap, wrapped Exceptions).
- **M5 PHP-Template-Partials:** Card/Badge/Button/Notice-Markup
  wird dutzendfach per HTML in Views geschrieben.
  → `vr_card($icon,$title,$body)`, `vr_badge($type,$text)`,
  `vr_button($label,$variant)` als Partial-Funktionen —
  Markup an einer Stelle, Konsistenz garantiert.
- **M6 View-Engine (46 Template-Dateien!):** Prefix-Mapping
  classic/modern/minimal + Varianten — dieselbe Loader-Logik
  waere fuer jedes Plugin mit Views nutzbar (Events, Formulare,
  Newsletter). → `vr_view_render($view_id, $variant, $data)`.
- **M7 Listen-/Tabellen-Komponenten:** Events-, Services-,
  Reports-Listen teilen Filter/Pagination/Empty-State-Markup.
  → Generische `vr_list_table` (kein WP_List_Table — zu alt,
  eigenes schlankes Grid).
- **M8 Build-/Deploy-Skripte dupliziert:** `scripts/` liegt in
  mehreren Addon-Repos (create-wp-zip, deploy-scp).
  → Ein Shared `vr-build/` Skript-Set im Design-System-Repo,
  pro Plugin nur `plugin.config.ps1` mit Slug/Pfaden.
- **M9 Debug-/Reparatur-Skripte:** `check-*.php`, `fix-*.php`
  tauchen in jedem Plugin auf (auch auf dem Server geloescht).
  → `vr-debug`-Toolkit: System-Report, Capability-Check,
  Cron-Status — eine Datei statt Ad-hoc-Skripten.
- **M10 Doku-Templates:** README/SCHNELLSTART/FAQ folgen immer
  demselben Geruest → Templates ins Design-System, pro Plugin
  nur Inhalte pflegen.
- **M11 Doppelte Hilfsfunktionen:** `is_numeric_array`,
  `delete_all`, `build_fallback_url` etc. mehrfach definiert
  → in `vr-core/helpers.php` sammeln.
- **M12 Shortcode-Registrierung + Parameter-Parsing** identisch
  pro Addon → `vr_shortcode_register($tag, $defaults, $cb)`.

---

## Quick-Win-Übersicht (Bewertung 2026-11-02)

Kriterien: geringer Aufwand (< ~2h pro Plugin), kein Risiko fuer
Bestandsinstallationen, kein Blocker durch offene Entscheidungen.

### ✅ Lohnt sich wirklich (empfohlene Reihenfolge)

| # | Item | Aufwand | Nutzen | Bemerkung |
|---|---|---|---|---|
| Q1 | **Phase-1-Header** (Author/Lizenz/URI je Plugin) | 15 min/Plugin | Autorschaft klar, WP.org-ready | braucht nur finale Author-URI |
| Q2 | **LICENSE + No-Warranty pruefen** | 15 min/Plugin | Haftungsschutz | GPLv2-Text kopieren |
| Q3 | **B4 Kompatibilitaets-Header** (`Requires at least`, `Requires PHP`) | 10 min/Plugin | WP.org-Pflichtfeld, saubere Aktivierungspruefung | aktuelle Mindestwerte verifizieren |
| Q4 | **G1 Secret-Scanning CI** (gitleaks) | 30 min einmal | verhindert Credential-Leaks in ALLEN Repos | ein Workflow-Template ueberall |
| Q5 | **php-lint CI in Addons** | 20 min/Repo | besteht nur im Hauptplugin | Workflow kopieren |
| Q6 | **F1 Issue/PR-Templates** | 30 min einmal | bessere Bug-Reports | ein Set in `.github/` je Repo |
| Q7 | **J4 Rollback-ZIP** | 20 min | `-previous.zip` im Fallback | eine Zeile im Upload-Ablauf |
| Q8 | **L4 ADR-Start** `docs/decisions/` | 30 min | heutige Entscheidungen nachdokumentieren | 3-4 Dateien aus diesem Plan |
| Q9 | **F3 Deprecation-Policy + D3 Doku-Geruest** | 1h | schriftlich, sonst verliert sich's | Textbausteine |
| Q10 | **L6 Dependabot** aktivieren | 10 min/Repo | Update-PRs automatisch | nur gh-Config |
| Q11 | **E5/F2 Betriebsregeln** (Secrets-Doku, WP-Release-Rhythmus) | 30 min | Prozess-Sicherheit | reine Doku |
| Q12 | **H4 System-Report-Seite** | ~2h | Support-Extremwert | als eigenes Feature bauen, testen |

### ⚠️ Sieht nach Quick Win aus, ist aber Falle oder mittlerer Aufwand

| Item | Warum NICHT als Quick Win |
|---|---|
| **M8 Build-Skripte zentralisieren** | Bewegt produktive Build-Pfade; bei 5 Repos schnell Bruch — erst mit vr-build-Design in Ruhe |
| **I1 Conditional Asset Loading** | Erkennungslogik fehleranfaellig (Shortcode im Widget/Block/Template) → Views koennen ungestylt aussehen; braucht Tests |
| **C1 PHPCS** | Erst-Lauf erzeugt hunderte Findings → Baseline/Suppressions konfigurieren ist halbtags Arbeit, nicht 1h |
| **G4 DSGVO-Doku** | Inhaltlich Denkarbeit je Plugin (was wird wo gespeichert) — eher 2–3h als schnell |
| **H5 WP-CLI-Kommandos** | Lohnt sich, aber Feature-Arbeit mit Tests — ~1 Tag |
| **L1 Release-Pipeline (GH Actions)** | SSH-Keys in CI-Secrets, Testlaeufe, Rollback-Pfad — 1–2 Tage, kein Quick Win |
| **I2 Minify-Pipeline** | Build-Aenderung + Sourcemap-/Debug-Handling — mittlerer Aufwand |
| **J1 uninstall.php** | Gefahr Datenverlust bei Fehlern — pro Plugin sorgfaeltig pruefen |

### ❌ Explizit KEINE Quick Wins (Architekturarbeit)

M1 (Updater vereinheitlichen — Basis-Entscheidung noetig),
M3/M4/M6 (Framework-Refactorings), vr-core, Namespace-Migration,
Monorepo-Bewertung, WP.org-Publikation, eigene Domain, C2 Playwright,
K-Serie (Editor), PHP-Namespace-Umstellung.

**Regel:** Alles was produktive Update-/Build-Kanaele, gespeicherte
Daten oder oeffentliche Ausgaben veraendert, ist per Definition kein
Quick Win — egal wie klein der Diff aussieht.

---

*Erstellt: 2026-11-02 — Referenzen: docs/STYLE-KONZEPT.md,
docs/GITHUB-UND-ZUGAENGE.md*
