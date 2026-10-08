BeforeDiscovery {
    $moduleRoot = Join-Path -Path $PSScriptRoot -ChildPath '../../Modules/Microsoft365DSC'
    $aggregatePath = Join-Path -Path $moduleRoot -ChildPath 'ResourcePermissions.json'
    $aggregateExists = Test-Path -Path $aggregatePath

    $resources = @()
    if ($aggregateExists)
    {
        $aggregate = Get-Content -Path $aggregatePath -Raw | ConvertFrom-Json
        $resources = Get-ChildItem -Path (Join-Path -Path $moduleRoot -ChildPath 'DscResources') -Filter 'settings.json' -Recurse -File | ForEach-Object {
            @{
                ResourceName = (Split-Path -Path $_.DirectoryName -Leaf).Replace('MSFT_', '')
                FullName     = $_.FullName
                Aggregate    = $aggregate
            }
        }
    }
}

Describe -Name 'ResourcePermissions.json covers the resource settings files' -Skip:(-not $aggregateExists) {
    It "Aggregate holds an entry for '<ResourceName>'" -TestCases $resources {
        $Aggregate.PSObject.Properties.Name | Should -Contain $ResourceName
    }

    It "Aggregate entry for '<ResourceName>' matches its settings.json" -TestCases $resources {
        $source = Get-Content -Path $FullName -Raw | ConvertFrom-Json

        $entry = ConvertTo-Json -InputObject $Aggregate.$ResourceName -Depth 99 -Compress
        $expected = ConvertTo-Json -InputObject $source -Depth 99 -Compress

        $entry | Should -Be $expected
    }
}
