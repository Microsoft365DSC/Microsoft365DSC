BeforeAll {
    $Script:DllLoaderModule = Import-Module "$PSScriptRoot/../../../Modules/Microsoft365DSC/Modules/M365DSCDllLoader.psm1" -Force -Global -PassThru
}

Describe 'M365DSCDllLoader' {
    AfterAll {
        # Leave the loader initialized for the tests that follow in the same session.
        Initialize-M365DSCDllLoader
    }

    It 'Throws the build hint when a dll file is missing' {
        & $Script:DllLoaderModule { $Script:AssembliesInitialized = $false }
        Mock -ModuleName M365DSCDllLoader -CommandName Test-Path -MockWith { $Path -notlike '*Microsoft365DSC.Compare.dll' }

        { Initialize-M365DSCDllLoader -WarningAction Stop } |
            Should -Throw '*Microsoft365DSC.Compare.dll not found at:*Please run Utilities/Build-DllFiles.ps1 to build the dll file.'
        & $Script:DllLoaderModule { $Script:AssembliesInitialized } | Should -BeFalse
    }

    It 'Loads the dll files again without warnings' {
        & $Script:DllLoaderModule { $Script:AssembliesInitialized = $false }

        { Initialize-M365DSCDllLoader -WarningAction Stop } | Should -Not -Throw
        & $Script:DllLoaderModule { $Script:AssembliesInitialized } | Should -BeTrue
    }
}
