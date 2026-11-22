# 2026-11-22 - Gemma 4 vuelve a los catálogos de clientes

**Qué**: Pi, OpenCode y DSH (repositorio y global), y los clientes de WSL, vuelven a registrar los 18 alias de los
cuatro modelos Gemma 4, idénticos a los de antes de la [poda](2026-11-22-client-catalog-trim.md):

- `gemma-4-26b-a4b-it-qat` (131K, 262K y visión en ambos)
- `gemma-4-12b-it-qat` (131K, 262K, MTP y visión en ambos)
- `gemma-4-12b-uncensored-balanced` (131K, 262K, MTP y visión en ambos)
- `gemma-4-e4b-it-qat` (131K y visión a 131K)

Los clientes listan 32 alias.

**Por qué**: Lo pidió el usuario, incluida la variante sin censura.

**Dónde**: `AGENTS.md` (lista de modelos registrados en «Propagación a clientes») y `handoff.md` (comprobación de
paridad). Clientes: `dotfiles-pi`, `dotfiles-opencode` y `dotfiles-dsh`, más la configuración global de DSH y WSL.

## Validación

- Las entradas se restauraron desde el commit anterior a la poda: quitar de nuevo las de Gemma reproduce exactamente
  los archivos actuales, y el diff solo contiene inserciones.
- Mismo conjunto de 32 alias en Pi, los dos perfiles de OpenCode y DSH (repositorio y global), igual a los alias
  servidos por los lanzadores de los ocho modelos registrados.
- No se arrancó ningún perfil: los lanzadores no cambiaron.
