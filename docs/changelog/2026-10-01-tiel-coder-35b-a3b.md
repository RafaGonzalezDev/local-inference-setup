# 2026-10-01 - Añadir Tiel Coder 35B A3B sin MTP

**Qué**: Se incorpora `Tiel-Coder-35B-A3B-UD-Q4_K_XL.gguf` con un manifiesto
reproducible y tres lanzadores autocontenidos equivalentes a los de su variante
MTP, pero sin decodificación especulativa: 131k/2048, 262k/1024 y visión a
131k/2048.

**Dónde**: `models/tiel-coder-35b-a3b/SHA256SUMS`,
`config/models/tiel-coder-35b-a3b.psd1`, `scripts/models/tiel-coder-35b-a3b/`,
`config/catalog.psd1`, `README.md`, `docs/overview/model-management.md`,
`docs/overview/models/tiel-coder-35b-a3b.md` y
`docs/overview/models/tiel-coder-35b-a3b-mtp.md`.

**Por qué**: Es la escalera sin el cabezal `nextn` del mismo modelo, publicada
por el autor para runtimes que no hacen especulación MTP, y el par de control
natural para aislar el coste de `--spec-type draft-mtp` en este hardware. Ambos
artefactos solo se diferencian en el cabezal: la corrección que Ornith hizo sobre
él tocó únicamente los tensores MTP, con `lm_head` bit a bit idéntico.

## Estado

- El origen queda fijado en la revisión
  `a1ae34c609d9ef03827f373a215795f22545334c` de
  `peculiar-ragdoll/Tiel-Coder-35B-A3B-GGUF`.
- El artefacto principal son 22.360.478.080 bytes con SHA-256
  `9779b32f998371c66ae5e1aa9a0bc7ad946b1a36c61ea6a8eb39d523b4b19033`, 389.402.080
  bytes menos que el `UD-Q4_K_XL` de la variante MTP.
- El proyector `mmproj-BF16.gguf` es el mismo fichero que sirve la variante MTP
  (mismo SHA-256); se copió en lugar de volver a descargarlo y el instalador lo
  verificó contra tamaño y hash antes de aceptarlo.
- Los alias de perfil son `tiel-coder-35b-a3b-131k`,
  `tiel-coder-35b-a3b-262k` y `tiel-coder-35b-a3b-vision-131k`, detrás del alias
  primario `tiel-coder-35b-a3b`.
- Los tres dejan `MTP_ARGS` vacío. El repositorio publica además
  `mtp-Tiel-Coder-35B-A3B.gguf`, un borrador suelto de 1.493.665.664 bytes que su
  tarjeta no documenta y que no se declara ni se descarga.
- El runtime se mantiene en `b11269-cuda13.4` y la KV en `q8_0`.
- No se ha iniciado ningún servidor ni se ha ejecutado ninguna inferencia.

## Validación

- `Download-Model.ps1 -Model tiel-coder-35b-a3b` verificó tamaño y SHA-256 del
  GGUF antes de instalarlo, y aceptó el proyector copiado como artefacto ya
  verificado. La reejecución explícita de `Test-ModelIntegrity.ps1` queda
  pendiente: habría que releer 23 GB con un modelo local en marcha.
- `Test-Llm.ps1 -ConfigurationOnly -RequireInstalledFiles` pasa los 23
  lanzadores del catálogo, 3 de ellos nuevos.
- La prueba funcional de los tres perfiles y la comparación de rendimiento
  frente a la variante MTP quedan pendientes y las ejecuta el usuario.
