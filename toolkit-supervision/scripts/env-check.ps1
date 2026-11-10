# Résolution du chemin relatif par rapport au script en cours d'exécution
$CONF = Join-Path $PSScriptRoot "..\config\toolkit.conf"

# Chargement du fichier de configuration (équivalent du 'source')
if (Test-Path $CONF) {
    Get-Content $CONF | ForEach-Object {
        $line = $_.Trim()
        # Ignore les commentaires (#) et les lignes vides
        if ($line -and -not $line.StartsWith('#') -and $line -match '^([^=]+)=(.*)$') {
            $varName = $matches[1].Trim()
            # Nettoie d'éventuels guillemets entourant la valeur
            $varValue = $matches[2].Trim(" `"'")
            Set-Variable -Name $varName -Value $varValue -Scope Script
        }
    }
} else {
    Write-Warning "Fichier de configuration introuvable : $CONF"
}

# Affichage avec interpolation de chaînes
Write-Host "Serveur : svr-lab-01"
Write-Host "Date : $(Get-Date -Format 'yyyy-MM-dd HH:mm')"
Write-Host "Rapports : $REPORT_DIR"
Write-Host "Seuil disque : 80%"