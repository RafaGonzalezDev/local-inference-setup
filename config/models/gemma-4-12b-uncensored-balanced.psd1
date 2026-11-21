@{
    SchemaVersion = 2
    Id = 'gemma-4-12b-uncensored-balanced'
    DisplayName = 'Gemma 4 12B Uncensored Balanced'
    RelativeDirectory = 'models\gemma-4-12b-uncensored-balanced'
    DeferredInference = $false
    Artifacts = @(
        @{
            File = 'Gemma4-12B-QAT-Uncensored-HauhauCS-Balanced-Q4_K_M.gguf'
            RemoteFile = 'Gemma4-12B-QAT-Uncensored-HauhauCS-Balanced-Q4_K_M.gguf'
            Size = 7381381760
            Sha256 = '59656d7494d6376ca97e9e20b64ea2e16cd97f12ec6d47bfccba91cb785b5134'
            Repository = 'HauhauCS/Gemma4-12B-QAT-Uncensored-HauhauCS-Balanced'
            Revision = 'ae8045ac2bd216293ca49a3065da2c942dde4b68'
        }
        @{
            File = 'mmproj-Gemma4-12B-QAT-Uncensored-HauhauCS-Balanced-BF16.gguf'
            RemoteFile = 'mmproj-Gemma4-12B-QAT-Uncensored-HauhauCS-Balanced-BF16.gguf'
            Size = 175115264
            Sha256 = 'b59e815479b7e5f0665bd29e6784c104a368092bcbc63120148c606f9276ab8e'
            Repository = 'HauhauCS/Gemma4-12B-QAT-Uncensored-HauhauCS-Balanced'
            Revision = 'ae8045ac2bd216293ca49a3065da2c942dde4b68'
        }
        @{
            File = 'mtp-gemma-4-12B-it.gguf'
            RemoteFile = 'mtp-gemma-4-12B-it.gguf'
            Size = 253707328
            Sha256 = 'c50c91c35f04903815b2e8930cbb8c8c5bee0e1aa00748c30a7b8ff05d2310b4'
            Repository = 'HauhauCS/Gemma4-12B-QAT-Uncensored-HauhauCS-Balanced'
            Revision = 'ae8045ac2bd216293ca49a3065da2c942dde4b68'
        }
    )
}
