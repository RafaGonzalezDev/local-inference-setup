# Qwen3.6 35B A3B

- Modelo: `Qwen3.6-35B-A3B-UD-Q4_K_M.gguf`
- Repositorio base: `unsloth/Qwen3.6-35B-A3B-GGUF`
- Revisión base: `a483e9e6cbd595906af30beda3187c2663a1118c`
- Repositorio MTP: `unsloth/Qwen3.6-35B-A3B-MTP-GGUF`
- Revisión MTP: `5bc3e238d916f48a861bac2f8a1990a0e9b7e98d`
- Alias API: `qwen3.6-35b-a3b`
- Arquitectura GGUF: `qwen35moe` (MoE, 256 expertos y 8 activos por token, 40 capas)

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

### Colocación automática

| Lanzador | Contexto | Batch/UBatch | Visión | MTP |
| --- | ---: | ---: | :---: | :---: |
| `start-agentic-auto-131k-2048.cmd` | 131.072 | 2.048/2.048 | no | no |
| `start-agentic-auto-262k-1024.cmd` | 262.144 | 1.024/1.024 | no | no |
| `start-agentic-auto-mtp-131k-2048.cmd` | 131.072 | 1.024/1.024 | no | sí, n-max 3 |
| `start-agentic-auto-vision-131k-2048.cmd` | 131.072 | 2.048/2.048 | sí | no |

Los cuatro comparten la configuración base: ocho hilos, caché KV `q8_0`,
Flash Attention, un slot, `--parallel 1`, `--cache-ram 0`, `--split-mode none`,
Jinja y presupuesto de razonamiento 8.192. El muestreo usa `temp 0.6`,
`top-p 0.95`, `top-k 20`, `min-p 0`, `presence-penalty 0`, `repeat-penalty 1`
con `--reasoning on`.

Los cuatro materializan `--gpu-layers auto --fit on --fit-target 1024` y omiten
`--n-cpu-moe`: `--fit` coloca los pesos con `-ot` por capa en lugar de usar esa
palanca. El perfil de visión usa `--fit-target 2048` porque `--fit` no
contabiliza el proyector multimodal, que se descarga a la GPU por defecto
(`--mmproj-offload` está habilitado). El perfil MTP usa el GGUF de `mtp\`, que
declara 41 bloques porque añade el módulo de borrador.

- **Auto agentic 131k** (`start-agentic-auto-131k-2048.cmd`): GGUF base con
  `batch/ubatch 2048/2048`. No incluye visión ni MTP.
- **Auto agentic 262k** (`start-agentic-auto-262k-1024.cmd`): GGUF base con
  `batch/ubatch 1024/1024`. No incluye visión ni MTP.
- **Auto MTP agentic** (`start-agentic-auto-mtp-131k-2048.cmd`): GGUF MTP con
  `batch/ubatch 1024/1024` y `--spec-type draft-mtp --spec-draft-n-max 3` para
  descodificación especulativa. El nombre conserva el sufijo histórico `2048`,
  pero los valores efectivos son 1024/1024. No incluye visión.
- **Auto vision agentic** (`start-agentic-auto-vision-131k-2048.cmd`): GGUF base
  con `batch/ubatch 2048/2048` y `--mmproj mmproj-F16.gguf
  --image-min-tokens 2048` para visión. No incluye MTP.

Con el contexto declarado, `--fit` resuelve en este hardware `-c <ctx> -ngl 41`,
esto es, las 40 capas en GPU, y manda a la CPU las FFN expertas de un tramo
final del modelo:

| Perfil | Tramo con expertos en CPU | Capas |
| --- | --- | ---: |
| `start-agentic-auto-131k-2048.cmd` | blk.18–39 | 22 |
| `start-agentic-auto-262k-1024.cmd` | blk.17–39 | 23 |
| `start-agentic-auto-mtp-131k-2048.cmd` | blk.21–40 | 20 |
| `start-agentic-auto-vision-131k-2048.cmd` | blk.15–39 | 25 |

`--fit` extiende el patrón `-ot` hasta `blk.40`; en el modelo base, que declara
40 capas, ese último patrón no coincide con ningún tensor. A diferencia de
`--n-cpu-moe N`, que descargaba las primeras N capas, `--fit` descarga un tramo
al final. El contexto debe seguir declarado: si se omite, `--fit` lo reduce al
mínimo de `--fit-ctx`, 4.096 tokens.

## Lanzadores retirados

Los cuatro perfiles manuales —`start-agentic-131k-2048.cmd`,
`start-agentic-262k-1024.cmd`, `start-agentic-mtp-131k-2048.cmd` y
`start-agentic-vision-131k-2048.cmd`, que fijaban `--gpu-layers 999
--n-cpu-moe <N> --fit off`— se retiraron el 2026-09-30. Su copia de referencia bajo
`logs\reference\retired-launchers-20260930\` se eliminó el 2026-10-01.

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
- `scripts/models/qwen3.6-35b-a3b/start-agentic-auto-131k-2048.cmd`
- `scripts/models/qwen3.6-35b-a3b/start-agentic-auto-262k-1024.cmd`
- `scripts/models/qwen3.6-35b-a3b/start-agentic-auto-mtp-131k-2048.cmd`
- `scripts/models/qwen3.6-35b-a3b/start-agentic-auto-vision-131k-2048.cmd`
- `runtimes/llama.cpp/b11269-cuda13.4/`

## Related ADRs

- [ADR-0001: lanzadores autocontenidos](../../adr/ADR-0001-self-contained-model-launchers.md)
