# Ternary Bonsai 2.5 27B

- Modelo: `Ternary-Bonsai-2.5-27B-PTQ1_0.gguf` (sin MTP), `Ternary-Bonsai-2.5-27B-PTQ1_0-mtp.gguf` (con el
  cabezal MTP integrado) y proyector `Ternary-Bonsai-2.5-27B-mmproj-BF16.gguf`
- Repositorio: `prism-ml/Ternary-Bonsai-2.5-27B-GGUF` (base `Qwen/Qwen3.8-27B`)
- Revisión: `28a7093cc25bc151cc2b284c5570f12ce343fdcf` (cabeza de `main` el 2026-11-24)
- Licencia: Apache 2.0, sin acceso restringido
- Alias API: `ternary-bonsai-2.5-27b`
- Arquitectura GGUF: `qwen35` (denso de 27B, 64 bloques híbridos: 3 de cada 4 con atención lineal y 1 con
  atención completa, `n_head_kv` 4, cabeza 256; contexto nativo 262.144). Texto e imagen con el proyector.
- Runtime: **fork de PrismML** `prism-b12178-cuda13.3` (no el `b12359-cuda13.5` del resto del catálogo).

Pesos exactamente ternarios ({-1, 0, +1} con una escala FP16 por grupo de 128, en una base rotada por
Hadamard), 1,76 bits por peso. La publicación ofrece tres empaquetados del **mismo** modelo: `PTQ1_0`
(5,99 GB), `PQ2_0` (7,25 GB) y `Q2_0` (7,67 GB). Ninguno es más preciso que otro; solo cambia el formato y el
runtime que los lee. `Q2_0` funciona en llama.cpp oficial desde b11556, pero la tarjeta mide que el fork lo
decodifica más rápido (150 frente a 109 tok/s en H200) y que `PTQ1_0` es el más rápido en todas las GPU NVIDIA
probadas. Con el fork instalado se eligió `PTQ1_0`: el archivo más pequeño y el más rápido, sin pérdida frente
a los otros dos.

## Runtime

