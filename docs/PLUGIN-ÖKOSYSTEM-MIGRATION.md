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

Entscheidung (offen, Optionen):

| Option | Vor | Contra |
|---|---|---|
| A: Repos unter persönlichem GitHub-Account | volle Kontrolle, globale Bereitstellung | Orgs verlieren direkte Kontrolle (Forks möglich) |
| B: Neue neutrale GitHub-Org (z. B. `vr-plugins`) | geteilter Besitz, sauber | zweite Org pflegen |
| C: Status quo in `feg-aschaffenburg` | kein Umbau | Org-Branding, VR-Plugins passen nicht rein |

- [ ] Entscheidung treffen (Empfehlung: **A** mit Org-Forks, oder **B**)
- [ ] Bei Umzug: `git remote` in lokalen Checkouts anpassen,
      Updater-URLs im Code aktualisieren (siehe 0.4)
- [ ] `cts-demo-theme` ggf. eigenes Repo anlegen

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

- [ ] Updater zeigt nach Repo-Umzug auf neue GitHub-URLs
      (`class-churchtools-suite-auto-updater.php`, `update-checker.php`)
- [ ] Fallback `plugin.feg-aschaffenburg.de/download/` beibehalten oder
      neutrale Domain einführen — Entscheidung
- [ ] Release-Prozess bleibt: `build-wp-zips.ps1` → `gh release` →
      Fallback-Upload (`plugin-test`)

### 0.5 Basis-Tooling (vor Plugin-Migration)

- [ ] `dev-shared/plugin-design-system/` anlegen:
      `tokens.css`, `components.css`, `admin.css`, `public.css`
      (Quelle: ChurchTools-CSS, auf `vr-` gemappt)
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

| # | Frage | Optionen |
|---|---|---|
| 1 | Repo-Ziel | persönlicher Account / neue Org / feg-aschaffenburg |
| 2 | Fallback-Domain | plugin.feg-aschaffenburg.de behalten / neutral |
| 3 | Migrations-Reihenfolge CSS | Big-Bang pro Plugin vs. inkrementell |
| 4 | VR-Plugin-Liste | welche VR-Plugins kommen ins Ökosystem |
| 5 | Theme `cts-demo-theme` | eigenes Repo? Namespace? |

*Erstellt: 2026-11-02 — Referenzen: docs/STYLE-KONZEPT.md,
docs/GITHUB-UND-ZUGAENGE.md*
