<#
    Entry points for class-based resources.

    This file is SOURCE ONLY. Utilities/Build-Microsoft365DSC.ps1 appends it to the generated
    _Shared.psm1, immediately after M365DSCResourceBase.

    It has to sit in that file specifically. It cannot live in M365DSCUtil.psm1 or any other
    hand-written nested module, because those have their own session state and cannot see class
    types at all. And it cannot resolve types with `$ResourceName -as [System.Type]`, because under
    the split layout the resource classes are spread across Part<NN>.psm1 - each its own module -
    so no single scope sees them all. Resolution goes through the static registry on
    M365DSCResourceBase, which every part populates at import.

    Everything in the codebase that needs to reach a resource class goes through here:

      - Modules/M365DSCReverse.psm1, which must call .Export() per resource and is itself a nested
        module with its own session state.
      - The PowerShell 7 side of the Windows PowerShell 5.1 dispatch
        (Invoke-M365DSCClassResourceInPowerShellCore, M365DSCUtil.psm1).

    These functions must NOT be added to the manifest's FunctionsToExport.
#>

<#
.SYNOPSIS
    Creates an instance of a class-based Microsoft365DSC resource.

.DESCRIPTION
    Resolves the resource name to its class type and returns a populated instance. This exists
    because PowerShell classes do not cross module boundaries: callers elsewhere in the module -
    let alone outside it - cannot write [AADGroup]::new().

.PARAMETER ResourceName
    Specifies the resource name, which is also the class name, e.g. 'AADGroup'.

.PARAMETER Property
    Specifies the property values to assign. Only the keys present here are marked as explicitly
    set, which is what makes GetBoundParameters() behave like $PSBoundParameters did.

.EXAMPLE
    $instance = New-M365DSCResourceInstance -ResourceName 'AADGroup' -Property @{ DisplayName = 'Contoso' }

.FUNCTIONALITY
    Public

.OUTPUTS
    System.Object
#>
function New-M365DSCResourceInstance
{
    [CmdletBinding()]
    [OutputType([System.Object])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $ResourceName,

        [Parameter()]
        [System.Collections.Hashtable]
        $Property = @{}
    )

    $type = [M365DSCResourceBase]::Resolve($ResourceName)
    if ($null -eq $type)
    {
        throw "Unknown Microsoft365DSC resource '$ResourceName'."
    }

    $instance = $type::new()
    $instance.FromHashtable($Property)

    return $instance
}

<#
.SYNOPSIS
    Indicates whether a class-based resource declares a given property.

.DESCRIPTION
    The class-based replacement for
    (Get-Command 'Export-TargetResource').Parameters.Keys.Contains('Filter'). Export support for
    -Filter and -SubscriptionId varies per resource, and the reverse engine has to ask before
    passing them.

.PARAMETER ResourceName
    Specifies the resource name, e.g. 'AADGroup'.

.PARAMETER PropertyName
    Specifies the property to look for, e.g. 'Filter'.

.EXAMPLE
    Test-M365DSCResourceProperty -ResourceName 'AADGroup' -PropertyName 'Filter'

.FUNCTIONALITY
    Internal

.OUTPUTS
    System.Boolean
#>
function Test-M365DSCResourceProperty
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $ResourceName,

        [Parameter(Mandatory = $true)]
        [System.String]
        $PropertyName
    )

    $type = [M365DSCResourceBase]::Resolve($ResourceName)
    if ($null -eq $type)
    {
        return $false
    }

    return ($null -ne $type.GetProperty($PropertyName))
}

<#
.SYNOPSIS
    Returns the name of the part module that declares a resource class.

.DESCRIPTION
    Exists for the unit tests. Pester scopes a mock to a module, and a mock scoped to the parent
    module does not reach a class method executing in a nested Classes/Part<NN>.psm1 - the call
    returns the real value and Should -Invoke counts zero. Tests therefore have to name the part
    they mock into, and the part a resource lands in depends on bucket count and alphabetical
    order, so it cannot be hardcoded.

    Commands reached through a BASE-class method (Connect, AddTelemetry, LogError) or through a
    helper declared in _Shared.psm1 execute in '_Shared', not in the part - those need mocking
    against '_Shared' instead.

.PARAMETER ResourceName
    Specifies the resource name, e.g. 'AADGroup'.

.EXAMPLE
    InModuleScope -ModuleName (Get-M365DSCResourceModuleName -ResourceName 'AADGroup') { ... }

.FUNCTIONALITY
    Internal

.OUTPUTS
    System.String
#>
function Get-M365DSCResourceModuleName
{
    [CmdletBinding()]
    [OutputType([System.String])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $ResourceName
    )

    return [M365DSCResourceBase]::ResolveModuleName($ResourceName)
}

