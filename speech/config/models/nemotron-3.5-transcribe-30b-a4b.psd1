@{
    SchemaVersion = 2
    Id = 'nemotron-3.5-transcribe-30b-a4b'
    DisplayName = 'Nemotron 3.5 Transcribe 30B A4B'
    # Weights live with the main catalog's models; this sub-root only owns the speech configuration.
    RelativeDirectory = '..\models\nemotron-3.5-transcribe-30b-a4b'
    DeferredInference = $false
    Artifacts = @(
        @{
            File = 'NVIDIA-Nemotron-3.5-Transcribe-30B-A4B-AD-IQ4_NL.gguf'
            RemoteFile = 'NVIDIA-Nemotron-3.5-Transcribe-30B-A4B-AD-IQ4_NL.gguf'
            Size = 19678656672
            Sha256 = '0c47d4ab6c783e7606ec03714b354fab0b2052027a7ea1991e7e2d3009c345ad'
            Repository = 'AtomicChat/NVIDIA-Nemotron-3.5-Transcribe-30B-A4B-GGUF'
            Revision = 'dbd06c5cad7a2f33c8e06be2fb3ef814dbd9aa59'
        }
        @{
            # The decoder names this file; keep its name unchanged.
            File = 'NVIDIA-Nemotron-3.5-Transcribe-30B-A4B-Encoder-F16.gguf'
            RemoteFile = 'NVIDIA-Nemotron-3.5-Transcribe-30B-A4B-Encoder-F16.gguf'
            Size = 1670410080
            Sha256 = '4221029c8a565c4a80c507ffa760c716e595acf663f9f4273ce69910050e7ba2'
            Repository = 'AtomicChat/NVIDIA-Nemotron-3.5-Transcribe-30B-A4B-GGUF'
            Revision = 'dbd06c5cad7a2f33c8e06be2fb3ef814dbd9aa59'
        }
    )
}
