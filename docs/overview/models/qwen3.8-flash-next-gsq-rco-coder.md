# qwen3.8-flash-next-gsq-rco-coder (Strata)

Qwen3.8 Flash Next Coder de ISTA-DASLab: el mismo modelo con 256 de los 512 expertos de cada capa (10 activos por
token), elegidos con RCO sobre datos de código, agentes y visión; pesos restantes a 3,5 bpw (IQ1_M en el nombre, 1,89
bpw sobre el modelo original). Servido por Strata. Solo texto. Ver [strata/README.md](../../../strata/README.md).

> **Retirado el 2026-11-22**, el mismo día de su alta: en las pruebas del usuario desde Pi (también con las
> instrucciones en inglés) dio resultados sustancialmente peores que el IQ3_XXS
> ([qwen3.8-flash-next-gsq-rco](qwen3.8-flash-next-gsq-rco.md)). Se borraron pesos, datos de Strata, lanzadores,
> manifiesto y alias de Pi. Esta ficha queda como registro; las rutas que cita ya no existen.

## Procedencia

| Artefacto | Dato |
| --- | --- |
| Repositorio | [ISTA-DASLab/Qwen3.8-Flash-Next-GSQ-RCO-Coder-GGUF](https://huggingface.co/ISTA-DASLab/Qwen3.8-Flash-Next-GSQ-RCO-Coder-GGUF), revisión `bba88856f8c3c0c9e40e45f82d05e228b814ac43` (la que fija Strata 0.2.18; actualización del 2026-10-17) |
| Shard 1 | `IQ1_M/Qwen3.8-Flash-Next-GSQ-RCO-IQ1_M-00001-of-00002.gguf`, 29.608.446.496 bytes, SHA-256 `bfa3644db4adfff072fc946c20994f2909d2cf89879d83f80a4c811d4016c211` |
| Shard 2 (tabla n-gram) | `IQ1_M/...-00002-of-00002.gguf`, 28.800.138.432 bytes, SHA-256 `316b46f3a2dbd68c900f43136ab9449f9dcc3725dfd8c794847c204bc161e113`: idéntico al del IQ3_XXS, instalado como hard link a él |
| Licencia | La tarjeta declara Apache 2.0 y dice que los pesos heredan la del modelo base |

Según la tarjeta (esfuerzo `xhigh`): SWE-bench Verified 79,20 (95,7 % del BF16) y LiveCodeBench v6 87,43 (100 %).
Es más débil fuera del código y en idiomas distintos del inglés.

## Preparación de Strata

- `strata install --family coder --model IQ1_M --gguf-dir ... --no-start` (log en
  `logs/validation/strata-qwen3.8-flash-next-coder-20261122/`) creó `strata-data/packs/coder-iq1_m` y la capa MTP
  `strata-data/mtp/rt`, convertida del checkpoint original de Qwen (las fuentes BF16 quedan en `strata-data/mtp/`,
  unos 5 GB). Usa su propio perfil de expertos (`data/expert-profile-coder.bin` del Terminal).
- `strata-data/dflash2/` contiene hard links al borrador DFlash2 del IQ3_XXS (mismo archivo para la familia).

## Perfiles

| Lanzador | Contexto | Modelo en la API (`model_name`) | Puerto |
| --- | ---: | --- | --- |
| `start-text-131k.cmd` | 131.072 | `qwen3.8-flash-next-coder-131k` | `0.0.0.0:8080` |
| `start-text-262k.cmd` | 262.144 | `qwen3.8-flash-next-coder-262k` | `0.0.0.0:8080` |

Los alias no empiezan por el ID canónico: Strata solo permite DFlash2 con el Coder cuando el `model_name` coincide
con `^qwen3\.8-flash-next-coder-` (`strata_control/drafting.py`, #5240). Con otro nombre volvería a MTP sin
avisar.

Argumentos del motor: los del instalador (`--spec 4 --spec-min-p 0.5 --mtp ...`, `--kv int8`,
`--kv-resident 32768`), comprobados con `strata serve --plan`.

## Borrador: MTP o DFlash2

Por defecto (`drafting` ausente, es decir, `auto`) Strata usa MTP con el Coder, porque no tiene cifras propias de
DFlash2 para él. El 2026-11-22 los dos JSON pasaron a `"drafting": "dflash2"` y, tras probarlo el usuario, volvieron
a MTP (sin esa clave; `serve --plan` confirma `--spec 4 --mtp ...`). Para usar DFlash2, añade
`"drafting": "dflash2",` al JSON: arranca con `--draft dflash2 --spec 6 --draft-conf 0.7`. Según el informe de #5240 (RTX 4090), DFlash2 dio un 21–37 % más de velocidad de generación
con el Coder; no medido aquí.

Primer arranque del perfil de 131K con MTP (log `logs/strata/qwen3.8-flash-next-coder-131k.log`): 25,1 GB de
expertos en RAM fija, 1,55 GiB de KV, caché de conversaciones de 6,9 GiB (dimensionada con la RAM libre), caché de
expertos de 4.007 ranuras (7,63 GiB) con 186 MiB de VRAM libres, aciertos del 81 % en generación; el usuario vio
42,6 GB de RAM ocupados en todo el sistema.

## Pendiente

- Perfil de 262K sin arrancar.
