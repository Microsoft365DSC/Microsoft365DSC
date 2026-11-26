Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath '..\..\..\Utilities\ApiSurface\M365DSCApiSurface.psd1') -Force

InModuleScope -ModuleName 'M365DSCApiSurface' {

    BeforeAll {
        function New-MetadataRow
        {
            param
            (
                [System.String] $Command = 'Get-MgApplication',
                [System.String] $Module = 'Applications',
                [System.String] $ApiVersion = 'v1.0',
                [System.String] $Uri = '/applications',
                [System.String] $OutputType = 'IMicrosoftGraphApplication'
            )

            return [ordered]@{
                Command    = $Command
                Module     = $Module
                ApiVersion = $ApiVersion
                Uri        = $Uri
                OutputType = $OutputType
            }
        }

        function New-CrudRow
        {
            param
            (
                [System.String] $Noun = 'Application',
                [System.String] $Prefix = 'Mg',
                [System.String] $Module = 'Applications',
                [System.String] $ApiVersion = 'v1.0',
                [System.String] $Uri = '/applications',
                [System.String] $OutputType = 'IMicrosoftGraphApplication'
            )

            return @('Get', 'New', 'Update', 'Remove') | ForEach-Object -Process {
                New-MetadataRow -Command "$_-$Prefix$Noun" -Module $Module -ApiVersion $ApiVersion -Uri $Uri -OutputType $OutputType
            }
        }

        function New-InventoryEntry
        {
            param
            (
                [System.String[]] $Verb = @('Get', 'New', 'Update', 'Remove'),
                [System.String[]] $Module = @('Applications'),
                [System.String[]] $ApiVersion = @('beta'),
                [System.String[]] $Uri = @('/applications'),
                [System.String[]] $OutputType = @()
            )

            return [ordered]@{
                Verbs       = [System.Collections.Generic.HashSet[System.String]]::new([System.String[]] $Verb, [System.StringComparer]::OrdinalIgnoreCase)
                Modules     = [System.Collections.Generic.HashSet[System.String]]::new([System.String[]] $Module, [System.StringComparer]::OrdinalIgnoreCase)
                ApiVersions = [System.Collections.Generic.HashSet[System.String]]::new([System.String[]] $ApiVersion, [System.StringComparer]::OrdinalIgnoreCase)
                Uris        = [System.Collections.Generic.HashSet[System.String]]::new([System.String[]] $Uri, [System.StringComparer]::OrdinalIgnoreCase)
                OutputTypes = [System.Collections.Generic.HashSet[System.String]]::new([System.String[]] $OutputType, [System.StringComparer]::OrdinalIgnoreCase)
                Commands    = [System.Collections.Generic.HashSet[System.String]]::new([System.StringComparer]::OrdinalIgnoreCase)
            }
        }

        function New-StringSet
        {
            param
            (
                [AllowEmptyCollection()]
                [System.String[]] $Value = @()
            )

            return , [System.Collections.Generic.HashSet[System.String]]::new(
                [System.String[]] @($Value), [System.StringComparer]::OrdinalIgnoreCase)
        }

        function New-Claim
        {
            param
            (
                [System.String[]] $Noun = @(),
                [System.String[]] $Module = @(),
                [System.String[]] $OutputType = @(),
                [System.String[]] $RouteParent = @()
            )

            return [ordered]@{
                Noun          = New-StringSet -Value $Noun
                Cmdlet        = New-StringSet
                ClaimedModule = New-StringSet -Value $Module
                OutputType    = New-StringSet -Value $OutputType
                RouteParent   = New-StringSet -Value $RouteParent
            }
        }

        function New-OriginRow
        {
            param
            (
                [System.String] $Resource = 'AADApplication',
                [System.Object[]] $Command = @()
            )

            return [ordered]@{
                Resource = $Resource
                Commands = $Command
            }
        }

        function Get-CandidateScore
        {
            param
            (
                [System.Object] $Entry,
                [System.Collections.IDictionary] $Claim,
                [System.String] $Noun = 'Application',
                [System.String] $Uri = '/applications'
            )

            $inventory = [ordered]@{ $Noun = $Entry }
            return (New-CoverageCandidate -Noun $Noun -Entry $Entry -Uri $Uri -Claim $Claim -Inventory $inventory -IsNew $false).score
        }
    }

    Describe 'Test-FullCrudNoun' {
        It 'Accepts Set and Update as the same write verb' {
            Test-FullCrudNoun -Verb @('Get', 'New', 'Remove', 'Set') | Should -BeTrue
            Test-FullCrudNoun -Verb @('Get', 'New', 'Remove', 'Update') | Should -BeTrue
        }

        It 'Rejects a noun with no delete' {
            Test-FullCrudNoun -Verb @('Get', 'New', 'Update') | Should -BeFalse
        }

        It 'Rejects a read-only noun' {
            Test-FullCrudNoun -Verb @('Get') | Should -BeFalse
        }
    }

    Describe 'ConvertTo-GraphNounMap' {
        It 'Folds Mg and MgBeta of one noun into a single entry carrying both versions' {
            $rows = @(New-CrudRow -Noun 'Application' -Prefix 'Mg' -ApiVersion 'v1.0') +
            @(New-CrudRow -Noun 'Application' -Prefix 'MgBeta' -ApiVersion 'beta' -Module 'Beta.Applications')

            $map = ConvertTo-GraphNounMap -Row $rows

            $map.Keys | Should -HaveCount 1
            $map['Application'].ApiVersions | Should -HaveCount 2
            $map['Application'].ApiVersions | Should -Contain 'v1.0'
            $map['Application'].ApiVersions | Should -Contain 'beta'
        }

        It 'Records every verb of a noun' {
            $map = ConvertTo-GraphNounMap -Row @(New-CrudRow -Noun 'Application')

            $map['Application'].Verbs | Should -HaveCount 4
        }

        It 'Skips a command that is not an SDK command' {
            $map = ConvertTo-GraphNounMap -Row @(New-MetadataRow -Command 'Get-Mailbox')

            $map.Keys | Should -HaveCount 0
        }

        It 'Drops an empty output type rather than recording a blank' {
            $map = ConvertTo-GraphNounMap -Row @(New-MetadataRow -OutputType '')

            $map['Application'].OutputTypes | Should -HaveCount 0
        }
    }

    Describe 'Get-GraphCommandInventory' {
        BeforeAll {
            $script:metadataPath = Join-Path -Path $TestDrive -ChildPath 'MgCommandMetadata.json'
            @(New-CrudRow -Noun 'Application') | ConvertTo-Json -Depth 5 |
                Set-Content -Path $script:metadataPath -Encoding utf8
        }

        It 'Records fallback when the metadata is not the pinned version' {
            $inventory = Get-GraphCommandInventory -PinnedVersion '2.35.1' -MetadataPath $script:metadataPath

            $inventory.Source.versionSource | Should -Be 'fallback'
            $inventory.Noun.Keys | Should -Contain 'Application'
        }

        It 'Records missing and an empty map when the metadata file is absent' {
            $inventory = Get-GraphCommandInventory -PinnedVersion '2.35.1' `
                -MetadataPath (Join-Path -Path $TestDrive -ChildPath 'absent.json') `
                -WarningAction SilentlyContinue

            $inventory.Source.versionSource | Should -Be 'missing'
            $inventory.Noun.Count | Should -Be 0
        }
    }

    Describe 'Get-CoverageClaimSet' {
        It 'Claims the noun of a Graph cmdlet and strips the module prefix' {
            $origin = @(New-OriginRow -Command @(
                    [ordered]@{ Name = 'Get-MgApplication'; Module = 'Microsoft.Graph.Applications' }))

            $claim = Get-CoverageClaimSet -Origin $origin

            $claim.Noun.Contains('Application') | Should -BeTrue
            $claim.ClaimedModule.Contains('Applications') | Should -BeTrue
        }

        It 'Strips the Beta segment of a beta module' {
            $origin = @(New-OriginRow -Command @(
                    [ordered]@{ Name = 'Get-MgBetaApplication'; Module = 'Microsoft.Graph.Beta.Applications' }))

            $claim = Get-CoverageClaimSet -Origin $origin

            $claim.Noun.Contains('Application') | Should -BeTrue
            $claim.ClaimedModule.Contains('Applications') | Should -BeTrue
        }

        It 'Ignores a workload cmdlet that is not a Graph cmdlet' {
            $origin = @(New-OriginRow -Command @(
                    [ordered]@{ Name = 'Get-Mailbox'; Module = 'ExchangeOnlineManagement' }))

            $claim = Get-CoverageClaimSet -Origin $origin

            $claim.Noun.Count | Should -Be 0
            $claim.ClaimedModule.Count | Should -Be 0
        }

        It 'Claims a noun whose resource could not resolve its entity type' {
            $origin = @(New-OriginRow -Resource 'AADUnresolved' -Command @(
                    [ordered]@{ Name = 'Get-MgApplication'; Module = 'Microsoft.Graph.Applications' }))
            $origin[0]['GeneratedFrom'] = $null

            $claim = Get-CoverageClaimSet -Origin $origin

            $claim.Noun.Contains('Application') | Should -BeTrue
        }

        It 'Carries the output types and route parents of a claimed noun' {
            $origin = @(New-OriginRow -Command @(
                    [ordered]@{ Name = 'Get-MgApplication'; Module = 'Microsoft.Graph.Applications' }))
            $inventory = [ordered]@{
                Application = New-InventoryEntry -Uri @('/applications/{id}/owners') -OutputType @('IMicrosoftGraphApplication')
            }

            $claim = Get-CoverageClaimSet -Origin $origin -Inventory $inventory

            $claim.OutputType.Contains('IMicrosoftGraphApplication') | Should -BeTrue
            $claim.RouteParent.Contains('/applications/{id}') | Should -BeTrue
        }
    }

    Describe 'Get-CandidateUri' {
        It 'Picks the shortest route and drops a trailing placeholder' {
            Get-CandidateUri -Uri @('/applications/{application-id}', '/applications', '/directory/deleted/applications') |
                Should -Be '/applications'
        }

        It 'Returns an empty string when the noun carries no route' {
            Get-CandidateUri -Uri @() | Should -Be ''
        }
    }

    Describe 'Find-CoverageGap filters' {
        BeforeAll {
            $script:ignore = [pscustomobject]@{
                modules  = @([pscustomobject]@{ module = 'Reports'; reason = 'Telemetry.' })
                uriRoots = @([pscustomobject]@{ uriRoot = '/communications'; reason = 'Live call state.' })
            }
        }

        It 'Removes a noun that a resource claims by name' {
            $inventory = [ordered]@{ Application = New-InventoryEntry }

            $kept = @(Find-CoverageGap -Inventory $inventory -Claim (New-Claim -Noun @('Application')) -Ignore $script:ignore)

            $kept | Should -HaveCount 0
        }

        It 'Keeps a noun that no resource claims' {
            $inventory = [ordered]@{ Application = New-InventoryEntry }

            $kept = @(Find-CoverageGap -Inventory $inventory -Claim (New-Claim) -Ignore $script:ignore)

            $kept | Should -HaveCount 1
            $kept[0].noun | Should -Be 'Application'
        }

        It 'Removes a noun without full CRUD' {
            $inventory = [ordered]@{ Application = New-InventoryEntry -Verb @('Get', 'New') }

            $kept = @(Find-CoverageGap -Inventory $inventory -Claim (New-Claim) -Ignore $script:ignore)

            $kept | Should -HaveCount 0
        }

        It 'Removes a noun whose module the ignore list names' {
            $inventory = [ordered]@{ UserRegistrationDetail = New-InventoryEntry -Module @('Reports') }

            $kept = @(Find-CoverageGap -Inventory $inventory -Claim (New-Claim) -Ignore $script:ignore)

            $kept | Should -HaveCount 0
        }

        It 'Removes a noun whose route sits under an ignored root' {
            $inventory = [ordered]@{ CommunicationCall = New-InventoryEntry -Uri @('/communications/calls') }

            $kept = @(Find-CoverageGap -Inventory $inventory -Claim (New-Claim) -Ignore $script:ignore)

            $kept | Should -HaveCount 0
        }

        It 'Ranks by score descending and by noun within one score' {
            $inventory = [ordered]@{
                Zeta  = New-InventoryEntry -Uri @('/zeta')
                Alpha = New-InventoryEntry -Uri @('/alpha')
                Deep  = New-InventoryEntry -Uri @('/a/b/c/d/e')
            }

            $kept = @(Find-CoverageGap -Inventory $inventory -Claim (New-Claim) -Ignore $script:ignore)

            @($kept | ForEach-Object -Process { $_.noun }) | Should -Be @('Alpha', 'Zeta', 'Deep')
        }
    }

    Describe 'New-CoverageCandidate weights' {
        BeforeAll {
            $script:base = New-InventoryEntry
        }

        It 'Adds 50 for a noun the baseline does not carry' {
            $inventory = [ordered]@{ Application = $script:base }
            $new = New-CoverageCandidate -Noun 'Application' -Entry $script:base -Uri '/applications' `
                -Claim (New-Claim) -Inventory $inventory -IsNew $true

            $new.score | Should -Be 50
        }

        It 'Adds 20 for a module a resource already uses' {
            Get-CandidateScore -Entry $script:base -Claim (New-Claim -Module @('Applications')) | Should -Be 20
        }

        It 'Adds 15 for a claimed sibling under the same route parent' {
            Get-CandidateScore -Entry $script:base -Claim (New-Claim -RouteParent @('')) -Uri '/servicePrincipals/x' |
                Should -Be 0

            Get-CandidateScore -Entry $script:base -Claim (New-Claim -RouteParent @('/identity')) -Uri '/identity/apiConnectors' |
                Should -Be 15
        }

        It 'Adds 5 for a Count companion' {
            $inventory = [ordered]@{
                Application      = $script:base
                ApplicationCount = New-InventoryEntry
            }

            (New-CoverageCandidate -Noun 'Application' -Entry $script:base -Uri '/applications' `
                    -Claim (New-Claim) -Inventory $inventory -IsNew $false).score | Should -Be 5
        }

        It 'Adds 5 for a noun that reached v1.0' {
            Get-CandidateScore -Entry (New-InventoryEntry -ApiVersion @('beta', 'v1.0')) -Claim (New-Claim) | Should -Be 5
        }

        It 'Subtracts 25 for an output type a claimed cmdlet shares' {
            Get-CandidateScore -Entry (New-InventoryEntry -OutputType @('IMicrosoftGraphApplication')) `
                -Claim (New-Claim -OutputType @('IMicrosoftGraphApplication')) | Should -Be -25
        }

        It 'Subtracts 20 for a noun that extends a claimed noun' {
            Get-CandidateScore -Entry $script:base -Claim (New-Claim -Noun @('Application')) -Noun 'ApplicationTemplate' |
                Should -Be -20
        }

        It 'Subtracts 20 for a route five levels deep' {
            Get-CandidateScore -Entry $script:base -Claim (New-Claim) -Uri '/a/b/c/d/e' | Should -Be -20
        }

        It 'Does not count a placeholder towards the route depth' {
            Get-CandidateScore -Entry $script:base -Claim (New-Claim) -Uri '/a/{a-id}/b/{b-id}/c/{c-id}/d' | Should -Be 0
        }

        It 'Subtracts 30 for a route that reads as telemetry' {
            Get-CandidateScore -Entry $script:base -Claim (New-Claim) -Uri '/reports/userActivity' | Should -Be -30
        }

        It 'Names every component that fired' {
            $inventory = [ordered]@{ Application = $script:base }
            $candidate = New-CoverageCandidate -Noun 'Application' -Entry $script:base -Uri '/a/b/c/d/e' `
                -Claim (New-Claim -Module @('Applications')) -Inventory $inventory -IsNew $true

            $candidate.score | Should -Be 50
            $candidate.reasons | Should -HaveCount 3
            $candidate.reasons -join '; ' | Should -Match 'new since the baseline \+50'
            $candidate.reasons -join '; ' | Should -Match 'route is 5 levels deep -20'
        }

        It 'Demotes but never removes, whatever the weights say' {
            $inventory = [ordered]@{
                Worst = New-InventoryEntry -Uri @('/a/b/c/d/userActivity') -Module @('Applications') -OutputType @('IMicrosoftGraphApplication')
            }
            $claim = New-Claim -Module @('Applications') -OutputType @('IMicrosoftGraphApplication') -Noun @('Wor')

            $kept = @(Find-CoverageGap -Inventory $inventory -Claim $claim -Ignore $null)

            $kept | Should -HaveCount 1
            $kept[0].score | Should -BeLessThan 0
        }
    }

    Describe 'Compare-Coverage' {
        BeforeAll {
            $script:candidate = @(
                [ordered]@{ noun = 'Application'; uri = '/applications'; modules = @('Applications'); score = 50; reasons = @('new since the baseline +50') }
                [ordered]@{ noun = 'ServicePrincipal'; uri = '/servicePrincipals'; modules = @('Applications'); score = 0; reasons = @() }
            )
        }

        It 'Reports only the candidate the baseline does not carry' {
            $findings = @(Compare-Coverage -Candidate $script:candidate -BaselineNoun @('ServicePrincipal'))

            $findings | Should -HaveCount 1
            $findings[0].code | Should -Be 'COV-NO-RESOURCE'
            $findings[0].id | Should -Be 'COV-NO-RESOURCE:Application'
            $findings[0].severity | Should -Be 'info'
            $findings[0].autoFixable | Should -BeFalse
        }

        It 'Reports nothing when the baseline carries every candidate' {
            Compare-Coverage -Candidate $script:candidate -BaselineNoun @('Application', 'ServicePrincipal') |
                Should -HaveCount 0
        }

        It 'Reports nothing when there is no baseline yet' {
            Compare-Coverage -Candidate $script:candidate -BaselineNoun @() | Should -HaveCount 0
        }

        It 'Carries the route and the score components as evidence' {
            $findings = @(Compare-Coverage -Candidate $script:candidate -BaselineNoun @('ServicePrincipal'))

            $findings[0].to.uri | Should -Be '/applications'
            $findings[0].evidence.source | Should -Be 'graph:/applications'
            $findings[0].evidence.reasons | Should -Contain 'new since the baseline +50'
        }
    }

    Describe 'Get-CoverageReport' {
        BeforeAll {
            $script:ignorePath = Join-Path -Path $TestDrive -ChildPath 'coverage-ignore.json'
            '{ "modules": [], "uriRoots": [] }' | Set-Content -Path $script:ignorePath -Encoding utf8
            $script:coveragePath = Join-Path -Path $TestDrive -ChildPath 'coverage.json'
        }

        It 'Yields no candidate when the SDK is not at the pin' {
            Mock -CommandName Get-GraphCommandInventory -MockWith {
                return [ordered]@{
                    Source = [ordered]@{ module = 'Microsoft.Graph.Authentication'; version = '2.30.0'; versionSource = 'fallback' }
                    Noun   = [ordered]@{ Application = New-InventoryEntry }
                }
            }

            $report = Get-CoverageReport -PinnedVersion '2.35.1' `
                -CoveragePath $script:coveragePath -IgnorePath $script:ignorePath -WarningAction SilentlyContinue

            $report.Source.versionSource | Should -Be 'fallback'
            $report.Candidate | Should -HaveCount 0
        }

        It 'Yields candidates when the SDK is at the pin' {
            Mock -CommandName Get-GraphCommandInventory -MockWith {
                return [ordered]@{
                    Source = [ordered]@{ module = 'Microsoft.Graph.Authentication'; version = '2.35.1'; versionSource = 'pinned' }
                    Noun   = [ordered]@{ Application = New-InventoryEntry }
                }
            }

            $report = Get-CoverageReport -PinnedVersion '2.35.1' `
                -CoveragePath $script:coveragePath -IgnorePath $script:ignorePath

            $report.Candidate | Should -HaveCount 1
            $report.Candidate[0].noun | Should -Be 'Application'
        }
    }

    Describe 'Format-CoverageMarkdown' {
        It 'Renders the top entries as runnable generator commands' {
            $candidate = @(
                [ordered]@{ noun = 'BookingBusiness'; modules = @('Bookings'); apiVersions = @('beta', 'v1.0')
                    uri = '/solutions/bookingBusinesses'; score = 40; reasons = @('module already used +20')
                }
            )

            $markdown = Format-CoverageMarkdown -Candidate $candidate -Source $null -RenderedCount 1

            $markdown | Should -Match '-CmdLetNoun MgBookingBusiness -APIVersion v1\.0'
            $markdown | Should -Match 'module already used \+20'
        }

        It 'Falls back to the beta prefix when the noun never reached v1.0' {
            $candidate = @(
                [ordered]@{ noun = 'Whatever'; modules = @('Beta.Whatever'); apiVersions = @('beta')
                    uri = '/whatever'; score = 0; reasons = @()
                }
            )

            $markdown = Format-CoverageMarkdown -Candidate $candidate -Source $null -RenderedCount 1

            $markdown | Should -Match '-CmdLetNoun MgBetaWhatever -APIVersion beta'
        }

        It 'Tables everything below the rendered count' {
            $candidate = @(
                [ordered]@{ noun = 'First'; modules = @('A'); apiVersions = @('beta'); uri = '/first'; score = 10; reasons = @() }
                [ordered]@{ noun = 'Second'; modules = @('A'); apiVersions = @('beta'); uri = '/second'; score = 0; reasons = @() }
            )

            $markdown = Format-CoverageMarkdown -Candidate $candidate -Source $null -RenderedCount 1

            $markdown | Should -Match '## The rest  \(1\)'
            $markdown | Should -Match '\| Second \| 0 \|'
        }
    }
    Describe 'Find-SubtypeGap' {
        BeforeAll {
            $script:subtypeRow = @(
                [ordered]@{ apiVersion = 'beta'; entityType = 'deviceConfiguration'; subtype = 'macOSVpnConfiguration'; isAbstract = $false; resource = ''; covered = $false }
                [ordered]@{ apiVersion = 'beta'; entityType = 'deviceConfiguration'; subtype = 'iosVpnConfiguration'; isAbstract = $false; resource = 'IntuneVPNConfigurationPolicyIOS'; covered = $true }
                [ordered]@{ apiVersion = 'beta'; entityType = 'deviceConfiguration'; subtype = 'macOSSingleSignOnBase'; isAbstract = $true; resource = ''; covered = $false }
                [ordered]@{ apiVersion = 'beta'; entityType = 'deviceConfiguration'; subtype = 'windowsPhone81VpnConfiguration'; isAbstract = $false; resource = ''; covered = $false }
            )
        }

        It 'Drops the covered, the abstract and the ignored subtype' {
            $ignore = [PSCustomObject]@{ odataSubtypes = @([PSCustomObject]@{ odataSubtype = 'windowsPhone81VpnConfiguration' }) }

            $candidates = @(Find-SubtypeGap -Subtype $script:subtypeRow -Ignore $ignore)

            $candidates | Should -HaveCount 1
            $candidates[0].subtype | Should -Be 'macOSVpnConfiguration'
        }

        It 'Weights a subtype whose entity type already has a resource' {
            $candidates = @(Find-SubtypeGap -Subtype $script:subtypeRow -Ignore $null -BaselineSubtype @('macOSVpnConfiguration', 'windowsPhone81VpnConfiguration'))
            $macOS = $candidates | Where-Object -FilterScript { $_.subtype -eq 'macOSVpnConfiguration' }

            $macOS.score | Should -Be 20
            $macOS.reasons | Should -Contain 'the entity type already has a resource +20'
        }

        It 'Weights a subtype the baseline does not carry' {
            $candidates = @(Find-SubtypeGap -Subtype $script:subtypeRow -Ignore $null)

            $candidates[0].score | Should -Be 70
            $candidates[0].reasons | Should -Contain 'new since the baseline +50'
        }

        It 'Scores a retired platform below everything else' {
            $rows = @(
                [ordered]@{ apiVersion = 'beta'; entityType = 'deviceConfiguration'; subtype = 'windowsPhone81VpnConfiguration'; isAbstract = $false; resource = ''; covered = $false }
            )

            $candidates = @(Find-SubtypeGap -Subtype $rows -Ignore $null -BaselineSubtype @('windowsPhone81VpnConfiguration'))

            $candidates[0].score | Should -Be -30
            $candidates[0].reasons | Should -Contain 'platform is retired -30'
        }
    }

    Describe 'Compare-Subtype' {
        BeforeAll {
            $script:subtypeCandidate = @(
                [ordered]@{ subtype = 'macOSVpnConfiguration'; entityType = 'deviceConfiguration'; apiVersion = 'beta'; score = 20; reasons = @('the entity type already has a resource +20') }
                [ordered]@{ subtype = 'iosUpdateConfiguration'; entityType = 'deviceConfiguration'; apiVersion = 'beta'; score = 20; reasons = @() }
            )
        }

        It 'Reports only the subtype the baseline does not carry' {
            $findings = @(Compare-Subtype -Candidate $script:subtypeCandidate -BaselineSubtype @('iosUpdateConfiguration'))

            $findings | Should -HaveCount 1
            $findings[0].code | Should -Be 'COV-NO-SUBTYPE'
            $findings[0].id | Should -Be 'COV-NO-SUBTYPE:macOSVpnConfiguration'
            $findings[0].severity | Should -Be 'info'
            $findings[0].to.entityType | Should -Be 'deviceConfiguration'
            $findings[0].evidence.source | Should -Be 'graph:beta/deviceConfiguration'
        }

        It 'Reports nothing when there is no baseline yet' {
            Compare-Subtype -Candidate $script:subtypeCandidate -BaselineSubtype @() | Should -HaveCount 0
        }
    }

    Describe 'Get-ODataTypeMentionedInCode' {
        It 'Reads both the discriminator and the bare type name from a resource' {
            $folder = Join-Path -Path $TestDrive -ChildPath 'MSFT_Sample'
            $null = New-Item -Path $folder -ItemType Directory -Force
            Set-Content -Path (Join-Path -Path $folder -ChildPath 'MSFT_Sample.psm1') -Value @(
                "`$odata = '#microsoft.graph.macOSWiFiConfiguration'"
                "-ODataType @('microsoft.graph.macOSEnterpriseWiFiConfiguration')"
            )

            $mentioned = Get-ODataTypeMentionedInCode -ResourcePath $TestDrive

            $mentioned.Contains('macOSWiFiConfiguration') | Should -BeTrue
            $mentioned.Contains('macOSEnterpriseWiFiConfiguration') | Should -BeTrue
        }

        It 'Returns an empty set when the path does not exist' {
            (Get-ODataTypeMentionedInCode -ResourcePath (Join-Path -Path $TestDrive -ChildPath 'missing')).Count | Should -Be 0
        }
    }
}