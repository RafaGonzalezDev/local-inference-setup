# Nemotron 3.5 Lightning 30B A3B

- Modelo: `NVIDIA-Nemotron-3.5-Lightning-30B-A3B-NVFP4.gguf`
- Repositorio: `ggml-org/NVIDIA-Nemotron-3.5-Lightning-30B-A3B-GGUF`
- Revisión: `88d7ce0b0fa385c5108866ce5d33690927531a37`
- Alias API: `nemotron-3.5-lightning-30b-a3b`
- Arquitectura GGUF: `nemotron_h_moe`

El artefacto GGUF no es NVFP4 puro: los MLP usan `NVFP4` (93 tensores), mientras
que atención, Mamba y embeddings permanecen en `BF16` (81 tensores) y las escalas
y normalizaciones en `F32`. La RTX 5080 acelera el formato NVFP4 por hardware
(FP4 nativo de Blackwell). El contexto nativo declarado en el GGUF es 1.048.576
tokens.

Este artefacto requiere el runtime `b10361` o posterior: el esquema de tensores
NVFP4 (escalas `.scale`) y la arquitectura `nemotron_h_moe` con cabeza NextN no
cargan en `b10273` (`wrong number of tensors; expected 510, got 501`).

## MTP y DFlash

El GGUF incorpora una cabeza NextN embebida (`nextn_predict_layers = 1`,
`blk.52.nextn.*`), pero se descartó el uso de MTP tras la calibración: con
`--spec-type draft-mtp` el decode pasó de ~88 a ~61-65 tok/s (draft a CPU,
aceptación 0,80) y el grafo especulativo añadió ~2,5 GB de VRAM. Sin
`--spec-type`, los tensores de la capa NextN se ignoran al cargar. NVIDIA
publica además un checkpoint de draft DFlash
(`NVIDIA-Nemotron-3.5-Lightning-30B-A3B-NVFP4-DFlash`, safetensors, 833M
parámetros); a fecha de integración no existe versión GGUF pública del sidecar.

## Perfiles

| Lanzador | Contexto | `n-cpu-moe` | MTP |
| --- | ---: | ---: | :---: |
| `start-agentic-131k-2048.cmd` | 131.072 | 23 | no |

El lanzador `start-agentic-131k-2048.cmd` materializa un perfil agentic con
131.072 tokens de contexto y `n-cpu-moe 23`. Conserva los parámetros comunes
del entorno: ocho hilos, caché KV `q8_0`, Flash Attention, un slot, `--gpu-layers
999`, `--cache-ram 0`, `--split-mode none`, `--fit off`, Jinja y presupuesto
de razonamiento 8.192. El muestreo usa `temp 0.6`, `top-p 0.95`, `top-k 20`
con `--reasoning on`.

La caché KV usa `q8_0` tanto para claves como para valores. El perfil materializa
`--gpu-layers 999` y deja el resto de parámetros en su valor declarado.

## Calibración histórica

Las mediciones siguientes corresponden a los perfiles anteriores `text` y
`agentic`, tal como se ejecutaban con `start-agentic.cmd` (contexto de 200.000
tokens y `n-cpu-moe 25`). Se conservan como referencia histórica y no describen
el lanzador actual de 131.072 tokens con `n-cpu-moe 23`.

La memoria se comprueba con métricas nativas WDDM de Windows, no desde WSL, con
el servidor cargado; el Administrador de tareas muestra el mismo contador.
Objetivo de Rafa: entre 1,0 y 1,3 GB libres. El baseline del escritorio ocupa
aproximadamente 1,5-2,5 GB de los 16.302 MiB totales, por lo que el margen
efectivo varía con la sesión.

| Perfil | `n-cpu-moe` | WDDM usado | WDDM libre | prompt | decode |
| --- | ---: | ---: | ---: | ---: | ---: |
| `text` | 20 | ~14.982 MiB (14,6 GB) | ~1,3 GB | ~103 tok/s | ~88 tok/s |
| `agentic` | 21 | ~15.082 MiB (14,7 GB) | ~1,2 GB | ~100 tok/s | ~81 tok/s |

Mediciones con una petición de 192 tokens de generación (razonamiento activo).
Cada capa MoE adicional en GPU libera ~0,65 GB de VRAM a costa de ~6 tok/s de
decode. `n-cpu-moe 22` en `text` dejó ~2,0 GB libres (fuera de rango por
exceso); `n-cpu-moe 20` en `agentic` dejó solo ~0,65 GB libres (fuera de rango
por defecto).

## Dependencias

- `/mnt/d/LLM/config/models/nemotron-3.5-lightning-30b-a3b.psd1`
- `/mnt/d/LLM/scripts/models/nemotron-3.5-lightning-30b-a3b/start-agentic-131k-2048.cmd`
- `/mnt/d/LLM/scripts/common/Test-Llm.ps1`

## Related ADRs

- [ADR-0001: lanzadores autocontenidos](../../adr/ADR-0001-self-contained-model-launchers.md)
