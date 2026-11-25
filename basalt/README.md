# Inkling 2 Mini con Basalt

Subárbol propio para modelos servidos por [Basalt](https://github.com/jesdga95/basalt), un fork de Strata solo para
Blackwell (sm_120), separado del catálogo de llama.cpp. El alias de cada perfil es el `alias` de su JSON; se registra en
Pi, OpenCode y DSH como los del resto del catálogo.

| Pieza | Ruta |
| --- | --- |
| Catálogo y manifiesto | `basalt/config/catalog.psd1`, `basalt/config/models/inkling-2-mini-nvfp4-mx8.psd1` |
| Paquete del modelo (`.basalt`) | `models/inkling-2-mini-nvfp4-mx8/Inkling-2-Mini-NVFP4-MX8.basalt` |
| Runtime | `runtimes/basalt/0.5.7/` (archivo de la versión, DLL de CUDA 13.5 junto a `bin/basalt.exe`, `.venv` del servidor) |
| Lanzadores | `basalt/scripts/models/<model-id>/start-text-<ctx>.cmd` |
| Configuración del servidor | `basalt/scripts/models/<model-id>/text-<ctx>.json` |
| Ficha | [inkling-2-mini-nvfp4-mx8](../docs/overview/models/inkling-2-mini-nvfp4-mx8.md) |

## Instalación

El archivo de la versión no trae las bibliotecas de CUDA ni el entorno de Python. Las DLL (`cudart64_13`, `cublas64_13`,
`cublasLt64_13`) salen del paquete `cudart` de CUDA 13.5 que fija `Install-LlamaRuntime.ps1` para `b12359` y se copian
junto a `basalt.exe`: no se toca el `PATH`. Basalt 0.5.7 está compilado con CUDA 13.0.2; el runtime 13.5 es compatible
hacia atrás. `pip` se quedó colgado al instalar los requisitos con Python 3.14; se instalaron con `uv`.

```powershell
$dl = 'D:\LLM\downloads\basalt-0.5.7'; $rt = 'D:\LLM\runtimes\basalt\0.5.7'
# basalt-v0.5.7-windows-x64.zip: SHA-256 dfb71d0a91b114a2969d44524dcd85fcb0547e2ffadb2f5b3499885218122881 (digest of the GitHub release)
# cudart-llama-bin-win-cuda-13.5-x64.zip (llama.cpp b12359): SHA-256 c2bf4cc202bfbaaa7a0b75f5082457c3811326947bb216059b72839d844e9cba
Expand-Archive "$dl\basalt-v0.5.7-windows-x64.zip" "$dl\extract"
Move-Item "$dl\extract\basalt-v0.5.7-windows-x64" $rt
Expand-Archive "$dl\cudart-llama-bin-win-cuda-13.5-x64.zip" "$dl\cudart"; Copy-Item "$dl\cudart\*.dll" "$rt\bin\"
py -3.14 -m venv "$rt\.venv"
uv pip install --python "$rt\.venv\Scripts\python.exe" -r "$rt\requirements.txt"

.\scripts\setup\Download-Model.ps1 -Model inkling-2-mini-nvfp4-mx8 -RootDirectory .\basalt
.\scripts\common\Test-ModelIntegrity.ps1 -RootDirectory .\basalt
```

## Uso

```powershell
.\basalt\scripts\models\inkling-2-mini-nvfp4-mx8\start-text-262k.cmd
```

Escucha en `0.0.0.0:8080` (API OpenAI y Anthropic en `/v1`; página de estadísticas en `/`), sin autenticación, como
los perfiles de llama.cpp: solo red privada y uno a la vez en ese puerto. Parada con `Ctrl+C`. `Test-Llm.ps1` no cubre
este subárbol. El lanzador redirige `USERPROFILE` y `HOME` a `runtimes/basalt/0.5.7/home`, así que el log del motor
(`home/.cache/basalt/<id>/engine.log`) y la caché de conversaciones quedan en la carpeta del runtime. El servidor
escribe además sus totales persistentes en `text-<ctx>.totals.json`, junto al JSON del perfil (estado local, no se
espeja).
