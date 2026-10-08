#Requires -Version 5.1

<#
.SYNOPSIS
    Generates the DSC v3 adapted resource manifest bundle for the class-based resources.

.DESCRIPTION
    Writes Modules/Microsoft365DSC/Microsoft365DSC.dsc.manifests.json, one bundle holding an entry
    per entry of DscResourcesToExport, next to Microsoft365DSC.psd1, so the manifests ship in the
    package. Each entry names the resource Microsoft365DSC/<Name>, points at Microsoft365DSC.psd1,
    requires the Microsoft.Adapter/PowerShell adapter and embeds a JSON schema for the resource
    properties. dsc 3.3 discovers the bundle the same way it discovers one file per resource.

    The manifests come from the DscResource.Authoring module. New-DscAdaptedResourceManifest
    parses each resource source file and, through -ModuleManifestPath, takes the module name,
    version, author and manifest path from Microsoft365DSC.psd1. The tool maps the declared CLR
    types, unwraps System.Nullable[T], emits the complex MSFT_* types and PSCredential once
    under $defs, reads the property descriptions from the [System.ComponentModel.Description()]
    attributes and advertises export only for a static Export(). The resource description is
    then replaced with the one from the readme.md of the resource, and New-DscResourceManifest
    collects the results into the bundle.

    DscResource.Authoring is installed under the PowerShell 7 module path while the build also
    runs under Windows PowerShell, so the script re-runs itself under pwsh when needed.

    dsc 3.3.0-preview.4 lists the bundled manifests and returns their schemas. Get, set and test through
    path Microsoft365DSC.psd1 still fail inside the shipped adapter, which cannot load class
    resources from a manifest without a RootModule and types nested classes after the file that
    declares them. Both defects are tracked upstream.

.PARAMETER RepositoryRoot
    Root of the Microsoft365DSC repository. Defaults to the parent of this script's folder.

.PARAMETER WarnOnly
    Warn instead of failing when PowerShell 7 or DscResource.Authoring is not available. A
    mismatch between the written manifests and DscResourcesToExport always fails.

.EXAMPLE
    .\New-M365DSCAdaptedResourceManifest.ps1

.EXAMPLE
    .\New-M365DSCAdaptedResourceManifest.ps1 -WarnOnly

.NOTES
    Called by Utilities/Build-Microsoft365DSC.ps1 after the class modules are built. Reads the
    DscResources tree, which places it before Remove-M365DSCBuildOnlySource.ps1 in the release
    flow. Install the tool with Install-PSResource -Name DscResource.Authoring.
#>

[CmdletBinding(SupportsShouldProcess)]
param
(
    [Parameter()]
    [System.String]
    $RepositoryRoot,

    [Parameter()]
    [Switch]
    $WarnOnly
)

$ErrorActionPreference = 'Stop'

# The first DscResource.Authoring release that maps qualified CLR types, emits $defs and
# accepts -ModuleManifestPath.
$minimumToolVersion = [System.Version] '0.3.0'

if ([System.String]::IsNullOrEmpty($RepositoryRoot))
{
    $RepositoryRoot = Split-Path -Path (Split-Path -Path $PSCommandPath -Parent) -Parent
}

$moduleRoot = Join-Path -Path $RepositoryRoot -ChildPath 'Modules/Microsoft365DSC'
$manifestPath = Join-Path -Path $moduleRoot -ChildPath 'Microsoft365DSC.psd1'
$sourceRoot = Join-Path -Path $moduleRoot -ChildPath 'DscResources'

if (-not (Test-Path -Path $manifestPath))
{
    throw "Manifest not found: $manifestPath"
}

if ($PSVersionTable.PSVersion.Major -lt 7)
{
    # DscResource.Authoring lives under the PowerShell 7 module path. Run this script there.
    if (-not (Get-Command -Name pwsh -ErrorAction Ignore))
    {
        $message = 'PowerShell 7 (pwsh) was not found on PATH. The adapted resource manifests were not generated.'
        if ($WarnOnly)
        {
            Write-Warning -Message $message
            return
        }
        throw $message
    }

    $arguments = @('-NoProfile', '-NonInteractive', '-File', $PSCommandPath, '-RepositoryRoot', $RepositoryRoot)
    if ($WarnOnly)
    {
        $arguments += '-WarnOnly'
    }
    if ($WhatIfPreference)
    {
        $arguments += '-WhatIf'
    }

    # The caller discards this script's output stream, so relay the child's console lines.
    & pwsh @arguments | ForEach-Object { Write-Host $_ }
    if ($LASTEXITCODE -ne 0)
    {
        throw "Adapted resource manifest generation failed under PowerShell 7 (exit $LASTEXITCODE)."
    }
    return
}

