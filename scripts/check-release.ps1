# Release-Check für ChurchTools Suite
#
# Prüft vor einem Release die Integrität (siehe ROADMAP "Release-Integrität"):
#   1. Header-Version == Versions-Konstante je Plugin
#   2. Git-Arbeitsbaum sauber (keine uncommitted Änderungen)
#   3. Tag v<Version> existiert und zeigt auf HEAD
#   4. Optional: gebaute ZIPs enthalten die passende Version und keine Dev-Dateien
#
# Aufruf vom Projektroot:
#   .\scripts\check-release.ps1
#   .\scripts\check-release.ps1 -ZipDir dist        # inkl. ZIP-Prüfung
#   npm run release:check

param(
    [string]$ZipDir = ""
)

$ErrorActionPreference = "Continue"
$SuiteRoot = Resolve-Path (Join-Path $PSScriptRoot "..") | Select-Object -ExpandProperty Path
$WorkspaceRoot = Resolve-Path (Join-Path $SuiteRoot "..") | Select-Object -ExpandProperty Path

$script:Failures = @()
$script:Warnings = @()

function Report {
    param([string]$Status, [string]$Check, [string]$Detail = "")
    $icon = switch ($Status) { "OK" { "[OK]" } "WARN" { "[WARN]" } "FAIL" { "[FAIL]" } }
    $color = switch ($Status) { "OK" { "Green" } "WARN" { "Yellow" } "FAIL" { "Red" } }
    $line = "  $icon $Check"
    if ($Detail) { $line += " - $Detail" }
    Write-Host $line -ForegroundColor $color
    if ($Status -eq "FAIL") { $script:Failures += "$Check - $Detail" }
    if ($Status -eq "WARN") { $script:Warnings += "$Check - $Detail" }
}

function Get-VersionFromFile {
    param([string]$FilePath, [string]$Pattern)
    if (-not (Test-Path $FilePath)) { return $null }
    $match = [regex]::Match((Get-Content $FilePath -Raw -Encoding UTF8), $Pattern)
    if (-not $match.Success) { return $null }
    return $match.Groups[1].Value
}

Write-Host "=== ChurchTools Suite - Release-Check ===" -ForegroundColor Cyan
Write-Host ""

# Plugin-Definitionen: Name, Pfad, Hauptdatei, Versions-Konstante
$plugins = @(
    @{ Name = "churchtools-suite"; Dir = $SuiteRoot; Main = "churchtools-suite.php"; Const = "CHURCHTOOLS_SUITE_VERSION" },
    @{ Name = "churchtools-suite-elementor"; Dir = (Join-Path $WorkspaceRoot "churchtools-suite-elementor"); Main = "churchtools-suite-elementor.php"; Const = "CTS_ELEMENTOR_VERSION" },
    @{ Name = "churchtools-suite-posts-sync"; Dir = (Join-Path $WorkspaceRoot "churchtools-suite-posts-sync"); Main = "churchtools-suite-posts-sync.php"; Const = "CTS_POSTS_SYNC_VERSION" },
    @{ Name = "churchtools-suite-presentations"; Dir = (Join-Path $WorkspaceRoot "churchtools-suite-presentations"); Main = "churchtools-suite-presentations.php"; Const = "CTS_PRESENTATIONS_VERSION" }
)

$versions = @{}

