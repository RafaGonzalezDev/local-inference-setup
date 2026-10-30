# Handoff

Sesión del 2026-10-26: altas de Nail y Occult Nail, Tiel Coder a IQ4_XS, retirada de diez modelos y
sincronización de los catálogos de cliente con todos los lanzadores. Este documento fija el **procedimiento que debe repetirse cada vez que se añade un modelo**;
el detalle técnico del modelo está en su ficha y changelog (ver rutas abajo).

## Next session focus

Cuando se incorpore un modelo nuevo a `D:\LLM` (siguiendo [AGENTS.md](AGENTS.md)), completar además estos
pasos, en este orden, sin pedirlos de nuevo:

1. **D:\LLM**: manifiesto, catálogo, lanzadores, descarga, integridad, `Test-Llm.ps1` estático sin filtros,
   calibración y smoke, README, ficha y changelog (todo según AGENTS.md).
2. **Verificar el contrato de razonamiento del cliente** con el perfil arrancado: que
   `chat_template_kwargs.enable_thinking: false` deja `reasoning_content` vacío y que
   `thinking_budget_tokens` corta el razonamiento. Si la plantilla usa `reasoning_effort` (Tiel), usar
   la receta alternativa de cada cliente.
3. **Registrar un ID por alias de perfil** (el segundo `--alias` del lanzador, p. ej.
   `nail-qwen3.6-35b-a3b-131k`) en los tres dotfiles. `input`/`modalities` con imagen solo en perfiles de
   visión. Límite de salida: 12.288 a 32K, 16.384 a 65K, 24.576 a 96K y 131K, 32.768 (pi, dsh) /
   32.000 (opencode) a 262K, salvo que la tarjeta pida más. Comprobar después que cada catálogo tiene
   exactamente los alias de todos los lanzadores (script de verificación abajo).
4. **Actualizar también la configuración global de DSH**
   (`C:\Users\rafat\.dsh\profiles\desktop\cordis.patch.yml`), no solo `dotfiles-dsh`: copia de seguridad
   `cordis.patch.yml.bak-<yyyyMMdd-HHmmss>-<model>` en el mismo directorio y edición acotada (alta o baja) de la
   misma entrada de `providers.llama-cpp.models`. No reinstalar el componente desde el repositorio: el
   archivo global conserva ajustes de la GUI (p. ej. `agent-default-model`) que el repositorio no
   tiene. Validar con el parse YAML de abajo y comprobar que el `diff` contra el repositorio solo muestra
   esos ajustes. DSH necesita reiniciarse para listar el modelo.
5. **Commit convencional por repositorio** (skill `conventional-commit`), push a `origin main` y mostrar
   al usuario la URL de cada remoto.
6. **Espejar D:\LLM en `local-inference-setup`** (incluido este `handoff.md`), commit y push.
7. **Clientes activos en WSL**: copiar el proveedor local del repositorio a `~/.pi/agent/models.json` y
   a `~/.config/opencode/opencode.json` (solo `provider.llamacpp.models`), con copia `.bak-<timestamp>` previa.

## Dónde se registra cada modelo

| Repositorio | Archivos | Patrón a copiar |
| --- | --- | --- |
| `C:\Users\rafat\Desktop\Code\dotfiles-dsh` | `config/profiles/desktop/cordis.patch.yml` (ruta `llm-pi-ai` → `providers.llama-cpp.models`) | Entrada YAML con `id`, `name` (`<Familia> Local · <ctx>`), `contextWindow`, `maxTokens`, `input`, `reasoningEfforts`; reglas en `skills/dsh-model-catalog/SKILL.md` |
| DSH global (sin git) | `C:\Users\rafat\.dsh\profiles\desktop\cordis.patch.yml` | Misma entrada que `dotfiles-dsh`; conservar las filas que difieran por ajustes de la GUI |
| `C:\Users\rafat\Desktop\Code\dotfiles-opencode` | `frameworks/{conductor,learning,orchestrated,streamlined,vanilla}/opencode.json` (`provider.llamacpp.models`), `docs/frameworks.md`, `docs/changelog/frameworks.md` | Clave = alias de perfil, `name` `<Familia> <Quant> Local (<ctx>)`, `limit`, `reasoning`, `variants` off/low/medium/high |
| `C:\Users\rafat\Desktop\Code\dotfiles-pi` | `agent/models.json` (`providers.llama-cpp.models`), `docs/overview/local-models.md` | Objeto con `compat` `chat-template` + `enable_thinking` desde `thinking.enabled` |
| `C:\Users\rafat\Desktop\Code\local-inference-setup` | Copia de `AGENTS.md`, `README.md`, `handoff.md`, `config/`, `docs/`, `scripts/` de `D:\LLM` | `.gitignore` excluye `models/`, `runtimes/`, `packages/`, `logs/`, `tests/` |

Cada commit anterior del mismo tipo sirve de plantilla: `git log -3 --stat` en cada repositorio.

## Current status

