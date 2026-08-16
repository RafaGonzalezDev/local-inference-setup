[CmdletBinding()]
param(
    [string]$Model = 'all',
    [string]$Profile,
    [int]$StartupTimeoutSeconds = 900,
    [string]$VisionImage,
    [ValidateRange(0, 4)]
    [int]$SpecDraftNMax = 0,
    [switch]$ConfigurationOnly,
    [switch]$IncludeDeferred
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$rootDirectory = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$launcherDirectory = Join-Path $rootDirectory 'scripts\models'
$catalog = Import-PowerShellDataFile -Path (Join-Path $rootDirectory 'config\catalog.psd1')
$resultDirectory = Join-Path $rootDirectory 'logs\validation'

if (-not $VisionImage) {
    $VisionImage = Join-Path $rootDirectory 'tests\assets\panels-1080p.png'
}
if ($Profile -and $Model -eq 'all') {
    throw 'Specify a model when filtering by profile.'
}
if ($Model -ne 'all' -and $catalog.Models -notcontains $Model) {
    throw "Unknown model '$Model'. Valid models: $($catalog.Models -join ', ')"
}

function Get-AssignmentValue {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Content,

        [Parameter(Mandatory = $true)]
        [string]$Name
    )

    $pattern = '(?m)^set "' + [regex]::Escape($Name) + '=(.*)"\r?$'
    $match = [regex]::Match($Content, $pattern)
    if (-not $match.Success) {
        throw "Launcher assignment '$Name' was not found."
    }
    return $match.Groups[1].Value
}

function Get-ArgumentValue {
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$Arguments,

        [Parameter(Mandatory = $true)]
        [string]$Name
    )

    $index = [array]::IndexOf($Arguments, $Name)
    if ($index -lt 0 -or $index + 1 -ge $Arguments.Count) {
        throw "Launcher argument '$Name' has no value."
    }
    return $Arguments[$index + 1]
}

