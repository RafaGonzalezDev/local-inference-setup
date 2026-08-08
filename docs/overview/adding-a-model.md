# Adding a Model and Its Profiles

## 1. Choose an Identifier

Use a canonical identifier in lowercase, for example
`vendor-model-size-variant`. The same identifier is used in:

- `models\<model-id>`
- `config\models\<model-id>.psd1`
- `scripts\models\<model-id>`
- The `-Model` parameters for download and validation

## 2. Register the Artifacts

The manifest only contains catalog, download, and integrity metadata:

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

Mutable branches such as `main` are not accepted for a reproducible installation. The
manifest does not contain profiles or inference parameters.

## 3. Create a Self-Contained Launcher per Profile

Copy an existing launcher and keep these group names because
`Test-Llm.ps1` inspects them:

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

Materialize all effective values in the file. Do not delegate to another
launcher and do not add `%*`. For vision use `VISION_ARGS`; for MTP use
`MTP_ARGS`. If a model requires another fork, pin its executable in `SERVER`
without mixing DLLs between runtimes.

## 4. Register and Validate

1. Add the identifier to `config\catalog.psd1`.
2. Create a `start-<profile>.cmd` per profile.
3. Run `Test-ModelIntegrity.ps1 -Model <model-id>`.
4. Run `Test-Llm.ps1 -ConfigurationOnly`.
5. Test each profile with a brief request.
6. Test the common image if vision exists.
7. Confirm clean shutdown and port release.
8. Document provenance, adapted values, and limitations.
9. If using a specific runtime, also test at least one profile from the
   default runtime.

Adapted values from another model should be identified as such and should not
be presented as performance results without measurement.