foreach ($p in $plugins) {
    $mainFile = Join-Path $p.Dir $p.Main
    Write-Host "--- $($p.Name) ---" -ForegroundColor White

    if (-not (Test-Path $mainFile)) {
        Report "WARN" "$($p.Name): Hauptdatei fehlt" $mainFile
        continue
    }

    # 1. Header-Version vs. Konstante
    $headerVersion = Get-VersionFromFile $mainFile "\*\s*Version:\s*([0-9][0-9.]*)"
    $constVersion = Get-VersionFromFile $mainFile ("define\(\s*'" + $p.Const + "'\s*,\s*'([^']+)'\s*\)")
    $versions[$p.Name] = $constVersion

    if (-not $headerVersion -or -not $constVersion) {
        Report "FAIL" "$($p.Name): Version nicht lesbar" "Header=$headerVersion Const=$constVersion"
    } elseif ($headerVersion -ne $constVersion) {
        Report "FAIL" "$($p.Name): Version uneinheitlich" "Header=$headerVersion, Konstante=$constVersion"
    } else {
        Report "OK" "$($p.Name): Version einheitlich" $constVersion
    }

    # 2. Git-Arbeitsbaum sauber?
    if (Test-Path (Join-Path $p.Dir ".git")) {
        $dirty = git -C $p.Dir status --porcelain 2>$null
        if ($dirty) {
            $detail = ($dirty | Select-Object -First 3) -join "; "
            Report "WARN" "$($p.Name): uncommitted Aenderungen" $detail
        } else {
            Report "OK" "$($p.Name): Arbeitsbaum sauber"
        }

        # 3. Tag v<Version> vorhanden und auf HEAD?
        if ($constVersion) {
            $tagRef = git -C $p.Dir rev-parse --verify --quiet "refs/tags/v$constVersion" 2>$null
            if (-not $tagRef) {
                Report "WARN" "$($p.Name): Tag v$constVersion fehlt"
            } else {
                $head = git -C $p.Dir rev-parse HEAD 2>$null
                if ($tagRef.Trim() -eq $head.Trim()) {
                    Report "OK" "$($p.Name): Tag v$constVersion zeigt auf HEAD"
                } else {
                    Report "WARN" "$($p.Name): Tag v$constVersion zeigt nicht auf HEAD"
                }
            }
        }
    } else {
        Report "WARN" "$($p.Name): kein Git-Repository"
    }
}

# 4. ZIP-Prüfung (optional)
if ($ZipDir -ne "") {
    Write-Host ""
    Write-Host "--- ZIP-Prüfung: $ZipDir ---" -ForegroundColor White

    $junkPatterns = @(".git/", "node_modules/", ".github/", "*.ps1", "*.backup*", "test-logs.php")

    foreach ($p in $plugins) {
        $ver = $versions[$p.Name]
        if (-not $ver) { continue }
        $zip = Join-Path $SuiteRoot (Join-Path $ZipDir "$($p.Name)-$ver.zip")
        if (-not (Test-Path $zip)) {
            Report "WARN" "$($p.Name)-$ver.zip nicht gefunden" $zip
            continue
        }

        $tmp = Join-Path $env:TEMP ("cts-zipcheck-" + [guid]::NewGuid().ToString("N"))
        try {
            Expand-Archive -Path $zip -DestinationPath $tmp -Force
            $zipMain = Get-ChildItem -Path $tmp -Recurse -Filter $p.Main | Select-Object -First 1
            if (-not $zipMain) {
                Report "FAIL" "$($p.Name)-$ver.zip" "Hauptdatei fehlt im ZIP"
            } else {
                $zipVersion = Get-VersionFromFile $zipMain.FullName "\*\s*Version:\s*([0-9][0-9.]*)"
                if ($zipVersion -ne $ver) {
                    Report "FAIL" "$($p.Name)-$ver.zip" "ZIP enthaelt Version $zipVersion"
                } else {
                    Report "OK" "$($p.Name)-$ver.zip" "Version stimmt"
                }
            }

            $entries = Get-ChildItem -Path $tmp -Recurse -File | ForEach-Object { $_.FullName.Substring($tmp.Length + 1) }
            $junk = $entries | Where-Object { $e = $_; $junkPatterns | Where-Object { $e -like "*$_*" -or $e -like $_ } }
            if ($junk) {
                $junkList = ($junk | Select-Object -First 5) -join "; "
                Report "WARN" "$($p.Name)-$ver.zip: Dev-Dateien im ZIP" $junkList
            }
        } finally {
            Remove-Item $tmp -Recurse -Force -ErrorAction SilentlyContinue
        }
    }
}

Write-Host ""
Write-Host "=== Ergebnis ===" -ForegroundColor Cyan
if ($script:Failures.Count -eq 0 -and $script:Warnings.Count -eq 0) {
    Write-Host "  Alle Checks bestanden." -ForegroundColor Green
    exit 0
} else {
    $summaryColor = "Yellow"
    if ($script:Failures.Count -gt 0) { $summaryColor = "Red" }
    Write-Host "  $($script:Failures.Count) Fehler, $($script:Warnings.Count) Warnungen" -ForegroundColor $summaryColor
}
exit $(if ($script:Failures.Count -gt 0) { 1 } else { 0 })
