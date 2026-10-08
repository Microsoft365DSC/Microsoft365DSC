<#
.SYNOPSIS
    This module contains the comparison logic for M365DSC.
    Delegates to the C# ResourceComparer for all type normalization,
    primary-key alignment, and drift detection.
#>

$Script:IsPowerShellCore = $PSVersionTable.PSEdition -eq 'Core'

<#
.SYNOPSIS
    Compares the current state of a resource with the desired state and returns whether they match.

.DESCRIPTION
    This function compares the current state of a resource with the desired state and returns whether they match.
    It also populates a global variable with detailed information about any drifts detected during the comparison.

.PARAMETER ResourceName
    Specifies the name of the resource to compare.

.PARAMETER DesiredValues
    Specifies a hashtable containing the desired values for the resource.

.PARAMETER CurrentValues
    Specifies a hashtable containing the current values of the resource.

.PARAMETER ExcludedProperties
    Specifies an array of property names to exclude from the comparison.

.PARAMETER IncludedProperties
    Specifies an array of property names to include in the comparison. If specified, only these properties will be compared.

.PARAMETER PostProcessing
    Specifies a script block or function that will be invoked after the initial comparison to allow for custom post-processing of the current and desired values.
    The script block should accept three parameters: DesiredValues, CurrentValues, and ValuesToCheck, and return a tuple containing the modified DesiredValues, CurrentValues, and ValuesToCheck.

.PARAMETER PostProcessingArgs
    Specifies an array of additional arguments to pass to the PostProcessing script block or function.

.OUTPUTS
    Returns a boolean indicating whether the current state matches the desired state.
#>
function Compare-M365DSCResourceState
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $ResourceName,

        [Parameter(Mandatory = $true)]
        [System.Collections.Hashtable]
        $DesiredValues,

        [Parameter(Mandatory = $true)]
        [System.Collections.Hashtable]
        $CurrentValues,

        [Parameter()]
        [System.String[]]
        $ExcludedProperties,

        [Parameter()]
        [System.String[]]
        $IncludedProperties,

        [Parameter()]
        [System.Func[Hashtable, Hashtable, Hashtable, [Object[]], Tuple[Hashtable, Hashtable, Hashtable]]]
        $PostProcessing,

        [Parameter()]
        [System.Object[]]
        $PostProcessingArgs = @()
    )

    Initialize-M365DSCDllLoader -ErrorAction Stop

    $Global:AllDrifts = @{
        DriftInfo     = @()
        CurrentValues = @{}
        DesiredValues = @{}
    }
    $Global:PotentialDrifts = @()

    # Load the schema once via the C# CacheManager (avoids boxing on every call).
    $currentPath = $PSScriptRoot
    if (-not [Microsoft365DSC.Cache.CacheManager]::IsSchemaLoaded)
    {
        $schemaPath = Join-Path -Path $currentPath -ChildPath '../SchemaDefinition.json'
        if (-not (Test-Path -Path $schemaPath))
        {
            throw "SchemaDefinition.json not found at expected path: $schemaPath. Ensure that the schema was properly included during module build and that the module is not being run from a non-standard location."
        }
        $schemaContent = [System.IO.File]::ReadAllText($schemaPath) | ConvertFrom-Json
        [Microsoft365DSC.Cache.CacheManager]::LoadSchema($schemaContent)
    }

    # Apply custom post-processing callback if specified.
    # PostProcessing is a PowerShell Func delegate, so it must be called here (before entering C#).
    $ValuesToCheck = $DesiredValues.Clone()
    if ($null -ne $PostProcessing)
    {
        Write-Verbose -Message "Applying custom post-processing to CurrentValues and ValuesToCheck for resource $ResourceName"
        try
        {
            $result = $PostProcessing.Invoke($DesiredValues, $CurrentValues, $ValuesToCheck, $PostProcessingArgs)
            if ($null -ne $result -and $result.Item1 -is [Hashtable] -and $result.Item2 -is [Hashtable] -and $result.Item3 -is [Hashtable])
            {
                $DesiredValues = $result.Item1
                $CurrentValues = $result.Item2
                $ValuesToCheck = $result.Item3
            }
            else
            {
                Write-Warning -Message "PostProcessing function did not return a valid tuple for resource $ResourceName. Using original values."
            }
        }
        catch
        {
            Write-Warning -Message "Error occurred during post-processing for resource $ResourceName`: $_"
        }
    }

    if ($VerbosePreference -ne 'SilentlyContinue')
    {
        Write-Verbose -Message "Current Values: $(Convert-M365DscHashtableToString -Hashtable $CurrentValues)"
        Write-Verbose -Message "Target Values: $(Convert-M365DscHashtableToString -Hashtable $DesiredValues)"
    }

    # Delegate the entire comparison to C#.
    # ResourceComparer handles: schema lookup, key/credential exclusion, Ensure handling,
    # CimInstance/PSObject normalization (via ObjectNormalizer), primary-key alignment,
    # complex object comparison, and simple property comparison.
    $compareResult = [Microsoft365DSC.Compare.ResourceComparer]::Compare(
        $DesiredValues,
        $CurrentValues,
        $ValuesToCheck,
        [Microsoft365DSC.Cache.CacheManager]::Schema,
        $ResourceName,
        $ExcludedProperties,
        $IncludedProperties
    )

    # Populate the global drift state from the C# result for downstream consumers
    # (event logging, telemetry, drift reporting).
    $testTargetResource = $compareResult.TestResult
    foreach ($drift in $compareResult.DriftInfo)
    {
        $Global:AllDrifts.DriftInfo += @{
            PropertyName = $drift['PropertyName']
            CurrentValue = $drift['CurrentValue']
            DesiredValue = $drift['DesiredValue']
        }
        if ($drift.ContainsKey('DeltaValue'))
        {
            $Global:AllDrifts.DriftInfo[-1]['DeltaValue'] = $drift['DeltaValue']
        }
    }

    return $testTargetResource
}

Export-ModuleMember -Function Compare-M365DSCResourceState
