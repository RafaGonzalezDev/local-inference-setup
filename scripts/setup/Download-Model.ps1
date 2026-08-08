[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [ValidatePattern('^[a-z0-9][a-z0-9._-]+$')]
    [string]$Model,

    [string]$RootDirectory
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

if ([string]::IsNullOrWhiteSpace($RootDirectory)) {
    $RootDirectory = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
}

$catalog = Import-PowerShellDataFile -Path (Join-Path $RootDirectory 'config\catalog.psd1')
if ($catalog.Models -notcontains $Model) {
    throw "Unknown model '$Model'. Valid models: $($catalog.Models -join ', ')"
}

$modelConfig = Import-PowerShellDataFile -Path (Join-Path $RootDirectory ("config\models\{0}.psd1" -f $Model))
$modelDirectory = Join-Path $RootDirectory $modelConfig.RelativeDirectory
$curlPath = (Get-Command 'curl.exe' -ErrorAction Stop).Source

foreach ($artifact in $modelConfig.Artifacts) {
    $destinationPath = Join-Path $modelDirectory $artifact.File
    $destinationDirectory = Split-Path -Parent $destinationPath
    $partialPath = "$destinationPath.partial"
    New-Item -ItemType Directory -Path $destinationDirectory -Force | Out-Null

    if (Test-Path -LiteralPath $destinationPath -PathType Leaf) {
        $existingSize = (Get-Item -LiteralPath $destinationPath).Length
        if ($existingSize -ne [long]$artifact.Size) {
            throw "Existing artifact has an unexpected size and will not be overwritten: $destinationPath"
        }

        $existingHash = (Get-FileHash -LiteralPath $destinationPath -Algorithm SHA256).Hash.ToLowerInvariant()
        if ($existingHash -ne $artifact.Sha256) {
            throw "Existing artifact has an invalid hash and will not be overwritten: $destinationPath"
        }

        Write-Host "Using verified artifact: $destinationPath"
        continue
    }

    $escapedRemoteFile = ($artifact.RemoteFile -split '/' | ForEach-Object { [Uri]::EscapeDataString($_) }) -join '/'
    $url = "https://huggingface.co/$($artifact.Repository)/resolve/$($artifact.Revision)/$escapedRemoteFile`?download=true"
    Write-Host "Downloading $($artifact.File) from pinned revision $($artifact.Revision)..."

    $arguments = @('--location', '--fail', '--retry', '3', '--continue-at', '-', '--output', $partialPath, $url)
    $process = Start-Process -FilePath $curlPath -ArgumentList $arguments -NoNewWindow -Wait -PassThru
    if ($process.ExitCode -ne 0) {
        throw "curl failed with exit code $($process.ExitCode) while downloading $($artifact.File)"
    }

    $downloadedSize = (Get-Item -LiteralPath $partialPath).Length
    if ($downloadedSize -ne [long]$artifact.Size) {
        throw "Downloaded artifact has an unexpected size: $partialPath"
    }

    $downloadedHash = (Get-FileHash -LiteralPath $partialPath -Algorithm SHA256).Hash.ToLowerInvariant()
    if ($downloadedHash -ne $artifact.Sha256) {
        throw "Downloaded artifact has an invalid hash: $partialPath"
    }

    Move-Item -LiteralPath $partialPath -Destination $destinationPath
    Write-Host "Installed verified artifact: $destinationPath"
}
