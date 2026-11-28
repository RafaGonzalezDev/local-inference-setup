@{
    SchemaVersion = 2
    Id = 'inkling-2-mini-gsq-rco-iq3_s'
    DisplayName = 'Inkling 2 Mini GSQ-RCO IQ3_S (ISTA-DASLab GGUF on Strata)'
    # Weights live with the main catalog's models; this sub-root only owns the Strata configuration.
    RelativeDirectory = '..\models\inkling-2-mini-gsq-rco-iq3_s'
    DeferredInference = $false
    Artifacts = @(
        @{
            # The GSQ-RCO IQ3_S GGUF pinned by Strata 0.2.23 (GSQ_COMMIT in strata_control/inkling_family.py).
            File = 'Inkling-2-Mini-GSQ-RCO-IQ3_S.gguf'
            RemoteFile = 'Inkling-2-Mini-GSQ-RCO-IQ3_S.gguf'
            Size = 11425259648
            Sha256 = '8a3515374c3cd9b65a1677b17e805bb1e32df8e98756e5f0d2fe1837d62aa4cb'
            Repository = 'ISTA-DASLab/Inkling-2-Mini-GSQ-RCO-GGUF'
            Revision = '357051619a8805c032e58a9976cea9bddb0832cd'
        }
        @{
            # DFlash 2 drafter, Strata's pre-quantized "mix" copy; the engine reads it as dflash2.safetensors beside the model.
            File = 'dflash2.safetensors'
            RemoteFile = 'Inkling-2-Mini-DFlash2-mix.safetensors'
            Size = 551600700
            Sha256 = 'cf7dbb08560dfd99544af0cdbab2915406fc571f516b19aff0fe113b9458d387'
            Repository = 'strata-engine/Inkling-2-Mini-DFlash2'
            Revision = '04ecd36faef74e696f0a7b6b3c119264442a6234'
        }
        @{
            # Strata's picture reader (Vision shard, 16 KiB layout); only the vision profiles pass it.
            File = 'Inkling-2-Mini-Vision-v2.strata'
            RemoteFile = 'Inkling-2-Mini-Vision-v2.strata'
            Size = 636551168
            Sha256 = '34a176505276729b58744fc9ee40a5005bbff9a590d8e1f7dbe82baf33ef07d5'
            Repository = 'strata-engine/Inkling-2-Mini-Strata'
            Revision = '5623ceb47d7a01db827460ce1c23e7818a75661b'
        }
    )
}
