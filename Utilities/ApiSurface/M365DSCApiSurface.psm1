<#
    Loader for the Microsoft365DSC API surface module.
#>

$scriptFiles = @(
    Get-ChildItem -Path (Join-Path -Path $PSScriptRoot -ChildPath 'Private') -Filter '*.ps1' -Recurse -File
    Get-ChildItem -Path (Join-Path -Path $PSScriptRoot -ChildPath 'Public') -Filter '*.ps1' -File
)

foreach ($scriptFile in $scriptFiles)
{
    . $scriptFile.FullName
}

Export-ModuleMember -Function 'Compare-M365DSCApiSurface', 'Get-M365DSCApiSurface',
'Invoke-M365DSCApiSurfaceCheck', 'Invoke-M365DSCApiSurfaceUpdate', 'Update-M365DSCResourceFromDrift'
