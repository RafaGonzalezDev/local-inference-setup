# Sage-A1.5 35B A3B

- Modelo: `Sage-A1.5-Q4_K_M.gguf`
- Proyector: `Sage-A1.5-mmproj.gguf`
- Repositorio: `InternScience/Sage-A1.5-Q4_K_M-GGUF` (cuantización oficial de `InternScience/Sage-A1.5`)
- Revisión: `10b179b52f2c841030db327627e707d076b4c8cf`
- Licencia: `apache-2.0` (repositorio GGUF y modelo base).
- Alias API: `sage-a1.5-35b-a3b`
- Arquitectura GGUF: `qwen35moe`, la de `qwen3.6-35b-a3b`, del que deriva (MoE híbrida de atención y SSM;
  41 bloques, 256 expertos y 8 activos, contexto nativo 262.144). El GGUF conserva un bloque `nextn`
  (`nextn_predict_layers = 1`) para MTP. Proyector `clip` con `qwen3vl_merger`. Los metadatos del GGUF
  lo llaman `Agents A1.5`.

Es un modelo agentic de razonamiento con tool calling y visión. La plantilla abre `<think>` por
defecto y admite `enable_thinking: false` por petición.

## Artefactos

| Artefacto | Archivo | Tamaño | SHA-256 |
| --- | --- | ---: | --- |
| `Q4_K_M` (con MTP) | `Sage-A1.5-Q4_K_M.gguf` | 21.713.463.520 bytes | `a64fe0bbf936db3eb54f66f142c2b2eee569ade83673649f549a21daef8ca395` |
| Proyector F16 | `Sage-A1.5-mmproj.gguf` | 899.282.880 bytes | `51cd4410057e8dc4152ca771a726fbfb34856f047e7049018c757d42ddd481f2` |

SHA-256 LFS de la API de Hugging Face en la revisión fijada; ambos verificados tras la descarga. El
repositorio solo publica esta cuantización.

## Perfiles

| Lanzador | Contexto | Batch/UBatch | Visión | MTP | Alias de perfil |
| --- | ---: | ---: | :---: | :---: | --- |
| `start-agentic-auto-131k-2048.cmd` | 131.072 | 2048/2048 | no | no | `sage-a1.5-35b-a3b-131k` |
| `start-agentic-auto-262k-1024.cmd` | 262.144 | 1024/1024 | no | no | `sage-a1.5-35b-a3b-262k` |
| `start-agentic-auto-mtp-131k-1024.cmd` | 131.072 | 1024/1024 | no | sí, n-max 3 | `sage-a1.5-35b-a3b-mtp-131k` |
| `start-agentic-auto-vision-131k-2048.cmd` | 131.072 | 2048/2048 | sí | no | `sage-a1.5-35b-a3b-vision-131k` |

Los cuatro son copias de los perfiles de `qwen3.6-35b-a3b` con la misma arquitectura: `b11551-cuda13.4`,
`--fit-target 1024` (2048 en visión), caché KV `q8_0`, `--reasoning auto`, `--reasoning-budget 8192`,
`--image-min-tokens 2048` y `--spec-type draft-mtp --spec-draft-n-max 3`. Todos usan el mismo GGUF:
sin `--spec-type`, llama.cpp ignora los tensores `nextn` («unused tensor … ignoring»).

- Muestreo de InternScience: `--temp 1.0 --top-p 0.95 --top-k 20 --min-p 0 --presence-penalty 1.5
  --repeat-penalty 1`.
- `--reasoning-budget 8192`, `--image-min-tokens 2048` y `n-max 3` se heredan de Qwen3.6; la
  publicación no los fija.
- La tarjeta sugiere `--reasoning-format deepthink`; no se usa porque el formato por defecto ya
  separa el razonamiento en `reasoning_content`, como se comprobó.
- El modo de verificación es por petición (`chat_template_kwargs: {"verification": true}`, exige un
  mensaje de sistema no vacío) y la orquestación de subagentes depende de que el cliente registre
  `spawn_subagent`. Ninguno requiere cambios en los lanzadores; ninguno se ha probado.

## Calibración medida

