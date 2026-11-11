@{
    SchemaVersion = 2
    Id = 'qwen3.6-35b-a3b'
    DisplayName = 'Qwen3.6 35B A3B'
    RelativeDirectory = 'models\qwen3.6-35b-a3b'
    DeferredInference = $false
    Artifacts = @(
        @{
            File = 'Qwen3.6-35B-A3B-UD-Q4_K_XL.gguf'
            RemoteFile = 'Qwen3.6-35B-A3B-UD-Q4_K_XL.gguf'
            Size = 22853663008
            Sha256 = '55983c5a75a1ab969824077b3bb3de4146e82a9234072b48ad4e8f92ad3fe9f1'
            Repository = 'unsloth/Qwen3.6-35B-A3B-MTP-GGUF'
            Revision = '5bc3e238d916f48a861bac2f8a1990a0e9b7e98d'
        }
        @{
            File = 'mmproj-F16.gguf'
            RemoteFile = 'mmproj-F16.gguf'
            Size = 899283680
            Sha256 = '8971ee4f331ff0a4c609374f32984b3d4e6dc086c0aa35f1d637fad1829e887f'
            Repository = 'unsloth/Qwen3.6-35B-A3B-GGUF'
            Revision = 'a483e9e6cbd595906af30beda3187c2663a1118c'
        }
    )
}
