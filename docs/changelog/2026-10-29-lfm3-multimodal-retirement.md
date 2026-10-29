# 2026-10-29 - Retirada de LFM3 VL, Audio y Omni

**Qué**: se eliminan `lfm3-vl-2b`, `lfm3-audio-2b` y `lfm3-omni-2b` de `experimental/lfm3`: pesos y
proyectores (unos 6,4 GB), manifiestos, lanzadores y su documentación. También se retira el alias
`lfm3-omni-2b-omni-32k` de Pi y OpenCode, en los repositorios y en los clientes activos de WSL.
`lfm3-1.7b` sigue igual, con el runtime `b11981-cuda13.4`.

**Por qué**: decisión del usuario tras probarlos (también como transcriptor y resumidor de audios, que
se descartaron): sus resultados no compensan.

**Se conserva**: el historial de los manifiestos y lanzadores en git de `local-inference-setup` (commit
`f2e4083`), los registros de validación y las muestras de audio en `experimental/lfm3/logs/` (sin
espejar), y la corrección de `Test-Llm.ps1` que solo envía la imagen de prueba a servidores con visión.
