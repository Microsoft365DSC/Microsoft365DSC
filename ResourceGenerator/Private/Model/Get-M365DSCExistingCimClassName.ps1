<#
.SYNOPSIS
    Lists every embedded class name already declared by the shipped resources' class modules.

.DESCRIPTION
    Used to avoid class name collisions: two resources declaring the same embedded class name
    with different members conflict when both modules are loaded, so a colliding generated class
    gets a numeric suffix. Classes belonging to the resource being (re)generated are excluded,
    since regenerating a resource legitimately redefines its own classes.

.PARAMETER ResourceName
    Specifies the resource whose own class module should be ignored.
#>
function Get-M365DSCExistingCimClassName
{
    [CmdletBinding()]
    [OutputType([System.String[]])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $ResourceName
    )

    $dscResourcesPath = Join-Path -Path $PSScriptRoot -ChildPath '..\..\..\Modules\Microsoft365DSC\DscResources'
    if (-not (Test-Path -Path $dscResourcesPath))
    {
        return [System.String[]] @()
    }

    $cimClasses = @()
    $moduleFiles = Get-ChildItem -Path $dscResourcesPath -Filter '*.psm1' -Recurse -File |
        Where-Object -FilterScript { $_.Directory.Name -ne "MSFT_$ResourceName" }

    foreach ($moduleFile in $moduleFiles)
    {
        $content = Get-Content -Path $moduleFile.FullName -Raw
        foreach ($match in [regex]::Matches($content, '(?m)^\s*class\s+(?<name>MSFT_\w+)'))
        {
            $cimClasses += $match.Groups['name'].Value
        }
    }

    return [System.String[]] @($cimClasses | Sort-Object -Unique)
}
