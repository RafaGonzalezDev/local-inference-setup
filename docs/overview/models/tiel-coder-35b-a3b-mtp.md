# Tiel Coder 35B A3B MTP

- Modelo: `Tiel-Coder-35B-A3B-MTP-UD-Q4_K_XL.gguf`
- Repositorio: `peculiar-ragdoll/Tiel-Coder-35B-A3B-GGUF-MTP`
- Revisión: `bbe9e566f39e4fc9652ac66b71968289a03c520a`
- Alias API: `tiel-coder-35b-a3b-mtp`
- Arquitectura GGUF: `qwen35moe` (MoE de la familia Ornith 1.5 35B A3B, con el bloque `nextn` de MTP)

Tiel Coder es una recuantización dinámica (imatrix propia del autor, receta
estilo Unsloth Dynamic) de `ornith-ai/Ornith-1.5-35B-A3B`, con la plantilla de
chat Sharp incorporada en el propio GGUF y el cabezal MTP conservado. Licencia
MIT, heredada del modelo base. El repositorio hermano
`peculiar-ragdoll/Tiel-Coder-35B-A3B-GGUF` publica la misma escalera sin el
cabezal MTP, incorporada aquí como [`tiel-coder-35b-a3b`](tiel-coder-35b-a3b.md);
este perfil usa el repositorio `-MTP` porque el artefacto elegido lo incluye.

## Artefactos

| Cuantización | Archivo | Tamaño | SHA-256 |
| --- | --- | ---: | --- |
| `UD-Q4_K_XL` (principal) | `Tiel-Coder-35B-A3B-MTP-UD-Q4_K_XL.gguf` | 22.749.880.160 bytes | `54f46c4ce544c225122b0f066c2336f10404be7bc53b0cc94d1dbbc5e826bdc1` |
| `BF16` (mmproj) | `mmproj-BF16.gguf` | 902.822.016 bytes | `d9ce31026d1cb1f3f8d5152e2e2a014d9d2b302b6c93a7dc07bb0a0487f52837` |

Ambos artefactos se fijan a la revisión
`bbe9e566f39e4fc9652ac66b71968289a03c520a` de
`peculiar-ragdoll/Tiel-Coder-35B-A3B-GGUF-MTP`. El autor sitúa el
`UD-Q4_K_XL` en 22,7 GB y lo recomienda como punto de partida para equipos con
24–32 GB de RAM+VRAM combinadas, que es el caso de este hardware (16 GB de VRAM
más 64 GB de RAM). El artefacto principal pesa 2.623.956.640 bytes más que el
`AD-Q4_K-IQ4_XS` de `ornith-1.5-35b-a3b`.

El proyector `mmproj-BF16.gguf` es el de Ornith, pasado sin modificar y
compartido por todos los niveles de cuantización del repositorio.

## Perfiles

| Lanzador | Contexto | Batch/UBatch | Visión | MTP |
| --- | ---: | ---: | :---: | :---: |
| `start-agentic-auto-mtp-131k-1024.cmd` | 131.072 | 1.024/1.024 | no | sí, n-max 3 |
| `start-agentic-auto-mtp-262k-1024.cmd` | 262.144 | 1.024/1.024 | no | sí, n-max 3 |
| `start-agentic-auto-mtp-vision-131k-1024.cmd` | 131.072 | 1.024/1.024 | sí | sí, n-max 3 |

Los tres comparten la configuración base del entorno: ocho hilos,
`--parallel 1`, `--cache-ram 0`, Flash Attention, `--split-mode none`, caché KV
`q8_0` para claves y valores, Jinja y presupuesto de razonamiento 8.192 con
`--reasoning on`. El muestreo usa `temp 0.6`, `top-p 0.95`, `top-k 20`,
`min-p 0`, `presence-penalty 0` y `repeat-penalty 1`.

Sobre el muestreo: la tarjeta del modelo recomienda `temperature 1.0`,
`top_p 0.95`, `top_k 20` para uso general y `temperature 0.6` para coding
agentic. La tarjeta del modelo base Ornith recomienda `0.6/0.95/20` para tareas
generales y `1.0` solo para reproducir sus benchmarks. Los tres perfiles fijan
`0.6` por coherencia con los perfiles agentic ya activos de `ornith-1.5-35b-a3b`
y `qwen3.6-35b-a3b`; es un valor adaptado de esos perfiles, no una medición
propia.

## MTP

