# Style-Konzept — Plugin-übergreifendes Design-System

Vorlage: ChurchTools Suite (Referenzimplementierung). Ziel: einheitliches
Erscheinungsbild für alle Vereinsring-/FEG-Plugins (VR-Plugins) in
WordPress-Backend und Frontend.

Grundprinzip: **WordPress-nativ wirken, nicht wie ein Fremdkörper.**
Das Backend orientiert sich an der WP-Admin-Sprache (Farben, Abstände,
Komponenten), ergänzt um ein eigenes, konsistentes Komponentensystem.

---

## 1. Namenskonvention & CSS-Architektur

| Punkt | Regel |
|---|---|
| Prefix | Alle eigenen Klassen mit Plugin-Prefix: `cts-` (ChurchTools Suite), für VR-Plugins analog `vr-` |
| Verschachtelung | Flach halten, Klassen statt Element-Selektoren |
| BEM-light | Komponente + Element: `.cts-card`, `.cts-card-header`, `.cts-card-body`, `.cts-card-footer` |
| Varianten | Suffix-Klassen: `.cts-button-primary`, `.cts-badge-success`, `.cts-tabs-small` |
| States | `.active`, `.loading`, `.disabled`, `[aria-busy]` |
| Utility | Sparsam: `.cts-mt-20`, `.cts-mb-20`, `.cts-muted` |

### Dateien (pro Plugin)

```
assets/css/<plugin>-admin.css     → nur Admin (admin_enqueue_scripts)
assets/css/<plugin>-public.css    → Frontend + Admin-Basis (Buttons/Badges teilen)
assets/css/<plugin>-single.css    → nur Detail-/Sonderseiten
assets/js/<plugin>-admin.js       → Vanilla JS, IIFE, keine jQuery-Pflicht
assets/js/<plugin>-public.js      → Frontend
```

**Regel:** Kein Inline-CSS in Templates außer dynamischen Werten
(z. B. Kalenderfarbe). Kein `!important` außer zum Überschreiben von WP-Core.

### Enqueue-Regeln

- Admin-CSS/JS nur auf eigenen Plugin-Seiten laden (`page`-Param / Screen-ID prüfen).
- Script-Dependencies nur auf **im selben Kontext registrierte** Handles
  (Fehlerquelle: Dep auf Frontend-Handle im Admin → Script wird nie ausgegeben).
- `wp_localize_script` für `ajaxUrl` + `nonce` + `version`.

---

## 2. Farbpalette

Basiert auf WP-Admin-Farben + Plugin-Akzent (ChurchTools-Gradient).

### Primär/Akzent

| Token | Wert | Verwendung |
|---|---|---|
| Primary | `#2271b1` | Buttons, aktive Tabs, Links, Focus |
| Primary Hover | `#135e96` | Hover-Zustände |
| Header-Gradient | `#667eea → #764ba2` (135°) | Seiten-Header im Admin (Plugin-Identität) |

### Neutral

| Token | Wert | Verwendung |
|---|---|---|
| Text | `#1d2327` | Überschriften, Fließtext stark |
| Text gedämpft | `#646970` | Sekundärtext, Beschreibungen |
| Border | `#c3c4c7` | Card-/Container-Rahmen |
| Border hell | `#dcdcde` | Trennlinien innerhalb von Cards |
| Hintergrund hell | `#f6f7f7` | Card-Footer, Sub-Tabs inaktiv |
| Fläche | `#fff` | Cards, Tab-Content |

### Status

| Klasse | Hintergrund | Text |
|---|---|---|
| `.cts-badge-success` | `#d4edda` | `#155724` |
| `.cts-badge-info` | `#d1ecf1` | `#0c5460` |
| `.cts-badge-warning` | `#fff3cd` | `#856404` |
| `.cts-badge-danger` | `#f8d7da` | `#721c24` |
| `.cts-badge-secondary` | `#e2e3e5` | `#383d41` |
| Info-Box | `#f0f0f1` + left-border `#72aee6` | `#646970` |

### Frontend-Besonderheit

Kalender-/Kategoriefarben kommen dynamisch aus der Datenbank → als
**CSS-Custom-Property** am Element setzen:

```css
.cts-event {
    --calendar-color: #2271b1;   /* Fallback, per inline style überschrieben */
    --date-badge-bg: var(--calendar-color);
    --grid-gap: 20px;
}
```

Das erlaubt farbige Elemente (Date-Badges, Akzentbalken) ohne
Inline-Farbwerte an jedem Unterelement.

---

## 3. Typografie

```css
font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto,
             Oxygen, Ubuntu, Cantarell, sans-serif;
```

| Element | Größe | Gewicht |
|---|---|---|
| Seitentitel (Header h1) | 20px | 400 |
| Header-Icon | 26px | — |
| Untertitel | 13px | 300 |
| Card-Titel (h3) | 14px | 600 |
| Fließtext / Buttons / Tabs | 13px | 400–500 |
| Badges | 12px | 600 |
| Meta/Beschreibung | 12–13px | 400 |

Emoji/Dashicons als Icons: `text-rendering: optimizeLegibility` +
`-webkit-font-smoothing: antialiased` auf Tab-/Button-Containern.

---

## 4. Abstände, Radien, Schatten

| Token | Wert |
|---|---|
| Card-Padding (Body) | 18px |
| Card-Header/-Footer | 14px 18px / 12px 18px |
| Button-Padding | 6px 12px |
| Tab-Padding | 10px 14px |
| Sub-Tab-Padding | 10px 16px |
| Grid-Gap Karten/Listen | 16–20px |
| Seitenabstand Komponenten | 20px (`.cts-mt-20`) |
| Border-Radius Cards | 0–6px (Admin eckig/konservativ, Frontend runder) |
| Border-Radius Buttons/Badges | 3px |
| Shadow Card | `0 1px 1px rgba(0,0,0,0.04)` |
| Shadow Card Hover | `0 2px 4px rgba(0,0,0,0.08)` |
| Transition | `all 0.15s ease` |

---

## 5. Menüführung (Backend)

### Hierarchie – 3 Ebenen

```
WP-Admin-Sidebar
└── Top-Level-Menü  (eigener Menüpunkt, dashicon, Position ~30)
    ├── Submenü: Übersichten  (Sammelpunkt, zweistufig via Flyout)
    ├── Submenü: Daten        (CPT-Listen: Events, Services, …)
    ├── Submenü: Einstellungen
    └── Submenü: Debug/Logs

Seite (Inhalt)
└── .cts-tabs        → Hauptbereiche der Seite (GET-Param ?tab=)
    └── .cts-sub-tabs → Unterbereiche (GET-Param &subtab=)
```

### Regeln

1. **Ein Top-Level-Menü pro Plugin.** Position zwischen 25–30, eigenes
   Dashicon (Hauptplugin: `dashicons-calendar-alt`).
2. **Submenüs für Hauptfunktionen** (Übersichten, Daten, Einstellungen,
   Debug). Reihenfolge über Positions-Parameter steuern.
3. **Zweistufige Menüebene** bei vielen Listenansichten: Ein Submenü
   „Übersichten" öffnet ein CSS-Flyout mit den Einzelansichten
   (statt 10 Submenü-Einträge).
4. **Tabs innerhalb der Seite** für verwandte Bereiche
   (Einstellungen → API/Sync/Posts/Kalender/Services/Templates/Erweitert).
   Tabs sind Links mit `?tab=`/`&subtab=` → serverseitiges Rendering,
   kein JS-Tabwechsel nötig. Aktiver Tab: `.active`-Klasse.
5. **Capabilities statt `manage_options`:** eigene Rechte
   (z. B. `manage_churchtools_suite`, `configure_churchtools_suite`),
   damit Fachrollen ohne Admin-Rechte arbeiten können.

### Tab-Styling

- Haupt-Tabs: Unterstrich-Stil (Border-bottom `#2271b1` wenn aktiv).
- Sub-Tabs: Pill-/Karteikarten-Stil (heller Hintergrund, aktiver Tab weiß
  mit blauer Unterkante); Content schließt optisch an
  (`.cts-sub-tabs + .cts-subtab-content` mit `border-top: none`).

