# 2026-10-28 - UD-Q4_K_XL sin MTP en todo el catálogo

**Qué**:

- Tiel Coder, Cyber Tiel y Nail pasan a su `UD-Q4_K_XL` sin cabezal MTP; Occult Nail ya lo usaba.
- Se retiran los 6 perfiles MTP (`*-mtp-131k` y `*-mtp-262k` de los tres). El catálogo queda en 4
  modelos y 16 perfiles.
- `tiel-coder-35b-a3b-mtp` y `cyber-tiel-coder-35b-a3b-mtp` se renombran a `tiel-coder-35b-a3b` y
  `cyber-tiel-coder-35b-a3b` (manifiesto, carpetas, catálogo, ficha y alias canónico). Los alias de
  perfil sin MTP no cambian.

**Por qué**: decisión del usuario. Con expertos en CPU, MTP aceptaba pocos borradores en prosa y
razonamiento y acababa más lento que sin MTP; además los perfiles sin MTP no aprovechaban la memoria
del cabezal. `UD-Q4_K_XL` es la cuantización que las tarjetas recomiendan, y Occult Nail ya mostraba
que su peso extra apenas cuesta velocidad a 131K.

**Dónde**:

- `config/catalog.psd1` y `config/models/{tiel-coder-35b-a3b,cyber-tiel-coder-35b-a3b,nail-qwen3.6-35b-a3b}.psd1`.
- `scripts/models/{tiel-coder-35b-a3b,cyber-tiel-coder-35b-a3b}/` (nuevos) y
  `scripts/models/nail-qwen3.6-35b-a3b/`.
- `README.md`, `AGENTS.md` (tabla de referencias y regla de MTP), `handoff.md` y las fichas de
  `docs/overview/models/`.
- Clientes: DSH (repositorio y configuración global), los cinco `opencode.json`, Pi y los clientes
  activos de WSL pierden los 6 alias MTP y actualizan los nombres de cuantización.

## Artefactos

| Modelo | Repositorio | Revisión | Archivo | Tamaño | SHA-256 |
| --- | --- | --- | --- | ---: | --- |
| Tiel Coder | `peculiar-ragdoll/Tiel-Coder-35B-A3B-GGUF` | `dd9b8f8be29bd939afe0fb5c712f09ed1ff87bb6` | `Tiel-Coder-35B-A3B-UD-Q4_K_XL.gguf` | 22.360.478.080 | `9779b32f998371c66ae5e1aa9a0bc7ad946b1a36c61ea6a8eb39d523b4b19033` |
| Cyber Tiel | `peculiar-ragdoll/Cyber-Tiel-Coder-35B-A3B-GGUF` | `e59f05c5bda27883c2846bd6163acba3f5e00a8e` | `Cyber-Tiel-Coder-35B-A3B-UD-Q4_K_XL.gguf` | 22.360.478.720 | `21bff5a96fa051809f4a8260befe977771c9927cae9c32eadfcb0718bae960cd` |
| Nail | `peculiar-ragdoll/Nail-Qwen3.6-35B-A3B-GGUF` | `ac66b0fad4bc2b68d29eff967c06d55de09429c1` | `Nail-Qwen3.6-35B-A3B-UD-Q4_K_XL.gguf` | 22.360.465.312 | `a9db25750e5b253922a6f780b5e6e7852013d2f85fad589270fbc8c314d2c9b1` |

SHA-256 LFS de la API de Hugging Face, verificados tras la descarga. Los proyectores no cambian: el
`mmproj-BF16.gguf` de Ornith tiene el mismo SHA-256 en los repositorios con y sin MTP y se copió desde
la instalación anterior.

Se eliminaron, tras validar los nuevos, `Nail-Qwen3.6-35B-A3B-UD-Q4_K_S.gguf`,
`mtp/Nail-Qwen3.6-35B-A3B-MTP-UD-IQ4_XS.gguf`, `models/tiel-coder-35b-a3b-mtp/` y
`models/cyber-tiel-coder-35b-a3b-mtp/` (unos 79 GB). Sus manifiestos siguen en el historial git de
`local-inference-setup`.

## Validación

- `Test-ModelIntegrity.ps1` en los tres modelos y `Test-Llm.ps1 -ConfigurationOnly
  -RequireInstalledFiles` sin filtros: 16/16.
- Calibración bajo carga de los 12 perfiles nuevos, una ejecución cada uno y en serie: carga, prompt de
  ~99K (131K) o ~230K (262K) tokens, decode largo y corto, tool calling y, en visión,
  `panels-1080p.png`. Todos pasan, con VRAM pico de 14,5–15,4 GB de 16,3 GB. Los resultados están en
  cada ficha y en `logs/validation/calibration-*-20261028-23*`.
- Referencia en la misma serie: Occult Nail 131K, sin cambios de pesos. Su prefill (1.957 t/s) es igual
  con 6 y 8 hilos, así que la diferencia con calibraciones anteriores viene del prompt y no del cambio
  de hilos.

**Pendiente**: comprobar con estos GGUF `reasoning_effort: "none"` y `thinking_budget_tokens`; el
contexto completo y un prompt largo con imagen siguen sin probarse.