Los tres perfiles materializan `--spec-type draft-mtp --spec-draft-n-max 3`. El
repositorio elegido existe precisamente para conservar ese cabezal: sin
`--spec-type draft-mtp`, llama.cpp ignora los tensores `nextn` y el archivo
carga unos 0,4 GB de peso muerto.

La tarjeta del autor documenta dos palancas, `--spec-draft-n-max` (cuántos
tokens se borradoran por paso) y `--spec-draft-p-min` (descarta un borrador por
debajo de esa probabilidad), y publica un barrido sobre `UD-Q4_K_XL` frente a
la misma configuración sin especulación: 1,22x con `n-max 1` y `p-min 0`, 1,16x
con `n-max 3` y `p-min 0`, y 1,11x con `n-max 3` y `p-min 0,8`. Son medidas del
autor en su hardware, no nuestras, y la propia tarjeta advierte que el óptimo
depende del equipo, del nivel de cuantización y del contexto. Se materializa
`n-max 3` siguiendo el perfil MTP de `qwen3.6-35b-a3b` y se deja `p-min` en su
defecto (0). Conviene barrer ambos valores midiendo tokens por segundo, no tasa
de aceptación, antes de fijar un valor propio.

El batch y el ubatch son 1.024/1.024 en los tres perfiles, igual que en el
perfil MTP de `qwen3.6-35b-a3b` y a diferencia de los 2.048/2.048 de los
perfiles sin MTP. Los búferes de cómputo crecen con `--ubatch-size` y compiten
con los pesos por el mismo margen de `--fit-target`, así que un ubatch menor
deja más VRAM para pesos y reduce el tramo de expertos que `--fit` manda a la
CPU. Los nombres de los tres perfiles declaran ese 1.024, igual que el perfil
MTP de Qwen.

La variante sin cabezal, [`tiel-coder-35b-a3b`](tiel-coder-35b-a3b.md), es el
par de control: ambos artefactos solo se diferencian en el cabezal `nextn`, así
que comparar sus perfiles de 131k aísla el efecto completo de la especulación,
tanto su coste como su ganancia.

## Visión

El perfil de visión añade `--mmproj mmproj-BF16.gguf --image-min-tokens 1024` y
usa `--fit-target 2048` porque `--fit` no contabiliza el proyector multimodal.
La tarjeta de Ornith 1.5 35B en este repositorio documenta 1.024 como mínimo
exigido por la tarjeta del modelo base, mientras que el perfil de visión de
`qwen3.6-35b-a3b` usa 2.048. La tarjeta de Tiel Coder no fija un valor: hereda
el proyector de Ornith y solo indica que la visión funciona igual que en el
repositorio base.

## Colocación automática

Los tres perfiles declaran `--gpu-layers auto --fit on` y omiten
`--n-cpu-moe`: `--fit` coloca los pesos con `-ot` por capa en lugar de usar esa
palanca. El contexto se declara siempre, porque `--fit` solo ajusta los
argumentos no declarados y, si se omite, lo reduce al mínimo de `--fit-ctx`.

El tramo final con expertos en CPU que `--fit` resuelve en este hardware no se
ha medido para este modelo y queda pendiente. Como referencia, en
`ornith-1.5-35b-a3b` (20.125.923.520 bytes) resolvió `blk.20–39` a 131k y
`blk.19–39` a 262k; este artefacto es unos 2,6 GB mayor, de modo que cabe
esperar un tramo igual o más largo. Es una expectativa, no una medición.

## Estado

Los tres perfiles usan `0.0.0.0:8080` sin autenticación y deben ejecutarse como
alternativas. La prueba funcional la ejecuta el usuario: esta preparación no
inicia `llama-server` ni realiza inferencias. No hay lanzadores retirados para
este modelo.

## Dependencias

- `config/models/tiel-coder-35b-a3b-mtp.psd1`
- `scripts/models/tiel-coder-35b-a3b-mtp/start-agentic-auto-mtp-131k-1024.cmd`
- `scripts/models/tiel-coder-35b-a3b-mtp/start-agentic-auto-mtp-262k-1024.cmd`
- `scripts/models/tiel-coder-35b-a3b-mtp/start-agentic-auto-mtp-vision-131k-1024.cmd`
- `runtimes/llama.cpp/b11269-cuda13.4/`

## Related ADRs

- [ADR-0001: lanzadores autocontenidos](../../adr/ADR-0001-self-contained-model-launchers.md)
