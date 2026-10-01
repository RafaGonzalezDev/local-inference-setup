# 2026-10-01 - Añadir Tiel Coder 35B A3B MTP

**Qué**: Se incorpora `Tiel-Coder-35B-A3B-MTP-UD-Q4_K_XL.gguf` con un manifiesto
reproducible y tres lanzadores autocontenidos que siguen el patrón de los
perfiles activos de `ornith-1.5-35b-a3b` y `qwen3.6-35b-a3b`: dos perfiles de
MTP (131k y 262k) y un perfil de MTP con visión.

**Dónde**: `models/tiel-coder-35b-a3b-mtp/SHA256SUMS`,
`config/models/tiel-coder-35b-a3b-mtp.psd1`,
`scripts/models/tiel-coder-35b-a3b-mtp/`, `config/catalog.psd1`, `README.md`,
`docs/overview/model-management.md` y
`docs/overview/models/tiel-coder-35b-a3b-mtp.md`.

**Por qué**: Es una recuantización dinámica de Ornith 1.5 35B A3B orientada a
coding agentic, cuya tarjeta recomienda el nivel `UD-Q4_K_XL` para equipos con
24–32 GB de RAM+VRAM combinadas. El repositorio elegido conserva el cabezal MTP
`nextn` del modelo base, así que los tres perfiles lo activan: sin
`--spec-type draft-mtp` llama.cpp ignora esos tensores y el archivo carga unos
0,4 GB de peso muerto.

## Estado

- El origen queda fijado en la revisión
  `bbe9e566f39e4fc9652ac66b71968289a03c520a` de
  `peculiar-ragdoll/Tiel-Coder-35B-A3B-GGUF-MTP`.
- El artefacto principal son 22.749.880.160 bytes con SHA-256
  `54f46c4ce544c225122b0f066c2336f10404be7bc53b0cc94d1dbbc5e826bdc1`; el
  proyector `mmproj-BF16.gguf` son 902.822.016 bytes con SHA-256
  `d9ce31026d1cb1f3f8d5152e2e2a014d9d2b302b6c93a7dc07bb0a0487f52837`.
- Los alias de perfil son `tiel-coder-35b-a3b-mtp-131k`,
  `tiel-coder-35b-a3b-mtp-262k` y `tiel-coder-35b-a3b-mtp-vision-131k`, todos
  detrás del alias primario `tiel-coder-35b-a3b-mtp`.
- El muestreo fija `temp 0.6`, `top-p 0.95`, `top-k 20` por coherencia con los
  perfiles agentic existentes. Es un valor adaptado, no una medición propia: la
  tarjeta del modelo recomienda 1.0 para uso general y 0.6 para coding agentic.
- El runtime se mantiene en `b11269-cuda13.4` y la KV en `q8_0`. El repositorio
  no pide ningún fork de llama.cpp y las palancas usadas (`--spec-type
  draft-mtp`, `--spec-draft-n-max`, `--mmproj`, `--image-min-tokens`, `--fit`)
  existen en esa compilación.
- No se ha iniciado ningún servidor ni se ha ejecutado ninguna inferencia.

## Validación

- `Test-ModelIntegrity.ps1 -Model tiel-coder-35b-a3b-mtp` informa `Passed` para
  los dos artefactos.
- `Test-Llm.ps1 -ConfigurationOnly` pasa los 20 lanzadores del catálogo, 3 de
  ellos nuevos.
- La prueba funcional de los tres perfiles queda pendiente y la ejecuta el
  usuario; el tramo de expertos que `--fit` descarga a la CPU en este hardware
  tampoco se ha medido todavía.
