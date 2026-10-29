[CmdletBinding()]
param(
    # Audio or video file; without it, a file picker opens again after each transcript until it is cancelled.
    [string]$Path,

    # English name of the spoken language, as the LFM3 cards expect; 'auto' lets the model detect it.
    [string]$Language = 'Spanish',

    # System prompt that replaces the default ASR instruction.
    [string]$Prompt,

    # Text file to write the transcript to, in addition to the console (only with -Path).
    [string]$OutFile,

    [string]$Server = 'http://127.0.0.1:8080',

    # Long audio loses text in a single request, so it is sent in segments of about this length.
    [ValidateRange(5, 120)]
    [int]$SegmentSeconds = 30,

    # Start lfm3-audio-2b when no server answers, and stop it when the script ends.
    [switch]$StartServer
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$launcherPath = Join-Path $PSScriptRoot 'models\lfm3-audio-2b\start-agentic-auto-audio-32k-1024.cmd'
$logDirectory = Join-Path (Split-Path -Parent $PSScriptRoot) 'logs'

function Invoke-Ffmpeg {
    param([Parameter(Mandatory = $true)] [string[]]$Arguments)

    $output = & ffmpeg -hide_banner -nostdin @Arguments 2>&1
    if ($LASTEXITCODE -ne 0) {
        throw "ffmpeg failed: $($output | Select-Object -Last 5 | Out-String)"
    }
    return $output
}

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
    $dialog.Title = 'Select an audio or video file to transcribe (Cancel to quit)'
    $dialog.Filter = 'Audio and video|*.wav;*.mp3;*.m4a;*.flac;*.ogg;*.opus;*.aac;*.wma;*.webm;*.mp4;*.mkv;*.mov|All files|*.*'
    if ($dialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        return $dialog.FileName
    }
    return $null
}

function Convert-AudioToText {
    param([Parameter(Mandatory = $true)] [string]$AudioPath)

    $workDirectory = Join-Path ([System.IO.Path]::GetTempPath()) ("transcribe-" + [guid]::NewGuid().ToString('N'))
    New-Item -ItemType Directory -Path $workDirectory | Out-Null
    try {
        # Normalize any input, including video, to 16 kHz mono WAV, which the server decodes directly.
        $wavPath = Join-Path $workDirectory 'audio.wav'
        $probe = Invoke-Ffmpeg -Arguments @('-i', $AudioPath, '-vn', '-ac', '1', '-ar', '16000', '-af', 'silencedetect=noise=-35dB:d=0.3', $wavPath)

        $duration = [double]::Parse((& ffprobe -v error -show_entries format=duration -of csv=p=0 $wavPath), [cultureinfo]::InvariantCulture)
        $silences = New-Object 'System.Collections.Generic.List[object]'
        $silenceStart = 0.0
        foreach ($line in $probe) {
            if ("$line" -match 'silence_start: ([\d.]+)') { $silenceStart = [double]::Parse($Matches[1], [cultureinfo]::InvariantCulture) }
            if ("$line" -match 'silence_end: ([\d.]+)') {
                $silenceEnd = [double]::Parse($Matches[1], [cultureinfo]::InvariantCulture)
                $silences.Add([pscustomobject]@{ Middle = ($silenceStart + $silenceEnd) / 2; Length = $silenceEnd - $silenceStart })
            }
        }

        # Cut at the longest pause in the second half of each segment, usually a sentence end, so no word
        # is split; fall back to the limit itself.
        $cuts = New-Object 'System.Collections.Generic.List[double]'
        $start = 0.0
        while ($duration - $start -gt $SegmentSeconds) {
            $limit = $start + $SegmentSeconds
            $longest = $silences | Where-Object { $_.Middle -gt $start + $SegmentSeconds / 2 -and $_.Middle -le $limit } |
                Sort-Object Length -Descending | Select-Object -First 1
            $start = if ($longest) { $longest.Middle } else { $limit }
            $cuts.Add($start)
        }
        $bounds = @(0.0) + $cuts + @($duration)

        $paragraphs = New-Object 'System.Collections.Generic.List[string]'
        for ($i = 0; $i -lt $bounds.Count - 1; $i++) {
            $segmentPath = Join-Path $workDirectory ("segment-{0:000}.wav" -f $i)
            $from = $bounds[$i].ToString([cultureinfo]::InvariantCulture)
            $to = $bounds[$i + 1].ToString([cultureinfo]::InvariantCulture)
            Invoke-Ffmpeg -Arguments @('-i', $wavPath, '-ss', $from, '-to', $to, '-c', 'copy', $segmentPath) | Out-Null
            Write-Progress -Activity "Transcribing $(Split-Path -Leaf $AudioPath)" -Status "Segment $($i + 1) of $($bounds.Count - 1)" -PercentComplete (100 * $i / ($bounds.Count - 1))

            $body = @{
                messages = @(
                    @{ role = 'system'; content = $Prompt }
                    @{ role = 'user'; content = @(@{ type = 'input_audio'; input_audio = @{ data = [Convert]::ToBase64String([System.IO.File]::ReadAllBytes($segmentPath)); format = 'wav' } }) }
                )
                max_tokens = 4096
            } | ConvertTo-Json -Depth 8 -Compress
            $response = Invoke-RestMethod -Uri "$Server/v1/chat/completions" -Method Post -ContentType 'application/json; charset=utf-8' -Body ([System.Text.Encoding]::UTF8.GetBytes($body)) -TimeoutSec 600
            $text = "$($response.choices[0].message.content)".Trim()
            if (-not $text) { continue }
            # A segment that starts mid-sentence gives that sentence back to the previous paragraph.
            if ($paragraphs.Count -gt 0 -and $paragraphs[-1] -notmatch '[.!?…]["»”)]?$') {
                $sentenceEnd = [regex]::Match($text, '^(.*?[.!?…]["»”)]?)(\s+|$)')
                $head = if ($sentenceEnd.Success) { $sentenceEnd.Groups[1].Value } else { $text }
                $paragraphs[$paragraphs.Count - 1] += " $head"
                $text = $text.Substring($head.Length).Trim()
                if (-not $text) { continue }
            }
            # One paragraph per segment with its approximate offset in the audio.
            $offset = [timespan]::FromSeconds([math]::Floor($bounds[$i]))
            $paragraphs.Add(('[{0:hh\:mm\:ss}] {1}' -f $offset, $text))
        }
        Write-Progress -Activity 'Transcribing' -Completed
        return $paragraphs -join "`r`n`r`n"
    }
    finally {
        Remove-Item -LiteralPath $workDirectory -Recurse -Force -ErrorAction SilentlyContinue
    }
}

