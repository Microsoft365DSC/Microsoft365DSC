# Copilot Instructions for Microsoft365DSC

## Ponytail, lazy senior dev mode

You are a lazy senior developer. Lazy means efficient, not careless. The best code is the code never written.

Before writing any code, stop at the first rung that holds:

1. Does this need to be built at all? (YAGNI)
2. Does the standard library already do this? Use it.
3. Does a native platform feature cover it? Use it.
4. Does an already-installed dependency solve it? Use it.
5. Can this be one line? Make it one line.
6. Only then: write the minimum code that works.

Rules:

- No abstractions that weren't explicitly requested.
- No new dependency if it can be avoided.
- No boilerplate nobody asked for.
- Deletion over addition. Boring over clever. Fewest files possible.
- Question complex requests: "Do you actually need X, or does Y cover it?"
- Pick the edge-case-correct option when two stdlib approaches are the same size, lazy means less code, not the flimsier algorithm.
- Mark intentional simplifications with a `ponytail:` comment. If the shortcut has a known ceiling (global lock, O(n²) scan, naive heuristic), the comment names the ceiling and the upgrade path.

Not lazy about: input validation at trust boundaries, error handling that prevents data loss, security, accessibility, the calibration real hardware needs (the platform is never the spec ideal, a clock drifts, a sensor reads off), anything explicitly requested. Lazy code without its check is unfinished: non-trivial logic leaves ONE runnable check behind, the smallest thing that fails if the logic breaks (an assert-based demo/self-check or one small test file; no frameworks, no fixtures). Trivial one-liners need no test.

## Architecture Overview

- **Purpose:** Automate deployment, configuration, reporting, and monitoring of Microsoft 365 Tenants using PowerShell Desired State Configuration (DSC).
- **Core Components:**
  - `Examples`: The directory containing all of the DSC resource examples.
  - `Modules/Microsoft365DSC`: Contains DSC resources for individual Microsoft 365 services (e.g. Entra, Exchange, Teams, SharePoint) and other core modules shared across the Microsoft365DSC module.
    - `Dependencies/`: Contains images for the README files, `Manifest.psd1` for the module dependencies and their versions, and other files.
    - `DscResources/`: The directory containing all of the DSC resources.
    - `Modules`: The directory containing all of the shared core modules.
  - `ResourceGenerator/`: Utilities for generating resource definitions.
  - `generator/`: TypeScript/Node.js code for resource generation and supporting scripts.
  - `dev-package/`: Development modules and tests.
  - `Tests/`: PowerShell-based unit and integration tests for DSC resources.
- **Data Flow:** Configurations are compiled and executed by an agent's Local Configuration Manager (LCM), which communicates with Microsoft 365 via remote API calls. Other option is to execute them e.g. with DSCv3's `dsc.exe`.

## Developer Workflows

- **Installation:**
  - Use `Install-Module -Name Microsoft365DSC -Force` to install.
  - Update with `Update-M365DSCModule`.
- **Testing:**
  - Run unit tests in `Tests/Unit/` using VS Code or in PowerShell. Example: `Invoke-Pester -Path Tests/Unit`.
  - CI runs workflows in `.github/workflows/` for code coverage, integration tests, and other checks.
- **Telemetry:**
  - Telemetry is enabled by default. Disable with `Set-M365DSCTelemetryOption -Enabled $False`.
- **Branching:**
  - All contributions start from the `dev` branch. Direct commits to `master` are prohibited. Use a feature branch to develop new features or fixes.

## Project-Specific Conventions

- **Resource Naming:** DSC resources follow the pattern `<Workload><Resource>`, e.g., `EXOGroupSettings`. Each file is prefixed with `MSFT_`, the class inside it carries the same name without that prefix.
- **Resource Definition:** A resource is one `[DscResource()]` class deriving from `M365DSCResourceBase`. Its `[DscProperty()]` declarations are the schema. `Modules/Microsoft365DSC/SchemaDefinition.json` is **auto-generated** by reflection over the classes and must **never** be edited by hand.
- **Building:** `DscResources/` is source. Run `./Utilities/Build-Microsoft365DSC.ps1` after changing it, before importing the module or running tests. It writes `Modules/Microsoft365DSC/Classes/`, which is not in version control.
- **Testing:** Each resource has a corresponding test file in `Tests/Unit/Microsoft365DSC/`. Its name is `Microsoft365DSC.<ResourceName>.Tests.ps1`.
- **Documentation:** Resource documentation is in `docs/` and `README.md`.
- **External Dependencies:**
  - PowerShell modules (e.g., `Microsoft.Graph`, `Pester`).
  - TypeScript dependencies in `generator/package.json`.

