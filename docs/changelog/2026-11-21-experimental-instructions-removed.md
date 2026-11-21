# 2026-11-21 - `experimental`: las instrucciones de Qwen Image salen del repositorio

**Qué**: se elimina `experimental/instructions/qwen-image-2.1.md`. `Start-Assistant.ps1` acepta
`-InstructionsDirectory` (por defecto `instructions\`) y `Start-Assistant.cmd` le pasa
`D:\AI\config\prompt-writer`.

**Por qué**: las instrucciones están escritas para los flujos de ComfyUI y se mueven a la instalación
de referencia (`D:\AI\config\prompt-writer\qwen-image-2.1.md`), donde se condensaron. Incluyen
contenido adulto explícito, así que, igual que el preset de restauración adulta de ComfyUI, quedan solo
en local y no se publican.

**Dónde**: `experimental/Start-Assistant.ps1`, `experimental/Start-Assistant.cmd`,
`experimental/README.md` y `experimental/instructions/qwen-image-2.1.md` (eliminado).

## Decisiones

- El asistente sigue aceptando solo ficheros que estén directamente en la carpeta indicada; una ruta con
  `..` se rechaza.
- En otra máquina hay que crear el fichero de instrucciones propio en esa carpeta.
- El fichero sigue en el historial de git: borrarlo de ahí exigiría reescribir el historial.

## Validación

- `Start-Assistant.ps1` sin errores de sintaxis. El asistente no se ha arrancado.
- `experimental` en este repositorio sigue sin reflejar cambios anteriores de `D:\LLM\experimental`
  (Occult-Nail en el asistente y en el redactor de ComfyUI, y el perfil de Gemma 4 12B); no se incluyen aquí.
