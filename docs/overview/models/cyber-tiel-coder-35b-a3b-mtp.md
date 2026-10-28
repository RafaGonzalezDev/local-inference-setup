# Cyber Tiel Coder 35B A3B MTP

- Publicador: `peculiar-ragdoll` (Hugging Face), que también publica Tiel Coder, Nail y Occult Nail
- Modelo: `Cyber-Tiel-Coder-35B-A3B-MTP-UD-Q4_K_S.gguf`
- Repositorio: `peculiar-ragdoll/Cyber-Tiel-Coder-35B-A3B-GGUF-MTP`
- Revisión: `b62212407346cb7aafcc8d2788a1844555002fd3`
- Licencia: `mit`, según la tarjeta (el modelo base es `huihui-ai/Huihui-Ornith-1.5-35B-A3B-abliterated`).
- Alias API: `cyber-tiel-coder-35b-a3b-mtp`
- Arquitectura GGUF: `qwen35moe` (la misma que Tiel Coder), contexto nativo 262.144, con el bloque
  `nextn` de MTP

CyberTiel es la variante abliterada de Tiel Coder, afinada para código y ciberseguridad: la tarjeta
la presenta con una imatrix ponderada hacia código y seguridad y la plantilla de chat de Tiel. Según la
publicación no rechaza peticiones en HarmBench (0 rechazos de 84) y sacrifica conocimiento general a
cambio de velocidad y capacidad de código; todo eso son afirmaciones del autor, no mediciones propias.
Como Occult Nail, es una build abliterada que no rechaza peticiones.

El cabezal MTP es el de Tiel Coder, injertado en el modelo abliterado (la base abliterada no trae
ninguno). La tarjeta afirma que el modelo principal verifica cada token, así que el cabezal solo
cambia la velocidad, y que acepta el 82 % de los borradores de un token en su hardware.

## Artefactos

| Cuantización | Archivo | Tamaño | SHA-256 |
| --- | --- | ---: | --- |
| `UD-Q4_K_S` (con MTP) | `Cyber-Tiel-Coder-35B-A3B-MTP-UD-Q4_K_S.gguf` | 21.282.439.488 bytes | `aa83a226a203e4427b6f1f4dc026c7827bc62a341de8c61e14412abe1044a8dd` |
| `BF16` (mmproj) | `mmproj-BF16.gguf` | 902.822.016 bytes | `d9ce31026d1cb1f3f8d5152e2e2a014d9d2b302b6c93a7dc07bb0a0487f52837` |

SHA-256 LFS de la API de Hugging Face en la revisión fijada. El proyector es el de Ornith sin cambios
y es byte a byte el mismo que el de `tiel-coder-35b-a3b-mtp`.

La cuantización la eligió el usuario. La tarjeta recomienda `UD-Q4_K_XL` (22,7 GB) como punto de
partida y describe `UD-Q4_K_S` como «tight 4-bit», útil cuando `Q4_K_M` deja poco contexto. Pesa
3,2 GB más que el `UD-IQ4_XS` que usa Tiel Coder, con 16 GB de VRAM.

## Perfiles

| Lanzador | Contexto | Batch/UBatch | Visión | MTP | Alias de perfil |
| --- | ---: | ---: | :---: | :---: | --- |
| `start-agentic-auto-mtp-131k-1024.cmd` | 131.072 | 1.024/1.024 | no | sí, n-max 3 | `cyber-tiel-coder-35b-a3b-mtp-131k` |
| `start-agentic-auto-mtp-262k-1024.cmd` | 262.144 | 1.024/1.024 | no | sí, n-max 3 | `cyber-tiel-coder-35b-a3b-mtp-262k` |
| `start-agentic-auto-131k-1024.cmd` | 131.072 | 1.024/1.024 | no | no | `cyber-tiel-coder-35b-a3b-131k` |
| `start-agentic-auto-262k-1024.cmd` | 262.144 | 1.024/1.024 | no | no | `cyber-tiel-coder-35b-a3b-262k` |
| `start-agentic-auto-vision-131k-1024.cmd` | 131.072 | 1.024/1.024 | sí | no | `cyber-tiel-coder-35b-a3b-vision-131k` |
| `start-agentic-auto-vision-262k-1024.cmd` | 262.144 | 1.024/1.024 | sí | no | `cyber-tiel-coder-35b-a3b-vision-262k` |

