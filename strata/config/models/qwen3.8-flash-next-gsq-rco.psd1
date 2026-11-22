@{
    SchemaVersion = 2
    Id = 'qwen3.8-flash-next-gsq-rco'
    DisplayName = 'Qwen3.8 Flash Next GSQ-RCO IQ3_XXS'
    # Weights live with the main catalog's models; this sub-root only owns the Strata configuration.
    RelativeDirectory = '..\models\qwen3.8-flash-next-gsq-rco'
    DeferredInference = $false
    Artifacts = @(
        @{
            # Shard 1: transformer weights (Strata keeps its experts in RAM and caches the hottest ones in VRAM).
            File = 'IQ3_XXS\Qwen3.8-Flash-Next-GSQ-RCO-IQ3_XXS-00001-of-00002.gguf'
            RemoteFile = 'IQ3_XXS/Qwen3.8-Flash-Next-GSQ-RCO-IQ3_XXS-00001-of-00002.gguf'
            Size = 47039860096
            Sha256 = '219ea929900dfa9ef091f3aa473fdba6874b65fcb36526d7d851ac9e95856d15'
            Repository = 'ISTA-DASLab/Qwen3.8-Flash-Next-GSQ-RCO-GGUF'
            Revision = 'ed59f92082b1e93c0e96d60a8b11aab089b52f09'
        }
        @{
            # Shard 2: the per-layer n-gram lookup table, shared by every size of this release.
            File = 'IQ3_XXS\Qwen3.8-Flash-Next-GSQ-RCO-IQ3_XXS-00002-of-00002.gguf'
            RemoteFile = 'IQ3_XXS/Qwen3.8-Flash-Next-GSQ-RCO-IQ3_XXS-00002-of-00002.gguf'
            Size = 28800138432
            Sha256 = '316b46f3a2dbd68c900f43136ab9449f9dcc3725dfd8c794847c204bc161e113'
            Repository = 'ISTA-DASLab/Qwen3.8-Flash-Next-GSQ-RCO-GGUF'
            Revision = 'ed59f92082b1e93c0e96d60a8b11aab089b52f09'
        }
    )
}
