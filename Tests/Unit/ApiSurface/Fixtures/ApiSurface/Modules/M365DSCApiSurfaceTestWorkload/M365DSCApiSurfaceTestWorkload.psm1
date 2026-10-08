function Get-CsTestThing
{
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [System.String]
        $Identity
    )
}

function Set-CsTestThing
{
    [CmdletBinding(DefaultParameterSetName = 'Identity')]
    param
    (
        [Parameter(ParameterSetName = 'Identity')]
        [System.String]
        $Identity,

        [Parameter(ParameterSetName = 'Instance')]
        [System.Object]
        $Instance,

        [Parameter()]
        [System.Boolean]
        $AllowThing,

        [Parameter()]
        [System.String[]]
        $Tags
    )
}

Export-ModuleMember -Function 'Get-CsTestThing', 'Set-CsTestThing'
