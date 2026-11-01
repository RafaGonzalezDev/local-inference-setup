# 2026-11-01 - LFM3 en el catálogo principal

**Qué**: `lfm3-1.7b` sale de `experimental/lfm3` y entra en el catálogo principal. Vuelven también
`lfm3-vl-2b`, `lfm3-audio-2b` y `lfm3-omni-2b`, retirados el 2026-10-29. Cada uno tiene un perfil:
`lfm3-1.7b-262k`, `lfm3-vl-2b-vision-128k`, `lfm3-audio-2b-audio-32k` y `lfm3-omni-2b-omni-32k`. El
catálogo queda en 11 modelos y 26 perfiles. Pi, OpenCode y DSH (repositorios, DSH global y WSL)
registran todos los alias salvo el de Audio.

**Por qué**: desde el 2026-10-30 el catálogo principal usa el mismo `b11981-cuda13.4`. La copia de
`experimental/lfm3` era idéntica byte a byte (mismo SHA-256 de binarios y paquetes), así que el
aislamiento ya no aportaba nada. El usuario eligió traer de vuelta toda la familia, con la revisión más
reciente de Audio y Omni. Los clientes registran solo los alias que pueden usar: ninguno envía ni
reproduce audio, así que Audio queda fuera.

**Dónde**: `config/catalog.psd1`, `config/models/lfm3-*.psd1`, `scripts/models/lfm3-*/`,
`docs/overview/models/lfm3-*.md`, `README.md`, `AGENTS.md`, `handoff.md`,
`docs/overview/inference-backend.md`. Pesos en `models/lfm3-*`. Los logs de validación y las muestras de
audio de `experimental/lfm3` se copiaron a `logs/validation/experimental-lfm3/`.

## Decisiones

- Los lanzadores son los validados el 2026-10-29, con la ruta de la raíz principal. Se conservan los
  sufijos `-audio` y `-omni`, que `AGENTS.md` ahora documenta.
- VL y Omni no tienen perfiles de 131K y 262K porque su contexto nativo es menor (128.000 y 32K).
- Audio y Omni: misma revisión de pesos que el 2026-10-29 (mismo SHA-256), pero el proyector nuevo
  cuantiza el decodificador del códec. La PR #31386, que lo permite al cuantizar, es posterior a `b11981`.
  Aun así, `b11981` carga los proyectores nuevos y genera voz con ellos.
- Omni mantiene `--reasoning off`, como pide su tarjeta; en los clientes es un modelo sin razonamiento.

## Validación

- Descarga verificada por tamaño y SHA-256; `Test-ModelIntegrity.ps1`: 18/18 artefactos.
- `Test-Llm.ps1 -ConfigurationOnly -RequireInstalledFiles` sin filtros: 26/26. Smoke de los cuatro perfiles.
- Pruebas funcionales (`logs/validation/functional-lfm3-*-20261101-*.json`): contexto y alias en
  `/props` y `/v1/models`; tool calling en 1.7B y Omni; descripción de imagen en VL y Omni; TTS en
  español y ASR ida y vuelta en Audio y Omni; contrato de razonamiento de VL. VRAM pico entre 5.363 y
  6.764 MiB.
- Sin probar: vídeo, `/v1/realtime` con los proyectores nuevos, prompts largos y sesiones reales de los
  clientes.

## Limpieza

- `experimental/` (runtime y paquetes idénticos a los principales, logs ya copiados) se borró el mismo
  día a petición del usuario.
