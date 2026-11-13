BeforeAll {
    if (-not (Test-Path -Path 'Function:\New-M365DSCLogEntry'))
    {
        Import-Module -Name "$PSScriptRoot/../Stubs/Generic.psm1" -Function 'New-M365DSCLogEntry' -Global -WarningAction SilentlyContinue
    }

    $Script:ModuleMgmtModule = Get-Module -Name 'M365DSCModuleMgmt' -All | Select-Object -First 1
    if ($null -eq $Script:ModuleMgmtModule)
    {
        $Script:ModuleMgmtModule = Import-Module "$PSScriptRoot/../../../Modules/Microsoft365DSC/Modules/M365DSCModuleMgmt.psm1" -DisableNameChecking -PassThru
    }

    function Set-TestDependencies
    {
        param ([System.Collections.Hashtable[]] $Dependencies)

        & $Script:ModuleMgmtModule {
            param ($Dependencies)

            $saved = @{
                Dependencies    = $Script:M365DSCDependencies
                DevDependencies = $Script:M365DSCDevDependencies
                PsResourceGet   = $Script:IsPsResourceGetAvailable
            }
            $Script:M365DSCDependencies = [System.Collections.Generic.Dictionary[System.String, System.Object]]::new([System.StringComparer]::OrdinalIgnoreCase)
            foreach ($dependency in $Dependencies)
            {
                $Script:M365DSCDependencies.Add($dependency.ModuleName, $dependency)
            }
            $Script:M365DSCDevDependencies = [System.Collections.Generic.Dictionary[System.String, System.Object]]::new([System.StringComparer]::OrdinalIgnoreCase)
            return $saved
        } $Dependencies
    }

    function Restore-TestDependencies
    {
        param ($Saved)

        & $Script:ModuleMgmtModule {
            param ($Saved)

            $Script:M365DSCDependencies = $Saved.Dependencies
            $Script:M365DSCDevDependencies = $Saved.DevDependencies
            $Script:IsPsResourceGetAvailable = $Saved.PsResourceGet
        } $Saved
    }
}

