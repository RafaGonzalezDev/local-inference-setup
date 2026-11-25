# inkling-2-mini-nvfp4-mx8 (Basalt)

Inkling 2 Mini de Thinking Machines (transformer en bucle de 24 capas, las 12 centrales recorridas tres veces; MoE de
128 expertos, 8 activos por token; contexto nativo de 1M) en el paquete `.basalt` de su autor, servido por
[Basalt](https://github.com/jesdga95/basalt) 0.5.7, no por llama.cpp ni Strata. Instalación y uso en
[basalt/README.md](../../../basalt/README.md).

Vuelve a petición del usuario (2026-11-25) tras descartarse en Strata el 2026-11-24 (ver la
[ficha anterior](inkling-2-mini-ud-q4_k_xl.md)): Basalt es otro motor y sirve los pesos nativos de la publicación.

## Procedencia

| Artefacto | Dato |
| --- | --- |
| Repositorio | [jesdga/Inkling-2-Mini-Basalt](https://huggingface.co/jesdga/Inkling-2-Mini-Basalt), revisión `c2afac3adb772e14d77b2ea2ac7068ad4460e932` |
| Paquete | `Inkling-2-Mini-NVFP4-MX8.basalt`; 19.606.374.189 bytes, SHA-256 `28ec70723feaa037942a02f55b9d5e898276f3e62a3b1fa083745f932a041b99` (LFS de Hugging Face, igual al de la tarjeta) |
| Origen | Convertido por el autor de Basalt desde [thinkingmachines/Inkling-2-Mini](https://huggingface.co/thinkingmachines/Inkling-2-Mini) con `tools/convert/convert.py --checkpoint`; no es una publicación oficial |
| Licencia | Apache 2.0 (modelo); MIT (Basalt) |
| Motor | Basalt 0.5.7 (`basalt-v0.5.7-windows-x64.zip`, SHA-256 `dfb71d0a…22881`), requiere 0.5.6 o posterior |

## Cuantización

| Parte | Formato |
| --- | --- |
| Expertos, capas 0-19 | NVFP4, los bits de la publicación sin redondear de nuevo |
| Expertos, capas 20-23 | MXFP8 de la publicación |
| Atención, gate, convolución corta y proyecciones | Q8_0 |
| Cabeza de salida | BF16 en el archivo; Q8_0 al cargar |
| Embedding | BF16 (en RAM fija; la GPU lee sus filas) |
| Visión y borrador DSpark | BF16 |

Calidad publicada por el autor: KLD medio 0,00297 y primer token igual en el 97,83 % frente a la publicación con los
expertos descuantizados a BF16 (no comparable con los KLD de Unsloth). Sin verificar aquí.

## Perfil

| Lanzador | Contexto | Alias en la API | KV | Puerto |
| --- | ---: | --- | --- | --- |
| `start-text-262k.cmd` | 262.144 | `inkling-2-mini-nvfp4-mx8-262k` | `int8` | `0.0.0.0:8080` |

- Contexto pedido por el usuario. Solo texto: el paquete trae visión (`--vision dynamic`, sin coste de VRAM hasta que
  llega una imagen), pero no se activa (los perfiles de visión no llevan borrador, decisión del usuario del 2026-10-28).
- `kv int8`: según las mediciones del autor, KLD 0,00343 frente a 0,00452 con `fp8` y 0,00304 con `fp16`, con 18 KiB
  por posición frente a 16 y 32. La tabla de configuración de 0.5.7 solo cita `fp16` y `fp8` para Inkling, pero el
  motor arrancó con `int8` (`kv=int8` en el log).
- **Sin borrador** (`"spec": 1`) desde el 2026-11-25, decisión del usuario para todos los perfiles de este modelo:
  DSpark acierta poco en prosa, ocupa 0,48 GiB de VRAM que pasan a expertos y el prefill es más rápido sin él (ver
  «Comparación de variantes»).
- Resto por defecto: 7 hilos de CPU para los expertos en RAM, `ram-reserve-mib` 2048,
  razonamiento por petición (`reasoning_effort` `none`, `minimal`, `low`, `medium`, `high`, `xhigh`, `max`; sin él, el
  `high` de la plantilla). Ni siquiera `none` desactiva del todo el razonamiento: escribe un bloque corto, devuelto
  como `reasoning_content`.
- El servidor rechaza un `Host` que no sea IP, `localhost` o el nombre del equipo; los clientes de WSL usan la IP.

## Memoria (log de carga)

Con unos 1,5-2 GiB de VRAM ocupados por el escritorio antes de arrancar:

- En la GPU: 1,14 GiB densos, 0,48 GiB de borrador, 0,95 GiB de prompt staging y 4,11 GiB de expertos (733 de 3.072).
- En RAM: 2.339 expertos (11,46 GiB), calculados por la CPU; el embedding (0,86 GiB).
- Reparto elástico: 707 de esos expertos (3,27 GiB) vuelven a la GPU mientras la caché KV no crece; regresan a RAM a
  medida que una conversación la necesita. Tras cargar: 1.061 MiB de VRAM libres, un margen fijo de Basalt 0.5.7
  ([#610](https://github.com/jesdga95/basalt/issues/610), corregido en `main` después de 0.5.7).

## Pruebas (2026-11-25)

Con las aplicaciones del escritorio cerradas, un arranque del perfil y peticiones secuenciales sin streaming:

| Petición | Prefill | Generación | Aceptación del borrador | Aciertos de expertos en VRAM |
| --- | ---: | ---: | ---: | ---: |
| Chat corto (37 tokens, `none`) | - | 69,7 tok/s | 43 % | 81,4 % |
| Chat corto (`low`) | - | 70,7 tok/s | 49 % | 80,9 % |
| Llamada a herramienta (`low`) | - | 87,1 tok/s | 83 % | 77,0 % |
| Prompt de 41.081 tokens | 3.261 tok/s | 60,1 tok/s | 86 % | 70,0 % |
| Prompt de 131.967 tokens | 2.758 tok/s | 48,9 tok/s | 81 % | 58,3 % |

- `/v1/models` y `/health`: alias y contexto de 262.144 correctos.
- Tool calling: `tool_calls` válido con `finish_reason: tool_calls`.
- Respuestas en español coherentes en todas las peticiones. Sin pruebas de visión, 1M ni calidad sistemática.
- Parada: puerto libre y VRAM de vuelta al valor previo.

Estas pruebas se hicieron con el borrador DSpark activado (`spec=8`, el valor por defecto del motor).

## Comparación de variantes (2026-11-25)

Un arranque por variante con el escritorio cerrado, escuchando en `127.0.0.1`, y las mismas cuatro peticiones sin
streaming: prosa (`none`, 1.024 tokens como máximo), código (`none`, 1.500), una llamada a herramienta (`low`) y el
prompt de 41.081 tokens (`none`, 2.048). Una sola medición por variante y respuestas de longitud distinta: diferencias
de pocos tok/s pueden ser ruido. Velocidades en tok/s, del `done` del servidor.

| Variante | Prosa | Código | Herramienta | Prefill 41K | Generación tras 41K | VRAM libre tras cargar |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| 262K `int8`, con borrador | 67,5 | 89,2 | 95,9 | 3.255 | 67,5 | 1.022 MiB |
| 262K `int8`, sin borrador | 83,6 | 80,9 | 78,5 | 3.766 | 62,4 | 1.153 MiB |
| 262K `fp8`, con borrador | 71,1 | 94,6 | 91,2 | 3.413 | 65,5 | 921 MiB |
| 131K `int8`, con borrador | 75,5 | 104,2 | 103,6 | 4.124 | 76,0 | 1.043 MiB |

- Sin borrador quedan 1.959 expertos en RAM al inicio, frente a 2.339 con él, y los aciertos en VRAM suben del 77-81 %
  al 85-88 %. La aceptación del borrador fue del 37-49 % en prosa y del 75-100 % en código, herramientas y el prompt
  largo.
- `fp8` deja menos de 1 GB libre y empeora la calidad según el autor; se descarta.
- 131K deja 6,86 GiB de expertos fijos en la GPU (4,11 a 262K) y es la más rápida, pero el usuario prefiere 262K.
- Sin medir: 131K sin borrador.
- Las configuraciones deben estar en una carpeta donde el servidor pueda escribir: guarda `<config>.totals.json` al
  terminar cada petición, y con la configuración en la carpeta temporal del agente se quedó bloqueado sin responder.
