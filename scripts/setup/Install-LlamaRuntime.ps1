[CmdletBinding()]
param(
    [string]$RootDirectory
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

if ([string]::IsNullOrWhiteSpace($RootDirectory)) {
    $RootDirectory = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
}

$version = 'b10502'
$versionNumber = '10502'
$commitPrefix = '0adcc3bb5'
$runtimeDirectory = Join-Path $rootDirectory 'runtimes\llama.cpp\b10502-cuda13.3'
$packageDirectory = Join-Path $rootDirectory 'packages\llama.cpp\b10502'

$assets = @(
    @{
        Name = 'llama-b10502-bin-win-cuda-13.3-x64.zip'
        Url = 'https://github.com/ggml-org/llama.cpp/releases/download/b10502/llama-b10502-bin-win-cuda-13.3-x64.zip'
        Sha256 = '657ad104b7c2f3aaf9abac91b48ffb72a2556cb8a6a38d395eaaf64bc1f1f719'
    },
    @{
        Name = 'cudart-llama-bin-win-cuda-13.3-x64.zip'
        Url = 'https://github.com/ggml-org/llama.cpp/releases/download/b10502/cudart-llama-bin-win-cuda-13.3-x64.zip'
        Sha256 = '1462a050eb4c684921ba51dcc4cc488a036674c3e73e9945ee705b854808d03e'
    }
)

New-Item -ItemType Directory -Path $runtimeDirectory -Force | Out-Null
New-Item -ItemType Directory -Path $packageDirectory -Force | Out-Null

foreach ($asset in $assets) {
    $packagePath = Join-Path $packageDirectory $asset.Name

    if (Test-Path -LiteralPath $packagePath -PathType Leaf) {
        $existingHash = (Get-FileHash -LiteralPath $packagePath -Algorithm SHA256).Hash.ToLowerInvariant()
        if ($existingHash -ne $asset.Sha256) {
            throw "Existing package has an invalid SHA-256 hash: $packagePath"
        }
        Write-Host "Using verified package: $($asset.Name)"
    }
    else {
        Write-Host "Downloading $($asset.Name)..."
        Invoke-WebRequest -Uri $asset.Url -OutFile $packagePath -UseBasicParsing
        $downloadedHash = (Get-FileHash -LiteralPath $packagePath -Algorithm SHA256).Hash.ToLowerInvariant()
        if ($downloadedHash -ne $asset.Sha256) {
            throw "Downloaded package has an invalid SHA-256 hash: $packagePath"
        }
    }

    Write-Host "Extracting $($asset.Name)..."
    Expand-Archive -LiteralPath $packagePath -DestinationPath $runtimeDirectory -Force
}

$serverPath = Join-Path $runtimeDirectory 'llama-server.exe'
if (-not (Test-Path -LiteralPath $serverPath -PathType Leaf)) {
    throw "The release archives did not produce the expected executable: $serverPath"
}

$versionStdoutPath = Join-Path $packageDirectory 'llama-server-version.stdout.txt'
$versionStderrPath = Join-Path $packageDirectory 'llama-server-version.stderr.txt'
$versionProcess = Start-Process -FilePath $serverPath -ArgumentList @('--version') -WorkingDirectory $runtimeDirectory -RedirectStandardOutput $versionStdoutPath -RedirectStandardError $versionStderrPath -Wait -PassThru
$versionOutput = @(
    (Get-Content -LiteralPath $versionStdoutPath -Raw -ErrorAction SilentlyContinue),
    (Get-Content -LiteralPath $versionStderrPath -Raw -ErrorAction SilentlyContinue)
) -join [Environment]::NewLine
$versionOutput = $versionOutput.Trim()

if ($versionProcess.ExitCode -ne 0) {
    throw "llama-server --version exited with code $($versionProcess.ExitCode). Output: $versionOutput"
}
$hasExpectedBuild = (
    $versionOutput -match "version:\s*$versionNumber\s+\(" -or
    $versionOutput -match "build\s+$versionNumber\b"
)
$hasExpectedCommit = $versionOutput -match "\b$commitPrefix\b"
if (-not ($hasExpectedBuild -and $hasExpectedCommit)) {
    throw "Unexpected llama-server version. Expected $version at $commitPrefix. Output: $versionOutput"
}

Write-Host $versionOutput
Write-Host "Installed verified llama.cpp $version runtime at $runtimeDirectory"
