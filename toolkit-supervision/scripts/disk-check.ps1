# Compare l'utilisation du disque au seuil defini dans la configuration

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
}

# Calcul du pourcentage d'utilisation du disque système (C:)
$drive = Get-PSDrive C
$USAGE = [math]::Round((($drive.Used / ($drive.Used + $drive.Free)) * 100))

Write-Host "Utilisation de C: : ${USAGE}%  (seuil : ${DISK_THRESHOLD}%)"

if ([int]$USAGE -gt [int]$DISK_THRESHOLD) {
    Write-Host "ALERTE : seuil depasse"
} else {