# Swift 1.5 Qwen3.8 27B GSQ-RCO MTP

- Modelo: `Swift-1.5-Qwen3.8-27B-GSQ-RCO-IQ3_XXS-mtp.gguf`
- Repositorio: `ukisai/Swift-1.5-Qwen3.8-27B-GSQ-RCO-GGUF`
- Revisión: `d74895bbe5db4bec1e0024e7cc87d59c02d7631a`
- Alias API: `swift-1.5-qwen3.8-27b-gsq-rco-mtp`
- Arquitectura GGUF: `qwen35` (Qwen3.8-27B: 27B denso, 64 capas, atención
  híbrida de 3 capas lineales y 1 completa por bloque, contexto nativo 262.144)

Swift 1.5 es un fine-tune de `Qwen3.8-27B` publicado por el autor con la receta
de cuantización GSQ-RCO aplicada y el cabezal `nextn` de MTP conservado dentro
del propio GGUF. Es otro fine-tune del mismo modelo base que el retirado
[`qwen3.8-27b-gsq-rco`](../../changelog/2026-09-30-retire-qwen3.8-27b-gsq-rco.md),
no una revisión de aquel modelo. Licencia Swift Open License v1.0: uso gratuito
para particulares y organizaciones con ingresos anuales brutos de hasta
US$1.000.000, incluidas las filiales; por encima de ese umbral requiere licencia
empresarial. Los componentes Qwen conservan Apache 2.0.

## Artefactos

| Cuantización | Archivo | Tamaño | SHA-256 |
| --- | --- | ---: | --- |
| `IQ3_XXS` con MTP (principal, instalado) | `Swift-1.5-Qwen3.8-27B-GSQ-RCO-IQ3_XXS-mtp.gguf` | 10.442.827.776 bytes | `e23eb251493b8a89f7d0217590b593e696ac9bacaeac8605541e477533dc5838` |
| `IQ3_XXS` estándar (no instalado) | `Swift-1.5-Qwen3.8-27B-GSQ-RCO-IQ3_XXS.gguf` | 10.094.357.792 bytes | `86969b8bde72e602bfb42deb83eb8bb3706c8f14250641f6444dd2355f934ac2` |

Ambos artefactos se fijan a la revisión
`d74895bbe5db4bec1e0024e7cc87d59c02d7631a` de
`ukisai/Swift-1.5-Qwen3.8-27B-GSQ-RCO-GGUF`. Solo se instala el principal, unos
9,7 GiB. La variante estándar no se descarga ni se declara en el manifiesto: se
documenta aquí como referencia, porque es la única forma de conocer el tamaño
del cabezal (la diferencia entre ambas, 348.469.984 bytes, unos 0,32 GiB) y
porque su ausencia se paga en la comparación descrita en Limitaciones. La resta
de tamaños es aritmética sobre las dos cifras publicadas, no una medición.

El campo `general.file_type` del GGUF vale 32, que el runtime etiqueta como
`BF16`, y `/props` lo reporta como `model_ftype: "BF16"` pese al nombre
`IQ3_XXS` del fichero. La asignación GSQ-RCO es mixta, así que esa etiqueta
describe la precisión de los tensores de mayor peso y no la del modelo completo:
el propio runtime informa de 3,05 bits por peso.

## Perfiles

| Lanzador | Contexto | Batch/UBatch | Visión | MTP |
| --- | ---: | ---: | :---: | :---: |
| `start-agentic-auto-mtp-32k-1024.cmd` | 32.768 | 1.024/1.024 | no | sí |
| `start-agentic-auto-mtp-65k-1024.cmd` | 65.536 | 1.024/1.024 | no | sí |
| `start-agentic-auto-mtp-96k-1024.cmd` | 98.304 | 1.024/1.024 | no | sí |
| `start-agentic-auto-mtp-131k-1024.cmd` | 131.072 | 1.024/1.024 | no | sí |

Los alias son `swift-1.5-qwen3.8-27b-gsq-rco-mtp-32k`,
`swift-1.5-qwen3.8-27b-gsq-rco-mtp-65k`,
`swift-1.5-qwen3.8-27b-gsq-rco-mtp-96k` y
`swift-1.5-qwen3.8-27b-gsq-rco-mtp-131k`, todos detrás del primario
`swift-1.5-qwen3.8-27b-gsq-rco-mtp`. Los cuatro comparten la configuración base:
`--parallel 1`, `--cache-ram 0`, `--flash-attn on`, `--split-mode none`,
`--load-mode none`, `--log-verbosity 3` y caché KV `q8_0` para claves y valores.
El contexto nativo del modelo es 262.144, pero ningún perfil de este modelo lo
declara: 131.072 es el techo instalado.

