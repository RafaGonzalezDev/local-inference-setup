@{
    SchemaVersion = 2
    Id = 'qwen3.8-27b'
    DisplayName = 'Qwen3.8 27B'
    RelativeDirectory = 'models\qwen3.8-27b'
    DeferredInference = $false
    Artifacts = @(
        @{
            File = 'Qwen3.8-27B-UD-IQ3_XXS.gguf'
            RemoteFile = 'Qwen3.8-27B-UD-IQ3_XXS.gguf'
            Size = 11701041664
            Sha256 = 'c0b7c3038681ed2e3040456c1dd45f9858b6c2290bed172c70388a94874f3eee'
            Repository = 'unsloth/Qwen3.8-27B-GGUF'
            Revision = 'main'
        }
        @{
            File = 'mmproj-F16.gguf'
            RemoteFile = 'mmproj-F16.gguf'
            Size = 550502400
            Sha256 = 'cbb841a9ee0636b2ec172f5bb8df2ea8dfeb01e90fe7c6126581d662a0b4e43e'
            Repository = 'unsloth/Qwen3.8-27B-GGUF'
            Revision = 'main'
        }
        @{
            File = 'MTP\mtp-Qwen3.8-27B-Q4_0.gguf'
            RemoteFile = 'mtp-Qwen3.8-27B-Q4_0.gguf'
            Size = 1470184448
            Sha256 = '50d9ce5a6da381bbcfb31061cf73df94a90e6faf8efeddee379a9cb8f1501c6e'
            Repository = 'unsloth/Qwen3.8-27B-GGUF'
            Revision = 'main'
        }
    )
}
