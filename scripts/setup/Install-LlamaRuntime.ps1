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

$version = 'b10273'
$versionNumber = '10273'
$commitPrefix = 'a6aa6f545'
$runtimeDirectory = Join-Path $rootDirectory 'runtimes\llama.cpp\b10273-cuda13.3'
$packageDirectory = Join-Path $rootDirectory 'packages\llama.cpp\b10273'

$assets = @(
    @{
        Name = 'llama-b10273-bin-win-cuda-13.3-x64.zip'
        Url = 'https://github.com/ggml-org/llama.cpp/releases/download/b10273/llama-b10273-bin-win-cuda-13.3-x64.zip'
        Sha256 = '2354c37455b4371145589d87cdd468a19c1fe6420649aaec3cf3ed68b20a61c6'
    },
    @{
        Name = 'cudart-llama-bin-win-cuda-13.3-x64.zip'
        Url = 'https://github.com/ggml-org/llama.cpp/releases/download/b10273/cudart-llama-bin-win-cuda-13.3-x64.zip'
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
if ($versionOutput -notmatch "version:\s*$versionNumber\s+\($commitPrefix" ) {
    throw "Unexpected llama-server version. Expected $version at $commitPrefix. Output: $versionOutput"
}

Write-Host $versionOutput
Write-Host "Installed verified llama.cpp $version runtime at $runtimeDirectory"
