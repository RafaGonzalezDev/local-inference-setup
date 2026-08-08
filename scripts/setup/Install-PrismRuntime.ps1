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

$release = 'prism-b9599-9ca265a'
$commitPrefix = '9ca265a'
$runtimeDirectory = Join-Path $rootDirectory 'runtimes\llama.cpp\prism-b9599-9ca265a-cuda12.4'
$packageDirectory = Join-Path $rootDirectory "packages\llama.cpp\$release"
$curlPath = (Get-Command 'curl.exe' -ErrorAction Stop).Source

$assets = @(
    @{
        Name = 'llama-prism-b1-9ca265a-bin-win-cuda-12.4-x64.zip'
        Url = 'https://github.com/PrismML-Eng/llama.cpp/releases/download/prism-b9599-9ca265a/llama-prism-b1-9ca265a-bin-win-cuda-12.4-x64.zip'
        Sha256 = 'd6b473338a05a56b815044a7a02caeea04942bb6dda8b8de019a9a5252c6f50a'
    },
    @{
        Name = 'cudart-llama-bin-win-cuda-12.4-x64.zip'
        Url = 'https://github.com/PrismML-Eng/llama.cpp/releases/download/prism-b9599-9ca265a/cudart-llama-bin-win-cuda-12.4-x64.zip'
        Sha256 = '8c79a9b226de4b3cacfd1f83d24f962d0773be79f1e7b75c6af4ded7e32ae1d6'
    }
)

New-Item -ItemType Directory -Path $runtimeDirectory -Force | Out-Null
New-Item -ItemType Directory -Path $packageDirectory -Force | Out-Null

foreach ($asset in $assets) {
    $packagePath = Join-Path $packageDirectory $asset.Name
    $partialPath = "$packagePath.partial"

    if (Test-Path -LiteralPath $packagePath -PathType Leaf) {
        $existingHash = (Get-FileHash -LiteralPath $packagePath -Algorithm SHA256).Hash.ToLowerInvariant()
        if ($existingHash -ne $asset.Sha256) {
            throw "Existing package has an invalid SHA-256 hash: $packagePath"
        }
        Write-Host "Using verified package: $($asset.Name)"
    }
    else {
        Write-Host "Downloading $($asset.Name)..."
        $arguments = @('--location', '--fail', '--retry', '3', '--continue-at', '-', '--output', $partialPath, $asset.Url)
        $process = Start-Process -FilePath $curlPath -ArgumentList $arguments -NoNewWindow -Wait -PassThru
        if ($process.ExitCode -ne 0) {
            throw "curl failed with exit code $($process.ExitCode) while downloading $($asset.Name)"
        }
        $downloadedHash = (Get-FileHash -LiteralPath $partialPath -Algorithm SHA256).Hash.ToLowerInvariant()
        if ($downloadedHash -ne $asset.Sha256) {
            throw "Downloaded package has an invalid SHA-256 hash: $partialPath"
        }
        Move-Item -LiteralPath $partialPath -Destination $packagePath
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
if ($versionOutput -notmatch $commitPrefix) {
    throw "Unexpected PrismML llama-server commit. Expected $commitPrefix. Output: $versionOutput"
}

Write-Host $versionOutput
Write-Host "Installed verified PrismML llama.cpp $release runtime at $runtimeDirectory"
