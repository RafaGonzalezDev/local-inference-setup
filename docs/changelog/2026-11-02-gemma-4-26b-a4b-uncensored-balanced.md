# 2026-11-02 - Añadir Gemma 4 26B A4B Uncensored Balanced

**Qué**: Alta de `gemma-4-26b-a4b-uncensored-balanced`
(`HauhauCS/Gemma4-26B-A4B-QAT-Uncensored-HauhauCS-Balanced-MTP`, `Q4_K_M`, revisión
`f9093662a2e7ae0503f637088bc96f77a1a70c83`) con cuatro perfiles: texto y visión a 131K y 262K (alias
`gemma-4-26b-a4b-uncensored-balanced-{131k,262k,vision-131k,vision-262k}`). El catálogo queda en 12
modelos y 30 perfiles. Pi, OpenCode y DSH (repositorios, DSH global y WSL) registran los cuatro alias.

**Dónde**: `config/catalog.psd1`, `config/models/gemma-4-26b-a4b-uncensored-balanced.psd1`,
`scripts/models/gemma-4-26b-a4b-uncensored-balanced/`, `README.md`, `handoff.md` y
`docs/overview/models/gemma-4-26b-a4b-uncensored-balanced.md`.

**Por qué**: Lo pidió el usuario. Su primera elección, `UD-Q4_K_L` de
`unsloth/gemma-4-26B-A4B-it-qat-GGUF`, no existe; eligió en su lugar esta variante sin rechazos, que solo
se publica en `Q4_K_M`. La arquitectura `gemma4` ya funcionaba en el catálogo con Gemma 4 26B (retirado el
2026-10-26). El borrador MTP es un archivo aparte y no se instala: el GGUF principal no tiene cabezal, así
que basta con dejar `MTP_ARGS` vacío.

## Decisiones

- Muestreo de la tarjeta para esta compilación: `--temp 0.6 --top-p 0.9 --top-k 64 --min-p 0.05
  --repeat-penalty 1.1`.
- `--reasoning auto` con presupuesto 8192: la plantilla razona por defecto y lee `enable_thinking`. Los
  clientes usan el mismo contrato que Occult Nail (`off` y presupuestos 2048/6144/12288).
- Proyector BF16, el único que ofrece la publicación.

## Validación

- Descarga verificada por tamaño y SHA-256; `Test-ModelIntegrity.ps1` 2/2;
  `Test-Llm.ps1 -ConfigurationOnly -RequireInstalledFiles` 30/30; smoke en los cuatro perfiles.
- Calibración con un prompt de 56.147 tokens: VRAM pico entre 15.082 y 15.527 MiB; prefill de
  2.141–2.702 tok/s y generación de 43–58 tok/s a esa longitud.
- Tool calling, contrato de razonamiento y descripción de imagen correctos. Detalle en la ficha.
- Sin probar: contexto completo, vídeo, calidad y sesiones reales de los clientes.