function Get-LauncherPlan {
    param(
        [Parameter(Mandatory = $true)]
        [System.IO.FileInfo]$Launcher,

        [int]$SpecDraftNMax = 0
    )

    $content = Get-Content -LiteralPath $Launcher.FullName -Raw
    if ($content -match 'Start-Llm\.ps1') {
        throw "Launcher still delegates to Start-Llm.ps1: $($Launcher.FullName)"
    }
    if ($content -match '%\*') {
        throw "Launcher still accepts hidden pass-through arguments: $($Launcher.FullName)"
    }

    $serverPath = (Get-AssignmentValue -Content $content -Name 'SERVER').Replace('%LLM_ROOT%', $rootDirectory)
    if (-not (Test-Path -LiteralPath $serverPath -PathType Leaf)) {
        throw "Runtime executable was not found: $serverPath"
    }

    $arguments = New-Object 'System.Collections.Generic.List[string]'
    foreach ($groupName in @(
        'MODEL_ARGS',
        'PERFORMANCE_ARGS',
        'NETWORK_ARGS',
        'REASONING_ARGS',
        'SAMPLING_ARGS',
        'RUNTIME_ARGS',
        'VISION_ARGS',
        'MTP_ARGS'
    )) {
        $assignment = Get-AssignmentValue -Content $content -Name $groupName
        foreach ($tokenMatch in [regex]::Matches($assignment, '"[^"]*"|\S+')) {
            $token = $tokenMatch.Value.Trim('"').Replace('%LLM_ROOT%', $rootDirectory)
            $arguments.Add($token)
        }
    }

    foreach ($requiredName in @('--model', '--ctx-size', '--host', '--port', '--alias')) {
        $count = @($arguments | Where-Object { $_ -eq $requiredName }).Count
        if ($count -ne 1) {
            throw "Launcher must contain exactly one '$requiredName' argument: $($Launcher.FullName)"
        }
    }

    $duplicateFlags = @(
        $arguments |
            Where-Object { $_.StartsWith('--') } |
            Group-Object |
            Where-Object { $_.Count -gt 1 }
    )
    if ($duplicateFlags.Count -gt 0) {
        throw "Launcher contains duplicate flags: $($duplicateFlags.Name -join ', ')"
    }

    foreach ($pathArgument in @('--model', '--mmproj', '--spec-draft-model')) {
        if ($arguments -contains $pathArgument) {
            $pathValue = Get-ArgumentValue -Arguments $arguments.ToArray() -Name $pathArgument
            if (-not (Test-Path -LiteralPath $pathValue -PathType Leaf)) {
                throw "Launcher file for '$pathArgument' was not found: $pathValue"
            }
        }
    }

    $modelId = $Launcher.Directory.Name
    $profileName = $Launcher.BaseName.Substring('start-'.Length)
    if ($modelId -eq 'qwen3.6-27b-mtp' -and $SpecDraftNMax -gt 0) {
        $draftNMaxIndex = [array]::IndexOf($arguments.ToArray(), '--spec-draft-n-max')
        if ($draftNMaxIndex -lt 0 -or $draftNMaxIndex + 1 -ge $arguments.Count) {
            throw "Launcher does not define '--spec-draft-n-max': $($Launcher.FullName)"
        }
        $arguments[$draftNMaxIndex + 1] = [string]$SpecDraftNMax
    }
    $contextSize = [int](Get-ArgumentValue -Arguments $arguments.ToArray() -Name '--ctx-size')
    if ($modelId -eq 'lfm2.5-2.6b' -and $contextSize -ne 131072) {
        throw "LFM2.5-2.6B profile '$profileName' must use a 131072-token context."
    }
    if ($modelId -eq 'lfm2.5-2.6b') {
        $contextOverride = Get-ArgumentValue -Arguments $arguments.ToArray() -Name '--override-kv'
        if ($contextOverride -ne 'lfm2.context_length=int:131072') {
            throw "LFM2.5-2.6B profile '$profileName' must override the incorrect GGUF context metadata."
        }
        if (
            (Get-ArgumentValue -Arguments $arguments.ToArray() -Name '--temp') -ne '0.1' -or
            (Get-ArgumentValue -Arguments $arguments.ToArray() -Name '--top-k') -ne '50' -or
            (Get-ArgumentValue -Arguments $arguments.ToArray() -Name '--repeat-penalty') -ne '1.1'
        ) {
            throw "LFM2.5-2.6B profile '$profileName' must use the recommended sampling parameters."
        }
    }
    if ($modelId -eq 'lfm2.5-8b-a1b' -and $contextSize -ne 128000) {
        throw "LFM2.5-8B-A1B profile '$profileName' must use its full 128000-token context."
    }
    if ($modelId -eq 'lfm2.5-8b-a1b') {
        if (
            (Get-ArgumentValue -Arguments $arguments.ToArray() -Name '--temp') -ne '0.2' -or
            (Get-ArgumentValue -Arguments $arguments.ToArray() -Name '--top-k') -ne '80' -or
            (Get-ArgumentValue -Arguments $arguments.ToArray() -Name '--repeat-penalty') -ne '1.05'
        ) {
            throw "LFM2.5-8B-A1B profile '$profileName' must use the recommended sampling parameters."
        }
    }
    if ($modelId -eq 'qwen3.6-27b-mtp') {
        $isAgenticProfile = $profileName -like 'agentic*'
        $isTextProfile = $profileName -like 'text*'
        if (-not $isAgenticProfile -and -not $isTextProfile) {
            throw "Qwen3.6-27B-MTP profile '$profileName' must be agentic or text."
        }
        if ($isAgenticProfile -and $contextSize -ne 262144) {
            throw "Qwen3.6-27B-MTP agentic profile '$profileName' must use a 262144-token context."
        }
        if ($isTextProfile -and $contextSize -ne 131072) {
            throw "Qwen3.6-27B-MTP text profile '$profileName' must use a 131072-token context."
        }
        if (-not ($arguments -contains '--spec-type')) {
            throw "Qwen3.6-27B-MTP profile '$profileName' must enable MTP speculative decoding."
        }
        if ((Get-ArgumentValue -Arguments $arguments.ToArray() -Name '--spec-type') -ne 'draft-mtp') {
            throw "Qwen3.6-27B-MTP profile '$profileName' must use draft-mtp."
        }
        $draftNMax = [int](Get-ArgumentValue -Arguments $arguments.ToArray() -Name '--spec-draft-n-max')
        if ($draftNMax -lt 1 -or $draftNMax -gt 4) {
            throw "Qwen3.6-27B-MTP profile '$profileName' must use --spec-draft-n-max between 1 and 4."
        }
        if ($arguments -contains '--mmproj' -or $arguments -contains '--n-cpu-moe' -or $arguments -contains '--cpu-moe') {
            throw "Qwen3.6-27B-MTP profile '$profileName' must not combine MTP with vision or MoE CPU offload."
        }
        $modelPath = Get-ArgumentValue -Arguments $arguments.ToArray() -Name '--model'
        $expectedFileName = if ($profileName -like '*-iq4-xs') {
            'Qwen3.6-27B-IQ4_XS.gguf'
        }
        else {
            'Qwen3.6-27B-Q4_K_M.gguf'
        }
        if ([System.IO.Path]::GetFileName($modelPath) -ne $expectedFileName) {
            throw "Qwen3.6-27B-MTP profile '$profileName' must use $expectedFileName."
        }
        $gpuLayerFlagCount = @($arguments | Where-Object { $_ -eq '--gpu-layers' }).Count
        if ($gpuLayerFlagCount -ne 1) {
            throw "Qwen3.6-27B-MTP profile '$profileName' must contain exactly one '--gpu-layers' argument."
        }
        $gpuLayers = Get-ArgumentValue -Arguments $arguments.ToArray() -Name '--gpu-layers'
        if ($gpuLayers -notmatch '^(auto|[0-9]+)$') {
            throw "Qwen3.6-27B-MTP profile '$profileName' has an invalid GPU layer value: $gpuLayers"
        }
        if ($gpuLayers -match '^[0-9]+$' -and ([int]$gpuLayers -lt 0 -or [int]$gpuLayers -gt 64)) {
            throw "Qwen3.6-27B-MTP profile '$profileName' must use between 0 and 64 GPU layers."
        }
        $fitValue = Get-ArgumentValue -Arguments $arguments.ToArray() -Name '--fit'
        $hasFitTarget = $arguments -contains '--fit-target'
        if ($fitValue -eq 'on' -and -not $hasFitTarget) {
            throw "Qwen3.6-27B-MTP profile '$profileName' must define --fit-target while fit is enabled."
        }
        if ($fitValue -eq 'off' -and $hasFitTarget) {
            throw "Qwen3.6-27B-MTP profile '$profileName' must not retain --fit-target after manual calibration."
        }
    }

    return [pscustomobject]@{
        Model = $modelId
        Profile = $profileName
        Alias = Get-ArgumentValue -Arguments $arguments.ToArray() -Name '--alias'
        LauncherPath = $Launcher.FullName
        ServerPath = $serverPath
        HostAddress = Get-ArgumentValue -Arguments $arguments.ToArray() -Name '--host'
        Port = [int](Get-ArgumentValue -Arguments $arguments.ToArray() -Name '--port')
        ContextSize = $contextSize
        Vision = $arguments -contains '--mmproj'
        Mtp = $arguments -contains '--spec-type'
        Arguments = $arguments.ToArray()
    }
}

