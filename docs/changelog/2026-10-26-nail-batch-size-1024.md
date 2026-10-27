# Nail qwen3.6-35b-a3b — batch-size reducido a 1024

- **Fecha**: 2026-10-26
- **Motivo**: los perfiles de `nail-qwen3.6-35b-a3b` compartían el `batch-size 2048` de `qwen3.6-35b-a3b` como punto de partida sin calibración. Se redujo a `1024/1024` tanto en el perfil 131K como en el de visión 131K para mayor estabilidad de memoria.
- **Archivos modificados**:
  - `scripts/models/nail-qwen3.6-35b-a3b/start-agentic-auto-131k-2048.cmd` → `start-agentic-auto-131k-1024.cmd`
  - `scripts/models/nail-qwen3.6-35b-a3b/start-agentic-auto-vision-131k-2048.cmd` → `start-agentic-auto-vision-131k-1024.cmd`
  - `README.md` — tabla de perfiles y lista de lanzadores actualizados
  - `docs/overview/models/nail-qwen3.6-35b-a3b.md` — tabla de perfil, descripción y texto
  - `AGENTS.md` — tabla de referencia con los nombres de lanzador actualizados

- **Batch/UBatch nuevos**: `1024/1024` en ambos perfiles (131K y visión). `--fit-target 2048` se conserva en visión por el margen del proyector.
- **Perfiles MTP y 262K**: no cambiados; ya usan `1024/1024` y su batch se mantuvo.
- **Aliases de perfil**: sin cambios (`nail-qwen3.6-35b-a3b-131k`, `nail-qwen3.6-35b-a3b-vision-131k`).
- **Catálogos de clientes**: sin cambios, porque los alias no cambian. Espejado en `local-inference-setup` el 2026-10-28.
