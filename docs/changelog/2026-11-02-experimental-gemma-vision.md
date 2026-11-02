# 2026-11-02 - `experimental`: Gemma con visión en CPU a 16K

**Qué**: el perfil CPU de `gemma-4-26b-a4b-uncensored-balanced` en `experimental` pasa de
`agentic-cpu-8k-1024` (solo texto) a `agentic-cpu-vision-16k-2048` (alias
`gemma-4-26b-a4b-uncensored-balanced-cpu-vision-16k`), con el proyector BF16 del catálogo principal.
`instructions/qwen-image-2.1.md` gana la sección *Attached images*.

**Por qué**: el nodo *Prompt writer* de ComfyUI (`D:\AI`) envía ahora las imágenes del flujo, etiquetadas
`<image1>`, `<image2>`… igual que el encoder de Qwen Image, para que el prompt se base en lo que hay en
ellas. El usuario pidió 16K y que el modelo no pierda detalle al ver la imagen.

**Dónde**: `experimental/config/models/gemma-4-26b-a4b-uncensored-balanced.psd1` (declara el proyector),
`experimental/scripts/models/gemma-4-26b-a4b-uncensored-balanced/start-agentic-cpu-vision-16k-2048.cmd`,
`experimental/Start-Assistant.ps1`, `experimental/instructions/qwen-image-2.1.md` y
`experimental/README.md`.

## Decisiones

- `--no-mmproj-offload`: sin él, el proyector se carga en la GPU aunque el modelo use `--device none`.
- `--image-min-tokens 1120 --image-max-tokens 1120`: el máximo del modelo; forzar 2.240 no da más.
- Batch/ubatch 2048: con 1024 el runtime avisa de que recorta el presupuesto a 1.024 porque la atención
  de la imagen no es causal y debe caber en un micro-lote.
- 16.384 de contexto: unos 4.000 tokens de instrucciones, hasta cinco imágenes de 1.120 y la respuesta.

## Validación

- `Test-ModelIntegrity.ps1 -RootDirectory` 2/2 y `Test-Llm.ps1 -ConfigurationOnly -RequireInstalledFiles
  -RootDirectory` 1/1.
- Mediciones en CPU y desde ComfyUI: ver [experimental/README.md](../../experimental/README.md#validación-2026-11-02)
  y el changelog de `D:\AI` (`docs/changelog/2026-11-02-prompt-writer-vision.md`).
