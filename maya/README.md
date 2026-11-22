# Inkling 2 Mini con maya-ik2

Subárbol propio para modelos servidos por `maya-ik2`, el motor de Inkling 2 de
[maya-inkling-mini](https://github.com/alesha-pro/maya-inkling-mini) (fork de Project Maya), separado del
catálogo de llama.cpp. Sus alias (`inkling-2-mini-131k`, `inkling-2-mini-262k`, el `model_name` de cada JSON) se
registran en Pi, OpenCode y DSH como los del resto del catálogo (desde el 2026-11-22). El motor se revisa
periódicamente contra su upstream: ver la [ficha](../docs/overview/models/inkling-2-mini.md#revisión-periódica-del-motor).

| Pieza | Ruta |
| --- | --- |
| Catálogo y manifiesto | `maya/config/catalog.psd1`, `maya/config/models/inkling-2-mini.psd1` |
| Pesos | `models/inkling-2-mini/` (compartido con el resto de `models/`) |
| Runtime | `runtimes/maya-ik2/e819852-cuda13.4/` (checkout fijado, `build/`, `.venv/`, `ik2/tokenizer/`) |
| Lanzadores | `maya/scripts/models/inkling-2-mini/start-text-{131k,262k}.cmd` |
| Configuración del motor | `maya/scripts/models/inkling-2-mini/text-{131k,262k}.json` |
| Ficha | [inkling-2-mini](../docs/overview/models/inkling-2-mini.md) |

## Instalación

Pesos, con los scripts comunes:

```powershell
.\scripts\setup\Download-Model.ps1 -Model inkling-2-mini -RootDirectory .\maya
.\scripts\common\Test-ModelIntegrity.ps1 -RootDirectory .\maya
```

Runtime, compilado desde el código fuente (no hay binarios publicados). Toolchain: VS 2022 Build Tools
(MSVC 19.44.35222, con su CMake 3.31.6 y Ninja), CUDA 13.4.59 y Python 3.14:

```powershell
$dst = '.\runtimes\maya-ik2\e819852-cuda13.4'
git init $dst; git -C $dst remote add origin https://github.com/alesha-pro/maya-inkling-mini.git
git -C $dst fetch --depth 1 origin e819852f822479af783638a467bfdfe2ed6882ec; git -C $dst checkout FETCH_HEAD
# In a cmd with vcvars64.bat loaded, from $dst:
#   cmake -S . -B build -G Ninja -DCMAKE_BUILD_TYPE=Release -DSTRATA_ENABLE_CUDA=ON -DCMAKE_CUDA_ARCHITECTURES=120 -DSTRATA_BUILD_TESTS=OFF
#   cmake --build build -j 6 --target maya-ik2
# Copy cublas64_13.dll and cublasLt64_13.dll from CUDA\v13.4\bin\x64 into build\ (the global PATH is not changed).
py -3.14 -m venv "$dst\.venv"
& "$dst\.venv\Scripts\python.exe" -m pip install numpy jinja2 regex pyyaml tqdm requests pillow psutil "jsonschema>=4.18,<5" huggingface_hub
& "$dst\.venv\Scripts\python.exe" "$dst\tools\strata_tokenizer.py" --gguf .\models\inkling-2-mini\Inkling-2-Mini-UD-Q4_K_XL.gguf `
  --out "$dst\ik2" --chat-template "$dst\tools\ik2\chat_template.jinja" --check
```

El tokenizador se escribe en `ik2/tokenizer/` porque depende del GGUF y de la plantilla de ese commit.

## Uso

```powershell
.\maya\scripts\models\inkling-2-mini\start-text-262k.cmd
```

Escucha en `0.0.0.0:8080` (API OpenAI y Anthropic en `/v1`), sin autenticación, como los perfiles de llama.cpp:
solo red privada y uno a la vez en ese puerto. Parada con `Ctrl+C`. `Test-Llm.ps1` no cubre este subárbol:
valida lanzadores de `llama-server`. El servidor escribe su log y el del motor en `logs/maya/`.
