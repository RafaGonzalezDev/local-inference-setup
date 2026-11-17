@{
    SchemaVersion = 2
    Id = 'gemma-4-e4b-it-qat'
    DisplayName = 'Gemma 4 E4B IT QAT'
    RelativeDirectory = 'models\gemma-4-e4b-it-qat'
    DeferredInference = $false
    Artifacts = @(
        @{
            File = 'gemma-4-E4B_q4_0-it.gguf'
            RemoteFile = 'gemma-4-E4B_q4_0-it.gguf'
            Size = 5154941280
            Sha256 = '676c35070db6dbe52f93e9c864ee0fba4eddea94b9c875d9cb10daff453fbaee'
            Repository = 'google/gemma-4-E4B-it-qat-q4_0-gguf'
            Revision = '4b4a2c1d584be7264f87aac328a1bc739ce81b6c'
        }
        @{
            File = 'gemma-4-E4B-it-mmproj.gguf'
            RemoteFile = 'gemma-4-E4B-it-mmproj.gguf'
            Size = 991552256
            Sha256 = '7498a37cb619e55f2fcf87eb931f56e99389ed6d432e4c5c66110694c0d65578'
            Repository = 'google/gemma-4-E4B-it-qat-q4_0-gguf'
            Revision = '4b4a2c1d584be7264f87aac328a1bc739ce81b6c'
        }
    )
}
