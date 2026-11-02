# GitHub-Repositories, Update-Mechanik und Zugänge

Stand: 02.11.2026. Geprüft auf dem Laragon-Dev-Rechner (User `nauma`).

## 1. Repositories (Org `feg-aschaffenburg`)

| Repository | Sichtbarkeit | Lokal in Laragon | Stand |
|---|---|---|---|
| `feg-aschaffenburg/churchtools-suite` | public | Git-Checkout (`main`, dev-Site) | uncommitted Doku-/Code-Änderungen |
| `feg-aschaffenburg/churchtools-suite-elementor` | public | Git-Checkout (`master`, dev-Site) | **lokal v1.0.0.3, Repo nur 1.0.0.1 – ungepusht** |
| `feg-aschaffenburg/churchtools-suite-posts-sync` | public | Git-Checkout (`main`, dev-Site) | **lokal v0.2.0.3, Repo nur 0.2.0.1 – ungepusht** |
| `feg-aschaffenburg/churchtools-suite-presentations` | public | Git-Checkout (`main`, dev-Site) | **lokal v0.1.3, Repo nur 0.1.1 – ungepusht** |
| `feg-aschaffenburg/churchtools-suite-demos` | **private** | Git-Checkout (`master`, demo-Site `demo-chrurchtools-suite`) | **Historie divergiert: lokal 1 Commit `Release v1.1.4.2` ohne Bezug zu origin/master (42 Commits)** |

Hinweise:

- Das Demo-Repo heißt `churchtools-suite-demos` (Plural, privat); das Plugin-Verzeichnis heißt `churchtools-suite-demo`. Der produktive Arbeitsstand liegt in der Laragon-Site `demo-chrurchtools-suite`, nicht in `dev-churchtools-suite`.
- In `dev-churchtools-suite\wp-content\plugins\churchtools-suite-demo` liegt ein verwaister Clone-Rest (nur `.git/objects`, keine refs, ~555 KB) – Löschkandidat.
- Das Demo-Repo enthält auf `origin/master` lose Dev-Dateien (`check-*.php`, `test-admin-delete.php`, `content207.txt`), die lokal nicht vorhanden sind; lokal gibt es umgekehrt `README.md`, `ROADMAP.md`, `scripts/deploy-scp.ps1`, `templates/views/event-countdown`. Abgleich erfordert Merge mit `--allow-unrelated-histories` oder bewusstes Überschreiben einer Seite – Entscheidung offen.

## 2. Update-Mechanik

### Hauptplugin

- `includes/class-churchtools-suite-update-checker.php` und `class-churchtools-suite-auto-updater.php` fragen die GitHub-Releases-API von `feg-aschaffenburg/churchtools-suite` ab (`/releases?per_page=30`, `/releases/latest`).
- Ein optionales GitHub-Token kann per Option `churchtools_suite_github_token` oder Konstante `WP_CHURCHTOOLS_SUITE_GITHUB_TOKEN` hinterlegt werden (Rate-Limit/Abuse-Schutz).
- Aktueller Release-Stand: `v1.3.0.14` (31.08.2026) mit 4 Assets: `churchtools-suite-1.3.0.14.zip`, `churchtools-suite-elementor-0.6.28.zip`, `churchtools-suite-posts-sync-0.1.7.zip`, `churchtools-suite-presentations-0.1.0.zip`.
- **Addon-ZIPs hängen am Hauptplugin-Release** (Monorepo-Release-Strategie), nicht an den Addon-Repos.

### Addon-Updates

- `ChurchTools_Suite_Update_Checker::inject_addon_updates()` injiziert Updates für alle drei Addons in den WP-Update-Transient (Presentations seit 02.11.2026 ergänzt).
- Installation/Update über AJAX (`ajax_install_addon`, `ajax_update_addon`) liest Releases direkt aus den drei Addon-Repos; Asset-Matching per Namens-Prefix `<slug>-<version>.zip`.
- Repo-Mappings an drei Stellen gepflegt: `admin/class-churchtools-suite-admin.php` (ca. Zeilen 3429, 3708, 3852) und `admin/views/addons-page.php` (ca. Zeile 37 ff.).

### Fallback `plugin.feg-aschaffenburg.de`

