# 2026-11-17 - Gemma 4 26B A4B QAT sustituye a la versión HauhauCS y entra Gemma 4 E4B QAT

**Qué**:

- `gemma-4-26b-a4b-it-qat`: `gemma-4-26B-A4B-it-qat-UD-Q4_K_XL.gguf` de `unsloth/gemma-4-26B-A4B-it-qat-GGUF`
  (revisión `7b92b5b28818151e8669af2e45e88d6086f490dd`) con `mmproj-BF16.gguf`. Cuatro perfiles sin MTP:
  texto y visión a 131K y 262K. Alias `gemma-4-26b-a4b-it-qat-{131k,262k,vision-131k,vision-262k}`.
- Se retira del catálogo principal `gemma-4-26b-a4b-uncensored-balanced` (HauhauCS): lanzadores, manifiesto
  `config/models/` y sus cuatro alias. Sus pesos siguen en `models\` (ver «Decisiones»).
- `gemma-4-e4b-it-qat`: `gemma-4-E4B_q4_0-it.gguf` de `google/gemma-4-E4B-it-qat-q4_0-gguf` (revisión
  `4b4a2c1d584be7264f87aac328a1bc739ce81b6c`) con `gemma-4-E4B-it-mmproj.gguf` (visión y audio). Dos perfiles
  al contexto nativo: texto y visión a 131K. Alias `gemma-4-e4b-it-qat-{131k,vision-131k}`.
- La ficha de `gemma-4-12b-it-qat` recoge los tipos reales de su GGUF (Q4_0 pese al nombre `UD-Q4_K_XL`).

El catálogo pasa a 16 modelos y 46 perfiles.

**Por qué**: Petición del usuario. Prefiere el Gemma 26B oficial, con rechazos, porque probablemente use mejor las
herramientas y ya tiene otros modelos sin censura. Además quería un E4B en los catálogos.

**Decisiones**:

- 26B: el usuario pidió no ejecutar los lanzadores, porque espera resultados parecidos a los de la versión anterior
  (misma arquitectura y pesos QAT de origen). Solo se verificaron integridad y configuración estática.
- El MTP sigue desactivado en ambos modelos, como en el resto del catálogo salvo el 12B. No se instala el borrador del
  26B; la publicación del E4B no tiene borrador.
- Muestreo estándar de Gemma 4 (`1.0/0.95/64`) en ambos, en lugar del de HauhauCS.
- El perfil del E4B que carga el proyector usa `-vision`, como el 12B, aunque también acepta audio: `-audio` y
  `-omni` quedan para LFM3.
- No se crea un perfil de 262K del E4B: su contexto nativo es 131.072.
- Los pesos de HauhauCS (18 GB) se conservan: el manifiesto y el lanzador CPU de `experimental/` los siguen
  referenciando, aunque ya no los usa nada (el Prompt writer de ComfyUI pasó a Occult Nail). Borrarlos dejaría
  esa raíz inválida; queda pendiente de que el usuario decida si se eliminan junto con esa parte de `experimental/`.

**Dónde**: `config/catalog.psd1`, `config/models/{gemma-4-26b-a4b-it-qat,gemma-4-e4b-it-qat}.psd1`,
`scripts/models/{gemma-4-26b-a4b-it-qat,gemma-4-e4b-it-qat}/`, `logs/validation/calibration-gemma-4-e4b-it-qat-20261117/`
(script de calibración, no espejado), `README.md`, `handoff.md` y
`docs/overview/models/{gemma-4-26b-a4b-it-qat,gemma-4-e4b-it-qat,gemma-4-12b-it-qat,gemma-4-26b-a4b-uncensored-balanced}.md`.
Se eliminaron `config/models/gemma-4-26b-a4b-uncensored-balanced.psd1` y
`scripts/models/gemma-4-26b-a4b-uncensored-balanced/`.

## Validación

- `Test-ModelIntegrity.ps1` pasa en ambos modelos (2/2 cada uno); `Test-Llm.ps1 -ConfigurationOnly
  -RequireInstalledFiles` sin filtros: 46/46.
- E4B: smoke de los dos perfiles y calibración bajo carga con un prompt de 54K tokens: VRAM pico de 6,8 GB (texto) y
  8,2 GB (visión) sobre 16,3 GB, prefill de unos 11.800 tok/s, generación de unos 155 tok/s, caché de prompt
  reutilizada, tool calling, contrato de razonamiento, visión y audio. Detalle en la ficha.
- 26B: sin pruebas funcionales (petición del usuario).
