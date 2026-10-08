# Agent Guide for Microsoft365DSC

Purpose: concise, enforceable rules for AI coding agents editing this repository.

- Default branch target: feature branch according to naming standards. Start from `dev` and never modify `master`.
- Workflow: open a todo via `manage_todo_list`, mark `in-progress`, apply focused patches, rethink your changes, present to the user for approval, mark `completed`.
- Always present the changes to the user before marking work completed.
- Never add secrets or credentials to commits. If a change requires secrets, create a placeholder and document required manual steps in the PR.

Generated files (do not edit):

- `Modules/Microsoft365DSC/SchemaDefinition.json` is produced by `Utilities/New-M365DSCSchemaFromClasses.ps1`, which reflects over the built class-based resources, and is regenerated in CI by `Utilities/New-M365DSCDscSchemaCache.ps1`. **Never modify this file directly.**
- `Modules/Microsoft365DSC/Microsoft365DSC.dsc.manifests.json` is the DSC v3 adapted resource manifest bundle produced by `Utilities/New-M365DSCAdaptedResourceManifest.ps1` from the resource sources with the `DscResource.Authoring` module. It is not in version control. **Never modify this file directly.**

Resource definitions (manually authored):

- Every resource is a PowerShell class in `Modules/Microsoft365DSC/DscResources/MSFT_<Name>/MSFT_<Name>.psm1`, declared as `[DscResource()] class <Name> : M365DSCResourceBase` and exposing `Get()`, `Set()`, `Test()` and `Export()` methods.
- A resource's parameter set is the list of `[DscProperty()]` declarations on that class. Add, remove or change a parameter by editing those declarations directly.
- Complex types are plain `class MSFT_*` declarations further down the same file. They carry no version attribute.
- The repository ships no MOF schema. `.github/workflows/Validation Checks.yml` fails the build when any `.schema.mof` file is present, when a resource does not declare `[DscResource()]`, or when a resource still declares a `Get-`, `Set-`, `Test-` or `Export-TargetResource` function.

Class-specific rules covering `$Script:` variables, `$this.ResourceCache` and `$this` inside nested script blocks live in [.github/copilot-instructions.md](./.github/copilot-instructions.md). Rules for authoring the files under `Examples/` live in [.github/instructions/m365dsc-examples.instructions.md](./.github/instructions/m365dsc-examples.instructions.md).

## Comment Guidelines

- Do not use em-dash or en-dash in comments, variable names, or function names. Use a hyphen instead.
- Do not use non-ASCII characters in comments, variable names, or function names. Use ASCII characters only.
- Do not add any comments to code. If a comment is required, rewrite the code to make it self-documenting instead. Exceptions may occur, then comment only what the code cannot say itself. If a name, a signature, or a test already conveys it, do not repeat it in prose.
- Do not use semicolons or colons. Colons are only allowed when a list of items follows.
- Never narrate history. Do not write what a previous version did, which bug was fixed, or what the symptom looked like. Write for the next reader of the file, who does not know a change happened.
- Prefer deleting a stale comment to updating it. A comment that has drifted from the code is worse than none.
- Use en-US writing style instead of en-GB for spelling in code, comments, and documentation.
- When writing an architecture documentation or a blog, use the present tense and a lively, active voice. Avoid passive voice, future tense, and past tense. Write as if the reader is reading it now, not in the past or future.
- Overly usage of `..., so ...` and other forms of connecting clauses is discouraged. Either use separate sentences or another way of connecting.

## Coding Rules for DSC Resources

1. **No helper/debug methods.** Do not add helper functions for debugging. Use existing utilities (`Write-Verbose`, `New-M365DSCLogEntry`, etc.).
2. **No status output from `Test()`.** `Test()` must return only `$true` or `$false`. Do not output status messages or results from it.
3. **No logging `Get()` results.** Do not write the result of `Get()` to the log or console. The caller handles result inspection.
4. **`Export()` must honour `$Filter`.** Every resource declares `[DscProperty()] [System.String] $Filter`, and `Export()` passes `$this.Filter` through to the underlying list call so filtering happens client-side. See `Modules/Microsoft365DSC/DscResources/MSFT_AADGroup/MSFT_AADGroup.psm1` for the pattern.
5. **When creating a new hashtable, create it fresh rather than clearing an existing one.** Do not reuse a hashtable by removing all items. Just instantiate a new `@{}`.
6. **Standard error handling in catch blocks.** Do not add extra `Write-Verbose` in catch blocks. Use the standard `New-M365DSCLogEntry` + `throw` pattern aligned with other resources.

   ```powershell
   catch
   {
       New-M365DSCLogEntry -Message 'Error retrieving data:' `
           -Exception $_ `
           -Source $($MyInvocation.MyCommand.Source) `
           -TenantId $TenantId `
           -Credential $Credential
       throw
   }
   ```

