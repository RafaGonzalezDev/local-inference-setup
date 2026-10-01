# Ornith 1.5 35B A3B

- Modelo: `Ornith-1.5-35B-A3B-AD-Q4_K-IQ4_XS.gguf`
- Repositorio: `AtomicChat/Ornith-1.5-35B-A3B-GGUF`
- Revisión: `7aa8fc1d9b861d797880f4a341166d4bb3439f74`
- Alias API: `ornith-1.5-35b-a3b`
- Arquitectura GGUF: `qwen35moe` (MoE, 256 expertos y 8 activos por token, 40 capas)

La variante `AD-Q4_K-IQ4_XS` ocupa 20.125.923.520 bytes. AtomicChat la sitúa
en 20,13 GB y publica una divergencia media inferior a la del `Q4_K_M`, además
de reducir aproximadamente 1 GB de tamaño. El modelo activa unos 3B parámetros
por token de un total de 34,7B y admite hasta 262.144 tokens de contexto.

## Perfiles

### Colocación automática

| Lanzador | Contexto | Batch/UBatch | Visión | MTP |
| --- | ---: | ---: | :---: | :---: |
| `start-agentic-auto-131k-2048.cmd` | 131.072 | 2.048/2.048 | no | no |
| `start-agentic-auto-262k-1024.cmd` | 262.144 | 1.024/1.024 | no | no |

Ambos materializan un perfil agentic de alta prefill y declaran
`--gpu-layers auto --fit on --fit-target 1024`, sin `--n-cpu-moe`. Conservan los
parámetros comunes del entorno: ocho hilos, KV `q8_0`, Flash Attention, un slot,
`--cache-ram 0`, `--split-mode none`, Jinja y presupuesto de razonamiento 8.192.
El muestreo usa `temp 0.6`, `top-p 0.95`, `top-k 20` con `--reasoning on`.

La caché KV usa `q8_0` tanto para claves como para valores para reducir su
consumo en las ventanas de 131.072 y 262.144 tokens.

Con el contexto declarado, `--fit` resuelve en este hardware `-c <ctx> -ngl 41`,
esto es, las 40 capas en GPU, y manda a la CPU las FFN expertas de un tramo
final del modelo:

| Perfil | Tramo con expertos en CPU | Capas |
| --- | --- | ---: |
| `start-agentic-auto-131k-2048.cmd` | blk.20–39 | 20 |
| `start-agentic-auto-262k-1024.cmd` | blk.19–39 | 21 |

A diferencia de `--n-cpu-moe N`, que descargaba las primeras N capas, `--fit`
descarga un tramo al final. El contexto debe seguir declarado: si se omite,
`--fit` lo reduce al mínimo de `--fit-ctx`, 4.096 tokens.

El modelo conserva la arquitectura multimodal Qwen, pero en la configuración
actual no existe un lanzador de visión: el proyector F16 de Qwen3.6 35B A3B
(`models/qwen3.6-35b-a3b/mmproj-F16.gguf`) no se invoca y los perfiles envían
`VISION_ARGS` vacío. Si se añade un perfil visual más adelante, debe incluir
`--image-min-tokens 1024` como exige la tarjeta del modelo.

Ornith soporta MTP nativo sobre el propio GGUF con `--spec-type draft-mtp`,
pero en la revisión fijada no hay un artefacto draft público separado y en la
configuración actual no hay lanzador MTP (`MTP_ARGS` vacío).

Todos los perfiles usan `0.0.0.0:8080` sin autenticación y deben ejecutarse
como alternativas. Su funcionamiento queda pendiente de la prueba manual
solicitada por el usuario; esta preparación no inicia `llama-server` ni realiza
inferencias.

## Lanzadores retirados

Los perfiles manuales `start-agentic-131k-2048.cmd` y
`start-agentic-262k-1024.cmd` (`--gpu-layers 999 --n-cpu-moe 20/24 --fit off`) se
retiraron el 2026-09-30. Su copia de referencia bajo
`logs\reference\retired-launchers-20260930\` se eliminó el 2026-10-01.

Antes de esta retirada ya se habían eliminado los perfiles de visión (`vision`,
`agentic-vision`) y MTP/ágiles (`agentic-mtp`, `agentic-131k-4096`,
`agentic-200k-2048`, `agentic-mtp-131k-4096`) que documentaban equivalentes a los
de Qwen3.6 35B A3B.

| Perfil (retirado) | Contexto | CPU-MoE | Batch/UBatch | Visión | MTP |
| --- | ---: | ---: | ---: | :---: | :---: |
| `vision` | 65.536 | 23 | 1.024/1.024 | sí | no |
| `agentic-vision` | 262.144 | 28 | 1.024/1.024 | sí | no |
| `agentic-mtp` | 262.144 | 28 | 1.024/1.024 | no | sí, n-max 3 |
| `agentic-131k-4096` | 131.072 | 23 | 4.096/4.096 | no | no |
| `agentic-200k-2048` | 200.000 | 25 | 2.048/2.048 | no | no |
| `agentic-mtp-131k-4096` | 131.072 | 26 | 2.048/2.048 | no | sí, n-max 3 |

## Dependencias

- `config/models/ornith-1.5-35b-a3b.psd1`
- `scripts/models/ornith-1.5-35b-a3b/start-agentic-auto-131k-2048.cmd`
- `scripts/models/ornith-1.5-35b-a3b/start-agentic-auto-262k-1024.cmd`
- `runtimes/llama.cpp/b11269-cuda13.4/`

## Related ADRs

- [ADR-0001: lanzadores autocontenidos](../../adr/ADR-0001-self-contained-model-launchers.md)
