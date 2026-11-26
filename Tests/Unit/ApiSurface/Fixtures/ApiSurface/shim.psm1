#region Shared Helpers

function Invoke-M365DSCGraphShimGetResource
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [System.Collections.IDictionary]
        $BoundParameters,

        [Parameter(Mandatory = $true)]
        [System.String]
        $CollectionUri,

        [Parameter()]
        [System.String]
        $SingleItemUri
    )
}

function Invoke-M365DSCGraphShimWriteResource
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [System.Collections.IDictionary]
        $BoundParameters,

        [Parameter(Mandatory = $true)]
        [System.String]
        $Uri,

        [Parameter(Mandatory = $true)]
        [ValidateSet('POST', 'PATCH', 'PUT')]
        [System.String]
        $Method,

        [Parameter()]
        [System.String[]]
        $ExtraExcludeParams
    )
}

function Invoke-M365DSCGraphShimDeleteResource
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [System.Collections.IDictionary]
        $BoundParameters,

        [Parameter(Mandatory = $true)]
        [System.String]
        $Uri
    )
}

function Get-M365DSCGraphShimAllPages
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [System.String]
        $Uri
    )
}

#endregion Shared Helpers

function Get-MgBetaTestPolicy
{
    [CmdletBinding()]
    param(
        [Parameter()]
        [System.String]
        $TestPolicyId,

        [Parameter()]
        [System.String]
        $Filter,

        [Parameter()]
        [System.Management.Automation.SwitchParameter]
        $All
    )

    $singleItemUri = if ($PSBoundParameters.ContainsKey('TestPolicyId') -and -not [System.String]::IsNullOrEmpty($TestPolicyId)) { "/beta/testPolicies/$($TestPolicyId)" } else { $null }
    return Invoke-M365DSCGraphShimGetResource -BoundParameters $PSBoundParameters -CollectionUri "/beta/testPolicies" -SingleItemUri $singleItemUri -ErrorAction $ErrorActionPreference
}

function New-MgBetaTestPolicy
{
    [CmdletBinding()]
    param(
        [Parameter()]
        [System.Object]
        $BodyParameter
    )

    return Invoke-M365DSCGraphShimWriteResource -BoundParameters $PSBoundParameters -Uri "/beta/testPolicies" -Method 'POST' -ErrorAction $ErrorActionPreference
}

function Update-MgBetaTestPolicy
{
    [CmdletBinding()]
    param(
        [Parameter()]
        [System.String]
        $TestPolicyId,

        [Parameter()]
        [System.Object]
        $BodyParameter
    )

    return Invoke-M365DSCGraphShimWriteResource -BoundParameters $PSBoundParameters -Uri "/beta/testPolicies/$($TestPolicyId)" -Method 'PATCH' -ExtraExcludeParams @('TestPolicyId') -ErrorAction $ErrorActionPreference
}

function Remove-MgBetaTestPolicy
{
    [CmdletBinding()]
    param(
        [Parameter()]
        [System.String]
        $TestPolicyId
    )

    Invoke-M365DSCGraphShimDeleteResource -BoundParameters $PSBoundParameters -Uri "/beta/testPolicies/$($TestPolicyId)" -ErrorAction $ErrorActionPreference
}

function Get-MgTestGroup
{
    [CmdletBinding()]
    param(
        [Parameter()]
        [System.String]
        $TestGroupId
    )

    $singleItemUri = if ($PSBoundParameters.ContainsKey('TestGroupId') -and -not [System.String]::IsNullOrEmpty($TestGroupId)) { "/v1.0/testGroups/$($TestGroupId)" } else { $null }
    return Invoke-M365DSCGraphShimGetResource -BoundParameters $PSBoundParameters -CollectionUri "/v1.0/testGroups" -SingleItemUri $singleItemUri -ErrorAction $ErrorActionPreference
}
