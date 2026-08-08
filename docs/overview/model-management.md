# Model Management

## Recover or Download a Model

To recover a model from its pinned repository and revision:

```powershell
powershell.exe -NoProfile -ExecutionPolicy RemoteSigned `
  -File scripts\setup\Download-Model.ps1 `
  -Model gemma-4-12b-v2
```

The script resumes `.partial` downloads, checks size and SHA-256, and never silently overwrites a different artifact.

Ternary Bonsai 27B requires the Prism runtime first:

```powershell
& scripts\setup\Install-PrismRuntime.ps1
& scripts\setup\Download-Model.ps1 -Model ternary-bonsai-27b
```

## Copy from Another Storage

Use a resumable copy without destructive synchronization. After verifying the artifact:

```powershell
& scripts\common\Test-ModelIntegrity.ps1 -Model <model-id>
```

Exit codes 0 to 7 from `robocopy` are acceptable; 8 or higher represents failure. Do not activate a profile if an artifact is missing or its hash differs.

## Validating Profiles

Static validation of all 34 launchers, without loading weights:

```powershell
& scripts\common\Test-Llm.ps1 -ConfigurationOnly
```

Individual functional test:

```powershell
& scripts\common\Test-Llm.ps1 `
  -Model qwen3.6-35b-a3b `
  -Profile vision
```

The test waits for `/health`, makes a request of up to 16 tokens, and stops the process tree it initiated. Vision profiles reuse `tests\assets\panels-1080p.png`. These are not benchmarks.

When testing the entire catalog, models with `DeferredInference` are skipped. Use `-IncludeDeferred` or an explicit model to include them.

## Updating a Runtime

Install each version in a new immutable directory and verify its packages and commit. After updating the `SERVER` value of all affected launchers, run configuration validation and test representative profiles before retiring the previous version.

Specialized runtimes remain isolated. A Prism update requires changing the three Ternary launchers and also checking at least one profile that continues using the official runtime.

## Retiring a Model

1. Close any terminal serving the model.
2. Remove its launchers from `scripts\models`.
3. Remove its manifest from `config\models`.
4. Remove its identifier from `config\catalog.psd1`.
5. Update `README.md` and its documentation card.
6. Run `Test-Llm.ps1 -ConfigurationOnly`.
7. Delete GGUFs only after validating the exact scope.

Data retirement is a separate operation from script or documentation reorganization.
