# 2026-11-22 - Retirada de Inkling 2 Mini

**Qué**: Se retiran las dos instalaciones de Inkling 2 Mini:

- `inkling-2-mini` sobre `maya-ik2` (fork de Project Maya compilado desde el commit `e819852`): pesos
  `models/inkling-2-mini/` (16,4 GB), runtime `runtimes/maya-ik2/` (1,4 GB) y el subárbol `maya/` completo.
- `inkling-2-mini-sq-15` sobre Strata 0.2.19: pesos `models/inkling-2-mini-sq-15/` (13,4 GB), manifiesto, lanzadores,
  el componente `strata-inkling` (`components/shapes/`) y su configuración de instalación.

Los alias `inkling-2-mini-131k`, `-262k` y `inkling-2-mini-sq-15-131k`, `-262k` salen de Pi, OpenCode y DSH
(repositorio y global) y de los clientes de WSL. `AGENTS.md` deja de describir `maya/` y su revisión periódica. Los
clientes listan 53 alias: 51 de llama.cpp y 2 de `strata/`.

**Por qué**: Lo pidió el usuario. El SQ-15 solo era utilizable hasta ~32K tokens en esta tarjeta y Strata lo sirve
sin razonamiento (ver la investigación en su [ficha](../overview/models/inkling-2-mini-sq-15.md)); Qwen3.8 Flash
Next, adoptado el mismo día, cubre su uso.

**Se conserva**: las fichas (históricas, con nota de retirada), los changelogs anteriores y los logs de
`logs/validation/` y `logs/maya/`. Strata 0.2.19 y Flash-Next no cambian.

## Validación

- Paridad de alias: 53 servidos y 53 en Pi, en los dos perfiles de OpenCode y en DSH (repositorio y global).
- Ningún archivo activo de `D:\LLM` (`AGENTS.md`, `README.md`, `config/`, `scripts/`, `strata/`) referencia
  `maya/` ni los modelos retirados.
