# ADR-0001: Self-Contained Model Launchers

- Status: accepted
- Date: 2026-08-07

## Context

The `.cmd` launchers delegated to `Start-Llm.ps1`, which combined values from
runtime, model, and profile manifests. The design avoided duplication, but
prevented knowing the effective command by inspecting a model's shortcut.
Modifying a profile required understanding the precedence of three layers.

## Options Considered

1. Maintain legacy manifests and the common engine. Optimizes DRY and global
   changes, but preserves opacity.
2. Declare all arguments in each `.cmd` and reuse a helper only for
   process, PID, and logs. Improves visibility, but maintains a common dependency.
3. Invoke `llama-server.exe` directly from each `.cmd`. Maximizes
   transparency and local editing at the cost of duplication.

## Decision

Adopt the third option. Each profile materializes runtime, model, and all its
flags in a single `.cmd`. Manifests are limited to catalog, download, and
integrity metadata. `Test-Llm.ps1` validates launchers, but does not participate
in normal execution.

DRY is deliberately relaxed for launch configuration. Each file maintains a
single responsibility: describe and execute an observable profile.

## Consequences

- A user can inspect and edit the effective command in a single file.
- Paths and values do not depend on precedence or inherited values.
- Global changes must be applied and validated across all catalog profiles.
- The managed PID, background startup, and generic overrides are retired.
- Interactive stop is performed with `Ctrl+C`.
- Argument group names are an internal contract of `Test-Llm.ps1`.
