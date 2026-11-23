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
| `C:\Users\rafat\Desktop\Code\dotfiles-opencode` | `profiles/{orchestrated,vanilla}/opencode.json` (`provider.llamacpp.models`, idéntico en ambos), `docs/profiles.md`, `docs/changelog/profiles.md` | Clave = alias de perfil, `name` `<Familia>[-V]-<ctx>` (p. ej. `Tiel-Coder-V-262K`), `limit`, `reasoning`, `variants` off/low/medium/high |
| `C:\Users\rafat\Desktop\Code\dotfiles-pi` | `agent/models.json` (`providers.llama-cpp.models`), `docs/overview/local-models.md` | Objeto con `compat` `chat-template` + `enable_thinking` desde `thinking.enabled`; mismo `name` que en OpenCode |
| `C:\Users\rafat\Desktop\Code\local-inference-setup` | Copia de `AGENTS.md`, `README.md`, `handoff.md`, `config/`, `docs/`, `scripts/` de `D:\LLM` | `.gitignore` excluye `models/`, `runtimes/`, `packages/`, `logs/`, `tests/` |

Cada commit anterior del mismo tipo sirve de plantilla: `git log -3 --stat` en cada repositorio.

## Current status

- Catálogo activo (2026-10-30): 6 modelos y 20 perfiles en `b11981`, sin MTP. Cuatro son `UD-Q4_K_XL` de
  `peculiar-ragdoll`: `tiel-coder-35b-a3b`, `nail-qwen3.6-35b-a3b`, `occult-nail-1.0-35b-a3b` y
  `cyber-tiel-coder-35b-a3b`; `nemotron-3.5-lightning-30b-a3b` es `AD-IQ4_NL` de `AtomicChat` y `flint`,
  `UD-Q4_K_XL` de `unsloth`. El 2026-10-30 todos los lanzadores pasaron de `b11551` a `b11981` y se eliminó
  `b11551` ([changelog](docs/changelog/2026-10-30-llama-runtime-b11981-catalog.md)). Los perfiles MTP se retiraron y Tiel y Cyber Tiel perdieron el sufijo
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
  Pi (repositorio y WSL, copias `*.bak-<timestamp>-{lfm3-b11981,lfm3-multimodal-retirement}`) lista además
  `lfm3-1.7b-262k`; OpenCode lo quitó el 2026-10-31. Desde el 2026-11-01 vuelve a estar en los tres
  clientes (ver más abajo).
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
- 2026-11-01: alta de `apex-35b-v1.0` (`Q4_K_S` con imatrix de `Apexintelligence-AI`), dos perfiles (131K y
  262K): 7 modelos y 22 perfiles ([changelog](docs/changelog/2026-11-01-apex-35b-v1.0.md)). Calibrados bajo
  carga, con tool calling y contrato de razonamiento medidos. En los clientes solo ofrece `off` y razonamiento
  dinámico sin tope (DSH lo consigue enviando `thinking_token_budget`, que el servidor ignora). Copias: `cordis.patch.yml.bak-20261101-064129-apex` (DSH global) y
  `*.bak-20261101-064209-apex` en WSL (Pi, OpenCode y `model.json`); después, `opencode.json.bak-20261101-072940-apex-output`,
  `cordis.patch.yml.bak-20261101-074004-apex-dynamic` y `*.bak-20261101-074250-apex-dynamic` en WSL.
- 2026-11-01: la familia LFM3 entra en el catálogo principal: `lfm3-1.7b` sale de `experimental/lfm3` y
  vuelven `lfm3-vl-2b`, `lfm3-audio-2b` y `lfm3-omni-2b` (Audio y Omni con la revisión más reciente, de
  proyector nuevo). Son 11 modelos y 26 perfiles ([changelog](docs/changelog/2026-11-01-lfm3-main-catalog.md)).
  Los clientes listan los 25 alias servidos menos `lfm3-audio-2b-audio-32k`. Copias:
  `cordis.patch.yml.bak-20261101-214738-lfm3-main-catalog` (DSH global) y `*.bak-20261101-215112-lfm3-main-catalog`
  en WSL (Pi, OpenCode y `model.json`). `experimental/` se borró el mismo día.
