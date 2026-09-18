# Model Management

## Recover or Download a Model

To recover a model from its pinned repository and revision:

```powershell
powershell.exe -NoProfile -ExecutionPolicy RemoteSigned `
  -File scripts\setup\Download-Model.ps1 `
  -Model gemma-4-12b-v2
```

The script resumes `.partial` downloads, checks size and SHA-256, and never silently overwrites a different artifact.

## Copy from Another Storage

Use a resumable copy without destructive synchronization. After verifying the artifact:

```powershell
& scripts\common\Test-ModelIntegrity.ps1 -Model <model-id>
```

Exit codes 0 to 7 from `robocopy` are acceptable; 8 or higher represents failure. Do not activate a profile if an artifact is missing or its hash differs.

## Validating Profiles

Static validation of all 21 launchers, without requiring installed weights:

```powershell
& scripts\common\Test-Llm.ps1 -ConfigurationOnly
```

To additionally require every runtime and launcher artifact to exist:

```powershell
& scripts\common\Test-Llm.ps1 -ConfigurationOnly -RequireInstalledFiles
```

Individual functional test:

```powershell
& scripts\common\Test-Llm.ps1 `
  -Model qwen3.6-35b-a3b `
  -Profile agentic-vision-131k-2048
```

The test waits for `/health`, makes a request of up to 16 tokens, and stops the process tree it initiated. Vision profiles reuse `tests\assets\panels-1080p.png`. These are not benchmarks.

When testing the entire catalog, models with `DeferredInference` are skipped. Use `-IncludeDeferred` or an explicit model to include them.

## Updating a Runtime

Install each version in a new immutable directory and verify its packages and
commit. Each runtime has its own installer: `Install-LlamaRuntime.ps1` for the
official `llama.cpp` and `Install-BonsaiRuntime.ps1` for the PrismML fork used by
Ternary-Bonsai 2 27B.

After updating the `SERVER` value of the affected launchers, run configuration
validation and test representative profiles before retiring the previous
version. Do not copy DLLs between runtime directories.

## Retiring a Model

1. Close any terminal serving the model.
2. Remove its launchers from `scripts\models`.
3. Remove its manifest from `config\models`.
4. Remove its identifier from `config\catalog.psd1`.
5. Update `README.md` and its documentation card.
6. Run `Test-Llm.ps1 -ConfigurationOnly`.
7. Delete GGUFs only after validating the exact scope.

Data retirement is a separate operation from script or documentation reorganization.