El soporte de `PTQ1_0` en llama.cpp oficial está en revisión ([#29672](https://github.com/ggml-org/llama.cpp/pull/29672),
CUDA en #29676) y llama.cpp oficial rechaza el tipo. Se instaló la release binaria `prism-b12178-03ec600`
de [PrismML-Eng/llama.cpp](https://github.com/PrismML-Eng/llama.cpp/releases/tag/prism-b12178-03ec600)
(publicada el 2026-11-24, CUDA 13.3 para Windows x64), con aprobación del usuario:

| Paquete | SHA-256 |
| --- | --- |
| `llama-prism-b12178-03ec600-bin-win-cuda-13.3-x64.zip` | `a34bdb817e797243f86c5e2dd1bdf118d17ea32b6eaa4e6f32c41533b13bc2d8` |
| `cudart-llama-bin-win-cuda-13.3-x64.zip` | `1462a050eb4c684921ba51dcc4cc488a036674c3e73e9945ee705b854808d03e` |

Hashes del `digest` de la API de GitHub; `Install-LlamaRuntime.ps1 -Version prism-b12178` los comprueba y
verifica `version: 0.7.0-dev (build 12178, commit 03ec60072)`. Es un binario precompilado, no una compilación
local. Solo lo usan los lanzadores de este modelo. Todos los flags de los lanzadores existen en su `--help`
(`--fit`, `--fit-target`, `--cache-ram`, `--load-mode none`, `--reasoning auto`, `--spec-type draft-mtp`,
`--spec-draft-p-min`, etc.).

## Artefactos

| Archivo | Tamaño | SHA-256 |
| --- | ---: | --- |
| `Ternary-Bonsai-2.5-27B-PTQ1_0.gguf` | 5.993.834.848 bytes | `929560ec9d37cf3cadd4b00cc87b51c570082a628dd830b4692dc0b2ed18dbbe` |
| `Ternary-Bonsai-2.5-27B-PTQ1_0-mtp.gguf` | 6.232.818.944 bytes | `e0fc5f3d47b9c926d52677d303b19df356a2376614b3e1cb9973865fc04ca431` |
| `Ternary-Bonsai-2.5-27B-mmproj-BF16.gguf` | 931.145.856 bytes | `e287342d92332fa3577ed1d42e921dac9370c08da58ba9337fa450f6cc76cfd7` |

SHA-256 LFS de la API de Hugging Face en la revisión fijada; las descargas se verificaron por tamaño y SHA-256.
El proyector BF16 se prefirió al `Q8_0` (629 MB) por precisión; la memoria lo permite. Se instala la variante
sin cabezal para los perfiles sin MTP, como pide la política del catálogo cuando la publicación la ofrece.

## Perfiles

| Lanzador | Contexto | Batch/UBatch | Visión | MTP | Alias de perfil |
| --- | ---: | ---: | :---: | :---: | --- |
| `start-agentic-auto-131k-1024.cmd` | 131.072 | 1024/1024 | no | no | `ternary-bonsai-2.5-27b-131k` |
| `start-agentic-auto-mtp-131k-1024.cmd` | 131.072 | 1024/1024 | no | sí | `ternary-bonsai-2.5-27b-mtp-131k` |
| `start-agentic-auto-vision-131k-1024.cmd` | 131.072 | 1024/1024 | sí | no | `ternary-bonsai-2.5-27b-vision-131k` |

Base común del catálogo: `--gpu-layers auto --fit on`, `--fit-target 1024` (texto y MTP) / `2048` (visión),
6 hilos, `--cache-ram 8192`, caché KV `q8_0`, Flash Attention, `--parallel 1` (la tarjeta lo recomienda para
GPU con poca VRAM), `--split-mode none`, Jinja, `--load-mode none`, logs compactos y `--reasoning-budget 8192`.

- Muestreo de la tarjeta en modo razonamiento: `--temp 1.0 --top-p 0.95 --top-k 20 --min-p 0
  --presence-penalty 0 --repeat-penalty 1` (`--min-p 0` explícito porque llama.cpp aplica 0,05 por defecto).
- MTP: cabezal integrado en el GGUF `-mtp`, sin archivo borrador externo. Receta del preset CUDA del autor
  (`presets/llama.cpp/mtp-cuda.json`, perfil Blackwell): `--spec-type draft-mtp --spec-draft-n-min 0
  --spec-draft-n-max 3 --spec-draft-p-min 0.1`.
- Razonamiento: la plantilla abre `<think>` por defecto con esfuerzo `xhigh` y solo acepta `xhigh`, `medium`
  y `low` (la tarjeta dice que `low` se comporta casi como `xhigh`). Con `--reasoning auto`, `/apply-template`
  confirma: sin esfuerzo y con `xhigh` inserta la instrucción de `xhigh`; `medium` no añade instrucción; `low`
  añade la suya; `reasoning_effort: "none"` cierra el bloque (`<think>\n\n</think>`) sin error.
- Visión: presupuesto de imagen por defecto del proyector; la imagen de prueba ocupó unos 2.000 tokens y se
  procesó con ubatch 1024 sin recortes.

### Por qué no hay perfiles de 262K

Con KV `q8_0` y el modelo entero en la GPU, el planificador estima 15.110 MiB (5.440 de pesos, 8.853 de
contexto y 816 de cómputo) frente a 14.985 MiB libres; con el margen de 1.024 MiB faltan 1.149 MiB y `--fit`
deja 8 de 65 capas en la CPU. Medido así, un prompt de 43.650 tokens se procesó a 1.078 tok/s y la generación
cayó a 10,2 tok/s. Haría falta que el resto del sistema ocupara menos de unos 140 MiB de VRAM. Se descartó;
una caché KV más pequeña (`q4_0` o `pq2_0m` del fork) lo permitiría a costa de precisión, sin evaluar.

## Validación (2026-11-25, `prism-b12178-cuda13.3`)

Con una videollamada con cámara activa durante las medidas: el escritorio ocupaba unos 1,4–2 GB de VRAM y la
llamada puede restar algo de velocidad. Una repetición por medida.

| Perfil | Prompt | Prefill | Generación | VRAM pico (total GPU) |
| --- | ---: | ---: | ---: | ---: |
| 131K | 26 tokens (relato, sin razonamiento) | — | 93,0 tok/s | — |
| 131K | 43.652 tokens | 1.528 tok/s | 76,5 tok/s | no registrado |
| MTP 131K | 26 tokens (relato) | — | 124,3 tok/s | — |
| MTP 131K | código Python, 1.024 tokens | — | 177,3 tok/s | — |
| MTP 131K | 43.652 tokens | 1.465 tok/s | 123,5 tok/s | 13.912 MiB |
| Visión 131K | imagen + texto, 2.060 tokens | 1.248 tok/s | 91,8 tok/s | 13.720 MiB |

- MTP: aceptación de borradores del 36 % en el relato (264/738), 66 % en código (679/1031) y 51 % con el prompt
  largo (254/495). Frente al perfil sin MTP, la generación sube 1,34 veces en el relato y 1,6 veces a 43K; el
  prefill baja un 4 %.
- `Test-Llm.ps1` (smoke) pasa en los tres perfiles; `/props` informa `n_ctx` 131.072 y `/v1/models` publica el
  alias canónico.
- Tool calling (MTP 131K, esfuerzo `medium`): `get_weather` con `{"city":"Madrid"}` y `finish_reason
  tool_calls`.
- Visión: describe correctamente la imagen de prueba (tres franjas verticales roja, verde y azul, 16:9).
- Cierre limpio: el puerto 8080 quedó libre tras cada prueba.

## Pendiente

- Comparar en Pi, como pide la guía para un runtime nuevo; calidad, contexto completo de 131K, `PQ2_0` y
  `Q2_0` sobre llama.cpp oficial no evaluados.
- El fork evoluciona deprisa (los kernels "in testing" de la tarjeta aún no están publicados); no se activaron
  variables de entorno experimentales (`LLAMA_MTP_PREFILL_LEAN`, `GGML_CUDA_*`).
