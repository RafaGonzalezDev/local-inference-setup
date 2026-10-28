# 2026-10-28 - Retirada de Qwen3.6 base, LFM2.5, Nemotron 3.5 Bolt y Ornith 1.5

**Qué**: se retiran `qwen3.6-35b-a3b` (el base de `unsloth`), `lfm2.5-24b-a2b`,
`nemotron-3.5-bolt-e4b` y `ornith-1.5-35b-a3b`: catálogo, manifiestos, lanzadores, fichas y pesos. El
catálogo queda en 3 modelos y 10 perfiles (`tiel-coder-35b-a3b-mtp`, `nail-qwen3.6-35b-a3b` y
`occult-nail-1.0-35b-a3b`), todos sobre `b11669-cuda13.4`. Se retiraron el mismo día los modelos LFM3 y
el runtime compilado ([changelog](2026-10-28-lfm3-retirement.md)).

**Por qué**: el usuario eligió qué modelos ya no usa. «Ornith 1.3 35B-A3B» se interpretó como
`ornith-1.5-35b-a3b`, el único Ornith 35B-A3B del catálogo; no existía ningún 1.3.

## Eliminado

- Pesos: `models/qwen3.6-35b-a3b` (unos 43 GB, con el GGUF base, el MTP y el proyector),
  `models/lfm2.5-24b-a2b` (13,5 GB), `models/nemotron-3.5-bolt-e4b` (5,8 GB) y
  `models/ornith-1.5-35b-a3b` (18,7 GB).
- `config/models/<id>.psd1`, `scripts/models/<id>/` (8 lanzadores: los cuatro de Qwen,
  `lfm2.5-24b-a2b-131k`, `nemotron-3.5-bolt-e4b-65k` y los dos de Ornith) y `docs/overview/models/<id>.md`.
- Entradas de `config/catalog.psd1`, de la tabla y la lista de lanzadores del `README.md`, las filas de
  referencia de Qwen y la excepción de batch de LFM2.5 en `AGENTS.md`, y las referencias de `handoff.md`.
- Clientes: los ocho alias de perfil de DSH (repositorio y configuración global), los cinco
  `opencode.json`, el catálogo de Pi, sus documentos y los clientes activos de WSL (incluidos recientes,
  favoritos y variantes guardados por OpenCode).

## Se conserva

- Los changelogs históricos de estos modelos y las fichas de Nail, Occult Nail y Tiel Coder, que citan
  Qwen3.6 y Ornith solo como origen de sus modelos base. Nail y Occult Nail tienen sus propios GGUF y
  proyectores y no usaban archivos de `models/qwen3.6-35b-a3b`.
- Los ejemplos de README y `model-management.md` que usaban Qwen pasan a Nail, y las referencias de
  lanzadores de `AGENTS.md` a Nail y Tiel.
- Los lanzadores, manifiestos con revisión y SHA-256 y fichas siguen en el historial git de
  `local-inference-setup`, desde donde se pueden restaurar y volver a descargar.

## Validación

- `Test-Llm.ps1 -ConfigurationOnly -RequireInstalledFiles` sin filtros: 10 perfiles, 0 fallos.
- Los 8 catálogos de cliente contienen exactamente los 10 alias de los lanzadores.