- Konstante `FALLBACK_DOWNLOAD_BASE = 'https://plugin.feg-aschaffenburg.de/download'` in beiden Updater-Klassen. Erzeugt URLs `…/download/churchtools-suite.zip` bzw. `…/download/churchtools-suite-<version>.zip`.
- **Status: leer.** Alle geprüften URLs liefern 404 (`churchtools-suite.zip`, `churchtools-suite-1.3.0.14.zip`, `churchtools-suite-elementor-0.6.28.zip`). `/download/` selbst ist eine WP-Seite (200).
- Die Fallback-ZIPs müssen manuell auf den Server gelegt werden; kein Skript im Repo lädt sie dorthin hoch. Solange GitHub-Assets vorhanden sind, wird der Fallback nicht benötigt.

### Release-Erstellung

- `scripts/release-and-deploy-github.ps1` baut die ZIPs aus dem Workspace (Add-ons als Geschwister-Verzeichnisse) und erstellt das GitHub-Release inkl. Assets. Parameter: `-AutoVersion`, `-InitRepo`, `-SkipGit/-SkipPush/-SkipRelease`.
- `scripts/build-wp-zips.ps1` baut nur die ZIPs (`npm run zip:build` / `zip:release`).

## 3. Zugänge auf diesem Rechner

| Zugang | Status | Details |
|---|---|---|
| GitHub CLI (`gh`) | ✅ vorhanden | Account `FEGAschaffenburg`, Token-Scopes `repo`, `workflow`, `read:org`, `gist`; Git-Protokoll HTTPS. Push, Releases und Asset-Uploads möglich. |
| SSH-Konfiguration | ⚠️ unvollständig | `~/.ssh/config` kennt nur `vereinsring-netcup` (anderes Projekt). Der Alias `plugin-test` (Standard in `deploy-scp.ps1`) existiert **nicht** → Skript läuft hier nicht. |
| SSH `feg.de:22073` | ⚠️ Host erreichbar, Key fehlt | Server antwortet mit `Permission denied (publickey)`. Auf diesem Rechner liegt kein passender Private Key (nur `id_vereinsring_netcup`). `known_hosts` enthält historische Einträge für `[feg.de]:22073`, `[web73.feg.de]:22073`, `[ftp.feg.de]:22073` – der Zugang lief früher vermutlich über einen anderen Rechner/User. |
| `plugin.feg-aschaffenburg.de:22` | ❌ nicht erreichbar | Direkter SSH auf Port 22 läuft in Timeout; SSH läuft über `feg.de:22073` (Strato). |
| WP-Admin `plugin.feg-aschaffenburg.de` | ❓ unbekannt | `wp-login.php` erreichbar (200); Zugangsdaten liegen hier nicht vor. |

## 4. Konsequenz: Was ist für ein Update nötig?

| Aufgabe | Möglich? | Voraussetzung |
|---|---|---|
| Code-Änderungen + GitHub-Release | ✅ ja | `gh`-Login vorhanden; `release-and-deploy-github.ps1` nutzbar |
| Plugin-Updates an Installationen | ✅ ja (über GitHub) | GitHub-Release mit Assets; Fallback aktuell tot, aber nicht benötigt |
| Fallback-ZIPs auf feg.de legen | ❌ nein | SSH-Key für `feg.de:22073` (Strato-Hosting) oder WP-Admin-Zugang nötig |
| Deploy per `deploy-scp.ps1` | ❌ nein | SSH-Alias `plugin-test` + Key in `~/.ssh` anlegen |

## 5. Empfehlungen

1. **SSH-Zugang einrichten:** Private Key für `feg.de:22073` (Strato) beschaffen oder neuen Key hinterlegen und `~/.ssh/config` um `plugin-test` ergänzen – sonst bleibt `deploy-scp.ps1` auf diesem Rechner unbrauchbar. Benötigt: SSH-Benutzername + Private Key (oder Passwort zum Einrichten).
2. **Fallback-Downloads befüllen:** Aktuelle Release-ZIPs unter `/download/` ablegen, damit der Fallback-Greif bei GitHub-Ausfällen/Rate-Limits funktioniert. Benötigt Serverzugang (SSH/SFTP) oder WP-Admin-Zugang zu `plugin.feg-aschaffenburg.de`.
3. **Addon-Stände pushen:** Die lokalen Addon-Versionen sind neuer als ihre Repos (siehe Tabelle) – Commits erstellen und pushen, sobald freigegeben.
4. **Demo-Repo-Abgleich:** Divergente Historie zusammenführen (siehe Hinweise oben).
