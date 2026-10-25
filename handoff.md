# Handoff

Sesión del 2026-10-25: alta de `nemotron-3.5-bolt-e4b` en `D:\LLM` y su propagación a los clientes y al
espejo público. Este documento fija el **procedimiento que debe repetirse cada vez que se añade un modelo**;
el detalle técnico del modelo está en su ficha y changelog (ver rutas abajo).

## Next session focus

Cuando se incorpore un modelo nuevo a `D:\LLM` (siguiendo [AGENTS.md](AGENTS.md)), completar además estos
pasos, en este orden, sin pedirlos de nuevo:

1. **D:\LLM**: manifiesto, catálogo, lanzadores, descarga, integridad, `Test-Llm.ps1` estático sin filtros,
   calibración y smoke, README, ficha y changelog (todo según AGENTS.md).
2. **Verificar el contrato de razonamiento del cliente** con el perfil arrancado: que
   `chat_template_kwargs.enable_thinking: false` deja `reasoning_content` vacío y que
   `thinking_budget_tokens` corta el razonamiento. Si la plantilla usa `reasoning_effort` (Tiel, Swift) o
   siempre razona (LFM2.5, Flint), usar la receta alternativa de cada cliente.
3. **Registrar un ID por alias de perfil** (el segundo `--alias` del lanzador, p. ej.
   `nemotron-3.5-bolt-e4b-65k`) en los tres dotfiles. `input`/`modalities` con imagen solo en perfiles de
   visión. Límite de salida: 16.384 a 65K, 24.576 a 131K, 32.768 (pi, dsh) / 32.000 (opencode) a 262K,
   salvo que la tarjeta pida más.
4. **Commit convencional por repositorio** (skill `conventional-commit`), push a `origin main` y mostrar
   al usuario la URL de cada remoto.
5. **Espejar D:\LLM en `local-inference-setup`** (incluido este `handoff.md`), commit y push.

## Dónde se registra cada modelo

| Repositorio | Archivos | Patrón a copiar |
| --- | --- | --- |
| `C:\Users\rafat\Desktop\Code\dotfiles-dsh` | `config/profiles/desktop/cordis.patch.yml` (ruta `llm-pi-ai` → `providers.llama-cpp.models`) | Entrada YAML con `id`, `name` (`<Familia> Local · <ctx>`), `contextWindow`, `maxTokens`, `input`, `reasoningEfforts`; reglas en `skills/dsh-model-catalog/SKILL.md` |
| `C:\Users\rafat\Desktop\Code\dotfiles-opencode` | `frameworks/{conductor,learning,orchestrated,streamlined,vanilla}/opencode.json` (`provider.llamacpp.models`), `docs/frameworks.md`, `docs/changelog/frameworks.md` | Clave = alias de perfil, `name` `<Familia> <Quant> Local (<ctx>)`, `limit`, `reasoning`, `variants` off/low/medium/high |
| `C:\Users\rafat\Desktop\Code\dotfiles-pi` | `agent/models.json` (`providers.llama-cpp.models`), `docs/overview/local-models.md` | Objeto con `compat` `chat-template` + `enable_thinking` desde `thinking.enabled` |
| `C:\Users\rafat\Desktop\Code\local-inference-setup` | Copia de `AGENTS.md`, `README.md`, `handoff.md`, `config/`, `docs/`, `scripts/` de `D:\LLM` | `.gitignore` excluye `models/`, `runtimes/`, `packages/`, `logs/`, `tests/` |

Cada commit anterior del mismo tipo sirve de plantilla: `git log -3 --stat` en cada repositorio.

## Current status

- `nemotron-3.5-bolt-e4b` instalado y validado en D:\LLM: ver
  [docs/overview/models/nemotron-3.5-bolt-e4b.md](docs/overview/models/nemotron-3.5-bolt-e4b.md).
- Registrado y subido (2026-10-25):
  - dotfiles-dsh `bcad8be` — https://github.com/RafaGonzalezDev/dotfiles-dsh
  - dotfiles-opencode `87d8086` — https://github.com/RafaGonzalezDev/dotfiles-opencode
  - dotfiles-pi `9486349` — https://github.com/RafaGonzalezDev/dotfiles-pi
  - local-inference-setup: espejo con este alta — https://github.com/RafaGonzalezDev/local-inference-setup
