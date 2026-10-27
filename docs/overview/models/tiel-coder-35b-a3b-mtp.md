# Tiel Coder 35B A3B MTP

- Publicador: `peculiar-ragdoll` (Hugging Face), que también publica Nail y Occult Nail
- Modelo: `Tiel-Coder-35B-A3B-MTP-UD-IQ4_XS.gguf`
- Repositorio: `peculiar-ragdoll/Tiel-Coder-35B-A3B-GGUF-MTP`
- Revisión: `bb5f3f441849fc24c2d9037c310bc995404bfa0c`
- Licencia: `mit`, heredada del modelo base.
- Alias API: `tiel-coder-35b-a3b-mtp`
- Arquitectura GGUF: `qwen35moe` (MoE de la familia Ornith 1.5 35B A3B, con el bloque `nextn` de MTP)

Tiel Coder es una recuantización dinámica de `ornith-ai/Ornith-1.5-35B-A3B` hecha por
`peculiar-ragdoll` (imatrix propia, receta estilo Unsloth Dynamic), con la plantilla de chat Sharp
incorporada en el GGUF y el cabezal MTP conservado.

Desde el 2026-10-26 este ID usa `UD-IQ4_XS` en lugar de `UD-Q4_K_XL`, a petición del usuario. Se
conservan el ID y los alias para que los clientes y las selecciones guardadas sigan funcionando. La
variante sin cabezal MTP (`tiel-coder-35b-a3b`) se retiró el mismo día.

## Artefactos

| Cuantización | Archivo | Tamaño | SHA-256 |
| --- | --- | ---: | --- |
| `UD-IQ4_XS` (con MTP) | `Tiel-Coder-35B-A3B-MTP-UD-IQ4_XS.gguf` | 18.119.933.792 bytes | `96b4c5430b5a693447a0aafce58840466829e1788e46fc037b23dfbafab009bf` |
| `BF16` (mmproj) | `mmproj-BF16.gguf` | 902.822.016 bytes | `d9ce31026d1cb1f3f8d5152e2e2a014d9d2b302b6c93a7dc07bb0a0487f52837` |

SHA-256 LFS de la API de Hugging Face en la revisión fijada; ambos verificados en disco. La tarjeta
describe `UD-IQ4_XS` como el nivel de 4 bits con más margen de contexto. El proyector es el de Ornith,
sin cambios y compartido por todas las cuantizaciones; es idéntico al de la revisión anterior
`bbe9e566…`, así que se conservó la copia local.

## Perfiles

| Lanzador | Contexto | Batch/UBatch | Visión | MTP | Alias de perfil |
| --- | ---: | ---: | :---: | :---: | --- |
| `start-agentic-auto-mtp-131k-1024.cmd` | 131.072 | 1.024/1.024 | no | sí, n-max 3 | `tiel-coder-35b-a3b-mtp-131k` |
| `start-agentic-auto-mtp-262k-1024.cmd` | 262.144 | 1.024/1.024 | no | sí, n-max 3 | `tiel-coder-35b-a3b-mtp-262k` |
| `start-agentic-auto-mtp-vision-131k-1024.cmd` | 131.072 | 1.024/1.024 | sí | sí, n-max 3 | `tiel-coder-35b-a3b-mtp-vision-131k` |

Al cambiar la cuantización, los lanzadores solo cambiaron la ruta del GGUF. Mantienen la base del
entorno: `b11669`, `--fit-target 1024` (2048 en visión), caché KV `q8_0`, `--reasoning auto` y
presupuesto 8.192.

- Muestreo `temp 0.6 --top-p 0.95 --top-k 20 --min-p 0`, sin penalizaciones: la tarjeta recomienda
  `1.0/0.95/20` para uso general y `0.6` para coding agentic.
- MTP `--spec-type draft-mtp --spec-draft-n-max 3` y `p-min` por defecto. La tarjeta publica barridos
  propios de `n-max`/`p-min` en su hardware; aquí no se han barrido.
- Visión: `--mmproj mmproj-BF16.gguf --image-min-tokens 1024`, el mínimo que la tarjeta de Ornith
  exige.
- La plantilla lee `reasoning_effort` y además acepta `enable_thinking: false`.

## Validación medida (2026-10-26, `UD-IQ4_XS`)

Una ejecución por perfil, sin cambiar parámetros. `/props` confirma el contexto, `/v1/models` publica
el alias canónico y el de perfil con `ftype IQ4_XS - 4.25 bpw`, y el log muestra «creating MTP draft
context» en los tres perfiles.

| Perfil | Prompt largo | Prefill | Decode largo | Decode corto (1.024) | Borradores aceptados (corto) | VRAM pico | RAM libre mínima |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| MTP 131K | 99.544 | 2.238,33 t/s (44,5 s) | 56,75 t/s | 73,00 t/s | 603/1.259 | 15.713 MiB | 39.534 MiB |
| MTP 262K | 229.933 | 1.469,88 t/s (156,4 s) | 44,10 t/s | 61,75 t/s | 628/1.180 | 15.863 MiB | 34.914 MiB |
| MTP visión 131K | 99.544 | 1.959,48 t/s (50,8 s) | 61,74 t/s | 65,75 t/s | 635/1.159 | 15.038 MiB | 37.028 MiB |

- `nvidia-smi` y RAM libre muestreados cada ~0,8 s; el escritorio ocupaba ~1,5 GB antes de cada
  arranque. Decode largo: respuesta breve tras el prompt largo (`temperature 0`). Decode corto:
  `enable_thinking: false`, `temperature 0`.
- Tool calling en los tres perfiles: `get_weather` con `arguments {"location":"Madrid"}` y
  razonamiento separado.
- Contrato de razonamiento (131K): `enable_thinking: false` y `reasoning_effort: "none"` dejan
  `reasoning_content` vacío; `thinking_budget_tokens: 64` lo corta.
- Visión: `tests/assets/panels-1080p.png` (2.242 tokens) se describe como tres paneles rojo, verde y azul.
- No se comparó con `--spec-type none`: no hay medición de la ganancia de MTP.

## Límites y no verificado

- No se ejercitó el contexto completo (prompts de hasta 99.544 y 229.933 tokens) ni un prompt largo
  con imagen.
- No se midió la calidad de `IQ4_XS` frente a `Q4_K_XL`.
- Los perfiles escuchan en `0.0.0.0:8080` sin autenticación: solo red privada de confianza y un
  perfil a la vez.

## Dependencias

- `config/models/tiel-coder-35b-a3b-mtp.psd1`
- `scripts/models/tiel-coder-35b-a3b-mtp/*.cmd`
- `runtimes/llama.cpp/b11669-cuda13.4/`

## Related ADRs

- [ADR-0001: lanzadores autocontenidos](../../adr/ADR-0001-self-contained-model-launchers.md)
