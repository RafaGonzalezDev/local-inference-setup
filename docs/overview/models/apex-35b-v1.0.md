# Apex 35B V1.0

- Modelo: `Apex-35B-V1.0-Q4_K_S.gguf`
- Repositorio: `Apexintelligence-AI/Apex-35B-V1.0-GGUF` (cuantización oficial de
  `Apexintelligence-AI/Apex-35B-V1.0`, que parte de `Qwen/Qwen3.6-35B-A3B`)
- Revisión: `c585fe8de7387925133ab7a573916c2d7070d714` (cabeza de `main` el 2026-11-01); tarjeta
  principal consultada en `5105f8f9ed8fd8212a72da546bcbb4f01d2cfd68`
- Licencia: `apache-2.0`, sin acceso restringido
- Alias API: `apex-35b-v1.0`
- Arquitectura GGUF: `qwen35moe` (35B totales, ~3B activos; 40 capas, 3 Gated DeltaNet por cada
  Gated Attention; 256 expertos con 8 activos más uno compartido; `embedding_length` 2048 y
  `expert_feed_forward_length` 512; contexto nativo 262.144). Incluye una capa MTP
  (`nextn_predict_layers = 1`, `block_count = 41`). **Solo texto**: la publicación no trae proyector.

Modelo de propósito general orientado a código, herramientas y búsqueda. Su rasgo distintivo es el
razonamiento dinámico: decide en cada turno si piensa y durante cuánto.

## Elección de la cuantización

El usuario pidió primero `Q4_K_M` y la cambió por `Q4_K_S` al saber que, según la tarjeta, todas las
cuantizaciones salvo BF16, Q8_0, Q6_K, Q5_K_M y Q4_K_M usan imatrix (datos de calibración y método por
tensor de bartowski). La cabecera lo confirma: `quantize.imatrix.dataset` apunta a
`Apexintelligence-AI_Apex-35B-V1.0-calibration-v6.txt` (510 entradas, 550 chunks).

Tipos reales leídos de la cabecera (`general.file_type = 14`, Q4_K_S): Q4_K 118, Q8_0 252, Q6_K 2,
Q4_0 11 y F32 370 tensores. Los 11 Q4_0 pertenecen a la capa MTP. Las dimensiones son múltiplos de 256,
así que no hay sustitución de K-quants por tipos de bloque 32.

## Artefactos

| Cuantización | Archivo | Tamaño | SHA-256 |
| --- | --- | ---: | --- |
| `Q4_K_S` | `Apex-35B-V1.0-Q4_K_S.gguf` | 21.423.933.600 bytes | `79cbe5c8bb01891da3909d6d4971f3abfc86d888e1aa2ba27a7ea50f7c45ad3a` |

SHA-256 LFS de la API de Hugging Face en la revisión fijada; la descarga del 2026-11-01 se verificó por
tamaño y SHA-256. La publicación no ofrece una variante sin cabezal MTP.

## Perfiles

| Lanzador | Contexto | Batch/UBatch | Visión | Alias de perfil |
| --- | ---: | ---: | :---: | --- |
| `start-agentic-auto-131k-1024.cmd` | 131.072 | 1024/1024 | no | `apex-35b-v1.0-131k` |
| `start-agentic-auto-262k-1024.cmd` | 262.144 | 1024/1024 | no | `apex-35b-v1.0-262k` |

Copian la base del catálogo (Flint/Nail) salvo modelo, alias, muestreo y presupuesto de razonamiento:
`b11981-cuda13.4`, `--gpu-layers auto --fit on --fit-target 1024`, contexto explícito, 6 hilos,
`--cache-ram 8192`, caché KV `q8_0`, Flash Attention, `--parallel 1`, `--split-mode none`, Jinja,
`--load-mode none` y logs compactos. `MTP_ARGS` vacío por la política del catálogo (decisión del
usuario, 2026-10-28). Batch/ubatch no son óptimos medidos.

Muestreo y razonamiento:

- `--temp 1.0 --top-p 0.95 --top-k 20 --min-p 0` son los valores recomendados por el autor (también los
  de `generation_config.json`); `--presence-penalty 0 --repeat-penalty 1` son neutros.
- `--reasoning auto` y `--reasoning-budget -1`: sin tope en el servidor, porque la longitud del
  razonamiento es dinámica y la tarjeta reserva `max_tokens=65536` para razonamiento y respuesta. Los
  clientes acotan por petición con `thinking_budget_tokens`.
- La plantilla embebida termina en `<|im_start|>assistant\n<think>` y la tarjeta pide no sustituirla.
  Lee `enable_thinking` y `preserve_thinking`, pero no `reasoning_effort`: no hay niveles de esfuerzo,
  solo activar/desactivar y acotar por presupuesto.
