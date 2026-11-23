# Modelos servidos por Strata

Subárbol propio para modelos servidos por [Strata](https://github.com/Niko1221/Strata), separado del catálogo de
llama.cpp. El alias de cada perfil es el `model_name` de su JSON; se registra en Pi, OpenCode y DSH como los del
resto del catálogo (desde el 2026-11-22).

| Pieza | Ruta |
| --- | --- |
| Catálogo y manifiestos | `strata/config/catalog.psd1`, `strata/config/models/<model-id>.psd1` |
| Pesos de Flash-Next (GGUF) | `models/qwen3.8-flash-next-gsq-rco/IQ3_XXS/` |
| Datos preparados de Flash-Next | `models/qwen3.8-flash-next-gsq-rco/strata-data/` (paquete `packs/iq3_xxs`, borrador `dflash2/`) |
| Pesos de Inkling 2 Mini (GGUF de Unsloth y borrador DSpark) | `models/inkling-2-mini-ud-q4_k_xl/` |
| Tokenizador de Inkling (extraído del GGUF) | `models/inkling-2-mini-ud-q4_k_xl/strata-data/packs/inkling-2-mini-ud-q4_k_xl/tokenizer/` |
| Runtime en uso | `runtimes/strata/0.2.20/` (Terminal 0.1.66; `strata-engine` y `strata-inkling` 0.1.66 CUDA 13; `strata.cmd`) |
| Runtime anterior | `runtimes/strata/0.2.19/` (Terminal y motor 0.1.65), sin lanzadores; se conserva para volver atrás |
| Lanzadores | `strata/scripts/models/<model-id>/start-text-<ctx>.cmd` |
| Configuración del motor | `strata/scripts/models/<model-id>/text-<ctx>.json` |
| Fichas | [qwen3.8-flash-next-gsq-rco](../docs/overview/models/qwen3.8-flash-next-gsq-rco.md), [inkling-2-mini-ud-q4_k_xl](../docs/overview/models/inkling-2-mini-ud-q4_k_xl.md) |

El Coder de ISTA-DASLab se probó y se retiró el mismo día (ver su
[ficha](../docs/overview/models/qwen3.8-flash-next-gsq-rco-coder.md)). Inkling 2 Mini SQ-15 se probó con Strata 0.2.19 y
se retiró el mismo día (ver su [ficha](../docs/overview/models/inkling-2-mini-sq-15.md)); vuelve con 0.2.20 en el
GGUF `UD-Q4_K_XL` de Unsloth.

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
# strata.cmd: copy of the 0.2.19 wrapper pointing at terminal\0.1.66.
# The installer writes run configs into appdata\Local\Strata\install, which it does not create.
New-Item -ItemType Directory "$root\appdata\Local\Strata\install" -Force

# Main engine
& "$root\strata.cmd" update --yes --no-control --feed $env:STRATA_FEED

# Qwen3.8 Flash Next: weights and model preparation (the pack and DFlash2 drafter from 0.2.18 are reused unchanged)
.\scripts\setup\Download-Model.ps1 -Model qwen3.8-flash-next-gsq-rco -RootDirectory .\strata
& "$root\strata.cmd" install --family qwen --model IQ3_XXS --gguf-dir D:\LLM\models\qwen3.8-flash-next-gsq-rco\IQ3_XXS `
  --data-dir D:\LLM\models\qwen3.8-flash-next-gsq-rco\strata-data --context 131072 --vision no --host 0.0.0.0 --port 8080 `
  --no-browser --drafter dflash2 --yes --no-start

# Inkling 2 Mini UD-Q4_K_XL: weights, then the strata-inkling component, tokenizer and expert split (once per context)
.\scripts\setup\Download-Model.ps1 -Model inkling-2-mini-ud-q4_k_xl -RootDirectory .\strata
& "$root\strata.cmd" install --family inkling-2-mini --model UD-Q4_K_XL --gguf-dir D:\LLM\models\inkling-2-mini-ud-q4_k_xl `
  --data-dir D:\LLM\models\inkling-2-mini-ud-q4_k_xl\strata-data --context 131072 --vision no --host 0.0.0.0 --port 8080 `
  --no-browser --yes --no-start

.\scripts\common\Test-ModelIntegrity.ps1 -RootDirectory .\strata
```

Los JSON de Flash-Next son copias de `install\strata-iq3_xxs.json` con `model_name` y `log` cambiados, más
`--vram-reserve-mib 1536` en `args` y, en los de 200K y 262K, `--max-context 204800` o `262144`. Los de Inkling son
copias de `install\strata-inkling-2-mini-ud-q4_k_xl.json`, generado una vez por contexto (cambia el reparto de
expertos), con `model_name`, `log` y `--dspark <archivo>` añadidos. El servidor lee `args`, no `args_written`: un
cambio va en ambos, junto con `model_name` y `log`.

## Uso

```powershell
.\strata\scripts\models\qwen3.8-flash-next-gsq-rco\start-text-131k.cmd
.\strata\scripts\models\inkling-2-mini-ud-q4_k_xl\start-text-131k.cmd
```

Escucha en `0.0.0.0:8080` (API OpenAI y Anthropic en `/v1`), sin autenticación, como los perfiles de llama.cpp: solo
red privada y uno a la vez en ese puerto. Parada con `Ctrl+C`. `Test-Llm.ps1` no cubre este subárbol. El log del
servidor va a `logs/strata/`. Para comprobar la configuración sin cargar el modelo:

```powershell
& .\runtimes\strata\0.2.20\strata.cmd serve --profile .\strata\scripts\models\qwen3.8-flash-next-gsq-rco\text-131k.json --host 0.0.0.0 --port 8080 --plan
```

Con Inkling, `--plan` avisa de que el motor "no tiene borrador DSpark" porque el plan no consulta el ejecutable; al
arrancar, el servidor sí lo consulta (`--info`) y añade `--draft dspark`.
