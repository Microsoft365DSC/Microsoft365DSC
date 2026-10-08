BeforeAll {
    $script:repositoryRoot = Join-Path -Path $PSScriptRoot -ChildPath '../../..' -Resolve
    $script:scriptPath = Join-Path -Path $script:repositoryRoot -ChildPath 'Utilities/Update-ResourceOrigin.ps1' -Resolve
    $script:fixtureRoot = Join-Path -Path $PSScriptRoot -ChildPath 'Fixtures' -Resolve

    function Invoke-OriginFixture
    {
        param
        (
            [Parameter(Mandatory = $true)]
            [System.String]
            $Name,

            [Parameter()]
            [switch]
            $Force,

            [Parameter()]
            [System.String]
            $ResourceFilter = '*'
        )

        $work = Join-Path -Path $TestDrive -ChildPath $Name
        $resourceRoot = Join-Path -Path $work -ChildPath 'Resources'
        if (-not (Test-Path -Path $resourceRoot))
        {
            $null = New-Item -Path $resourceRoot -ItemType Directory -Force
            Copy-Item -Path (Join-Path -Path $script:fixtureRoot -ChildPath 'Resources/*') -Destination $resourceRoot -Recurse -Force
        }
        $unresolvedPath = Join-Path -Path $work -ChildPath 'unresolved.md'

        $summary = & $script:scriptPath -RepositoryRoot $script:repositoryRoot `
            -ResourcePath $resourceRoot `
            -CmdletMappingPath (Join-Path -Path $script:fixtureRoot -ChildPath 'cmdlet-mapping.json') `
            -CsdlPathV1 (Join-Path -Path $script:fixtureRoot -ChildPath 'csdl-v1.0.xml') `
            -CsdlPathBeta (Join-Path -Path $script:fixtureRoot -ChildPath 'csdl-beta.xml') `
            -UnresolvedPath $unresolvedPath `
            -ResourceFilter $ResourceFilter `
            -Force:$Force

        return @{
            Root       = $resourceRoot
            Summary    = $summary
            Unresolved = $unresolvedPath
        }
    }

    function Get-FixtureSettings
    {
        param
        (
            [Parameter(Mandatory = $true)]
            [System.String]
            $Root,

            [Parameter(Mandatory = $true)]
            [System.String]
            $Resource
        )

        return Get-Content -Path (Join-Path -Path $Root -ChildPath "MSFT_$Resource/settings.json") -Raw | ConvertFrom-Json
    }

    function Get-UnresolvedReason
    {
        param
        (
            [Parameter(Mandatory = $true)]
            [System.Object]
            $Run,

            [Parameter(Mandatory = $true)]
            [System.String]
            $Resource
        )

        return ($Run.Summary.UnresolvedRows | Where-Object { $_.Resource -eq $Resource } | Select-Object -First 1).Reason
    }
}

Describe 'Update-ResourceOrigin.ps1' {
    Context 'Graph resources' {
        BeforeAll {
            $script:run = Invoke-OriginFixture -Name 'graph'
        }

        It 'resolves an entity set navigation under a singleton' {
            $origin = (Get-FixtureSettings -Root $script:run.Root -Resource 'AADAttributeSet').generatedFrom
            $origin.workload | Should -Be 'MicrosoftGraph'
            $origin.apiVersion | Should -Be 'beta'
            $origin.entityType | Should -Be 'attributeSet'
            $origin.odataSubtype | Should -BeNullOrEmpty
            $origin.cmdletNoun | Should -Be 'MgBetaDirectoryAttributeSet'
            $origin.cmdletVerb | Should -Be 'New'
            $origin.includeNavigationProperties | Should -BeFalse
            $generatorManifest = Import-PowerShellDataFile -Path (Join-Path -Path $script:repositoryRoot -ChildPath 'ResourceGenerator/M365DSCResourceGenerator.psd1')
            $origin.generatorVersion | Should -Be $generatorManifest.ModuleVersion
        }

        It 'resolves a v1.0 entity set and flags declared navigation properties' {
            $origin = (Get-FixtureSettings -Root $script:run.Root -Resource 'AADGroup').generatedFrom
            $origin.apiVersion | Should -Be 'v1.0'
            $origin.entityType | Should -Be 'group'
            $origin.cmdletNoun | Should -Be 'MgGroup'
            $origin.includeNavigationProperties | Should -BeTrue
        }

        It 'records the concrete subtype of a polymorphic entity and the Intune workload' {
            $origin = (Get-FixtureSettings -Root $script:run.Root -Resource 'IntuneDeviceCompliancePolicyWindows10').generatedFrom
            $origin.workload | Should -Be 'Intune'
            $origin.entityType | Should -Be 'deviceCompliancePolicy'
            $origin.odataSubtype | Should -Be 'windows10CompliancePolicy'
            $origin.cmdletNoun | Should -Be 'MgBetaDeviceManagementDeviceCompliancePolicy'
        }

        It 'does not count Assignments as an included navigation property' {
            $origin = (Get-FixtureSettings -Root $script:run.Root -Resource 'IntuneDeviceCompliancePolicyWindows10').generatedFrom
            $origin.includeNavigationProperties | Should -BeFalse
        }

        It 'picks the noun with the most CRUD verbs over helper lookups' {
            $origin = (Get-FixtureSettings -Root $script:run.Root -Resource 'AADConditionalAccessPolicy').generatedFrom
            $origin.cmdletNoun | Should -Be 'MgBetaIdentityConditionalAccessPolicy'
            $origin.entityType | Should -Be 'conditionalAccessPolicy'
            $origin.cmdletVerb | Should -Be 'Get'
        }

        It 'ignores odata literals that are not derived entity types' {
            $origin = (Get-FixtureSettings -Root $script:run.Root -Resource 'AADConditionalAccessPolicy').generatedFrom
            $origin.odataSubtype | Should -BeNullOrEmpty
        }

        It 'keeps the sub-namespace of a type outside microsoft.graph' {
            $origin = (Get-FixtureSettings -Root $script:run.Root -Resource 'AADNetworkAccessFilteringProfile').generatedFrom
            $origin.entityType | Should -Be 'networkaccess.filteringProfile'
        }

        It 'resolves a plain Intune entity set' {
            $origin = (Get-FixtureSettings -Root $script:run.Root -Resource 'IntuneDeviceCategory').generatedFrom
            $origin.workload | Should -Be 'Intune'
            $origin.entityType | Should -Be 'deviceCategory'
        }

        It 'lets the generator auto-pick between several derived payload types by name' {
            $origin = (Get-FixtureSettings -Root $script:run.Root -Resource 'IntuneDeviceCompliancePolicyIos').generatedFrom
            $origin.entityType | Should -Be 'deviceCompliancePolicy'
            $origin.odataSubtype | Should -Be 'iosCompliancePolicy'
        }

        It 'falls back to isof() read filters when no payload names a subtype' {
            $origin = (Get-FixtureSettings -Root $script:run.Root -Resource 'IntuneDeviceCompliancePolicyFilterOnly').generatedFrom
            $origin.odataSubtype | Should -Be 'iosCompliancePolicy'
        }

        It 'lets an exact cmdlet noun match win over a subset match with the same verb count' {
            $origin = (Get-FixtureSettings -Root $script:run.Root -Resource 'AADNamedLocationExact').generatedFrom
            $origin.cmdletNoun | Should -Be 'MgBetaIdentityConditionalAccessNamedLocationExact'
            $origin.entityType | Should -Be 'namedLocation'
        }

        It 'prefers the parent noun over a child navigation noun that carries more verbs' {
            $origin = (Get-FixtureSettings -Root $script:run.Root -Resource 'AADAttributeSetChild').generatedFrom
            $origin.cmdletNoun | Should -Be 'MgBetaDirectoryAttributeSet'
            $origin.entityType | Should -Be 'attributeSet'
        }

        It 'ignores negated isof() filters and comment mentions when picking the subtype' {
            $origin = (Get-FixtureSettings -Root $script:run.Root -Resource 'IntuneDeviceCompliancePolicyNegated').generatedFrom
            $origin.odataSubtype | Should -Be 'windows10CompliancePolicy'
        }

        It 'trusts a weakly named Get-only noun when the walked type carries the declared properties' {
            $origin = (Get-FixtureSettings -Root $script:run.Root -Resource 'AADZetaSettings').generatedFrom
            $origin.entityType | Should -Be 'attributeSet'
            $origin.cmdletNoun | Should -Be 'MgBetaDirectoryAttributeSet'
            $origin.cmdletVerb | Should -Be 'Get'
        }

        It 'folds a v1.0 noun into its beta twin and records the beta surface' {
            $origin = (Get-FixtureSettings -Root $script:run.Root -Resource 'AADGroupTwin').generatedFrom
            $origin.cmdletNoun | Should -Be 'MgBetaGroup'
            $origin.apiVersion | Should -Be 'beta'
            $origin.entityType | Should -Be 'group'
            $origin.cmdletVerb | Should -Be 'New'
        }

        It 'keeps odataSubtype null when the payload creates the base type and only a read filter names a subtype' {
            $origin = (Get-FixtureSettings -Root $script:run.Root -Resource 'AADNamedLocationBase').generatedFrom
            $origin.entityType | Should -Be 'namedLocation'
            $origin.odataSubtype | Should -BeNullOrEmpty
        }

        It 'identifies the resource by its folder, not by a stale resourceName' {
            $settings = Get-FixtureSettings -Root $script:run.Root -Resource 'AADFolderIdentity'
            $settings.resourceName | Should -Be 'ResourceName'
            $settings.generatedFrom.entityType | Should -Be 'attributeSet'
        }
    }

    Context 'Non-Graph resources' {
        BeforeAll {
            $script:run = Invoke-OriginFixture -Name 'nongraph'
        }

        It 'records the Exchange Online cmdlet noun with the Set verb when New is absent' {
            $origin = (Get-FixtureSettings -Root $script:run.Root -Resource 'EXOAcceptedDomain').generatedFrom
            $origin.workload | Should -Be 'ExchangeOnline'
            $origin.apiVersion | Should -BeNullOrEmpty
            $origin.entityType | Should -BeNullOrEmpty
            $origin.cmdletNoun | Should -Be 'AcceptedDomain'
            $origin.cmdletVerb | Should -Be 'Set'
        }

        It 'maps ExchangeOnlineManagement cmdlets to SecurityComplianceCenter by the Connect call' {
            $origin = (Get-FixtureSettings -Root $script:run.Root -Resource 'SCLabelPolicy').generatedFrom
            $origin.workload | Should -Be 'SecurityComplianceCenter'
            $origin.cmdletNoun | Should -Be 'LabelPolicy'
            $origin.cmdletVerb | Should -Be 'New'
        }

        It 'records the Teams cmdlet noun' {
            $origin = (Get-FixtureSettings -Root $script:run.Root -Resource 'TeamsMeetingPolicy').generatedFrom
            $origin.workload | Should -Be 'MicrosoftTeams'
            $origin.cmdletNoun | Should -Be 'CsTeamsMeetingPolicy'
        }

        It 'lets the winning cmdlet decide between several Connect workloads' {
            $origin = (Get-FixtureSettings -Root $script:run.Root -Resource 'TeamsTeam').generatedFrom
            $origin.workload | Should -Be 'MicrosoftTeams'
            $origin.cmdletNoun | Should -Be 'Team'
        }

        It 'records only the workload for a REST-only resource' {
            $origin = (Get-FixtureSettings -Root $script:run.Root -Resource 'AzureThing').generatedFrom
            $origin.workload | Should -Be 'Azure'
            $origin.cmdletNoun | Should -BeNullOrEmpty
            ($script:run.Summary.UnresolvedRows | Where-Object { $_.Resource -eq 'AzureThing' }) | Should -BeNullOrEmpty
        }
    }

    Context 'Unresolved resources' {
        BeforeAll {
            $script:run = Invoke-OriginFixture -Name 'unresolved'
            $script:worklist = Get-Content -Path $script:run.Unresolved -Raw
        }

        It 'reports <Resource> with a reason mentioning <Fragment>' -TestCases @(
            @{ Resource = 'IntuneDeviceCompliancePolicyAmbiguous'; Fragment = 'several derived types' }
            @{ Resource = 'IntuneDeviceCompliancePolicyBare'; Fragment = 'abstract' }
            @{ Resource = 'AADUnknownSegment'; Fragment = "'unknownThings' is not a navigation property of 'directory'" }
            @{ Resource = 'AADNoMapping'; Fragment = 'cmdlet-mapping.json' }
            @{ Resource = 'AADSplitEntity'; Fragment = 'different entity types' }
            @{ Resource = 'AADPolicyAmbiguous'; Fragment = 'Ambiguous cmdlet noun' }
            @{ Resource = 'AADNoCommands'; Fragment = 'no commands array' }
            @{ Resource = 'AADNoCrud'; Fragment = 'no Get, New, Update, Set or Remove cmdlet' }
            @{ Resource = 'AzureTwoWorkloads'; Fragment = 'several workloads' }
            @{ Resource = 'M365DSCNoConnect'; Fragment = 'no $this.Connect() call' }
            @{ Resource = 'AADRestWithLookup'; Fragment = 'Get-only lookups' }
            @{ Resource = 'AADRestZeroName'; Fragment = 'calls Invoke-MgGraphRequest' }
            @{ Resource = 'EXOWrongModule'; Fragment = "implies workload MicrosoftTeams but the resource only connects to ExchangeOnline" }
            @{ Resource = 'AADZetaNoOverlap'; Fragment = "Only 0 of 2 declared properties exist on 'attributeSet'" }
            @{ Resource = 'IntuneDeviceCompliancePolicyConflict'; Fragment = 'writes windows10CompliancePolicy but reads with a filter on iosCompliancePolicy' }
        ) {
            $reason = Get-UnresolvedReason -Run $script:run -Resource $Resource
            $reason | Should -Not -BeNullOrEmpty
            $reason | Should -BeLike "*$Fragment*"
            $script:worklist | Should -BeLike "*| $Resource |*"
        }

        It 'writes a partial block with the workload but no entity type' {
            $origin = (Get-FixtureSettings -Root $script:run.Root -Resource 'IntuneDeviceCompliancePolicyBare').generatedFrom
            $origin.workload | Should -Be 'Intune'
            $origin.cmdletNoun | Should -Be 'MgBetaDeviceManagementDeviceCompliancePolicy'
            $origin.entityType | Should -BeNullOrEmpty
        }

        It 'does not list resolved resources on the worklist' {
            $script:worklist | Should -Not -BeLike '*| AADAttributeSet |*'
            $script:worklist | Should -Not -BeLike '*| AzureThing |*'
        }

        It 'counts the unresolved resources per workload' {
            $script:run.Summary.Unresolved | Should -Be 15
            $script:run.Summary.UnresolvedByWorkload['Intune'] | Should -Be 3
            $script:run.Summary.UnresolvedByWorkload['MicrosoftGraph'] | Should -Be 9
            $script:run.Summary.UnresolvedByWorkload['ExchangeOnline'] | Should -BeNullOrEmpty
            $script:run.Summary.UnresolvedByWorkload['(unknown)'] | Should -Be 3
        }

        It 'resolves a cmdlet workload resource that declares no CRUD cmdlet' {
            $origin = (Get-FixtureSettings -Root $script:run.Root -Resource 'EXONoCmdlets').generatedFrom
            $origin.workload | Should -Be 'ExchangeOnline'
            $origin.cmdletNoun | Should -BeNullOrEmpty
        }
    }

    Context 'Preservation of existing content' {
        BeforeAll {
            $script:run = Invoke-OriginFixture -Name 'preserve'
            $script:before = Get-Content -Path (Join-Path -Path $script:fixtureRoot -ChildPath 'Resources/MSFT_AADPreserve/settings.json') -Raw | ConvertFrom-Json
            $script:after = Get-FixtureSettings -Root $script:run.Root -Resource 'AADPreserve'
        }

        It 'inserts generatedFrom and excludedProperties directly after resourceName' {
            @($script:after.PSObject.Properties.Name)[0..2] | Should -Be @('resourceName', 'generatedFrom', 'excludedProperties')
        }

        It 'keeps every other key in its original order' {
            $expected = @($script:before.PSObject.Properties.Name | Where-Object { $_ -ne 'excludedProperties' })
            $actual = @($script:after.PSObject.Properties.Name | Where-Object { $_ -notin @('generatedFrom', 'excludedProperties') })
            $actual | Should -Be $expected
        }

        It 'keeps every other value unchanged' {
            foreach ($name in @($script:before.PSObject.Properties.Name | Where-Object { $_ -ne 'excludedProperties' }))
            {
                (ConvertTo-Json -InputObject $script:after.$name -Depth 10 -Compress) |
                    Should -Be (ConvertTo-Json -InputObject $script:before.$name -Depth 10 -Compress) -Because "'$name' must survive the rewrite"
            }
        }

        It 'keeps a human-authored excludedProperties array' {
            @($script:after.excludedProperties) | Should -HaveCount 1
            $script:after.excludedProperties[0].name | Should -Be 'createdDateTime'
            $script:after.excludedProperties[0].reason | Should -Be 'ReadOnly'
        }

        It 'writes an empty excludedProperties array when none exists' {
            $settings = Get-FixtureSettings -Root $script:run.Root -Resource 'AADAttributeSet'
            $settings.PSObject.Properties.Name | Should -Contain 'excludedProperties'
            @($settings.excludedProperties) | Should -HaveCount 0
        }

        It 'never writes lastVerified' {
            $script:after.PSObject.Properties.Name | Should -Not -Contain 'lastVerified'
        }

        It 'writes UTF-8 without a byte order mark and CRLF line endings' {
            $bytes = [System.IO.File]::ReadAllBytes((Join-Path -Path $script:run.Root -ChildPath 'MSFT_AADPreserve/settings.json'))
            ($bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF) | Should -BeFalse
            $text = [System.Text.Encoding]::UTF8.GetString($bytes)
            $text | Should -Match "`r`n"
            ($text -replace "`r`n", '') | Should -Not -Match "`n"
        }
    }

    Context 'Idempotence and skipping' {
        BeforeAll {
            $script:first = Invoke-OriginFixture -Name 'idempotent'
            $script:snapshot = @{}
            foreach ($file in Get-ChildItem -Path $script:first.Root -Filter 'settings.json' -Recurse -File)
            {
                $script:snapshot[$file.FullName] = [System.IO.File]::ReadAllBytes($file.FullName)
            }
            $script:second = Invoke-OriginFixture -Name 'idempotent'
        }

        It 'produces byte-identical files on the second run' {
            foreach ($entry in $script:snapshot.GetEnumerator())
            {
                $current = [System.IO.File]::ReadAllBytes($entry.Key)
                [System.Convert]::ToBase64String($current) | Should -Be ([System.Convert]::ToBase64String($entry.Value)) -Because "$($entry.Key) must not change on a re-run"
            }
        }

        It 'writes nothing on the second run' {
            $script:second.Summary.Written | Should -Be 0
        }

        It 'skips resources that already carry a resolved block' {
            $origin = (Get-FixtureSettings -Root $script:first.Root -Resource 'AADPreResolved').generatedFrom
            $origin.entityType | Should -Be 'preexisting'
            $script:first.Summary.Skipped | Should -Be 1
        }

        It 'reprocesses unresolved resources on every run' {
            $script:second.Summary.Unresolved | Should -Be $script:first.Summary.Unresolved
        }

        It 'recomputes a pre-resolved block with -Force' {
            $forced = Invoke-OriginFixture -Name 'idempotent' -Force
            $origin = (Get-FixtureSettings -Root $forced.Root -Resource 'AADPreResolved').generatedFrom
            $origin.entityType | Should -Be 'attributeSet'
            $forced.Summary.Skipped | Should -Be 0
        }
    }

    Context 'Protection of hand recorded facts' {
        BeforeAll {
            $script:protect = Invoke-OriginFixture -Name 'protect'
            $script:handPath = Join-Path -Path $script:protect.Root -ChildPath 'MSFT_AADNoCommands/settings.json'

            $settings = Get-Content -Path $script:handPath -Raw | ConvertFrom-Json
            $settings.generatedFrom.apiVersion = 'beta'
            $settings.generatedFrom.entityType = 'handRecordedEntity'
            $settings.generatedFrom.cmdletNoun = 'MgBetaHandRecorded'
            Set-Content -Path $script:handPath -Value ($settings | ConvertTo-Json -Depth 20) -Encoding utf8NoBOM

            $script:forced = Invoke-OriginFixture -Name 'protect' -Force
            $script:after = (Get-Content -Path $script:handPath -Raw | ConvertFrom-Json).generatedFrom
        }

        It 'keeps a recorded entity type that -Force cannot re-derive' {
            $script:after.entityType | Should -Be 'handRecordedEntity'
            $script:after.apiVersion | Should -Be 'beta'
            $script:after.cmdletNoun | Should -Be 'MgBetaHandRecorded'
        }

        It 'still reports the resource as unresolved and says what it kept' {
            $row = @($script:forced.Summary.UnresolvedRows | Where-Object { $_.Resource -eq 'AADNoCommands' })
            $row | Should -HaveCount 1
            $row[0].Reason | Should -BeLike '*Kept the recorded*'
        }
    }
}
