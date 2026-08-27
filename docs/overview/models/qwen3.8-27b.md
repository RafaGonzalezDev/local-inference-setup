# Qwen3.8 27B

- Modelo: `Qwen3.8-27B-UD-IQ3_XXS.gguf`
- Proyector: `mmproj-F16.gguf`
- Cabezal MTP: `MTP/mtp-Qwen3.8-27B-Q4_0.gguf`
- Repositorio: `unsloth/Qwen3.8-27B-GGUF`
- Revisión: `27af057ecb382ddfea5d12837360a8980560e3ed`
- Alias API: `qwen3.8-27b`
- Licencia: Apache-2.0

Qwen3.8 27B es un modelo denso multimodal con 64 capas, visión nativa y
contexto nativo de 262.144 tokens. La primera configuración utiliza la variante
Dynamic 3.0 `UD-IQ3_XXS` de 10.934.860.704 bytes para dejar margen de VRAM en
una GPU de 16 GB.

## Perfiles

| Perfil | Contexto | Batch/UBatch | Visión | MTP |
| --- | ---: | ---: | :---: | :---: |
| `text` | 65.536 | 1.024/512 | no | no |
| `vision` | 32.768 | 1.024/512 | sí | no |
| `text-mtp` | 32.768 | 1.024/512 | no | sí, n-max 3 |

Los tres perfiles son deliberadamente conservadores. Comparten un slot,
`--gpu-layers 999`, Flash Attention, KV `q8_0`, ocho hilos, Jinja,
`--cache-ram 0`, `--split-mode none` y `--fit off`. El contexto, el batch y la
profundidad MTP se ampliarán sólo después de medir consumo, estabilidad y tasa
de aceptación.

El muestreo sigue las recomendaciones oficiales para thinking mode:
temperatura 1,0, `top-p 0,95`, `top-k 20`, `min-p 0`, penalización de presencia
0 y penalización de repetición 1. El presupuesto inicial de razonamiento es
8.192 tokens.

## Visión y MTP

El perfil `vision` carga el proyector F16 oficial y reserva
`--image-min-tokens 1024`. No combina visión con MTP durante la primera fase.

Aunque el checkpoint fue entrenado con Multi-Token Prediction, el GGUF
principal no incorpora el cabezal. Unsloth lo distribuye como el archivo
independiente `MTP/mtp-Qwen3.8-27B-Q4_0.gguf`; `text-mtp` lo carga mediante
`--spec-draft-model`, `--spec-type draft-mtp`, `--spec-draft-n-max 3` y
`--spec-draft-ngl 999`.

## Estado

Los lanzadores y artefactos están preparados para una validación manual
posterior. Esta incorporación no inicia `llama-server`, no carga los pesos y no
realiza inferencias, pruebas funcionales ni pruebas de imagen.
