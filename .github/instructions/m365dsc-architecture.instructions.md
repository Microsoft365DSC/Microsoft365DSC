---
applyTo: "**/*.ps1,**/*.psm1"
description: "Architecture and structure of Microsoft365DSC resources"
---

# Microsoft365DSC Resource Architecture Guide

This guide gives AI agents a deep understanding of how DSC resources inside the Microsoft365DSC module are structured, named, and executed.

## Resource Structure Overview

Each DSC resource has the following files:

- `MSFT_<ResourceName>.psm1` - Resource implementation. One `[DscResource()]` class deriving from `M365DSCResourceBase`, plus its complex type classes.
- `MSFT_<ResourceName>/readme.md` - Short plain-language description of what the resource manages. **Must only describe what the resource does, not how to use it.** Do not include usage instructions, parameter details, examples, or configuration snippets. A single sentence or short paragraph is sufficient.
- `Examples/Resources/<ResourceName>/` - Example DSC configuration
- `docs/<Workload>/<ResourceName>.md` - Documentation. Auto-generated during build time.
- `Tests/Unit/Microsoft365DSC/Microsoft365DSC.<ResourceName>.Tests.ps1` - Pester tests

## Building

`DscResources/` is source. `Utilities/Build-Microsoft365DSC.ps1` compiles it into `Modules/Microsoft365DSC/Classes/`, wires those files into `Microsoft365DSC.psd1` and regenerates `SchemaDefinition.json`. `Classes/` is not in version control.

Run the build after changing anything under `DscResources/`, before importing the module or running tests.

## Class Pattern

```powershell
using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class AADExample : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('The display name of the instance.')]
    [System.String] $DisplayName

    [DscProperty()]
    [System.ComponentModel.Description('Present ensures the instance exists, absent ensures it is removed.')]
    [ValidateSet('Present', 'Absent')]
    [System.String] $Ensure

    # Export-only. Not part of the resource schema.
    [System.String] $Filter

    AADExample() : base()
    {
        $this.ResourceCache['propertiesToRetrieve'] = @('Id', 'DisplayName')
    }

    [AADExample] Get() { }
    [void] Set() { }
    [bool] Test() { }
    [string] Export() { }
}
```

### Rules

- **Properties are the schema.** Declare each one with `[DscProperty()]` and a `[System.ComponentModel.Description('...')]` ending with a period. Descriptions drive the generated documentation.
- **`Modules/Microsoft365DSC/SchemaDefinition.json` is auto-generated** by reflection over the classes and must never be edited manually.
- **Increment build version** when changing the properties of a resource that has not yet been merged to `dev` or `main`.
- Use `[System.Nullable[System.Boolean]]` for optional booleans so "unset" stays distinguishable from `$false`.
- Properties not part of the schema (such as `$Filter`) are declared without `[DscProperty()]`.
- `Get()` returns an instance of the resource class. **Do not** output the result to log or console.
- `Test()` returns strictly `$true` or `$false`. **Do not** output status messages for the result.
- `Set()` performs the actual configuration changes. **Never call `Test()` inside `Set()`** - the DSC engine handles the Test -> Set flow automatically.
- `Export()` returns the configuration as a string and supports reverse-DSC generation. **Must always include `$Filter` support.**
- **`Ensure` or `IsSingleInstance` must be present.** Singleton resources need `[DscProperty(Key)] [ValidateSet('Yes')] [System.String] $IsSingleInstance`. Multi-instance resources need `[ValidateSet('Present', 'Absent')] [System.String] $Ensure`. Rare exceptions (e.g. `AzureRoleEligibilityScheduleSettings`) must be explicitly justified.

## Base Class API

`M365DSCResourceBase` supplies what class methods do not get for free:

