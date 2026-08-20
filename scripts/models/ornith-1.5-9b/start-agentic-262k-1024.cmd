@echo off
setlocal
for %%I in ("%~dp0..\..\..") do set "LLM_ROOT=%%~fI"

rem This launcher is self-contained. Edit the literal values below to customize it.
set "SERVER=%LLM_ROOT%\runtimes\llama.cpp\b10502-cuda13.3\llama-server.exe"

rem Model
set "MODEL_ARGS=--model "%LLM_ROOT%\models\ornith-1.5-9b\Ornith-1.5-9B-AD-IQ4_XS.gguf""

rem Context and performance; use the model's native 262144-token context with flash attention and Jinja.
set "PERFORMANCE_ARGS=--gpu-layers 999 --ctx-size 262144 --parallel 1 --flash-attn on --split-mode none --fit off --threads 8 --threads-batch 8 --batch-size 1024 --ubatch-size 1024 --jinja"

rem Network and API identity
set "NETWORK_ARGS=--host 0.0.0.0 --port 8080 --alias ornith-1.5-9b"

rem Reasoning
set "REASONING_ARGS=--reasoning on"

rem Sampling; these values are required by the model card because no generation_config.json is shipped.
set "SAMPLING_ARGS=--temp 0.6 --top-p 0.95 --top-k 20"

rem Runtime, cache, logging, and reasoning budget
set "RUNTIME_ARGS=--log-verbosity 3 --load-mode none --cache-type-k q8_0 --cache-type-v q8_0 --cache-ram 0 --no-cache-idle-slots --reasoning-budget -1"

rem Vision projector is intentionally not installed for this text-only profile.
set "VISION_ARGS="

rem No speculative draft model is published for Ornith 1.5.
set "MTP_ARGS="

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
