@{
    SchemaVersion = 2
    Id = 'qwen3.6-35b-a3b'
    DisplayName = 'Qwen3.6 35B A3B'
    RelativeDirectory = 'models\qwen3.6-35b-a3b'
    DeferredInference = $false
    Artifacts = @(
        @{
            File = 'Qwen3.6-35B-A3B-UD-Q4_K_M.gguf'
            RemoteFile = 'Qwen3.6-35B-A3B-UD-Q4_K_M.gguf'
            Size = 22134528992
            Sha256 = 'ac0e2c1189e055faa36eff361580e79c5bd6f8e76bffb4ce547f167d53e31a61'
            Repository = 'unsloth/Qwen3.6-35B-A3B-GGUF'
            Revision = 'a483e9e6cbd595906af30beda3187c2663a1118c'
        }
        @{
            File = 'mmproj-F16.gguf'
            RemoteFile = 'mmproj-F16.gguf'
            Size = 899283680
            Sha256 = '8971ee4f331ff0a4c609374f32984b3d4e6dc086c0aa35f1d637fad1829e887f'
            Repository = 'unsloth/Qwen3.6-35B-A3B-GGUF'
            Revision = 'a483e9e6cbd595906af30beda3187c2663a1118c'
        }
        @{
            File = 'mtp\Qwen3.6-35B-A3B-UD-Q4_K_M.gguf'
            RemoteFile = 'Qwen3.6-35B-A3B-UD-Q4_K_M.gguf'
            Size = 22663387424
            Sha256 = '0b21525e972670ed59e1812e170b27c26355381f0656ecc4e25617ece7dac58b'
            Repository = 'unsloth/Qwen3.6-35B-A3B-MTP-GGUF'
            Revision = '5bc3e238d916f48a861bac2f8a1990a0e9b7e98d'
        }
    )
}
