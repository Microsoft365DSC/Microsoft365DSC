BeforeAll {
    $resourcesPath = Join-Path -Path $PSScriptRoot -ChildPath '../../Modules/Microsoft365DSC/DscResources'
    Import-Module (Join-Path -Path $PSScriptRoot -ChildPath '../../Modules/Microsoft365DSC/Modules/M365DSCIntuneUtil.psm1') -Force -Global

    $Script:Consumers = @{}
    foreach ($file in Get-ChildItem -Path $resourcesPath -Filter 'MSFT_*.psm1' -Recurse)
    {
        foreach ($match in [regex]::Matches((Get-Content -Path $file.FullName -Raw), "Get-M365DSCExportCachedCollection\s+-Collection\s+'(\w+)'"))
        {
            $key = $match.Groups[1].Value
            if (-not $Script:Consumers.ContainsKey($key))
            {
                $Script:Consumers[$key] = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
            }
            $null = $Script:Consumers[$key].Add(($file.BaseName -replace '^MSFT_', ''))
        }
    }
    $Script:Map = Get-M365DSCExportCollectionConsumerMap
}

Describe 'Export collection consumer map' {
    It 'declares every collection used by a resource' {
        @($Script:Consumers.Keys | Where-Object -FilterScript { -not $Script:Map.ContainsKey($_) }) | Should -BeNullOrEmpty
    }

    It 'lists exactly the resources that call Get-M365DSCExportCachedCollection for <_>' -ForEach @('deviceConfigurations', 'deviceCompliancePolicies', 'deviceEnrollmentConfigurations', 'pimGroups', 'reusablePolicySettings') {
        $expected = @(if ($Script:Consumers.ContainsKey($_)) { $Script:Consumers[$_] } else { @() }) | Sort-Object
        $actual = @($Script:Map[$_]) | Sort-Object
        $actual | Should -Be $expected
    }
}

AfterAll {
    Remove-Module -Name M365DSCIntuneUtil -Force -ErrorAction SilentlyContinue
}
