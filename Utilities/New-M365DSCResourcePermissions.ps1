<#
.SYNOPSIS
    Generates Modules/Microsoft365DSC/ResourcePermissions.json from the per-resource settings files.

.DESCRIPTION
    Folds every DscResources/MSFT_*/settings.json into one document keyed by resource name. This allows the
    module and its consumers to read a resource's permissions, required modules, commands and mode from
    a single file instead of opening several hundred.

.PARAMETER RepositoryRoot
    Root of the repository. Defaults to the parent of this script's folder.
#>
[CmdletBinding()]
param
(
    [Parameter()]
    [System.String]
    $RepositoryRoot = (Split-Path -Path $PSScriptRoot -Parent)
)

$ErrorActionPreference = 'Stop'

$moduleRoot = Join-Path -Path $RepositoryRoot -ChildPath 'Modules/Microsoft365DSC'
$resourcesRoot = Join-Path -Path $moduleRoot -ChildPath 'DscResources'
$outputPath = Join-Path -Path $moduleRoot -ChildPath 'ResourcePermissions.json'

if (-not (Test-Path -Path $resourcesRoot))
{
    throw "No DscResources folder at '$resourcesRoot'."
}

$manifestPath = Join-Path -Path $moduleRoot -ChildPath 'Microsoft365DSC.psd1'
$expectedResourceCount = @((Import-PowerShellDataFile -Path $manifestPath).DscResourcesToExport).Count

$settings = [ordered]@{}

foreach ($file in (Get-ChildItem -Path $resourcesRoot -Filter 'settings.json' -Recurse -File | Sort-Object -Property FullName))
{
    $resourceName = (Split-Path -Path $file.DirectoryName -Leaf).Replace('MSFT_', '')
    $settings[$resourceName] = [System.IO.File]::ReadAllText($file.FullName) | ConvertFrom-Json
}

if ($settings.Count -lt $expectedResourceCount)
{
    throw "Only $($settings.Count) settings files were found but the manifest exports $expectedResourceCount resources."
}

ConvertTo-Json -InputObject $settings -Depth 99 -Compress | Set-Content -Path $outputPath -Encoding utf8 -NoNewline

Write-Host "[permissions] Wrote $($settings.Count) resource settings to ResourcePermissions.json" -ForegroundColor Green
