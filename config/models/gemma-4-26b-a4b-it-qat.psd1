@{
    SchemaVersion = 2
    Id = 'gemma-4-26b-a4b-it-qat'
    DisplayName = 'Gemma 4 26B A4B IT QAT'
    RelativeDirectory = 'models\gemma-4-26b-a4b-it-qat'
    DeferredInference = $false
    Artifacts = @(
        @{
            File = 'gemma-4-26B-A4B-it-qat-UD-Q4_K_XL.gguf'
            RemoteFile = 'gemma-4-26B-A4B-it-qat-UD-Q4_K_XL.gguf'
            Size = 14249047104
            Sha256 = 'a7c5bc715f5ff8e99a3e8901ce7d2b42b402c669bf24f7c5250747633d0f5891'
            Repository = 'unsloth/gemma-4-26B-A4B-it-qat-GGUF'
            Revision = '7b92b5b28818151e8669af2e45e88d6086f490dd'
        }
        @{
            File = 'mmproj-BF16.gguf'
            RemoteFile = 'mmproj-BF16.gguf'
            Size = 1194828256
            Sha256 = '7b06953ccdbe8cf363f47841a7afaacd2b1c2ff9a8d6b426fdec7521a6878744'
            Repository = 'unsloth/gemma-4-26B-A4B-it-qat-GGUF'
            Revision = '7b92b5b28818151e8669af2e45e88d6086f490dd'
        }
    )
}
