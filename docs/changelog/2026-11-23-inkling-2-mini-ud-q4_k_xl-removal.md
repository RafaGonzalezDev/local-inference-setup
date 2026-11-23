# 2026-11-23 - Retirada de Inkling 2 Mini UD-Q4_K_XL y de Strata 0.2.18 y 0.2.19

**Qué**: Se retira `inkling-2-mini-ud-q4_k_xl` (alta del mismo día): pesos `models/inkling-2-mini-ud-q4_k_xl/`
(18 GB, con el borrador DSpark y el tokenizador extraído), manifiesto, entrada del catálogo de `strata/`, los tres
lanzadores con sus JSON, el componente `strata-inkling` (`runtimes/strata/0.2.20/appdata/Local/Strata/components/shapes/`)
y su configuración de instalación. Se desinstalan también `runtimes/strata/0.2.18/` y `runtimes/strata/0.2.19/`
(0,94 GB cada uno) y sus instaladores en `downloads/`: 0.2.20 queda como único runtime de Strata.

Los alias `inkling-2-mini-ud-q4_k_xl-131k`, `-262k` y `-1m` salen de Pi, OpenCode y DSH (repositorio y global), del
espejo y de los clientes de WSL. Los clientes listan 33 alias. `AGENTS.md` deja de citar Inkling en la lista de
modelos registrados y en la etiqueta de contexto `1m`.

**Por qué**: Lo pidió el usuario. Con Strata 0.2.20 el borrador DSpark no carga desde un GGUF en CUDA (fallo de
Strata) y, sin él, el modelo generaba a menos de 20 tok/s en este equipo; ver la
[ficha](../overview/models/inkling-2-mini-ud-q4_k_xl.md). Flash-Next funciona con 0.2.20, así que las versiones
anteriores ya no hacen falta.

**Se conserva**: la ficha (histórica, con nota de retirada), los changelogs y los logs de `logs/strata/`.

## Validación

- `Test-ModelIntegrity.ps1 -RootDirectory .\strata`: los 2 shards de Flash-Next.
- `strata serve --plan` con los tres JSON de Flash-Next (131K, 200K y 262K).
- Paridad de alias: 33 servidos y 33 en Pi, en los dos perfiles de OpenCode y en DSH (repositorio y global).