7. **No `Test()` call in `Set()`.** The DSC engine calls `Test()` before `Set()` automatically. Do not call it again inside `Set()`.
8. **Never hardcode Microsoft endpoint URLs.** Use `Get-MSCloudLoginConnectionProfile` or equivalent helpers to obtain base URLs at runtime, ensuring cloud-agnostic behaviour (GCC, GCC-High, DoD, China, etc.).
9. **`Ensure` or `IsSingleInstance` must be present.** A resource that manages a singleton configuration declares `[DscProperty(Key)]` with `[ValidateSet('Yes')]` on `[System.String] $IsSingleInstance`. A resource that manages multiple instances declares an `Ensure` property with `[ValidateSet('Present', 'Absent')]`. Rare exceptions exist (e.g. `AzureRoleEligibilityScheduleSettings`) but must be explicitly justified.
10. **Unit tests: mock all external functions and add stubs.** When writing unit tests, mock all functions from other modules. Add mock stubs to the correct file under `Tests/Unit/Stubs/` (typically `Microsoft365.psm1`). Place each stub in the correct `#region` that matches the source module name. Regions must be in **alphabetical order**. If a region for the module does not yet exist, create one and insert it in alphabetical order. Stubs within each region should also be in alphabetical order.
11. **Prefer non-beta modules and endpoints.** Use GA (non-beta) PowerShell modules and REST API endpoints whenever possible. Only use beta modules (e.g., `Microsoft.Graph.Beta.*`) or beta REST endpoints (e.g., `/beta/`) when the required functionality is new, not yet released to GA, or only available in preview.
12. **`Get()` must always return the key properties and `Ensure` in all code paths.** Even on the not-found path, the identity key (e.g. `Identity`, `GroupID`) must be populated and `Ensure` must be set to `'Absent'`.
13. **Check for `$null` explicitly before accessing properties.** Use `if ($null -ne $object)` rather than letting the `catch` block handle null references. Provide a graceful, descriptive error message.
14. **Use `elseif` for mutually exclusive `Ensure` branches in `Set()`.** Pattern: `if ($this.Ensure -eq 'Present' -and ...) { } elseif ($this.Ensure -eq 'Absent' -and ...) { }`. Only enter the `Absent` branch when the resource currently exists.
15. **No module-scope helper functions in resource modules.** The build merges every resource into shared part modules, so a function defined in a resource file leaks into every other resource. Code used once is inlined in the method that needs it. Code used more than once becomes a `hidden` method on the class, or a `hidden static` method called as `[ClassName]::Method()` where no `$this` exists, such as inside a `PostProcessing` block. See `MSFT_AADPermissionGrantPolicy` for both kinds.
16. **Hidden methods are named `VerbNoun` in PascalCase.** Start with an approved PowerShell verb (e.g., `GetConditionSetAsHashtable`, `TestConditionSetsEqual`, `ConvertToPermissionName`). The class scopes the name, no resource prefix is needed.
17. **Use `Write-Verbose -Message "..."` (named parameter).** Always pass the message with the `-Message` parameter, not positionally.
18. **Error messages must be resource-specific.** Never copy-paste error messages from other resources. Each message must reference the current resource's context. When `Ensure = 'Absent'` is unsupported, throw: `"This resource cannot delete [Entity]. Please make sure you set its Ensure value to Present."`.
19. **Do not wrap Boolean values in quotes.** Use `$true`/`$false`, never `'true'`/`'false'` or `"true"`/`"false"`, including in example files and test params.
20. **Use `($null -ne $var)` style (null on the left) for all null comparisons.** This is the enforced PowerShell best practice in this codebase (e.g., `($null -ne $Role)` not `($Role -ne $null)`).
21. **Do not remove `Verbose` from `$PSBoundParameters` explicitly.** `Verbose` is never part of `$PSBoundParameters`, so removing it is unnecessary noise.
22. **Never unwrap `AdditionalProperties` on Graph responses.** Graph calls go through `M365DSCGraphShim.psm1`, which wraps `Invoke-MgGraphRequest` and returns plain hashtables, so the typed-SDK `AdditionalProperties` dictionary does not exist. Read open-type payloads (for example `customSecurityAttributes`) directly off the returned object. Defensive `if ($null -ne $x.AdditionalProperties)` fallbacks are dead code and must not be added.
23. **Mock a Graph `Get-*` cmdlet once, then vary it per scenario.** In unit tests, define the baseline object (a helper in the outer `BeforeAll`, or a single top-level mock) and have each `Context` override only the properties that scenario exercises. Do not re-declare a full mock body in every `Context` when the contexts differ by one or two fields. Make each variation self-describing through the `Context` name (drift vs. match) rather than an inline comment, per rule 24.
24. **Comments explain *why*, never *what*.** Inline comments are reserved for logic whose reasoning is not evident from the code itself, such as a non-obvious API contract, an ordering requirement, or a workaround for a service-side quirk. Do not add comments that restate the next line, label an obvious block, or narrate the happy path. If a comment feels necessary to make the mechanics understandable, rewrite the code (clearer names, an extracted helper) instead of annotating it. Comment-based help (`<# .SYNOPSIS ... #>`) on public functions is governed separately by `.github/instructions/powershell.instructions.md` and is always welcome.

    ```powershell
    # Bad, restates the code
    # Handle different types of values
    if ($Value -is [string]) { ... }

    # Bad, labels an obvious block
    # Custom Security Attributes
    if ($PSBoundParameters.ContainsKey('CustomSecurityAttributes')) { ... }

    # Good, explains a non-obvious service contract
    # Graph requires each attribute be sent as $null to clear it. Omitting the
    # key leaves the existing value in place.
    $valuesHashtable.Add($attributeKey, $null)
    ```

