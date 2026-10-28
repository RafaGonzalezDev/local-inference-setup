# 2026-10-28 - Vuelta a b11551 y limpieza de runtimes

**Qué**: los 22 lanzadores vuelven a apuntar a `runtimes\llama.cpp\b11551-cuda13.4`, y
`Install-LlamaRuntime.ps1` instala `b11551` por defecto. Se eliminan el runtime
`b11669-cuda13.4` y los paquetes de `b11669` y `b11269` (este último ya no tenía runtime
instalado). Queda un solo runtime, `b11551`, con su paquete.

**Por qué**: el usuario midió, a través de Pi y con los dos modelos que probó en varias situaciones,
un rendimiento sustancialmente superior con `b11551` (decode entre 20 y 30 t/s mayor y prefill igual o
mayor). Decidió volver a él.

## Mediciones propias, que no coinciden

- **27 de octubre**, Nail 131K y MTP 131K, una ejecución por combinación y un prompt de 77.028 tokens:
  `b11669` igual o algo mejor (decode largo 53,9 a 60,1 t/s en 131K; 84,7 a 85,5 t/s en MTP).
- **28 de octubre**, Occult Nail 131K sin MTP, cuatro arranques alternando runtimes (`b11551`,
  `b11669`, `b11669`, `b11551`), dos pasadas por profundidad, caché de prompt desactivada:

| Profundidad | Runtime | Prefill (t/s) | Decode medio (t/s) | Decode mín–máx |
| --- | --- | ---: | ---: | --- |
| ~0 | `b11551` / `b11669` | n/a | 61,0 / 63,8 | 57,9–64,0 / 63,6–64,0 |
| 25K | `b11551` / `b11669` | 2.001 / 1.998 | 55,5 / 58,2 | 52,1–58,4 / 57,9–58,5 |
| 100K | `b11551` / `b11669` | 1.705 / 1.554 | 46,1 / 44,5 | 45,2–47,1 / 43,0–46,2 |

- La colocación de `--fit` es idéntica en ambos (capturada con `--log-verbosity 4`: 41 capas, 21
  desbordando, 11.704 MiB en GPU y 9.610 MiB en CPU), igual que la VRAM pico y el tiempo de carga.
- Lo único repetible fue el prefill a 100K, un 9,7 % más rápido con `b11551`. El decode quedó dentro del
  ruido (entre arranques del mismo runtime varía 3-5 t/s).
- No se reprodujo la diferencia de decode que ve el usuario en Pi. No se sabe la causa; las mediciones
  propias fueron sintéticas, de un solo modelo sin MTP, y con un proceso `node` atascado consumiendo una
  CPU lógica durante la prueba de profundidad. Registros: `logs/validation/ab-depth-20261028-025415.json`.

## Eliminado y cómo recuperarlo

- `runtimes/llama.cpp/b11669-cuda13.4` (0,70 GB), `packages/llama.cpp/b11669` y `packages/llama.cpp/b11269`
  (0,54 GB cada uno). `Install-LlamaRuntime.ps1 -Version b11669` (o `b11269`) los vuelve a instalar
  verificando SHA-256.
- Las fichas de modelo y la documentación vuelven a citar `b11551`; sus tablas de calibración ya eran
  mediciones con ese runtime.
- Nuevo criterio en `AGENTS.md`: antes de adoptar un runtime se compara con el actual en el cliente real
  del usuario (Pi), no solo con pruebas sintéticas.

## Validación

- `Test-Llm.ps1 -ConfigurationOnly -RequireInstalledFiles` sin filtros: 22 perfiles, 0 fallos, todos
  resolviendo `b11551`.
- `llama-server --version` de `b11551`: `0.6.0-dev (build 11551, commit 69f201a20)`.