---

## 6. Backend-Komponenten

### 6.1 Seiten-Header

```html
<div class="cts-wrap">
  <div class="cts-header">
    <h1><span>📅</span> Pluginname</h1>
    <p class="cts-subtitle">Beschreibung / Version</p>
  </div>
</div>
```

- Gradient-Hintergrund (Plugin-Identität), weißer Text.
- WP-Notices erscheinen **vor** dem Header (`margin-top` angeglichen).

### 6.2 Cards

Zentrales Strukturelement des Backends:

```html
<div class="cts-card">
  <div class="cts-card-header">
    <span class="cts-card-icon">✅</span>
    <h3>Titel</h3>
  </div>
  <div class="cts-card-body">…</div>
  <div class="cts-card-footer">…</div>
</div>
```

- Header: Icon (Emoji 24px) + h3 14px/600.
- Footer: heller Hintergrund, Aktionen linksbündig.
- Hover: leichter Schatten (Affordance).

### 6.3 Buttons

| Variante | Aussehen | Einsatz |
|---|---|---|
| `.cts-button-primary` | `#2271b1` gefüllt, weiß | Hauptaktion (Speichern, Sync) |
| `.cts-button-secondary` | weiß/hell, blaue Kontur | Sekundär (Testen, Abbrechen) |
| `.cts-button.loading` | Spinner via `::after` (`cts-spin`) | AJAX-Lauf |

- Icon (Emoji/Dashicon) + Text, `gap: 6px`, `inline-flex`.
- Beim AJAX: `disabled` + `aria-busy="true"` + Spinner, danach Originaltext zurück.

### 6.4 Badges & Status

`.cts-badge` + Varianten (`-success/-info/-warning/-danger/-secondary`)
für Sync-Status, Versionsstände, Zählwerte.

### 6.5 Hinweise/Notices

- WP-Notices (`notice notice-success inline`) für AJAX-Ergebnisse.
- `.cts-info` (graue Box, blauer Linksbalken) für permanente Hinweise.
- Leere Zustände: `.cts-empty-state` mit `.cts-empty-icon` + Text + Handlungsaufforderung.

### 6.6 Formulare

- `.cts-form`, Required-Felder mit rotem Border bei fehlender Eingabe.
- Toggle-Switches: `.cts-toggle` + `.cts-toggle-slider` (CSS-only Checkbox).
- Filter: `.cts-filter-section` + `.cts-filter-grid` + `.cts-filter-actions`
  + `.cts-active-filters` (Chips der aktiven Filter).

### 6.7 Tabellen & Listen

- `.cts-table-wrapper` (horizontales Scrollen auf schmalen Screens).
- `.cts-pagination` + `.cts-pagination-info`.

### 6.8 Spezial-Patterns

- **Shortcode-Generator:** `.cts-generator-card` mit nummerierten Steps
  (`.cts-step-number`), Auswahl-Grid, Ergebnis-Box mit Copy-Button.
- **Wizard-Optik** für komplexe Einstellungen statt endloser Formularseiten.

---

## 7. Frontend-Komponenten

Ziel: schlank, themenkompatibel, per Shortcode/Block einbindbar.
Alle Elemente in einem Plugin-Wrapper (`.cts-frontend`/View-Klasse) –
**keine globalen Resets**, damit das Theme nicht zerlegt wird.

### 7.1 View-Varianten (Template-System)

Pro Inhaltstyp mehrere Darstellungen über Prefix-Templates:

| Variante | Merkmale |
|---|---|
| `classic` | Listenansicht mit Date-Badge links |
| `modern` | Karten-Grid, Bildfläche, Hover |
| `minimal` | Nur Text/Zeilen, für Sidebar/Widget |
| `carousel` | Horizontale Scroll-Leiste mit Pfeilen |
| `countdown` | Nächstes Event groß mit Countdown |

Der View wählt Template-Datei über Mapping (mit Präfix-Fallback).

### 7.2 Kernkomponenten

- `.cts-event` / `.cts-card`: Karte mit Bild, Titel, Datum, Ort.
- `.cts-date-badge` / `.cts-calendar-badge`: farbcodiert via `--calendar-color`.
- `.cts-grid`: `display: grid`, `--grid-gap`, responsive Spalten
  (`auto-fill, minmax(280px, 1fr)`).
