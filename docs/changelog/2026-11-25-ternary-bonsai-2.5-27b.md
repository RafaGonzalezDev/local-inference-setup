# 2026-11-25 - Ternary Bonsai 2.5 27B sobre el fork de PrismML

**Qué**: Alta de `ternary-bonsai-2.5-27b`: `PTQ1_0` de `prism-ml/Ternary-Bonsai-2.5-27B-GGUF` (revisión
`28a7093cc25bc151cc2b284c5570f12ce343fdcf`), con y sin el cabezal MTP integrado y con el proyector BF16. Tres
perfiles a 131K: texto, MTP y visión. Alias `ternary-bonsai-2.5-27b-{131k,mtp-131k,vision-131k}`.

Nuevo runtime `prism-b12178-cuda13.3` (release binaria `prism-b12178-03ec600` del fork
`PrismML-Eng/llama.cpp`), usado solo por este modelo. `Install-LlamaRuntime.ps1` acepta
`-Version prism-b12178` y descarga desde el repositorio y la etiqueta del fork.

**Por qué**: Petición del usuario. Los tres empaquetados publicados (`PTQ1_0`, `PQ2_0`, `Q2_0`) son el mismo
modelo ternario, así que la precisión no decide; `Q2_0` funcionaría en `b12359`, pero el usuario aprobó el fork
por velocidad, MTP y visión. Con el fork, `PTQ1_0` es el más pequeño y el más rápido en NVIDIA.

**Decisiones**:

- Sin perfiles de 262K: con KV `q8_0` el modelo entero necesita 15.110 MiB frente a unos 15.000 libres, `--fit`
  deja 8 capas en CPU y la generación cae a 10 tok/s.
- MTP con la receta del preset CUDA del autor para Blackwell (`--spec-draft-n-min 0 --spec-draft-n-max 3
  --spec-draft-p-min 0.1`). Medido 1,3–1,6 veces más rápido que sin MTP; el perfil sin MTP usa el GGUF sin
  cabezal.
- Presupuesto de razonamiento 8192, como el resto del catálogo, aunque la plantilla razona en `xhigh` por
  defecto.

**Dónde**: `config/catalog.psd1`, `config/models/ternary-bonsai-2.5-27b.psd1`,
`scripts/models/ternary-bonsai-2.5-27b/`, `scripts/setup/Install-LlamaRuntime.ps1`, `README.md`, `AGENTS.md`
y `docs/overview/models/ternary-bonsai-2.5-27b.md`.

## Validación

- `Test-ModelIntegrity.ps1`: 3/3. `Test-Llm.ps1 -ConfigurationOnly` sin filtros: todos los perfiles pasan.
  Smoke de los tres perfiles: pasa.
- Calibración con un prompt de 43.652 tokens, tool calling, contrato de razonamiento y visión; cifras en la ficha.
  Medido con una videollamada con cámara activa.
