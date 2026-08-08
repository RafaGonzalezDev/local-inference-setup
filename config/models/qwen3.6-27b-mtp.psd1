@{
    SchemaVersion = 2
    Id = 'qwen3.6-27b-mtp'
    DisplayName = 'Qwen3.6 27B MTP'
    RelativeDirectory = 'models\qwen3.6-27b-mtp'
    DeferredInference = $false
    Artifacts = @(
        @{
            File = 'Qwen3.6-27B-Q4_K_M.gguf'
            RemoteFile = 'Qwen3.6-27B-Q4_K_M.gguf'
            Size = 17106773120
            Sha256 = 'a7cbd3ecc0e3f9b333edee61ae66bc87ed713c5d49587a8355814722ed329e0f'
            Repository = 'unsloth/Qwen3.6-27B-MTP-GGUF'
            Revision = '5cb35eb3dcbf52dbce5f87dbc64df6aaffadcace'
        }
        @{
            File = 'Qwen3.6-27B-IQ4_XS.gguf'
            RemoteFile = 'Qwen3.6-27B-IQ4_XS.gguf'
            Size = 15705859200
            Sha256 = '89f2c7e4f9f91d17ba9df6f0eef67cb909bc67d91cd035291be35cd88f1848ba'
            Repository = 'unsloth/Qwen3.6-27B-MTP-GGUF'
            Revision = '5cb35eb3dcbf52dbce5f87dbc64df6aaffadcace'
        }
    )
}