- Clientes: solo `off` y dinámico (activado sin tope), decisión del usuario del 2026-11-01, porque un
  presupuesto no ajusta el esfuerzo de Apex, solo lo corta. OpenCode declara `off` y `dynamic` (sin
  `thinking_budget_tokens`); Pi, `off` y `high` sin campo de presupuesto; DSH, `off` y `high` enviando
  el presupuesto como `thinking_token_budget`, que `llama-server` ignora (atajo: el `compat` de la ruta
  no permite quitar el campo a un solo modelo). Verificado con servidor de captura (OpenCode, Pi) y con
  el servidor: `thinking_budget_tokens: 64` cortó el razonamiento en 46 palabras y
  `thinking_token_budget: 64` lo dejó en 587.
- `--reasoning-preserve` (activo por defecto en el runtime) conserva el razonamiento de turnos
  anteriores, como recomienda la tarjeta para multiturno y tool calling.

## Validación (2026-11-01, `b11981`)

- `Test-ModelIntegrity.ps1` y `Test-Llm.ps1 -ConfigurationOnly -RequireInstalledFiles` (22/22) pasan; el
  smoke pasa en ambos perfiles.
- `/props` informa `n_ctx` 131.072 y 262.144; `/v1/models` publica el alias canónico y el de perfil.
- Calibración bajo carga (VRAM total 16.303 MiB, ~1,1 GB ocupados por otros procesos antes de arrancar):

| Perfil | Prompt | Prefill | Generación | VRAM pico | RAM libre mínima |
| --- | ---: | ---: | ---: | ---: | ---: |
| 131K | 31.202 tokens | 2.487 tok/s | 70,8 tok/s | 15.328 MiB | 36,3 GB |
| 131K | 113.247 tokens | 2.228 tok/s | 58,2 tok/s | 15.331 MiB | 35,7 GB |
| 262K | 31.202 tokens | 2.219 tok/s | 64,2 tok/s | 15.327 MiB | 34,4 GB |
| 262K | 220.918 tokens | 1.701 tok/s | 43,2 tok/s | 15.331 MiB | 31,8 GB |

  Cada carga generó 1.536 tokens (corte por `max_tokens`). La carga desde caché de disco tardó ~6,5 s.
- Tool calling en ambos perfiles: `get_weather` con `arguments {"location":"Madrid"}`, `finish_reason
  tool_calls` y razonamiento separado en `reasoning_content`.
- Contrato de razonamiento (ambos perfiles): con una pregunta trivial razona brevemente (30–66 tokens);
  `enable_thinking: false` y `reasoning_effort: "none"` dejan `reasoning_content` vacío (4 tokens);
  `thinking_budget_tokens: 64` corta el razonamiento en ~45–48 palabras y el modelo responde después.
  `/apply-template` conserva el razonamiento de turnos previos.

Registros: `logs/validation/apex-35b-v1.0-*-20261101.json`.

## MTP medido (no habilitado)

A petición del usuario se comparó la generación con el perfil 131K sin MTP y una copia temporal con
`--spec-type draft-mtp --spec-draft-n-max 3` (receta de Qwen/Tiel/Nail; el log confirma
`creating MTP draft context`). Mismos prompts, `temperature 0`, `seed 1`, sin razonamiento salvo la
última fila, dos repeticiones (resultados casi idénticos; se muestra la media):

| Prompt | Sin MTP | Con MTP | Aceptación | Diferencia |
| --- | ---: | ---: | ---: | ---: |
| Código (LRU cache) | 80,2 tok/s | 94,0 tok/s | 70 % | +17 % |
| Prosa (relato de 500 palabras) | 80,5 tok/s | 57,0 tok/s | 28 % | −29 % |
| Razonamiento explicado | 80,1 tok/s | 99,8 tok/s | 78 % | +25 % |
| Razonamiento con `<think>` | 79,8 tok/s | 96,5 tok/s | 74 % | +21 % |

Con MTP las respuestas difieren algo de longitud pese a `temperature 0` (p. ej. 785 frente a 587 tokens
en prosa), por lo que la comparación es por tok/s, no por tiempo total. Con el muestreo real
(`temperature 1.0`) la aceptación suele ser menor que con greedy; no se midió. MTP sumó ~90 MiB de VRAM.
El resultado repite el patrón que motivó retirar MTP el 2026-10-28: gana en código y razonamiento,
pierde en prosa.

## Pendiente

- Calidad, contexto completo (262.144 tokens exactos) y comportamiento en Pi no evaluados.
- Rendimiento con MTP bajo `temperature 1.0` y en conversaciones reales no medido.
