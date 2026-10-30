# Recursive Flint 40B A2.5B

- Modelo: `flint-UD-Q4_K_XL.gguf`
- Repositorio: `unsloth/flint-GGUF` (cuantización de `RecursiveSI/flint`)
- Revisión: `20468edfc38ab43d6914cc88b08cbecb05d0fc62` (sigue siendo la cabeza de `main` el 2026-10-30)
- Licencia: el repositorio declara `apache-2.0` y publica `LICENSE`; los metadatos del GGUF dicen
  `general.license = other`, `general.license.name = flint-preview` y `general.name = Flint Preview`
  (lectura de la instalación del 2026-10-22). La discrepancia no está aclarada en la publicación.
- Alias API: `flint`
- Arquitectura GGUF: `flint` (MoE de 39,8B totales y ~2,5B activos; 49 capas, 2 densas y 47 MoE con
  256 expertos, 6 activos más un experto compartido; 35 capas de ventana deslizante de 513 tokens y 14
  de atención completa; 4 cabeceras KV; contexto nativo 262.144). **Solo texto**: no hay proyector ni
  cabezal MTP.

Modelo de razonamiento con tool calling, entrenado desde cero por Recursive y orientado a agentes de
código. Se instaló el 2026-10-22, se retiró el 2026-10-26 y vuelve el 2026-10-30 con la misma revisión
y el mismo archivo ([changelog](../../changelog/2026-10-30-flint.md)).

## Runtime

Usa `b11981-cuda13.4` (elección del usuario, 2026-10-30), el runtime de todo el catálogo desde ese día.
El anterior, `b11551`, no reconoce la arquitectura `flint`: el soporte oficial llegó en el PR
#30928 de `llama.cpp` (primer build `b11803`) y la plantilla necesita los escapes hexadecimales del PR
#30929. La instalación anterior usó `b11827`.

La guía de Unsloth compila su fork `unslothai/llama.cpp`. No hace falta para esta cuantización: sus
tensores son de tipos estándar (F32, BF16, Q8_0, Q4_K, Q5_K, Q6_K, IQ3_S, IQ4_XS, leídos en la
instalación anterior) y el build oficial los cargó.

## Artefactos

| Cuantización | Archivo | Tamaño | SHA-256 |
| --- | --- | ---: | --- |
| `UD-Q4_K_XL` | `flint-UD-Q4_K_XL.gguf` | 25.054.688.704 bytes | `63c2ecc461ca545134b670c660e76fa20f47240f8d39b6510bfd21c4dd6e072f` |

SHA-256 LFS de la API de Hugging Face en la revisión fijada; la descarga del 2026-10-30 se verificó por
tamaño y SHA-256. El repositorio publica además `UD-IQ1_M` a `UD-Q6_K_XL`, `Q8_0`, `BF16` en tres
partes y el imatrix; solo se descargó la variante pedida.

## Perfiles

| Lanzador | Contexto | Batch/UBatch | Visión | Alias de perfil |
| --- | ---: | ---: | :---: | --- |
| `start-agentic-auto-131k-1024.cmd` | 131.072 | 1024/1024 | no | `flint-131k` |
| `start-agentic-auto-262k-1024.cmd` | 262.144 | 1024/1024 | no | `flint-262k` |

Provisionales: copian la base actual del catálogo (Nail) salvo runtime, modelo, alias y muestreo:
`--gpu-layers auto --fit on --fit-target 1024`, contexto explícito, 6 hilos, `--cache-ram 8192`, caché
KV `q8_0`, Flash Attention, `--parallel 1`, `--split-mode none`, Jinja, `--load-mode none` y logs
compactos. Batch/ubatch no son óptimos medidos.

Muestreo y razonamiento:

- `--temp 1.0 --top-p 0.95 --top-k 20` son los valores recomendados por Recursive, que el GGUF repite
  en `general.sampling.*`. `--min-p 0 --presence-penalty 0 --repeat-penalty 1` son neutros.