- 2026-11-02: alta de `gemma-4-26b-a4b-uncensored-balanced` (`Q4_K_M` de `HauhauCS`, variante sin rechazos de los
  pesos QAT de Gemma 4 26B A4B), cuatro perfiles (texto y visión a 131K y 262K), sin el borrador MTP aparte: 12
  modelos y 30 perfiles ([changelog](docs/changelog/2026-11-02-gemma-4-26b-a4b-uncensored-balanced.md)). Calibrados
  con 56K tokens (VRAM pico 15,5 GB); mismo contrato de razonamiento que Occult Nail. Los clientes listan 29
  alias. Copias: `cordis.patch.yml.bak-20261102-000750-gemma-uncensored` (DSH global) y
  `*.bak-20261102-000812-gemma-uncensored` en WSL (Pi, OpenCode y `model.json`).
- 2026-11-11: vuelve `qwen3.6-35b-a3b` con el `UD-Q4_K_XL` oficial de Unsloth (GGUF con capa MTP sin usar) y el
  proyector de Nail, cuatro perfiles (texto y visión a 131K y 262K): 13 modelos y 34 perfiles
  ([changelog](docs/changelog/2026-11-11-qwen3.6-35b-a3b.md)). Prueba funcional sin calibración bajo carga
  (mismos pesos que Nail). Strata se evaluó y se borró el mismo día. Los clientes listan 33 alias. Copias:
  `cordis.patch.yml.bak-20261111-013749-qwen3.6` (DSH global) y `*.bak-20261111-013927-qwen3.6` en WSL (Pi,
  OpenCode y `model.json`).
- 2026-11-15: los 34 lanzadores del catálogo y los 3 de `experimental/` pasan de `b11981-cuda13.4` a
  `b12359-cuda13.5` (v1.0.0) y se eliminan `runtimes\llama.cpp\b11981-cuda13.4` y `packages\llama.cpp\b11981`
  ([changelog](docs/changelog/2026-11-15-llama-runtime-b12359-v1.0.0.md)). Medido solo en Qwen3.6 131K; smoke
  de Apex 131K y 262K, el resto sin prueba funcional por decisión del usuario. Alias sin cambios: los clientes
  no se tocaron.
- 2026-11-16: vuelven `ornith-1.5-9b` (`Q4_K_M` oficial de `ornith-ai`, texto, 131K y 262K) y
  `gemma-4-12b-it-qat` (`UD-Q4_K_XL` de `unsloth` con proyector BF16 y borrador MTP externo; texto, MTP y
  visión a 131K y 262K): 15 modelos y 42 perfiles ([changelog](docs/changelog/2026-11-16-ornith-1.5-9b-gemma-4-12b-it-qat.md)).
  Calibrados bajo carga con 56K tokens (VRAM pico 10,3 a 14,3 GB), con reutilización de caché, tool calling y
  contrato de razonamiento medidos; el MTP acelera la generación 2,2 a 2,7 veces. Los clientes listan 41
  alias. Copias: `cordis.patch.yml.bak-20261116-180400-ornith-gemma12b` (DSH global) y
  `*.bak-20261116-180514-ornith-gemma12b` en WSL (Pi, OpenCode y `model.json`).
- 2026-11-16: `ornith-1.5-9b` recibe su proyector BF16 y perfiles de visión a 131K y 262K **sin prueba
  funcional ni calibración** (GPU ocupada, decisión del usuario): 44 perfiles, 43 alias en clientes
  ([changelog](docs/changelog/2026-11-16-ornith-1.5-9b-vision.md)). Pendiente: smoke con la imagen de prueba y
  calibración bajo carga. Copias: `cordis.patch.yml.bak-20261116-184457-ornith-vision` y `*.bak-20261116-184522-ornith-vision` en WSL.
