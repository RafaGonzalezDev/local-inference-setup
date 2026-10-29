[CmdletBinding()]
param(
    # Audio or video file; without it, a file picker opens again after each summary until it is cancelled.
    [string]$Path,

    # English name of the spoken language, as the LFM3 cards expect; 'auto' lets the model detect it.
    [string]$Language = 'Spanish',

    [string]$Server = 'http://127.0.0.1:8080',

    # Start lfm3-omni-2b when no server answers, and stop it when the script ends.
    [switch]$StartServer
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# Long audio loses text in a single request, so it is transcribed in segments of this length.
$segmentSeconds = 30
$summaryPrompt = 'Esta es la transcripción automática de un audio y puede contener palabras mal reconocidas. Escribe en español un resumen de uno o dos párrafos de lo que se dice. No añadas información que no esté en la transcripción.'
$launcherPath = Join-Path $PSScriptRoot 'models\lfm3-omni-2b\start-agentic-auto-omni-32k-1024.cmd'
$logDirectory = Join-Path (Split-Path -Parent $PSScriptRoot) 'logs'

function Get-ServerProps {
    try {
        return Invoke-RestMethod -Uri "$Server/props" -TimeoutSec 5
    }
    catch {
        return $null
    }
}

function Select-AudioFile {
    Add-Type -AssemblyName System.Windows.Forms
    $dialog = New-Object System.Windows.Forms.OpenFileDialog
    $dialog.Title = 'Select an audio or video file to summarize (Cancel to quit)'
    $dialog.Filter = 'Audio and video|*.wav;*.mp3;*.m4a;*.flac;*.ogg;*.opus;*.aac;*.wma;*.webm;*.mp4;*.mkv;*.mov|All files|*.*'
    if ($dialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        return $dialog.FileName
    }
    return $null
}

function Invoke-Chat {
    param([Parameter(Mandatory = $true)] [object[]]$Messages)

    $body = @{ messages = $Messages; max_tokens = 2048 } | ConvertTo-Json -Depth 8 -Compress
    $response = Invoke-RestMethod -Uri "$Server/v1/chat/completions" -Method Post -ContentType 'application/json; charset=utf-8' -Body ([System.Text.Encoding]::UTF8.GetBytes($body)) -TimeoutSec 600
    return "$($response.choices[0].message.content)".Trim()
}

function Get-AudioSummary {
    param([Parameter(Mandatory = $true)] [string]$AudioPath)

    $workDirectory = Join-Path ([System.IO.Path]::GetTempPath()) ("summarize-" + [guid]::NewGuid().ToString('N'))
    New-Item -ItemType Directory -Path $workDirectory | Out-Null
    try {
        # Any input, including the audio track of a video, becomes 16 kHz mono WAV segments.
        $output = & ffmpeg -hide_banner -nostdin -i $AudioPath -vn -ac 1 -ar 16000 -f segment -segment_time $segmentSeconds (Join-Path $workDirectory 'segment-%03d.wav') 2>&1
        if ($LASTEXITCODE -ne 0) {
            throw "ffmpeg could not read ${AudioPath}: $($output | Select-Object -Last 3 | Out-String)"
        }

        $asrPrompt = if ($Language -eq 'auto') { 'Perform ASR.' } else { "Perform ASR in $Language." }
        $segments = @(Get-ChildItem -LiteralPath $workDirectory -Filter 'segment-*.wav' | Sort-Object Name)
        $texts = for ($i = 0; $i -lt $segments.Count; $i++) {
            Write-Progress -Activity "Summarizing $(Split-Path -Leaf $AudioPath)" -Status "Transcribing segment $($i + 1) of $($segments.Count)" -PercentComplete (100 * $i / ($segments.Count + 1))
            Invoke-Chat -Messages @(
                @{ role = 'system'; content = $asrPrompt }
                @{ role = 'user'; content = @(@{ type = 'input_audio'; input_audio = @{ data = [Convert]::ToBase64String([System.IO.File]::ReadAllBytes($segments[$i].FullName)); format = 'wav' } }) }
            )
        }

        Write-Progress -Activity "Summarizing $(Split-Path -Leaf $AudioPath)" -Status 'Writing the summary' -PercentComplete (100 * $segments.Count / ($segments.Count + 1))
        $summary = Invoke-Chat -Messages @(
            @{ role = 'system'; content = $summaryPrompt }
            @{ role = 'user'; content = ($texts -join ' ') }
        )
        Write-Progress -Activity 'Summarizing' -Completed
        return $summary
    }
    finally {
        Remove-Item -LiteralPath $workDirectory -Recurse -Force -ErrorAction SilentlyContinue
    }
}

if (-not (Get-Command 'ffmpeg' -ErrorAction SilentlyContinue)) {
    throw 'ffmpeg was not found in PATH.'
}

$serverProcess = $null
try {
    $props = Get-ServerProps
    if (-not $props) {
        if (-not $StartServer) {
            throw "No llama-server answered at $Server. Start lfm3-omni-2b or lfm3-audio-2b from experimental\lfm3\scripts\models first, or use -StartServer."
        }
        Write-Host 'Starting lfm3-omni-2b...'
        # Same console, no new window: closing the window also ends the server.
        $serverProcess = Start-Process -FilePath $env:ComSpec -ArgumentList ('/d /s /c ""{0}""' -f $launcherPath) -NoNewWindow -PassThru `
            -RedirectStandardOutput (Join-Path $logDirectory 'summary-server.stdout.log') `
            -RedirectStandardError (Join-Path $logDirectory 'summary-server.stderr.log')
        $deadline = (Get-Date).AddSeconds(180)
        while (-not ($props = Get-ServerProps)) {
            if ($serverProcess.HasExited -or (Get-Date) -gt $deadline) {
                throw "lfm3-omni-2b did not start; see $logDirectory\summary-server.stderr.log"
            }
            Start-Sleep -Seconds 1
        }
    }
    if (-not $props.modalities.audio) {
        throw "The server at $Server does not accept audio. Stop it and start lfm3-omni-2b or lfm3-audio-2b."
    }

    if ($Path) {
        Write-Output (Get-AudioSummary -AudioPath (Resolve-Path -LiteralPath $Path).Path)
        return
    }

    # Each summary replaces the previous one in a single, known file next to this script.
    $summaryPath = Join-Path $PSScriptRoot 'SUMMARY.md'
    while ($selected = Select-AudioFile) {
        Write-Host "Summarizing $selected..."
        $summary = Get-AudioSummary -AudioPath $selected
        $markdown = @(
            '# Summary'
            ''
            "- Source: ``$selected``"
            "- Date: $(Get-Date -Format 'yyyy-MM-dd HH:mm')"
            ''
            $summary
        ) -join "`r`n"
        Set-Content -LiteralPath $summaryPath -Value $markdown -Encoding utf8
        Write-Host "Saved to $summaryPath"
    }
}
finally {
    if ($serverProcess -and -not $serverProcess.HasExited) {
        & taskkill /T /F /PID $serverProcess.Id | Out-Null
        Write-Host 'Stopped lfm3-omni-2b.'
    }
}
