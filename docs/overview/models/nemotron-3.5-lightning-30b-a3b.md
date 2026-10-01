# Nemotron 3.5 Lightning 30B A3B

- Modelo: `NVIDIA-Nemotron-3.5-Lightning-30B-A3B-NVFP4.gguf`
- Repositorio: `ggml-org/NVIDIA-Nemotron-3.5-Lightning-30B-A3B-GGUF`
- Revisión: `88d7ce0b0fa385c5108866ce5d33690927531a37`
- Alias API: `nemotron-3.5-lightning-30b-a3b`
- Arquitectura GGUF: `nemotron_h_moe` (híbrido Mamba/SSM + MoE, 53 bloques)

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

## Perfil

### Colocación automática

| Lanzador | Contexto | Visión | MTP |
| --- | ---: | :---: | :---: |
| `start-agentic-auto-131k-2048.cmd` | 131.072 | no | no |

El lanzador declara contexto, muestreo, alias y puerto, y materializa
`--gpu-layers auto --fit on --fit-target 1024`, que fija el margen libre como
objetivo. El modelo declara 53 bloques, así que `--fit` resuelve `-ngl 53`
(todas en GPU) y descarga a la CPU las FFN expertas de `blk.34` a `blk.52`, 19
entradas frente a las 23 capas del perfil manual retirado. La estimación de
`llama-fit-params.exe` con el escritorio reteniendo ~1,6 GiB deja 13.610 MiB en
GPU y 7.637 MiB en host, frente a 12.996 y 8.077 del reparto manual, en MiB y
sumando modelo, contexto y búfer de cómputo.

Conserva los parámetros comunes del entorno: ocho hilos, caché KV `q8_0`, Flash
Attention, un slot, `--cache-ram 0`, `--split-mode none`, Jinja y presupuesto de
razonamiento 8.192. El muestreo usa `temp 0.6`, `top-p 0.95`, `top-k 20` con
`--reasoning on`.

## Lanzador retirado

El perfil manual `start-agentic-131k-2048.cmd` (`--gpu-layers 999
--n-cpu-moe 23 --fit off`) se retiró el 2026-09-30. Su copia de referencia bajo
`logs\reference\retired-launchers-20260930\` se eliminó el 2026-10-01.

## Calibración histórica

Las mediciones siguientes corresponden a los perfiles anteriores `text` y
`agentic`, tal como se ejecutaban con `start-agentic.cmd` (contexto de 200.000
tokens y `n-cpu-moe 25`). Se conservan como referencia histórica y no describen
el lanzador actual.

La memoria se comprueba con métricas nativas WDDM de Windows, no desde WSL, con
el servidor cargado; el Administrador de tareas muestra el mismo contador.
Objetivo de Rafa: entre 1,0 y 1,3 GB libres. El baseline del escritorio ocupa
aproximadamente 1,5-2,5 GB de los 16.302 MiB totales, por lo que el margen
efectivo varía con la sesión.

| Perfil | `n-cpu-moe` | WDDM usado | WDDM libre | prompt | decode |
| --- | ---: | --- | --- | ---: | ---: |
| `text` | 20 | ~14.982 MiB (14,6 GB) | ~1,3 GB | ~103 tok/s | ~88 tok/s |
| `agentic` | 21 | ~15.082 MiB (14,7 GB) | ~1,2 GB | ~100 tok/s | ~81 tok/s |

Mediciones con una petición de 192 tokens de generación (razonamiento activo).
Cada capa MoE adicional en GPU libera ~0,65 GB de VRAM a costa de ~6 tok/s de
decode. `n-cpu-moe 22` en `text` dejó ~2,0 GB libres (fuera de rango por
exceso); `n-cpu-moe 20` en `agentic` dejó solo ~0,65 GB libres (fuera de rango
por defecto).

## Dependencias

- `D:/LLM/config/models/nemotron-3.5-lightning-30b-a3b.psd1`
- `D:/LLM/scripts/models/nemotron-3.5-lightning-30b-a3b/start-agentic-auto-131k-2048.cmd`
- `D:/LLM/scripts/common/Test-Llm.ps1`

## Related ADRs

- [ADR-0001: lanzadores autocontenidos](../../adr/ADR-0001-self-contained-model-launchers.md)
