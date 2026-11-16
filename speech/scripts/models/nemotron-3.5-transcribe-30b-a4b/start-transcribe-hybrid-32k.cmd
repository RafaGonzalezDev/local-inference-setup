@echo off
setlocal
for %%I in ("%~dp0..\..\..\..") do set "LLM_ROOT=%%~fI"

rem Speech-LLM transcription server (NeMo-Speech.cpp SALM), apart from the llama.cpp chat catalog.
rem Hybrid placement for a 16 GB GPU: the experts of the first 28 decoder blocks stay in system RAM.
set "SERVER=%LLM_ROOT%\runtimes\nemo-speech\nightly-e790e46-cuda\bin\nemo-speech.exe"

rem Model: the decoder; its encoder file (speech encoder, speaker branch, CTC timestamp head) is loaded from beside it
set "MODEL_ARGS=--asr-model "%LLM_ROOT%\models\nemotron-3.5-transcribe-30b-a4b\NVIDIA-Nemotron-3.5-Transcribe-30B-A4B-AD-IQ4_NL.gguf""

rem Context and performance: NeMo-Speech.cpp 16 GB row; max_context 32768 holds about 29 minutes of audio per request
set "PERFORMANCE_ARGS=--device cuda --asr.salm.max_sequences 1 --asr.salm.n_ctx_per_sequence 32768 --asr.salm.max_context 32768 --asr.salm.n_cpu_moe 28 --asr.salm.n_batch 512 --asr.salm.encoder_max_batch 1 --asr.salm.encoder_ahead_seconds 600 --asr.backend.threads 6"

rem Network: local only and without authentication; port 8090 leaves 8080 to the chat models
set "NETWORK_ARGS=--host 127.0.0.1 --port 8090 --no-ui"

"%SERVER%" serve ^
  %MODEL_ARGS% ^
  %PERFORMANCE_ARGS% ^
  %NETWORK_ARGS%
set "EXIT_CODE=%ERRORLEVEL%"
endlocal & exit /b %EXIT_CODE%
