# 2026-11-25 - Baja de Ternary Bonsai 2.5 27B y del fork de PrismML

**Qué**: Se eliminan `ternary-bonsai-2.5-27b` (pesos `PTQ1_0` con y sin MTP y proyector BF16, manifiesto,
lanzadores de texto, MTP y visión a 131K, ficha y changelog de alta) y el runtime `prism-b12178-cuda13.3` con
sus paquetes. `Install-LlamaRuntime.ps1` vuelve a aceptar solo las releases oficiales. Los alias
`ternary-bonsai-2.5-27b-{131k,mtp-131k,vision-131k}` salen de Pi, OpenCode y DSH.

**Por qué**: Decisión del usuario el mismo día del alta: las respuestas eran de baja calidad, sobre todo en
español. El rendimiento medido había sido bueno (77 tok/s sin MTP y 124 tok/s con MTP a 43K de contexto, todo
en la GPU), pero no compensó la calidad. El fork solo lo usaba este modelo.

**Dónde**: `config/catalog.psd1`, `scripts/setup/Install-LlamaRuntime.ps1`, `README.md`, `AGENTS.md` y
`handoff.md`; el historial queda en el git de `local-inference-setup`.
