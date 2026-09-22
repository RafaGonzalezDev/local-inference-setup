# Ternary Bonsai 2 27B

- Modelo: `Ternary-Bonsai-2-27B-PQ2_0.gguf`
- Proyector: `Ternary-Bonsai-2-27B-mmproj-Q8_0.gguf`
- Repositorio: `prism-ml/Ternary-Bonsai-2-27B-gguf`
- Revisión: `6ed5e12bf84b7a63069882c91dd9e9218647d17b`
- Alias API: `ternary-bonsai-2-27b`
- Arquitectura GGUF: `qwen35` (atención híbrida, ~75% lineal / ~25% completa)
- Licencia: Apache-2.0

Ternary Bonsai 2 27B es una destilación ternaria de Qwen3.8-27B. Cada peso toma
un valor de {-1, 0, +1} con un factor de escala FP16 compartido por cada grupo de
128 pesos, y las matrices se almacenan en una base rotada con Hadamard por bloques
(bloque 1024); el runtime aplica la transformación equivalente a las activaciones.
El resultado son 27,36B parámetros a 1,72 bits/peso efectivos que conservan
razonamiento en modo thinking, llamadas a herramientas por API, visión y contexto
nativo de 262.144 tokens, con un tamaño desplegado de 7,21 GB.

## Artefactos

| Formato | Archivo | Tamaño | SHA-256 |
| --- | --- | ---: | --- |
| `PQ2_0` (ternaria, slots de 2 bits) | `Ternary-Bonsai-2-27B-PQ2_0.gguf` | 7.206.168.928 bytes | `3907dc1658db1f78a9826bf8d5bcb8dc65db0d466388937af57f2294fae62ec1` |
| `Q8_0` (mmproj) | `Ternary-Bonsai-2-27B-mmproj-Q8_0.gguf` | 629.246.976 bytes | `6807ede61d570bb86ba34b756a0fa109edc33668604de867c6ea6d8f1d631903` |

Ambos artefactos se fijan a la revisión `6ed5e12bf84b7a63069882c91dd9e9218647d17b`
de `prism-ml/Ternary-Bonsai-2-27B-gguf`.

El repositorio publica además `Ternary-Bonsai-2-27B-PTQ1_0.gguf` (5.946.648.928
bytes), un empaquetado más denso de la misma representación ternaria, y el
proyector de referencia `Ternary-Bonsai-2-27B-mmproj-BF16.gguf` (931.145.856
bytes). No se descargan: `PQ2_0` es la variante recomendada por la ficha para
GPUs Blackwell y para procesamiento de prompt, y `Q8_0` es el proyector
desplegable, 302 MB menor que el de referencia.

## Runtime

Estos archivos no cargan en el runtime oficial. `PTQ1_0` y `PQ2_0` son tipos
propios del fork `PrismML-Eng/llama.cpp`: el runtime oficial los rechaza como
tipos desconocidos y, sin la transformación Hadamard de activaciones, produce
salida inválida. Los dos lanzadores fijan `SERVER` en
`runtimes\llama.cpp\prism-b10685-7dffb15-cuda13.3\llama-server.exe`, instalado por
`scripts/setup/Install-BonsaiRuntime.ps1` desde la release `prism-b10685-7dffb15`
(commit `7dffb158`, `version: 0.2.0-dev (build 10685, commit 7dffb158d)`). Las DLL
del fork permanecen en su propio directorio y no se mezclan con las del runtime
oficial `b10502-cuda13.3`.

## Perfiles

| Lanzador | Contexto | Batch/UBatch | Visión | MTP |
| --- | ---: | ---: | :---: | :---: |
| `start-text-131k-1024.cmd` | 131.072 | 1.024/1.024 | no | no |
| `start-vision-131k-1024.cmd` | 131.072 | 1.024/1.024 | sí, imagen fijada a 1.024 tokens | no |

Windows conserva dos perfiles a 131k: texto sin `--mmproj` y visión con
proyector. El perfil de texto se sincronizó el 2026-09-22; las mediciones
siguientes pertenecen al perfil de visión, no al nuevo perfil de texto.
Ambos materializan un slot, `--gpu-layers 999`, Flash Attention, caché KV
`q8_0` en claves y valores, ocho hilos, Jinja, `--cache-ram 0`, `--split-mode
none`, `--fit off`, `--load-mode none` y `--log-verbosity 3`.

El muestreo sigue los valores oficiales de thinking mode de la ficha: temperatura
1,0, `top-p 0,95`, `top-k 20`, `min-p 0`, penalización de presencia 0 y penalización
de repetición 1. El presupuesto inicial de razonamiento es 8.192 tokens.

