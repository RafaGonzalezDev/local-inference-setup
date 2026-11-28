# inkling-2-mini-gsq-rco-iq3_s (Strata)

Inkling 2 Mini de Thinking Machines (transformer en bucle de 24 capas, las 12 centrales recorridas tres veces; MoE de
128 expertos, 8 activos por token; 26,2B parámetros, 3,4B activos; contexto nativo de 1M) en el GGUF GSQ-RCO IQ3_S
de IST Austria DASLab, con el borrador DFlash 2. Servido por el motor `strata-inkling` de Strata 0.2.23, no por
llama.cpp. Texto y, en los perfiles `vision`, imágenes. Instalación y uso en [strata/README.md](../../../strata/README.md).

Convive con `inkling-2-mini-nvfp4-mx8` de Basalt (ver su [ficha](inkling-2-mini-nvfp4-mx8.md)); comparten el puerto
8080, así que solo puede funcionar uno de los dos a la vez.

**Por qué vuelve Inkling a Strata.** El usuario lo pidió el 2026-11-28, tras el descarte del 2026-11-24 (ver
[UD-Q4_K_XL](inkling-2-mini-ud-q4_k_xl.md)). Strata 0.2.23 cambia el fondo de aquel descarte: añade kernels propios
para el GSQ-RCO IQ3_S («fits a single 12 GB card»), sustituye DSpark por DFlash 2 y su motor 0.1.70 es nuevo. Las
cifras de las notas de la versión son del autor y se midieron en otras tarjetas; la RTX 5080 no tiene el modo
rápido activado por defecto («slower prompt reading at 32K»).

## Procedencia

