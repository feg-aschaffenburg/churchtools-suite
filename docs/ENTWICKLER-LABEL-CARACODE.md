# CaraCode – Entwickler-Label, Umstellungsplan & Branding

Dieses Dokument enthält das vollständige Paket für den Start des Entwickler-Labels **CaraCode** von **Kai Naumann** (Alzenau): Die rechtliche Strukturierung, den technischen Ablaufplan für GitHub & Hosting sowie das Branding-Konzept inklusive Logo-Download.

---

## 1. Logo & Markenmaterialien

- **Logo-Grafik (Download):** [Logo herunterladen (JPG)](watermarked_img_3725758013865451581.jpg)

### Farbpalette (Hex-Codes)
- **Cara (Primär):** `#10B981` (Smaragdgrün / Caritas, Frische, Leben)
- **Code (Sekundär):** `#1E293B` (Dunkelblau / Technologie, Struktur, Vertrauen)
- **Hintergrund:** `#F8FAFC` / `#FFFFFF` (Neutrales Light Theme)

### Logo-Symbolik
Das Icon kombiniert vier abgerundete Schnittstellen-Arme (Software-Knotenpunkte/Nodes) mit einem leicht verlängerten vertikalen Balken. Dadurch entsteht eine dezente Kreuz-Symbolik, die den christlichen Hintergrund widerspiegelt, ohne im weltlichen Vereinsumfeld aufdringlich zu wirken.

---

## 2. Rechtlicher Rahmen & Identität

- **Rechtsform:** Privatperson (Kai Naumann). *CaraCode* agiert als neutrales Entwickler-Label / Pseudonym.
- **Haftungsbeschränkung:** Alle Plugins werden unter der Open-Source-Lizenz **GPLv3** veröffentlicht. Ergänzend wird in den Repositories und im Plugin-Backend folgender Hinweis eingebunden:
  > *Die Software wird „wie gesehen“ (AS IS) ohne Gewährleistung bereitgestellt. Die Nutzung erfolgt auf eigene Verantwortung.*
- **Impressum:** Impressumspflicht nach § 5 DDG mit Angabe des Klarnamens (Kai Naumann, Alzenau) auf `caracode.de` und im GitHub-Profil.

---

## 3. Technischer Ablaufplan für die Umstellung

### Phase 1: Accounts & Buchhaltung trennen
1. **Zweites netcup-Konto:** Ein neues, privates netcup-Konto auf Kai Naumann anlegen und die Domain `caracode.de` registrieren. *(Verhindert Vermischung mit der Vereinsring-Buchhaltung)*.
2. **GitHub-Organisation:** Auf GitHub die kostenlose Organisation `@caracode` (oder `@caracode-dev`) registrieren.

### Phase 2: Repositories zentralisieren
1. In den bestehenden Plugin-Repositories auf GitHub unter **Settings -> Danger Zone** die Option **Transfer ownership** wählen.
2. Ziel: Organisation `@caracode`. *(Alle Releases, Commit-Historien, Tags und Issues bleiben zu 100 % erhalten)*.

### Phase 3: Statische Landingpage & Domain (0 € Hosting)
1. In der Org `@caracode` ein neues Repo namens `caracode.github.io` anlegen.
2. `index.html` (Landingpage) und `404.html` (Fallback) hochladen.
3. **DNS-Einstellungen bei netcup:**
   - A-Records (für `@`): `185.199.108.153`, `185.199.109.153`, `185.199.110.153`, `185.199.111.153`
   - CNAME-Record (für `www`): `caracode.github.io.`
4. Unter **Settings -> Pages** die Custom Domain `caracode.de` eintragen und **Enforce HTTPS** aktivieren.

### Phase 4: Code-Anpassungen in den Plugins
1. **PHP-Namespaces:**
   - ChurchTools Plugin: `namespace CaraCode\ChurchTools\ShirtManager;`
   - Vereinsring Plugin: `namespace CaraCode\Vereinsring\Manager;`
2. **Plugin Header:**
   ```php
   /**
    * Plugin Name:       CaraCode CT Shirt Manager
    * Plugin URI:        https://caracode.de
    * Author:            CaraCode (Kai Naumann)
    * Author URI:        https://caracode.de
    * License:           GPL-3.0-or-later
    */
   ```
3. **Plugin Update Checker (Puc):** URL auf das neue Org-Repository `https://github.com/caracode/ct-shirt-manager/` umstellen.
4. **Downloads & Fallbacks:** Releases werden direkt über GitHub Releases bereitgestellt (`.../releases/latest/download/...`).