`/props` confirma el contexto declarado y `/v1/models` publica el alias canónico y el de perfil;
`input_modalities` es `["text"]`, o `["text", "image", "video"]` en el perfil de visión.

| Perfil | Prompt largo | Prefill | Decode largo | Decode corto (1.024 tokens) | VRAM pico | RAM libre mínima |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| 131K | 102.639 | 2.774,32 t/s (37,0 s) | 57,31 t/s | 75,82 t/s | 15.649 MiB | 39.116 MiB |
| 262K | 239.463 | 1.494,79 t/s (160,2 s) | 41,72 t/s | 69,45 t/s | 15.721 MiB | 36.949 MiB |
| MTP 131K | 102.639 | 1.753,04 t/s (58,5 s) | 57,53 t/s | 80,75 t/s | 15.548 MiB | 37.708 MiB |
| Visión 131K | 102.639 | 2.512,06 t/s (40,9 s) | 51,66 t/s | 67,55 t/s | 14.854 MiB | 36.862 MiB |

- Una petición por carga, con `nvidia-smi` muestreado cada ~0,8 s; el escritorio ocupaba 1,4–1,5 GB
  de la tarjeta antes de cada arranque. Decode corto: prompt breve, `temperature 0`, 1.024 tokens.
- MTP: 649 de 1.119 borradores aceptados (58 %) en el decode corto y 149 de 318 en el largo. Gana
  un 6,5 % en decode corto, nada en decode largo y pierde un 37 % de prefill frente al perfil
  131K (ubatch 1024 frente a 2048 y el contexto borrador). La ganancia es marginal.
- Visión: la imagen `tests/assets/panels-1080p.png` (2.092 tokens de prompt) se describe
  correctamente como tres franjas verticales roja, verde y azul.
- Tool calling verificado en los cuatro perfiles: `get_weather` responde `finish_reason = tool_calls`
  con `arguments {"location":"Madrid"}` y razonamiento en `reasoning_content`.
- Presupuesto de arranques de diagnóstico con `--log-verbosity 4`:

| Perfil | Colocación `--fit` | Modelo GPU / host | KV (10 capas) | Estado recurrente | Cómputo GPU / host |
| --- | --- | ---: | ---: | ---: | ---: |
| 131K | 41 capas, 19 desbordadas; 1.118 MiB libres | 11.230 / 8.946 MiB | 1.360 MiB | 63 MiB | 1.152 / 608 MiB |
| 262K | 41 capas, 22 desbordadas; 1.128 MiB libres | 9.868 / 10.308 MiB | 2.720 MiB | 63 MiB | 1.144 / 560 MiB |
| MTP 131K | 42 capas, 22 desbordadas; 1.128 MiB libres | 10.767 / 9.930 MiB | 1.360 + 256 MiB borrador | 251 MiB | 634 + 336 / 288 + 272 MiB |
| Visión 131K | 41 capas, 23 desbordadas; 3.203 MiB libres | 9.145 / 11.031 MiB | 1.360 MiB | 63 MiB | 1.152 / 608 MiB |

  En visión el runtime estima 1.130,63 MiB para el proyector en el peor caso y lo resta antes de
  ajustar.
- `Test-Llm.ps1` pasa en los cuatro perfiles.

## Límites y no verificado

- No se ejercitó el contexto completo: los prompts más largos fueron 102.639 (131K) y 239.463 (262K)
  tokens. El prompt largo con imagen no se probó.
- No se probaron los modos de verificación ni de orquestación, ni cadenas de varias llamadas a
  herramientas.
- No se midió calidad; los resultados de la tarjeta corresponden a BF16, no a esta `Q4_K_M`.
- Los perfiles escuchan en `0.0.0.0:8080` sin autenticación: solo red privada de confianza y un
  perfil a la vez.

## Dependencias

- `config/models/sage-a1.5-35b-a3b.psd1`
- `scripts/models/sage-a1.5-35b-a3b/*.cmd`
- `runtimes/llama.cpp/b11551-cuda13.4/`

## Related ADRs

- [ADR-0001: lanzadores autocontenidos](../../adr/ADR-0001-self-contained-model-launchers.md)