if (-not (Get-Command 'ffmpeg' -ErrorAction SilentlyContinue)) {
    throw 'ffmpeg was not found in PATH.'
}
if (-not $Prompt) {
    $Prompt = if ($Language -eq 'auto') { 'Perform ASR.' } else { "Perform ASR in $Language." }
}

$serverProcess = $null
try {
    $props = Get-ServerProps
    if (-not $props) {
        if (-not $StartServer) {
            throw "No llama-server answered at $Server. Start lfm3-audio-2b or lfm3-omni-2b from experimental\lfm3\scripts\models first, or use -StartServer."
        }
        Write-Host 'Starting lfm3-audio-2b...'
        # Same console, no new window: closing the window also ends the server.
        $serverProcess = Start-Process -FilePath $env:ComSpec -ArgumentList ('/d /s /c ""{0}""' -f $launcherPath) -NoNewWindow -PassThru `
            -RedirectStandardOutput (Join-Path $logDirectory 'transcription-server.stdout.log') `
            -RedirectStandardError (Join-Path $logDirectory 'transcription-server.stderr.log')
        $deadline = (Get-Date).AddSeconds(180)
        while (-not ($props = Get-ServerProps)) {
            if ($serverProcess.HasExited -or (Get-Date) -gt $deadline) {
                throw "lfm3-audio-2b did not start; see $logDirectory\transcription-server.stderr.log"
            }
            Start-Sleep -Seconds 1
        }
    }
    if (-not $props.modalities.audio) {
        throw "The server at $Server does not accept audio. Stop it and start lfm3-audio-2b or lfm3-omni-2b."
    }

    if ($Path) {
        $transcript = Convert-AudioToText -AudioPath (Resolve-Path -LiteralPath $Path).Path
        Write-Output $transcript
        if ($OutFile) {
            Set-Content -LiteralPath $OutFile -Value $transcript -Encoding utf8
            Write-Host "Saved to $OutFile"
        }
        return
    }

    while ($selected = Select-AudioFile) {
        Write-Host "Transcribing $selected..."
        $transcript = Convert-AudioToText -AudioPath $selected
        # Save next to the audio without overwriting an earlier transcript, then open it in the default editor.
        $base = Join-Path (Split-Path -Parent $selected) ([System.IO.Path]::GetFileNameWithoutExtension($selected))
        $textPath = "$base.transcript.txt"
        if (Test-Path -LiteralPath $textPath) {
            $textPath = "$base.transcript-$(Get-Date -Format 'yyyyMMdd-HHmmss').txt"
        }
        Set-Content -LiteralPath $textPath -Value $transcript -Encoding utf8
        Write-Host "Saved to $textPath"
        Invoke-Item -LiteralPath $textPath
    }
}
finally {
    if ($serverProcess -and -not $serverProcess.HasExited) {
        & taskkill /T /F /PID $serverProcess.Id | Out-Null
        Write-Host 'Stopped lfm3-audio-2b.'
    }
}
