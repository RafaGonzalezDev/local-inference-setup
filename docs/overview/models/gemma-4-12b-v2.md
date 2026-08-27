# Gemma 4 12B v2

- Modelo: `gemma-4-12B-it-qat-UD-Q4_K_XL.gguf`
- Repositorio: `unsloth/gemma-4-12B-it-qat-GGUF`
- Revisión: `980b060c40a8539ac159e0501a3e0f66a6365af3`
- Alias API: `gemma-4-12b-v2`
- Perfiles: `text`, `vision`

Ambos perfiles conservan el contexto de 262.144 tokens, razonamiento activado,
temperatura 1,0, `top_p=0.95` y `top_k=64`. El perfil visual añade únicamente
`mmproj-F16.gguf`.

El modelo es denso: no configura CPU-MoE. La caché KV conserva F16 porque el
lanzador WSL no habilitaba cuantización por defecto. No dispone de MTP instalado.

Esta es la revisión refrescada por Unsloth en julio de 2026, con cambios de
tool calling respecto a la carga anterior.
