BeforeAll {
    $script:ModulesRoot = Join-Path (Split-Path (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent) -Parent) 'Modules\Microsoft365DSC\Modules' -Resolve
    $script:CompilerText = [System.IO.File]::ReadAllText((Join-Path $script:ModulesRoot 'M365DSCConfigurationCompiler.psm1'))
    $script:ReverseText = [System.IO.File]::ReadAllText((Join-Path $script:ModulesRoot 'M365DSCReverse.psm1'))
}

Describe 'Fast compile host contract' {
    It 'the compiler wrapper uses the PSDscFastCompileActive recursion guard' {
        $script:CompilerText | Should -Match '\$Global:PSDscFastCompileActive'
    }

    It 'the export trailer emits the plain configuration invocation only' {
        $script:ReverseText | Should -Match '\$DSCContent\.Append\("\$launchCommand"\)'
        $script:ReverseText | Should -Not -Match 'Invoke-M365DSCConfigurationBuild -Path `\$PSCommandPath'
    }

    It 'the compiler exports the approved-verb name' {
        $script:CompilerText | Should -Match 'function Invoke-M365DSCConfigurationBuild'
    }

    It 'the wrapper probes for the M365DSCFastHost engine tag' {
        $script:CompilerText | Should -Match 'M365DSCFastHost'
    }
}

Describe 'Invoke-M365DSCConfigurationBuild standard pipeline' {
    BeforeAll {
        Import-Module (Join-Path $script:ModulesRoot 'M365DSCConfigurationCompiler.psm1') -Force
        Mock -ModuleName 'M365DSCConfigurationCompiler' -CommandName Test-M365DSCFastCompileAvailable -MockWith { $false }

        $script:ScriptPath = Join-Path $TestDrive 'M365TenantConfig.ps1'
        Set-Content -Path $script:ScriptPath -Value "'compiled'; `$Global:PSDscFastCompileActive"
    }

    AfterEach {
        Remove-Variable -Name 'PSDscFastCompileActive' -Scope Global -ErrorAction 'SilentlyContinue'
    }

    It 'runs the script and warns about parameters it cannot apply without ConfigurationName' {
        $result = Invoke-M365DSCConfigurationBuild -Path $script:ScriptPath -Engine Standard -OutputPath (Join-Path $TestDrive 'Out') -ConfigurationData @{ AllNodes = @() } -WarningVariable warnings -WarningAction SilentlyContinue

        $result[0] | Should -Be 'compiled'
        $warnings.Count | Should -Be 1
        $warnings[0].Message | Should -Match 'Ignoring: OutputPath, ConfigurationData\.'
    }

    It 'sets the recursion guard while running and restores the previous value afterwards' {
        $Global:PSDscFastCompileActive = $true

        $result = Invoke-M365DSCConfigurationBuild -Path $script:ScriptPath -Engine Standard

        $result[1] | Should -BeTrue
        $Global:PSDscFastCompileActive | Should -BeTrue
    }

    It 'resets the recursion guard to $false when it was not set before' {
        $null = Invoke-M365DSCConfigurationBuild -Path $script:ScriptPath -Engine Standard

        $Global:PSDscFastCompileActive | Should -BeFalse
    }

    It 'throws a terminating error for a missing script path' {
        { Invoke-M365DSCConfigurationBuild -Path (Join-Path $TestDrive 'Missing.ps1') -Engine Standard } | Should -Throw -ErrorId 'PathNotFound*'
    }
}
