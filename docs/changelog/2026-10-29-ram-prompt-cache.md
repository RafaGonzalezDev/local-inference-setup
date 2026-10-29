# 2026-10-29 - Caché de prompts en RAM en los lanzadores

**Qué**: los 16 lanzadores pasan de `--cache-ram 0` a `--cache-ram 8192`, el valor por defecto de
llama.cpp. Con ella se activa también `--cache-idle-slots` (por defecto en `b11551`), que ya no avisa
de que se desactiva. No cambian nombres, alias, contexto, visión ni razonamiento, así que los
catálogos de cliente no cambian.

**Por qué**: decisión del usuario. Con `--parallel 1` el único slot guarda solo la última petición, y
sin caché en RAM cualquier petición intermedia (título de sesión, subagentes de `orchestrated`, otra
sesión) obligaba a reprocesar la conversación entera al volver a ella. La caché guarda esa
conversación en RAM y la restaura. No cambia la velocidad de prefill ni de generación; ocupa hasta
8 GiB de RAM, y las calibraciones dejan 35-40 GiB libres. No se conoce el motivo del `0` anterior; no
estaba documentado.

**Dónde**: `scripts/models/*/start-*.cmd` y la base agentic de `AGENTS.md`.

**Validación**:

- `Test-Llm.ps1 -ConfigurationOnly -RequireInstalledFiles` sin filtros: 16/16.
- `cyber-tiel-coder-35b-a3b` `agentic-auto-131k-1024`, con la arquitectura híbrida `qwen35moe`:

| Paso | Tokens procesados | Recuperados de caché | Prefill |
| --- | ---: | ---: | ---: |
| Conversación A en frío | 20.961 | 0 | 10,3 s |
| Conversación B, distinta, ocupa el slot | 19 | 179 | 0,16 s |
| Vuelta a A con un mensaje más | 20 | 20.992 | 0,18 s |

**Pendiente**: no se midió el comportamiento con la caché llena (expulsión de contextos antiguos) ni
con contextos de más de ~21K tokens. Una prueba de `orchestrated` con y sin caché se interrumpió por
decisión del usuario; sus restos quedan en `~/workspace/bench/` de WSL.
