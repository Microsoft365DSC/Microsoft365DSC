<#
    Loader for the Microsoft365DSC resource generator.

    All logic lives in Public/ and Private/. This file only dot-sources those scripts so that
    every function shares the module's session state. Only New-M365DSCResource and Update-M365DSCResourceStub are exported
    (see the manifest); everything under Private/ is an implementation detail.
#>

$scriptFiles = @(
    Get-ChildItem -Path (Join-Path -Path $PSScriptRoot -ChildPath 'Private') -Filter '*.ps1' -Recurse -File
    Get-ChildItem -Path (Join-Path -Path $PSScriptRoot -ChildPath 'Public') -Filter '*.ps1' -File
)

foreach ($scriptFile in $scriptFiles)
{
    . $scriptFile.FullName
}

Export-ModuleMember -Function 'New-M365DSCResource', 'Update-M365DSCResourceStub'
