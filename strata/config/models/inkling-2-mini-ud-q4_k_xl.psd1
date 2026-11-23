@{
    SchemaVersion = 2
    Id = 'inkling-2-mini-ud-q4_k_xl'
    DisplayName = 'Inkling 2 Mini UD-Q4_K_XL (Unsloth GGUF on Strata)'
    # Weights live with the main catalog's models; this sub-root only owns the Strata configuration.
    RelativeDirectory = '..\models\inkling-2-mini-ud-q4_k_xl'
    DeferredInference = $false
    Artifacts = @(
        @{
            # Strata 0.2.20 pins this exact file (strata_control/inkling_family.py). Unsloth moved it to Old_Support/
            # on 2026-11-23 when it re-uploaded the root files, so it is saved under the root name Strata looks for.
            File = 'Inkling-2-Mini-UD-Q4_K_XL.gguf'
            RemoteFile = 'Old_Support/Inkling-2-Mini-UD-Q4_K_XL.gguf_file'
            Size = 17629759456
            Sha256 = 'e62d463c135ffe283df8d94b279a96ca145ac128b52ce854478613045bf4de15'
            Repository = 'unsloth/Inkling-2-Mini-GGUF'
            Revision = '8078d149286eec7193795413b9e0643da6d11fa1'
        }
        @{
            # DSpark speculative drafter in the format Strata 0.2.20 pins (the repository's "_Old" Q8_0 file).
            File = 'dspark-Inkling-2-Mini-Q8_0.gguf'
            RemoteFile = 'dspark-Inkling-2-Mini-Q8_0_Old.gguf'
            Size = 402278560
            Sha256 = '2ec78510da837e8fc3be54a14757a0c5fbd2d8d9e85a0d92853fafdf674f3773'
            Repository = 'unsloth/Inkling-2-Mini-GGUF'
            Revision = '8078d149286eec7193795413b9e0643da6d11fa1'
        }
    )
}
