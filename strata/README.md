# Qwen3.8 Flash Next con Strata

Subárbol propio para modelos servidos por [Strata](https://github.com/Niko1221/Strata), separado del catálogo de
llama.cpp. Su alias (el `model_name` de cada JSON) se registra en Pi, OpenCode y DSH como los del resto del catálogo
(desde el 2026-11-22).

| Pieza | Ruta |
| --- | --- |
| Catálogo y manifiesto | `strata/config/catalog.psd1`, `strata/config/models/qwen3.8-flash-next-gsq-rco.psd1` |
| Pesos (GGUF) | `models/qwen3.8-flash-next-gsq-rco/IQ3_XXS/` |
| Datos preparados por Strata | `models/qwen3.8-flash-next-gsq-rco/strata-data/` (paquete `packs/iq3_xxs`, borrador `dflash2/`) |
| Runtime | `runtimes/strata/0.2.18/` (Terminal 0.1.64, motor 0.1.64 CUDA 13, `strata.cmd`) |
| Lanzadores | `strata/scripts/models/qwen3.8-flash-next-gsq-rco/start-text-{131k,200k}.cmd` |
| Configuración del motor | `strata/scripts/models/qwen3.8-flash-next-gsq-rco/text-{131k,200k}.json` |
| Ficha | [qwen3.8-flash-next-gsq-rco](../docs/overview/models/qwen3.8-flash-next-gsq-rco.md) |

El Coder de ISTA-DASLab se probó y se retiró el mismo día (ver su
[ficha](../docs/overview/models/qwen3.8-flash-next-gsq-rco-coder.md)).

## Instalación

Todo el estado de Strata (componentes, ajustes, configuraciones) queda en `runtimes/strata/0.2.18/`:
`strata.cmd` redirige `LOCALAPPDATA`, `APPDATA`, `STRATA_DATA_DIR`, `STRATA_SETTINGS_FILE` y `STRATA_HOME`. No se
toca el `PATH` ni `%LOCALAPPDATA%\Strata` del usuario.

```powershell
# Terminal (install.ps1 of the v0.2.18 release, checked against install-manifest.txt and the signed feed)
$root = '.\runtimes\strata\0.2.18'
$env:LOCALAPPDATA = "$root\appdata\Local"; $env:STRATA_DATA_DIR = "$root\appdata\Local\Strata"
$env:STRATA_HOME = "$root\home"; $env:STRATA_NO_PATH = '1'
$env:STRATA_FEED = 'https://github.com/Niko1221/Strata/releases/download/v0.2.18'
& .\downloads\strata-0.2.18\install.ps1

# Engine, weights, model preparation and drafter
$feed = 'https://github.com/Niko1221/Strata/releases/download/v0.2.18'
& "$root\strata.cmd" update --yes --no-control --feed $feed
.\scripts\setup\Download-Model.ps1 -Model qwen3.8-flash-next-gsq-rco -RootDirectory .\strata
.\scripts\common\Test-ModelIntegrity.ps1 -RootDirectory .\strata
& "$root\strata.cmd" install --family qwen --model IQ3_XXS --gguf-dir .\models\qwen3.8-flash-next-gsq-rco\IQ3_XXS `
  --data-dir .\models\qwen3.8-flash-next-gsq-rco\strata-data --context 131072 --vision no --host 0.0.0.0 --port 8080 `
  --no-browser --drafter dflash2 --yes --no-start
& "$root\strata.cmd" drafting fetch --config "$root\appdata\Local\Strata\install\strata-iq3_xxs.json"
```

Los JSON de los lanzadores son copias de `strata-iq3_xxs.json` con `model_name` y `log` cambiados, más
`--vram-reserve-mib 1536` en `args` y, en el de 200K, `--max-context 204800`.

## Uso

```powershell
.\strata\scripts\models\qwen3.8-flash-next-gsq-rco\start-text-131k.cmd
```

Escucha en `0.0.0.0:8080` (API OpenAI y Anthropic en `/v1`), sin autenticación, como los perfiles de llama.cpp: solo
red privada y uno a la vez en ese puerto. Parada con `Ctrl+C`. `Test-Llm.ps1` no cubre este subárbol. El log del
servidor va a `logs/strata/`. Para comprobar la configuración sin cargar el modelo:

```powershell
& .\runtimes\strata\0.2.18\strata.cmd serve --profile .\strata\scripts\models\qwen3.8-flash-next-gsq-rco\text-131k.json --host 0.0.0.0 --port 8080 --plan
```