- 2026-11-17: `gemma-4-26b-a4b-it-qat` (`UD-Q4_K_XL` de `unsloth`, Q4_0 real, proyector BF16; texto y visión a
  131K y 262K, sin MTP) sustituye a `gemma-4-26b-a4b-uncensored-balanced`, **sin prueba funcional** por petición
  del usuario; los pesos de HauhauCS siguen en `models\` (los referencia `experimental/`, sin uso). Entra
  `gemma-4-e4b-it-qat` (Q4_0 oficial de `google`, proyector de visión y audio; texto y visión a 131K, nativo),
  con smoke y calibración bajo carga (VRAM pico 6,8 y 8,2 GB). 16 modelos y 46 perfiles; los clientes listan 45
  alias ([changelog](docs/changelog/2026-11-17-gemma-4-26b-a4b-it-qat-gemma-4-e4b-it-qat.md)). El script de
  calibración quedó en `logs/validation/calibration-gemma-4-e4b-it-qat-20261117/` (no se espeja). Copias:
  `cordis.patch.yml.bak-20261117-192105-gemma26b-e4b` (DSH global) y `*.bak-20261117-192321-gemma26b-e4b` en WSL
  (Pi, OpenCode y `model.json`).
- 2026-11-21: alta de `gemma-4-12b-uncensored-balanced` (`Q4_K_M` de `HauhauCS`, variante sin censura de Gemma 4
  12B QAT, con proyector BF16 y borrador MTP propios; texto, MTP y visión a 131K y 262K, muestreo de la tarjeta),
  **sin prueba funcional** por decisión del usuario: se asumen los resultados de `gemma-4-12b-it-qat`. Los perfiles
  de visión de ambos 12B pasan a `--image-min-tokens 1120 --image-max-tokens 1120` y batch/ubatch 2048
  (`-vision-*-2048`), sin medir. 17 modelos y 52 perfiles; los clientes listan 51 alias
  ([changelog](docs/changelog/2026-11-21-gemma-4-12b-uncensored-balanced.md)). Copias:
  `cordis.patch.yml.bak-20261121-220705-gemma12b-uncensored` (DSH global) y `*.bak-20261121-220919-gemma12b-uncensored`
  en WSL (Pi, OpenCode y `model.json`).
- 2026-11-22: prueba experimental de `inkling-2-mini` con `maya-ik2` en el subárbol `maya/` (perfiles
  `start-text-131k.cmd` y `start-text-262k.cmd`, fuera de `Test-Llm.ps1`;
  [changelog](docs/changelog/2026-11-22-inkling-2-mini-maya-ik2.md)). Primero se registró solo en el Pi vivo de WSL
  (copias `models.json.bak-20261122-052722-inkling-maya-temp` y `models.json.bak-20261122-055343-inkling-thinking-map`);
  el mismo día el usuario lo adoptó y se propagó a los tres dotfiles, a DSH global
  (`cordis.patch.yml.bak-20261122-064029-inkling-2-mini`), al espejo (con `maya/`) y a los clientes de WSL
  (`*.bak-20261122-064414-inkling-2-mini` en Pi, OpenCode y `model.json`). Los clientes listan 53 alias: los 51 de llama.cpp más los 2 de `maya/`.
  El upstream de `maya-ik2` se revisa periódicamente (ver la ficha).
- 2026-11-22: alta de `qwen3.8-flash-next-gsq-rco` (IQ3_XXS) con Strata 0.2.18 en el subárbol `strata/` (perfil
  `start-text-131k.cmd`, runtime en `runtimes/strata/0.2.18/`, fuera de `Test-Llm.ps1`;
  [changelog](docs/changelog/2026-11-22-qwen3.8-flash-next-gsq-rco-strata.md)). Registrado solo en Pi: `dotfiles-pi`
  (`ee1778d`) y el Pi vivo de WSL (copia `models.json.bak-20261122-075135-qwen3.8-flash-next`); Pi lista 55 alias.
  El usuario arrancó el de 131K desde Pi (95–140 tok/s, RAM y VRAM llenas); el de 262K se retiró (`dotfiles-pi`
  `4f8273e`, copia `models.json.bak-20261122-080532-flash-next-262k-removal`). El Coder
  (`qwen3.8-flash-next-gsq-rco-coder`) se añadió (`c96e961`, copia `models.json.bak-20261122-082604-flash-next-coder`)
  y se retiró el mismo día por dar peores resultados; el usuario adoptó el IQ3_XXS y se propagó a los tres dotfiles,
  a DSH global (`cordis.patch.yml.bak-20261122-092142-qwen3.8-flash-next`), al espejo (con `strata/`) y a WSL
  (`*.bak-20261122-092321-qwen3.8-flash-next` en Pi, OpenCode y `model.json`). Los clientes listan 54 alias: 51 de
  llama.cpp, 2 de `maya/` y 1 de `strata/`. Después se añadió `--vram-reserve-mib 1536` a su JSON (confirmado en
  la sesión siguiente: sin escalón de velocidad hasta 103K; ver su ficha) y un perfil de 200K (204.800 tokens,
  sin arrancar), propagado con las copias `cordis.patch.yml.bak-20261122-095259-qwen3.8-flash-next-200k` (DSH global)
  y `*.bak-20261122-095320-qwen3.8-flash-next-200k` en WSL (Pi, OpenCode y `model.json`). Los clientes listan 55
  alias: 51 de llama.cpp, 2 de `maya/` y 2 de `strata/`.
- 2026-11-22: Strata 0.2.19 (Terminal y motores 0.1.65) en `runtimes/strata/0.2.19/`; los dos lanzadores de
  Flash-Next apuntan a él (mismos argumentos y alias; 0.2.18 se conserva para volver atrás). Alta preliminar de
  `inkling-2-mini-sq-15` (Strata, perfiles de 131K y 262K, sin razonamiento) registrada solo en Pi: `dotfiles-pi`
  `0fd4c64` y el Pi vivo de WSL (copia `models.json.bak-20261122-162651-inkling-sq15-strata`); Pi lista 57 alias,
  OpenCode y DSH siguen en 55. Ni el espejo ni los otros clientes se han tocado hasta que el usuario lo adopte
  ([changelog](docs/changelog/2026-11-22-strata-0.2.19-inkling-sq-15.md)).
- 2026-11-22: retirada completa de Inkling 2 Mini (`maya-ik2` con `maya/` y el runtime, y el SQ-15 de Strata con su
  componente `strata-inkling`), a petición del usuario. Alias quitados de Pi, OpenCode, DSH (repositorio y global,
  copia `cordis.patch.yml.bak-20261122-173858-inkling-removal`), el espejo y WSL (`*.bak-*-inkling-removal`). Los
  clientes listan 53 alias: 51 de llama.cpp y 2 de `strata/`
  ([changelog](docs/changelog/2026-11-22-inkling-2-mini-removal.md)).
- 2026-11-22: a petición del usuario, los clientes solo registran Cyber Tiel Coder, Occult Nail, Qwen3.6 35B-A3B y
  Qwen3.8 Flash Next (14 alias); los otros 13 modelos conservan pesos y lanzadores, sin alias en ningún cliente. Copias:
  `cordis.patch.yml.bak-20261122-174815-catalog-prune` (DSH global) y `*.bak-*-catalog-prune` en WSL
  ([changelog](docs/changelog/2026-11-22-client-catalog-trim.md)).
- 2026-11-22: a petición del usuario vuelven a los clientes los 18 alias de los cuatro Gemma 4 (26B-A4B QAT, 12B QAT,
  12B Uncensored Balanced y E4B QAT), idénticos a los de antes de la poda: los clientes listan 32 alias. Copias:
  `cordis.patch.yml.bak-20261122-212307-gemma-restore` (DSH global) y `*.bak-20261122-212627-gemma-restore` en WSL (Pi, OpenCode y
  `model.json`) ([changelog](docs/changelog/2026-11-22-client-catalog-gemma-restore.md)).
- 2026-11-23: vuelve el perfil de 262K de Flash-Next (`start-text-262k.cmd`, alias
  `qwen3.8-flash-next-gsq-rco-262k`), creado por el usuario a partir del de 200K. Su JSON solo cambiaba el contexto
  en `args_written`, así que la prueba de la mañana se hizo a 204.800 tokens con el alias `-200k`; se corrigieron
  `args`, `model_name` y `log` (comprobado con `serve --plan`, sin arrancar a 262K). Los clientes listan 33 alias.
  Copias: `cordis.patch.yml.bak-20261123-143129-qwen3.8-flash-next-262k` (DSH global) y
  `*.bak-20261123-143309-qwen3.8-flash-next-262k` en WSL (Pi, OpenCode y `model.json`)
  ([changelog](docs/changelog/2026-11-23-qwen3.8-flash-next-gsq-rco-262k.md)).
- 2026-11-23: DSH (repositorio `dotfiles-dsh` y global) apunta a `http://192.168.1.100:8080/v1` en vez de
  `127.0.0.1`, como Pi y OpenCode, para usar los modelos de este equipo desde el del trabajo. Copia:
  `cordis.patch.yml.bak-20261123-144152-llama-cpp-lan-url`.
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
- `dotfiles-opencode/docs/profiles.md` y `dotfiles-pi/docs/overview/local-models.md`: tablas de
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
foreach ($d in 'AGENTS.md','README.md','handoff.md','config','docs','scripts','strata') { git diff --no-index --stat "D:\LLM\$d" "C:\Users\rafat\Desktop\Code\local-inference-setup\$d" }
```

```bash
# Clientes: JSON válido e IDs únicos
cd /c/Users/rafat/Desktop/Code
node -e "for(const f of ['orchestrated','vanilla']){const m=require('./dotfiles-opencode/profiles/'+f+'/opencode.json').provider.llamacpp.models;console.log(f,Object.keys(m).length)}"
node -e "const m=require('./dotfiles-pi/agent/models.json').providers['llama-cpp'].models;console.log(m.length,new Set(m.map(x=>x.id)).size)"
node -e "const Y=require('C:/Users/rafat/.dsh/audit-dsh/extracted/dsh/node_modules/yaml');const d=Y.parse(require('fs').readFileSync('dotfiles-dsh/config/profiles/desktop/cordis.patch.yml','utf8').replace(/!!js/g,''));const m=d.find(e=>e.id==='llm-pi-ai').config.providers['llama-cpp'].models;console.log(m.length,new Set(m.map(x=>x.id)).size)"

