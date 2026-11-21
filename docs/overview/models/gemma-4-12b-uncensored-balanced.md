# Gemma 4 12B Uncensored Balanced

- Modelo: `Gemma4-12B-QAT-Uncensored-HauhauCS-Balanced-Q4_K_M.gguf`, proyector
  `mmproj-Gemma4-12B-QAT-Uncensored-HauhauCS-Balanced-BF16.gguf` y borrador MTP `mtp-gemma-4-12B-it.gguf`
- Repositorio: `HauhauCS/Gemma4-12B-QAT-Uncensored-HauhauCS-Balanced` (variante sin rechazos de
  `google/gemma-4-12B-it`, construida desde los pesos QAT oficiales)
- Revisión: `ae8045ac2bd216293ca49a3065da2c942dde4b68` (cabeza de `main` el 2026-11-21)
- Licencia: `gemma`, sin acceso restringido
- Alias API: `gemma-4-12b-uncensored-balanced`
- Arquitectura GGUF: `gemma4` (denso de 12B, contexto nativo 262.144 según los metadatos de la API y la
  tarjeta). Entrada de texto e imagen con el proyector.

Es la contrapartida sin censura de `gemma-4-12b-it-qat` ([ficha](gemma-4-12b-it-qat.md)). La variante
**Balanced** es la que el autor recomienda: elimina los rechazos sin cambiar datos ni capacidades y razona
antes de responder. La publicación solo ofrece `Q4_K_M` (la tarjeta lo justifica por el QAT a 4 bits).

El borrador MTP lo incluye la propia publicación; según la tarjeta procede de la publicación de Unsloth, pero
no es byte a byte el mismo archivo que usa `gemma-4-12b-it-qat` (253.707.328 frente a 253.708.800 bytes y
SHA-256 distinto), así que se instala el de esta revisión.

## Artefactos

| Archivo | Tamaño | SHA-256 |
| --- | ---: | --- |
| `Gemma4-12B-QAT-Uncensored-HauhauCS-Balanced-Q4_K_M.gguf` | 7.381.381.760 bytes | `59656d7494d6376ca97e9e20b64ea2e16cd97f12ec6d47bfccba91cb785b5134` |
| `mmproj-Gemma4-12B-QAT-Uncensored-HauhauCS-Balanced-BF16.gguf` | 175.115.264 bytes | `b59e815479b7e5f0665bd29e6784c104a368092bcbc63120148c606f9276ab8e` |
| `mtp-gemma-4-12B-it.gguf` | 253.707.328 bytes | `c50c91c35f04903815b2e8930cbb8c8c5bee0e1aa00748c30a7b8ff05d2310b4` |

SHA-256 LFS de la API de Hugging Face en la revisión fijada; la descarga se verificó por tamaño y SHA-256.

## Perfiles

| Lanzador | Contexto | Batch/UBatch | Visión | MTP | Alias de perfil |
| --- | ---: | ---: | :---: | :---: | --- |
| `start-agentic-auto-131k-1024.cmd` | 131.072 | 1024/1024 | no | no | `gemma-4-12b-uncensored-balanced-131k` |
| `start-agentic-auto-262k-1024.cmd` | 262.144 | 1024/1024 | no | no | `gemma-4-12b-uncensored-balanced-262k` |
| `start-agentic-auto-mtp-131k-1024.cmd` | 131.072 | 1024/1024 | no | sí | `gemma-4-12b-uncensored-balanced-mtp-131k` |
| `start-agentic-auto-mtp-262k-1024.cmd` | 262.144 | 1024/1024 | no | sí | `gemma-4-12b-uncensored-balanced-mtp-262k` |
| `start-agentic-auto-vision-131k-2048.cmd` | 131.072 | 2048/2048 | sí | no | `gemma-4-12b-uncensored-balanced-vision-131k` |
| `start-agentic-auto-vision-262k-2048.cmd` | 262.144 | 2048/2048 | sí | no | `gemma-4-12b-uncensored-balanced-vision-262k` |

Son copia de los de `gemma-4-12b-it-qat` salvo modelo, proyector, borrador, alias y muestreo (los de texto y MTP
con batch/ubatch 1024/1024): `b12359-cuda13.5`,
`--gpu-layers auto --fit on`, `--fit-target 1024` (texto y MTP) / `2048` (visión), 6 hilos, `--cache-ram 8192`,
caché KV `q8_0`, Flash Attention, `--parallel 1`, `--split-mode none`, Jinja, `--load-mode none`, logs
compactos, `--reasoning auto` y `--reasoning-budget 8192`. MTP con la receta de borrador externo
(`--spec-draft-model ... --spec-type draft-mtp --spec-draft-n-max 4 --spec-draft-ngl auto`); los perfiles de
visión no lo llevan.

- Muestreo: `--temp 0.6 --top-p 0.9 --top-k 64 --min-p 0.05 --repeat-penalty 1.1`, los valores que la tarjeta
  recomienda para esta compilación (no los de Gemma 4 de serie, `1.0/0.95/64`), elegidos por el usuario.
- Visión: `--image-min-tokens 1120 --image-max-tokens 1120` y batch/ubatch 2048, igual que en
  `gemma-4-12b-it-qat` (ver su ficha): cada imagen usa el máximo de Gemma 4, unos 2,58 MP (4096x4096 pasa a
  1584x1584), y el ubatch debe contener la imagen entera.
- La plantilla embebida (leída de los metadatos de la API, no con `/apply-template`) lee `enable_thinking`, igual
  que la de Gemma 4 12B QAT.

## Validación

Sin pruebas funcionales por decisión del usuario (2026-11-21): no se arrancó ningún perfil. Se asumen los
resultados de `gemma-4-12b-it-qat` (misma arquitectura y tamaño, memoria pico de 11,2 a 14,3 GB, contrato de
razonamiento, tool calling y aceleración MTP), con dos diferencias no medidas: el GGUF es Q4_K_M y ocupa unos
665 MB más que el `UD-Q4_K_XL` (Q4_0) de Unsloth, y el borrador MTP es otro archivo. Los perfiles de visión
tampoco son comparables: usan 1120 tokens por imagen y ubatch 2048, sin medir en ninguno de los dos modelos.

- `Test-ModelIntegrity.ps1` y `Test-Llm.ps1 -ConfigurationOnly -RequireInstalledFiles` sin filtros (ver changelog).

## Pendiente

- Smoke, calibración bajo carga (sobre todo MTP 262K, el perfil más justo del modelo con censura), contrato de
  razonamiento, tool calling, visión, aceptación del borrador y tipos reales de la cabecera GGUF.