| Member | Use |
| --- | --- |
| `$this.GetBoundParameters()` | The properties the configuration actually set |
| `$this.GetResourceName()` | Resource name without the `MSFT_` prefix |
| `$this.GetModulePath()` | Path to the resource module |
| `$this.ExportedInstance` | The instance being exported, so `Get()` can skip a round trip |
| `$this.ResourceCache['<Key>']` | Per-instance cache, seeded in a `<ClassName>() : base()` constructor |
| `$this.Connect('<Workload>')` | Authenticated session; returns the connection mode |
| `$this.AddTelemetry('<Method>')` | Telemetry event for the current method |
| `$this.LogError($_, '<Message>')` | Standard error logging |
| `$this.ToHashtable()` / `$this.FromHashtable()` | Conversion between the class and a hashtable |
| `$this.GetForExport($Values)` | Populates the instance and runs `Get()` during export |
| `$this.GetCompareParameters()` | Override to customise drift comparison |
| `$this.RequiresPowerShellCore()` / `$this.InvokeInPowerShellCore()` | Edition bridge, first lines of every method |

## Class Method Scope

Class methods are not script blocks, and several things that work in a function do not work here:

- **No `$Script:` variables.** Every resource shares one module scope. Cache on `$this.ResourceCache` instead.
- **Automatic and global variables are invisible.** Write `$Global:PSVersionTable`, `$Global:M365DSCEmojiGreenCheckMark`. The parser reports the alternative as "Variable is not assigned in the method".
- **`$this` does not resolve inside a nested script block.** Hoist the lookup into a local before any `Where-Object` or `ForEach-Object`, and pass state into the `PostProcessing` block through `PostProcessingArgs`.
- **A local variable may not share a name with a class property.** `$tenantId` collides with the `TenantId` property and is a parse error.
- **Assign every local up front.** A variable first assigned inside an `if` branch is rejected; declare it as `$null` before the branch.
- **Hashtables cannot be splatted inline.** Assign `$this.ResourceCache['x']` to a local, then splat the local.

Resource modules define no module-scope functions, because the build merges all resources into shared part modules and such a function would leak into every other resource. Code used once is inlined. Code used more than once becomes a `hidden` method, or a `hidden static` method called as `[ClassName]::Method()` where no `$this` exists, such as inside a `PostProcessing` block. Static methods take `$this.ResourceCache` as a `[System.Collections.Hashtable] $Cache` parameter when they need to cache.

## Naming Conventions

- File names always start with `MSFT_`, e.g. `MSFT_AADAccessReviewDefinition.psm1`, except for Test files, which start with `Microsoft365DSC.`
- The class name is the file name without the `MSFT_` prefix.
- Hidden methods are named `VerbNoun` in PascalCase with an approved verb (`GetConditionSetAsHashtable`). The class scopes the name, no resource prefix is needed.
- Resource names must be PascalCase and reflect the service:
  - `AADConditionalAccessPolicy`
  - `EXOAcceptedDomain`
  - `TeamsAppSetupPolicy`

## External Dependencies

Most resources use:

- Microsoft.Graph SDK
- ExchangeOnlineManagement
- SharePoint / PnP PowerShell
- Teams PowerShell module

Dependency notes:

- Document minimum required versions in each resource's module settings (`Modules/<ModuleName>/settings.json`) under `requiredModules`.
- Prefer Microsoft Graph APIs when they cover the scenario; use workload-specific modules only when required functionality is not available in Graph.
- **Prefer non-beta (GA) modules and REST endpoints.** Use GA PowerShell modules (e.g., `Microsoft.Graph.Users`) and GA REST endpoints (e.g., `/v1.0/`) whenever the required functionality is available. Only use beta modules (e.g., `Microsoft.Graph.Beta.Users`) or beta REST endpoints (e.g., `/beta/`) when the functionality is new, not yet released to GA, or only available in preview.

When generating new code, the agent should:

- Prefer Graph where available
- Prefer GA (non-beta) modules and endpoints over beta
- Use existing helper modules
- Follow Microsoft365DSC logging and exception patterns

Templates and references:

- See `Modules/Microsoft365DSC/DscResources/_Base/M365DSCResourceBase.psm1` for the base class contract.
- See `Modules/Microsoft365DSC/DscResources/MSFT_AADUser/MSFT_AADUser.psm1` for a reference implementation.
- See `m365dsc-complex-types.instructions.md` for patterns on complex types (embedded classes, nested arrays, export serialization, deep comparison helpers).