## DSC Resource Coding Rules

These rules apply to all DSC resource implementations. Agents **must** follow them:

1. **No helper/debug methods.** Do not add helper functions for debugging purposes. Use existing utilities only.
2. **No status output from `Test()`.** Do not log or display the result of `Test()`. It must only return `$true` or `$false`.
3. **No logging `Get()` results.** Do not output `Get()` results to log or console.
4. **Export must include `$Filter` support.** Every `Export()` must honour the `$Filter` property.
5. **Export: use `Add-Member` for DomainId.** Do not use hashtable normalization. Use `Add-Member -NotePropertyName 'DomainId'` instead.
6. **Standard error handling only.** No extra `Write-Verbose` in catch blocks. Use only `$this.LogError($_, '<Message>')` + `throw`.
7. **No `Test()` call in `Set()`.** DSC handles Test→Set automatically.
8. **Never hardcode endpoint URLs.** Use `Get-MSCloudLoginConnectionProfile` or equivalent helpers for cloud-agnostic URLs.
9. **Increment build version on new property changes.** If changing the properties of a resource not yet in `dev` or `main`, increment its build version.
10. **`Ensure` or `IsSingleInstance` required.** Singleton resources need `[DscProperty(Key)] [ValidateSet('Yes')] [System.String] $IsSingleInstance`. Multi-instance resources need `[ValidateSet('Present', 'Absent')] [System.String] $Ensure`. Rare exceptions must be justified.
11. **Unit tests: mock all external functions and add stubs.** Mock all functions from other modules. Add mock stubs to `Tests/Unit/Stubs/` in the correct `#region` (alphabetical order). Create a new region if the module is not yet present.
12. **Prefer non-beta modules and endpoints.** Use GA modules and REST endpoints. Only use beta when functionality is not yet available in GA.
13. **`Get()` must always return the key propert(y|ies) and `Ensure` in all code paths.** Even in the "not found" return, the identity key (e.g., `Identity`, `GroupID`) must be populated and `Ensure` must be set to `'Absent'`.
14. **Check for `$null` explicitly before accessing properties.** Use `if ($null -ne $object)` rather than letting the `catch` block handle null references. Provide a graceful, descriptive error message.
15. **Use `elseif` for mutually exclusive `Ensure` branches in `Set()`.** Pattern: `if ($this.Ensure -eq 'Present' -and ...) { } elseif ($this.Ensure -eq 'Absent' -and ...) { }`. Only enter the `Absent` branch when the resource currently exists.
16. **No module-scope helper functions in resource modules.** The build merges every resource into shared part modules, so a function defined in a resource file leaks into every other resource. Inline code used once. Code used more than once becomes a `hidden` method, or a `hidden static` method called as `[ClassName]::Method()` where no `$this` exists, such as inside a `PostProcessing` block.
17. **Hidden methods are named `VerbNoun` in PascalCase.** Start with an approved PowerShell verb (e.g., `GetConditionSetAsHashtable`, `TestConditionSetsEqual`). The class scopes the name, no resource prefix is needed.
18. **Use `Write-Verbose -Message "..."` (named parameter).** Always pass the message with the `-Message` parameter, not positionally.
19. **Error messages must be resource-specific.** Never copy-paste error messages from other resources. Each message must reference the current resource's context. When `Ensure = 'Absent'` is unsupported, throw: `"This resource cannot delete [Entity]. Please make sure you set its Ensure value to Present."`.
20. **Every new DSC resource must add an export block to the central export function.** When adding a new resource, ensure `Export-M365DSCConfiguration` (or equivalent) in the core module includes a block for the new resource.
21. **Do not wrap Boolean values in quotes.** Use `$true`/`$false`, never `'true'`/`'false'` or `"true"`/`"false"`, including in example files and test params.
22. **Use `($null -ne $var)` style (null on the left) for all null comparisons.** This is the enforced PowerShell best practice in this codebase (e.g., `($null -ne $Role)` not `($Role -ne $null)`).
23. **Do not remove `Verbose` from `$this.GetBoundParameters()` explicitly.** `Verbose` is never part of it, so removing it is unnecessary noise.
24. **When creating a new hashtable, create it fresh rather than clearing an existing one.** Do not reuse a hashtable by removing all items; just instantiate a new `@{}`.
25. **No `$Script:` variables.** All resources share one module scope. Cache per-resource state on `$this.ResourceCache['<Key>']`, seeded in a `<ClassName>() : base()` constructor. Static methods take it as a `[System.Collections.Hashtable] $Cache` parameter.
26. **Prefix global variables with `$Global:` inside class methods.** Automatic and global variables are otherwise invisible: `$Global:PSVersionTable`, `$Global:M365DSCEmojiGreenCheckMark`.
27. **Declare locals before conditional assignment.** A variable first assigned inside an `if` branch is a parse error in a class method. Declare it as `$null` up front.
28. **Never give a local the same name as a class property.** `$tenantId` collides with the `TenantId` property and is a parse error.
29. **Do not splat a cache entry inline.** `cmd $this.ResourceCache['x']` passes the hashtable positionally. Assign it to a local first, then splat the local.
30. **Do not use `$this` inside a nested script block.** It does not resolve. Hoist the value into a local first; for the `PostProcessing` block, pass state through `PostProcessingArgs`.