Describe 'M365DSCModuleMgmt' {
    Context 'Test-M365DSCDependenciesForNewVersions' {
        BeforeAll {
            $Script:Saved = Set-TestDependencies -Dependencies @(
                @{ ModuleName = 'Test.NotInstalled'; RequiredVersion = '1.0.0' }
                @{ ModuleName = 'Test.Outdated'; RequiredVersion = '1.0.0' }
                @{ ModuleName = 'Test.Current'; RequiredVersion = '2.0.0' }
                @{ ModuleName = 'Test.NotInGallery'; RequiredVersion = '1.0.0' }
            )
            & $Script:ModuleMgmtModule { $Script:IsPsResourceGetAvailable = $true }
        }

        AfterAll {
            Restore-TestDependencies -Saved $Script:Saved
        }

        BeforeEach {
            $Script:HostMessages = @()
            Mock -ModuleName M365DSCModuleMgmt -CommandName Write-Host -MockWith {
                $Script:HostMessages += [System.String]$Object
            }
            Mock -ModuleName M365DSCModuleMgmt -CommandName Find-PSResource -MockWith {
                @(
                    [PSCustomObject]@{ Name = 'Test.NotInstalled'; Version = [System.Version]'1.5.0' }
                    [PSCustomObject]@{ Name = 'Test.Outdated'; Version = [System.Version]'1.2.0' }
                    [PSCustomObject]@{ Name = 'Test.Current'; Version = [System.Version]'2.0.0' }
                )
            }
            Mock -ModuleName M365DSCModuleMgmt -CommandName Get-Module -ParameterFilter { $ListAvailable } -MockWith {
                switch ($Name)
                {
                    'Test.Outdated' { @([PSCustomObject]@{ Name = 'Test.Outdated'; Version = [System.Version]'1.0.0' }, [PSCustomObject]@{ Name = 'Test.Outdated'; Version = [System.Version]'1.1.0' }) }
                    'Test.Current' { [PSCustomObject]@{ Name = 'Test.Current'; Version = [System.Version]'2.0.0' } }
                    default { $null }
                }
            }
        }

        It 'Queries the gallery once and reports each dependency against its own installed versions' {
            Test-M365DSCDependenciesForNewVersions

            Should -Invoke -ModuleName M365DSCModuleMgmt -CommandName Find-PSResource -Times 1 -Exactly -ParameterFilter { $null -eq $Repository }
            $Script:HostMessages | Should -HaveCount 3
            $Script:HostMessages[0] | Should -Be 'Module {Test.NotInstalled} is not installed, latest version available is {1.5.0}'
            $Script:HostMessages[1] | Should -Be 'New version of {Test.Outdated} is available {1.2.0}'
            $Script:HostMessages[2] | Should -Be 'Module {Test.NotInGallery} was not found in the gallery'
        }

        It 'Writes a single error instead of per-module messages when the gallery query fails entirely' {
            Mock -ModuleName M365DSCModuleMgmt -CommandName Find-PSResource -MockWith {
                Write-Error -Message 'Repository is unreachable.' -ErrorAction SilentlyContinue
            }

            Test-M365DSCDependenciesForNewVersions -ErrorVariable queryErrors -ErrorAction SilentlyContinue

            $wrappedErrors = @($queryErrors | Where-Object { $_.Exception.Message -like 'Could not query the gallery*' })
            $wrappedErrors | Should -HaveCount 1
            $wrappedErrors[0].Exception.Message | Should -BeLike '*Repository is unreachable.*'
            $Script:HostMessages | Should -HaveCount 0
        }
    }

    Context 'Update-M365DSCDependencies -ValidateOnly' {
        BeforeAll {
            $Script:Saved = Set-TestDependencies -Dependencies @(
                @{ ModuleName = 'Test.Present'; RequiredVersion = '1.0.0' }
                @{ ModuleName = 'Test.Missing'; RequiredVersion = '1.0.0' }
            )
            & $Script:ModuleMgmtModule { $Script:IsPsResourceGetAvailable = $false }
        }

        AfterAll {
            Restore-TestDependencies -Saved $Script:Saved
        }

        It 'Returns only the missing dependency and installs nothing' {
            Mock -ModuleName M365DSCModuleMgmt -CommandName Install-Module -MockWith {}
            Mock -ModuleName M365DSCModuleMgmt -CommandName Install-PSResource -MockWith {}
            Mock -ModuleName M365DSCModuleMgmt -CommandName Get-PSResource -MockWith { $null }
            Mock -ModuleName M365DSCModuleMgmt -CommandName Get-Module -ParameterFilter { $ListAvailable } -MockWith { $null }
            Mock -ModuleName M365DSCModuleMgmt -CommandName Test-M365DSCDependencyManifestPath -MockWith { $ModuleName -eq 'Test.Present' }
            Mock -ModuleName M365DSCModuleMgmt -CommandName Test-M365DSCCurrentUserIsAdministrator -MockWith { $false }

            $result = Update-M365DSCDependencies -ValidateOnly -ErrorAction Stop

            @($result).ModuleName | Should -Be @('Test.Missing')
            Should -Invoke -ModuleName M365DSCModuleMgmt -CommandName Test-M365DSCCurrentUserIsAdministrator -Times 0 -Exactly
            Should -Invoke -ModuleName M365DSCModuleMgmt -CommandName Install-Module -Times 0 -Exactly
            Should -Invoke -ModuleName M365DSCModuleMgmt -CommandName Install-PSResource -Times 0 -Exactly
            Should -Invoke -ModuleName M365DSCModuleMgmt -CommandName Get-PSResource -Times 0 -Exactly
        }
    }

    Context 'Remove-M365DSCInstalledModuleVersion' {
        BeforeAll {
            $moduleFolder = Join-Path -Path $TestDrive -ChildPath 'Test.Fake/1.0.0'
            New-Item -Path $moduleFolder -ItemType Directory -Force | Out-Null
            New-ModuleManifest -Path (Join-Path -Path $moduleFolder -ChildPath 'Test.Fake.psd1') -ModuleVersion '1.0.0'
            $Script:FakeModule = Test-ModuleManifest -Path (Join-Path -Path $moduleFolder -ChildPath 'Test.Fake.psd1')
        }

        It 'Reports the module and adds the administrator hint for an access-denied error under Program Files' -Skip:(-not $IsWindows) {
            Mock -ModuleName M365DSCModuleMgmt -CommandName Remove-Item -MockWith { throw [System.UnauthorizedAccessException]::new('Access to the path is denied.') }
            Mock -ModuleName M365DSCModuleMgmt -CommandName New-M365DSCLogEntry -MockWith {}
            Mock -ModuleName M365DSCModuleMgmt -CommandName Test-M365DSCCurrentUserIsAdministrator -MockWith { $false }
            $originalProgramFiles = $env:ProgramFiles
            try
            {
                $env:ProgramFiles = $TestDrive
                $errors = & $Script:ModuleMgmtModule { param ($Module) Remove-M365DSCInstalledModuleVersion -Module $Module -InformationAction SilentlyContinue 2>&1 } $Script:FakeModule
            }
            finally
            {
                $env:ProgramFiles = $originalProgramFiles
            }

            @($errors)[0].Exception.Message | Should -Be 'Could not uninstall Test.Fake Version 1.0.0. You need to run this command as a local administrator.'
            Should -Invoke -ModuleName M365DSCModuleMgmt -CommandName New-M365DSCLogEntry -Times 1 -Exactly
        }

        It 'Omits the administrator hint for a module outside Program Files' {
            Mock -ModuleName M365DSCModuleMgmt -CommandName Remove-Item -MockWith { throw [System.UnauthorizedAccessException]::new('Access to the path is denied.') }
            Mock -ModuleName M365DSCModuleMgmt -CommandName New-M365DSCLogEntry -MockWith {}

            $errors = & $Script:ModuleMgmtModule { param ($Module) Remove-M365DSCInstalledModuleVersion -Module $Module -InformationAction SilentlyContinue 2>&1 } $Script:FakeModule

            @($errors)[0].Exception.Message | Should -Be 'Could not uninstall Test.Fake Version 1.0.0'
        }
    }

    Context 'Confirm-M365DSCLoadedModule' {
        It 'Warns and still imports a module that is missing from the manifest' {
            Mock -ModuleName M365DSCModuleMgmt -CommandName Import-M365DSCDependencyModule -MockWith {}
            Mock -ModuleName M365DSCModuleMgmt -CommandName Get-Module -MockWith { $null }

            try
            {
                Confirm-M365DSCLoadedModule -ModuleName 'Test.NotInManifest' -WarningVariable warnings -WarningAction SilentlyContinue
            }
            finally
            {
                & $Script:ModuleMgmtModule { [void]$Script:M365DSCValidatedDependencies.Remove('Test.NotInManifest') }
            }

            $warnings | Should -HaveCount 1
            $warnings[0].Message | Should -BeLike "Module 'Test.NotInManifest' is not declared in Dependencies/Manifest.psd1*"
            Should -Invoke -ModuleName M365DSCModuleMgmt -CommandName Import-M365DSCDependencyModule -Times 1 -Exactly -ParameterFilter { $Parameters.Name -eq 'Test.NotInManifest' }
        }
    }

    Context 'Initialize-M365DSCModuleMgmt' {
        It 'Warns about a settings.json commands module that is missing from the manifest instead of failing' {
            Mock -ModuleName M365DSCModuleMgmt -CommandName Import-M365DSCResourceSettings -MockWith {
                $settings = [System.Collections.Generic.Dictionary[System.String, System.Object]]::new([System.StringComparer]::OrdinalIgnoreCase)
                $settings.Add('TestResource', [PSCustomObject]@{
                    commands        = @([PSCustomObject]@{ module = 'Test.NotInManifest'; cmdlets = @('Get-TestItem') })
                    requiredModules = @()
                    mode            = $null
                })
                return , $settings
            }

            $warnings = & $Script:ModuleMgmtModule {
                $saved = @{}
                foreach ($name in 'M365DSCDependencies', 'M365DSCDevDependencies', 'M365DSCResourceSettings', 'M365DSCValidatedDependencies', 'CurrentConfiguration', 'M365DSCRequiredModules', 'M365DSCRequiredModulesLoaded')
                {
                    $saved[$name] = Get-Variable -Name $name -Scope Script -ValueOnly
                }
                try
                {
                    $Script:M365DSCDependencies = $null
                    Initialize-M365DSCModuleMgmt -WarningVariable initWarnings -WarningAction SilentlyContinue
                    $initWarnings
                }
                finally
                {
                    foreach ($name in $saved.Keys)
                    {
                        Set-Variable -Name $name -Scope Script -Value $saved[$name]
                    }
                }
            }

            $warnings | Should -HaveCount 1
            $warnings[0].Message | Should -BeLike "Module 'Test.NotInManifest' is referenced*{TestResource}*missing from Dependencies/Manifest.psd1."
        }
    }
}
