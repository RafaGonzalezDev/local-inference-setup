# Ornith 1.5 9B

- Modelo: `Ornith-1.5-9B-AD-IQ4_XS.gguf`
- Repositorio: `AtomicChat/Ornith-1.5-9B-GGUF`
- Revisión: `2f8ad6c3dc473d3044c5c01de25751d3d12782ec`
- Alias API: `ornith-1.5-9b`
- Arquitectura GGUF: `qwen35` (denso, sin tensores de expertos, 32 capas)

## Arquitectura

Ornith 1.5 9B es un modelo híbrido de aproximadamente 8,95B parámetros y
contexto nativo de 262.144 tokens. No se instala un proyector visual ni un
modelo draft MTP para este perfil.

## Artefacto

| Cuantización | Archivo | Tamaño | SHA-256 |
| --- | --- | ---: | --- |
| `AD-IQ4_XS` | `Ornith-1.5-9B-AD-IQ4_XS.gguf` | 5.517.828.864 bytes | `09f4b19dc7f0b1d4cf5480bb96ab4a42a88e93ddf28f98bf56a8580d4436afa7` |

La revisión pinneada contiene el archivo IQ4_XS con ese nombre. El manifiesto,
`SHA256SUMS`, el archivo instalado y el launcher usan la misma cuantización.

## Perfil

### Colocación automática

| Lanzador | Contexto | Batch/UBatch | Visión | MTP |
| --- | ---: | ---: | :---: | :---: |
| `start-agentic-auto-262k-1024.cmd` | 262.144 | 1.024/1.024 | no | no |

El lanzador declara contexto, batch/ubatch, muestreo, alias y puerto, y
materializa `--gpu-layers auto --fit on --fit-target 1024`. Con 262.144 tokens,
`--fit` resuelve `-ngl -1`: las 32 capas caben en la GPU y no se descarga
ninguna.

Usa Flash Attention, ocho hilos, caché KV `q8_0`, un slot, `--cache-ram 0`,
`--split-mode none`, Jinja, `--no-cache-idle-slots` y un presupuesto de
razonamiento sin límite artificial (`--reasoning-budget -1`). El muestreo usa
`temp 0.6`, `top-p 0.95` y `top-k 20`; los parámetros no materializados
conservan el default de llama.cpp.

## Lanzador retirado

El perfil manual `start-agentic-262k-1024.cmd` se retiró el 2026-09-30; fijaba
`--gpu-layers 999 --n-cpu-moe 20 --fit off`. Su copia de referencia bajo
`logs\reference\retired-launchers-20260930\` se eliminó el 2026-10-01.

El modelo declara la arquitectura `qwen35` sin tensores de expertos
(`n_expert = 0`). `llama-fit-params.exe` devuelve la misma estimación con
`--n-cpu-moe 20` y sin él, 10.756 MiB en GPU y 1.089 MiB en host, así que aquel
`--n-cpu-moe 20` era inerte en este modelo.

## Estado

- Integridad verificada contra tamaño y SHA-256.
- Prueba funcional superada en 4,24 segundos con el perfil retirado
  `agentic-262k-1024` (`n-cpu-moe 20`); el proceso terminó limpiamente y liberó
  el puerto 8080.
- Validación funcional del perfil automático: pendiente.

## Dependencias

- `config/models/ornith-1.5-9b.psd1`
- `scripts/models/ornith-1.5-9b/start-agentic-auto-262k-1024.cmd`
- `runtimes/llama.cpp/b11269-cuda13.4/`

## Source

- [Hugging Face model repository](https://huggingface.co/AtomicChat/Ornith-1.5-9B-GGUF)
- License: MIT
