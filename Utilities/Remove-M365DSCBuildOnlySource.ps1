#Requires -Version 5.1

<#
.SYNOPSIS
    Deletes the DscResources tree that the packaged module does not need.

.DESCRIPTION
    DscResources/MSFT_*/ is the editing surface for the class-based resources.
    Build-Microsoft365DSC.ps1 compiles MSFT_*/MSFT_*.psm1 into Classes/Part*.psm1 and _Base into
    Classes/_Shared.psm1, folds every settings.json into ResourcePermissions.json, and turns every
    readme.md into the descriptions in SchemaDefinition.json.

.PARAMETER RepositoryRoot
    Root of the Microsoft365DSC repository. Defaults to the parent of this script's folder.

.PARAMETER ModuleRoot
    Root of an already installed module, the folder holding Microsoft365DSC.psd1. Use this to trim
    a copy under a module path instead of a checkout.

.EXAMPLE
    .\Remove-M365DSCBuildOnlySource.ps1 -WhatIf

.EXAMPLE
    .\Remove-M365DSCBuildOnlySource.ps1

.EXAMPLE
    .\Remove-M365DSCBuildOnlySource.ps1 -ModuleRoot 'C:\Program Files\WindowsPowerShell\Modules\Microsoft365DSC\1.26.1007.1'
#>

[CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High', DefaultParameterSetName = 'Repository')]
param
(
    [Parameter(ParameterSetName = 'Repository')]
    [System.String]
    $RepositoryRoot,

    [Parameter(Mandatory, ParameterSetName = 'Module')]
    [System.String]
    $ModuleRoot
)

$ErrorActionPreference = 'Stop'

$moduleRoot = if ($PSCmdlet.ParameterSetName -eq 'Module')
{
    (Resolve-Path -Path $ModuleRoot).ProviderPath
}
else
{
    if ([System.String]::IsNullOrEmpty($RepositoryRoot))
    {
        $RepositoryRoot = Split-Path -Path (Split-Path -Path $PSCommandPath -Parent) -Parent
    }

    Join-Path -Path $RepositoryRoot -ChildPath 'Modules/Microsoft365DSC'
}

$sourceRoot = Join-Path -Path $moduleRoot -ChildPath 'DscResources'
$classRoot = Join-Path -Path $moduleRoot -ChildPath 'Classes'

if (-not (Test-Path -Path $classRoot))
{
    throw "Classes folder not found at '$classRoot'. Run Build-Microsoft365DSC.ps1 first - removing the sources before they are compiled would leave nothing to ship."
}

foreach ($product in 'ResourcePermissions.json', 'SchemaDefinition.json')
{
    $productPath = Join-Path -Path $moduleRoot -ChildPath $product
    if (-not (Test-Path -Path $productPath))
    {
        throw "$product not found at '$productPath'. The tree carries the only copy of what it holds, so removing it now would drop that data."
    }
}

if (-not (Test-Path -Path $sourceRoot))
{
    Write-Host "[trim] No DscResources folder at '$sourceRoot', nothing to remove." -ForegroundColor Green
    return
}

$files = @(Get-ChildItem -Path $sourceRoot -Recurse -File)
$freed = ($files | Measure-Object -Property Length -Sum).Sum
$directories = @(Get-ChildItem -Path $sourceRoot -Directory).Count

if ($PSCmdlet.ShouldProcess($sourceRoot, 'Remove build-only source tree'))
{
    Remove-Item -Path $sourceRoot -Recurse -Force
}

Write-Host ("[trim] Removed {0} directory(ies), {1} file(s), {2} MB" -f $directories, $files.Count, [System.Math]::Round($freed / 1MB, 1)) -ForegroundColor Green
