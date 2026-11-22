@{
    SchemaVersion = 2
    Id = 'inkling-2-mini'
    DisplayName = 'Inkling 2 Mini'
    # Weights live with the main catalog's models; this sub-root only owns the maya-ik2 configuration.
    RelativeDirectory = '..\models\inkling-2-mini'
    DeferredInference = $false
    Artifacts = @(
        @{
            # Root file in Unsloth's looped layout: the only quantization maya-ik2 reads (not Mainline_Support).
            File = 'Inkling-2-Mini-UD-Q4_K_XL.gguf'
            RemoteFile = 'Inkling-2-Mini-UD-Q4_K_XL.gguf'
            Size = 17629759456
            Sha256 = 'e62d463c135ffe283df8d94b279a96ca145ac128b52ce854478613045bf4de15'
            Repository = 'unsloth/Inkling-2-Mini-GGUF'
            Revision = 'ae9327c5fbc7333116ba32eee78bb5d2bbefae4f'
        }
    )
}