## El valor de 98.304

`--ctx-size` acepta cualquier entero, así que la elección es una convención, no
una restricción del runtime. Los perfiles de este repositorio usan múltiplos
binarios, y «96K» significa 98.304 tokens (96 × 1.024), no 96.000. La diferencia
importa porque 98.304 es divisible por el lote declarado
(`--batch-size 1024`) y por el espaciado mínimo de los puntos de control de
contexto que el servidor anuncia al arrancar (`min spacing = 8192`):
98.304 = 96 × 1.024 = 12 × 8.192. Un valor como 96.000 no es múltiplo de ninguno
de los dos y no aporta nada a cambio.

El perfil se sitúa entre el de 65K y el de 131K. Frente a 131.072 ahorra
1.140 MiB de caché KV —(131.072 − 98.304) tokens × 34.816 bytes por token—, que
es margen que `--fit` puede dedicar a mantener capas densas en la GPU en lugar de
resolverlas en la CPU.

## Batch y ubatch

Los cuatro perfiles usan `--batch-size 1024 --ubatch-size 1024`. `--ubatch-size`
fija el tamaño de los búferes de cómputo, que compiten con los pesos por el mismo
margen de `--fit-target`: al bajar de 2.048 a 1.024 se reduce el tramo de capas
densas que `--fit` manda a la CPU, y en un modelo denso ese tramo se paga en cada
token generado, no solo en los expertos activos. El coste asumido es un prefill
más lento, que no se ha medido. No se crea ningún perfil con 2.048, tampoco para
los contextos pequeños, donde el prefill es menos costoso y la palanca sería más
barata de probar.

## MTP

Los cuatro perfiles materializan `--spec-type draft-mtp --spec-draft-n-max 3`. El
cabezal `nextn` vive dentro del mismo GGUF, así que no hace falta
`--spec-draft-model` ni un fichero borrador externo. `--spec-draft-p-min` se deja
en su valor por defecto (0). El autor no evaluó la velocidad ni la calidad del
MTP de estos ficheros: no hay publicado ningún factor de aceleración ni barrido
de `--spec-draft-n-max` para esta publicación, de modo que `n-max 3` es una
elección heredada de los perfiles MTP existentes del catálogo y no una medición.
Antes de fijar un valor propio conviene barrer `n-max` y `p-min` midiendo tokens
por segundo, no tasa de aceptación.

La cabecera del GGUF confirma el cabezal: `qwen35.block_count = 65` y
`qwen35.nextn_predict_layers = 1`, con 15 tensores en el bloque 64
(`blk.64.nextn.eh_proj`, `blk.64.nextn.enorm`, `blk.64.nextn.hnorm` y
`blk.64.nextn.shared_head_norm`, además de la atención y el FFN de esa capa).

La activación efectiva de la especulación quedó confirmada al arrancar el perfil
con `--log-verbosity 4`: el runtime imprime
`common_speculative_init_result: creating MTP draft context against the target
model`, añade `adding speculative implementation 'draft-mtp'` con `n_max=3` y
deja de marcar los 15 tensores `blk.64.nextn.*` como no usados —lo que sí hace
`llama-fit-params.exe`, que no construye el contexto de borrador—. El costo en
VRAM de activarlo está medido: el búfer de modelo pasa de 9.227,87 MiB a
9.560 MiB por el cabezal `nextn` (unos 333 MiB), y el contexto de borrador añade
384 MiB de caché en f16 y 328 MiB de cómputo a 98.304 tokens, 1.045 MiB en total
(ver Medición de VRAM). Lo que sigue sin medir es la ganancia: no hay barrido de
tokens por segundo ni de tasa de aceptación para estos ficheros.

## Muestreo y razonamiento

El muestreo queda en `temp 1`, `top-p 0.95`, `top-k 20`, `min-p 0`,
`presence-penalty 0` y `repeat-penalty 1`. El razonamiento se declara con
`--reasoning auto --reasoning-effort xhigh --reasoning-budget -1`: el presupuesto
negativo mantiene el límite desactivado, de modo que el presupuesto no trunca la
cadena de razonamiento y es el modelo quien la cierra, en coherencia con el
esfuerzo `xhigh`. Son valores declarados de configuración, no mediciones propias.

El servidor reporta `reasoning_format: "none"` y `chat_format: "Content-only"`:
la traza de pensamiento llega dentro de `content` y no en un campo
`reasoning_content` separado. Ningún lanzador del catálogo declara
`--reasoning-format`, así que es el comportamiento común del entorno y no una
particularidad de este modelo; si un cliente necesita el campo separado, hay que
añadir ese flag.

## Visión

