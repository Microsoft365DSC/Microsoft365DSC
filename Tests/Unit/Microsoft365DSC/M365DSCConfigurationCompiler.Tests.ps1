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
