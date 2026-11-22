# 2026-11-22 - Catálogo de clientes reducido a cuatro modelos

**Qué**: Pi, OpenCode y DSH (repositorio y global), y los clientes de WSL, solo registran los alias de cuatro
modelos (14 alias):

- `cyber-tiel-coder-35b-a3b` (131K, 262K y visión en ambos)
- `occult-nail-1.0-35b-a3b` (131K, 262K y visión en ambos)
- `qwen3.6-35b-a3b` (131K, 262K y visión en ambos)
- `qwen3.8-flash-next-gsq-rco` (131K y 200K, Strata)

Salen de los clientes 39 alias de 13 modelos: Tiel Coder, Nail Qwen3.6, Nemotron 3.5 Lightning, Recursive Flint,
Apex 35B, Gemma 4 26B-A4B QAT, Gemma 4 12B QAT, Gemma 4 12B Uncensored Balanced, Gemma 4 E4B QAT, Ornith 1.5 9B,
LFM3 1.7B, LFM3 VL 2B y LFM3 Omni 2B.

**Por qué**: Lo pidió el usuario, que eligió los modelos que sigue usando. Sus pesos, manifiestos y lanzadores
siguen en `D:\LLM` y en `config/catalog.psd1`; solo dejan de aparecer en los clientes.

**Dónde**: `AGENTS.md` (excepción en «Propagación a clientes») y `handoff.md` (comprobación de paridad). Clientes:
`dotfiles-pi`, `dotfiles-opencode` y `dotfiles-dsh`, más la configuración global de DSH y WSL.

## Validación

- Los 14 alias que quedan son idénticos a los del commit anterior en Pi y OpenCode, y en `opencode.json` solo
  cambió el catálogo local.
- Mismo conjunto de 14 alias en Pi, los dos perfiles de OpenCode y DSH (repositorio y global); YAML de DSH válido.