Los seis son copias exactas de los de `tiel-coder-35b-a3b-mtp`, a petición del usuario, cambiando solo
el modelo, el proyector y los alias: `b11669-cuda13.4`, `--fit-target 1024` (2048 en visión), caché KV
`q8_0`, `--reasoning auto`, presupuesto 8.192 y batch/ubatch 1.024/1.024.

- Muestreo `--temp 0.6 --top-p 0.95 --top-k 20 --min-p 0`, sin penalizaciones: es el de coding agentic
  de la tarjeta. Para ciberseguridad/CTF la tarjeta propone `--top-k 40 --min-p 0.05`, probado por el
  autor en Q4; no se ha aplicado.
- MTP `--spec-type draft-mtp --spec-draft-n-max 3` y `p-min` por defecto, como en el resto del
  catálogo. La tarjeta mide en su equipo `n-max 1 --spec-draft-p-min 0.0` como lo más rápido (1,21x
  frente a 1,17x con `n-max 3`) y `--spec-draft-p-min 0.5` como lo más robusto; aquí no se ha barrido.
- Presupuesto de razonamiento: la tarjeta dice que el modelo rinde mejor sin límite
  (`--reasoning-budget -1`) y que, si se limita, usa 16.384 con `--predict 32768`. Los lanzadores
  heredan los 8.192 de Tiel; se puede cambiar editando `RUNTIME_ARGS`.
- Visión: `--mmproj mmproj-BF16.gguf --image-min-tokens 1024`, como en Tiel. Los perfiles de visión
  no llevan MTP.
- Los tres perfiles sin MTP (131K, 262K y visión) usan este mismo GGUF con `MTP_ARGS` vacío. La
  tarjeta avisa de que sin `--spec-type draft-mtp` el cabezal (~0,4 GB) es peso muerto que llama.cpp
  ignora, y publica una escalera sin MTP en `peculiar-ragdoll/Cyber-Tiel-Coder-35B-A3B-GGUF`; no se
  ha descargado.
- No uses `--n-cpu-moe` con este GGUF: la tarjeta avisa de que el cabezal MTP es el bloque 40 y un
  valor de 41 lo sacaría de la GPU. Los lanzadores no lo usan; `--fit` coloca los expertos por su
  cuenta.

## Validación

Por decisión del usuario no se han probado los lanzadores ni calibrado la memoria, así que no hay
mediciones propias de este modelo.

- Descarga verificada por tamaño y SHA-256 en la revisión fijada; `Test-ModelIntegrity.ps1`.
- `Test-Llm.ps1 -ConfigurationOnly -RequireInstalledFiles` sin filtros: los 22 perfiles pasan.
- Sin verificar: arranque de cada perfil, contexto efectivo, alias servidos, inicialización del
  cabezal MTP, plantilla de razonamiento (`enable_thinking`, `reasoning_effort`), tool calling, visión,
  rendimiento, aceptación de borradores y calidad.

## Límites y no verificado

- Memoria: con 21,3 GB de pesos y 16 GB de VRAM, `--fit` descargará más expertos a la CPU que con Tiel
  Coder (18,1 GB). Es probable que el decode sea más lento y que el margen de VRAM sea menor que el
  medido para Tiel; no se ha comprobado, y en el perfil 262K aún más. Si falla o falta margen, la
  calibración mínima de [model-management](../model-management.md#minimum-memory-calibration) indica
  cómo reducir contexto o batch.
- La plantilla y el contrato de razonamiento se han supuesto iguales a los de Tiel Coder porque la
  tarjeta dice que usa la misma receta y plantilla; los clientes lo registran así.
- Los perfiles escuchan en `0.0.0.0:8080` sin autenticación: solo red privada de confianza y un
  perfil a la vez.

## Dependencias

- `config/models/cyber-tiel-coder-35b-a3b-mtp.psd1`
- `scripts/models/cyber-tiel-coder-35b-a3b-mtp/start-agentic-auto-mtp-131k-1024.cmd`
- `scripts/models/cyber-tiel-coder-35b-a3b-mtp/start-agentic-auto-mtp-262k-1024.cmd`
- `scripts/models/cyber-tiel-coder-35b-a3b-mtp/start-agentic-auto-131k-1024.cmd`
- `scripts/models/cyber-tiel-coder-35b-a3b-mtp/start-agentic-auto-262k-1024.cmd`
- `scripts/models/cyber-tiel-coder-35b-a3b-mtp/start-agentic-auto-vision-131k-1024.cmd`
- `scripts/models/cyber-tiel-coder-35b-a3b-mtp/start-agentic-auto-vision-262k-1024.cmd`
- `runtimes/llama.cpp/b11669-cuda13.4/`
