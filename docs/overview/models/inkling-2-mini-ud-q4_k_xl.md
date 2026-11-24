# inkling-2-mini-ud-q4_k_xl (Strata)

> **De vuelta el 2026-11-24 con Strata 0.2.21**, a petición del usuario: GGUF reeditado de Unsloth, borrador
> `mtp.safetensors` de Thinking Machines y razonamiento activo. Lo vigente está en «Strata 0.2.21 (2026-11-24)», al
> final; el resto de la ficha describe la prueba con 0.2.20 (retirada el 2026-11-23, ver el
> [changelog](../../changelog/2026-11-23-inkling-2-mini-ud-q4_k_xl-removal.md)).

Inkling 2 Mini de Thinking Machines (transformer en bucle de 24 capas, las 12 centrales recorridas tres veces;
MoE de 128 expertos, 8 activos por token; 26,2B parámetros, 3,4B activos y unos 5,4B efectivos por token; contexto
nativo de 1M) en el GGUF dinámico `UD-Q4_K_XL` de Unsloth, con el borrador DSpark. Servido por el motor
`strata-inkling` de Strata 0.2.20, no por llama.cpp. Solo texto y **sin razonamiento**. Instalación y uso en
[strata/README.md](../../../strata/README.md).

Sustituye al SQ-15 probado y retirado el 2026-11-22 (ver su [ficha](inkling-2-mini-sq-15.md)): 0.2.20 corrige los
dos fallos que lo limitaban a unos 32K en este equipo (ver «Modo híbrido en 0.2.20»).

## Procedencia

