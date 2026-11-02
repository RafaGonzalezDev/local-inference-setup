@{
    SchemaVersion = 2
    Id = 'occult-nail-1.0-35b-a3b'
    DisplayName = 'Occult Nail 1.0 35B A3B'
    # Shares the GGUF installed for the main catalog instead of keeping a second copy.
    RelativeDirectory = '..\models\occult-nail-1.0-35b-a3b'
    DeferredInference = $true
    Artifacts = @(
        @{
            File = 'Occult-Nail-1.0-35B-A3B-UD-Q4_K_XL.gguf'
            RemoteFile = 'Occult-Nail-1.0-35B-A3B-UD-Q4_K_XL.gguf'
            Size = 22360465312
            Sha256 = '1fa938085d7c5472767e75c987a595b7bf439258f63f3fdd55ca3bc7a3eaf733'
            Repository = 'peculiar-ragdoll/Occult-Nail-1.0-35B-A3B-GGUF'
            Revision = '3fdd9b72fc54083a6c8959b259011366a0b1571b'
        }
    )
}
