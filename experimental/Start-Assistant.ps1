#Requires -Version 7
[CmdletBinding()]
param(
    # File name inside experimental\instructions; the .md extension is optional.
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$Instructions
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# Must match the NETWORK_ARGS of the launcher.
$launcherPath = Join-Path $PSScriptRoot 'scripts\models\lfm3-1.7b-uncensored\start-agentic-cpu-32k-1024.cmd'
$port = 8081
$baseUrl = "http://127.0.0.1:$port"
$modelAlias = 'lfm3-1.7b-uncensored'
$startupTimeoutSeconds = 300

$instructionsDirectory = Join-Path $PSScriptRoot 'instructions'
$fileName = if ([IO.Path]::GetExtension($Instructions)) { $Instructions } else { "$Instructions.md" }
$instructionsPath = [IO.Path]::GetFullPath((Join-Path $instructionsDirectory $fileName))
# Only files directly inside the instructions folder are accepted.
if ((Split-Path -Parent $instructionsPath) -ne $instructionsDirectory -or -not (Test-Path -LiteralPath $instructionsPath -PathType Leaf)) {
    $available = (Get-ChildItem -LiteralPath $instructionsDirectory -File).BaseName -join ', '
    throw "Instructions file '$Instructions' was not found in $instructionsDirectory. Available: $available"
}
$systemPrompt = (Get-Content -LiteralPath $instructionsPath -Raw -Encoding utf8).Trim()
if (-not $systemPrompt) {
    throw "Instructions file is empty: $instructionsPath"
}

# Never attach to a server this utility did not start.
if (Get-NetTCPConnection -LocalPort $port -State Listen -ErrorAction SilentlyContinue) {
    throw "Port $port is already in use. Stop the process listening on it and try again."
}

$logDirectory = Join-Path $PSScriptRoot 'logs'
New-Item -ItemType Directory -Path $logDirectory -Force | Out-Null
$logPath = Join-Path $logDirectory ("server-{0}.log" -f (Get-Date -Format 'yyyyMMdd-HHmmss'))

$server = $null
try {
    # The server shares this console, so closing the window also ends it; stdin from NUL keeps
    # cmd from waiting on "Terminate batch job" after Ctrl+C.
    $server = Start-Process -FilePath 'cmd.exe' -NoNewWindow -PassThru `
        -ArgumentList "/d /s /c `"`"$launcherPath`" > `"$logPath`" 2>&1 < nul`""

    Write-Host "Loading $modelAlias on CPU (log: $logPath)..."
    $deadline = (Get-Date).AddSeconds($startupTimeoutSeconds)
    while ($true) {
        if ($server.HasExited) {
            throw "Server exited with code $($server.ExitCode). See $logPath"
        }
        try {
            if ((Invoke-WebRequest "$baseUrl/health" -SkipHttpErrorCheck -TimeoutSec 5).StatusCode -eq 200) { break }
        } catch {
            # Not listening yet.
        }
        if ((Get-Date) -gt $deadline) {
            throw "Server was not ready after $startupTimeoutSeconds seconds. See $logPath"
        }
        Start-Sleep -Milliseconds 500
    }

    Write-Host "Ready. Instructions: $fileName. Type a prompt, or /exit to quit."
    while ($true) {
        $prompt = Read-Host "`n>"
        if ($prompt.Trim() -eq '/exit') { break }
        if (-not $prompt.Trim()) { continue }

        $body = @{
            model = $modelAlias
            stream = $false
            messages = @(
                @{ role = 'system'; content = $systemPrompt }
                @{ role = 'user'; content = $prompt }
            )
        } | ConvertTo-Json -Depth 5
        $response = Invoke-RestMethod "$baseUrl/v1/chat/completions" -Method Post `
            -ContentType 'application/json; charset=utf-8' -Body ([Text.Encoding]::UTF8.GetBytes($body))

        $answer = "$($response.choices[0].message.content)".Trim()
        if (-not $answer) {
            Write-Warning "Empty answer (finish reason: $($response.choices[0].finish_reason))."
            continue
        }
        Write-Host ''
        Write-Output $answer
        Set-Clipboard -Value $answer
        Write-Host "`n[Copied to clipboard]" -ForegroundColor DarkGray
    }
} finally {
    if ($server -and -not $server.HasExited) {
        $server.Kill($true)
        $server.WaitForExit()
    }
    if ($server) {
        Write-Host 'Server stopped.'
    }
}
