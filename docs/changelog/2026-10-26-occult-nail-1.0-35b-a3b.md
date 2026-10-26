# 2026-10-26 - Añadir Occult Nail 1.0 35B A3B

**Qué**: Se incorpora `occult-nail-1.0-35b-a3b` con `UD-Q4_K_XL` y `mmproj-F16.gguf` de
`peculiar-ragdoll/Occult-Nail-1.0-35B-A3B-GGUF` (revisión `3fdd9b72fc54083a6c8959b259011366a0b1571b`), con
los perfiles `agentic-auto-131k-2048`, `agentic-auto-262k-1024` y `agentic-auto-vision-131k-2048`.

**Dónde**: `config/catalog.psd1`, `config/models/occult-nail-1.0-35b-a3b.psd1`,
`scripts/models/occult-nail-1.0-35b-a3b/`, `README.md` y `docs/overview/models/occult-nail-1.0-35b-a3b.md`.

**Por qué**: Es la variante abliterada de Nail, publicada por `peculiar-ragdoll`, con la misma
arquitectura `qwen35moe`. Reutiliza sin cambios los tres perfiles sin MTP de `qwen3.6-35b-a3b`, porque
la publicación no trae cabezal MTP ni recomienda muestreo.

## Validación

- Descarga verificada por tamaño y SHA-256; `Test-ModelIntegrity.ps1` pasa.
- `Test-Llm.ps1 -ConfigurationOnly -RequireInstalledFiles` pasa sin filtros.
- Una carga representativa por perfil (99.547 y 229.936 tokens), tool calling, imagen común y contrato
  de razonamiento; detalle en la ficha.
