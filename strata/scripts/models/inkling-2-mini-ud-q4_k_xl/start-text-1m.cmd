@echo off
setlocal
for %%I in ("%~dp0..\..\..\..") do set "LLM_ROOT=%%~fI"

rem Inkling 2 Mini UD-Q4_K_XL (Unsloth GGUF) with the DSpark drafter, text only and without reasoning, served by Strata's strata-inkling engine.
rem The run config beside this file holds the engine arguments (model, DSpark drafter, context, VRAM/RAM expert split); its paths are absolute under D:\LLM.
set "STRATA_ROOT=%LLM_ROOT%\runtimes\strata\0.2.20"
set "TERMINAL=%STRATA_ROOT%\appdata\Local\Strata\terminal\0.1.66"
set "PYTHON=%TERMINAL%\python\python.exe"
set "SERVER_SCRIPT=%TERMINAL%\serve\server.py"
set "ENGINE_CONFIG=%~dp0text-1m.json"

rem Strata finds its engine component, settings and state through these folders; they stay inside its runtime folder.
set "LOCALAPPDATA=%STRATA_ROOT%\appdata\Local"
set "APPDATA=%STRATA_ROOT%\appdata\Roaming"
set "STRATA_DATA_DIR=%STRATA_ROOT%\appdata\Local\Strata"
set "STRATA_SETTINGS_FILE=%STRATA_ROOT%\appdata\Roaming\Strata\settings.json"
set "STRATA_HOME=%STRATA_ROOT%\home"

rem Network: same port and exposure as the llama.cpp profiles (private network only, no authentication)
set "NETWORK_ARGS=--host 0.0.0.0 --port 8080"

if not exist "%LLM_ROOT%\logs\strata" mkdir "%LLM_ROOT%\logs\strata"
pushd "%TERMINAL%"
"%PYTHON%" "%SERVER_SCRIPT%" --engine strata --config "%ENGINE_CONFIG%" %NETWORK_ARGS%
set "EXIT_CODE=%ERRORLEVEL%"
popd
endlocal & exit /b %EXIT_CODE%
