# MiniCPM-V 4.7 35B A3B

- Modelo: `MiniCPM-V-4_7-35B-A3B-Q4_K_M.gguf`
- Repositorio: `openbmb/MiniCPM-V-4.7-35B-A3B-gguf`
- Revisión: `3c3f7e84f14a760ff26d17ab5932d4aa996227c0`
- Licencia: `apache-2.0` (repositorio público, no restringido)
- Alias API: `minicpm-v-4.7-35b-a3b`
- Arquitectura GGUF: `qwen35moe` (MoE híbrida SSM/atención, 35B totales y 3B activos, contexto nativo
  262.144 tokens) más proyector de visión `mmproj-model-f16.gguf` (compresión de tokens 16x; el autor
  indica SigLIP2 como módulo de visión)

El modelo base es `openbmb/MiniCPM-V-4.7-35B-A3B`; este repositorio publica los GGUF oficiales.

## Artefactos

| Cuantización | Archivo | Tamaño | SHA-256 |
| --- | --- | ---: | --- |
| `Q4_K_M` | `MiniCPM-V-4_7-35B-A3B-Q4_K_M.gguf` | 21.166.255.008 bytes | `bf3d1c67f7843193e4483aebd26c5dea6b6d1f6a06ffa03c2387a6f3cc6d7df5` |
| `F16` (mmproj 16x) | `mmproj-model-f16.gguf` | 1.119.575.840 bytes | `bff3b688e14c300eca273092c37c50a0ddfcc2054e079af1a0480edeed5d20f1` |

Ambos artefactos están fijados a la revisión `3c3f7e84f14a760ff26d17ab5932d4aa996227c0` y se
verificaron por tamaño y SHA-256 tras la descarga. El repositorio publica además el proyector 4x
(`mmproj-model-f16-4x.gguf`), las demás cuantizaciones y el borrador DSpark; solo se conserva lo que
usan los perfiles.

## Runtime

Este modelo necesita `runtimes\llama.cpp\b11551-cuda13.4`, que desde el 2026-10-13 es el runtime de
todo el catálogo; `b11269-cuda13.4` queda instalado como versión anterior para revertir.

