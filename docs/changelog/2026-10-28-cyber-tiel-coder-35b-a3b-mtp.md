# 2026-10-28 - Añadir Cyber Tiel Coder 35B A3B MTP

**Qué**: se incorpora `cyber-tiel-coder-35b-a3b-mtp` con `UD-Q4_K_S` y `mmproj-BF16.gguf` de
`peculiar-ragdoll/Cyber-Tiel-Coder-35B-A3B-GGUF-MTP` (revisión `b62212407346cb7aafcc8d2788a1844555002fd3`),
con los perfiles MTP `agentic-auto-mtp-131k-1024` y `agentic-auto-mtp-262k-1024` y los sin MTP
`agentic-auto-131k-1024`, `agentic-auto-262k-1024`, `agentic-auto-vision-131k-1024` y
`agentic-auto-vision-262k-1024`, todos con batch/ubatch 1.024/1.024. Los de visión no llevan MTP.

**Dónde**: `config/catalog.psd1`, `config/models/cyber-tiel-coder-35b-a3b-mtp.psd1`,
`scripts/models/cyber-tiel-coder-35b-a3b-mtp/`, `README.md`, `handoff.md` y
`docs/overview/models/cyber-tiel-coder-35b-a3b-mtp.md`.

**Por qué**: es la variante abliterada y cyber de Tiel Coder, del mismo publicador y la misma
arquitectura `qwen35moe`. A petición del usuario, los lanzadores son copias exactas de los de
`tiel-coder-35b-a3b-mtp`, cambiando solo el modelo, el proyector y los alias, y no se prueban.

## Validación

- Descarga verificada por tamaño y SHA-256; `Test-ModelIntegrity.ps1` pasa.
- `Test-Llm.ps1 -ConfigurationOnly -RequireInstalledFiles` sin filtros pasa con los 22 perfiles.
- Sin pruebas funcionales ni calibración de memoria, por decisión del usuario; la ficha detalla qué
  queda sin verificar, sobre todo el margen de VRAM de un GGUF de 21,3 GB.
- Clientes: DSH, OpenCode, Pi y los clientes de WSL listan los seis alias de perfil, copiados de las
  entradas de Tiel Coder.