- Catálogo activo (2026-10-29): 5 modelos y 18 perfiles en `b11551`, sin MTP. Cuatro son `UD-Q4_K_XL` de
  `peculiar-ragdoll`: `tiel-coder-35b-a3b`, `nail-qwen3.6-35b-a3b`, `occult-nail-1.0-35b-a3b` y
  `cyber-tiel-coder-35b-a3b`; el quinto, `nemotron-3.5-lightning-30b-a3b`, es `AD-IQ4_NL` de `AtomicChat`. Los perfiles MTP se retiraron y Tiel y Cyber Tiel perdieron el sufijo
  `-mtp` ([changelog](docs/changelog/2026-10-28-q4-k-xl-without-mtp.md)). Lanzadores con 6 hilos.
- Retirados el 2026-10-26 a elección del usuario, con sus pesos: `tiel-coder-35b-a3b`, `gemma-4-12b-v2`,
  `gemma-4-26b-a4b`, `ornith-1.5-9b`, `nemotron-3.5-lightning-30b-a3b`, `ling-3.0-tiny`,
  `swift-1.5-qwen3.8-27b-gsq-rco-mtp`, `minicpm-v-4.7-35b-a3b`, `flint`, `sage-a1.5-35b-a3b`, y el runtime
  `b11827`. Ver [el changelog de retirada](docs/changelog/2026-10-26-model-set-retirement.md).
- 2026-10-27: runtime del catálogo a `b11669` (v0.7.0) sin smoke por perfil ([changelog](docs/changelog/2026-10-27-llama-runtime-b11669.md)).
  2026-10-28: vuelto a `b11551` y eliminados `b11669` y los paquetes sin uso, porque el usuario midió un decode
  sustancialmente mayor con `b11551` a través de Pi ([changelog](docs/changelog/2026-10-28-runtime-back-to-b11551.md)).
  2026-10-28: retirados `lfm3-1.7b`, `lfm3-audio-2b` y `lfm3-omni-2b` con el runtime compilado
  `19ff817-cuda13.4` ([changelog](docs/changelog/2026-10-28-lfm3-retirement.md)). También retirados
  `lfm2.5-24b-a2b`, `nemotron-3.5-bolt-e4b`, `ornith-1.5-35b-a3b` y `qwen3.6-35b-a3b`, con sus pesos
  ([changelog](docs/changelog/2026-10-28-model-set-retirement.md)).
- 2026-10-29: `lfm3-1.7b` (`Q8_0`) en `experimental/lfm3` con su runtime oficial `b11981-cuda13.4`, fuera
  del catálogo principal ([changelog](docs/changelog/2026-10-29-lfm3-b11981.md)); VL, Audio y Omni se
  instalaron y retiraron el mismo día ([changelog](docs/changelog/2026-10-29-lfm3-multimodal-retirement.md)).
  Pi y OpenCode (repositorios y WSL, copias `*.bak-<timestamp>-{lfm3-b11981,lfm3-multimodal-retirement}`)
  listan además `lfm3-1.7b-262k`; DSH no, por decisión del usuario. En la comprobación de paridad, añade
  ese alias a `served.txt`.
- 2026-10-29: vuelve `nemotron-3.5-lightning-30b-a3b` con `AD-IQ4_NL` de `AtomicChat` y dos perfiles (131K y
  262K): el catálogo pasa a 5 modelos y 18 perfiles ([changelog](docs/changelog/2026-10-29-nemotron-3.5-lightning-30b-a3b.md)).
  Copias de los clientes: `*.bak-<timestamp>-nemotron-lightning`.
- 2026-10-30: vuelve `flint` (`UD-Q4_K_XL`, misma revisión que el 2026-10-22) con `b11981-cuda13.4` y dos
  perfiles (`flint-131k`, `flint-262k`): 6 modelos y 20 perfiles ([changelog](docs/changelog/2026-10-30-flint.md)).
  Calibrados bajo carga, con tool calling y contrato de razonamiento medidos: el razonamiento no se
  desactiva por petición y `thinking_budget_tokens: 0` lo vuelca en `content`, así que los clientes no
  deben enviar presupuesto 0 a Flint (sus entradas no ofrecen `off`). Los tres dotfiles, DSH global y WSL
  listan los 20 alias (Pi y OpenCode, además `lfm3-1.7b-262k`); copias `cordis.patch.yml.bak-20261030-101331-flint`
  y `*.bak-20261030-101503-flint` en WSL.
- Los 20 perfiles calibrados bajo carga (los 12 de `UD-Q4_K_XL` nuevos el 2026-10-28, los 2 de Nemotron el
  2026-10-29 y los 2 de Flint el 2026-10-30). El contrato de razonamiento completo solo se verificó en Occult Nail, Nemotron y en las versiones
  anteriores de Tiel y Nail.
- Los tres dotfiles, DSH global y los clientes activos de WSL (`~/.pi/agent/models.json` y
  `~/.config/opencode/opencode.json`) listan exactamente los 18 alias (2026-10-29). Cada archivo vivo tiene copia
  `*.bak-<timestamp>-{profile-aliases,retirement,lfm3-1.7b,lfm3-retirement,model-retirement,qwen-retirement,mtp-retirement}` (OpenCode también `modalities-fix`, del 2026-10-29); DSH global,
  `cordis.patch.yml.bak-*-{lfm3-1.7b,lfm3-retirement,model-retirement,qwen-retirement,mtp-retirement}`.
