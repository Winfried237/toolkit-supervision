# Archive un repertoire et ecrit un rapport dans le dossier de rapports

# 1. Chargement de la configuration
$CONF = Join-Path $PSScriptRoot "..\config\toolkit.conf"

if (Test-Path $CONF) {
    Get-Content $CONF | ForEach-Object {
        $line = $_.Trim()
        if ($line -and -not $line.StartsWith('#') -and $line -match '^([^=]+)=(.*)$') {
            $varName = $matches[1].Trim()
            $varValue = $matches[2].Trim(" `"'")
            Set-Variable -Name $varName -Value $varValue -Scope Script
        }
    }
} else {
    Write-Warning "Fichier de configuration introuvable : $CONF"
}

# 2. Paramètre source avec valeur par défaut 'config'
$SOURCE = if ($args[0]) { $args[0] } else { "config" }

# 3. Création du dossier de rapports (équivalent de mkdir -p)
if (-not (Test-Path -Path $REPORT_DIR)) {
    New-Item -ItemType Directory -Path $REPORT_DIR -Force | Out-Null
}

# 4. Définition du chemin de l'archive ZIP
$timestamp = Get-Date -Format 'yyyyMMdd-HHmm'
$ARCHIVE = Join-Path $REPORT_DIR "backup-$timestamp.zip"

# 5. Création de l'archive (équivalent tar -czf avec suppression d'erreur)
try {
    Compress-Archive -Path $SOURCE -DestinationPath $ARCHIVE -Force -ErrorAction SilentlyContinue
} catch {
    # Ignorer les erreurs silencieuses comme 2>/dev/null
}

# 6. Calcul de la taille de l'archive générée (équivalent du du -h)
$fileSize = "0 Ko"
if (Test-Path $ARCHIVE) {
    $bytes = (Get-Item $ARCHIVE).Length
    if ($bytes -ge 1GB) {
        $fileSize = "$([math]::Round($bytes / 1GB, 2)) Go"
    } elseif ($bytes -ge 1MB) {
        $fileSize = "$([math]::Round($bytes / 1MB, 2)) Mo"
    } else {
        $fileSize = "$([math]::Round($bytes / 1KB, 2)) Ko"
    }
}

# 7. Écriture du rapport dans le fichier cible
$REPORT_FILE = Join-Path $REPORT_DIR "backup-report.$REPORT_FORMAT"
@"
Serveur : $SERVER_NAME
Source  : $SOURCE
Archive : $ARCHIVE
Taille  : $fileSize
"@ | Set-Content -Path $REPORT_FILE -Encoding utf8

Write-Host "Rapport ecrit dans $REPORT_FILE"