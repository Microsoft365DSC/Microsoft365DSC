# Resource Comparison Architecture

## Overview

This document describes how resource-specific comparison logic is handled in Microsoft365DSC.
This ensures that drift detection and reporting use the same comparison parameters as the DSC runtime, regardless of whether the comparison is triggered by `Test()` or `New-M365DSCDeltaReport`.

## Problem Statement

Previously, there were two comparison pathways that produced inconsistent results:

1. **Resource-Level Comparison** (via `Test()`):
   * Resources could specify custom comparison logic (PostProcessing, ExcludedProperties, IncludedProperties)
   * Used during DSC runtime operations

2. **Report-Level Comparison** (via `New-M365DSCDeltaReport`):
   * Called `Compare-M365DSCResourceState` directly without resource-specific parameters
   * Lost all custom comparison logic, causing false drift detection

## Solution Architecture

Both pathways ask the resource class itself for its comparison parameters.

### 1. Resource-Level `GetCompareParameters()` Method

`M365DSCResourceBase` declares the method and returns an empty hashtable. Resources that require custom comparison logic override it, returning the same parameters that are passed to `Test-M365DSCTargetResource`:

**Example:** `MSFT_AADRoleAssignmentScheduleRequest`

```powershell
    [System.Collections.Hashtable] GetCompareParameters()
    {
        return @{
            ExcludedProperties = @('Justification')
            CompareRules       = @(
                @{ Type = 'IgnoreWhenPast'; Path = 'ScheduleInfo.StartDateTime' }
                @{ Type = 'DurationMatchesEnd'; Expiration = 'ScheduleInfo.expiration'; Start = 'ScheduleInfo.startDateTime' }
            )
        }
    }
```

The resource's own `Test()` splats the result:

```powershell
    [bool] Test()
    {
        ...
        $compareParameters = $this.GetCompareParameters()
        return Test-M365DSCTargetResource -DesiredValues $this.GetBoundParameters() `
            -ResourceName $this.GetResourceName() `
            @compareParameters -CurrentValues $this.Get().ToHashtable()
    }
```

**Supported Return Values:**

