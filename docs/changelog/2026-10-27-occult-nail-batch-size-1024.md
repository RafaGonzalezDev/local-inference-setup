# Occult Nail 1.0 35B-A3B — batch-size reducido a 1024

- **Fecha**: 2026-10-27
- **Motivo**: los perfiles de `occult-nail-1.0-35b-a3b` heredaban el `batch/ubatch 2048/2048` de
  `qwen3.6-35b-a3b` sin calibración. Se reducen a `1024/1024` el perfil 131K y el de visión 131K
  para alinearlos con Nail y dejar margen de memoria.
- **Archivos modificados**:
  - `scripts/models/occult-nail-1.0-35b-a3b/start-agentic-auto-131k-2048.cmd` →
    `start-agentic-auto-131k-1024.cmd`
  - `scripts/models/occult-nail-1.0-35b-a3b/start-agentic-auto-vision-131k-2048.cmd` →
    `start-agentic-auto-vision-131k-1024.cmd`
  - `README.md` — tabla de perfiles y lista de lanzadores actualizados
  - `docs/overview/models/occult-nail-1.0-35b-a3b.md` — tabla de perfiles y notas de validación

- **Batch/UBatch nuevos**: `1024/1024` en ambos perfiles. `--fit-target 2048` y
  `--image-min-tokens 2048` se conservan en visión: no son batch.
- **Perfil 262K**: no cambiado; ya usaba `1024/1024`.
- **Aliases de perfil**: sin cambios (`occult-nail-1.0-35b-a3b-131k`,
  `occult-nail-1.0-35b-a3b-vision-131k`), por lo que los catálogos de cliente no cambian.
- **Pendiente**: recalibrar memoria y rendimiento con `1024/1024`; las mediciones documentadas se
  tomaron con `2048/2048`.
