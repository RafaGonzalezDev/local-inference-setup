# Qwen3.8 Flash Next con Strata

Subárbol propio para modelos servidos por [Strata](https://github.com/Niko1221/Strata), separado del catálogo de
llama.cpp. El alias de cada perfil es el `model_name` de su JSON; se registra en Pi, OpenCode y DSH como los del
resto del catálogo (desde el 2026-11-22).

| Pieza | Ruta |
| --- | --- |
| Catálogo y manifiesto | `strata/config/catalog.psd1`, `strata/config/models/qwen3.8-flash-next-gsq-rco.psd1` |
| Pesos de Flash-Next (GGUF) | `models/qwen3.8-flash-next-gsq-rco/IQ3_XXS/` |
| Datos preparados de Flash-Next | `models/qwen3.8-flash-next-gsq-rco/strata-data/` (paquete `packs/iq3_xxs`, borrador `dflash2/`) |
| Runtime | `runtimes/strata/0.2.20/` (Terminal y `strata-engine` 0.1.66 CUDA 13, `strata.cmd`); el único instalado desde el 2026-11-23 |
| Lanzadores | `strata/scripts/models/<model-id>/start-text-<ctx>.cmd` |
| Configuración del motor | `strata/scripts/models/<model-id>/text-<ctx>.json` |
| Ficha | [qwen3.8-flash-next-gsq-rco](../docs/overview/models/qwen3.8-flash-next-gsq-rco.md) |

Se probaron y retiraron el Coder de ISTA-DASLab (ver su
[ficha](../docs/overview/models/qwen3.8-flash-next-gsq-rco-coder.md)) e Inkling 2 Mini, en SQ-15 con 0.2.19 y en el
GGUF `UD-Q4_K_XL` de Unsloth con 0.2.20 y con 0.2.21 (ver sus fichas, [SQ-15](../docs/overview/models/inkling-2-mini-sq-15.md) y
[UD-Q4_K_XL](../docs/overview/models/inkling-2-mini-ud-q4_k_xl.md)). Strata 0.2.21 se descartó el 2026-11-24: Flash-Next
no pasaba de 65-70 tok/s con ella, frente a más de 100 tok/s con 0.2.20, e Inkling seguía siendo lento.

## Instalación

Todo el estado de Strata (componentes, ajustes, configuraciones) queda en `runtimes/strata/<versión>/`:
`strata.cmd` redirige `LOCALAPPDATA`, `APPDATA`, `STRATA_DATA_DIR`, `STRATA_SETTINGS_FILE` y `STRATA_HOME`. No se
toca el `PATH` ni `%LOCALAPPDATA%\Strata` del usuario. Las descargas de GitHub necesitan acceso de red fuera del
sandbox. El instalador resuelve las rutas relativas desde su propia carpeta: pásale rutas absolutas.

```powershell
# Terminal (install.ps1 of the v0.2.20 release, checked against the release digests, install-manifest.txt and the signed feed)
$root = 'D:\LLM\runtimes\strata\0.2.20'
New-Item -ItemType Directory "$root\appdata\Local", "$root\appdata\Roaming", "$root\home" -Force
$env:LOCALAPPDATA = "$root\appdata\Local"; $env:APPDATA = "$root\appdata\Roaming"
$env:STRATA_DATA_DIR = "$root\appdata\Local\Strata"; $env:STRATA_SETTINGS_FILE = "$root\appdata\Roaming\Strata\settings.json"
$env:STRATA_HOME = "$root\home"; $env:STRATA_NO_PATH = '1'
$env:STRATA_FEED = 'https://github.com/Niko1221/Strata/releases/download/v0.2.20'
& .\downloads\strata-0.2.20\install.ps1
# strata.cmd: the wrapper below, pointing at terminal\0.1.66.
# The installer writes run configs into appdata\Local\Strata\install, which it does not create.
New-Item -ItemType Directory "$root\appdata\Local\Strata\install" -Force

# Main engine
& "$root\strata.cmd" update --yes --no-control --feed $env:STRATA_FEED

# Qwen3.8 Flash Next: weights and model preparation (the pack and DFlash2 drafter from 0.2.18 are reused unchanged)
.\scripts\setup\Download-Model.ps1 -Model qwen3.8-flash-next-gsq-rco -RootDirectory .\strata
& "$root\strata.cmd" install --family qwen --model IQ3_XXS --gguf-dir D:\LLM\models\qwen3.8-flash-next-gsq-rco\IQ3_XXS `
  --data-dir D:\LLM\models\qwen3.8-flash-next-gsq-rco\strata-data --context 131072 --vision no --host 0.0.0.0 --port 8080 `
  --no-browser --drafter dflash2 --yes --no-start

.\scripts\common\Test-ModelIntegrity.ps1 -RootDirectory .\strata
```

`strata.cmd` (en `runtimes/strata/0.2.20/`, sin versionar):

```bat
@echo off
rem Runs the Strata Terminal with all of its state (components, run configs, settings, logs) kept inside this folder.
setlocal
set "STRATA_ROOT=%~dp0"
set "STRATA_ROOT=%STRATA_ROOT:~0,-1%"
set "LOCALAPPDATA=%STRATA_ROOT%\appdata\Local"
set "APPDATA=%STRATA_ROOT%\appdata\Roaming"
set "STRATA_DATA_DIR=%STRATA_ROOT%\appdata\Local\Strata"
set "STRATA_SETTINGS_FILE=%STRATA_ROOT%\appdata\Roaming\Strata\settings.json"
set "STRATA_HOME=%STRATA_ROOT%\home"
call "%STRATA_ROOT%\appdata\Local\Strata\terminal\0.1.66\bin\strata.cmd" %*
exit /b %ERRORLEVEL%
```

Los JSON de los lanzadores son copias de `install\strata-iq3_xxs.json` con `model_name` y `log` cambiados, más
`--vram-reserve-mib 1536` en `args` y, en los de 200K y 262K, `--max-context 204800` o `262144`. El servidor lee
`args`, no `args_written`: un cambio de contexto va en ambos, junto con `model_name` y `log`.

## Uso

```powershell
.\strata\scripts\models\qwen3.8-flash-next-gsq-rco\start-text-131k.cmd
```

Escucha en `0.0.0.0:8080` (API OpenAI y Anthropic en `/v1`), sin autenticación, como los perfiles de llama.cpp: solo
red privada y uno a la vez en ese puerto. Parada con `Ctrl+C`. `Test-Llm.ps1` no cubre este subárbol. El log del
servidor va a `logs/strata/`. Para comprobar la configuración sin cargar el modelo:

```powershell
& .\runtimes\strata\0.2.20\strata.cmd serve --profile .\strata\scripts\models\qwen3.8-flash-next-gsq-rco\text-131k.json --host 0.0.0.0 --port 8080 --plan
```
