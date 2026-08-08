[CmdletBinding()]
param(
    [string]$Model = 'all',
    [string]$RootDirectory
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

if ([string]::IsNullOrWhiteSpace($RootDirectory)) {
    $RootDirectory = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
}

$catalog = Import-PowerShellDataFile -Path (Join-Path $RootDirectory 'config\catalog.psd1')
$modelIds = @($catalog.Models)

if ($Model -ne 'all') {
    if ($modelIds -notcontains $Model) {
        throw "Unknown model '$Model'. Valid models: $($modelIds -join ', ')"
    }
    $modelIds = @($Model)
}

$results = New-Object 'System.Collections.Generic.List[object]'

foreach ($modelId in $modelIds) {
    $modelConfig = Import-PowerShellDataFile -Path (Join-Path $RootDirectory ("config\models\{0}.psd1" -f $modelId))
    $modelDirectory = Join-Path $RootDirectory $modelConfig.RelativeDirectory

    foreach ($artifact in $modelConfig.Artifacts) {
        $filePath = Join-Path $modelDirectory $artifact.File
        $status = 'Missing'
        $actualHash = ''

        if (Test-Path -LiteralPath $filePath -PathType Leaf) {
            $actualSize = (Get-Item -LiteralPath $filePath).Length
            if ($actualSize -ne [long]$artifact.Size) {
                $status = 'InvalidSize'
            }
            else {
                Write-Host "Hashing $filePath..."
                $actualHash = (Get-FileHash -LiteralPath $filePath -Algorithm SHA256).Hash.ToLowerInvariant()
                $status = if ($actualHash -eq $artifact.Sha256) { 'Passed' } else { 'InvalidHash' }
            }
        }

        $results.Add([pscustomobject]@{
            Model = $modelId
            File = $artifact.File
            Status = $status
            ExpectedHash = $artifact.Sha256
            ActualHash = $actualHash
        })
    }
}

$results | Format-Table Model, File, Status -AutoSize
$failedResults = @($results | Where-Object { $_.Status -ne 'Passed' })
if ($failedResults.Count -gt 0) {
    throw "$($failedResults.Count) model integrity check(s) failed."
}

Write-Host "All $($results.Count) model integrity checks passed."
