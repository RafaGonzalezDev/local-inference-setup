@{
    SchemaVersion = 2
    Id = 'mimo-v2.6-distill-qwen-9b'
    DisplayName = 'MiMo V2.6 Distill Qwen 9B Q6_K'
    RelativeDirectory = 'models\mimo-v2.6-distill-qwen-9b'
    DeferredInference = $false
    Artifacts = @(
        @{
            File = 'MiMo-V2.6-Distill-Qwen-9B-Q6_K.gguf'
            RemoteFile = 'MiMo-V2.6-Distill-Qwen-9B-Q6_K.gguf'
            Size = 7793710624
            Sha256 = 'ef96d05a2ddf2cbb450d1af1ac3860ec769d3575bafa70692ee5609bda3fad7d'
            Repository = 'bartowski/MiMo-V2.6-Distill-Qwen-9B-GGUF'
            Revision = '4371da10c84fb26da3592d4cf312d24aa82b7b65'
        }
        @{
            File = 'mmproj-MiMo-V2.6-Distill-Qwen-9B-f16.gguf'
            RemoteFile = 'mmproj-MiMo-V2.6-Distill-Qwen-9B-f16.gguf'
            Size = 918166048
            Sha256 = 'ff348f3180a63188aa7285db85f550fe38acb61dd013c599eb8bad08d2cc2576'
            Repository = 'bartowski/MiMo-V2.6-Distill-Qwen-9B-GGUF'
            Revision = '4371da10c84fb26da3592d4cf312d24aa82b7b65'
        }
    )
}
