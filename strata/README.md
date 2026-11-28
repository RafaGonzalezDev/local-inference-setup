# Modelos servidos por Strata

Subárbol propio para modelos servidos por [Strata](https://github.com/Niko1221/Strata), separado del catálogo de
llama.cpp. El alias de cada perfil es el `model_name` de su JSON; se registra en Pi, OpenCode y DSH como los del
resto del catálogo (desde el 2026-11-22).

| Pieza | Ruta |
| --- | --- |
| Catálogo y manifiestos | `strata/config/catalog.psd1`, `strata/config/models/<model-id>.psd1` |
| Pesos de Flash-Next (GGUF) | `models/qwen3.8-flash-next-gsq-rco/IQ3_XXS/` |
| Datos preparados de Flash-Next | `models/qwen3.8-flash-next-gsq-rco/strata-data/` (paquete `packs/iq3_xxs`, borrador `dflash2/`) |
| Pesos de Inkling | `models/inkling-2-mini-gsq-rco-iq3_s/` (GGUF, `dflash2.safetensors`, `Inkling-2-Mini-Vision-v2.strata`; tokenizador en `strata-data/`) |
| Runtime | `runtimes/strata/0.2.23/` (Terminal 0.1.70; `strata-engine` y `strata-inkling` 0.1.70 CUDA 13), el de los lanzadores sin sufijo; `runtimes/strata/0.2.22/` de respaldo para Flash-Next (Terminal y motor 0.1.69 CUDA 13) |
| Lanzadores | `strata/scripts/models/<model-id>/start-<text\|vision>-<ctx>[-0.2.22].cmd` |
| Configuración del motor | `strata/scripts/models/<model-id>/<text\|vision>-<ctx>[-0.2.22].json` |
| Fichas | [qwen3.8-flash-next-gsq-rco](../docs/overview/models/qwen3.8-flash-next-gsq-rco.md), [inkling-2-mini-gsq-rco-iq3_s](../docs/overview/models/inkling-2-mini-gsq-rco-iq3_s.md) |

Se probaron y retiraron el Coder de ISTA-DASLab (ver su
[ficha](../docs/overview/models/qwen3.8-flash-next-gsq-rco-coder.md)) e Inkling 2 Mini en SQ-15 con 0.2.19 y en el
GGUF `UD-Q4_K_XL` de Unsloth con 0.2.20 y 0.2.21 (ver sus fichas, [SQ-15](../docs/overview/models/inkling-2-mini-sq-15.md) y
[UD-Q4_K_XL](../docs/overview/models/inkling-2-mini-ud-q4_k_xl.md)). Strata 0.2.21 se descartó el 2026-11-24 y 0.2.20
se borró el 2026-11-28, cuando el usuario midió 0.2.22 claramente por encima. Inkling vuelve con 0.2.23 en el GGUF
GSQ-RCO IQ3_S, que tiene kernels propios y el borrador DFlash 2.

## Instalación

Todo el estado de Strata (componentes, ajustes, configuraciones) queda en `runtimes/strata/<versión>/`:
`strata.cmd` redirige `LOCALAPPDATA`, `APPDATA`, `STRATA_DATA_DIR`, `STRATA_SETTINGS_FILE` y `STRATA_HOME`. No se
toca el `PATH` ni `%LOCALAPPDATA%\Strata` del usuario. Las descargas de GitHub necesitan acceso de red fuera del
sandbox. El instalador resuelve las rutas relativas desde su propia carpeta: pásale rutas absolutas.

```powershell
# Terminal (install.ps1 of the v0.2.23 release, checked against the release digests; identical to 0.2.20's and 0.2.22's)
$root = 'D:\LLM\runtimes\strata\0.2.23'
New-Item -ItemType Directory "$root\appdata\Local", "$root\appdata\Roaming", "$root\home" -Force
$env:LOCALAPPDATA = "$root\appdata\Local"; $env:APPDATA = "$root\appdata\Roaming"
$env:STRATA_DATA_DIR = "$root\appdata\Local\Strata"; $env:STRATA_SETTINGS_FILE = "$root\appdata\Roaming\Strata\settings.json"
$env:STRATA_HOME = "$root\home"; $env:STRATA_NO_PATH = '1'
$env:STRATA_FEED = 'https://github.com/Niko1221/Strata/releases/download/v0.2.23'
& .\downloads\strata-0.2.23\install.ps1
# strata.cmd: the wrapper below, pointing at terminal\0.1.70.
# The installer writes run configs into appdata\Local\Strata\install, which it does not create.
New-Item -ItemType Directory "$root\appdata\Local\Strata\install" -Force

# Main engine (strata-engine, used by Qwen)
& "$root\strata.cmd" update --yes --no-control --feed $env:STRATA_FEED

# Qwen3.8 Flash Next: weights and model preparation (the pack and DFlash2 drafter from 0.2.18 are reused unchanged)
.\scripts\setup\Download-Model.ps1 -Model qwen3.8-flash-next-gsq-rco -RootDirectory .\strata
& "$root\strata.cmd" install --family qwen --model IQ3_XXS --gguf-dir D:\LLM\models\qwen3.8-flash-next-gsq-rco\IQ3_XXS `
  --data-dir D:\LLM\models\qwen3.8-flash-next-gsq-rco\strata-data --context 131072 --vision no --host 0.0.0.0 --port 8080 `
  --no-browser --drafter dflash2 --yes --no-start

# Inkling 2 Mini GSQ-RCO IQ3_S: weights, then the strata-inkling component and the tokenizer (one run per context and vision choice)
.\scripts\setup\Download-Model.ps1 -Model inkling-2-mini-gsq-rco-iq3_s -RootDirectory .\strata
$m = 'D:\LLM\models\inkling-2-mini-gsq-rco-iq3_s'
& "$root\strata.cmd" install --family inkling-2-mini --model GSQ-RCO-IQ3_S --gguf-dir $m --data-dir "$m\strata-data" `
  --context 131072 --vision yes --host 0.0.0.0 --port 8080 --no-browser --yes --no-start

.\scripts\common\Test-ModelIntegrity.ps1 -RootDirectory .\strata
```

`strata.cmd` (en `runtimes/strata/0.2.23/`, sin versionar):

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
call "%STRATA_ROOT%\appdata\Local\Strata\terminal\0.1.70\bin\strata.cmd" %*
exit /b %ERRORLEVEL%
```

Los JSON de Flash-Next son copias de `install\strata-iq3_xxs.json` con `model_name` y `log` cambiados, más
`--vram-reserve-mib 1536` en `args` y, en los de 200K y 262K, `--max-context 204800` o `262144`. Los de Inkling son
copias de `install\strata-inkling-2-mini-gsq-rco-iq3_s.json`, escrito por `strata install` para cada contexto y
elección de visión, con `model_name` y `log` cambiados y `"drafting": "dflash2"` (ver la ficha). El servidor lee
`args`, no `args_written`: un cambio de contexto va en ambos, junto con `model_name` y `log`.

## Uso

```powershell
.\strata\scripts\models\qwen3.8-flash-next-gsq-rco\start-text-131k.cmd
.\strata\scripts\models\inkling-2-mini-gsq-rco-iq3_s\start-text-262k.cmd
.\strata\scripts\models\inkling-2-mini-gsq-rco-iq3_s\start-vision-262k.cmd
```

Para volver a 0.2.22 con Flash-Next, detén el servidor y usa `start-text-131k-0.2.22.cmd`,
`start-text-200k-0.2.22.cmd` o `start-text-262k-0.2.22.cmd` en la misma carpeta. Conservan los alias y el puerto;
no hay que cambiar de modelo en los clientes. Sus logs llevan el sufijo `-0.2.22.log`. Inkling solo tiene
lanzadores de 0.2.23: el motor de 0.2.22 rechaza los archivos nuevos.

Escucha en `0.0.0.0:8080` (API OpenAI y Anthropic en `/v1`), sin autenticación, como los perfiles de llama.cpp: solo
red privada y uno a la vez en ese puerto. Parada con `Ctrl+C`. `Test-Llm.ps1` no cubre este subárbol. El log del
servidor va a `logs/strata/`. Para comprobar la configuración sin cargar el modelo:

```powershell
& .\runtimes\strata\0.2.23\strata.cmd serve --profile .\strata\scripts\models\qwen3.8-flash-next-gsq-rco\text-131k.json --host 0.0.0.0 --port 8080 --plan
```

Con Inkling, `--plan` no consulta el motor: muestra `--draft dflash2` sin `--draft-beam 1 --draft-adapt` y avisa de
que el motor «no lee imágenes». Al arrancar, el servidor pregunta con `--info` (`images=1 spec_opts=1`) y pasa ambos.
