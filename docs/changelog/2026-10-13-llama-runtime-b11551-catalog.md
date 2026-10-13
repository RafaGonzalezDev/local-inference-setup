# 2026-10-13 - Runtime del catálogo a b11551

**Qué**: Los 30 lanzadores del catálogo pasan a apuntar a
`runtimes\llama.cpp\b11551-cuda13.4`. `b11269-cuda13.4` permanece instalado y
sigue siendo instalable con `-Version b11269`; el valor por defecto de
`Install-LlamaRuntime.ps1` pasa a `b11551`.

**Dónde**: los 30 `scripts/models/**/start-*.cmd`,
`scripts/setup/Install-LlamaRuntime.ps1`, `README.md`,
`docs/overview/inference-backend.md`, `AGENTS.md` y la sección Dependencias de
las tarjetas de modelo.

**Por qué**: MiniCPM-V 4.7 necesita `b11551` —el soporte se fusionó después de
`b11269` (PR #29416: clave `rope.section_order` y tensor `v.tok_embd_sep`)— y
mantener dos runtimes en uso obliga a recordar qué perfil usa cuál. La
comparación A/B, mismo perfil y mismos argumentos
(`qwen3.6-35b-a3b/agentic-auto-131k-2048`, prompt de 728 tokens, 200 de salida),
da la misma colocación de `--fit` (41 entradas de capa, `n_part=21`) y la misma
caché KV, 26–32 MiB más de búfer de cómputo, prefill de 1.060,75 a 1.361,46 t/s
(+28 %) y decode de 70,04 a 68,91 t/s (dentro del ruido); la carga hasta asignar
la caché KV baja de 16,1 s a 6,6 s.

## Estado

- El cambio es solo la ruta del ejecutable: ningún argumento de perfil, alias,
  contexto ni lote cambia.
- Los dos paquetes comparten el mismo archivo `cudart` y el toolkit 13.4.
- Revertir es editar una línea `SERVER` por lanzador, o reinstalar `b11269`.
- Los 30 lanzadores usan únicamente flags y valores presentes en el `--help` de
  `b11551` (`auto`, `on`, `none`, `xhigh`, `q8_0` incluidos).

## Validación

- `Test-Llm.ps1 -ConfigurationOnly -RequireInstalledFiles` sin filtros: 30
  lanzadores, 0 fallos, todos resolviendo el ejecutable de `b11551`.
- Prueba funcional: el barrido completo de perfiles se detuvo por decisión del
  usuario. Antes de detenerlo pasaron con `b11551` los smokes de
  `gemma-4-12b-v2/text-auto`, `gemma-4-12b-v2/vision-auto`,
  `gemma-4-26b-a4b/agentic-auto` y `gemma-4-26b-a4b/agentic-auto-vision`. El
  resto de perfiles no se ha re-ejecutado con el runtime nuevo.
- Las tablas de calibración de las tarjetas de modelo siguen siendo mediciones
  hechas con `b11269`; no se han repetido.