- DSH global: a 2026-10-28 solo difiere del repositorio en ajustes de la GUI: `agent-default-model`
  sin `reasoningEffort: high` y `ui-chat.transcriptView: standard` (el repositorio, `detailed`). DSH
  necesita reiniciarse para dejar de listar los alias MTP retirados.
- Estado de OpenCode en WSL (`~/.local/state/opencode/model.json`): recientes, favoritos y variantes
  migrados a alias de perfil y sin modelos retirados (copias `.bak-*`).

## Key context

- `dotfiles-dsh` tiene `package-lock.json` modificado desde antes de esta sesión, ajeno al alta: no se
  incluyó en el commit. No lo toques sin preguntar.
- `dotfiles-opencode` usa CRLF en los `opencode.json`: al insertar por script, normalizar a CRLF (no mezclar
  finales de línea). `cordis.patch.yml` usa LF.
- Solo un perfil puede escuchar en `0.0.0.0:8080`; no detener servidores que no inició el agente.
  El script de calibración de esta sesión no se versionó; la ficha de Nail describe qué mide.
- El handoff anterior (2026-10-13, barrido funcional de `b11551`, MiniCPM-V, DSpark) se puede consultar en el
  historial git de `local-inference-setup`.

## Artifacts to reference

- [AGENTS.md](AGENTS.md) y [docs/overview/adding-a-model.md](docs/overview/adding-a-model.md): alta en D:\LLM.
- [docs/changelog/2026-10-26-nail-qwen3.6-35b-a3b.md](docs/changelog/2026-10-26-nail-qwen3.6-35b-a3b.md).
- `dotfiles-dsh/skills/dsh-model-catalog/SKILL.md`: política de nombres y contrato de razonamiento de DSH.
- `dotfiles-opencode/docs/frameworks.md` y `dotfiles-pi/docs/overview/local-models.md`: tablas de
  variantes/niveles de razonamiento y límites de salida.

## Suggested skills

- `conventional-commit` para cada commit, uno por repositorio.
- `ponytail` para mantener el diff mínimo.
- `docs-structure` antes de añadir documentación nueva.
- `handoff` para reescribir este archivo al cerrar la sesión.

## Open questions

- ¿Instalar también los dotfiles de OpenCode y Pi en sus clientes activos tras cada alta? (DSH global ya
  forma parte del procedimiento.)

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

# DSH global: mismos IDs que el repositorio; el diff solo debe mostrar ajustes de la GUI
node -e "const Y=require('C:/Users/rafat/.dsh/audit-dsh/extracted/dsh/node_modules/yaml');const d=Y.parse(require('fs').readFileSync('C:/Users/rafat/.dsh/profiles/desktop/cordis.patch.yml','utf8').replace(/!!js/g,''));const m=d.find(e=>e.id==='llm-pi-ai').config.providers['llama-cpp'].models;console.log(m.length,new Set(m.map(x=>x.id)).size)"
diff /c/Users/rafat/.dsh/profiles/desktop/cordis.patch.yml dotfiles-dsh/config/profiles/desktop/cordis.patch.yml

# Paridad: cada catálogo contiene exactamente los alias de perfil de todos los lanzadores
grep -ho -- '--alias [^ "]*' /d/LLM/scripts/models/*/*.cmd | sed 's/--alias [^,]*,//' | sort > served.txt
# Pi y OpenCode también listan este perfil de experimental/lfm3; en DSH aparece como "missing", y es lo esperado
printf '%s\n' lfm3-1.7b-262k >> served.txt
node -e "
const fs=require('fs');const srv=fs.readFileSync('served.txt','utf8').trim().split('\n');
const Y=require('C:/Users/rafat/.dsh/audit-dsh/extracted/dsh/node_modules/yaml');
const dsh=f=>Y.parse(fs.readFileSync(f,'utf8').replace(/!!js/g,'')).find(e=>e.id==='llm-pi-ai').config.providers['llama-cpp'].models.map(m=>m.id);
const lists={dsh:dsh('dotfiles-dsh/config/profiles/desktop/cordis.patch.yml'),dshGlobal:dsh('C:/Users/rafat/.dsh/profiles/desktop/cordis.patch.yml'),pi:require('./dotfiles-pi/agent/models.json').providers['llama-cpp'].models.map(m=>m.id)};
for(const f of ['conductor','learning','orchestrated','streamlined','vanilla'])lists['oc-'+f]=Object.keys(require('./dotfiles-opencode/frameworks/'+f+'/opencode.json').provider.llamacpp.models);
for(const[k,v] of Object.entries(lists))console.log(k,v.length,'missing:',srv.filter(x=>!v.includes(x)).join(' ')||'-','extra:',v.filter(x=>!srv.includes(x)).join(' ')||'-')"
rm served.txt
```
