# Qwen3.6 35B A3B

- Modelo: `Qwen3.6-35B-A3B-UD-Q4_K_M.gguf`
- Repositorio base: `unsloth/Qwen3.6-35B-A3B-GGUF`
- Revisión base: `a483e9e6cbd595906af30beda3187c2663a1118c`
- Repositorio MTP: `unsloth/Qwen3.6-35B-A3B-MTP-GGUF`
- Revisión MTP: `5bc3e238d916f48a861bac2f8a1990a0e9b7e98d`
- Alias API: `qwen3.6-35b-a3b`

## Artefactos

| Cuantización | Archivo | Tamaño | SHA-256 |
| --- | --- | ---: | --- |
| `UD-Q4_K_M` (base) | `Qwen3.6-35B-A3B-UD-Q4_K_M.gguf` | 22.134.528.992 bytes | `ac0e2c1189e055faa36eff361580e79c5bd6f8e76bffb4ce547f167d53e31a61` |
| `UD-Q4_K_M` (MTP integrado) | `mtp/Qwen3.6-35B-A3B-UD-Q4_K_M.gguf` | 22.663.387.424 bytes | `0b21525e972670ed59e1812e170b27c26355381f0656ecc4e25617ece7dac58b` |
| `F16` (mmproj) | `mmproj-F16.gguf` | 899.283.680 bytes | `8971ee4f331ff0a4c609374f32984b3d4e6dc086c0aa35f1d637fad1829e887f` |

El artefacto base se fija a la revisión `a483e9e6cbd595906af30beda3187c2663a1118c`
de `unsloth/Qwen3.6-35B-A3B-GGUF`. El artefacto MTP se fija a la revisión
`5bc3e238d916f48a861bac2f8a1990a0e9b7e98d` de `unsloth/Qwen3.6-35B-A3B-MTP-GGUF`.
El proyecto de visión usa `mmproj-F16.gguf` para la proyección multimodal.

## Perfiles

| Lanzador | Contexto | Batch/UBatch | `n-cpu-moe` | Visión | MTP |
| --- | ---: | ---: | ---: | :---: | :---: |
| `start-agentic-131k-2048.cmd` | 131.072 | 2.048/2.048 | 22 | no | no |
| `start-agentic-262k-1024.cmd` | 262.144 | 1.024/1.024 | 24 | no | no |
| `start-agentic-mtp-131k-2048.cmd` | 131.072 | 1.024/1.024 | 25 | no | sí, n-max 3 |
| `start-agentic-vision-131k-2048.cmd` | 131.072 | 2.048/2.048 | 24 | sí | no |

Los cuatro lanzadores comparten la configuración base: ocho hilos, caché KV `q8_0`,
Flash Attention, un slot, `--gpu-layers 999`, `--parallel 1`, `--cache-ram 0`,
`--split-mode none`, `--fit off`, Jinja y presupuesto de razonamiento 8.192.
El muestreo usa `temp 0.6`, `top-p 0.95`, `top-k 20`, `min-p 0`,
`presence-penalty 0`, `repeat-penalty 1` con `--reasoning on`.

- **Base agentic 131k** (`start-agentic-131k-2048.cmd`): utiliza el GGUF base con
  `n-cpu-moe 22` y `batch/ubatch 2048/2048`. No incluye visión ni MTP.
- **Base agentic 262k** (`start-agentic-262k-1024.cmd`): utiliza el GGUF base con
  `n-cpu-moe 24` y `batch/ubatch 1024/1024`. No incluye visión ni MTP.
- **MTP agentic** (`start-agentic-mtp-131k-2048.cmd`): utiliza el GGUF MTP con
  `n-cpu-moe 25`, `batch/ubatch 1024/1024` y `--spec-type draft-mtp
  --spec-draft-n-max 3` para descodificación especulativa. El nombre conserva
  el sufijo histórico `2048`, pero los valores efectivos son 1024/1024.
  No incluye visión.
- **Vision agentic** (`start-agentic-vision-131k-2048.cmd`): utiliza el GGUF
  base con `n-cpu-moe 24`, `batch/ubatch 2048/2048` y `--mmproj
  mmproj-F16.gguf --image-min-tokens 2048` para visión. No incluye MTP.

## Calibración histórica

Las mediciones siguientes corresponden a los perfiles anteriores `vision`,
`agentic-vision`, `agentic-mtp`, `agentic-131k-4096`, `agentic-200k-2048` y
`agentic-mtp-131k-4096`, tal como se ejecutaban con los lanzadores antiguos.
Se conservan como referencia histórica y no describen los lanzadores actuales.

| Perfil | Contexto | `n-cpu-moe` | Batch/UBatch | Visión | MTP |
| --- | ---: | ---: | ---: | :---: | :---: |
| `vision` | 65.536 | 23 | 1.024/1.024 | sí | no |
| `agentic-vision` | 262.144 | 28 | 1.024/1.024 | sí | no |
| `agentic-mtp` | 262.144 | 28 | 1.024/1.024 | no | sí |
| `agentic-131k-4096` | 131.072 | 23 | 4.096/4.096 | no | no |
| `agentic-200k-2048` | 200.000 | 25 | 2.048/2.048 | no | no |
| `agentic-mtp-131k-4096` | 131.072 | 26 | 2.048/2.048 | no | sí |

Los perfiles `vision` y `agentic-vision` lanzaban además
`--image-min-tokens 1024`; los perfiles de visión conservaban temperatura 1,0
y penalización de presencia 1,5. Todos los perfiles agentic usaban temperatura
0,6 y penalización de presencia 0.

## Dependencias

- `config/models/qwen3.6-35b-a3b.psd1`
- `scripts/models/qwen3.6-35b-a3b/start-agentic-131k-2048.cmd`
- `scripts/models/qwen3.6-35b-a3b/start-agentic-262k-1024.cmd`
- `scripts/models/qwen3.6-35b-a3b/start-agentic-mtp-131k-2048.cmd`
- `scripts/models/qwen3.6-35b-a3b/start-agentic-vision-131k-2048.cmd`
- `runtimes/llama.cpp/b10502-cuda13.3/`

## Related ADRs

- [ADR-0001: lanzadores autocontenidos](../../adr/ADR-0001-self-contained-model-launchers.md)
