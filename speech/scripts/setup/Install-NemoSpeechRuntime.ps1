[CmdletBinding()]
param(
    [string]$RootDirectory,

    [ValidateSet('0.3.0', 'nightly-e790e46')]
    [string]$Version = 'nightly-e790e46'
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

if ([string]::IsNullOrWhiteSpace($RootDirectory)) {
    # speech\scripts\setup -> D:\LLM
    $RootDirectory = Split-Path -Parent (Split-Path -Parent (Split-Path -Parent $PSScriptRoot))
}

# Pinned official NVIDIA release, installed in its own immutable directory.
$releases = @{
    # Tag v0.3.0 -> commit 20999cc921d2b14aa58708f61756a8b2e787ba20; first release with SALM (Nemotron 3.5 Transcribe).
    '0.3.0' = @{
        Tag = 'v0.3.0'
        Asset = 'nemo-speech-0.3.0-windows-x86_64-cuda.zip'
        Sha256 = 'd0d32ae1bf6ee0534767a47b2aa0e9e2ff6fe39643465c0baae9301d04f6ed42'
        VersionPattern = '0\.3\.0'
    }
    # Nightly of 2026-11-13 (commit e790e463b2913cff9f989a3df224c587f14b4c5c): first build with
    # asr.salm.n_cpu_moe, which keeps experts in system RAM on a 16 GB GPU. The nightly tag moves,
    # so the archive kept under packages\ is the only reinstallable copy once a newer nightly replaces it.
    'nightly-e790e46' = @{
        Tag = 'nightly'
        Asset = 'nemo-speech-nightly-windows-x86_64-cuda.zip'
        Sha256 = '17a54013679473eb6bdafe23217ff3ed253cb4e6475812e056a688e65892d8dc'
        VersionPattern = '0\.3\.0\+nightly\.e790e46'
    }
}

$release = $releases[$Version]
$assetName = $release.Asset
$url = "https://github.com/NVIDIA/NeMo-Speech.cpp/releases/download/$($release.Tag)/$assetName"
$runtimeDirectory = Join-Path $RootDirectory "runtimes\nemo-speech\$Version-cuda"
$packageDirectory = Join-Path $RootDirectory "packages\nemo-speech\$Version"
$packagePath = Join-Path $packageDirectory $assetName
$expectedHash = $release.Sha256

New-Item -ItemType Directory -Path $packageDirectory -Force | Out-Null

if (Test-Path -LiteralPath $packagePath -PathType Leaf) {
    $existingHash = (Get-FileHash -LiteralPath $packagePath -Algorithm SHA256).Hash.ToLowerInvariant()
    if ($existingHash -ne $expectedHash) {
        throw "Existing package has an invalid SHA-256 hash: $packagePath"
    }
    Write-Host "Using verified package: $assetName"
}
else {
    Write-Host "Downloading $assetName..."
    $partialPath = "$packagePath.partial"
    Invoke-WebRequest -Uri $url -OutFile $partialPath -UseBasicParsing
    $downloadedHash = (Get-FileHash -LiteralPath $partialPath -Algorithm SHA256).Hash.ToLowerInvariant()
    if ($downloadedHash -ne $expectedHash) {
        throw "Downloaded package has an invalid SHA-256 hash: $partialPath"
    }
    Move-Item -LiteralPath $partialPath -Destination $packagePath
}

if (Test-Path -LiteralPath $runtimeDirectory) {
    throw "Runtime directory already exists and will not be overwritten: $runtimeDirectory"
}

# The archive has one top-level folder; flatten it so the executable sits at a fixed path.
$extractDirectory = Join-Path $packageDirectory 'extract'
if (Test-Path -LiteralPath $extractDirectory) { Remove-Item -LiteralPath $extractDirectory -Recurse -Force }
Expand-Archive -LiteralPath $packagePath -DestinationPath $extractDirectory
$executable = Get-ChildItem -LiteralPath $extractDirectory -Recurse -Filter 'nemo-speech.exe' | Select-Object -First 1
if ($null -eq $executable) {
    throw "The release archive did not contain nemo-speech.exe"
}
$binDirectory = $executable.DirectoryName
$archiveRoot = if ((Split-Path -Leaf $binDirectory) -eq 'bin') { Split-Path -Parent $binDirectory } else { $binDirectory }
New-Item -ItemType Directory -Path (Split-Path -Parent $runtimeDirectory) -Force | Out-Null
Move-Item -LiteralPath $archiveRoot -Destination $runtimeDirectory
Remove-Item -LiteralPath $extractDirectory -Recurse -Force -ErrorAction SilentlyContinue

$serverPath = Get-ChildItem -LiteralPath $runtimeDirectory -Recurse -Filter 'nemo-speech.exe' | Select-Object -First 1
$versionOutput = (& $serverPath.FullName --version 2>&1 | Out-String).Trim()
if ($LASTEXITCODE -ne 0) {
    throw "nemo-speech --version exited with code $LASTEXITCODE. Output: $versionOutput"
}
if ($versionOutput -notmatch $release.VersionPattern) {
    throw "Unexpected nemo-speech version. Expected $Version. Output: $versionOutput"
}

Write-Host $versionOutput
Write-Host "Installed verified NeMo-Speech.cpp $Version runtime at $($serverPath.FullName)"
