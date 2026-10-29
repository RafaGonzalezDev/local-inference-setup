[CmdletBinding()]
param(
    [string]$RootDirectory,

    [ValidateSet('b11269', 'b11551', 'b11669', 'b11827', 'b11981')]
    [string]$Version = 'b11551'
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
    # Nightly build that first contains MiniCPM-V 4.7 support (merge 69f201a, PR #29416).
    b11551 = @{
        Commit = '69f201a'
        Sha256 = '80c5f94fe5ecd8090fe682c89861a949efb4a3487782cfcd99252a18f571afc7'
    }
    # Build behind the v0.7.0 stable release (nightly-tag.txt of v0.7.0); installable but unused since 2026-10-28.
    b11669 = @{
        Commit = '620d222'
        Sha256 = '3b92d5c064f5032e603e531d3ec8961f3bd6613e5dfad047399a92dec8e95dbc'
    }
    # Nightly build after Flint support (PR #30928) and Jinja hex escapes (PR #30929).
    b11827 = @{
        Commit = '970b51c'
        Sha256 = '5d54c5fa2f26d9c80fa7439692e5929e8f7f1e7b2d00e3d6ab5a919154c768fa'
    }
    # Nightly build after v0.8.0 (b11960) with LFM3 text, VL, Audio and Omni support (PR #31252, #31257, #31283).
    b11981 = @{
        Commit = 'da6c30a'
        Sha256 = 'b160dff6e5d74855eda001261299b5fc1f4db714080f04c35f3a5c8c696c9691'
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
