[CmdletBinding()]
param(
    # Audio or video file; a file picker opens when it is omitted.
    [string]$Path,

    # English name of the spoken language, as the LFM3 cards expect; 'auto' lets the model detect it.
    [string]$Language = 'Spanish',

    # System prompt that replaces the default ASR instruction.
    [string]$Prompt,

    # Text file to write the transcript to, in addition to the console.
    [string]$OutFile,

    [string]$Server = 'http://127.0.0.1:8080',

    # Long audio loses text in a single request, so it is sent in segments of about this length.
    [ValidateRange(5, 120)]
    [int]$SegmentSeconds = 30
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Invoke-Ffmpeg {
    param([Parameter(Mandatory = $true)] [string[]]$Arguments)

    $output = & ffmpeg -hide_banner -nostdin @Arguments 2>&1
    if ($LASTEXITCODE -ne 0) {
        throw "ffmpeg failed: $($output | Select-Object -Last 5 | Out-String)"
    }
    return $output
}

if (-not (Get-Command 'ffmpeg' -ErrorAction SilentlyContinue)) {
    throw 'ffmpeg was not found in PATH.'
}

if ([string]::IsNullOrWhiteSpace($Path)) {
    Add-Type -AssemblyName System.Windows.Forms
    $dialog = New-Object System.Windows.Forms.OpenFileDialog
    $dialog.Title = 'Select an audio or video file to transcribe'
    $dialog.Filter = 'Audio and video|*.wav;*.mp3;*.m4a;*.flac;*.ogg;*.opus;*.aac;*.wma;*.webm;*.mp4;*.mkv;*.mov|All files|*.*'
    if ($dialog.ShowDialog() -ne [System.Windows.Forms.DialogResult]::OK) {
        Write-Host 'No file selected.'
        return
    }
    $Path = $dialog.FileName
}
$Path = (Resolve-Path -LiteralPath $Path).Path

$props = Invoke-RestMethod -Uri "$Server/props" -TimeoutSec 10
if (-not $props.modalities.audio) {
    throw "The server at $Server does not accept audio. Start lfm3-audio-2b or lfm3-omni-2b from experimental\lfm3\scripts\models."
}

if (-not $Prompt) {
    $Prompt = if ($Language -eq 'auto') { 'Perform ASR.' } else { "Perform ASR in $Language." }
}

$workDirectory = Join-Path ([System.IO.Path]::GetTempPath()) ("transcribe-" + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $workDirectory | Out-Null
try {
    # Normalize any input, including video, to 16 kHz mono WAV, which the server decodes directly.
    $wavPath = Join-Path $workDirectory 'audio.wav'
    $probe = Invoke-Ffmpeg -Arguments @('-i', $Path, '-vn', '-ac', '1', '-ar', '16000', '-af', 'silencedetect=noise=-35dB:d=0.3', $wavPath)

    $duration = [double]::Parse((& ffprobe -v error -show_entries format=duration -of csv=p=0 $wavPath), [cultureinfo]::InvariantCulture)
    $silences = New-Object 'System.Collections.Generic.List[double]'
    $silenceStart = 0.0
    foreach ($line in $probe) {
        if ("$line" -match 'silence_start: ([\d.]+)') { $silenceStart = [double]::Parse($Matches[1], [cultureinfo]::InvariantCulture) }
        if ("$line" -match 'silence_end: ([\d.]+)') { $silences.Add(([double]::Parse($Matches[1], [cultureinfo]::InvariantCulture) + $silenceStart) / 2) }
    }

    # Cut at the last silence before each segment limit, so no word is split; fall back to the limit itself.
    $cuts = New-Object 'System.Collections.Generic.List[double]'
    $start = 0.0
    while ($duration - $start -gt $SegmentSeconds) {
        $limit = $start + $SegmentSeconds
        $candidates = @($silences | Where-Object { $_ -gt $start + $SegmentSeconds / 2 -and $_ -le $limit })
        $start = if ($candidates.Count -gt 0) { $candidates[-1] } else { $limit }
        $cuts.Add($start)
    }
    $bounds = @(0.0) + $cuts + @($duration)

    $parts = New-Object 'System.Collections.Generic.List[string]'
    for ($i = 0; $i -lt $bounds.Count - 1; $i++) {
        $segmentPath = Join-Path $workDirectory ("segment-{0:000}.wav" -f $i)
        $from = $bounds[$i].ToString([cultureinfo]::InvariantCulture)
        $to = $bounds[$i + 1].ToString([cultureinfo]::InvariantCulture)
        Invoke-Ffmpeg -Arguments @('-i', $wavPath, '-ss', $from, '-to', $to, '-c', 'copy', $segmentPath) | Out-Null
        Write-Progress -Activity "Transcribing $(Split-Path -Leaf $Path)" -Status "Segment $($i + 1) of $($bounds.Count - 1)" -PercentComplete (100 * $i / ($bounds.Count - 1))

        $body = @{
            messages = @(
                @{ role = 'system'; content = $Prompt }
                @{ role = 'user'; content = @(@{ type = 'input_audio'; input_audio = @{ data = [Convert]::ToBase64String([System.IO.File]::ReadAllBytes($segmentPath)); format = 'wav' } }) }
            )
            max_tokens = 4096
        } | ConvertTo-Json -Depth 8 -Compress
        $response = Invoke-RestMethod -Uri "$Server/v1/chat/completions" -Method Post -ContentType 'application/json; charset=utf-8' -Body ([System.Text.Encoding]::UTF8.GetBytes($body)) -TimeoutSec 600
        $text = "$($response.choices[0].message.content)".Trim()
        if ($text) { $parts.Add($text) }
    }
    Write-Progress -Activity 'Transcribing' -Completed

    $transcript = $parts -join ' '
    Write-Output $transcript
    if ($OutFile) {
        Set-Content -LiteralPath $OutFile -Value $transcript -Encoding utf8
        Write-Host "Saved to $OutFile"
    }
}
finally {
    Remove-Item -LiteralPath $workDirectory -Recurse -Force -ErrorAction SilentlyContinue
}