Los cuatro perfiles tienen visión desactivada: no declaran `--mmproj` ni
`--image-min-tokens`. El repositorio del autor no publica proyector multimodal
verificado para esta publicación, así que no se instala ninguno.

## Colocación automática

Los cuatro perfiles declaran `--gpu-layers auto --fit on --fit-target 1024` y
omiten tanto `--n-cpu-moe` como `--n-cpu-ffn`: `--fit` coloca los pesos con `-ot`
por capa en lugar de usar esas palancas. El contexto se declara siempre, porque
`--fit` solo ajusta los argumentos no declarados y, si se omite, lo reduce al
mínimo de `--fit-ctx`. `--n-cpu-ffn` era la palanca con la que se justificó el
salto de runtime a `b11269` para el modelo denso retirado; aquí queda fuera por
la misma razón que en el resto del catálogo.

La sonda de colocación de `llama-fit-params.exe` resuelve descarga completa en la
GPU en los cuatro contextos y no emite ningún `-ot`: informa de 66/66 capas en
`CUDA0` (65 bloques más la capa de salida) con 11.519, 12.563, 13.650 y
14.739 MiB de modelo, contexto y cómputo para 32.768, 65.536, 98.304 y 131.072
tokens, sobre una GPU de 16.275 MiB. Es una estimación del planificador, y no
contabiliza el contexto de borrador del MTP, así que queda por debajo del costo
real cuando la especulación está activa. La medición en ejecución está en
Medición de VRAM.

## Medición de VRAM

Medido en esta máquina —RTX 5080, 16.275 MiB visibles para el runtime— con el
runtime `b11551-cuda13.4`, `--flash-attn on`, caché KV `q8_0` en claves y
valores, `--parallel 1`, lote 1.024/1.024 y **sin** MTP, forzando
`--fit off --gpu-layers 999` para que ninguna capa pueda resolverse en CPU. La
ventana se confirma leyendo `n_ctx` en `/props`; la VRAM se lee con `nvidia-smi`
y el desbordamiento a memoria del sistema con el contador
`GPU Adapter Memory(*)\Shared Usage`, que en reposo marca 62 MiB:

| `--ctx-size` | `n_ctx` | VRAM usada | libre | veredicto |
| ---: | ---: | ---: | ---: | --- |
| 65.536 | 65.536 | 14.779 MiB | 1.199 MiB | cabe |
| 98.304 | 98.304 | 15.341 MiB | 637 MiB | cabe |
| 114.688 | 114.688 | 15.351 MiB | 627 MiB | cabe |
| 131.072 | 131.072 | 15.735 MiB | 243 MiB | cabe, al límite |
| 262.144 | 262.144 | saturado | 436 MiB | no cabe: 6.261 MiB en memoria compartida |

La carga del escritorio varió entre filas y está incluida en la columna «libre»:
la VRAM que otros procesos ocupaban se movió entre 960 y 2.340 MiB durante las
pruebas.

Los búferes que declara el propio runtime a 262.144 tokens (`--log-verbosity 5`)
son 9.227,87 MiB de modelo, 8.704,00 MiB de caché KV y 1.696,30 MiB de cómputo:
19.628,17 MiB, unos 3,4 GiB por encima de la tarjeta, y de ahí el desbordamiento.
La caché KV son 34.816 bytes por token exactos —16 capas de atención completa
(3, 7, 11 … 63) × 2 (K y V) × 4 cabezas KV × 256 dimensiones × 1,0625 bytes de
q8_0—; las 49 capas lineales no usan caché y el runtime las marca `filtered`. Con
esas cifras, la VRAM del modelo se recalcula para cualquier contexto:

    VRAM(ctx) ≈ 10.290 + 0,0352 · ctx   [MiB]

El término fijo son los pesos más el búfer de cómputo, que sube de 1.010 a
1.696 MiB porque la máscara de atención es de 2 bytes por celda; el término
variable es la caché KV. El techo es el contexto que deja
`16.275 − escritorio − margen` MiB libres: con el margen de 1.024 MiB que
declaran `--fit-target`, unos 113.000 tokens con el escritorio en 1 GiB y unos
76.000 con el escritorio en 2,3 GiB.

