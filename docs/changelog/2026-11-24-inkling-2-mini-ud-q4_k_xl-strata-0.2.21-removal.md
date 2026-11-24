# 2026-11-24 - Retirada de Inkling 2 Mini UD-Q4_K_XL y de Strata 0.2.21

**Qué**: Se retira `inkling-2-mini-ud-q4_k_xl` (vuelto el mismo día con Strata 0.2.21): pesos
`models/inkling-2-mini-ud-q4_k_xl/` (17 GB, GGUF, `mtp.safetensors` y tokenizador extraído), manifiesto, entrada del
catálogo de `strata/` y los tres lanzadores con sus JSON. Se desinstala Strata 0.2.21 (`runtimes/strata/0.2.21/`,
1,4 GB, y su instalador en `downloads/`): 0.2.20 vuelve a ser el único runtime de Strata.

Los alias `inkling-2-mini-ud-q4_k_xl-131k`, `-262k` y `-1m` salen de Pi, OpenCode y DSH (repositorio y global), del
espejo y de los clientes de WSL. Los clientes listan 33 alias. `AGENTS.md` deja de citar Inkling y Strata 0.2.21.

**Por qué**: Decisión del usuario tras probar desde Pi. Inkling generaba unos 45-50 tok/s a 262K y la mitad a 131K,
con un procesamiento del prompt muy lento. Flash-Next, apuntado un momento a 0.2.21, no pasó de 65-70 tok/s, frente
a más de 100 tok/s con 0.2.20. Se descartan por completo Strata 0.2.21 y los modelos de Inkling; ver la
[ficha](../overview/models/inkling-2-mini-ud-q4_k_xl.md).

**Se conserva**: la ficha (histórica), los changelogs y los logs de `logs/strata/`.

## Validación

- `Test-ModelIntegrity.ps1 -RootDirectory .\strata`: los 2 shards de Flash-Next.
- Los lanzadores de Flash-Next apuntan a 0.2.20 e idénticos a los del espejo.
- Paridad de alias: 33 servidos y 33 en Pi, en los dos perfiles de OpenCode y en DSH (repositorio y global).
