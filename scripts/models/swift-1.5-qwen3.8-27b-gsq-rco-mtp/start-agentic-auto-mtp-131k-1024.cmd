@echo off
setlocal
for %%I in ("%~dp0..\..\..") do set "LLM_ROOT=%%~fI"

rem Automatic device placement MTP profile for a dense 27B model; --fit resolves the layer split.
set "SERVER=%LLM_ROOT%\runtimes\llama.cpp\b11551-cuda13.4\llama-server.exe"

rem Model
set "MODEL_ARGS=--model "%LLM_ROOT%\models\swift-1.5-qwen3.8-27b-gsq-rco-mtp\Swift-1.5-Qwen3.8-27B-GSQ-RCO-IQ3_XXS-mtp.gguf""

rem Context and performance; 1024/1024 keeps compute buffers small so --fit leaves more weights on GPU
set "PERFORMANCE_ARGS=--gpu-layers auto --ctx-size 131072 --parallel 1 --cache-ram 0 --flash-attn on --split-mode none --fit on --fit-target 1024 --threads 8 --threads-batch 8 --batch-size 1024 --ubatch-size 1024 --jinja"

rem Network and API identity; the second alias is the profile ID this launcher serves to clients.
set "NETWORK_ARGS=--host 0.0.0.0 --port 8080 --alias swift-1.5-qwen3.8-27b-gsq-rco-mtp,swift-1.5-qwen3.8-27b-gsq-rco-mtp-131k"

rem Reasoning; xhigh is the effort used by the author's evaluation and the template default
set "REASONING_ARGS=--reasoning auto --reasoning-effort xhigh"

rem Sampling, as recommended by the model card for thinking mode
set "SAMPLING_ARGS=--temp 1 --top-p 0.95 --top-k 20 --min-p 0 --presence-penalty 0 --repeat-penalty 1"

rem Runtime, cache, logging and reasoning budget; no artificial thinking cap
set "RUNTIME_ARGS=--log-verbosity 3 --load-mode none --cache-type-k q8_0 --cache-type-v q8_0 --reasoning-budget -1"

rem Vision: this release ships no verified projector
set "VISION_ARGS="

rem MTP speculative decoding; the nextn head lives in the main GGUF
set "MTP_ARGS=--spec-type draft-mtp --spec-draft-n-max 3"

"%SERVER%" ^
  %MODEL_ARGS% ^
  %PERFORMANCE_ARGS% ^
  %NETWORK_ARGS% ^
  %REASONING_ARGS% ^
  %SAMPLING_ARGS% ^
  %RUNTIME_ARGS% ^
  %VISION_ARGS% ^
  %MTP_ARGS%
set "EXIT_CODE=%ERRORLEVEL%"
endlocal & exit /b %EXIT_CODE%
