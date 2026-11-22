@echo off
setlocal
for %%I in ("%~dp0..\..\..\..") do set "LLM_ROOT=%%~fI"

rem Inkling 2 Mini, text only, served by maya-ik2 (Project Maya fork) instead of llama-server.
rem The engine config beside this file holds the model, context and engine settings; its paths are relative to LLM_ROOT.
set "PYTHON=%LLM_ROOT%\runtimes\maya-ik2\e819852-cuda13.4\.venv\Scripts\python.exe"
set "SERVER_SCRIPT=%LLM_ROOT%\runtimes\maya-ik2\e819852-cuda13.4\serve\server.py"
set "ENGINE_CONFIG=%~dp0text-262k.json"

rem The dashboard's update check would fetch upstream code; this runtime stays at its pinned commit.
set "MAYA_UPDATE_CHECK=0"

rem Network: same port and exposure as the llama.cpp profiles (private network only, no authentication)
set "NETWORK_ARGS=--port 8080"

if not exist "%LLM_ROOT%\logs\maya" mkdir "%LLM_ROOT%\logs\maya"
pushd "%LLM_ROOT%"
"%PYTHON%" "%SERVER_SCRIPT%" --engine maya --config "%ENGINE_CONFIG%" %NETWORK_ARGS%
set "EXIT_CODE=%ERRORLEVEL%"
popd
endlocal & exit /b %EXIT_CODE%
