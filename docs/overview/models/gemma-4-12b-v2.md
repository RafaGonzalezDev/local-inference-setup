# Gemma 4 12B v2

- Modelo: `gemma-4-12B-it-qat-UD-Q4_K_XL.gguf`
- Repositorio: `unsloth/gemma-4-12B-it-qat-GGUF`
- Revisión: `980b060c40a8539ac159e0501a3e0f66a6365af3`
- Alias API: `gemma-4-12b-v2`
- Perfiles: `text-auto`, `vision-auto`

Ambos perfiles conservan el contexto de 262.144 tokens, razonamiento activado,
temperatura 1,0, `top_p=0.95` y `top_k=64`. El perfil visual añade únicamente
`mmproj-F16.gguf`.

El modelo es denso: no configura CPU-MoE. La caché KV conserva F16 porque el
lanzador WSL no habilitaba cuantización por defecto. No dispone de MTP instalado.

## Colocación automática

| Lanzador | Contexto | `--fit-target` | Visión |
| --- | ---: | ---: | :---: |
| `start-text-auto.cmd` | 262.144 | 1024 | no |
| `start-vision-auto.cmd` | 262.144 | 2048 | sí |

Ambos declaran contexto, muestreo, alias y puerto, y materializan
`--gpu-layers auto --fit on --fit-target 1024`, con `--fit-target 2048` en el
perfil visual porque `--fit` no contabiliza el proyector. Con 262.144 tokens,
`--fit` resuelve `-ngl -1`: el modelo cabe entero en la GPU y no descarga
ninguna capa. En este modelo la variante automática no altera la colocación;
sólo declara el objetivo de margen y permite que el runtime reduzca la descarga
si otro proceso retiene VRAM.

## Lanzadores retirados

Los perfiles manuales `text` y `vision` (`--gpu-layers 999 --fit off`) se
retiraron el 2026-09-30. Su copia de referencia bajo
`logs\reference\retired-launchers-20260930\` se eliminó el 2026-10-01.

Esta es la revisión refrescada por Unsloth en julio de 2026, con cambios de
tool calling respecto a la carga anterior.

## Dependencias

- `config/models/gemma-4-12b-v2.psd1`
- `scripts/models/gemma-4-12b-v2/start-text-auto.cmd`
- `scripts/models/gemma-4-12b-v2/start-vision-auto.cmd`
- `runtimes/llama.cpp/b11269-cuda13.4/`

## Related ADRs

- [ADR-0001: lanzadores autocontenidos](../../adr/ADR-0001-self-contained-model-launchers.md)
