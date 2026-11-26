BeforeDiscovery {
    $repositoryRoot = Join-Path -Path $PSScriptRoot -ChildPath '../..' -Resolve
    . (Join-Path -Path $repositoryRoot -ChildPath 'Utilities/Get-M365DSCIntuneTemplateBinding.ps1')

    $registryPath = Join-Path -Path $repositoryRoot -ChildPath 'Modules/Microsoft365DSC/IntuneTemplateRegistry.json'
    $registry = Get-Content -Path $registryPath -Raw | ConvertFrom-Json

    $bindings = @(Get-M365DSCIntuneTemplateBinding -ResourcePath (Join-Path -Path $repositoryRoot -ChildPath 'Modules/Microsoft365DSC/DscResources')) |
        ForEach-Object -Process {
            @{
                ResourceName = $_.Resource
                TemplateId   = $_.TemplateId
                Registered   = $registry.PSObject.Properties[$_.Resource].Value
            }
        }

}

Describe 'IntuneTemplateRegistry' {
    Context 'Every resource that pins a template is registered' {
        It "Should register '<ResourceName>' with the template it pins" -TestCases $bindings {
            $Registered | Should -Be $TemplateId -Because "IntuneTemplateRegistry.json is a scrape of the resources (run Utilities/Build-IntuneTemplateRegistry.ps1)"
        }
    }

    Context 'The registry holds nothing else' {
        BeforeAll {
            $repositoryRoot = Join-Path -Path $PSScriptRoot -ChildPath '../..' -Resolve
            . (Join-Path -Path $repositoryRoot -ChildPath 'Utilities/Get-M365DSCIntuneTemplateBinding.ps1')

            $registered = @((Get-Content -Path (Join-Path -Path $repositoryRoot -ChildPath 'Modules/Microsoft365DSC/IntuneTemplateRegistry.json') -Raw |
                        ConvertFrom-Json).PSObject.Properties.Name)
            $bound = @((Get-M365DSCIntuneTemplateBinding -ResourcePath (Join-Path -Path $repositoryRoot -ChildPath 'Modules/Microsoft365DSC/DscResources')).Resource)

            $script:orphans = @($registered | Where-Object -FilterScript { $_ -notin $bound })
        }

        It 'Should register no resource that pins no template' {
            $script:orphans -join ', ' | Should -BeNullOrEmpty -Because 'IntuneTemplateRegistry.json must not outlive the resources it names (run Utilities/Build-IntuneTemplateRegistry.ps1)'
        }
    }
}
