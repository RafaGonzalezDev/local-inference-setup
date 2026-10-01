# 2026-10-01 - Alinear el nombre de los lanzadores con su contenido

**Qué**: Se renombran los tres lanzadores cuyo nombre declaraba un batch de
2.048 mientras el script materializaba 1.024:

- `qwen3.6-35b-a3b/start-agentic-auto-mtp-131k-2048.cmd` →
  `start-agentic-auto-mtp-131k-1024.cmd`
- `tiel-coder-35b-a3b-mtp/start-agentic-auto-mtp-131k-2048.cmd` →
  `start-agentic-auto-mtp-131k-1024.cmd`
- `tiel-coder-35b-a3b-mtp/start-agentic-auto-mtp-vision-131k-2048.cmd` →
  `start-agentic-auto-mtp-vision-131k-1024.cmd`

**Dónde**: `scripts/models/qwen3.6-35b-a3b/`,
`scripts/models/tiel-coder-35b-a3b-mtp/`, `README.md`,
`docs/overview/models/qwen3.6-35b-a3b.md`,
`docs/overview/models/tiel-coder-35b-a3b-mtp.md` y
`docs/changelog/2026-10-01-tiel-mtp-batch-alignment.md`.

**Por qué**: El nombre del perfil es el identificador con el que `Test-Llm.ps1`
selecciona, valida y reporta un lanzador, y el sufijo numérico declara el batch
que ese fichero materializa. Un nombre que dice 2.048 sobre un script que usa
1.024 obliga a abrir el fichero para saber qué se está ejecutando, que es
justamente lo que el diseño de lanzadores autocontenidos quiere evitar.

## Estado

- Auditoría de los 23 lanzadores: nombre frente a `--ctx-size` y
  `--batch-size` del propio script. Los tres renombrados eran los únicos
  desajustados; los otros 20 ya coincidían.
- Los dos lanzadores de `gemma-4-12b-v2` no materializan `--batch-size` y los
  seis de `gemma-4-26b-a4b` no codifican contexto ni batch en el nombre: usan
  nombres descriptivos (`text-auto`, `agentic-auto-vision`, ...), así que su
  nombre no declara ningún valor que pueda contradecir al script. No se
  renombran.
- Los alias de cliente no cambian, porque ninguno codifica el batch:
  `qwen3.6-35b-a3b-mtp-131k`, `tiel-coder-35b-a3b-mtp-131k` y
  `tiel-coder-35b-a3b-mtp-vision-131k` siguen siendo los mismos. Los catálogos
  de DSH, Pi y OpenCode, que referencian alias y no nombres de fichero, no se
  tocan.
- Los cambios de nombre no alteran ningún argumento de los scripts: el contenido
  de los tres ficheros es idéntico antes y después.

## Validación

- `Test-Llm.ps1 -ConfigurationOnly -RequireInstalledFiles` pasa los 23
  lanzadores con sus nombres nuevos.
- No se ha iniciado ningún servidor ni se ha ejecutado ninguna inferencia.
