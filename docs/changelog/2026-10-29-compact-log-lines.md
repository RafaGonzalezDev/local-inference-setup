# 2026-10-29 - Líneas de log más cortas en los lanzadores

**Qué**: los 16 lanzadores añaden `--no-log-timestamps --no-log-prefix` a `RUNTIME_ARGS`, junto a
`--log-verbosity 3`. No cambian nombres, alias, contexto, visión ni razonamiento, así que los
catálogos de cliente no cambian.

**Por qué**: a petición del usuario, las líneas obligaban a ensanchar la terminal. Los flags quitan la
marca de tiempo y la letra de nivel del principio de cada línea (unos 15 caracteres); el contenido no
cambia y `slot print_timing:` se conserva porque forma parte del mensaje:

```text
antes:  0.21.116.186 I slot print_timing: id  0 | task 0 | prompt eval time = ...
ahora:  slot print_timing: id  0 | task 0 | prompt eval time = ...
```

Sin la letra de nivel, avisos y errores solo se distinguen por el color (`--log-colors auto`, activo
en terminal). `b11551` no tiene opción para ocultar solo las líneas de progreso del prefill; condensar
más exigiría filtrar la salida, que choca con [ADR-0001](../adr/ADR-0001-self-contained-model-launchers.md).

**Dónde**: `scripts/models/*/start-*.cmd` y la base agentic de `AGENTS.md`.

**Validación**: arranque de prueba con los flags (salida comprobada), `Test-Llm.ps1 -ConfigurationOnly
-RequireInstalledFiles` 16/16 y smoke de `tiel-coder-35b-a3b` `agentic-auto-131k-1024`.
