BeforeAll {
    $Script:UtilModule = Get-Module -Name 'M365DSCUtil' -All | Select-Object -First 1
    if ($null -eq $Script:UtilModule)
    {
        $Script:UtilModule = Import-Module "$PSScriptRoot/../../../Modules/Microsoft365DSC/Modules/M365DSCUtil.psm1" -DisableNameChecking -PassThru
    }

    $Script:ModuleMgmtModule = Get-Module -Name 'M365DSCModuleMgmt' -All | Select-Object -First 1
    if ($null -eq $Script:ModuleMgmtModule)
    {
        $Script:ModuleMgmtModule = Import-Module "$PSScriptRoot/../../../Modules/Microsoft365DSC/Modules/M365DSCModuleMgmt.psm1" -DisableNameChecking -PassThru
    }
}

Describe 'M365DSCPowerShellSession' {
    It 'Imports the manifest of the Microsoft365DSC instance that creates the relay session' {
        $manifestPath = & $Script:UtilModule { $script:M365DSCModuleManifestPath }
        $expectedPath = Join-Path -Path (Split-Path -Path (Split-Path -Path $Script:UtilModule.Path -Parent) -Parent) -ChildPath 'Microsoft365DSC.psd1'

        $manifestPath | Should -Be $expectedPath
        Test-Path -Path $manifestPath | Should -BeTrue
    }

    It 'Registers no PnP resolver when PnP.PowerShell ships no Microsoft.Identity.Client' {
        { & $Script:ModuleMgmtModule { param($Base) Register-M365DSCPnPIdentityClientResolver -ModuleBase $Base } $TestDrive } | Should -Not -Throw
    }
}