| Artefacto | Dato |
| --- | --- |
| Repositorio | [unsloth/Inkling-2-Mini-GGUF](https://huggingface.co/unsloth/Inkling-2-Mini-GGUF), revisión `8078d149286eec7193795413b9e0643da6d11fa1` |
| Modelo | `Old_Support/Inkling-2-Mini-UD-Q4_K_XL.gguf_file`, guardado como `Inkling-2-Mini-UD-Q4_K_XL.gguf`; 17.629.759.456 bytes, SHA-256 `e62d463c135ffe283df8d94b279a96ca145ac128b52ce854478613045bf4de15` |
| Borrador DSpark | `dspark-Inkling-2-Mini-Q8_0_Old.gguf`, guardado como `dspark-Inkling-2-Mini-Q8_0.gguf`; 402.278.560 bytes, SHA-256 `2ec78510da837e8fc3be54a14757a0c5fbd2d8d9e85a0d92853fafdf674f3773` |
| Tokenizador | Extraído del GGUF por `strata-inkling --export-tokenizer` (plantilla de 6.868 bytes) |
| Licencia | Apache 2.0, con la política de uso aceptable de Thinking Machines; MIT (Strata) |
| Motor | Strata 0.2.20: `strata-inkling` 0.1.66 `windows-x86_64-cuda-cuda13`, feed firmado (secuencia 132) |

**Por qué `Old_Support/`.** Strata 0.2.20 fija en `strata_control/inkling_family.py` el tamaño y el SHA-256 de cada
GGUF de Unsloth y los descarga de `main`. Unsloth volvió a subir los archivos de la raíz el 2026-11-23 (16:29 UTC):
el `UD-Q4_K_XL` de la raíz es ahora de 17.629.760.736 bytes (`e6427665…`), y el que fija Strata pasó a
`Old_Support/`, igual que el borrador DSpark (`_Old`). Se instalan los fijados por Strata, que coinciden byte a byte
con su código; la descarga automática de Strata fallaría con la revisión actual de `main`. La tarjeta no explica qué
cambió en la raíz. `Mainline_Support/` son los mismos tensores con la disposición de llama.cpp oficial.

SHA-256 del LFS de Hugging Face, comprobados por `Download-Model.ps1` y `Test-ModelIntegrity.ps1`.

## Calidad publicada

Datos de Unsloth frente a `UD-Q8_K_XL`: KLD medio 0,0107 y el mismo primer token en el 98,0 % (`UD-IQ4_XS`: 0,0109
y 97,7 %; `UD-Q3_K_XL`: 0,0174 y 96,3 %). Strata afirma que su SQ-15 supera a `UD-Q4_K_XL`; sin verificar aquí.

## Perfiles

| Lanzador | Contexto | Modelo en la API (`model_name`) | Expertos en VRAM / RAM | Puerto |
| --- | ---: | --- | --- | --- |
| `start-text-131k.cmd` | 131.072 | `inkling-2-mini-ud-q4_k_xl-131k` | 11,27 / 4,21 GB | `0.0.0.0:8080` |
| `start-text-262k.cmd` | 262.144 | `inkling-2-mini-ud-q4_k_xl-262k` | 10,74 / 4,74 GB | `0.0.0.0:8080` |
| `start-text-1m.cmd` | 1.048.576 | `inkling-2-mini-ud-q4_k_xl-1m` | 7,52 / 7,96 GB | `0.0.0.0:8080` |

- Contextos elegidos por el usuario (2026-11-23). El de 1M es el nativo; el menú de Strata llega a 262K, pero el
  motor admite 1.048.576 (`MAX_CONTEXT`). La etiqueta `1m` sigue la convención binaria de las demás (1.048.576).
- Argumentos: los que escribe `strata install` para este equipo y cada contexto (`--native`, `--max-context`,
  `--vram-experts-gb`, `--ram-experts-gb`), más `--dspark` con la ruta del borrador. El motor también lo encuentra solo
  junto al modelo, pero así no depende de qué haya en la carpeta. El instalador detecta el GGUF como `.strata` al
  pasarle `--model` y no añade `--dspark` (fallo de Strata).
- Al arrancar, el servidor consulta `--info` y añade `--draft dspark` (comprobado con `inkling_kind.engine_args`).
  `serve --plan` avisa de lo contrario porque no consulta el ejecutable.
- KV global en FP16 (32 KiB por token; lo que el instalador elige con `--kv-offload auto`), sobre todo en RAM: unos
  4,3 GB a 131K, 8,6 GB a 262K y 34,4 GB a 1M. El KV del borrador (4 KiB por token) va en VRAM: unos 0,5, 1,1 y
  4,3 GB; por eso el perfil de 1M deja menos expertos en VRAM. `--kv fp8` reduciría a la mitad el KV global; no se usa.
- Estimación de RAM a 1M, sin medir: unos 42 GB entre expertos y KV, más el servidor y el sistema, de 61,9 GB.
  Solo cabe con el equipo dedicado a la inferencia; nunca a la vez que Flash-Next (además comparten puerto).
- Sin `--vram-reserve-mib`: en 0.2.20 el motor reserva por su cuenta el KV, el espacio de prefill, DSpark y un
  margen para WDDM antes de repartir los expertos, y la fórmula del instalador incluye 1,6 GB para driver y
  escritorio. Sin comprobar bajo carga.
- Sin visión: no se descargó el `mmproj` ni el fragmento de visión.
- **Sin razonamiento.** Strata sigue sirviendo Inkling con `reasoning_effort: "none"` y `enable_thinking: false`
  (`serve/inkling_dialect.py`, `HAS_THINKING = False`). La tarjeta del modelo advierte de que el mínimo no desactiva
  del todo el razonamiento; Strata descarta lo que produzca.

## Modo híbrido en 0.2.20

Leído en el código fuente de `engine/src/inkling2/` de v0.2.20, comparado con v0.2.19:

- `cuda/ink_runner.cuh` aplica `--vram-experts-gb` y `--ram-experts-gb` y reserva antes el margen de KV, prefill,
  DSpark y WDDM. En 0.2.19 el backend rápido los ignoraba y llenaba la VRAM.
- El KV global se reparte entre VRAM y RAM fija mapeada (`--kv-offload auto|on|off`, por defecto `auto`) en lugar de
  recortar el contexto (en 0.2.19: 131.072 → 6.400).
- `ink_serve.h` valida el prompt contra el contexto efectivo (`effective_max_ctx`) y lo anuncia en `READY`/`HELLO`.
  En 0.2.19 lo validaba contra el pedido y un prompt mayor que el recortado escribía fuera del búfer (CUDA error 700).

Las notas de la versión citan además la corrección de salidas `NaN` con prompts de 24K a 45K y de fallos de arranque
con `exit code 3`.

## Pruebas

- `Download-Model.ps1` y `Test-ModelIntegrity.ps1 -RootDirectory .\strata`: los 4 artefactos del subárbol.
- `strata install` (componente `strata-inkling` con la firma y los archivos comprobados, tokenizador extraído).
- `strata-inkling.exe --info`: `format=gguf build=GGUF-NVFP4 drafter=dspark images=1`.
- `strata serve --plan` con los tres JSON: alias, contexto, reparto, host y puerto correctos.
- Sin arranque, inferencia ni calibración: las pruebas las hace el usuario desde Pi (decisión del usuario,
  2026-11-23). Pendiente: memoria real a 262K y 1M, velocidad y tool calling.

## Prueba del usuario (2026-11-23)

1. **Los tres perfiles se cerraban al arrancar** con `strata-inkling: missing tensor
   'dspark.layers.0.self_attn.o_proj.weight'`, después de cargar el modelo. Fallo de Strata 0.2.20 (también en
   `main` ese día): `ink_gguf_loader.h` traduce los tensores del borrador GGUF a `layers.<n>.…`, sin el prefijo
   `dspark.`, y el backend CUDA (`cuda/ink_runner.cuh` y `cuda/ink_manifest.hpp`) copia los nombres tal cual y los
   busca con el prefijo, sin alternativa (`InkManifest::get` termina el proceso). El archivo estaba bien (54
   tensores, 3 capas). Los `.strata` guardan el prefijo, por eso el SQ-15 sí cargaba DSpark. El motor encuentra
   cualquier `dspark-*.gguf` junto al modelo, así que quitar `--dspark` no bastaba.
2. **Con `"drafting": "off"`** (el servidor pasa `--draft off`, que impide inicializar DSpark) el perfil de 262K
   arrancó. El usuario midió menos de 20 tok/s de generación desde Pi y lo dio por inutilizable; el log solo
   registra la carga, no las peticiones.
3. **Causas probables, según el log de carga:** 1.025 de 3.072 expertos (6,17 GiB) en RAM paginable, por encima
   del tope de 4,21–4,74 GiB que calculó el instalador; todo el KV global en RAM (0 tokens en VRAM, con 1,46 GiB
   libres); el bucle recorre tres veces las 12 capas centrales por token; y sin borrador. A 1M, el motor recortó el
   contexto a 454.528 tokens por la RAM disponible.

## Strata 0.2.21 (2026-11-24)

Vuelve con el mismo ID y los mismos tres alias. Motor `strata-inkling` 0.1.67 (`windows-x86_64-cuda-cuda13`) de Strata
0.2.21, instalado en `runtimes/strata/0.2.21/` (feed firmado, secuencia 133). Los lanzadores de Flash-Next siguen en
0.2.20.

| Artefacto | Dato |
| --- | --- |
| Modelo | `Inkling-2-Mini-UD-Q4_K_XL.gguf` de la raíz de [unsloth/Inkling-2-Mini-GGUF](https://huggingface.co/unsloth/Inkling-2-Mini-GGUF), revisión `8078d149286eec7193795413b9e0643da6d11fa1`; 17.629.760.736 bytes, SHA-256 `e64276656f072e9b2197a61723667cbdb71da66a716ffd966e572c21088f3cd3` |
| Borrador DSpark | `mtp.safetensors` de [thinkingmachines/Inkling-2-Mini](https://huggingface.co/thinkingmachines/Inkling-2-Mini), revisión `1fb4134b9a74f9681054f4ef82e4bf1f458a2337`; 635.801.416 bytes (BF16), SHA-256 `7c3b651317f01f73bcf4e1dceba66ef8b7e1a1eac6bc171e882e690a4b10a1d2`; Apache 2.0 |
| Tokenizador | Extraído del GGUF por `strata-inkling --export-tokenizer` (plantilla de 6.868 bytes) |

SHA-256 del LFS de Hugging Face, comprobados por `Download-Model.ps1` y `Test-ModelIntegrity.ps1`.

**Por qué estos archivos.** El GGUF es la versión reeditada por Unsloth el 2026-11-23 (disposición de llama.cpp
oficial, +1.280 bytes). Strata 0.2.21 lo acepta junto al que fija (`ALT_GGUF_FILES` en
`strata_control/inkling_family.py`: el motor lo carga y responde con él), aunque sus propias descargas sigan en el
archivo antiguo. El borrador reeditado por Unsloth (503.889.952 bytes, disposición `dflash`) no lo lee el motor
todavía; 0.2.21 usa por defecto el `mtp.safetensors` original, que según Strata tiene los mismos tensores que el Q8_0
antiguo (sin cuantizar). El motor lo admite: `--info` declara `drafter=dspark spec_opts=1 dspark_f32_widen=1`.
Corrige el fallo de 0.2.20 (`missing tensor 'dspark.layers.0...'`).

### Perfiles

| Lanzador | Contexto | Modelo en la API (`model_name`) | Expertos en VRAM / RAM | Puerto |
| --- | ---: | --- | --- | --- |
| `start-text-131k.cmd` | 131.072 | `inkling-2-mini-ud-q4_k_xl-131k` | 7,47 / 7,25 GB | `0.0.0.0:8080` |
| `start-text-262k.cmd` | 262.144 | `inkling-2-mini-ud-q4_k_xl-262k` | 6,65 / 8,08 GB | `0.0.0.0:8080` |
| `start-text-1m.cmd` | 1.048.576 | `inkling-2-mini-ud-q4_k_xl-1m` | 3,72 / 11,00 GB | `0.0.0.0:8080` |

- JSON: copias de `install\strata-inkling-2-mini-ud-q4_k_xl.json` que escribe `strata install` de 0.2.21 para cada
  contexto, con `model_name` y `log` cambiados y `"drafting": "dspark"` en lugar de `"auto"`. El instalador ya añade
  `--dspark <mtp.safetensors>`. El reparto de 0.2.21 deja menos expertos en VRAM que el de 0.2.20 (7,47 frente a
  11,27 GB a 131K): reserva antes el KV, el prefill y el borrador. Sin medir bajo carga.
- **Por qué `dspark` y no `auto`.** Con `auto`, `strata launch` mide al primer arranque de cada reparto si el borrador
  compensa (dos arranques del motor, con y sin borrador; unos 3 minutos) y lo guarda en el JSON. Esa medición la hace
  el lanzador de Strata (`strata_cli/launch/runner.py`), no `serve/server.py`, que es lo que ejecutan estos
  lanzadores: con `auto` y sin medición, el servidor arranca con `--draft off` (lo muestra `serve --plan`). Con
  `dspark`, el servidor pasa `--draft dspark --draft-beam 1 --draft-adapt`; `--draft-adapt` apaga el borrador
  durante 40 pasos de una petición cuando la ganancia medida baja de 0,93. Strata documenta un caso en que el
  borrador fue 2 veces más lento (RTX 4060 con este mismo GGUF), así que su efecto aquí está por medir.
- **Razonamiento.** El servidor de 0.2.21 (commit `39b8407c4`) pasa a la plantilla el nivel de cada petición
  (`none` 0, `minimal` 0,1, `low` 0,2, `medium` 0,7, `high` 0,9, `xhigh`/`max` 0,99), con `low` por defecto
  (`STRATA_INKLING_EFFORT`), y devuelve el razonamiento como `reasoning_content`. Presupuesto por nivel: 1.024
  (`none` y `minimal`), 2.048, 4.096, 8.192 y 16.384 tokens (`xhigh` y `max`); `reasoning_budget_tokens` de la
  petición manda. Si una respuesta termina sin texto visible, el servidor reintenta una vez abriendo la respuesta.
  `strata_control/inkling_family.py` sigue declarando `HAS_THINKING = False`, aparentemente solo para la app.
  En Pi, OpenCode y DSH los alias usan el mismo contrato que Flash-Next (`reasoning_effort`; Pi también envía
  `minimal`).
- Con herramientas y nivel 0, el servidor repite el turno de razonamiento vacío en el historial para que los turnos
  de agente reutilicen el prompt (#6733, commit `45e86f7c1`).

### Pruebas

- `Download-Model.ps1` y `Test-ModelIntegrity.ps1 -RootDirectory .\strata`: los 4 artefactos del subárbol.
- `strata install` para 131K, 262K y 1M (componente `strata-inkling` 0.1.67 con firma y archivos comprobados,
  tokenizador extraído, `drafter: DSpark (mtp.safetensors)`).
- `strata-inkling.exe --info` con el GGUF y el borrador; `serve --plan` de los tres JSON; `inkling_kind.engine_args`
  de cada JSON (`--draft dspark --draft-beam 1 --draft-adapt`).
- Sin arranque, inferencia ni calibración: el usuario lo prueba desde Pi. Pendiente: velocidad con y sin borrador,
  memoria real a 262K y 1M, razonamiento por nivel y tool calling.
