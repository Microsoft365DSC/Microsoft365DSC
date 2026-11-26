$manifest = Import-PowerShellDataFile -Path (Join-Path -Path $PSScriptRoot -ChildPath 'Microsoft365DSC.psd1')
$prerelease = $manifest.PrivateData.PSData.PreRelease

if ([System.String]::IsNullOrEmpty($prerelease))
{
    return
}

Write-Warning -Message "This session runs the pre-release version $($manifest.ModuleVersion)-$prerelease of Microsoft365DSC."
Write-Warning -Message 'Pre-release versions carry a higher version number than the published releases. Update-M365DSCModule and Update-Module never move back to a published release, and Import-Module loads the pre-release as long as it is installed.'
Write-Warning -Message "To update to or go back to the published release, uninstall every pre-release with 'Uninstall-PSResource -Name Microsoft365DSC -Prerelease' and then run 'Install-PSResource -Name Microsoft365DSC'."
Write-Warning -Message "With PowerShellGet, run 'Uninstall-Module -Name Microsoft365DSC -AllVersions -AllowPrerelease' and then 'Install-Module -Name Microsoft365DSC'."
