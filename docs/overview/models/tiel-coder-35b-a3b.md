# Tiel Coder 35B A3B

- Modelo: `Tiel-Coder-35B-A3B-UD-Q4_K_XL.gguf`
- Repositorio: `peculiar-ragdoll/Tiel-Coder-35B-A3B-GGUF`
- Revisión: `a1ae34c609d9ef03827f373a215795f22545334c`
- Alias API: `tiel-coder-35b-a3b`
- Arquitectura GGUF: `qwen35moe` (MoE de la familia Ornith 1.5 35B A3B, sin el bloque `nextn`)

Es el mismo modelo que [`tiel-coder-35b-a3b-mtp`](tiel-coder-35b-a3b-mtp.md) sin
el cabezal de predicción multi-token: una recuantización dinámica (imatrix propia
del autor, receta estilo Unsloth Dynamic) de `ornith-ai/Ornith-1.5-35B-A3B` con
la plantilla de chat Sharp incorporada en el GGUF. Licencia MIT, heredada del
modelo base.

Las dos variantes existen porque el cabezal `nextn` solo sirve a un runtime que
haga decodificación especulativa MTP. El autor publicó esta escalera cuando el
cabezal de Ornith todavía no estaba entrenado —eliminarlo no cambiaba ninguna
salida y ahorraba un 2,4% del tamaño— y la mantiene para quien no use
especulación. El repositorio `-MTP` es, según su propia tarjeta, la elección
cuando el runtime sí la hace.

## Artefactos

| Cuantización | Archivo | Tamaño | SHA-256 |
| --- | --- | ---: | --- |
| `UD-Q4_K_XL` (principal) | `Tiel-Coder-35B-A3B-UD-Q4_K_XL.gguf` | 22.360.478.080 bytes | `9779b32f998371c66ae5e1aa9a0bc7ad946b1a36c61ea6a8eb39d523b4b19033` |
| `BF16` (mmproj) | `mmproj-BF16.gguf` | 902.822.016 bytes | `d9ce31026d1cb1f3f8d5152e2e2a014d9d2b302b6c93a7dc07bb0a0487f52837` |

Ambos artefactos se fijan a la revisión
`a1ae34c609d9ef03827f373a215795f22545334c` de
`peculiar-ragdoll/Tiel-Coder-35B-A3B-GGUF`. El proyector es byte a byte el mismo
que sirve `tiel-coder-35b-a3b-mtp`; se guarda una copia por modelo para que cada
directorio sea autocontenido.

El artefacto principal pesa 389.402.080 bytes menos que el `UD-Q4_K_XL` de la
variante MTP. Esa diferencia es el cabezal `nextn`, y es la única: el autor
confirma que la corrección del cabezal tocó solo los tensores MTP, con `lm_head`
bit a bit idéntico y el mismo multiconjunto de valores en los expertos de la
capa 39. Las dos variantes son por tanto un par limpio para comparar el efecto de
la decodificación especulativa.

## Perfiles

| Lanzador | Contexto | Batch/UBatch | Visión | MTP |
| --- | ---: | ---: | :---: | :---: |
| `start-agentic-auto-131k-2048.cmd` | 131.072 | 2.048/2.048 | no | no |
| `start-agentic-auto-262k-1024.cmd` | 262.144 | 1.024/1.024 | no | no |
| `start-agentic-auto-vision-131k-2048.cmd` | 131.072 | 2.048/2.048 | sí | no |

Los tres comparten la configuración base del entorno: ocho hilos,
`--parallel 1`, `--cache-ram 0`, Flash Attention, `--split-mode none`, caché KV
`q8_0` para claves y valores, Jinja y presupuesto de razonamiento 8.192 con
`--reasoning on`. El muestreo usa `temp 0.6`, `top-p 0.95`, `top-k 20`,
`min-p 0`, `presence-penalty 0` y `repeat-penalty 1`, igual que la variante MTP.

Los tres dejan `MTP_ARGS` vacío: estos niveles no llevan cabezal `nextn`, así que
`--spec-type draft-mtp` no tendría nada que borradorar. Son el perfil de
referencia sin especulación frente al que medir los tres de
`tiel-coder-35b-a3b-mtp`, que sí la activan con `--spec-draft-n-max 3`.

## Visión

El perfil de visión añade `--mmproj mmproj-BF16.gguf --image-min-tokens 1024` y
usa `--fit-target 2048` porque `--fit` no contabiliza el proyector multimodal.
La tarjeta de Ornith 1.5 35B en este repositorio documenta 1.024 como mínimo
exigido por la tarjeta del modelo base, mientras que el perfil de visión de
`qwen3.6-35b-a3b` usa 2.048. El proyector se sirve a precisión BF16 original en
todos los niveles de cuantización.

## Colocación automática

Los tres perfiles declaran `--gpu-layers auto --fit on` y omiten
`--n-cpu-moe`: `--fit` coloca los pesos con `-ot` por capa en lugar de usar esa
palanca. El contexto se declara siempre, porque `--fit` solo ajusta los
argumentos no declarados y, si se omite, lo reduce al mínimo de `--fit-ctx`.

El tramo final con expertos en CPU que `--fit` resuelve en este hardware no se ha
medido para este modelo y queda pendiente. Como referencia, en
`ornith-1.5-35b-a3b` (20.125.923.520 bytes) resolvió `blk.20–39` a 131k y
`blk.19–39` a 262k; este artefacto es unos 2,2 GB mayor, de modo que cabe esperar
un tramo igual o más largo. Es una expectativa, no una medición.

## Artefacto no utilizado

El repositorio publica además `mtp-Tiel-Coder-35B-A3B.gguf` (1.493.665.664
bytes), un fichero suelto de borrador que su tarjeta no documenta en ninguna
parte y que ningún lanzador de este repositorio invoca. No se declara en el
manifiesto ni se descarga. Si en el futuro se quiere probar la especulación con
modelo borrador externo, habría que determinar antes con qué `--spec-type` y con
qué `--spec-draft-model` se consume.

## Estado

Los tres perfiles usan `0.0.0.0:8080` sin autenticación y deben ejecutarse como
alternativas. La prueba funcional la ejecuta el usuario: esta preparación no
inicia `llama-server` ni realiza inferencias. No hay lanzadores retirados para
este modelo.

## Dependencias

- `config/models/tiel-coder-35b-a3b.psd1`
- `scripts/models/tiel-coder-35b-a3b/start-agentic-auto-131k-2048.cmd`
- `scripts/models/tiel-coder-35b-a3b/start-agentic-auto-262k-1024.cmd`
- `scripts/models/tiel-coder-35b-a3b/start-agentic-auto-vision-131k-2048.cmd`
- `runtimes/llama.cpp/b11269-cuda13.4/`

## Related ADRs

- [ADR-0001: lanzadores autocontenidos](../../adr/ADR-0001-self-contained-model-launchers.md)