# DSH global: mismos IDs que el repositorio; el diff solo debe mostrar ajustes de la GUI
node -e "const Y=require('C:/Users/rafat/.dsh/audit-dsh/extracted/dsh/node_modules/yaml');const d=Y.parse(require('fs').readFileSync('C:/Users/rafat/.dsh/profiles/desktop/cordis.patch.yml','utf8').replace(/!!js/g,''));const m=d.find(e=>e.id==='llm-pi-ai').config.providers['llama-cpp'].models;console.log(m.length,new Set(m.map(x=>x.id)).size)"
diff /c/Users/rafat/.dsh/profiles/desktop/cordis.patch.yml dotfiles-dsh/config/profiles/desktop/cordis.patch.yml

# Paridad: cada catálogo contiene exactamente los alias de perfil de todos los lanzadores
grep -ho -- '--alias [^ "]*' /d/LLM/scripts/models/*/*.cmd | sed 's/--alias [^,]*,//' > served.txt
# Strata profiles: the alias is the model_name of each engine config
grep -ho '"model_name": "[^"]*"' /d/LLM/strata/scripts/models/*/*.json | sed 's/.*: "//;s/"$//' >> served.txt
sort -o served.txt served.txt
# LFM3 Audio no se registra en ningún cliente (ninguno envía audio)
sed -i '/^lfm3-audio-2b-audio-32k$/d' served.txt
# Desde el 2026-11-22 los clientes solo registran estos ocho modelos (decisión del usuario; ver AGENTS.md)
grep -E '^(cyber-tiel-coder-35b-a3b|occult-nail-1\.0-35b-a3b|qwen3\.6-35b-a3b|qwen3\.8-flash-next-gsq-rco|gemma-4-26b-a4b-it-qat|gemma-4-12b-it-qat|gemma-4-12b-uncensored-balanced|gemma-4-e4b-it-qat)-' served.txt > served.keep && mv served.keep served.txt
node -e "
const fs=require('fs');const srv=fs.readFileSync('served.txt','utf8').trim().split('\n');
const Y=require('C:/Users/rafat/.dsh/audit-dsh/extracted/dsh/node_modules/yaml');
const dsh=f=>Y.parse(fs.readFileSync(f,'utf8').replace(/!!js/g,'')).find(e=>e.id==='llm-pi-ai').config.providers['llama-cpp'].models.map(m=>m.id);
const lists={dsh:dsh('dotfiles-dsh/config/profiles/desktop/cordis.patch.yml'),dshGlobal:dsh('C:/Users/rafat/.dsh/profiles/desktop/cordis.patch.yml'),pi:require('./dotfiles-pi/agent/models.json').providers['llama-cpp'].models.map(m=>m.id)};
for(const f of ['orchestrated','vanilla'])lists['oc-'+f]=Object.keys(require('./dotfiles-opencode/profiles/'+f+'/opencode.json').provider.llamacpp.models);
for(const[k,v] of Object.entries(lists))console.log(k,v.length,'missing:',srv.filter(x=>!v.includes(x)).join(' ')||'-','extra:',v.filter(x=>!srv.includes(x)).join(' ')||'-')"
rm served.txt
```
