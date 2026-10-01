[CmdletBinding()]
param(
    [string]$RootDirectory,

    [ValidateSet('b11269')]
    [string]$Version = 'b11269'
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

if ([string]::IsNullOrWhiteSpace($RootDirectory)) {
    $RootDirectory = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
}

# Pinned official release, installed in its own immutable directory.
$releases = @{
    b11269 = @{
        Commit = 'cee37ffea'
        Sha256 = '79e8431306e0d5dad9f7d429272226387d449a167d3e9285cdf0ec0edce8b27e'
    }
}
$versionNumber = $Version.Substring(1)
$commitPrefix = $releases[$Version].Commit
$runtimeDirectory = Join-Path $RootDirectory "runtimes\llama.cpp\$Version-cuda13.4"
$packageDirectory = Join-Path $RootDirectory "packages\llama.cpp\$Version"

$assets = @(
    @{
        Name = "llama-$Version-bin-win-cuda-13.4-x64.zip"
        Url = "https://github.com/ggml-org/llama.cpp/releases/download/$Version/llama-$Version-bin-win-cuda-13.4-x64.zip"
        Sha256 = $releases[$Version].Sha256
    },
    @{
        Name = 'cudart-llama-bin-win-cuda-13.4-x64.zip'
        Url = "https://github.com/ggml-org/llama.cpp/releases/download/$Version/cudart-llama-bin-win-cuda-13.4-x64.zip"
        Sha256 = '738f8c251ac22b70c3ae6f83a10cf222725df0395246a2cf58f32bdb85fbe668'
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
$hasExpectedCommit = $versionOutput -match "\b$commitPrefix[0-9a-f]*\b"
if (-not ($hasExpectedBuild -and $hasExpectedCommit)) {
    throw "Unexpected llama-server version. Expected $version at $commitPrefix. Output: $versionOutput"
}

Write-Host $versionOutput
Write-Host "Installed verified llama.cpp $version runtime at $runtimeDirectory"