* `ExcludedProperties` (string[]): Properties to exclude from comparison
* `IncludedProperties` (string[]): Properties to explicitly include in comparison
* `PostProcessing` (ScriptBlock): Custom transformation logic (must return Tuple[Hashtable, Hashtable, Hashtable])
* `PostProcessingArgs` (object[]): Additional arguments passed to PostProcessing scriptblock
* `CompareRules` (object[]): Declarative rules applied before `PostProcessing`, see [Compare Rules](#compare-rules)

The base class also provides `GetSettingsCatalogCompareParameters()`, which the settings-catalog resources delegate to instead of writing their own body.

### 2. Helper Functions

**`Get-M365DSCResourceCompareParameters`** (in `DscResources/_Base/M365DSCResourceFactory.psm1`)

* Resolves the resource name to its class type through the `M365DSCResourceBase` registry
* Constructs an instance with no properties set and returns its `GetCompareParameters()`
* Returns `@{}` for an unknown resource name rather than throwing

This lives with the other class entry points because PowerShell classes do not cross module boundaries: `M365DSCUtil.psm1` cannot write `[AADGroup]::new()`.

**`Get-M365DSCResourceComparisonParameters`** (in `M365DSCUtil.psm1`)

* Caches the result per resource for the lifetime of the session
* Delegates to `Get-M365DSCResourceCompareParameters`

### 3. Offline Comparison Data in `SchemaDefinition.json`

The delta report compares configurations without loading every resource class. The comparison parameters it needs are stored in `Modules/Microsoft365DSC/SchemaDefinition.json`, next to each resource's parameters:

```json
{
    "ClassName": "MSFT_AADAgreement",
    "Parameters": [ ... ],
    "CompareParameters": { "ExcludedProperties": [ "FileData" ] }
}
```

* `CompareParameters` contains the `ExcludedProperties`, `IncludedProperties` and `CompareRules` a resource returns. Empty lists as well as resources without a `GetCompareParameters()` implementation result in no `CompareParameters` entry.
* `HasPostProcessing` is `true` when the resource returns a `PostProcessing` scriptblock. A scriptblock cannot be stored in JSON. The flag tells the report to ask the resource class at runtime.

`Utilities/New-M365DSCSchemaFromClasses.ps1` generates the file from the built class-based resources: for every registered resource it creates an instance with no properties set and reads its `GetCompareParameters()`. `Utilities/Build-Microsoft365DSC.ps1` runs it on every build. The file is not checked in. An override takes effect with the next build.

A `GetCompareParameters()` method that throws during generation leaves the resource without comparison data. The generator reports it and continues:

```text
WARNING: SPOTenantSettings.GetCompareParameters() failed. Its comparison parameters are missing from SchemaDefinition.json: <message>
```

The offline comparison then skips the resource-specific parameters for that resource. To prevent this, fix the override before relying on the report.

### 4. Integration with New-M365DSCDeltaReport

`New-M365DSCDeltaReport` loads `SchemaDefinition.json` through `Initialize-M365DSCSchemaCache` and compares with `Microsoft365DSC.Compare.ConfigurationComparer`:

* `SchemaIndex.GetCompareParameters()` reads `CompareParameters` from the schema entry, including its `CompareRules`. A resource that only declares rules needs no PowerShell at report time.
* For every resource in the compared configurations whose schema entry has `HasPostProcessing`, the report calls `Get-M365DSCResourceComparisonParameters` and passes the returned `CompareRules`, `PostProcessing`, `PostProcessingArgs`, `ExcludedProperties` and `IncludedProperties` to the comparer. `IsReport = $true` is appended to `PostProcessingArgs`. A callback uses it to tell a report from `Test()` (`[M365DSCResourceBase]::IsReportContext()`) and skip anything that needs a workload connection.
* The report's own `-ExcludedProperties` and `-ExcludedResources` apply on top of the resource parameters.

## Implementation Guide

### Adding Custom Comparison to a New Resource

1. **Override `GetCompareParameters()`** on your resource class:

    ```powershell
        [System.Collections.Hashtable] GetCompareParameters()
        {
            return @{
                ExcludedProperties = @('PropertyToExclude1', 'PropertyToExclude2')
                # IncludedProperties = @('PropertyToInclude1')  # Optional
                # PostProcessing = $scriptBlock  # Optional
            }
        }
    ```

2. **Splat it** in the resource's `Test()`, as shown above.

3. **Test your implementation**
   * Run your resource's `Test()` - should work as before
   * Run `Assert-M365DSCBlueprint` - should now use the same comparison logic

No registration step is needed because the next build writes the override into `SchemaDefinition.json`  and the report resolves the class for `PostProcessing`. An override is picked up on its own. Check the build output for a `GetCompareParameters() failed` warning.

### Compare Rules

Prefer `CompareRules` over a `PostProcessing` scriptblock. Rules are data. The schema stores them, and every comparer applies them the same way, the Microsoft365DSC.Compare library outside PowerShell included. Rules run in declaration order on copies of the desired and current values, before `PostProcessing`.

```powershell
    [System.Collections.Hashtable] GetCompareParameters()
    {
        return @{
            CompareRules = @(
                @{ Type = 'RemoveWhen'; Properties = @('BucketId'); When = @{ Property = 'BucketId'; IsNullOrEmpty = $true } }
                @{ Type = 'Normalize'; Paths = @('Notes'); Using = 'StripNewlines' }
            )
        }
    }
```

| Type | Members | Effect |
| --- | --- | --- |
| `CheckAllSchemaProperties` | | Compares every schema property either side has. Null and an empty collection count as absent. |
| `RemoveWhen` | `Properties`, `PropertyPattern`, `When`, `AlsoFromDesired` | Stops comparing the listed properties and the ones whose name matches the pattern. |
| `CheckWhen` | `Property`, `When` | Compares a property the desired values leave out, against null. |
| `SetWhen` | `Side`, `Property`, `Value`, `When` | Writes a value on one side. `Side` defaults to `Desired`. |
| `Normalize` | `Paths`, `Side`, `Using`, normalizer options | Rewrites values with the normalizer in `Using`. `Side` defaults to `Both`. |
| `Equivalent` | `Property`, `Values` | Treats the listed values of a property as equal. |
| `NullEqualsEmpty` | `PropertyPattern`, `Side` | Reads a missing array as empty. `Side` defaults to `Current`. |
| `Tolerance` | `Properties`, `Within` | Stops comparing time spans that differ by at most `Within`, such as `00:05:00`. |
| `IgnoreNested` | `Paths` | Removes nested properties on both sides. |
| `IgnoreWhenPast` | `Path` | Takes the current date when the desired date differs and lies in the past. |
| `SameInstant` | `Path` | Takes the current date when both dates are the same instant. |
| `Rename` | `From`, `To` | Renames a property on both sides. |
| `DurationMatchesEnd` | `Expiration`, `Start`, `ToleranceMinutes` | Treats an `afterDuration` expiration as equal to an `afterDateTime` one that ends that long after the start. |
| `AllowCurrentExtras` | `Property`, `MatchKey` | Accepts collection items only the current side has, paired by `MatchKey`. |
| `CustomCompare` | `Name`, comparer options | Runs a C# comparer registered under `Name`. |

A path is dotted, such as `ScheduleInfo.Expiration`. A segment ending in `[]`, such as `Settings[].Value`, continues into every element of that array. Matching a property ignores case.

`When` is one condition or a combination. A condition has `Property`, an optional `Side` that defaults to `Desired`, and one operator: `Equals`, `NotEquals`, `IsNullOrEmpty`, `NotNullOrEmpty`, `HasKey`, `NotHasKey`, `Truthy` or `Falsy`. Combine conditions with `All = @(...)` or `Any = @(...)`:

```powershell
When = @{ All = @(
    @{ Property = 'Mode'; Equals = 'Off' }
    @{ Side = 'Current'; Property = 'Window'; NotNullOrEmpty = $true }
) }
```

The normalizers are:

* `StripNewlines`
* `RegexReplace` with `Pattern` and `Replacement`
* `PrefixUnless` with `Pattern` and a `Format` such as `'v:{0}'`
* `FormatDuration`, the shortest ISO 8601 duration such as `P90D`
* `FormatDateTime`, a round-trip UTC timestamp
* `FormatTimeOfDay`, `hh:mm` with a full day as `1.00:00`
* `FormatSize`, a size such as `10KB` without the byte count
* `ReformatDateTime` with `InputFormats` and `Format`
* `ExchangeFilter`, an Exchange filter with `-and` grouped before `-or` and every operand in parentheses

Dates without an offset are read as UTC.

The comparers are:

* `SCLabelPolicy`, `SCSensitivityLabel`, `SCAutoSensitivityLabelRule` and `SCDLPComplianceRule` for the resource of the same name
* `FeatureUpdateRollout` for the rollout dates of `IntuneWindowsUpdateForBusinessFeatureUpdateProfileWindows10`
* `TenantIsolationRules` with `TenantIds`, a hashtable from tenant name to tenant id, for `PPTenantIsolationSettings`

A comparer can explain a drift. `Test()` writes that explanation to the event log as a warning from the resource. The report does not write it.

`[Microsoft365DSC.Compare.CompareRuleRegistry]::RegisterComparer()` and `RegisterNormalizer()` add more. Each takes a factory that receives the rule declaration.

The unit tests fail when a resource declares an unknown rule type, comparer or normalizer, or misses a required member.

### PostProcessing Script Pattern

The PostProcessing scriptblock receives four parameters and must return a Tuple:

```powershell
$postProcessingScript = {
    param
    (
        $DesiredValues,      # Hashtable - values from configuration
        $CurrentValues,      # Hashtable - values from tenant
        $ValuesToCheck,      # Hashtable - properties to compare
        $PostProcessingArgs  # Optional array - additional context
    )

    # Modify values as needed
    # Example: Normalize datetime values
    if ($DesiredValues.StartDate -lt [DateTime]::Now) {
        $DesiredValues.StartDate = $CurrentValues.StartDate
    }

    # MUST return Tuple[Hashtable, Hashtable, Hashtable]
    return [System.Tuple[Hashtable, Hashtable, Hashtable]]::new(
        $DesiredValues,
        $CurrentValues,
        $ValuesToCheck
    )
}
```

The scriptblock is invoked by `Test-M365DSCTargetResource`, outside the instance's scope, so `$this` is not available inside it. State travels via `PostProcessingArgs`.

Note that the report path constructs the instance with no properties set, so any state an override reads from `$this` holds its default there.

## Benefits

1. **Consistency**: Report generation and DSC runtime use identical comparison logic
2. **Maintainability**: Comparison logic lives in one place (the resource class)
3. **Flexibility**: Resources can define complex comparison rules without modifying core engine
4. **Discoverability**: The override sits next to the `Test()` that uses it

## File Locations

* **Base Class:** `Modules/Microsoft365DSC/DscResources/_Base/M365DSCResourceBase.psm1`
* **Class Entry Points:** `Modules/Microsoft365DSC/DscResources/_Base/M365DSCResourceFactory.psm1`
* **Helper Functions:** `Modules/Microsoft365DSC/Modules/M365DSCUtil.psm1`
* **Comparison Engine:** `Modules/Microsoft365DSC/Modules/M365DSCCompare.psm1`, `src/Microsoft365DSC.Compare/ConfigurationComparer.cs`
* **Offline Comparison Data:** `Modules/Microsoft365DSC/SchemaDefinition.json` (generated), read by `src/Microsoft365DSC.Compare/SchemaIndex.cs`
* **Offline Data Generator:** `Utilities/New-M365DSCSchemaFromClasses.ps1`
* **Report Generator:** `Modules/Microsoft365DSC/Modules/M365DSCReport.psm1`
* **Resource Example:** `Modules/Microsoft365DSC/DscResources/MSFT_AADRoleAssignmentScheduleRequest/MSFT_AADRoleAssignmentScheduleRequest.psm1`