El esfuerzo de razonamiento por defecto del modelo es `xhigh`; `medium` puede
seleccionarse por petición o con `--chat-template-kwargs`, y `low` no está
soportado (se comporta como `xhigh`), según la ficha del modelo.

No se publica draft MTP ni DSpark para este modelo, por lo que no hay perfil
especulativo.

## Visión

El perfil de visión carga el proyector `Q8_0` oficial, que la ficha describe como
el paquete desplegable del vision tower. El lanzador materializa
`--image-min-tokens 1024 --image-max-tokens 1024`: el mínimo responde al aviso del
runtime ("Qwen-VL models require at minimum 1024 image tokens to function
correctly on grounding tasks") y el máximo acota el prefill y la VRAM en una GPU
de 16 GB. El resultado es una imagen fijada a 1.024 tokens; el demo de
referencia deja CUDA sin límite y la ficha permite hasta ~4.096 tokens por
imagen. Para OCR o texto pequeño puede subirse o retirarse el máximo y asumir el
coste de prefill.

## Calibración

Medición con métricas nativas de Windows (`nvidia-smi`), con el modelo en la
caché de página del sistema, sobre una RTX 5080 de 16.303 MiB. El baseline del
escritorio está incluido en la columna de uso.

| Perfil | Contexto | Baseline | Uso con servidor | Delta | Libre | RAM del proceso | Carga |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| `vision-131k-1024` | 131.072 | 1.970 MiB | 15.257 MiB | 13.287 MiB (~13 GB) | 1.046 MiB | 1,21 GB | 2,6 s |

Las cifras de carga corresponden a un fichero ya en caché de página tras la
descarga; en un arranque en frío serán mayores. Con ~1 GB libre, el margen se
agota si el escritorio gana carga o el prefill es muy largo; las palancas son
`--no-mmproj-offload` (~0,9 GB), `--ubatch-size 512` o reducir el contexto.

Los tiempos siguientes proceden de la prueba funcional de 16 tokens de salida y
no son benchmarks: prefill de 1.072 tokens a 1.227 tok/s y decode a 76,8 tok/s.

### Calibración histórica

Los perfiles retirados midieron lo siguiente antes de la consolidación:

| Perfil | Contexto | Baseline | Uso con servidor | Delta | RAM del proceso | Carga |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| `text` | 65.536 | 1.995 MiB | 11.667 MiB | 9.672 MiB (~9,4 GB) | 0,98 GB | 2,6 s |
| `vision` | 32.768 | 2.002 MiB | 11.269 MiB | 9.267 MiB (~9,1 GB) | 0,95 GB | 2,7 s |

Sus pruebas funcionales de 16 tokens midieron: perfil `text`, prefill de 57
tokens a 388 tok/s y decode a 76,3 tok/s; perfil `vision`, prefill de 1.072
tokens a 1.298 tok/s y decode a 76,4 tok/s.

## Validación histórica

Estos resultados preceden a la sincronización del perfil de texto de 131k;
no constituyen una prueba funcional de ese perfil.

- Integridad verificada contra el tamaño y SHA-256 fijados en el manifiesto para
  los dos artefactos.
- Validación declarativa de los 21 lanzadores del catálogo y de los ficheros
  instalados, en verde.
- Prueba funcional superada por `start-vision-131k-1024.cmd` (5,03 s, con la
  imagen de referencia `tests/assets/panels-1080p.png`).
- El proceso terminó limpiamente y liberó el puerto 8080.
- Coexistencia comprobada: un perfil del runtime oficial (`ling-3.0-tiny`
  `agentic-131k-1024`) sigue superando su prueba funcional con el segundo
  runtime instalado.

Avisos observados con el runtime del fork, ninguno bloqueante:

- `--cache-idle-slots requires --cache-ram, disabling`: consecuencia directa de
  `--cache-ram 0`, presente en el resto de perfiles del repositorio.
- `chat template supports preserving reasoning, consider enabling it via
  --reasoning-preserve`: opción disponible si se quiere conservar el bloque de
  razonamiento entre turnos.
- El aviso de grounding sobre tokens de imagen desaparece al fijar
  `--image-min-tokens 1024`.

## Dependencias

- `config/models/ternary-bonsai-2-27b.psd1`
- `scripts/models/ternary-bonsai-2-27b/start-text-131k-1024.cmd`
- `scripts/models/ternary-bonsai-2-27b/start-vision-131k-1024.cmd`
- `scripts/setup/Install-BonsaiRuntime.ps1`
- `runtimes/llama.cpp/prism-b10685-7dffb15-cuda13.3/`

## Related ADRs

- [ADR-0001: lanzadores autocontenidos](../../adr/ADR-0001-self-contained-model-launchers.md)