- `.cts-list`: Zeilen-Layout mit `--cts-list-padding`.
- `.cts-modal`: Detail-Popup (Overlay + Panel, Schließen via X, ESC, Outside-Click).
- `.cts-countdown`: große Zeitanzeige mit eigenen Custom Properties
  (`--countdown-bg`, `--countdown-text`, `--countdown-accent`, `--countdown-secondary`).
- `.cts-tooltip`, `.cts-pagination`.

### 7.3 Regeln Frontend

- Theme-Unabhängigkeit: eigene Schriftgrößen/Farben setzen, nicht erben
  (Themes überschreiben sonst unvorhersehbar).
- Custom Properties pro View-Root für thembare Werte.
- Responsive: Grid-Collapse unter ~768px, Touch-Ziele ≥ 44px.
- Kein jQuery-Zwang im Frontend.

---

## 8. Interaktions- & AJAX-Patterns

1. **Buttons:** `type="button"`, Handler in `<plugin>-admin.js`,
   nicht inline `onclick`.
2. **AJAX:** `fetch(ajaxUrl)` POST `application/x-www-form-urlencoded`
   mit `action` + `nonce` (aus `wp_localize_script`).
3. **Antwort-Parsing:** erst `r.text()`, dann `JSON.parse` mit
   Fallback-Extraktion (`{…}`-Slice) – PHP-Notices vor JSON abfangen,
   Fehlertext in Konsole + lesbare Meldung im Result-Div.
4. **Ergebnis-Anzeige:** dediziertes Result-Element unter dem Button,
   `display:none` → `block` mit Notice-Markup.
5. **Success-Folgeaktion:** nach erfolgreichem Sync `setTimeout(location.reload, 1500)`.
6. **Duplikat-Schutz:** bei Inline- + externem Script
   `dataset.xxxHandler` setzen und beim zweiten Binder abbrechen
   (siehe `ctsSyncHandler`).
7. **Sicherheit:** jedes AJAX-Action mit Nonce-Prüfung + Capability-Check;
   `nopriv` nur für explizit öffentliche Endpunkte mit eigenem Public-Nonce.

---

## 9. Accessibility

- Focus sichtbar: `outline: 1px solid #2271b1` auf Tabs/Buttons.
- `aria-busy` während AJAX, `role="status"`/`aria-live` auf Result-Divs.
- Kontraste: Text `#1d2327`/`#646970` auf Weiß erfüllt AA;
  Badge-Paare (Bg/Text) sind abgestimmt.
- Alle interaktiven Elemente echte `<button>`/`<a>` – keine `div`-Buttons.
- Sub-Tab-Navigation via URL → Deep-Linking + Browser-Back funktioniert.

---

## 10. Checkliste: Übertragung auf VR-Plugins

- [ ] Prefix festlegen (`vr-` oder pluginspezifisch `vrf-`, `vrm-` …)
- [ ] Admin-CSS: Header (eigener Gradient je Plugin), Tabs, Sub-Tabs,
      Cards, Buttons, Badges, Info-Box, Empty-State, Toggle übernehmen
- [ ] Public-CSS: View-System + Custom Properties übernehmen
- [ ] Menü: 1 Top-Level + Submenüs + Tabs/Subtabs + eigene Capabilities
- [ ] Enqueue: Kontext-Check + nur registrierte Script-Dependencies
- [ ] AJAX-Pattern: localize + fetch + JSON-Fallback + Result-Div + Guard
- [ ] Typo/Farben/Abstände aus Abschnitt 2–4 als CSS-Variablen (`:root`)
- [ ] PHP-Lint + `node --check` für alle JS-Dateien im CI-Workflow
- [ ] Release-Check vor jedem Release (`check-release.ps1`-Pendant)

---

*Referenz: ChurchTools Suite v1.3.0.17 — `assets/css/churchtools-suite-admin.css`,
`assets/css/churchtools-suite-public.css`, `admin/class-churchtools-suite-admin.php`.*
