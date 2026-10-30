@{
    SchemaVersion = 2
    Id = 'flint'
    DisplayName = 'Recursive Flint 40B A2.5B'
    RelativeDirectory = 'models\flint'
    DeferredInference = $false
    Artifacts = @(
        @{
            File = 'flint-UD-Q4_K_XL.gguf'
            RemoteFile = 'flint-UD-Q4_K_XL.gguf'
            Size = 25054688704
            Sha256 = '63c2ecc461ca545134b670c660e76fa20f47240f8d39b6510bfd21c4dd6e072f'
            Repository = 'unsloth/flint-GGUF'
            Revision = '20468edfc38ab43d6914cc88b08cbecb05d0fc62'
        }
    )
}
