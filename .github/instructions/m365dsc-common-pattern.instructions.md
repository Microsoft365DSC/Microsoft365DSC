---
applyTo: "**/*.ps1,**/*.psm1"
description: "Common patterns and helper functions in Microsoft365DSC"
---

# Common Patterns in Microsoft365DSC

This guide defines the shared logic patterns used throughout the project.

## Method Preamble

Every `Get()`, `Set()`, `Test()` and `Export()` starts with the edition bridge, then connects and records telemetry:

```powershell
[AADExample] Get()
{
    if ($this.RequiresPowerShellCore())
    {
        $remote = [AADExample]::new()
        $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
        return $remote
    }

    $null = $this.Connect('MicrosoftGraph')

    #Ensure the proper dependencies are installed in the current environment.
    Confirm-M365DSCDependencies

    #region Telemetry
    $this.AddTelemetry('Get')
    #endregion
    ...
}
```

`Set()` returns nothing, so its bridge is `$null = $this.InvokeInPowerShellCore('Set'); return`. `Test()` returns `[bool] $this.InvokeInPowerShellCore('Test')` and `Export()` returns `[string] $this.InvokeInPowerShellCore('Export')`.

## Authentication Requirements

All Microsoft365DSC resources authenticate through `$this.Connect('<Workload>')`, which wraps `New-M365DSCConnection` from the `MSCloudLoginAssistant` PowerShell module. It returns the connection mode, which `Export()` passes to `Get-M365DSCExportContentForResource`.

Resources must **not** require explicit authentication per resource. They depend on the global Microsoft365DSC auth session.

Forbidden patterns:

- Do not perform resource-level direct Graph auth (e.g. `Connect-MgGraph` inside a resource) unless a documented exception is provided.
- Do not embed raw secrets, tokens, or credentials in code or telemetry at any time.

## Logging

Use:

- `Write-M365DSCHost` for user output
- `Write-Verbose -Message` for Verbose messages
- Never use `Write-Host` except for interactive scenarios
- **Do not** add extra `Write-Verbose` in catch blocks — only use `$this.LogError()` + `throw`
- **Do not** output the results of `Get()` to log or console
- **Do not** output status messages for `Test()` results — it must only return `$true` or `$false`

## Exception Handling

Use the built-in error helper with a try/catch block. **Do not** add extra `Write-Verbose` statements in catch blocks:

```powershell
catch
{
    $this.LogError($_, 'Error retrieving data:')

    throw
}
```

`LogError` fills in the source, tenant and credential from the instance. A static method has no `$this`, so let the exception reach the calling method's catch block.

## Debugging

- **Do not** add helper methods or functions for debugging purposes. Use the existing logging utilities (`Write-Verbose`, `$this.LogError()`, etc.).

## Set() Rules

- **Never call `Test()` inside `Set()`.** The DSC engine handles the Test -> Set flow automatically. `Set()` must only implement the configuration changes.
- Read current state with `$this.Get().ToHashtable()`.
- Compare against `$this.GetBoundParameters()` to know which properties the configuration actually set.

## Endpoint URLs

- **Never hardcode** URLs to Microsoft endpoints (e.g., `https://graph.microsoft.com`, `https://management.azure.com`). Use `Get-MSCloudLoginConnectionProfile` or equivalent helpers to obtain base URLs at runtime. This ensures cloud-agnostic behaviour for GCC, GCC-High, DoD, China, and other sovereign clouds.

## Caching

Per-resource state goes on `$this.ResourceCache['<Key>']`, seeded in a `<ClassName>() : base()` constructor for values known up front:

```powershell
AADExample() : base()
{
    $this.ResourceCache['propertiesToRetrieve'] = @('Id', 'DisplayName')
}
```

Values fetched at runtime are cached on first use:

```powershell
if ($null -eq $this.ResourceCache['allRoleDefinitions'])
{
    $this.ResourceCache['allRoleDefinitions'] = Get-MgBetaRoleManagementDirectoryRoleDefinition -All
}
```

`ResourceCache` is a `[Hashtable]`, so keys are case-insensitive. Static methods have no `$this` and take it as a parameter:

```powershell
hidden static [System.Collections.Hashtable] GetSomethingAsHashtable([System.Collections.Hashtable] $Cache, [System.Object] $Value)
{
    ...
}
```