<#
.SYNOPSIS
    Returns the mandatory key properties declared by a class-based resource.

.DESCRIPTION
    Used by the export engine to pick the instance name for an exported resource block.

    Reads the class itself rather than Get-M365DSCResourcesDictionary. The dictionary is
    populated from Get-DscResourceV2 and is deliberately left empty in some hosts - notably under
    $Global:IsTestEnvironment - which left the export engine with $null keys and no usable fallback
    once MSFT_<Name>.psm1 stopped existing. The attributes on the class are always there.

.PARAMETER ResourceName
    Specifies the resource name, e.g. 'AADGroup'.

.EXAMPLE
    Get-M365DSCResourceMandatoryKey -ResourceName 'AADGroup'

.FUNCTIONALITY
    Internal

.OUTPUTS
    System.String[]
#>
function Get-M365DSCResourceMandatoryKey
{
    [CmdletBinding()]
    [OutputType([System.String[]])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $ResourceName
    )

    $type = [M365DSCResourceBase]::Resolve($ResourceName)
    if ($null -eq $type)
    {
        return [System.String[]] @()
    }

    $keys = [System.Collections.Generic.List[System.String]]::new()
    foreach ($property in $type.GetProperties())
    {
        $attribute = @($property.GetCustomAttributes([System.Management.Automation.DscPropertyAttribute], $true))
        if ($attribute.Count -eq 0)
        {
            continue
        }

        if ($attribute[0].Key -or $attribute[0].Mandatory)
        {
            $keys.Add($property.Name)
        }
    }

    return $keys.ToArray()
}

<#
.SYNOPSIS
    Returns the custom comparison parameters declared by a class-based resource.

.DESCRIPTION
    The class-based replacement for importing MSFT_<Resource>.psm1 and invoking its
    Get-CompareParameters function. Used by the delta report so that reporting compares the same
    way Test() does.

    Instantiates the resource with no properties set, so overrides that read instance state get
    their defaults. Unknown names return an empty hashtable rather than throwing: the report walks
    whatever resource names a blueprint contains, including deprecated ones.

.PARAMETER ResourceName
    Specifies the resource name, e.g. 'AADGroup'.

.EXAMPLE
    Get-M365DSCResourceCompareParameters -ResourceName 'AADApplication'

.FUNCTIONALITY
    Internal

.OUTPUTS
    System.Collections.Hashtable
#>
function Get-M365DSCResourceCompareParameters
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $ResourceName
    )

    $type = [M365DSCResourceBase]::Resolve($ResourceName)
    if ($null -eq $type)
    {
        return @{}
    }

    return $type::new().GetCompareParameters()
}

<#
.SYNOPSIS
    Invokes a method on a class-based Microsoft365DSC resource.

.DESCRIPTION
    The single entry point used to drive a resource from outside the root module, and the remote
    half of the Windows PowerShell 5.1 dispatch.

.PARAMETER ResourceName
    Specifies the resource name, which is also the class name, e.g. 'AADGroup'.

.PARAMETER MethodName
    Specifies the method to invoke.

.PARAMETER Parameters
    Specifies the property values to assign before invoking.

.EXAMPLE
    Invoke-M365DSCResourceMethod -ResourceName 'AADGroup' -MethodName 'Test' -Parameters @{ DisplayName = 'Contoso' }

.FUNCTIONALITY
    Internal

.OUTPUTS
    System.Object
#>
function Invoke-M365DSCResourceMethod
{
    [CmdletBinding()]
    [OutputType([System.Object])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $ResourceName,

        [Parameter(Mandatory = $true)]
        [ValidateSet('Get', 'Set', 'Test', 'Export')]
        [System.String]
        $MethodName,

        [Parameter()]
        [System.Collections.Hashtable]
        $Parameters = @{}
    )

    $type = [M365DSCResourceBase]::Resolve($ResourceName)
    if ($null -eq $type)
    {
        throw "Unknown Microsoft365DSC resource '$ResourceName'."
    }

    $known = @{}
    foreach ($entry in $Parameters.GetEnumerator())
    {
        if ($null -ne $type.GetProperty($entry.Key))
        {
            $known[$entry.Key] = $entry.Value
        }
    }

    $instance = New-M365DSCResourceInstance -ResourceName $ResourceName -Property $known

    $previousVerbosePreference = Set-M365DSCVerboseScope
    try
    {
        $result = $instance.$MethodName()
    }
    finally
    {
        $null = Set-M365DSCVerboseScope -Restore $previousVerbosePreference
    }

    if ($result -is [M365DSCResourceBase])
    {
        $result = $result.ToHashtable()
    }

    return $result
}