- `--reasoning auto` con `--reasoning-budget 8192`, como el resto del catálogo. Ese valor solo rige
  cuando la petición no trae presupuesto: Pi envía `thinking_budget_tokens` en cada nivel
  (1.024–12.288), que lo sustituye. La tarjeta pide al menos 32.768 tokens de salida en problemas
  difíciles; si el razonamiento se queda corto, el ajuste es subir o quitar el tope (`-1`).
- `/apply-template` devuelve `<|user|>Hi<|assistant|>`: la plantilla no abre `<think>`; el modelo abre
  el bloque por sí mismo y el runtime lo separa en `reasoning_content`.
- La tarjeta pide conservar `reasoning_content` en el historial, que es el comportamiento por defecto
  del runtime.

## Contrato de razonamiento medido (2026-10-30, `b11981`)

Mismo problema aritmético en ambos perfiles (`max_tokens 6144`), una petición por variante:

| Petición | Resultado |
| --- | --- |
| Sin parámetros | Razona (711 y 950 tokens) en `reasoning_content`; responde `201`, correcto |
| `chat_template_kwargs.enable_thinking: false` | **Sigue razonando** (506 y 368 tokens); la plantilla ignora la variable |
| `reasoning_effort: "none"` | **Sigue razonando** (756 y 686 tokens) |
| `thinking_budget_tokens: 256` | Corta el razonamiento en 256 tokens exactos y responde `201` |
| `thinking_budget_tokens: 0` | **Rompe la salida**: no hay `reasoning_content` y el razonamiento sale en `content` terminado en `</think>` (1.452 tokens); con `enable_thinking: false` añadido, igual (361 tokens) |

Conclusión: el razonamiento no se puede desactivar por petición; solo se acota con
`thinking_budget_tokens` mayor que 0. Un nivel «off» de cliente debe enviar como mucho
`enable_thinking: false` (inofensivo), nunca presupuesto 0.

## Calibración medida (2026-10-30, `b11981`)

Lanzadores actuales. Una petición por carga, `nvidia-smi` y RAM libre muestreados cada ~0,7 s (picos
observados, no máximos continuos); el escritorio ocupaba ~1,25 GB de la tarjeta antes de arrancar.
Prompt de documentación del repositorio repetida, 256 tokens de salida; el decode corto es un ensayo
de 1.536 tokens con prompt de 18.

| Perfil | Prompt largo | Prefill | Decode largo | Decode corto | VRAM pico | RAM libre mínima |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| 131K | 112.342 tokens | 1.410,02 t/s (85,4 s de pared) | 45,15 t/s | 70,96 t/s | 15.492 MiB | 35.822 MiB |
| 262K | 224.527 tokens | 1.073,16 t/s (217,3 s de pared) | 32,33 t/s | 63,88 t/s | 15.640 MiB | 31.599 MiB |

- `/props` confirma `n_ctx` 131.072 y 262.144; `/v1/models` publica `["flint", "flint-131k"]` y
  `["flint", "flint-262k"]`. Carga en 5,6–12 s (pesos en caché del sistema).
- El margen de VRAM en 262K es de ~660 MiB sobre 16.303 MiB, similar al de la instalación anterior.
- Tool calling verificado en ambos perfiles: `get_weather` devuelve `finish_reason = tool_calls` con
  `{"location":"Madrid"}` y razonamiento separado; el segundo turno, con el resultado de la
  herramienta y el razonamiento conservado en el historial, responde con los datos (17 °C, soleado).
- `Test-Llm.ps1` (smoke) pasa en ambos perfiles. Tras cada prueba el puerto 8080 y la VRAM quedaron
  liberados.
- No se ejercitaron el contexto completo ni respuestas de 32K tokens.

## Comparación propia con Nail (2026-10-30)

`nail-qwen3.6-35b-a3b/agentic-auto-131k-1024` (`b11551`) frente a `flint/agentic-auto-131k-1024`
(`b11981`): el runtime difiere, así que no separa modelo de runtime. Mediciones sintéticas desde
PowerShell, no a través de Pi.

