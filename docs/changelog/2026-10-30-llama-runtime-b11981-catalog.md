# 2026-10-30 - Pasar todo el catálogo a b11981 y eliminar b11551

**Qué**: Los 18 lanzadores que seguían en `b11551-cuda13.4` pasan a `b11981-cuda13.4`, que ya usaban
los dos de Flint; se eliminan `runtimes\llama.cpp\b11551-cuda13.4` y `packages\llama.cpp\b11551`, y
`Install-LlamaRuntime.ps1` pasa a instalar `b11981` por defecto. Solo cambia la línea `SERVER` de
cada lanzador (y el comentario de runtime de los de Flint).

**Dónde**: `scripts/models/*/start-*.cmd`, `scripts/setup/Install-LlamaRuntime.ps1`, `README.md`,
`AGENTS.md`, `handoff.md`, `docs/overview/inference-backend.md`, las fichas de `docs/overview/models/`
y `experimental/lfm3/README.md`.

**Por qué**: Decisión del usuario tras medir los dos runtimes con el perfil `agentic-auto-131k-1024`
de cada modelo (dos arranques por runtime en orden A-B-B-A, prompt de ~112K tokens con 256 de
salida y un decode con prompt corto). Medias en t/s:

| Modelo | Runtime | Prefill 112K | Decode 112K | Decode corto | VRAM pico | RAM libre mínima |
| --- | --- | ---: | ---: | ---: | ---: | ---: |
| Tiel Coder | b11551 | 1.959,6 | 61,12 | 83,60 | 15.595 MiB | 38.168 MiB |
| | b11981 | 2.038,1 (+4,0 %) | 62,48 (+2,2 %) | 84,81 (+1,4 %) | 15.728 MiB | 38.297 MiB |
| Nail Qwen3.6 | b11551 | 2.021,2 | 61,02 | 84,28 | 15.534 MiB | 38.759 MiB |
| | b11981 | 2.107,4 (+4,3 %) | 62,45 (+2,3 %) | 86,31 (+2,4 %) | 15.709 MiB | 39.107 MiB |
| Occult Nail | b11551 | 2.023,1 | 61,69 | 84,60 | 15.367 MiB | 38.968 MiB |
| | b11981 | 2.109,5 (+4,3 %) | 62,66 (+1,6 %) | 85,99 (+1,6 %) | 15.537 MiB | 39.167 MiB |
| Cyber Tiel | b11551 | 1.960,6 | 61,02 | 83,66 | 15.541 MiB | 38.928 MiB |
| | b11981 | 2.043,4 (+4,2 %) | 62,99 (+3,2 %) | 85,36 (+2,0 %) | 15.550 MiB | 39.178 MiB |
| Nemotron 3.5 Lightning | b11551 | 2.870,4 | 76,88 | 100,09 | 15.483 MiB | 43.760 MiB |
| | b11981 | 2.855,3 (−0,5 %) | 76,95 (+0,1 %) | 100,67 (+0,6 %) | 15.478 MiB | 43.761 MiB |

La dispersión entre repeticiones fue menor del 0,5 % en prefill y del 3 % en decode. Las mediciones son
sintéticas desde PowerShell, no a través de Pi: AGENTS.md pide contrastar en Pi antes de adoptar un
runtime, y el usuario decidió adoptarlo sin esa prueba.

## Validación

- `Test-Llm.ps1 -ConfigurationOnly -RequireInstalledFiles` sin filtros pasa 20/20, antes y después de
  borrar `b11551`.
- `Test-Llm.ps1` (smoke) pasa en los 20 perfiles con `b11981`, incluidos los ocho de visión con
  `panels-1080p.png`; el smoke no comprueba que la descripción corresponda a la imagen.
- No se recalibraron bajo carga los perfiles 262K ni los de visión: con `b11981` la VRAM pico de los
  131K subió hasta 175 MiB en algunos modelos, así que sus márgenes pueden ser algo menores que los
  registrados en las fichas.
