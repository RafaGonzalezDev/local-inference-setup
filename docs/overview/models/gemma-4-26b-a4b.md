# Gemma 4 26B A4B

- Modelo: `gemma-4-26B-A4B-it-qat-UD-Q4_K_XL.gguf`
- Repositorio: `unsloth/gemma-4-26B-A4B-it-qat-GGUF`
- Revisión: `7b92b5b28818151e8669af2e45e88d6086f490dd`
- Alias API: `gemma-4-26b-a4b`
- Arquitectura GGUF: `gemma4` (MoE, 128 expertos y 8 activos por token, 30 capas)

## Colocación automática

| Lanzador | Contexto | Batch/Ubatch | Visión | MTP |
| --- | ---: | ---: | :---: | :---: |
| `start-text-auto.cmd` | 131.072 | 1024/256 | no | no |
| `start-text-auto-mtp.cmd` | 131.072 | 1024/256 | no | sí |
| `start-vision-auto.cmd` | 65.536 | 1024/1024 | sí | no |
| `start-agentic-auto.cmd` | 262.144 | 1024/1024 | no | no |
| `start-agentic-auto-vision.cmd` | 262.144 | 1024/1024 | sí | no |
| `start-vision-auto-mtp.cmd` | 65.536 | 1024/1024 | sí | sí |

Los seis materializan `--gpu-layers auto --fit on --fit-target 1024` — `2048` en
los tres perfiles con visión porque `--fit` no contabiliza el proyector — y
omiten `--n-cpu-moe`. Los dos perfiles MTP declaran además
`--spec-draft-ngl auto` y usan el drafter separado
`mtp-gemma-4-26B-A4B-it.gguf`. Todos mantienen ocho hilos, caché KV Q8,
temperatura 1,0, `top_p=0.95` y `top_k=64`, salvo los perfiles agentic, que usan
temperatura 0,6 y penalización de presencia 0.

El modelo declara 30 capas, así que `--fit` resuelve `-ngl 31` (todas en GPU) y
descarga a la CPU las FFN expertas de un tramo final:

| Perfil | Tramo con expertos en CPU | Capas | Manual `n-cpu-moe` (retirado) |
| --- | --- | ---: | ---: |
| `start-agentic-auto.cmd` | blk.19–30 | 12 | 12 |
| `start-agentic-auto-vision.cmd` | blk.17–30 | 14 | 16 |
| `start-text-auto.cmd` | blk.25–30 | 6 | 5 |
| `start-text-auto-mtp.cmd` | blk.25–30 | 6 | 7 |
| `start-vision-auto.cmd` | blk.23–30 | 8 | 8 |
| `start-vision-auto-mtp.cmd` | blk.23–30 | 8 | 10 |

Estimación de `llama-fit-params.exe` con el escritorio reteniendo ~1,6 GiB, en
MiB y sumando modelo, contexto y búfer de cómputo:

| Perfil | Automático GPU / host | Manual GPU / host (retirado) |
| --- | ---: | ---: |
| `agentic` | 13.936 / 5.158 | 13.373 / 5.835 |
| `agentic-vision` | 12.843 / 6.251 | 11.739 / 7.469 |
| `text` | 13.899 / 2.239 | 13.760 / 2.508 |
| `text-mtp` | 13.899 / 2.239 | 12.943 / 3.325 |
| `vision` | 12.931 / 3.140 | 12.253 / 3.818 |
| `vision-mtp` | 12.931 / 3.140 | 11.437 / 4.634 |

En la mayoría de perfiles el reparto automático es más agresivo que el manual y
deja menos peso en la CPU; `text` es la excepción, con una capa más descargada.
`--fit` descarga un tramo final del modelo, mientras `--n-cpu-moe N` descarga las
primeras N capas, así que ambas políticas difieren en posición aunque coincidan
en número. La estimación de los perfiles MTP no incluye el drafter
`mtp-gemma-4-26B-A4B-it.gguf`, que `llama-fit-params.exe` no recibe.

`agentic-vision` combina la ventana completa del modelo (262.144, la misma que
Qwen3.6-35B-A3B) con la visión y el batch de `vision` (`UBatchSize` 1024), usando
el muestreo agentic; no usa MTP.

## Lanzadores retirados

Los seis perfiles manuales —`text`, `text-mtp`, `vision`, `agentic`,
`agentic-vision` y `vision-mtp`, que fijaban `--gpu-layers 999 --n-cpu-moe <N>
--fit off` y `--spec-draft-ngl 999`— se retiraron el 2026-09-30. Su copia de referencia bajo
`logs\reference\retired-launchers-20260930\` se eliminó el 2026-10-01.
La referencia `agentic` usaba 12 capas MoE en CPU (2026-08-06): sin el mmproj,
16 capas dejaban ~2,3 GiB libres; con 12 queda ~950 MiB libres por nvidia-smi
(~1,3 GB en el Administrador de tareas).

## Dependencias

- `config/models/gemma-4-26b-a4b.psd1`
- `scripts/models/gemma-4-26b-a4b/start-text-auto.cmd`
- `scripts/models/gemma-4-26b-a4b/start-text-auto-mtp.cmd`
- `scripts/models/gemma-4-26b-a4b/start-vision-auto.cmd`
- `scripts/models/gemma-4-26b-a4b/start-vision-auto-mtp.cmd`
- `scripts/models/gemma-4-26b-a4b/start-agentic-auto.cmd`
- `scripts/models/gemma-4-26b-a4b/start-agentic-auto-vision.cmd`
- `runtimes/llama.cpp/b11269-cuda13.4/`

## Related ADRs

- [ADR-0001: lanzadores autocontenidos](../../adr/ADR-0001-self-contained-model-launchers.md)