| Medida | Flint | Nail |
| --- | ---: | ---: |
| Prefill con 112K de prompt | 1.410 t/s | 1.909 t/s |
| Decode con 112K de contexto | 45,2 t/s | 57,7 t/s |
| Decode con contexto corto | 70,5–72,5 t/s | 78,2–79,4 t/s |
| VRAM pico | 15.492–15.679 MiB | 15.619 MiB |

Longitud del razonamiento con los valores por defecto del lanzador (`--reasoning-budget 8192`), cuatro
prompts (aritmética, función Python, depuración de PowerShell, comparación SQLite/PostgreSQL), dos
ejecuciones cada uno:

| Prompt | Flint: tokens de razonamiento | Nail: tokens de razonamiento |
| --- | --- | --- |
| Aritmética | 329, 374 | 902, 457 |
| Función Python | 644, 409 | 2.619, 2.265 |
| Depuración | 750, 3.454 | 2.730, 2.284 |
| Comparación | 625, 653 | 2.235, 1.695 |
| **Total (tiempo de pared)** | **7.238 (118,7 s)** | **15.187 (206,4 s)** |

Flint razonó menos de la mitad que Nail y terminó antes pese a decodificar más despacio, con una
ejecución atípica de 3.454 tokens. Muestra pequeña (n = 2 por prompt) y sin evaluar la calidad de las
respuestas.

## Mediciones históricas

Con `b11827`, 8 hilos, `--cache-ram 0` y batch `2048/2048` en 131K, el 2026-10-22:

| Perfil | Carga | Prefill | Decode | VRAM pico | RAM libre mínima |
| --- | --- | ---: | ---: | ---: | ---: |
| 131K | 112.544 tokens de prompt, 256 de salida | 1.668,28 t/s (67,5 s) | 37,90 t/s | 15.657 MiB | 30.751 MiB |
| 262K | 225.076 tokens de prompt, 256 de salida | 929,64 t/s (242,1 s) | 27,85 t/s | 15.581 MiB | 33.022 MiB |

Tool calling verificado entonces en ambos perfiles (`finish_reason = tool_calls`, razonamiento en
`reasoning_content`). Con los lanzadores actuales, el prefill es menor (1.410 frente a 1.668 t/s
en 131K) y el decode largo mayor (45,2 frente a 37,9); cambian a la vez runtime, hilos, caché de
prompts y batch, así que no se atribuye la diferencia a ninguno.

## Comparación publicada con Qwen3.6-35B-A3B

Cifras del autor (gráfico de `RecursiveSI/flint`, BF16, pass@1; las de Qwen son las declaradas por
Qwen salvo que se indique). No son mediciones propias ni de esta cuantización.

| Benchmark | Flint BF16 | Flint NVFP4 | Qwen3.6-35B-A3B |
| --- | ---: | ---: | ---: |
| Terminal-Bench 2.1 | 54,9 | 53,7 | 44,9 |
| SWE-bench Pro v2 (medido por Recursive) | 89,7 | 88,5 | 73,8 |
| SWE-bench Verified | 74,2 | 74,1 | 73,4 |
| LiveCodeBench v6 | 80,3 | 80,8 | 80,4 |
| IFBench | 89,2 | 88,1 | 67,9 |
| IFEval | 95,1 | 94,6 | 89,6 |

## Pendiente

- Comparación de rendimiento con Nail a través de Pi, que es el criterio del usuario para runtimes.
- Calidad de las respuestas frente a Nail en tareas reales.
- La discrepancia de licencia entre repositorio y GGUF no está resuelta.
- Los perfiles escuchan en `0.0.0.0:8080` sin autenticación: solo red privada de confianza y un
  perfil a la vez.

## Dependencias

- `config/models/flint.psd1`
- `scripts/models/flint/start-agentic-auto-131k-1024.cmd`
- `scripts/models/flint/start-agentic-auto-262k-1024.cmd`
- `runtimes/llama.cpp/b11981-cuda13.4/`

## Related ADRs

- [ADR-0001: lanzadores autocontenidos](../../adr/ADR-0001-self-contained-model-launchers.md)
