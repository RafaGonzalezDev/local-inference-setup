@echo off
setlocal
for %%I in ("%~dp0..\..\..") do set "LLM_ROOT=%%~fI"

rem Single profile: vision enabled and the full validated long context.
set "SERVER=%LLM_ROOT%\runtimes\llama.cpp\prism-b10685-7dffb15-cuda13.3\llama-server.exe"

rem Model
set "MODEL_ARGS=--model "%LLM_ROOT%\models\ternary-bonsai-2-27b\Ternary-Bonsai-2-27B-PQ2_0.gguf""

rem Context and performance
set "PERFORMANCE_ARGS=--gpu-layers 999 --ctx-size 131072 --parallel 1 --cache-ram 0 --flash-attn on --split-mode none --fit off --threads 8 --threads-batch 8 --batch-size 1024 --ubatch-size 1024 --jinja"

rem Network and API identity
set "NETWORK_ARGS=--host 0.0.0.0 --port 8080 --alias ternary-bonsai-2-27b"

rem Reasoning
set "REASONING_ARGS=--reasoning on"

rem Sampling: official thinking-mode values from the model card.
set "SAMPLING_ARGS=--temp 1 --top-p 0.95 --top-k 20 --min-p 0 --presence-penalty 0 --repeat-penalty 1"

rem Runtime, cache, logging, and reasoning budget
set "RUNTIME_ARGS=--log-verbosity 3 --load-mode none --cache-type-k q8_0 --cache-type-v q8_0 --reasoning-budget 8192"

rem Vision: the minimum follows the fork warning for Qwen-VL grounding; the
rem image token cap bounds prefill and VRAM. The reference demo leaves CUDA
rem uncapped and allows up to ~4096 tokens per image.
set "VISION_ARGS=--mmproj "%LLM_ROOT%\models\ternary-bonsai-2-27b\Ternary-Bonsai-2-27B-mmproj-Q8_0.gguf" --image-min-tokens 1024 --image-max-tokens 1024"

rem MTP speculative decoding: no drafter is published for this model.
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
