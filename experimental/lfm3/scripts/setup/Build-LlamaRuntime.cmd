@echo off
setlocal
rem Builds llama.cpp from a pinned commit for the LFM3 family (source build, not an official release).
for %%I in ("%~dp0..\..") do set "LFM3_ROOT=%%~fI"

set "COMMIT=19ff817fb25e9a1b838b1d7f9f4325f7bf9779c4"
set "SOURCE=%LFM3_ROOT%\src\llama.cpp"
set "BUILD=%SOURCE%\build-cuda13.4"
set "RUNTIME=%LFM3_ROOT%\runtimes\llama.cpp\19ff817-cuda13.4"
set "VS=C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools"
set "CUDA_PATH=C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v13.4"

if not exist "%SOURCE%\.git" (
  git init -q "%SOURCE%" || exit /b 1
  git -C "%SOURCE%" remote add origin https://github.com/ggml-org/llama.cpp.git || exit /b 1
)
git -C "%SOURCE%" fetch -q --depth 1 origin %COMMIT% || exit /b 1
git -C "%SOURCE%" checkout -q --detach %COMMIT% || exit /b 1

call "%VS%\VC\Auxiliary\Build\vcvarsall.bat" x64 >nul || exit /b 1

rem RTX 5080 only (sm_120); OpenSSL off because model downloads go through Download-Model.ps1.
cmake -S "%SOURCE%" -B "%BUILD%" -G Ninja ^
  -DCMAKE_BUILD_TYPE=Release ^
  -DGGML_CUDA=ON ^
  -DCMAKE_CUDA_ARCHITECTURES=120 ^
  -DGGML_NATIVE=ON ^
  -DLLAMA_OPENSSL=OFF ^
  -DLLAMA_BUILD_TESTS=OFF || exit /b 1
cmake --build "%BUILD%" --config Release -j %NUMBER_OF_PROCESSORS% --target llama-server llama-mtmd-cli llama-tts llama-cli || exit /b 1

if exist "%RUNTIME%" (
  echo Runtime directory already exists: %RUNTIME%
  exit /b 1
)
mkdir "%RUNTIME%" || exit /b 1
copy /y "%BUILD%\bin\*.exe" "%RUNTIME%\" >nul || exit /b 1
copy /y "%BUILD%\bin\*.dll" "%RUNTIME%\" >nul || exit /b 1
for %%D in (cudart64_13.dll cublas64_13.dll cublasLt64_13.dll) do (
  copy /y "%CUDA_PATH%\bin\x64\%%D" "%RUNTIME%\" >nul 2>nul || copy /y "%CUDA_PATH%\bin\%%D" "%RUNTIME%\" >nul || exit /b 1
)
"%RUNTIME%\llama-server.exe" --version
endlocal & exit /b %ERRORLEVEL%
