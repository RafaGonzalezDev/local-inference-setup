# 2026-10-22 - Razonamiento en modo auto

**Qué**: Los 31 lanzadores pasan de `--reasoning on` a `--reasoning auto`. Swift
conserva `--reasoning-effort xhigh` y todos los perfiles mantienen su
`--reasoning-budget`.

**Dónde**: los 31 `scripts/models/**/start-*.cmd`,
`docs/overview/adding-a-model.md`, `docs/overview/inference-backend.md`
(sección Reasoning), `AGENTS.md` y las tarjetas de modelo que citaban el flag.

**Por qué**: con `--reasoning on`, el servidor añade `enable_thinking=true` a los
argumentos de plantilla por defecto y ese valor sobrescribe el
`enable_thinking=false` que produce `reasoning_effort: "none"`. Ningún cliente
compatible con OpenAI podía desactivar el razonamiento con ese campo. Medido en
`ornith-1.5-9b/agentic-auto-262k-1024` con build `11551`: con `on`, la petición
sin campo y las peticiones con `none`, `low` y `high` dieron la misma salida
(132 caracteres de razonamiento, 103 tokens); con `auto`, `none` produce 0
caracteres de razonamiento y 73 tokens, igual que
`chat_template_kwargs.enable_thinking: false`.

## Estado

- Sin campos de razonamiento en la petición, el comportamiento no cambia: la
  plantilla abre el bloque de razonamiento.
- `reasoning_effort: "none"` (Chat Completions) y `reasoning.effort: "none"`
  (Responses) desactivan el razonamiento; `enable_thinking: false` y
  `thinking_budget_tokens` siguen funcionando como antes.
- Sin cambios: Anthropic `thinking: {"type": "disabled"}` no lo desactiva, los
  niveles `low`/`medium`/`high` solo tienen efecto en Tiel y Swift, y LFM2.5
  siempre razona.
- Revertir es editar la línea `REASONING_ARGS` de cada lanzador.

## Validación

- `Test-Llm.ps1 -ConfigurationOnly -RequireInstalledFiles` sin filtros: 31
  perfiles, 0 fallos.
- Un perfil por modelo (12) arrancado con `auto` y comprobado con
  `/apply-template`: sin campos, las 12 plantillas abren el razonamiento (Gemma
  con `<|think|>` en el sistema). Con `reasoning_effort: "none"` o
  `enable_thinking: false`, 11 lo cierran vacío; LFM2.5 lo mantiene abierto,
  como su plantilla dicta. `/props` indica `supports_reasoning_effort` solo en
  Swift, Tiel y Tiel MTP.
- No se ejecutaron smokes de generación por perfil ni pruebas de calidad; la
  comparación de tokens se midió solo en Ornith 1.5 9B, con una muestra por caso.
