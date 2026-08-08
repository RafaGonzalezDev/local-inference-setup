@{
    SchemaVersion = 2
    Id = 'gemma-4-12b-v2'
    DisplayName = 'Gemma 4 12B v2'
    RelativeDirectory = 'models\gemma-4-12b-v2'
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
            File = 'mmproj-F16.gguf'
            RemoteFile = 'mmproj-F16.gguf'
            Size = 175115840
            Sha256 = 'ecc4e93128da8363b7dbf2193eab98cf1142353f52ceaa0c95c0872997aaadd3'
            Repository = 'unsloth/gemma-4-12B-it-qat-GGUF'
            Revision = '980b060c40a8539ac159e0501a3e0f66a6365af3'
        }
    )
}
