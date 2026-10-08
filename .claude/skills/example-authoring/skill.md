---
name: Example Authoring
description: Author or repair the DSC example files under Examples/Resources
---

# Example Authoring

The authoring contract for every file under `Examples/Resources/` is
`.github/instructions/m365dsc-examples.instructions.md`. Read it in full before editing an example,
and follow it exactly.

## Steps

1. Read `.github/instructions/m365dsc-examples.instructions.md`.
2. Read the resource class at `Modules/Microsoft365DSC/DscResources/MSFT_<Name>/MSFT_<Name>.psm1` to
   get the property set, the `[ValidateSet]` members and the complex types.
3. Read the three example files before changing any of them.
4. Edit `1-Create.ps1` and `2-Update.ps1`. Leave `3-Remove.ps1` alone unless it carries a property
   outside the allowed set.
5. Verify with the analyzer and the two Pester gates named in the contract.

## Constraints

- Preserve CRLF line endings and any byte-order mark. Read and write with
  `[System.IO.File]::ReadAllText` and `WriteAllText` using a `UTF8Encoding` whose BOM flag matches
  the original. Never use `sed -i`.
- Keys stay byte-identical across every file in the folder.
- Do not create or delete files.