Con MTP activo el costo sube 1.045 MiB a 98.304 tokens, así que el perfil de 96K
no mantiene las 66 capas en GPU con el escritorio cargado. Medido con los
argumentos reales del perfil (`--fit on --fit-target 1024` y MTP activo, con
1.890 MiB de la tarjeta ya tomados por otros procesos y por el propio contexto
CUDA del runtime), el planificador proyecta 14.871 MiB frente a 14.385 MiB
disponibles y descarga 12 capas:

    cannot meet free memory target of 1024 MiB, need to reduce device memory by 1510 MiB
    set ngl_per_device[0].n_layer=54
      - CUDA0 (NVIDIA GeForce RTX 5080): 54 layers,  13088 MiB used,   1296 MiB free
    load_tensors: offloaded 54/66 layers to GPU
    load_tensors:        CUDA0 model buffer size =  8176.98 MiB
    load_tensors:    CUDA_Host model buffer size =  1771.60 MiB
    llama_kv_cache:      CUDA0 KV buffer size =  2652.00 MiB
    llama_kv_cache:        CPU KV buffer size =   612.00 MiB
    llama_memory_recurrent:      CUDA0 RS buffer size =   486.28 MiB
    llama_memory_recurrent:        CPU RS buffer size =   112.22 MiB

Es el comportamiento que ya tenía el perfil de 131K, que descarga 8 capas con
1.440 MiB ya tomados: `--fit` es automático y el tramo que resuelve en CPU
depende del escritorio en el momento de arrancar, no del perfil. Entre 96K y 131K
la diferencia es de 1.140 MiB de caché KV a favor del de 96K. Si se necesita ese
contexto con las 66 capas en GPU, la palanca medida es quitar
`--spec-type draft-mtp`, que libera los 1.045 MiB; no se ha medido el efecto de
esa elección sobre la velocidad.

## Antecedente: el modelo retirado `qwen3.8-27b-gsq-rco`

Existió antes en el catálogo el modelo `qwen3.8-27b-gsq-rco`, retirado el
2026-09-30 porque su salida no alcanzó el nivel exigido. Aquel modelo usaba
`IQ3_S`, con divergencia KL publicada por el autor de 0,0513 a contexto 512, de
fidelidad superior al `IQ3_XXS` que se instala aquí, con 0,0978 en la misma
medida. La tarjeta del autor mide calidad de cuantización, no calidad de tarea, y
no a contexto largo, así que esa diferencia no permite anticipar el
comportamiento en uso agentic. Swift 1.5 es otro fine-tune del mismo modelo base,
no el modelo retirado, y su incorporación no reabre el retiro: el detalle del
retiro está en
[`2026-09-30-retire-qwen3.8-27b-gsq-rco.md`](../../changelog/2026-09-30-retire-qwen3.8-27b-gsq-rco.md).

## Limitaciones

- No se instala la variante estándar, así que no hay perfil sin MTP que aísle la
  ganancia de la especulación: cualquier comparación de velocidad mezclaría el
  efecto del MTP con el del prefill y la colocación.
- El autor no evaluó el MTP de estos ficheros, ni en velocidad ni en calidad.
- La única medida de cuantización publicada es la divergencia KL a contexto 512,
  que no es una medida de tarea ni de contexto largo.
- La ganancia del MTP sigue sin medir: la especulación se activa (ver MTP), pero
  no hay barrido propio de tokens por segundo ni tasa de aceptación, y `n-max 3`
  es un valor heredado del catálogo, no medido.
- No hay medición propia de tokens por segundo ni de tiempo de prefill para
  ninguno de los cuatro perfiles. La VRAM en ejecución sí está medida, sin MTP y
  con todas las capas forzadas a la GPU, en Medición de VRAM; el tramo con MTP se
  midió una sola vez y con el escritorio cargado.

## Estado

Los cuatro perfiles usan `0.0.0.0:8080` sin autenticación y deben ejecutarse como
alternativas. La prueba funcional la ejecuta el usuario: la incorporación del
perfil de 96K no ejecutó inferencias, solo arranques de servidor para medir VRAM
(ver Medición de VRAM), cerrados liberando la tarjeta y el puerto. No hay
lanzadores retirados para este modelo.

## Dependencias

- `config/models/swift-1.5-qwen3.8-27b-gsq-rco-mtp.psd1`
- `scripts/models/swift-1.5-qwen3.8-27b-gsq-rco-mtp/start-agentic-auto-mtp-32k-1024.cmd`
- `scripts/models/swift-1.5-qwen3.8-27b-gsq-rco-mtp/start-agentic-auto-mtp-65k-1024.cmd`
- `scripts/models/swift-1.5-qwen3.8-27b-gsq-rco-mtp/start-agentic-auto-mtp-96k-1024.cmd`
- `scripts/models/swift-1.5-qwen3.8-27b-gsq-rco-mtp/start-agentic-auto-mtp-131k-1024.cmd`
- `runtimes/llama.cpp/b11551-cuda13.4/`

## Related ADRs

- [ADR-0001: lanzadores autocontenidos](../../adr/ADR-0001-self-contained-model-launchers.md)
