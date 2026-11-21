# 2026-11-21 - Añadir Gemma 4 12B Uncensored Balanced

**Qué**: Alta de `gemma-4-12b-uncensored-balanced` (`HauhauCS/Gemma4-12B-QAT-Uncensored-HauhauCS-Balanced`,
`Q4_K_M`, revisión `ae8045ac2bd216293ca49a3065da2c942dde4b68`) con su proyector BF16 y su borrador MTP. Seis
perfiles: texto, MTP y visión a 131K y 262K. Alias
`gemma-4-12b-uncensored-balanced-{131k,262k,mtp-131k,mtp-262k,vision-131k,vision-262k}`. El catálogo pasa a 17
modelos y 52 perfiles.

**Por qué**: Petición del usuario: la variante sin censura de `gemma-4-12b-it-qat`, con los mismos perfiles.

**Decisiones**:

- Lanzadores copiados de `gemma-4-12b-it-qat`; solo cambian modelo, proyector, borrador, alias y muestreo.
- Muestreo de la tarjeta de HauhauCS (`0.6/0.9/64`, `min-p 0.05`, `repeat-penalty 1.1`) en lugar del estándar de
  Gemma 4, a elección del usuario.
- Se instala el borrador MTP de esta publicación, aunque su tamaño y hash difieren del de `gemma-4-12b-it-qat`.
- **Sin pruebas funcionales** por decisión del usuario: se asumen los resultados del modelo con censura.

## Resolución de imagen en Gemma 4 12B (ambas variantes)

El usuario pidió que el modelo vea las imágenes a la máxima resolución admitida (idealmente hasta 4096x4096).
El código de `b12359` muestra que:

- `gemma4uv` usa presupuestos de 70 a 1120 tokens por imagen (el rango de Gemma 4), con 48x48 px por token.
- La imagen requiere atención no causal y debe caber en un ubatch: con `--ubatch-size 1024` el servidor
  recortaba el máximo a 1024 tokens (aviso `cap image_max_tokens`), también en `gemma-4-12b-it-qat`.
- Leer 4096x4096 sin reducir pediría unos 7225 tokens, más de seis veces el máximo de Gemma 4: se descartó.

Los cuatro perfiles de visión de `gemma-4-12b-it-qat` y `gemma-4-12b-uncensored-balanced` pasan a
`--image-min-tokens 1120 --image-max-tokens 1120` y batch/ubatch 2048, y se renombran de `-vision-*-1024` a
`-vision-*-2048`. Los alias de perfil no cambian. Una imagen de 4096x4096 se lee a 1584x1584; las pequeñas se
amplían al mismo presupuesto. Sin probar: memoria con el ubatch mayor y efecto en la calidad.

**Dónde**: `config/catalog.psd1`, `config/models/gemma-4-12b-uncensored-balanced.psd1`,
`scripts/models/gemma-4-12b-uncensored-balanced/`, `scripts/models/gemma-4-12b-it-qat/start-agentic-auto-vision-*`,
`README.md`, `AGENTS.md`, `handoff.md` y `docs/overview/models/{gemma-4-12b-uncensored-balanced,gemma-4-12b-it-qat}.md`.

## Validación

- Descarga verificada por tamaño y SHA-256; `Test-ModelIntegrity.ps1` (3/3) y `Test-Llm.ps1 -ConfigurationOnly
  -RequireInstalledFiles` sin filtros (52/52).
- No se arrancó ningún perfil: smoke, memoria, razonamiento, tool calling, visión y MTP quedan pendientes.
