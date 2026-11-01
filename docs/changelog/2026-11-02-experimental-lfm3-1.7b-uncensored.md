# 2026-11-02 - `experimental/` con LFM3 1.7B Uncensored y asistente de terminal

**Qué**: vuelve `experimental/` como raíz aparte con `lfm3-1.7b-uncensored`
(`AtomicChat/LFM3-1.7B-Uncensored-GGUF`, `AD-Q6_K`, revisión `3ad712542eb9de349dbd28f2739b69c925cdec7d`),
un perfil solo CPU (`agentic-cpu-262k-1024`, `127.0.0.1:8081`) y `Start-Assistant.ps1`, que arranca el
modelo al abrirse, responde cada prompt con un fichero de instrucciones, copia la respuesta al
portapapeles y detiene el modelo al salir. Incluye `instructions/qwen-image-2.1.md` para escribir prompts
de Qwen Image 2.1.

**Por qué**: lo pidió el usuario. El modelo no entra en el catálogo principal ni en Pi, OpenCode o DSH, y
debe ejecutarse entero en CPU.

**Dónde**: `experimental/` (README, `config/`, `scripts/models/lfm3-1.7b-uncensored/`, `instructions/`,
`Start-Assistant.ps1`; sin espejar `models/` ni `logs/`) y `README.md`.

## Decisiones

- Reutiliza `runtimes/llama.cpp/b11981-cuda13.4` del catálogo principal mediante `%LLM_ROOT%\..`, en vez
  de copiarlo como en 2026-10-29. `Test-Llm.ps1` normaliza la ruta, así que el validador la acepta.
- `instructions/qwen-image-2.1.md` resume la skill de prompts de Qwen Image 2.1 de WSL (`~/SKILL.md`) para
  un modelo de 1,7B: solo texto a imagen, reglas numeradas y cortas, 200–300 palabras en vez de 400–500 y
  salida en un único párrafo sin JSON ni `wh_ratio`, para copiarlo directamente.
- Detalle del perfil y del asistente en [experimental/README.md](../../experimental/README.md).

## Validación

- Descarga verificada por tamaño y SHA-256; integridad 1/1 y estática con `-RequireInstalledFiles` 1/1 en
  `experimental`; estática sin filtros del catálogo principal sin cambios.
- No se lanzó el modelo, por indicación del usuario: ni smoke, ni RAM, ni velocidad, ni el flujo completo
  del asistente.