- Verificado en el servidor: `enable_thinking: false` sin razonamiento; `thinking_budget_tokens: 64` cortó
  el razonamiento a unas 36 palabras.
- **No** se ha instalado la configuración en los clientes activos (`~/.dsh`, OpenCode, Pi) ni reiniciado
  ningún harness: los dotfiles solo cambian en el repositorio.

## Key context

- `dotfiles-dsh` tiene `package-lock.json` modificado desde antes de esta sesión, ajeno al alta: no se
  incluyó en el commit. No lo toques sin preguntar.
- `dotfiles-opencode` usa CRLF en los `opencode.json`: al insertar por script, normalizar a CRLF (no mezclar
  finales de línea). `cordis.patch.yml` usa LF.
- Las listas de los clientes contienen IDs anteriores que no coinciden con alias de perfil actuales
  (p. ej. `gemma-4-12b-v2` sin sufijo). No se corrigieron: fuera de alcance.
- Solo un perfil puede escuchar en `0.0.0.0:8080`. Durante esta sesión el usuario arrancó el perfil de
  Bolt desde el Explorador; no detener servidores que no inició el agente.
- El handoff anterior (2026-10-13, barrido funcional de `b11551`, MiniCPM-V, DSpark) se puede consultar en el
  historial git de `local-inference-setup`.

## Artifacts to reference

- [AGENTS.md](AGENTS.md) y [docs/overview/adding-a-model.md](docs/overview/adding-a-model.md): alta en D:\LLM.
- [docs/changelog/2026-10-25-nemotron-3.5-bolt-e4b.md](docs/changelog/2026-10-25-nemotron-3.5-bolt-e4b.md).
- `dotfiles-dsh/skills/dsh-model-catalog/SKILL.md`: política de nombres y contrato de razonamiento de DSH.
- `dotfiles-opencode/docs/frameworks.md` y `dotfiles-pi/docs/overview/local-models.md`: tablas de
  variantes/niveles de razonamiento y límites de salida.

## Suggested skills

- `conventional-commit` para cada commit, uno por repositorio.
- `ponytail` para mantener el diff mínimo.
- `docs-structure` antes de añadir documentación nueva.
- `handoff` para reescribir este archivo al cerrar la sesión.

## Open questions

- ¿Instalar los dotfiles en los clientes activos tras cada alta, o solo actualizar los repositorios?
- ¿Añadir el borrador DFlash de Bolt como perfil propio (requiere descarga, prueba y medición)?

## Verification steps

```powershell
# D:\LLM: validación estática global y del modelo nuevo
& scripts\common\Test-Llm.ps1 -ConfigurationOnly -RequireInstalledFiles
& scripts\common\Test-ModelIntegrity.ps1 -Model <model-id>

# Espejo: solo deben diferir archivos ignorados (.gitignore, LICENSE, logs, packages, tests)
git -C C:\Users\rafat\Desktop\Code\local-inference-setup status -sb
foreach ($d in 'AGENTS.md','README.md','handoff.md','config','docs','scripts') { git diff --no-index --stat "D:\LLM\$d" "C:\Users\rafat\Desktop\Code\local-inference-setup\$d" }
```

```bash
# Clientes: JSON válido e IDs únicos
cd /c/Users/rafat/Desktop/Code
node -e "for(const f of ['conductor','learning','orchestrated','streamlined','vanilla']){const m=require('./dotfiles-opencode/frameworks/'+f+'/opencode.json').provider.llamacpp.models;console.log(f,Object.keys(m).length)}"
node -e "const m=require('./dotfiles-pi/agent/models.json').providers['llama-cpp'].models;console.log(m.length,new Set(m.map(x=>x.id)).size)"
node -e "const Y=require('C:/Users/rafat/.dsh/audit-dsh/extracted/dsh/node_modules/yaml');const d=Y.parse(require('fs').readFileSync('dotfiles-dsh/config/profiles/desktop/cordis.patch.yml','utf8').replace(/!!js/g,''));const m=d.find(e=>e.id==='llm-pi-ai').config.providers['llama-cpp'].models;console.log(m.length,new Set(m.map(x=>x.id)).size)"
```
