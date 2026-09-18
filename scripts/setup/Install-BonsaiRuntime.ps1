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

# The ternary (PQ2_0, PTQ1_0) and hybrid-attention kernels required by the
# Ternary-Bonsai models live in the PrismML fork of llama.cpp. The official
# build rejects those quantization types or produces invalid output, so this
# runtime is installed in its own immutable directory and never shares DLLs
# with the official runtime.
$release = 'prism-b10685-7dffb15'
$buildNumber = '10685'
$commitPrefix = '7dffb158'
$runtimeDirectory = Join-Path $RootDirectory 'runtimes\llama.cpp\prism-b10685-7dffb15-cuda13.3'
$packageDirectory = Join-Path $RootDirectory 'packages\llama.cpp\prism-b10685-7dffb15'

$assets = @(
    @{
        Name = 'llama-prism-b10685-7dffb15-bin-win-cuda-13.3-x64.zip'
        Url = 'https://github.com/PrismML-Eng/llama.cpp/releases/download/prism-b10685-7dffb15/llama-prism-b10685-7dffb15-bin-win-cuda-13.3-x64.zip'
        Sha256 = '0b0e44045b0b55bb892c5afa8fd4c988194c47c02967ff1da55cd01c0c8eda69'
    }
    @{
        Name = 'cudart-llama-bin-win-cuda-13.3-x64.zip'
        Url = 'https://github.com/PrismML-Eng/llama.cpp/releases/download/prism-b10685-7dffb15/cudart-llama-bin-win-cuda-13.3-x64.zip'
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
    # Some fork archives place the binaries under a top-level directory.
    $nestedServer = Get-ChildItem -LiteralPath $runtimeDirectory -Filter 'llama-server.exe' -File -Recurse |
        Select-Object -First 1
    if ($nestedServer) {
        $nestedDirectory = Split-Path -Parent $nestedServer.FullName
        Write-Host "Flattening $nestedDirectory into $runtimeDirectory..."
        Get-ChildItem -LiteralPath $nestedDirectory -Force | Move-Item -Destination $runtimeDirectory -Force
    }
}
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

# The fork reports its own release line, for example
# "version: 0.2.0-dev (build 10685, commit 7dffb158d)". Accept either the
# explicit release tag or the pinned build number together with the commit.
$hasReleaseTag = $versionOutput -match [regex]::Escape($release)
$hasExpectedBuild = (
    $versionOutput -match "version:\s*$buildNumber\s+\(" -or
    $versionOutput -match "build\s+$buildNumber\b"
)
$hasExpectedCommit = $versionOutput -match [regex]::Escape($commitPrefix)
if (-not ($hasReleaseTag -or ($hasExpectedBuild -and $hasExpectedCommit))) {
    throw "Unexpected llama-server version. Expected $release at $commitPrefix. Output: $versionOutput"
}

Write-Host $versionOutput
Write-Host "Installed verified PrismML llama.cpp $release runtime at $runtimeDirectory"