## Code Formatting & Style

These formatting rules are enforced during code review. Agents must apply them to all generated or modified PowerShell code:

1. **No trailing or consecutive empty lines.** Remove blank lines at the end of files. Maximum one blank line between logical blocks.
2. **One blank line between top-level function definitions.** Separate each function with exactly one blank line.
3. **Opening `{` on the same line as the statement.** In PowerShell, braces open on the same line (e.g., `if (...) {`), not on a new line.
4. **Align `=` signs in hashtable and parameter blocks.** When constructing hashtables or splatting parameters, align `=` signs vertically for readability.
5. **No trailing semicolons.** Do not add `;` at the end of statements in PowerShell.
6. **Each cmdlet parameter on its own line.** When calling a cmdlet with multiple parameters, place each parameter on its own line.
7. **No double spaces before parameter values.** Ensure single spacing between parameter names and their values.

## Property & Description Conventions

1. **Key properties come first.** Declare them at the top of the class. Authentication properties (`Credential`, `ApplicationId`, `TenantId`, `CertificateThumbprint`, `ManagedIdentity`, `AccessTokens`, ...) go at the bottom, followed by any non-schema properties such as `$Filter`.
2. **Every `[DscProperty()]` must carry a `[System.ComponentModel.Description('...')]` ending with a period `.`.** Descriptions drive auto-generated wiki documentation and must be present and properly punctuated for all properties.
3. **Resource names must be singular.** e.g., `EXOGroupSetting` not `EXOGroupSettings`, unless the M365 API concept is inherently plural.
4. **Do not use abbreviations in descriptions.** Use full words: `"alternate"` not `"alt"`, correct product names like `"Giphy"` not `"Gilphy"`.
5. **Use third-person phrasing in all descriptions.** Use `"their"` not `"your"` (e.g., `"Manages their SPO tenant settings."` not `"Manages your SPO tenant settings."`).
6. **Descriptions must have a space between sentences.** When a description contains multiple sentences, separate them with a single space after the period.
7. **Use `[ValidateSet()]` for properties with a known fixed set of values.** Prefer enforcing allowed values on the property rather than free-text where an enum is available.
8. **Use `[System.Nullable[System.Boolean]]` for optional booleans.** A plain `[System.Boolean]` cannot express "not set".
9. **Escape single quotes in descriptions by doubling them.** e.g. `'The application''s certificate.'`

## Examples

1. **Changing a resource's property set means updating its examples.** The files under `Examples/Resources/<ResourceName>/` must configure every configurable non-authentication property. Read `.github/instructions/m365dsc-examples.instructions.md` in full before editing anything under `Examples/`, and verify with `Utilities/Measure-M365DSCExampleCoverage.ps1` and the Pester gates in `Tests/QA/`.

<!-- mermaid-ai-skills:start -->
## Mermaid Diagrams

When the user asks to create, edit, or visualize a diagram, follow the
instructions in `.github/instructions/mermaid.instructions.md`.
<!-- mermaid-ai-skills:end -->