$launchers = @(
    Get-ChildItem -LiteralPath $launcherDirectory -Filter 'start-*.cmd' -File -Recurse |
        Sort-Object FullName
)
if ($Model -eq 'all' -and -not $Profile -and $launchers.Count -ne 39) {
    throw "Expected 39 launchers but found $($launchers.Count)."
}
if ($Model -ne 'all') {
    $launchers = @($launchers | Where-Object { $_.Directory.Name -eq $Model })
}
if ($Profile) {
    $launchers = @($launchers | Where-Object { $_.BaseName -eq "start-$Profile" })
}
if ($launchers.Count -eq 0) {
    throw 'No matching launchers were found.'
}

$testCases = New-Object 'System.Collections.Generic.List[object]'
foreach ($launcher in $launchers) {
    $modelConfig = Import-PowerShellDataFile -Path (Join-Path $rootDirectory ("config\models\{0}.psd1" -f $launcher.Directory.Name))
    if (-not $ConfigurationOnly -and -not $IncludeDeferred -and $Model -eq 'all' -and $modelConfig.DeferredInference) {
        Write-Host "Skipping deferred inference model: $($launcher.Directory.Name)"
        continue
    }
    $testCases.Add((Get-LauncherPlan -Launcher $launcher -SpecDraftNMax $SpecDraftNMax))
}

