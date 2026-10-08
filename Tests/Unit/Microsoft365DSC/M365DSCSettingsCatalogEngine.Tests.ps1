BeforeAll {
    Import-Module "$PSScriptRoot/../../../Modules/Microsoft365DSC/Modules/M365DSCDllLoader.psm1" -Force -Global
    Initialize-M365DSCDllLoader

    $Script:FixtureRoot = Join-Path -Path $PSScriptRoot -ChildPath 'Fixtures/SettingsCatalog'

    function ConvertTo-CaseInsensitive
    {
        param($Node)

        if ($Node -is [System.Collections.IDictionary])
        {
            $hashtable = [System.Collections.Hashtable]::new([System.StringComparer]::OrdinalIgnoreCase)
            foreach ($key in $Node.Keys)
            {
                $hashtable[$key] = ConvertTo-CaseInsensitive -Node $Node[$key]
            }
            return $hashtable
        }

        if ($Node -is [System.Collections.IList] -and $Node -isnot [string])
        {
            return , [object[]] @($Node | ForEach-Object -Process { , (ConvertTo-CaseInsensitive -Node $_) })
        }

        return $Node
    }

    function ConvertTo-Canonical
    {
        param($Node)

        if ($Node -is [System.Collections.IDictionary])
        {
            $ordered = [ordered]@{ }
            foreach ($key in ($Node.Keys | Sort-Object))
            {
                $ordered[$key] = ConvertTo-Canonical -Node $Node[$key]
            }
            return $ordered
        }

        if ($Node -is [System.Collections.IList] -and $Node -isnot [string])
        {
            return , @($Node | ForEach-Object -Process { , (ConvertTo-Canonical -Node $_) })
        }

        return $Node
    }

    function Import-Fixture
    {
        param([System.String] $Name)

        return ConvertTo-CaseInsensitive -Node ([object[]] (Get-Content -Path (Join-Path -Path $Script:FixtureRoot -ChildPath $Name) -Raw | ConvertFrom-Json -AsHashtable -Depth 40))
    }

    function Get-Golden
    {
        param([System.String] $Name)

        return (Get-Content -Path (Join-Path -Path $Script:FixtureRoot -ChildPath $Name) -Raw).TrimEnd()
    }
}

Describe 'Settings Catalog engine against captured Security Baseline payloads' -ForEach @(
    @{ Baseline = 'IntuneSecurityBaselineDefenderForEndpoint'; Settings = 57; Templates = 65 }
    @{ Baseline = 'IntuneSecurityBaselineHoloLens2Standard'; Settings = 23; Templates = 23 }
    @{ Baseline = 'IntuneSecurityBaselineMicrosoft365AppsForEnterprise'; Settings = 125; Templates = 128 }
    @{ Baseline = 'IntuneSecurityBaselineWindows10'; Settings = 329; Templates = 330 }
) {
    BeforeAll {
        $Script:Templates = Import-Fixture -Name "$Baseline.settingTemplates.json"
        $Script:Settings = Import-Fixture -Name "$Baseline.policySettings.json"
        $Script:Exported = [Microsoft365DSC.Intune.SettingCatalogPolicyExporter]::Export([object[]] $Script:Settings, @{ }, $null, $true)
    }

    It 'Loads the <Baseline> fixtures' {
        $Script:Settings.Count | Should -Be $Settings
        $Script:Templates.Count | Should -Be $Templates
    }

    It 'Exports <Baseline> settings into the pinned DSC parameter set' {
        ((ConvertTo-Canonical -Node $Script:Exported) | ConvertTo-Json -Depth 40).TrimEnd() | Should -BeExactly (Get-Golden -Name "$Baseline.export.expected.json")
    }

    It 'Builds the pinned <Baseline> policy body from the exported parameters' {
        $built = [Microsoft365DSC.Intune.SettingCatalogPolicySettingBuilder]::Build([System.Collections.Generic.List[object]] $Script:Templates, $Script:Exported.Clone(), $true)

        $built.Count | Should -Be $Settings
        ((ConvertTo-Canonical -Node @($built)) | ConvertTo-Json -Depth 40).TrimEnd() | Should -BeExactly (Get-Golden -Name "$Baseline.build.expected.json")
    }

    It 'Resolves the same setting names on repeated calls for <Baseline>' {
        $definitions = [System.Collections.Generic.List[object]]::new()
        foreach ($template in $Script:Templates)
        {
            foreach ($definition in $template['settingDefinitions'])
            {
                $definitions.Add($definition)
            }
        }

        $first = [Microsoft365DSC.Intune.SettingsCatalogHelper]::GetSettingName($definitions[0], $definitions)
        $second = [Microsoft365DSC.Intune.SettingsCatalogHelper]::GetSettingName($definitions[0], $definitions)
        $first | Should -Be $second
        $first | Should -Not -BeNullOrEmpty
    }
}
