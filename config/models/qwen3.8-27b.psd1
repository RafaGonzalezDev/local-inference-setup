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
            Sha256 = 'TODO-VERIFY'
            Repository = 'unsloth/Qwen3.8-27B-GGUF'
            Revision = 'main'
        }
        @{
            File = 'mmproj-F16.gguf'
            RemoteFile = 'mmproj-F16.gguf'
            Size = 550502400
            Sha256 = 'TODO-VERIFY'
            Repository = 'unsloth/Qwen3.8-27B-GGUF'
            Revision = 'main'
        }
        @{
            File = 'MTP\mtp-Qwen3.8-27B-Q4_0.gguf'
            RemoteFile = 'mtp-Qwen3.8-27B-Q4_0.gguf'
            Size = 1470184448
            Sha256 = 'TODO-VERIFY'
            Repository = 'unsloth/Qwen3.8-27B-GGUF'
            Revision = 'main'
        }
    )
}
