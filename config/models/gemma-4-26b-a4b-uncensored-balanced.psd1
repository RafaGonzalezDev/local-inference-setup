@{
    SchemaVersion = 2
    Id = 'gemma-4-26b-a4b-uncensored-balanced'
    DisplayName = 'Gemma 4 26B A4B Uncensored Balanced'
    RelativeDirectory = 'models\gemma-4-26b-a4b-uncensored-balanced'
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
        @{
            File = 'mmproj-Gemma4-26B-A4B-QAT-Uncensored-HauhauCS-Balanced-BF16.gguf'
            RemoteFile = 'mmproj-Gemma4-26B-A4B-QAT-Uncensored-HauhauCS-Balanced-BF16.gguf'
            Size = 1194827776
            Sha256 = 'b5346e5bfd906f5e16878c2d0b8243e948ca7410fa28ea35be9b0c54a0ac10b7'
            Repository = 'HauhauCS/Gemma4-26B-A4B-QAT-Uncensored-HauhauCS-Balanced-MTP'
            Revision = 'f9093662a2e7ae0503f637088bc96f77a1a70c83'
        }
    )
}
