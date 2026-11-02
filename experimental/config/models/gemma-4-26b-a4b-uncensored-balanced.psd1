@{
    SchemaVersion = 2
    Id = 'gemma-4-26b-a4b-uncensored-balanced'
    DisplayName = 'Gemma 4 26B A4B Uncensored Balanced'
    # Shares the GGUF installed for the main catalog instead of keeping a second copy.
    RelativeDirectory = '..\models\gemma-4-26b-a4b-uncensored-balanced'
    DeferredInference = $false
    Artifacts = @(
        @{
            File = 'Gemma4-26B-A4B-QAT-Uncensored-HauhauCS-Balanced-Q4_K_M.gguf'
            RemoteFile = 'Gemma4-26B-A4B-QAT-Uncensored-HauhauCS-Balanced-Q4_K_M.gguf'
            Size = 16796015520
            Sha256 = '3c13133469e431312fffb8b1d9c85ae42199e6bb5746ea1da84e8ddf2097d73c'
            Repository = 'HauhauCS/Gemma4-26B-A4B-QAT-Uncensored-HauhauCS-Balanced-MTP'
            Revision = 'f9093662a2e7ae0503f637088bc96f77a1a70c83'
        }
    )
}
