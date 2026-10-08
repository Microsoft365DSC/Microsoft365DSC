$minimumVersion = [Version]'7.6'

if ($PSVersionTable.PSEdition -eq 'Core')
{
    if ($PSVersionTable.PSVersion -lt $minimumVersion)
    {
        Write-Warning -Message "Microsoft365DSC requires PowerShell $minimumVersion or higher. The current session is running PowerShell $($PSVersionTable.PSVersion)."
        Write-Warning -Message 'Please upgrade PowerShell. You can download the latest release from: https://aka.ms/powershell-release'
    }

    return
}

Write-Warning -Message "Microsoft365DSC requires PowerShell $minimumVersion or higher installed alongside Windows PowerShell. The current session is running Windows PowerShell $($PSVersionTable.PSVersion)."
Write-Warning -Message 'Windows PowerShell is only supported to compile a configuration (Invoke-M365DSCConfigurationBuild) and to run [Get|Start|Test]-DscConfiguration. In that case, the Local Configuration Manager relays the execution of every resource to PowerShell 7.'
Write-Warning -Message 'All other cmdlets, such as Export-M365DSCConfiguration, have to be run from PowerShell 7. You can download the latest release from: https://aka.ms/powershell-release'
