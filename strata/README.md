# Modelos servidos por Strata

Subárbol propio para modelos servidos por [Strata](https://github.com/Niko1221/Strata), separado del catálogo de
llama.cpp. El alias de cada perfil es el `model_name` de su JSON; se registra en Pi, OpenCode y DSH como los del
resto del catálogo (desde el 2026-11-22).

| Pieza | Ruta |
| --- | --- |
| Catálogo y manifiestos | `strata/config/catalog.psd1`, `strata/config/models/<model-id>.psd1` |
| Pesos de Flash-Next (GGUF) | `models/qwen3.8-flash-next-gsq-rco/IQ3_XXS/` |
| Datos preparados de Flash-Next | `models/qwen3.8-flash-next-gsq-rco/strata-data/` (paquete `packs/iq3_xxs`, borrador `dflash2/`) |
| Pesos de Inkling 2 Mini (GGUF de Unsloth y borrador `mtp.safetensors`) | `models/inkling-2-mini-ud-q4_k_xl/` |
| Tokenizador de Inkling (extraído del GGUF) | `models/inkling-2-mini-ud-q4_k_xl/strata-data/packs/inkling-2-mini-ud-q4_k_xl/tokenizer/` |
| Runtime de Flash-Next | `runtimes/strata/0.2.20/` (Terminal y `strata-engine` 0.1.66 CUDA 13, `strata.cmd`) |
| Runtime de Inkling | `runtimes/strata/0.2.21/` (Terminal 0.1.67; `strata-engine` y `strata-inkling` 0.1.67 CUDA 13; `strata.cmd`), desde el 2026-11-24 |
| Lanzadores | `strata/scripts/models/<model-id>/start-text-<ctx>.cmd` |
| Configuración del motor | `strata/scripts/models/<model-id>/text-<ctx>.json` |
| Fichas | [qwen3.8-flash-next-gsq-rco](../docs/overview/models/qwen3.8-flash-next-gsq-rco.md), [inkling-2-mini-ud-q4_k_xl](../docs/overview/models/inkling-2-mini-ud-q4_k_xl.md) |

Se probaron y retiraron el Coder de ISTA-DASLab (ver su
[ficha](../docs/overview/models/qwen3.8-flash-next-gsq-rco-coder.md)) e Inkling 2 Mini SQ-15 con 0.2.19 (ver su
[ficha](../docs/overview/models/inkling-2-mini-sq-15.md)). El GGUF `UD-Q4_K_XL` de Inkling se retiró con 0.2.20 el
2026-11-23 y volvió con 0.2.21 el 2026-11-24.

## Instalación

Todo el estado de Strata (componentes, ajustes, configuraciones) queda en `runtimes/strata/<versión>/`:
`strata.cmd` redirige `LOCALAPPDATA`, `APPDATA`, `STRATA_DATA_DIR`, `STRATA_SETTINGS_FILE` y `STRATA_HOME`. No se
toca el `PATH` ni `%LOCALAPPDATA%\Strata` del usuario. Las descargas de GitHub necesitan acceso de red fuera del
sandbox. El instalador resuelve las rutas relativas desde su propia carpeta: pásale rutas absolutas. Cada versión
se instala igual, cambiando el número de versión y la carpeta del Terminal (0.2.20: `terminal\0.1.66`; 0.2.21:
`terminal\0.1.67`).

```powershell
# Terminal (install.ps1 of the release, checked against the release digests, install-manifest.txt and the signed feed)
$version = '0.2.21'
$root = "D:\LLM\runtimes\strata\$version"
New-Item -ItemType Directory "$root\appdata\Local", "$root\appdata\Roaming", "$root\home" -Force
$env:LOCALAPPDATA = "$root\appdata\Local"; $env:APPDATA = "$root\appdata\Roaming"
$env:STRATA_DATA_DIR = "$root\appdata\Local\Strata"; $env:STRATA_SETTINGS_FILE = "$root\appdata\Roaming\Strata\settings.json"
$env:STRATA_HOME = "$root\home"; $env:STRATA_NO_PATH = '1'
$env:STRATA_FEED = "https://github.com/Niko1221/Strata/releases/download/v$version"
& ".\downloads\strata-$version\install.ps1"
# strata.cmd: the wrapper below, pointing at that version's terminal folder.
# The installer writes run configs into appdata\Local\Strata\install, which it does not create.
New-Item -ItemType Directory "$root\appdata\Local\Strata\install" -Force

# Main engine
& "$root\strata.cmd" update --yes --no-control --feed $env:STRATA_FEED

# Qwen3.8 Flash Next (on 0.2.20): weights and model preparation (the pack and DFlash2 drafter from 0.2.18 are reused unchanged)
.\scripts\setup\Download-Model.ps1 -Model qwen3.8-flash-next-gsq-rco -RootDirectory .\strata
& "D:\LLM\runtimes\strata\0.2.20\strata.cmd" install --family qwen --model IQ3_XXS --gguf-dir D:\LLM\models\qwen3.8-flash-next-gsq-rco\IQ3_XXS `
  --data-dir D:\LLM\models\qwen3.8-flash-next-gsq-rco\strata-data --context 131072 --vision no --host 0.0.0.0 --port 8080 `
  --no-browser --drafter dflash2 --yes --no-start

# Inkling 2 Mini UD-Q4_K_XL (on 0.2.21): weights and drafter, then the strata-inkling component, tokenizer and expert
# split (run once per context: 131072, 262144 and 1048576)
.\scripts\setup\Download-Model.ps1 -Model inkling-2-mini-ud-q4_k_xl -RootDirectory .\strata
& "D:\LLM\runtimes\strata\0.2.21\strata.cmd" install --family inkling-2-mini --model UD-Q4_K_XL --gguf-dir D:\LLM\models\inkling-2-mini-ud-q4_k_xl `
  --data-dir D:\LLM\models\inkling-2-mini-ud-q4_k_xl\strata-data --context 131072 --vision no --host 0.0.0.0 --port 8080 `
  --no-browser --yes --no-start

.\scripts\common\Test-ModelIntegrity.ps1 -RootDirectory .\strata
```

`strata.cmd` (en `runtimes/strata/<versión>/`, sin versionar; aquí el de 0.2.21):

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
call "%STRATA_ROOT%\appdata\Local\Strata\terminal\0.1.67\bin\strata.cmd" %*
exit /b %ERRORLEVEL%
```

Los JSON de Flash-Next son copias de `install\strata-iq3_xxs.json` con `model_name` y `log` cambiados, más
`--vram-reserve-mib 1536` en `args` y, en los de 200K y 262K, `--max-context 204800` o `262144`. Los de Inkling son
copias de `install\strata-inkling-2-mini-ud-q4_k_xl.json`, generado una vez por contexto (cambia el reparto de
expertos), con `model_name` y `log` cambiados y `"drafting": "dspark"` en vez de `"auto"`: la medición que decide
`auto` solo la hace `strata launch`, y sin ella el servidor arranca sin borrador (ver la ficha). El servidor lee
`args`, no `args_written`: un cambio va en ambos, junto con `model_name` y `log`.

## Uso

```powershell
.\strata\scripts\models\qwen3.8-flash-next-gsq-rco\start-text-131k.cmd
.\strata\scripts\models\inkling-2-mini-ud-q4_k_xl\start-text-131k.cmd
```

Escucha en `0.0.0.0:8080` (API OpenAI y Anthropic en `/v1`), sin autenticación, como los perfiles de llama.cpp: solo
red privada y uno a la vez en ese puerto. Parada con `Ctrl+C`. `Test-Llm.ps1` no cubre este subárbol. El log del
servidor va a `logs/strata/`. Para comprobar la configuración sin cargar el modelo (con el runtime de cada modelo):

```powershell
& .\runtimes\strata\0.2.20\strata.cmd serve --profile .\strata\scripts\models\qwen3.8-flash-next-gsq-rco\text-131k.json --host 0.0.0.0 --port 8080 --plan
& .\runtimes\strata\0.2.21\strata.cmd serve --profile .\strata\scripts\models\inkling-2-mini-ud-q4_k_xl\text-131k.json --host 0.0.0.0 --port 8080 --plan
```

Con Inkling, `--plan` avisa de que el motor "no tiene borrador DSpark" porque no consulta el ejecutable; al arrancar,
el servidor sí lo consulta (`--info`) y añade `--draft dspark --draft-beam 1 --draft-adapt` (comprobado con
`inkling_kind.engine_args`).
