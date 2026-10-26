# Recursive Flint 40B A2.5B

- Modelo: `flint-UD-Q4_K_XL.gguf`
- Repositorio: `unsloth/flint-GGUF` (cuantización de `RecursiveSI/flint`)
- Revisión: `20468edfc38ab43d6914cc88b08cbecb05d0fc62`
- Licencia: el repositorio declara `apache-2.0` y publica `LICENSE`; los metadatos del GGUF dicen
  `general.license = other`, `general.license.name = flint-preview` y `general.name = Flint Preview`.
  La discrepancia no está aclarada en la publicación.
- Alias API: `flint`
- Arquitectura GGUF: `flint` (MoE de 39,8B totales y ~2,5B activos; 49 capas, 2 densas y 47 MoE con
  256 expertos, 6 activos más expertos compartidos; 35 capas de ventana deslizante de 513 tokens y 14
  de atención completa; 4 cabeceras KV; contexto nativo 262.144). **Solo texto**: no hay proyector ni
  cabezal MTP.

Es un modelo de razonamiento con tool calling, orientado a agentes de código.

## Runtime

Necesita `b11827-cuda13.4`. `b11551` no reconoce la arquitectura `flint`: el soporte oficial llegó en
el PR #30928 de `llama.cpp` (primer build `b11803`) y la plantilla necesita los escapes hexadecimales
del PR #30929. Ambos están en `b11827`.

La guía de Unsloth compila su fork `unslothai/llama.cpp` (rama `iq1-narrow`). No es necesario para
esta cuantización: todos los tensores de `UD-Q4_K_XL` son de tipos estándar (F32, BF16, Q8_0, Q4_K,
Q5_K, Q6_K, IQ3_S, IQ4_XS) y el build oficial los carga. Suponemos que la rama sirve para `UD-IQ1_M`;
no está verificado.

## Artefactos

| Cuantización | Archivo | Tamaño | SHA-256 |
| --- | --- | ---: | --- |
| `UD-Q4_K_XL` | `flint-UD-Q4_K_XL.gguf` | 25.054.688.704 bytes | `63c2ecc461ca545134b670c660e76fa20f47240f8d39b6510bfd21c4dd6e072f` |

El SHA-256 es el LFS que publica la API de Hugging Face en la revisión fijada; la descarga se verificó
por tamaño y SHA-256. El repositorio publica además `UD-IQ1_M` a `UD-Q6_K_XL`, `Q8_0`, `BF16` en tres
partes y el imatrix; solo se descargó la variante pedida.

## Perfiles

| Lanzador | Contexto | Batch/UBatch | Visión | Alias de perfil |
| --- | ---: | ---: | :---: | --- |
| `start-agentic-auto-131k-1024.cmd` | 131.072 | 1024/1024 | no | `flint-131k` |
| `start-agentic-auto-262k-1024.cmd` | 262.144 | 1024/1024 | no | `flint-262k` |

Ambos copian la estructura de los perfiles agentic de `qwen3.6-35b-a3b`:
`--gpu-layers auto --fit on --fit-target 1024`, contexto explícito, ocho hilos, caché KV `q8_0`,
Flash Attention, `--parallel 1`, `--cache-ram 0`, `--split-mode none`, Jinja y `--load-mode none`.
Batch/ubatch no son óptimos medidos. El perfil 131K se publicó como
`start-agentic-auto-131k-2048.cmd` con `2048/2048` y desde el 2026-10-25 usa `1024/1024`; el alias
`flint-131k` no cambia.

Muestreo y razonamiento:

- `--temp 1.0 --top-p 0.95 --top-k 20` son los valores recomendados por Recursive, que el GGUF repite
  en `general.sampling.*`. `--min-p 0 --presence-penalty 0 --repeat-penalty 1` son neutros, igual que
  en la guía de Unsloth.
- `--reasoning auto` con `--reasoning-budget -1`: la tarjeta pide al menos 32.768 tokens de salida
  en problemas difíciles, así que no se aplica el tope local de 8192.
