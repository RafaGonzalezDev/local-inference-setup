@{
    SchemaVersion = 2
    Id = 'inkling-2-mini-nvfp4-mx8'
    DisplayName = 'Inkling 2 Mini NVFP4-MX8 (Basalt)'
    # Weights live with the main catalog's models; this sub-root only owns the Basalt configuration.
    RelativeDirectory = '..\models\inkling-2-mini-nvfp4-mx8'
    DeferredInference = $false
    Artifacts = @(
        @{
            # One self-contained pack: weights, vision encoder, tokenizer, chat template and DSpark drafter.
            File = 'Inkling-2-Mini-NVFP4-MX8.basalt'
            RemoteFile = 'Inkling-2-Mini-NVFP4-MX8.basalt'
            Size = 19606374189
            Sha256 = '28ec70723feaa037942a02f55b9d5e898276f3e62a3b1fa083745f932a041b99'
            Repository = 'jesdga/Inkling-2-Mini-Basalt'
            Revision = 'c2afac3adb772e14d77b2ea2ac7068ad4460e932'
        }
    )
}
