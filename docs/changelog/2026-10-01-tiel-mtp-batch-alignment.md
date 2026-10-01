# 2026-10-01 - Alinear los perfiles MTP de Tiel Coder con el de Qwen

**Qué**: Los tres perfiles de `tiel-coder-35b-a3b-mtp` pasan a usar la misma
configuración de decodificación especulativa que el perfil MTP de
`qwen3.6-35b-a3b`: `--spec-draft-n-max 3` y batch/ubatch 1.024/1.024. Los dos
perfiles de 131k bajan de 2.048/2.048; el de 262k ya estaba en 1.024/1.024.

**Dónde**: `scripts/models/tiel-coder-35b-a3b-mtp/start-agentic-auto-mtp-131k-1024.cmd`,
`scripts/models/tiel-coder-35b-a3b-mtp/start-agentic-auto-mtp-vision-131k-1024.cmd`
y `docs/overview/models/tiel-coder-35b-a3b-mtp.md`.

**Por qué**: `--ubatch-size` fija el tamaño de los búferes de cómputo, que
compiten con los pesos por el mismo margen de `--fit-target`. Con 2.048 el
reparto automático tenía que descargar más expertos a la CPU que con 1.024, y
ese tramo se paga en cada token generado. Los perfiles sin MTP mantienen
2.048/2.048 porque no pagan una pasada de verificación por paso. Los nombres de
fichero declaraban todavía el `2048` heredado; se corrigieron el mismo día, en la
entrada de alineación de nombres.

## Estado

- Los seis perfiles con decodificación especulativa del catálogo quedan con
  `n-max`, batch y ubatch alineados salvo los dos de `gemma-4-26b-a4b`, que
  conservan `n-max 4` y su ubatch propio porque en ese modelo el ubatch es una
  elección del modelo y no del MTP: su perfil sin MTP usa el mismo valor.
- No cambian el contexto, el muestreo, el alias, el puerto ni el runtime de
  ningún perfil.
- No se ha iniciado ningún servidor ni se ha ejecutado ninguna inferencia.

## Validación

- `Test-Llm.ps1 -ConfigurationOnly -RequireInstalledFiles` pasa los 23
  lanzadores.
- La comparación de rendimiento entre 1.024 y 2.048 y entre las variantes con y
  sin MTP queda pendiente y la ejecuta el usuario.
