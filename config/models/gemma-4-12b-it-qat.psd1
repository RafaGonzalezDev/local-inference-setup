@{
    SchemaVersion = 2
    Id = 'gemma-4-12b-it-qat'
    DisplayName = 'Gemma 4 12B IT QAT'
    RelativeDirectory = 'models\gemma-4-12b-it-qat'
    DeferredInference = $false
    Artifacts = @(
        @{
            File = 'gemma-4-12B-it-qat-UD-Q4_K_XL.gguf'
            RemoteFile = 'gemma-4-12B-it-qat-UD-Q4_K_XL.gguf'
            Size = 6716356800
            Sha256 = '90fd44e29e0d7cffeb0fd00dc73cfdab9ed0b0e95306ecf7821ea634c940c370'
            Repository = 'unsloth/gemma-4-12B-it-qat-GGUF'
            Revision = '980b060c40a8539ac159e0501a3e0f66a6365af3'
        }
        @{
            File = 'mmproj-BF16.gguf'
            RemoteFile = 'mmproj-BF16.gguf'
            Size = 175115840
            Sha256 = 'dcb8103adad042b1bf99df767aaf34eb37c5a73a4a2f0417e4d7ba557e91664f'
            Repository = 'unsloth/gemma-4-12B-it-qat-GGUF'
            Revision = '980b060c40a8539ac159e0501a3e0f66a6365af3'
        }
        @{
            File = 'mtp-gemma-4-12B-it.gguf'
            RemoteFile = 'mtp-gemma-4-12B-it.gguf'
            Size = 253708800
            Sha256 = 'fcb35dea42c71333db904cee11baac525c9ef872818ee3753f6cb156f3c6f4f6'
            Repository = 'unsloth/gemma-4-12B-it-qat-GGUF'
            Revision = '980b060c40a8539ac159e0501a3e0f66a6365af3'
        }
    )
}