25. **Changing a resource's property set means updating its examples.** The files under `Examples/Resources/<ResourceName>/` must configure every configurable non-authentication property. Read [.github/instructions/m365dsc-examples.instructions.md](./.github/instructions/m365dsc-examples.instructions.md) in full before editing anything under `Examples/`, and verify with `Utilities/Measure-M365DSCExampleCoverage.ps1` and the Pester gates in `Tests/QA/`.

Quick checklist:

1. Add a todo and mark `in-progress`.
2. Make minimal `apply_patch` edits.
3. Rethink changes and present to the user.
4. If accepted, mark todo `completed` and summarize results.

<!-- code-review-graph MCP tools -->
## MCP Tools: code-review-graph

**IMPORTANT: This project has a knowledge graph. ALWAYS use the
code-review-graph MCP tools BEFORE using Grep/Glob/Read to explore
the codebase.** The graph is faster, cheaper (fewer tokens), and gives
you structural context (callers, dependents, test coverage) that file
scanning cannot.

### When to use graph tools FIRST

- **Exploring code**: `semantic_search_nodes` or `query_graph` instead of Grep
- **Understanding impact**: `get_impact_radius` instead of manually tracing imports
- **Code review**: `detect_changes` + `get_review_context` instead of reading entire files
- **Finding relationships**: `query_graph` with callers_of/callees_of/imports_of/tests_for
- **Architecture questions**: `get_architecture_overview` + `list_communities`

Fall back to Grep/Glob/Read **only** when the graph doesn't cover what you need.

### Key Tools

| Tool | Use when |
| ------ | ---------- |
| `detect_changes` | Reviewing code changes, gives risk-scored analysis |
| `get_review_context` | Need source snippets for review, token-efficient |
| `get_impact_radius` | Understanding blast radius of a change |
| `get_affected_flows` | Finding which execution paths are impacted |
| `query_graph` | Tracing callers, callees, imports, tests, dependencies |
| `semantic_search_nodes` | Finding functions/classes by name or keyword |
| `get_architecture_overview` | Understanding high-level codebase structure |
| `refactor_tool` | Planning renames, finding dead code |

### Workflow

1. The graph auto-updates on file changes (via hooks).
2. Use `detect_changes` for code review.
3. Use `get_affected_flows` to understand impact.
4. Use `query_graph` pattern="tests_for" to check coverage.
