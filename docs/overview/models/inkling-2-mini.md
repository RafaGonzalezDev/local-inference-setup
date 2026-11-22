# inkling-2-mini (maya-ik2)

> **Retirado el 2026-11-22** a petición del usuario: se borraron los pesos, el runtime `runtimes/maya-ik2/`, el
> subárbol `maya/` y los alias de Pi, OpenCode y DSH. Ver el
> [changelog](../../changelog/2026-11-22-inkling-2-mini-removal.md). El resto de la ficha es histórico.

Inkling 2 Mini de Thinking Machines (26B MoE en bucle: 24 capas de pesos, las 6 a 17 recorridas 3 veces, 48 visitas
por token; 128 expertos, 8 activos; 40 visitas con ventana deslizante de 1.024 y 8 con atención completa; contexto
nativo 1.048.576). Servido por `maya-ik2`, no por llama.cpp. Solo texto. Instalación y uso en
[maya/README.md](../../../maya/README.md).

## Procedencia

| Artefacto | Dato |
| --- | --- |
| Repositorio | [unsloth/Inkling-2-Mini-GGUF](https://huggingface.co/unsloth/Inkling-2-Mini-GGUF), revisión `ae9327c5fbc7333116ba32eee78bb5d2bbefae4f` |
| Archivo | `Inkling-2-Mini-UD-Q4_K_XL.gguf` (raíz, disposición en bucle de Unsloth; no `Mainline_Support/`) |
| Tamaño | 17.629.759.456 bytes |
| SHA-256 | `e62d463c135ffe283df8d94b279a96ca145ac128b52ce854478613045bf4de15` (LFS de Hugging Face) |
| Licencia | Apache 2.0 (pesos); MIT (motor) |
| Motor | [alesha-pro/maya-inkling-mini](https://github.com/alesha-pro/maya-inkling-mini) commit `e819852f822479af783638a467bfdfe2ed6882ec` |

`maya-ik2` solo lee `UD-Q4_K_XL`. Los expertos de las capas 0 a 19 son NVFP4 de Thinking Machines; los de 20 a 23,
Q8_0.

## Runtime compilado

- Directorio: `runtimes/maya-ik2/e819852-cuda13.4/`; compilación registrada en
  `logs/validation/build-maya-ik2-e819852-20261122.log`.
- Toolchain: MSVC 19.44.35222 (VS 2022 Build Tools), CMake 3.31.6-msvc6, Ninja, CUDA 13.4.59, `sm_120`,
  CPU con AVX-512 (`STRATA_PORTABLE=OFF`).
- SHA-256: `maya-ik2.exe` `f1db9c231a0bbb3c2d78371a0c866a4bfc0b5c11caec30bfc69f7a2d06c86053`;
  `cublas64_13.dll` `1119dbca0a808e0c8850bb4221e330daf0b5ddb348d62d37b6ac533854723df9`;
  `cublasLt64_13.dll` `0f5bc315fef706b5626248ebd74e8a48a9e82fa2f0cad38330f5f70984913107` (copiadas de CUDA 13.4).
- Python 3.14 en `.venv` propio; tokenizador generado con `--check` (16 cadenas de ida y vuelta, 0 fallos).

## Perfil

| Lanzador | Contexto | Modelo en la API (`model_name`) | Puerto |
| --- | ---: | --- | --- |
| `start-text-131k.cmd` | 131.072 | `inkling-2-mini-131k` | `0.0.0.0:8080` |
| `start-text-262k.cmd` | 262.144 | `inkling-2-mini-262k` | `0.0.0.0:8080` |

El servidor anuncia un único nombre por perfil, así que `model_name` es el alias de perfil (el que usan los
clientes), no el ID canónico. Configuración del motor (`text-131k.json`, `text-262k.json`) y su motivo:

- `--max-context`: 262.144, el contexto pedido por el usuario; 131.072 deja más VRAM a la caché de expertos.
  `--threads 6`, como los perfiles de llama.cpp.
- `IK2_KV=fp8`: la caché KV de las 8 visitas globales ocupa 16 KB por token (4 GiB a 262K) frente al doble en FP16.
- `IK2_DENSE=q8`: pesos densos como bloques Q8_0 del GGUF, la mitad de VRAM que la copia FP16.
- `IK2_ROOM_MIB=1024`: margen libre junto a la caché de expertos, equivalente a `--fit-target 1024`; el motor
  dimensiona la caché con el resto de la VRAM libre al arrancar.
- `IK2_GATE_TILE=64`, `IK2_GATE_BF16=1`, `IK2_Q8_UNROLL=1`, `IK2_BATCH_PREFILL=1`: los de las configuraciones del
  autor.
- Muestreo y razonamiento: los predeterminados del servidor para Inkling (temperatura 1.0, top_p 1.0, esfuerzo
  `auto` de la plantilla, presupuesto de razonamiento 32.768), que coinciden con la recomendación de Unsloth.
- `MAYA_UPDATE_CHECK=0` en el lanzador: el panel no busca código nuevo; el runtime queda en su commit.

## Limitaciones conocidas

- Los 14,7 GiB de expertos no caben en 16 GB con 262K: se usa la caché de expertos en VRAM con el resto en RAM
  fija. La ruta residente (125 tok/s del autor en una RTX 3090) no aplica aquí.
- En Windows con MSVC el carril de CPU (`IK2_CPU`) está desactivado en el código (`ik2::cpu::available()` solo
  detecta AVX-512 con GCC/Clang): los expertos que fallan en la caché se copian por PCIe 5.0.
- Sin borrador DSpark ni visión en este perfil. Una petición a la vez.
- La prueba con llama.cpp del 2026-11-20 (build 12600, `UD-Q4_K_M`, ya retirados) dio 45,6 tok/s a 65K y unos
  9 tok/s a 131K con batch 1024; logs en `logs/validation/calibration-inkling-2-mini-*`.

## Pruebas

Calibración del 2026-11-22 con `start-text-262k.cmd` (escritorio con 1,7 GB de VRAM ocupada antes de cargar);
datos en `logs/validation/calibration-inkling-2-mini-maya-20261122/`:

| Medida | Resultado |
| --- | --- |
| Carga hasta `/health` | unos 5 s; `/v1/models`: `inkling-2-mini`, 262.144 tokens, solo texto |
| VRAM | 15.603 MiB de pico en todo el sistema (de 16.303); estable durante prefill y generación |
| RAM libre mínima | 31.002 MiB |
| Generación, prompt corto (800 tokens) | 35,9–41,6 tok/s; pico 43,8 |
| Prefill de 76.019 tokens | 1.252 tok/s (60,7 s); generación después 28,6 tok/s (19 tokens) |
| Prefill de 203.659 tokens | 1.114 tok/s (182,8 s); generación después 27,4 tok/s (197 tokens) |
| Dato escondido en el prompt largo | encontrado a 76K y a 204K |
| Tool calling | `get_weather` y `read_file` con argumentos correctos con esfuerzo none, medium y high |
| `reasoning_effort` | `none` responde sin razonar (0 palabras); low, high y el valor por defecto razonan |

- El motor avisa de que con 14,6 GiB libres no puede tener todos los expertos en VRAM; no expone el tamaño de la
  caché ni la tasa de aciertos por la API.
- La tarjeta enlaza a PCIe 4.0 x16 (`/metrics`), no 5.0. Durante la generación copia 3–15 GB/s de expertos, con la
  GPU al 70 % y unos 95 W: el límite es el bus.
- Frente a llama.cpp (2026-11-20): algo más lento con contexto corto (45,6 tok/s en su perfil de 65K) y mucho más
  rápido en contexto largo (9 tok/s a 131K en llama.cpp; prefill de 330 frente a 1.252 tok/s).
- La placa (MSI B650 GAMING PLUS WIFI) solo ofrece PCIe 4.0 x16 en la ranura de la GPU; la RTX 5080 admite 5.0.
- Perfil de 131K (prueba rápida): `/health` y `/v1/models` con `inkling-2-mini-131k`; 42–45 tok/s en dos
  generaciones de 800 tokens con prompt corto (frente a 36–42 a 262K), 15,5 GB de VRAM. Sin prueba de contexto
  largo ni tool calling en este perfil.
- 2026-11-22: tras probarlo desde Pi, el usuario lo adoptó. Los dos perfiles se registraron en Pi, OpenCode y DSH
  (`Inkling-2-Mini-131K` / `-262K`; DSH `Inkling 2 Mini Local · 131K` / `· 262K`), con el mapa de esfuerzo de Tiel y
  sin campo de presupuesto, que `maya-ik2` no lee.
- En Pi tiende a editar ficheros con `bash` (`python3 - <<EOF`, `sed`) en lugar de `edit`/`write`. Hipótesis: lo
  entrenaron con entornos solo de bash (sus cifras de SWE-bench son "bash only"). Sin corregir; una instrucción en
  `AGENTS.md` del proyecto es la mitigación candidata.
- 2026-11-22: en Pi el modelo agotó dos veces los 24.576 tokens razonando (no era un bucle: el detector marcó 0).
  Se añadió `"thinking_budget": 8192` (como `--reasoning-budget 8192` de llama.cpp) y `"fit_max_tokens": true` a
  ambos perfiles, y en Pi el mapa de esfuerzo de Tiel (`high` -> `xhigh`, `minimal` -> `low`) con `maxTokens` 24.576
  (131K) y 32.768 (262K). **El presupuesto no tiene efecto con Inkling**: con `xhigh` siguió razonando hasta el
  límite de 14.000 tokens y el servidor no anuncia presupuesto al arrancar (el código solo lo aplica si conoce el
  token que cierra el razonamiento). Queda solo el límite de `maxTokens`.
- Los ficheros no se ven en tiempo real en Pi: `InklingRewriter` (`serve/frontend.py`) retiene cada llamada a
  herramienta hasta cerrarla para poder reparar su JSON, así que los argumentos llegan enteros al final.

## Revisión periódica del motor

El runtime está fijado en el commit `e819852` de
[alesha-pro/maya-inkling-mini](https://github.com/alesha-pro/maya-inkling-mini), un repositorio que cambia a
diario y que se ofrece a [mw00/project-maya](https://github.com/mw00/project-maya) en la PR #1095. En cada revisión
del despliegue, compara el commit fijado con ambos (`git log e819852..origin/main` y las notas de versión de Project
Maya) y valora traer mejoras, sobre todo:

- **Streaming de llamadas a herramientas de Inkling**: `InklingRewriter` (`serve/frontend.py`) retiene cada llamada
  hasta cerrarla; podría emitir los argumentos tras `"args":{` y conservar la reparación del envoltorio.
- **Presupuesto de razonamiento**: `thinking_budget` no tiene efecto con Inkling en este commit.
- **Carril de CPU en Windows**: `ik2::cpu::available()` solo detecta AVX-512 con GCC/Clang; con MSVC los expertos
  que faltan siempre se copian por PCIe.
- **Rendimiento con la caché de expertos parcial** (16 GB): cualquier cambio en el reparto o en las copias.
- **Borrador DSpark** con la caché parcial, si llega a soportarse.

Un commit nuevo va en su propia carpeta `runtimes/maya-ik2/<commit>-cuda<versión>/`, con compilación, toolchain y
SHA-256 registrados, y se compara con el actual desde Pi (no solo con pruebas sintéticas) antes de mover los
lanzadores.
