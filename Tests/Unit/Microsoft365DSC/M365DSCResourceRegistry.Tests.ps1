BeforeAll {
    Import-Module "$PSScriptRoot/../../../Modules/Microsoft365DSC/Modules/M365DSCDllLoader.psm1" -Force -Global
    Initialize-M365DSCDllLoader
    $Script:ModulePath = (Resolve-Path -Path "$PSScriptRoot/../../../Modules/Microsoft365DSC/Microsoft365DSC.psd1").Path
    Import-Module $Script:ModulePath -Global -WarningAction SilentlyContinue
}

Describe 'M365DSCResourceBase registry' {
    It 'resolves the resource classes that the calling runspace imported' {
        $parentAssembly = (New-M365DSCResourceInstance -ResourceName 'AADGroup').GetType().Assembly

        $runspace = [System.Management.Automation.Runspaces.RunspaceFactory]::CreateRunspace()
        $runspace.Open()
        $powershell = [System.Management.Automation.PowerShell]::Create()
        $powershell.Runspace = $runspace
        try
        {
            $null = $powershell.AddScript({
                    param ($Path)
                    Import-Module $Path -WarningAction SilentlyContinue
                    (New-M365DSCResourceInstance -ResourceName 'AADGroup').GetType().Assembly
                }).AddArgument($Script:ModulePath)
            $childAssembly = @($powershell.Invoke())[0]

            $childAssembly | Should -Not -BeNullOrEmpty
            [object]::ReferenceEquals($childAssembly, $parentAssembly) | Should -BeFalse
            $afterChildImport = (New-M365DSCResourceInstance -ResourceName 'AADGroup').GetType().Assembly
            [object]::ReferenceEquals($afterChildImport, $parentAssembly) | Should -BeTrue
        }
        finally
        {
            $powershell.Dispose()
            $runspace.Dispose()
        }
    }

    It 'releases a disposed runspace that created resource instances' {
        $weakRunspace = & {
            $runspace = [System.Management.Automation.Runspaces.RunspaceFactory]::CreateRunspace()
            $runspace.Open()
            $powershell = [System.Management.Automation.PowerShell]::Create()
            $powershell.Runspace = $runspace
            $null = $powershell.AddScript({
                    param ($Path)
                    Import-Module $Path -WarningAction SilentlyContinue
                    $null = New-M365DSCResourceInstance -ResourceName 'AADGroup'
                }).AddArgument($Script:ModulePath)
            $null = $powershell.Invoke()
            $powershell.Dispose()
            $runspace.Dispose()
            [System.WeakReference]::new($runspace)
        }

        foreach ($attempt in 1..3)
        {
            [System.GC]::Collect()
            [System.GC]::WaitForPendingFinalizers()
        }

        $weakRunspace.IsAlive | Should -BeFalse
    }
}
