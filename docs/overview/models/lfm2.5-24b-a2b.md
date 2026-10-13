# LFM2.5 24B A2B

- Modelo: `LFM2.5-24B-A2B-Q4_K_M.gguf`
- Repositorio: `LiquidAI/LFM2.5-24B-A2B-GGUF`
- Revisión: `f97fc8a443da86c71818adf91baecde5b7ef4c50`
- Licencia: `lfm1.0` (Liquid Foundation Model Open License v1.0; el repositorio publica el texto en
  `LICENSE`). No es una licencia permisiva tipo Apache: revisar sus términos antes de un uso comercial.
- Alias API: `lfm2.5-24b-a2b`
- Arquitectura GGUF: `lfm2moe` (MoE híbrida de convolución corta y atención, 24B totales y 2B activos,
  contexto nativo 131.072 tokens, vocabulario de 128.000). **Solo texto**: el repositorio no publica
  proyector multimodal.

Es un modelo de razonamiento: la plantilla abre ` thinking` al empezar cada respuesta, y anuncia
tool calling como capacidad principal.

## Artefactos

| Cuantización | Archivo | Tamaño | SHA-256 |
| --- | --- | ---: | --- |
| `Q4_K_M` | `LFM2.5-24B-A2B-Q4_K_M.gguf` | 14.526.258.464 bytes | `d3334405b96228eb9908cdebb5c6194908f2da64282bda852afc3a3910c64e7d` |

Fijado a la revisión `f97fc8a443da86c71818adf91baecde5b7ef4c50` y verificado por tamaño y SHA-256
tras la descarga. El repositorio publica además `Q5_K_M`, `Q6_K`, `Q8_0`, `F16`, `BF16` y un
`QAD-Q4_0` con destilación consciente de cuantización; solo se descargó la variante pedida.

## Perfiles

| Lanzador | Contexto | Batch/UBatch | Visión | Alias de perfil |
| --- | ---: | ---: | :---: | --- |
| `start-agentic-auto-131k-2048.cmd` | 131.072 | 2.048/2.048 | no | `lfm2.5-24b-a2b-131k` |

Hay un solo perfil, y es deliberado:

- **No hay 262K**: el GGUF declara 131.072 tokens nativos y el catálogo respeta el límite nativo.
- **No hay perfil de visión**: la publicación no incluye proyector (`mmproj`); este modelo es de texto.
  Una variante VL sería otro modelo, con su propio repositorio y proyector.
- **No hay perfil especulativo**: el repositorio no publica cabezal MTP ni borrador.

El perfil comparte la configuración de los perfiles agentic del catálogo: `b11551-cuda13.4`,
`--gpu-layers auto --fit on --fit-target 1024`, contexto explícito, ocho hilos, caché KV `q8_0`,
Flash Attention, `--parallel 1`, `--cache-ram 0`, `--split-mode none`, Jinja y `--load-mode none`.

Muestreo y razonamiento:

- `--temp 0.1 --top-k 50 --repeat-penalty 1.05` son los valores del `generation_config.json` del
  modelo base, que el GGUF repite como `general.sampling.temp`, `general.sampling.top_k` y
  `general.sampling.penalty_repeat`. La publicación no fija `top_p` ni `min_p`: el lanzador los deja
  en su valor neutro (`--top-p 1 --min-p 0 --presence-penalty 0`) para no truncar más de lo que pide
  el autor.
- `--reasoning on` con `--reasoning-budget 8192` es la convención local para perfiles agentic. El
  modelo siempre piensa, así que el presupuesto es un tope, no una activación.
- El runtime avisa de que la plantilla conserva el razonamiento en el historial por defecto
  (`preserve_reasoning kwarg: true`, «may use more tokens»). Desactivarlo es añadir
  `--no-reasoning-preserve` al grupo `RUNTIME_ARGS`.

## Calibración medida

Contexto declarado 131.072; `/props` lo confirma y `/v1/models` publica
`aliases: ["lfm2.5-24b-a2b", "lfm2.5-24b-a2b-131k"]` y `input_modalities: ["text"]`.

| Carga | Prefill | Decode | VRAM pico | RAM libre mínima |
| --- | ---: | ---: | ---: | ---: |
| 742 tokens de prompt, 200 de salida | 2.693,69 t/s (275,46 ms) | 122,83 t/s (8,14 ms/token) | 15.419 MiB | 42,5 GB |
| 15.862 tokens de prompt, 128 de salida | 8.251,88 t/s (1.922,23 ms) | 131,36 t/s (7,61 ms/token) | 15.541 MiB | 42,3 GB |

- Una petición por carga, con `nvidia-smi` muestreado cada ~0,9 s: son picos observados, no máximos
  continuos. El escritorio ocupaba ~1,3 GB de la tarjeta antes de cada arranque.
- Carga completa del modelo: 4,2–5,0 s según las marcas de tiempo del log.
- Presupuesto declarado a 131.072 tokens, de un arranque de diagnóstico con los mismos argumentos y
  `--log-verbosity 4`: `--fit` coloca 41 entradas de capa con 7 desbordando tensores de atención
  (13.816 MiB usados, 1.166 MiB libres), búferes de modelo de 11.603,95 MiB en GPU y 2.446,58 MiB en
  memoria del sistema, caché KV `q8_0` de 1.360,00 MiB (10,88 KB por token: 10 capas de atención con
  8 cabeceras KV cada una), estado recurrente de 0,47 MiB y cómputo de 852,09 MiB en GPU más
  576,10 MiB en host. El ajuste tardó 2,10 s y no redujo el contexto, porque estaba declarado.
- Tool calling verificado: una petición con la función `get_weather` responde
  `finish_reason = tool_calls` con `arguments {"location":"Madrid"}` y el razonamiento en
  `reasoning_content`. El runtime reconoce la plantilla con su ruta especializada
  («Using specialized template: LFM2.5»).

## Límites y no verificado

- El prompt más largo probado es de 15.862 tokens: el contexto completo de 131.072 no se ha
  ejercitado, solo su presupuesto de memoria.
- No se probaron cadenas de varias llamadas a herramientas ni el modo JSON de tool calling (el modelo
  escribe llamadas «pythonicas» por defecto; el runtime las normaliza a `tool_calls`).
- No se midió calidad ni perplejidad, y no hay comparación con las otras cuantizaciones del
  repositorio.
- La licencia `lfm1.0` impone condiciones propias; no se ha revisado su compatibilidad con cada uso.
- Los perfiles escuchan en `0.0.0.0:8080` sin autenticación: solo red privada de confianza y un
  perfil a la vez.

## Dependencias

- `config/models/lfm2.5-24b-a2b.psd1`
- `scripts/models/lfm2.5-24b-a2b/start-agentic-auto-131k-2048.cmd`
- `runtimes/llama.cpp/b11551-cuda13.4/`

## Related ADRs

- [ADR-0001: lanzadores autocontenidos](../../adr/ADR-0001-self-contained-model-launchers.md)