- La plantilla termina en `<|assistant|>` sin abrir `<think>` (`/apply-template` devuelve
  `<|user|>Hi<|assistant|>`); el modelo abre el bloque por sí mismo y el runtime lo separa en
  `reasoning_content`. La plantilla no tiene interruptor de razonamiento.
- El runtime avisa de que conserva el razonamiento en el historial por defecto, que es lo que pide la
  tarjeta. Desactivarlo es añadir `--no-reasoning-preserve` a `RUNTIME_ARGS`.

## Calibración medida

`/props` confirma el contexto declarado de cada perfil y `/v1/models` publica
`aliases: ["flint", "flint-131k"]` o `["flint", "flint-262k"]` con `input_modalities: ["text"]`.

| Perfil | Carga | Prefill | Decode | VRAM pico | RAM libre mínima |
| --- | --- | ---: | ---: | ---: | ---: |
| 131K | 112.544 tokens de prompt, 256 de salida | 1.668,28 t/s (67,5 s) | 37,90 t/s | 15.657 MiB | 30.751 MiB |
| 262K | 225.076 tokens de prompt, 256 de salida | 929,64 t/s (242,1 s) | 27,85 t/s | 15.581 MiB | 33.022 MiB |

- Las mediciones del perfil 131K (en esta tabla y en la de diagnóstico) se tomaron el 2026-10-22 con
  el lanzador anterior, `batch/ubatch 2048/2048`; no se han repetido con `1024/1024`.
- Una petición por carga, con `nvidia-smi` muestreado cada ~0,8 s: son picos observados, no máximos
  continuos. El escritorio ocupaba 1,5–1,9 GB de la tarjeta antes de cada arranque.
- El decode se midió al final de prompts largos; no se midió con contexto corto.
- Presupuesto de un arranque de diagnóstico con los mismos argumentos y `--log-verbosity 4`:

| Perfil | Colocación `--fit` | Modelo GPU / host | KV completo (14 capas) | KV SWA (35 capas) | Cómputo GPU / host |
| --- | --- | ---: | ---: | ---: | ---: |
| 131K | 50 capas, 31 con expertos desbordados; 1.152 MiB libres | 10.839 / 13.050 MiB | 1.904 MiB | 102 MiB | 987 / 587 MiB |
| 262K | 50 capas, 35 con expertos desbordados; 1.173 MiB libres | 8.807 / 15.082 MiB | 3.808 MiB | 65 MiB | 1.132 / 548 MiB |

- Tool calling verificado en ambos perfiles: una petición con `get_weather` responde
  `finish_reason = tool_calls` con `arguments {"location":"Madrid"}` y el razonamiento en
  `reasoning_content`.
- `Test-Llm.ps1` pasa en ambos perfiles, y en `qwen3.6-35b-a3b/agentic-auto-131k-2048` con el runtime
  predeterminado.

## Límites y no verificado

- No se ejercitó el contexto completo de 262.144 tokens, solo hasta 225.076 de prompt; tampoco
  respuestas largas de 32K tokens de razonamiento.
- No se comprobó si `reasoning_effort: "none"` desactiva el razonamiento por petición: la plantilla
  no consume esa variable.
- No se probaron cadenas de varias llamadas a herramientas ni clientes reales.
- No se midió calidad ni perplejidad. El PR de soporte indica que el escalado adaptativo de
  activaciones de expertos cuesta un 10–30 % de velocidad; no se midió su efecto aquí.
- La discrepancia de licencia entre repositorio y GGUF no está resuelta.
- Los perfiles escuchan en `0.0.0.0:8080` sin autenticación: solo red privada de confianza y un
  perfil a la vez.

## Dependencias

- `config/models/flint.psd1`
- `scripts/models/flint/start-agentic-auto-131k-1024.cmd`
- `scripts/models/flint/start-agentic-auto-262k-1024.cmd`
- `runtimes/llama.cpp/b11827-cuda13.4/`

## Related ADRs

- [ADR-0001: lanzadores autocontenidos](../../adr/ADR-0001-self-contained-model-launchers.md)
