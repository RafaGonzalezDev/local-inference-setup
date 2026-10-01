# Ling 3.0 Tiny

- Modelo: `Ling-3.0-tiny-UD-Q6_K_XL.gguf`
- Repositorio: `bloomer010/Ling-3.0-tiny-GGUF`
- Alias API: `ling-3.0-tiny`
- Arquitectura GGUF: `bailingmoe3` (KDA + MLA hybrid)

## Arquitectura

- 7,9B parámetros totales y 1,3B activos por token.
- 24 capas: 18 KDA y 6 MLA.
- 128 expertos enrutados, 8 activos por token y 1 experto compartido.
- Contexto nativo de 131.072 tokens según el GGUF; el lanzador declara 262.144.
- Thinking activado por defecto y sin bloque MTP incluido.

## Artefacto

| Cuantización | Archivo | Tamaño | SHA-256 |
| --- | --- | ---: | --- |
| `UD-Q6_K_XL` | `Ling-3.0-tiny-UD-Q6_K_XL.gguf` | 7,27 GB | `de5734f3a9aa71e97d92653b11c5953a39c4877d6d368474af2d80ef51bfbb34` |

Fijado a la revisión `76d03bfc93a2b0ec84aac5f187cdf3793541e2a7`. Esta cuantización usa
`Q6_K` en los tensores principales de gate y up de los expertos, y `Q8_0` en
embeddings, salida, down projections, atención, Q-LoRA y KDA.

## MTP y DFlash

No hay modelo draft MTP publicado para Ling 3.0 Tiny. El repositorio no incluye
un checkpoint de draft DFlash público; la arquitectura KDA/MLA no combina con el
formato de especitación speculative actual. Si se requiere MTP en el futuro, la
arquitectura del modelo habría de reponerse con un sidecar compatible.

## Perfil

### Colocación automática

| Lanzador | Contexto | Batch/UBatch | Visión | MTP |
| --- | ---: | ---: | :---: | :---: |
| `start-agentic-auto-262k-1024.cmd` | 262.144 | 1.024/1.024 | no | no |

El lanzador declara contexto, batch/ubatch, muestreo, alias y puerto, y
materializa `--gpu-layers auto --fit on --fit-target 1024`. Con 262.144 tokens,
`--fit` resuelve `-ngl -1`: los 7,27 GB del modelo caben enteros en la GPU y no
descarga ninguna capa MoE.

Conserva los parámetros comunes del entorno: Flash Attention, Jinja, un único
slot, `--cache-ram 0`, `--split-mode none` y presupuesto de razonamiento sin
límite artificial (`--reasoning-budget -1`). El muestreo usa `temp 1.0`,
`top-p 0.95`, `top-k 20`, `min-p 0`, penalización de presencia 0 y penalización
de repetición 1 con `--reasoning on`.

La caché KV usa `q8_0` tanto para claves como para valores.

El contexto declarado de 262.144 tokens no demuestra que se haya probado un
prompt completo de ese tamaño ni amplía por sí solo el contexto nativo
documentado, que el GGUF fija en 131.072.

## Lanzador retirado

El perfil manual `start-agentic-262k-1024.cmd` (`--gpu-layers 999 --n-cpu-moe 8
--fit off`) se retiró el 2026-09-30. Su copia de referencia bajo
`logs\reference\retired-launchers-20260930\` se eliminó el 2026-10-01. Enviaba
8 capas MoE a la CPU, a diferencia del reparto automático, que no descarga
ninguna.

## Calibración histórica

Las mediciones siguientes corresponden al perfil anterior `text` que se
ejecutaba con `start-text.cmd` (contexto de 131.072 tokens y `n-cpu-moe 8`).
Se conservan como referencia histórica y no describen el lanzador actual de
262.144 tokens.

La memoria se comprueba con métricas nativas WDDM de Windows, no desde WSL, con
el servidor cargado; el Administrador de tareas muestra el mismo contador.
Objetivo de Rafa: entre 0,5 y 0,8 GB libres. El baseline del escritorio ocupa
aproximadamente 1,0-1,5 GB de los 16.302 MiB totales, por lo que el margen
efectivo varía con la sesión.

| Perfil | `n-cpu-moe` | WDDM usado | WDDM libre | prompt | decode |
| --- | ---: | --- | --- | ---: | ---: |
| `text` | 8 | ~12.000 MiB (11,7 GB) | ~0,8 GB | ~95 tok/s | ~78 tok/s |

Mediciones con una petición de 128 tokens de generación (razonamiento activo).
Cada capa MoE adicional en GPU libera ~0,5 GB de VRAM a costa de ~3 tok/s de
decode.

## Dependencias

- `config/models/ling-3.0-tiny.psd1`
- `scripts/models/ling-3.0-tiny/start-agentic-auto-262k-1024.cmd`
- `runtimes/llama.cpp/b11269-cuda13.4/`

## Validación histórica

Los resultados siguientes corresponden al perfil retirado de 131k. No se
atribuyen al perfil actual de 262k, sincronizado desde Windows el 2026-09-22.

- Integridad verificada contra el tamaño y SHA-256 fijados en el manifiesto.
- Configuración declarativa y paths instalados verificados para
  `start-agentic-131k-1024.cmd`.
- Prueba funcional superada en 4,28 segundos con el launcher
  `start-agentic-131k-1024.cmd`.
- El proceso terminó limpiamente y liberó el puerto 8080.

`llama.cpp` informa que `special_eos_id` no figura entre los identificadores
`special_eog_ids` del tokenizador. El aviso no bloqueó la carga ni la generación,
pero conviene volver a comprobarlo al actualizar el GGUF o el runtime.

## Related ADRs

- [ADR-0001: lanzadores autocontenidos](../../adr/ADR-0001-self-contained-model-launchers.md)
