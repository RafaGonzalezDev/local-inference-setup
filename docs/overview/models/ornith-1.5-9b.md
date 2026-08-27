# Ornith 1.5 9B

- Modelo: `Ornith-1.5-9B-AD-IQ4_XS.gguf`
- Repositorio: `AtomicChat/Ornith-1.5-9B-GGUF`
- Revisión: `2f8ad6c3dc473d3044c5c01de25751d3d12782ec`
- Alias API: `ornith-1.5-9b`
- Arquitectura GGUF: `qwen35`

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

| Lanzador | Contexto | Batch/UBatch | `n-cpu-moe` | Visión | MTP |
| --- | ---: | ---: | ---: | :---: | :---: |
| `start-agentic-262k-1024.cmd` | 262.144 | 1.024/1.024 | 20 | no | no |

El launcher usa `--gpu-layers 999`, Flash Attention, ocho hilos, caché KV
`q8_0`, un slot, `--cache-ram 0`, `--split-mode none`, `--fit off`, Jinja,
`--no-cache-idle-slots` y un presupuesto de razonamiento sin límite artificial
(`--reasoning-budget -1`). El muestreo usa `temp 0.6`, `top-p 0.95` y
`top-k 20`; los parámetros no materializados conservan el default de llama.cpp.

## Estado

- Integridad verificada contra tamaño y SHA-256.
- Configuración declarativa y paths instalados verificados.
- Prueba funcional superada en 4,19 segundos con `n-cpu-moe 20`.
- El proceso terminó limpiamente y liberó el puerto 8080.

## Dependencias

- `config/models/ornith-1.5-9b.psd1`
- `scripts/models/ornith-1.5-9b/start-agentic-262k-1024.cmd`
- `runtimes/llama.cpp/b10502-cuda13.3/`

## Source

- [Hugging Face model repository](https://huggingface.co/AtomicChat/Ornith-1.5-9B-GGUF)
- License: MIT