Call it as `[AADExample]::GetSomethingAsHashtable($this.ResourceCache, $value)`, or with `$PostProcessingArgs[0]` inside a `PostProcessing` block.

## Complex Type Handling

For detailed patterns on working with complex types (embedded classes, nested arrays), including conversion helpers, deep comparison, export serialization, and unit testing, see `m365dsc-complex-types.instructions.md`.

## Drift Detection Patterns

`Test()` always uses the pre-defined comparison block:

```powershell
[bool] Test()
{
    if ($this.RequiresPowerShellCore())
    {
        return [bool] $this.InvokeInPowerShellCore('Test')
    }

    #region Telemetry
    $this.AddTelemetry('Test')
    #endregion

    $compareParameters = $this.GetCompareParameters()
    $result = Test-M365DSCTargetResource -DesiredValues $this.GetBoundParameters() `
        -ResourceName $this.GetResourceName() `
        @compareParameters -CurrentValues $this.Get().ToHashtable()
    return $result
}
```

Customise the comparison by overriding `GetCompareParameters()`, which returns the extra arguments splatted above:

```powershell
[System.Collections.Hashtable] GetCompareParameters()
{
    return @{
        ExcludedProperties = @('PasswordNeverExpires')
    }
}
```

For a post-processing callback, return a `PostProcessing` script block alongside it. The block is invoked by `Test-M365DSCTargetResource` outside the instance's scope, so `$this` is unavailable — pass everything it needs through `PostProcessingArgs`:

```powershell
[System.Collections.Hashtable] GetCompareParameters()
{
    return @{
        PostProcessing = {
            param($DesiredValues, $CurrentValues, $ValuesToCheck, $PostProcessingArgs)
            foreach ($key in $PostProcessingArgs[0])
            {
                # ...
            }

            return [System.Tuple[Hashtable, Hashtable, Hashtable]]::new($DesiredValues, $CurrentValues, $ValuesToCheck)
        }
        # Prevent array unrolling
        PostProcessingArgs = @(, [System.String[]] $this.ResourceCache['someKeys'])
    }
}
```

Settings-catalog resources call `$this.GetSettingsCatalogCompareParameters()` instead, optionally with a list of properties to exclude.

## Reverse DSC (Export())

When generating exported configuration:

- Output objects in alphabetical property order
- Avoid emitting default values
- **Always honour `$Filter`** for client-side filtering

The shape is the same for every resource: fetch the instances, set `$this.ExportedInstance` for each, call `$this.GetForExport($Params)`, pass the result to `Get-M365DSCExportContentForResource`, and append to a `[System.Text.StringBuilder]`:

```powershell
foreach ($config in $exportedInstances)
{
    $Params = @{
        DisplayName = $config.DisplayName
        Credential  = $this.Credential
        # ... remaining authentication properties
    }

    $this.ExportedInstance = $config
    $Results = $this.GetForExport($Params)

    $currentDSCBlock = Get-M365DSCExportContentForResource -ResourceName $this.GetResourceName() `
        -ConnectionMode $ConnectionMode `
        -ModulePath $this.GetModulePath() `
        -Results $Results `
        -Credential $this.Credential

    [void]$dscContent.Append($currentDSCBlock)
    Save-M365DSCPartialExport -Content $currentDSCBlock `
        -FileName $Global:PartialExportFileName
}

return $dscContent.ToString()
```

`Get()` reads `$this.ExportedInstance` to skip the round trip:

```powershell
if (-not $this.ExportedInstance -or $this.ExportedInstance.DisplayName -ne $this.DisplayName)
{
    # fetch from the service
}
else
{
    $instance = $this.ExportedInstance
}
```

Refer to `Modules/Microsoft365DSC/DscResources/MSFT_AADUser/MSFT_AADUser.psm1` for a full reference implementation.

## Documentation Rules

The documentation is built automatically inside of the pipeline and deployed to the website https://microsoft365dsc.com.

The cmdlet responsible for this is `Update-M365DSCResourceDocumentationPage` and `New-M365DSCCmdletDocumentation` from the module `Modules/Microsoft365DSC/Modules/M365DSCDogGenerator` and `Modules/Microsoft365DSC/Modules/M365DSCUtil`.

Telemetry rules:

- Telemetry must never include PII. Use `$this.AddTelemetry('<Method>')` rather than ad-hoc telemetry code.
