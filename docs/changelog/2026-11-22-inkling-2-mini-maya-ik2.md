# 2026-11-22 - Inkling 2 Mini con maya-ik2 en un subárbol experimental

**Qué**: Nuevo subárbol `maya/` con catálogo, el manifiesto de `inkling-2-mini` (`UD-Q4_K_XL` de Unsloth,
revisión `ae9327c5fbc7333116ba32eee78bb5d2bbefae4f`) y el lanzador `start-text-262k.cmd`, que arranca el servidor
Python de maya-inkling-mini con su motor `maya-ik2` a 262.144 tokens, solo texto, en `0.0.0.0:8080`. Runtime
nuevo compilado desde el commit `e819852` en `runtimes/maya-ik2/e819852-cuda13.4/`.

**Dónde**: `maya/` (README, `config/`, `scripts/models/inkling-2-mini/`), `models/inkling-2-mini/`,
`runtimes/maya-ik2/`, `docs/overview/models/inkling-2-mini.md`, `README.md`.

**Por qué**: El usuario quiere Inkling 2 Mini a 262K. llama.cpp lo servía a 45,6 tok/s a 65K y caía a unos 9 tok/s
a 131K (prueba del 2026-11-20). `maya-ik2` promete más velocidad con una caché de expertos en VRAM; no es
`llama-server`, así que vive aparte como `speech/` y reutiliza `Download-Model.ps1` y `Test-ModelIntegrity.ps1`
con `-RootDirectory`. No se propaga a clientes ni al espejo hasta medir si compensa (acordado con el usuario).

## Validación

- GGUF verificado por tamaño y SHA-256; `Test-ModelIntegrity.ps1 -RootDirectory .\maya` pasa.
- Compilación correcta (`sm_120`, CUDA 13.4.59, MSVC 19.44); SHA-256 de binarios en la ficha.
- `Test-Llm.ps1 -ConfigurationOnly -RequireInstalledFiles`: los 52 perfiles de llama.cpp siguen pasando; el
  subárbol `maya/` queda fuera por diseño.
- Calibración funcional con la GPU libre: carga en unos 5 s, pico de 15.603 MiB de VRAM, 36–42 tok/s con prompt
  corto, prefill de 203.659 tokens a 1.114 tok/s y generación a 27,4 tok/s a esa profundidad, tool calling y
  `reasoning_effort: "none"` correctos. Detalle en la ficha.
- Perfil adicional `start-text-131k.cmd` (42–45 tok/s con prompt corto). Cada perfil anuncia su alias
  (`inkling-2-mini-131k`, `inkling-2-mini-262k`) como `model_name`.
- Registro temporal en el `~/.pi/agent/models.json` vivo de WSL (no en `dotfiles-pi`), con copia
  `models.json.bak-20261122-052722-inkling-maya-temp`.
- `thinking_budget` 8192 y `fit_max_tokens` en ambos perfiles; en Pi, el mapa de esfuerzo de Tiel y `maxTokens`
  24.576 / 32.768. El presupuesto resultó sin efecto con Inkling (ver ficha).
- Adopción (2026-11-22, tras la prueba del usuario desde Pi): alias registrados en `dotfiles-pi`,
  `dotfiles-opencode`, `dotfiles-dsh`, la configuración global de DSH y los clientes de WSL; el espejo
  `local-inference-setup` incluye `maya/`. `AGENTS.md` incorpora el subárbol a «Propagación a clientes» y pide
  revisar periódicamente el upstream del motor.
