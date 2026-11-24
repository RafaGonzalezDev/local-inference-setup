@{
    SchemaVersion = 2
    Id = 'inkling-2-mini-ud-q4_k_xl'
    DisplayName = 'Inkling 2 Mini UD-Q4_K_XL (Unsloth GGUF on Strata)'
    # Weights live with the main catalog's models; this sub-root only owns the Strata configuration.
    RelativeDirectory = '..\models\inkling-2-mini-ud-q4_k_xl'
    DeferredInference = $false
    Artifacts = @(
        @{
            # Unsloth's re-upload of 2026-11-23 (mainline llama.cpp layout). Strata 0.2.21 accepts it next to its pinned
            # older file (ALT_GGUF_FILES in strata_control/inkling_family.py).
            File = 'Inkling-2-Mini-UD-Q4_K_XL.gguf'
            RemoteFile = 'Inkling-2-Mini-UD-Q4_K_XL.gguf'
            Size = 17629760736
            Sha256 = 'e64276656f072e9b2197a61723667cbdb71da66a716ffd966e572c21088f3cd3'
            Repository = 'unsloth/Inkling-2-Mini-GGUF'
            Revision = '8078d149286eec7193795413b9e0643da6d11fa1'
        }
        @{
            # DSpark drafter: Thinking Machines' original BF16 checkpoint, the default drafter of GGUF builds in Strata 0.2.21
            # (Unsloth's re-uploaded drafter uses a layout the engine cannot read yet).
            File = 'mtp.safetensors'
            RemoteFile = 'mtp.safetensors'
            Size = 635801416
            Sha256 = '7c3b651317f01f73bcf4e1dceba66ef8b7e1a1eac6bc171e882e690a4b10a1d2'
            Repository = 'thinkingmachines/Inkling-2-Mini'
            Revision = '1fb4134b9a74f9681054f4ef82e4bf1f458a2337'
        }
    )
}
