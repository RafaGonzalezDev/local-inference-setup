# inkling-2-mini-sq-15 (Strata)

> **Retirado el 2026-11-22**, el mismo día de su alta, a petición del usuario: pesos, lanzadores, manifiesto, el
> componente `strata-inkling` y los alias de Pi se borraron. Ver «Investigación del modo híbrido» al final y el
> [changelog](../../changelog/2026-11-22-inkling-2-mini-removal.md).

Inkling 2 Mini de Thinking Machines (26,4B MoE en bucle, 3,4B activos por token; ver la
[ficha de `maya-ik2`](inkling-2-mini.md) para la arquitectura) en SQ-15, la cuantización propia de Strata. Servido por
el motor `strata-inkling` de Strata, no por llama.cpp ni por `maya-ik2`. Solo texto. Prueba preliminar, registrada
solo en Pi. Instalación y uso en [strata/README.md](../../../strata/README.md).

## Procedencia

| Artefacto | Dato |
| --- | --- |
| Repositorio | [strata-engine/Inkling-2-Mini-Strata](https://huggingface.co/strata-engine/Inkling-2-Mini-Strata), revisión `04996a1e2c45009b6a04f2af126cb6bdb2ba3587` |
| Pesos | `Inkling-2-Mini-SQ-15.strata`, 14.348.316.672 bytes, SHA-256 `2ea32eed533afba257e2cbee7b073dc2c3da80fe55d1d2d794779b5498e30737` |
| Tokenizador | `tokenizer.json`, 26.178.678 bytes, SHA-256 `7f332727f9a3f093dd452a39cc978e6757627e5dad1b0673aa4e75174f236dd6` |
| Licencia | Apache 2.0 (pesos, con la política de uso aceptable de Thinking Machines); MIT (Strata) |
| Motor | Strata 0.2.19: `strata-inkling` 0.1.65 `windows-x86_64-cuda-cuda13`, feed firmado (secuencia 131) |

Los SHA-256 del LFS de Hugging Face coinciden con los que fija Strata en `strata_control/inkling_family.py`. Los
comprobaron `Download-Model.ps1`, `Test-ModelIntegrity.ps1` y el propio instalador de Strata.

## Formato SQ-15

Formato `.strata` v1.1, sin equivalente en llama.cpp. Según `inkling_fit.py`: 2,07 GB de pesos densos (con el
borrador DSpark integrado) y 12,28 GB de expertos, unos 4,3 bits por parámetro de media. SQ-20 (19,35 GB) conserva
el formato original (SF4+MX8) y el autor lo da como idéntico al modelo original. Datos del autor para SQ-15:
coincidencia del primer token del 96,68 % y KL de 0,00889 frente al original. Sin verificar aquí: la afirmación de
que supera a `UD-Q4_K_XL` y los tipos por tensor del archivo.

## Perfiles

| Lanzador | Contexto | Modelo en la API (`model_name`) | Expertos en VRAM / RAM | Puerto |
| --- | ---: | --- | --- | --- |
| `start-text-131k.cmd` | 131.072 | `inkling-2-mini-sq-15-131k` | 9,71 / 2,57 GB | `0.0.0.0:8080` |
| `start-text-262k.cmd` | 262.144 | `inkling-2-mini-sq-15-262k` | 5,41 / 6,87 GB | `0.0.0.0:8080` |

- Los argumentos son los que escribe `strata install` para este equipo y cada contexto: `--native`,
  `--max-context`, `--vram-experts-gb` y `--ram-experts-gb`. `drafting: dspark` y `parallel: 1` (una petición a
  la vez).
- El reparto sale de una fórmula del instalador (17,1 GB de VRAM, 0,85 GB de driver y KV FP16). **No descuenta la
  VRAM que ya usa el escritorio** (unos 1,5 GiB): con la KV llena, el perfil de 131K puede quedarse sin margen, y
  Windows pasaría memoria de la GPU a la RAM, como pasó con Flash-Next antes de `--vram-reserve-mib`. Sin medir.
  El binario acepta `--vram-reserve-mib`, pero no se ha comprobado cómo convive con el reparto fijo, así que no se ha
  añadido.
- Según la fórmula de Strata, solo cabe entero en la VRAM con contexto corto (32K, su valor por defecto).
- Sin visión: el fragmento `Inkling-2-Mini-Vision.strata` (0,64 GB) no se descargó.
- **Sin razonamiento.** Strata sirve Inkling siempre con `reasoning_effort: "none"` y `enable_thinking: false`
  (`serve/inkling_dialect.py`; `HAS_THINKING = False`) y descarta cualquier bloque de razonamiento. Es la diferencia
  principal frente a `maya-ik2`, que sí razona. En Pi: `reasoning: false`, `maxTokens` 24.576 (131K) y 32.768 (262K),
  los mismos límites que los alias de `maya-ik2`.

## Pruebas

- `strata serve --plan` con los dos JSON: alias, contexto, reparto de expertos, host y puerto correctos.
- `strata-inkling.exe --info`: `build=SQ-15`, `drafter=dspark`, `images=1`, `parallel=64`.
- Sin arranque, inferencia ni calibración: las pruebas las hace el usuario desde Pi (decisión del usuario,
  2026-11-22).
- Referencia publicada más parecida a este equipo: RTX 5070 Ti de 16 GB con SQ-15, 88 tok/s con un prompt corto y
  DSpark, sin razonamiento (dato del autor). La RTX 5080 enlaza aquí a PCIe 4.0 x16.

## Investigación del modo híbrido (2026-11-22)

En Pi, la primera petición falló con `the engine stopped unexpectedly (exit code 3)`. Causa, leída en el código
fuente de `strata-inkling` v0.2.19 (`engine/src/inkling2/`):

- El backend CUDA rápido ignora `--vram-experts-gb` y `--ram-experts-gb`: carga todos los expertos en VRAM si caben
  dejando ~1,3 GiB libres (`cuda/ink_runner.cuh`), sin contar el contexto pedido, y luego recorta el contexto a lo
  que queda (131.072 → 6.400 con FP16; 262.144 → 8.832).
- El servidor valida el prompt contra el contexto pedido, no contra el recortado (`ink_serve.h`): una petición de
  más de 6.400 tokens escribe fuera del búfer de KV (CUDA error 700). Fallo de Strata.
- El backend alternativo (`ep_dual_gpu.cu`, con `--vram-reserve-mib` o `--cpu-threads`) sí aplica
  `--vram-experts-gb`, pero hace normas, mezclas y atención en la CPU, no tiene DSpark y falló con este archivo
  (`invalid argument`).
- El modo híbrido del backend rápido se puede forzar subiendo `--chunk`, que aumenta la reserva mínima.

`--bench` (KV FP8, sin DSpark; logs en `logs/validation/inkling-sq15-hybrid-20261122/`):

| Configuración | Expertos en RAM | Contexto efectivo | Prefill | Decode |
| --- | ---: | ---: | ---: | ---: |
| Todo en VRAM, 12K, prompt 8K | 0 | 12.288 | 2.546 tok/s | 79,8 tok/s |
| Híbrido `--chunk 16384`, 32K, prompt 8K | 204 (6,6 %) | 32.768 | 2.582 tok/s | 83,3 tok/s |
| Híbrido `--chunk 16384`, 65K pedido | 204 | 45.440 | 791 tok/s | 26,5 tok/s |
| Híbrido `--chunk 20480`, 65K | 303 | 65.536 | 502 tok/s | 21,6 tok/s |
| Todo en VRAM, 131K pedido, prompt 2K | 0 | 17.408 | 1.509 tok/s | 18,3 tok/s |

Unos pocos expertos en RAM no penalizan; lo que hunde la velocidad es quedarse sin margen de VRAM (Windows pagina):
el motor ajusta el contexto demasiado al límite. Con el escritorio ocupando ~1,5 GiB, el SQ-15 solo era utilizable
hasta ~32K tokens. Con eso, sin razonamiento y con Flash-Next disponible, el usuario lo retiró.
