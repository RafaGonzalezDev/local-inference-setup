# LFM3 1.7B

## Publicación

- Modelo: [LiquidAI/LFM3-1.7B](https://huggingface.co/LiquidAI/LFM3-1.7B), revisión
  `40ebe0aa6662c9d40389c2f5d565b6a2c6aebacd`. Licencia LFM Open License v1.0 (`lfm1.0`), sin acceso
  restringido.
- GGUF oficial: [LiquidAI/LFM3-1.7B-GGUF](https://huggingface.co/LiquidAI/LFM3-1.7B-GGUF), revisión
  `b3f2ae5d73cd3c91bf40e8ba752c648aa05dffdf`.
- Artefacto: `LFM3-1.7B-Q8_0.gguf`, 1.846.238.496 bytes, SHA-256 LFS
  `8f6b24182258205e9e01e21f1f24a1f208c1e8115578825d202ce39976af20b6`.

## Arquitectura y capacidades

- Arquitectura GGUF `lfm3` (texto), 1,7B parámetros, contexto nativo 262.144 tokens
  (`max_position_embeddings`).
- Post-entrenado para arneses de agentes (la tarjeta cita Hermes Agent, Pi y OpenClaw): tool calling
  en XML, salidas estructuradas y búsqueda diferida de herramientas. La tarjeta no lo recomienda para
  programación agentic ni tareas con mucho conocimiento.
- Razona por defecto: la plantilla abre `<think>` en el turno del asistente. La tarjeta advierte que
  `enable_thinking=False` puede ser inconsistente en tareas de mucho razonamiento.
- Cuantización `Q8_0`: a este tamaño la memoria no limita. El repositorio publica también un `Q4_0`
  QAD (entrenado para recuperar la precisión de Q4) que no se instala.

## Runtime

Ninguna release oficial de llama.cpp soporta `lfm3` todavía (PR #31252, fusionada el 2026-10-27). El
perfil usa `19ff817-cuda13.4`, compilado desde el código fuente; ver
[backend](../inference-backend.md#source-built-runtime-19ff817). Al salir una release con soporte,
basta con cambiar la línea `SERVER` y repetir las pruebas.

## Perfil

| Lanzador | Contexto | Batch/UBatch | Visión | MTP | Alias de perfil |
| --- | ---: | --- | --- | --- | --- |
| `start-agentic-auto-262k-1024.cmd` | 262.144 | 1024/1024 | no | no | `lfm3-1.7b-262k` |

- Base del catálogo: `--gpu-layers auto --fit on --fit-target 1024`, ocho hilos, caché KV `q8_0`,
  Flash Attention, `--parallel 1`, `--cache-ram 0`, `--split-mode none`, Jinja y `--load-mode none`.
- `--reasoning auto` con presupuesto 8.192.
- Muestreo del perfil general de la tarjeta y `generation_config`: `--temp 0.1 --top-p 1 --top-k 50
  --min-p 0 --repeat-penalty 1.1`. Para matemáticas y ciencia la tarjeta recomienda
  `temperature 1.0, top_p 0.95, top_k 20` por petición.

## Validación (2026-10-28, runtime `19ff817-cuda13.4`)

- Integridad y `Test-Llm.ps1 -ConfigurationOnly -RequireInstalledFiles` sin filtros: 19 perfiles,
  0 fallos. Smoke `Test-Llm.ps1 -Model lfm3-1.7b`: correcto.
- `/props` confirma 262.144 tokens; `/v1/models` publica `lfm3-1.7b` y `lfm3-1.7b-262k`. La plantilla
  aplicada termina en `<|im_start|>assistant\n<think>`.
- Contrato de razonamiento: `chat_template_kwargs.enable_thinking: false` y
  `reasoning_effort: "none"` dejan `reasoning_content` vacío; `thinking_budget_tokens: 64` corta el
  razonamiento en ~36 palabras y el modelo sigue respondiendo en `content`. Sin límite, una pregunta
  aritmética corta agotó 600 tokens razonando: conviene un presupuesto o un `max_tokens` amplio.
- Tool calling: `get_weather` devuelve `finish_reason = tool_calls` con `{"location":"Madrid"}`.
- Prompt sintético de 154.425 tokens sin razonamiento: prefill 13.060 t/s, decode 157,6 t/s;
  decode corto ~270 t/s. VRAM pico 6.154 MiB (incluye ~1,4 GB del escritorio) y RAM libre mínima
  46.978 MiB: el modelo y la caché caben en la GPU con mucho margen.
- En ese prompt largo, la pregunta de recuperación («¿qué nodo informó en el paso 4321 y con qué
  temperatura?») se respondió mal (nodo 71, 73; lo correcto es 53, 95). No se evaluó calidad más
  allá de esta prueba.
- Registros: `logs/validation/contract-lfm3-1.7b-20261028-*.{json,log}` y
  `logs/validation/smoke-tests-20261028-001313-846-53187383.json`.

## Clientes

Registrado como `lfm3-1.7b-262k` en DSH, OpenCode y Pi con contexto 262.144 y salida máxima 32.768
(32.000 en OpenCode), y razonamiento desactivable con `enable_thinking`.

## Dependencias

- `config/models/lfm3-1.7b.psd1`
- `scripts/models/lfm3-1.7b/start-agentic-auto-262k-1024.cmd`
- `runtimes/llama.cpp/19ff817-cuda13.4/` (compilado con `scripts/setup/Build-LlamaRuntime.cmd`)