if ($testCases.Count -eq 0) {
    throw 'No matching test cases were found.'
}

New-Item -ItemType Directory -Path $resultDirectory -Force | Out-Null
$results = New-Object 'System.Collections.Generic.List[object]'

foreach ($testCase in $testCases) {
    $startedAt = Get-Date
    $status = 'Failed'
    $details = ''
    $process = $null

    $draftSuffix = if ($SpecDraftNMax -gt 0) { " (spec-draft-n-max $SpecDraftNMax)" } else { '' }
    Write-Host "Testing $($testCase.Model)/$($testCase.Profile)$draftSuffix..."

    $timestamp = Get-Date -Format 'yyyyMMdd-HHmmss'
    $logPrefix = Join-Path $resultDirectory "$($testCase.Model)-$($testCase.Profile)-$timestamp"
    $stdoutPath = "$logPrefix.stdout.log"
    $stderrPath = "$logPrefix.stderr.log"

    try {
        if ($ConfigurationOnly) {
            $status = 'Passed'
            $details = "Validated $($testCase.Arguments.Count) arguments."
            Write-Host "Passed $($testCase.Model)/$($testCase.Profile) configuration"
            continue
        }

        $commandLine = '/d /s /c ""{0}""' -f $testCase.LauncherPath
        $process = Start-Process -FilePath $env:ComSpec -ArgumentList $commandLine -WorkingDirectory (Split-Path -Parent $testCase.LauncherPath) -RedirectStandardOutput $stdoutPath -RedirectStandardError $stderrPath -PassThru
        $healthUri = "http://127.0.0.1:$($testCase.Port)/health"
        $deadline = (Get-Date).AddSeconds($StartupTimeoutSeconds)
        $healthy = $false

        while ((Get-Date) -lt $deadline) {
            if ($process.HasExited) {
                $stderrTail = if (Test-Path -LiteralPath $stderrPath) {
                    (Get-Content -LiteralPath $stderrPath -Tail 30) -join [Environment]::NewLine
                }
                else {
                    'No standard error log was created.'
                }
                throw "llama-server exited before becoming healthy.`n$stderrTail"
            }

            try {
                $healthResponse = Invoke-WebRequest -Uri $healthUri -UseBasicParsing -TimeoutSec 5
                if ($healthResponse.StatusCode -eq 200) {
                    $healthy = $true
                    break
                }
            }
            catch {
                # Model loading can temporarily return an error.
            }

            Start-Sleep -Seconds 2
        }

        if (-not $healthy) {
            throw "The server did not become healthy within $StartupTimeoutSeconds seconds."
        }

        $messageContent = 'Reply with exactly: pong'
        if ($testCase.Vision) {
            if (-not (Test-Path -LiteralPath $VisionImage -PathType Leaf)) {
                throw "Vision fixture was not found: $VisionImage"
            }
            $imageBytes = [System.IO.File]::ReadAllBytes($VisionImage)
            $imageBase64 = [Convert]::ToBase64String($imageBytes)
            $messageContent = @(
                @{ type = 'text'; text = 'Briefly describe the panel layout in this image.' }
                @{ type = 'image_url'; image_url = @{ url = "data:image/png;base64,$imageBase64" } }
            )
        }

        $requestBody = @{
            model = $testCase.Alias
            messages = @(
                @{ role = 'user'; content = $messageContent }
            )
            max_tokens = 16
            stream = $false
        } | ConvertTo-Json -Depth 8 -Compress

        $response = Invoke-RestMethod -Uri "http://127.0.0.1:$($testCase.Port)/v1/chat/completions" -Method Post -ContentType 'application/json' -Body $requestBody -TimeoutSec 300
        if (-not $response.choices -or $response.choices.Count -lt 1) {
            throw 'The response did not contain a completion choice.'
        }

        $message = $response.choices[0].message
        $responseParts = New-Object 'System.Collections.Generic.List[string]'
        foreach ($propertyName in @('content', 'reasoning_content')) {
            $property = $message.PSObject.Properties[$propertyName]
            if ($property -and -not [string]::IsNullOrWhiteSpace([string]$property.Value)) {
                $responseParts.Add([string]$property.Value)
            }
        }
        if ($responseParts.Count -eq 0) {
            throw 'The completion response was empty.'
        }

        $status = 'Passed'
        $details = ($responseParts -join ' ').Trim()
        Write-Host "Passed $($testCase.Model)/$($testCase.Profile)"
    }
    catch {
        $details = $_.Exception.Message
        Write-Warning "Failed $($testCase.Model)/$($testCase.Profile): $details"
    }
    finally {
        if (-not $ConfigurationOnly -and $process -and -not $process.HasExited) {
            $taskkillPath = Join-Path $env:SystemRoot 'System32\taskkill.exe'
            Start-Process -FilePath $taskkillPath -ArgumentList @('/PID', [string]$process.Id, '/T', '/F') -WindowStyle Hidden -Wait | Out-Null
            $process.Refresh()
            if (-not $process.HasExited) {
                throw "The test process tree for PID $($process.Id) did not stop."
            }
        }

        if (-not $ConfigurationOnly) {
            $releaseDeadline = (Get-Date).AddSeconds(30)
            $listeners = @()
            do {
                $listeners = @(Get-NetTCPConnection -State Listen -LocalPort $testCase.Port -ErrorAction SilentlyContinue)
                if ($listeners.Count -eq 0) {
                    break
                }
                Start-Sleep -Seconds 1
            } while ((Get-Date) -lt $releaseDeadline)

            if ($listeners.Count -gt 0) {
                Write-Warning "TCP port $($testCase.Port) remained in use after the test."
            }
        }

        $results.Add([pscustomobject]@{
            Model = $testCase.Model
            Profile = $testCase.Profile
            SpecDraftNMax = if ($SpecDraftNMax -gt 0) { $SpecDraftNMax } else { $null }
            Status = $status
            StartedAt = $startedAt.ToString('o')
            DurationSeconds = [math]::Round(((Get-Date) - $startedAt).TotalSeconds, 2)
            Details = $details
        })
    }
}

$timestamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$resultPrefix = if ($ConfigurationOnly) { 'configuration-tests' } else { 'smoke-tests' }
$resultPath = Join-Path $resultDirectory "$resultPrefix-$timestamp.json"
$results | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath $resultPath -Encoding UTF8
$results | Format-Table Model, Profile, Status, DurationSeconds -AutoSize
Write-Host "Results: $resultPath"

$failedResults = @($results | Where-Object { $_.Status -ne 'Passed' })
if ($failedResults.Count -gt 0) {
    throw "$($failedResults.Count) test(s) failed."
}