El runtime `b11269` no lo soporta. El soporte de MiniCPM-V 4.7 se fusionó en `llama.cpp` el
2026-10-10 (PR #29416, commit de fusión `69f201a2051ea9b9e9b50c3cc56afd9e2ae64414`) y `b11551` es el
primer nightly que lo contiene: `compare/69f201a…b11551` responde `identical` y
`compare/69f201a…b11550` responde `behind_by=1`. Este GGUF usa la clave de metadatos
`qwen35moe.rope.section_order` (M-RoPE de lienzo) y un tensor `v.tok_embd_sep` en el proyector;
`b11269` no contiene ninguna de las dos cadenas en sus binarios, mientras que `b11551` contiene
`rope.section_order` en `llama.dll` y `tok_embd_sep` en `mtmd.dll`.

Instalación del runtime:

```powershell
powershell -NoProfile -ExecutionPolicy RemoteSigned -File scripts\setup\Install-LlamaRuntime.ps1 -Version b11551
```

## Perfiles

| Lanzador | Contexto | Batch/UBatch | Visión | Alias de perfil |
| --- | ---: | ---: | :---: | --- |
| `start-agentic-auto-131k-2048.cmd` | 131.072 | 2.048/2.048 | no | `minicpm-v-4.7-35b-a3b-131k` |
| `start-agentic-auto-262k-1024.cmd` | 262.144 | 1.024/1.024 | no | `minicpm-v-4.7-35b-a3b-262k` |
| `start-agentic-auto-vision-131k-2048.cmd` | 131.072 | 2.048/2.048 | sí | `minicpm-v-4.7-35b-a3b-vision-131k` |

Los tres comparten la configuración heredada de `qwen3.6-35b-a3b`, que usa la misma arquitectura: ocho
hilos, caché KV `q8_0`, Flash Attention, un slot (`--parallel 1`), `--cache-ram 0`,
`--split-mode none`, Jinja, `--reasoning auto` con presupuesto 8.192 y
`--gpu-layers auto --fit on`. El perfil de visión declara `--fit-target 2048` porque `--fit` no
contabiliza el proyector, y `--mmproj` apunta al proyector 16x de la misma publicación.

El perfil de 262.144 tokens usa el contexto nativo declarado por el GGUF y baja el lote a
1.024/1.024, como los demás perfiles de contexto largo del catálogo; es texto, sin proyector.

No se usa `--image-min-tokens`: el número de tokens de imagen lo decide el proyector (596 tokens
para el PNG de prueba de 1920x1080) y la guía de llama.cpp de este modelo no lo usa.

Muestreo y razonamiento:

- `--temp 0.7 --top-p 0.8 --top-k 100 --min-p 0 --presence-penalty 0 --repeat-penalty 1.05`
  proceden de la guía oficial de llama.cpp para v4.7 (Cookbook de MiniCPM-V), no de Qwen. El GGUF
  incrusta además `general.sampling.temp 1`, `top_p 0.95` y `top_k 20`; el lanzador materializa los
  valores de la guía y los sobrescribe.
- `--reasoning auto` con `--reasoning-budget 8192` es la convención local para perfiles agentic. La
  guía del modelo recomienda `--reasoning off` para respuestas directas; cambiarlo es editar esa
  línea del lanzador. La plantilla del modelo activa el pensamiento por defecto.

## Calibración medida

`/props` confirma el contexto declarado en cada perfil —131.072 en texto y visión, 262.144 en el de
contexto largo— y `/v1/models` publica `aliases: ["minicpm-v-4.7-35b-a3b", "<alias de perfil>"]`,
además de `capabilities: ["completion"]` en texto y `["completion","multimodal"]` en visión.

| Perfil | Petición representativa | Prefill | Decode | VRAM pico | RAM libre mínima |
| --- | --- | ---: | ---: | ---: | ---: |
| `agentic-auto-131k-2048` | 728 tokens de prompt, 200 de salida | 1.431,71 t/s (508,48 ms) | 75,32 t/s (13,28 ms/token) | 15.153 MiB | 36,0 GB |
| `agentic-auto-262k-1024` | 15.533 tokens de prompt, 128 de salida | 2.631,09 t/s (5.903,63 ms) | 66,33 t/s (15,08 ms/token) | 15.104 MiB | 35,1 GB |
| `agentic-auto-vision-131k-2048` | imagen 1920x1080 (596 tokens) + 749 de texto, 200 de salida | 1.095,63 t/s (1.227,60 ms) | 65,89 t/s (15,18 ms/token) | 14.268 MiB | 33,9 GB |

- Las cifras son de una sola petición por perfil, con `nvidia-smi` muestreado cada ~0,9 s: son picos
  observados, no máximos continuos. El escritorio ocupaba entre 1.497 y 2.148 MiB de la tarjeta
  antes de cada arranque.
- Carga completa del modelo: 6,8 s (texto) y 7,7 s (visión) según las marcas de tiempo del log.
- La respuesta de visión describe correctamente el fixture: tres paneles verticales rojo, verde y
  azul. Las respuestas traen `content` y `reasoning_content` separados, coherente con
  `--reasoning on` y `--jinja` (medido antes del cambio a `--reasoning auto`).
- Tool calling verificado con el perfil de texto: una petición con una función `get_weather` responde
  `finish_reason = tool_calls` y `arguments {"location":"Madrid"}`, con el razonamiento en
  `reasoning_content`.
- Misma carga en los dos perfiles de texto, una petición por celda: con un prompt de 728 tokens y 200
  de salida, decode de 75,32 t/s en el perfil de 131K y 72,87 t/s en el de 262K; con un prompt de
  15.533 tokens y 128 de salida, 72,67 frente a 66,33 t/s. La pérdida del 3–9 % no está aislada: el
  perfil de 262K reserva 1.360 MiB más de caché KV en la tarjeta y baja el ubatch de 2.048 a 1.024, y
  con esa misma carga el prefill cae de 3.992,99 a 2.631,09 t/s.
- `--fit` decide la colocación automáticamente; el reparto de expertos entre GPU y CPU depende de la
  memoria libre en el momento de arrancar y no se ha fijado por perfil.
- Presupuesto declarado a 262.144 tokens, de un arranque de diagnóstico con los mismos argumentos y
  `--log-verbosity 4`: caché KV `q8_0` de 2.720,00 MiB sobre las 10 capas de atención completa
  (10,88 KB por token, coherente con `head_count_kv = 2`, `key_length = value_length = 256`), estado
  recurrente de 62,81 MiB, cómputo de 1.136,30 MiB en GPU y 544,31 MiB en host, y búferes de modelo
  de 9.960,06 MiB en GPU y 10.215,18 MiB en memoria del sistema. El planificador coloca las 41
  entradas de capa con 23 desbordando expertos y deja 1.041 MiB libres en la tarjeta; el ajuste
  tardó 3,04 s y no redujo el contexto, porque estaba declarado.

## DSpark: probado y retirado

Se descargó y probó el borrador especulativo de la misma publicación
(`dspark-MiniCPM-V-4_7-35B-A3B-F16.gguf`, 789.442.368 bytes, SHA-256
`dbeca717b96448ecbb2240864ae00d2f90fe069bc3a8ce08c58084c8b7b96c0f`) con
`--spec-type draft-dspark --spec-draft-n-max 15 --spec-draft-ngl auto`.

El borrador se inicializa correctamente —el runtime registra `adding speculative implementation
'draft-dspark'`, `n_max=15`, `block_size=15`, `mask_token_id=248076`, `n_extract=5`,
`sample_from_anchor=true`— pero no acelera:

| Medición | Sin borrador | Con borrador DSpark |
| --- | ---: | ---: |
| Decode (200 tokens de salida) | 75,32 t/s | 3,29 t/s |
| Aceptación de borradores | — | 0,05921 (91 aceptados / 1.537 generados) |
| Longitud media aceptada | — | 1,84 |
| VRAM pico | 15.153 MiB | 15.927 MiB |
| RAM libre mínima | 36,0 GB | 31,8 GB |

Además, `--fit` no puede contabilizar el modelo extra: el log registra `failed to measure the memory
of the extra model, fitting without it`. Con esa aceptación y ese costo por token, el perfil se
retiró: no se publican lanzador ni artefacto. Las cifras quedan como registro; la ruta de
aceleración de MiniCPM-V 4.7 documentada por el autor (Lookahead Expert Scheduling) vive en el fork
`tc-mb/llama.cpp-omni`, que no se ha evaluado.

## Límites y no verificado

- Solo se probó el proyector 16x y una sola imagen; el 4x y el vídeo no se han descargado ni
  probado.
- El prompt más largo probado es de 15.533 tokens, en el perfil de 262.144: el contexto completo
  declarado no se ha ejercitado con un prompt de esa longitud, solo se ha comprobado su presupuesto
  de memoria en el arranque.
- No se probaron tool calling con imagen ni cadenas de varias llamadas.
- En el prefill multimodal el runtime emite `find_slot: non-consecutive token position … with 596 new
  tokens`; la descripción fue correcta, pero no se ha comprobado el efecto en imágenes mayores,
  múltiples o en vídeo.
- No se midió perplejidad, calidad ni lotes concurrentes (`--parallel 1` en ambos perfiles).
- Los perfiles escuchan en `0.0.0.0:8080` sin autenticación; solo red privada de confianza y un
  perfil a la vez.

## Dependencias

- `config/models/minicpm-v-4.7-35b-a3b.psd1`
- `scripts/models/minicpm-v-4.7-35b-a3b/start-agentic-auto-131k-2048.cmd`
- `scripts/models/minicpm-v-4.7-35b-a3b/start-agentic-auto-262k-1024.cmd`
- `scripts/models/minicpm-v-4.7-35b-a3b/start-agentic-auto-vision-131k-2048.cmd`
- `runtimes/llama.cpp/b11551-cuda13.4/`

## Related ADRs

- [ADR-0001: lanzadores autocontenidos](../../adr/ADR-0001-self-contained-model-launchers.md)
