# 2026-10-28 - Perfiles con y sin MTP, y visión a 262K, en cada modelo

**Qué**: a petición del usuario, cada modelo tiene lanzadores con y sin MTP cuando es posible, y
perfiles de visión a 131K y 262K si tiene proyector. Los perfiles de visión nunca llevan MTP. Todos
los lanzadores nuevos usan batch/ubatch 1.024/1.024. El catálogo pasa a 4 modelos y 22 perfiles:

| Modelo | Perfiles |
| --- | --- |
| `tiel-coder-35b-a3b-mtp` | `mtp-131k`, `mtp-262k`, `131k`, `262k`, `vision-131k`, `vision-262k` |
| `cyber-tiel-coder-35b-a3b-mtp` | los mismos seis |
| `nail-qwen3.6-35b-a3b` | `131k`, `262k`, `mtp-131k`, `mtp-262k`, `vision-131k`, `vision-262k` |
| `occult-nail-1.0-35b-a3b` | `131k`, `262k`, `vision-131k`, `vision-262k` (sin MTP) |

- Tiel Coder y Cyber Tiel: los perfiles `131k`, `262k`, `vision-131k` y `vision-262k` usan el mismo GGUF
  con cabezal MTP y `MTP_ARGS` vacío (alias `<id sin mtp>-131k`, `-262k`, `-vision-131k` y
  `-vision-262k`); ninguna de las dos publicaciones incluye una versión sin MTP.
- Nail: nuevos `mtp-262k` (GGUF de `mtp\`, `UD-IQ4_XS`) y `vision-262k` (copia del de visión 131K).
- Occult Nail: nuevo `vision-262k`. No tiene MTP: su publicación no trae cabezal y no existe una
  publicación `-MTP`.
- **Retirado**: `tiel-coder-35b-a3b-mtp/start-agentic-auto-mtp-vision-131k-1024.cmd` (alias
  `tiel-coder-35b-a3b-mtp-vision-131k`), el único perfil de visión con MTP que existía. Su sustituto
  es `tiel-coder-35b-a3b-vision-131k`.

**Dónde**: `scripts/models/{tiel-coder-35b-a3b-mtp,cyber-tiel-coder-35b-a3b-mtp,nail-qwen3.6-35b-a3b,occult-nail-1.0-35b-a3b}/`,
las cuatro fichas de modelo, `AGENTS.md` (la regla de visión sin MTP y el nombre de los perfiles),
`README.md` y `handoff.md`.

## Validación

- Validación estática sin filtros (alias únicos, rutas del manifiesto y paridad con los catálogos de
  cliente).
- Los lanzadores nuevos no se han probado, por decisión del usuario; los de 262K con visión son los que
  más margen de VRAM necesitan.
