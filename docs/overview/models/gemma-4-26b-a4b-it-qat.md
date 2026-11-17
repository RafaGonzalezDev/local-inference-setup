# Gemma 4 26B A4B IT QAT

- Modelo: `gemma-4-26B-A4B-it-qat-UD-Q4_K_XL.gguf` y proyector `mmproj-BF16.gguf`
- Repositorio: `unsloth/gemma-4-26B-A4B-it-qat-GGUF` (QAT oficial de `google/gemma-4-26B-A4B-it`)
- Revisión: `7b92b5b28818151e8669af2e45e88d6086f490dd` (cabeza de `main` el 2026-11-17)
- Licencia: Apache 2.0, sin acceso restringido
- Alias API: `gemma-4-26b-a4b-it-qat`
- Arquitectura GGUF: `gemma4` (MoE, 128 expertos con 8 activos, 30 capas, `embedding_length` 2816,
  `feed_forward_length` 2112, `expert_feed_forward_length` 704; atención deslizante de 1024 alternada con
  global; contexto nativo 262.144). Entrada de texto e imagen según la tarjeta de Google; el proyector solo
  tiene codificador de visión.

Sustituye el 2026-11-17 a `gemma-4-26b-a4b-uncensored-balanced` (HauhauCS) a petición del usuario: este
modelo mantiene los rechazos de Google, pero el usuario lo prefiere por su probable mejor uso de herramientas
y ya tiene otros modelos sin censura. `UD-Q4_K_XL` es la única cuantización del modelo que publica el
repositorio (más el proyector en BF16/F16/F32 y los borradores MTP).

## Cuantización

Pese al nombre, el archivo es **Q4_0 puro**: la cabecera declara `general.file_type = 2` y `general.name`
«Gemma-4 26B-A4B IT (smart Q4_0, QAT-lossless)». Tipos: Q4_0 en 266 tensores y F32 en 392, sin K-quants. Al
contrario que la Q4_K_M de HauhauCS (Q4_K/Q5_0/Q8_0/Q6_K), no hay sustituciones por dimensiones no múltiplo de
256, porque Q4_0 ya usa bloques de 32. Pesa 14,25 GB frente a los 16,80 GB de la anterior.

## Artefactos

| Archivo | Tamaño | SHA-256 |
| --- | ---: | --- |
| `gemma-4-26B-A4B-it-qat-UD-Q4_K_XL.gguf` | 14.249.047.104 bytes | `a7c5bc715f5ff8e99a3e8901ce7d2b42b402c669bf24f7c5250747633d0f5891` |
| `mmproj-BF16.gguf` | 1.194.828.256 bytes | `7b06953ccdbe8cf363f47841a7afaacd2b1c2ff9a8d6b426fdec7521a6878744` |

SHA-256 LFS de la API de Hugging Face en la revisión fijada; las descargas se verificaron por tamaño y SHA-256
(`Test-ModelIntegrity.ps1`, 2/2). El proyector es BF16, como en los demás Gemma 4 del catálogo. El borrador MTP
(`mtp-gemma-4-26B-A4B-it.gguf`, Q4_0) no se instala: el usuario pidió mantener el MTP desactivado.

## Perfiles

| Lanzador | Contexto | Batch/UBatch | Visión | Alias de perfil |
| --- | ---: | ---: | :---: | --- |
| `start-agentic-auto-131k-1024.cmd` | 131.072 | 1024/1024 | no | `gemma-4-26b-a4b-it-qat-131k` |
| `start-agentic-auto-262k-1024.cmd` | 262.144 | 1024/1024 | no | `gemma-4-26b-a4b-it-qat-262k` |
| `start-agentic-auto-vision-131k-1024.cmd` | 131.072 | 1024/1024 | sí | `gemma-4-26b-a4b-it-qat-vision-131k` |
| `start-agentic-auto-vision-262k-1024.cmd` | 262.144 | 1024/1024 | sí | `gemma-4-26b-a4b-it-qat-vision-262k` |

Copian los perfiles sin MTP de `gemma-4-12b-it-qat` salvo modelo, proyector y alias: `b12359-cuda13.5`,
`--gpu-layers auto --fit on`, `--fit-target 1024` (texto) / `2048` (visión), 6 hilos, `--cache-ram 8192`,
caché KV `q8_0`, Flash Attention, `--parallel 1`, `--split-mode none`, Jinja, `--load-mode none`, logs
compactos, `--reasoning-budget 8192` y `MTP_ARGS` vacío.

- Muestreo: `--temp 1.0 --top-p 0.95 --top-k 64`, la configuración estándar de Gemma 4 (la de HauhauCS era
  `0.6/0.9/64` con `min-p` y penalización de repetición).
- `--reasoning auto`: plantilla de Gemma 4 con `<|think|>` en el turno de sistema, como el 12B; no se
  comprobó con `/apply-template` en este GGUF.
- La visión no fija `--image-min-tokens`.

## Validación (2026-11-17)

- `Test-ModelIntegrity.ps1` (2/2) y `Test-Llm.ps1 -ConfigurationOnly -RequireInstalledFiles` sin filtros
  (46/46) pasan.
- **Sin pruebas funcionales**: el usuario pidió no ejecutar los lanzadores, porque espera resultados parecidos
  a los de la versión de HauhauCS (misma arquitectura y pesos QAT de origen). Ni arranque, ni memoria, ni
  plantilla, ni herramientas, ni visión están comprobados en este GGUF.

## Pendiente

- Smoke, calibración de memoria (la versión anterior llegaba a 15,5 GB de pico; esta pesa 2,5 GB menos),
  contrato de razonamiento, tool calling y visión.
