# Añadir un modelo y sus perfiles

## 1. Elegir un identificador

Use un identificador canónico en minúsculas, por ejemplo
`vendor-model-size-variant`. El mismo identificador se utiliza en:

- `models\<model-id>`
- `config\models\<model-id>.psd1`
- `scripts\models\<model-id>`
- Los parámetros `-Model` de descarga y validación

## 2. Registrar los artefactos

El manifiesto solo contiene metadatos de catálogo, descarga e integridad:

```powershell
@{
    SchemaVersion = 2
    Id = 'example-model'
    DisplayName = 'Example Model'
    RelativeDirectory = 'models\example-model'
    DeferredInference = $false
    Artifacts = @(
        @{
            File = 'model.gguf'
            RemoteFile = 'model.gguf'
            Size = 123456789
            Sha256 = '<64 hexadecimal characters>'
            Repository = 'organization/repository'
            Revision = '<pinned commit>'
        }
    )
}
```

No se admiten ramas móviles como `main` para una instalación reproducible. El
manifiesto no contiene perfiles ni parámetros de inferencia.

## 3. Crear un lanzador autocontenido por perfil

Copie un lanzador existente y mantenga estos nombres de grupos porque
`Test-Llm.ps1` los inspecciona:

```bat
@echo off
setlocal
for %%I in ("%~dp0..\..\..") do set "LLM_ROOT=%%~fI"

set "SERVER=%LLM_ROOT%\runtimes\llama.cpp\<runtime>\llama-server.exe"
set "MODEL_ARGS=--model "%LLM_ROOT%\models\example-model\model.gguf""
set "PERFORMANCE_ARGS=--gpu-layers 999 --ctx-size 131072"
set "NETWORK_ARGS=--host 0.0.0.0 --port 8080 --alias example-model"
set "REASONING_ARGS=--reasoning on"
set "SAMPLING_ARGS=--temp 1 --top-p 0.95"
set "RUNTIME_ARGS=--reasoning-budget 8192"
set "VISION_ARGS="
set "MTP_ARGS="

"%SERVER%" ^
  %MODEL_ARGS% ^
  %PERFORMANCE_ARGS% ^
  %NETWORK_ARGS% ^
  %REASONING_ARGS% ^
  %SAMPLING_ARGS% ^
  %RUNTIME_ARGS% ^
  %VISION_ARGS% ^
  %MTP_ARGS%
```

Materialice todos los valores efectivos en el archivo. No delegue en otro
lanzador y no añada `%*`. Para visión use `VISION_ARGS`; para MTP use
`MTP_ARGS`. Si un modelo requiere otro fork, fije su ejecutable en `SERVER`
sin mezclar DLL entre runtimes.

## 4. Registrar y validar

1. Añada el identificador a `config\catalog.psd1`.
2. Cree un `start-<profile>.cmd` por perfil.
3. Ejecute `Test-ModelIntegrity.ps1 -Model <model-id>`.
4. Ejecute `Test-Llm.ps1 -ConfigurationOnly`.
5. Pruebe cada perfil con una petición breve.
6. Pruebe la imagen común si existe visión.
7. Confirme el cierre limpio y la liberación del puerto.
8. Documente procedencia, valores adaptados y limitaciones.
9. Si usa un runtime específico, pruebe también al menos un perfil del runtime
   predeterminado.

Los valores adaptados de otro modelo deben identificarse como tales y no deben
presentarse como resultados de rendimiento sin una medición.