$module = Get-Module -ListAvailable -Name 'DscResource.Authoring' |
    Where-Object { $_.Version -ge $minimumToolVersion } |
    Sort-Object -Property Version -Descending |
    Select-Object -First 1

if ($null -eq $module)
{
    $message = "DscResource.Authoring $minimumToolVersion or later is not installed. Install it with Install-PSResource -Name DscResource.Authoring. The adapted resource manifests were not generated."
    if ($WarnOnly)
    {
        Write-Warning -Message $message
        return
    }
    throw $message
}

Import-Module -Name $module.Path -Force

$manifest = Import-PowerShellDataFile -Path $manifestPath
$resourceNames = @($manifest.DscResourcesToExport | Sort-Object)
if ($resourceNames.Count -eq 0)
{
    throw "DscResourcesToExport in '$manifestPath' is empty. Run Build-Microsoft365DSC.ps1 first."
}

function ConvertTo-SingleLine
{
    param
    (
        [System.String]
        $Text
    )

    return (($Text -split '\r?\n') | ForEach-Object { $_.Trim() } | Where-Object { $_ }) -join ' '
}

$defaultDescription = ConvertTo-SingleLine -Text $manifest.Description

$resources = @{}
foreach ($name in $resourceNames)
{
    $sourceDirectory = Join-Path -Path $sourceRoot -ChildPath "MSFT_$name"
    $sourceFile = Join-Path -Path $sourceDirectory -ChildPath "MSFT_$name.psm1"
    if (-not (Test-Path -Path $sourceFile))
    {
        throw "Source file not found for resource '$name': $sourceFile"
    }

    $description = $defaultDescription
    $readMePath = Join-Path -Path $sourceDirectory -ChildPath 'readme.md'
    if (Test-Path -Path $readMePath)
    {
        $parts = (Get-Content -Path $readMePath -Raw) -split '## Description'
        if ($parts.Count -gt 1)
        {
            $readMeDescription = ConvertTo-SingleLine -Text $parts[1]
            if ($readMeDescription)
            {
                $description = $readMeDescription
            }
        }
    }

    $resources[$name] = @{
        SourceFile  = $sourceFile
        Description = $description
    }
}

if (-not $PSCmdlet.ShouldProcess($moduleRoot, 'Write adapted resource manifests'))
{
    return
}

$bundlePath = Join-Path -Path $moduleRoot -ChildPath 'Microsoft365DSC.dsc.manifests.json'
Remove-Item -Path $bundlePath -Force -ErrorAction Ignore

$toolWarnings = @()
$manifests = @($resourceNames | ForEach-Object { $resources[$_].SourceFile } |
        New-DscAdaptedResourceManifest -ModuleManifestPath $manifestPath -WarningAction SilentlyContinue -WarningVariable toolWarnings)

foreach ($warning in $toolWarnings)
{
    Write-Warning -Message "[adapted] $($warning.Message)"
}

$described = 0

foreach ($adapted in $manifests)
{
    $name = ($adapted.Type -split '/')[-1]
    if (-not $resources.ContainsKey($name) -or $adapted.Type -ne "Microsoft365DSC/$name")
    {
        throw "Manifest '$($adapted.Type)' does not match an entry of DscResourcesToExport."
    }

    $null = Update-DscAdaptedResourceManifest -InputObject $adapted -Description $resources[$name].Description
    $described++
}

if ($described -ne $resourceNames.Count)
{
    throw "Built $described adapted resource manifests but the manifest exports $($resourceNames.Count) resources."
}

$bundle = $manifests | New-DscResourceManifest
$encoding = [System.Text.UTF8Encoding]::new($false)
[System.IO.File]::WriteAllText($bundlePath, $bundle.ToJson(), $encoding)

Write-Host "[adapted] Wrote $described adapted resource manifests to $bundlePath" -ForegroundColor Green