| Artefacto | Dato |
| --- | --- |
| Modelo | `Inkling-2-Mini-GSQ-RCO-IQ3_S.gguf` de [ISTA-DASLab/Inkling-2-Mini-GSQ-RCO-GGUF](https://huggingface.co/ISTA-DASLab/Inkling-2-Mini-GSQ-RCO-GGUF), revisión `357051619a8805c032e58a9976cea9bddb0832cd`; 11.425.259.648 bytes, SHA-256 `8a3515374c3cd9b65a1677b17e805bb1e32df8e98756e5f0d2fe1837d62aa4cb` |
| Borrador DFlash 2 | `Inkling-2-Mini-DFlash2-mix.safetensors` de [strata-engine/Inkling-2-Mini-DFlash2](https://huggingface.co/strata-engine/Inkling-2-Mini-DFlash2), revisión `04ecd36faef74e696f0a7b6b3c119264442a6234`, guardado como `dflash2.safetensors`; 551.600.700 bytes, SHA-256 `cf7dbb08560dfd99544af0cdbab2915406fc571f516b19aff0fe113b9458d387` |
| Lector de imágenes | `Inkling-2-Mini-Vision-v2.strata` de [strata-engine/Inkling-2-Mini-Strata](https://huggingface.co/strata-engine/Inkling-2-Mini-Strata), revisión `5623ceb47d7a01db827460ce1c23e7818a75661b`; 636.551.168 bytes, SHA-256 `34a176505276729b58744fc9ee40a5005bbff9a590d8e1f7dbe82baf33ef07d5` |
| Tokenizador | Extraído del GGUF por `strata-inkling --export-tokenizer` (plantilla de 6.868 bytes) en `strata-data/packs/inkling-2-mini-gsq-rco-iq3_s/tokenizer` |
| Licencia | Apache 2.0 (los tres repositorios; el modelo base añade la política de uso aceptable de Thinking Machines); MIT (Strata) |
| Motor | Strata 0.2.23: `strata-inkling` 0.1.70 `windows-x86_64-cuda-cuda13`, feed firmado (secuencia 138) |

Son los archivos y revisiones que fija Strata 0.2.23 en `strata_control/inkling_family.py` (`GSQ_COMMIT`,
`DFLASH2_OWN_COMMIT` con `DFLASH2_OWN_COPY = "mix"`, `STRATA_PACK_COMMIT`), contrastados con la API de Hugging Face
en esas revisiones: los SHA-256 son los del LFS, comprobados por `Download-Model.ps1` y `Test-ModelIntegrity.ps1`. El
`main` de ISTA-DASLab ya está en `f0da1097…`, con el mismo IQ3_S. La «mix» es la copia de Strata del borrador de
`incoai/Inkling-2-Mini-DFlash2` (989.975.616 bytes BF16), cuantizada de antemano (atención Q8_ROW, red feed-forward
SF4); según Strata, su aceptación queda a un 2 % de la del original. El proyector `mmproj` de ISTA-DASLab no lo lee el
motor (las imágenes pasan por el fragmento Vision), así que no se descarga.

Calidad publicada por ISTA-DASLab: conserva el 99,2 % de la media de tareas del modelo base. No se ha verificado aquí.

## Perfiles

| Lanzador | Contexto | Modelo en la API (`model_name`) | Expertos en VRAM / RAM | Imágenes |
| --- | ---: | --- | --- | --- |
| `start-text-131k.cmd` | 131.072 | `inkling-2-mini-gsq-rco-iq3_s-131k` | 8,03 / 0,84 GB | No |
| `start-text-262k.cmd` | 262.144 | `inkling-2-mini-gsq-rco-iq3_s-262k` | 7,54 / 1,34 GB | No |
| `start-vision-131k.cmd` | 131.072 | `inkling-2-mini-gsq-rco-iq3_s-vision-131k` | 7,45 / 1,43 GB | Sí (CPU) |
| `start-vision-262k.cmd` | 262.144 | `inkling-2-mini-gsq-rco-iq3_s-vision-262k` | 6,94 / 1,93 GB | Sí (CPU) |

Todos en `0.0.0.0:8080`, con `"parallel": 1`.

- Contextos y visión elegidos por el usuario (2026-11-28): texto y visión a 131K y 262K.
- JSON: el reparto de expertos y los argumentos son los que escribe `strata install` de 0.2.23 para este equipo en
  cada contexto y elección de visión (`--native`, `--max-context`, `--vision`, `--vram-experts-gb`,
  `--ram-experts-gb`), con `model_name`, `log` y `drafting` cambiados. El reparto depende de la VRAM libre al instalar
  (con unos 2 GB ocupados por el escritorio); sin medir bajo carga.
- **Borrador: `"drafting": "dflash2"`.** El instalador escribe `"auto"`, que solo mide `strata launch`
  (`strata_cli/launch/runner.py`); `serve/server.py`, el que ejecutan estos lanzadores, arranca con `--draft off`
  mientras no haya una medición (`inkling_kind.wants_drafter`). Con `dflash2`, el servidor pasa
  `--draft dflash2 --draft-beam 1 --draft-adapt` (comprobado con `inkling_kind.engine_args` y el `--info` del motor);
  `--draft-adapt` apaga el borrador 40 pasos de una petición cuando la ganancia medida baja de 0,93. Las notas de la
  versión advierten de que DFlash 2 puede ir más lento en algunos tipos de prompt y que Strata no lo activa por
  defecto si parte del modelo queda en RAM, como aquí. Si en Pi va peor, basta con poner `"drafting": "off"` en los
  JSON (en Basalt el usuario prefirió sin borrador).
- **Visión.** El servidor de 0.2.23 elegiría el lector en la CPU para una tarjeta de 16 GB (el de GPU restaría unos
  1,1 GB de expertos). El motor CUDA 0.1.70 no declara `vision_reader` en `--info`, así que el servidor quita
  `--vision-reader cpu` y el motor lee las imágenes «como antes», que en CUDA es en la CPU
  (`serve/inkling_kind.py`, sección #7043). El servidor reduce cada imagen a 0,8 MP como máximo; una captura de 1080p
  pasa a unos 1190 x 670 y Strata estima alrededor de un minuto por imagen con su lector de CPU.
- **Razonamiento.** El mismo contrato que con 0.2.21: el servidor pasa a la plantilla el nivel de
  `reasoning_effort` de cada petición (`none` 0, `minimal` 0,1, `low` 0,2, `medium` 0,7, `high` 0,9, `xhigh`/`max`
  0,99), con `low` por defecto (`STRATA_INKLING_EFFORT`), y devuelve el razonamiento como `reasoning_content`.
- `serve --plan` no consulta el motor: muestra `--draft dflash2` a secas y, en los de visión, avisa de que el motor
  «no lee imágenes». `strata-inkling.exe --info` con el GGUF y el lector responde `images=1 spec_opts=1
  dspark_f32_widen=1`, y `engine_args` conserva `--vision`.

## Pruebas

- `Download-Model.ps1` y `Test-ModelIntegrity.ps1 -RootDirectory .\strata`: los 5 artefactos del subárbol.
- `strata install` de 0.2.23 para los cuatro perfiles (componente `strata-inkling` 0.1.70 con firma y archivos
  comprobados, prueba de arranque del motor, tokenizador extraído, `dflash2.safetensors` reconocido por su SHA-256).
- `serve --plan` de los cuatro JSON (alias, contexto, host y puerto) e `inkling_kind.engine_args` con el ejecutable
  real (`--draft dflash2 --draft-beam 1 --draft-adapt`; `--vision` en los de visión).
- Sin arranque, inferencia ni calibración: las pruebas las hace el usuario desde Pi (decisión del usuario,
  2026-11-28). Pendiente: memoria real a 262K, velocidad con y sin DFlash 2, prefill, imágenes, razonamiento por
  nivel y tool calling.
