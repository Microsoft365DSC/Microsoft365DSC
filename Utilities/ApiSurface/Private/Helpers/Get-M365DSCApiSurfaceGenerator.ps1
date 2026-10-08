<#
.SYNOPSIS
    Returns the module of the resource generator, importing it on first use.

.DESCRIPTION
    The CSDL walking lives in the resource generator, which keeps generated resources and the API
    surface snapshot on one type graph. Its functions are private and every call goes through the
    module object.

.PARAMETER RepositoryRoot
    Specifies the root of the Microsoft365DSC repository.

.OUTPUTS
    The PSModuleInfo of M365DSCResourceGenerator.
#>
function Get-M365DSCApiSurfaceGenerator
{
    [CmdletBinding()]
    [OutputType([System.Management.Automation.PSModuleInfo])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $RepositoryRoot
    )

    if ($null -ne $script:M365DSCApiSurfaceGenerator)
    {
        return $script:M365DSCApiSurfaceGenerator
    }

    $manifestPath = Join-Path -Path $RepositoryRoot -ChildPath 'ResourceGenerator/M365DSCResourceGenerator.psd1'
    $script:M365DSCApiSurfaceGenerator = Import-Module -Name $manifestPath -Force -PassThru

    return $script:M365DSCApiSurfaceGenerator
}
