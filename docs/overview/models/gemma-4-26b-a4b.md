# Gemma 4 26B A4B

- Modelo: `gemma-4-26B-A4B-it-qat-UD-Q4_K_XL.gguf`
- Repositorio: `unsloth/gemma-4-26B-A4B-it-qat-GGUF`
- Revisión: `7b92b5b28818151e8669af2e45e88d6086f490dd`
- Alias API: `gemma-4-26b-a4b`

| Perfil | Contexto | CPU-MoE | Ubatch | Visión | MTP |
| --- | ---: | ---: | ---: | :---: | :---: |
| `text` | 131.072 | 5 | 256 | no | no |
| `text-mtp` | 131.072 | 7 | 256 | no | sí |
| `vision` | 65.536 | 8 | 1.024 | sí | no |
| `agentic` | 262.144 | 12 | 1.024 | no | no |
| `agentic-vision` | 262.144 | 16 | 1.024 | sí | no |
| `vision-mtp` | 65.536 | 10 | 1.024 | sí | sí |

El MTP utiliza el drafter separado `mtp-gemma-4-26B-A4B-it.gguf`. Los perfiles
mantienen ocho hilos, caché KV Q8, temperatura 1,0, `top_p=0.95` y `top_k=64`.

`agentic-vision` combina la ventana completa del modelo (262.144, la misma que
Qwen3.6-35B-A3B) con la visión y el batch de `vision` (`UBatchSize` 1024),
usando el muestreo agentic (temperatura 0,6 y penalización de presencia 0);
no usa MTP.

`agentic` (sin visión) usa la misma ventana y muestreo agentic con 12 capas MoE
en CPU (2026-08-06): sin el mmproj, 16 capas dejaban ~2,3 GiB libres; con 12
queda ~950 MiB libres por nvidia-smi (~1,3 GB en el Administrador de tareas).
