[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '',
    Justification = 'The stub generator has to carry the generator function names it replaces.')]
param ()

Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath '..\..\..\Utilities\ApiSurface\M365DSCApiSurface.psd1') -Force

InModuleScope -ModuleName 'M365DSCApiSurface' {

    BeforeAll {
        $script:fixtureRoot = Join-Path -Path $PSScriptRoot -ChildPath 'Fixtures/Apply'
        $script:repositoryRoot = Join-Path -Path $PSScriptRoot -ChildPath '../../..' -Resolve

        function New-FixtureResource
        {
            param
            (
                [System.String] $Fixture,
                [System.String] $Resource
            )

            $folder = Join-Path -Path $TestDrive -ChildPath "Resources/MSFT_$Resource"
            $null = New-Item -Path $folder -ItemType Directory -Force

            $target = Join-Path -Path $folder -ChildPath "MSFT_$Resource.psm1"
            Copy-Item -Path (Join-Path -Path $script:fixtureRoot -ChildPath "MSFT_$Fixture.psm1") -Destination $target -Force

            return $target
        }

        function New-EnumFinding
        {
            param
            (
                [System.String] $Resource,
                [System.String] $Property,
                [System.String[]] $Added,
                [System.Boolean] $AutoFixable = $true
            )

            return [PSCustomObject]@{
                id          = "RES-ENUM-STALE:${Resource}:$Property"
                code        = 'RES-ENUM-STALE'
                severity    = 'warning'
                autoFixable = $AutoFixable
                resource    = $Resource
                workload    = 'MicrosoftGraph'
                property    = $Property
                to          = [PSCustomObject]@{ added = $Added }
                evidence    = [PSCustomObject]@{ source = 'csdl:beta/testType/property' }
                firstSeen   = '2026-08-27'
            }
        }

        function Get-Generator
        {
            return Get-M365DSCApiSurfaceGenerator -RepositoryRoot $script:repositoryRoot
        }

        function Invoke-EnumApply
        {
            param
            (
                [System.String] $Path,
                [System.String] $Property,
                [System.String[]] $Added
            )

            $classEdit = Get-ResourceClassEdit -Path $Path
            $edits = @(Update-ValidateSet -ClassEdit $classEdit -PropertyName $Property -Member $Added -Generator (Get-Generator))
            if ($edits.Count -gt 0)
            {
                $null = Write-ResourceEdit -Path $Path -Text $classEdit.Text -Edit $edits -Confirm:$false
            }

            return $edits
        }

        function Get-DeclaredSet
        {
            param
            (
                [System.String] $Path,
                [System.String] $Property
            )

            $classEdit = Get-ResourceClassEdit -Path $Path
            $attribute = Get-ValidateSetAttribute -Member $classEdit.Property[$Property]
            return [System.String[]] @($attribute.PositionalArguments | ForEach-Object -Process { $_.Value })
        }
    }

    Describe 'Get-ResourceClassEdit' {
        It 'picks the DscResource class, not an embedded CIM class' {
            $path = New-FixtureResource -Fixture 'TestApplyBasic' -Resource 'TestApplyBasic'
            (Get-ResourceClassEdit -Path $path).ClassName | Should -BeExactly 'TestApplyBasic'
        }

        It 'collects only members carrying DscProperty' {
            $path = New-FixtureResource -Fixture 'TestApplyBasic' -Resource 'TestApplyBasic'
            $classEdit = Get-ResourceClassEdit -Path $path

            $classEdit.Property.Contains('DisplayName') | Should -BeTrue
            # Filter is the export-only member and carries no attribute.
            $classEdit.Property.Contains('Filter') | Should -BeFalse
        }

        It 'anchors a new declaration on Ensure' {
            $path = New-FixtureResource -Fixture 'TestApplyBasic' -Resource 'TestApplyBasic'
            $classEdit = Get-ResourceClassEdit -Path $path

            $classEdit.InsertOffset | Should -Be $classEdit.Property['Ensure'].Extent.StartOffset
        }

        It 'anchors on the first auth property when the resource is a singleton' {
            $path = New-FixtureResource -Fixture 'TestApplySingleton' -Resource 'TestApplySingleton'
            $classEdit = Get-ResourceClassEdit -Path $path

            $classEdit.Property.Contains('Ensure') | Should -BeFalse
            $classEdit.InsertOffset | Should -Be $classEdit.Property['Credential'].Extent.StartOffset
        }

        It 'resolves the result hashtable behind a variable' {
            $path = New-FixtureResource -Fixture 'TestApplyBasic' -Resource 'TestApplyBasic'
            $keys = @((Get-ResourceClassEdit -Path $path).ResultHashtable.KeyValuePairs.Item1.Extent.Text)

            $keys | Should -Contain 'Mode'
            $keys | Should -Contain 'AccessTokens'
        }

        It 'resolves a result hashtable inlined into AsResult' {
            $path = New-FixtureResource -Fixture 'TestApplyInline' -Resource 'TestApplyInline'
            @((Get-ResourceClassEdit -Path $path).ResultHashtable.KeyValuePairs.Item1.Extent.Text) |
                Should -Contain 'Severity'
        }

        It 'resolves a result hashtable held in a differently named variable' {
            $path = New-FixtureResource -Fixture 'TestApplySingleton' -Resource 'TestApplySingleton'
            @((Get-ResourceClassEdit -Path $path).ResultHashtable.KeyValuePairs.Item1.Extent.Text) |
                Should -Contain 'Tier'
        }

        It 'refuses to guess when two hashtables both look like the result' {
            $path = New-FixtureResource -Fixture 'TestApplyAmbiguous' -Resource 'TestApplyAmbiguous'
            (Get-ResourceClassEdit -Path $path).ResultHashtable | Should -BeNullOrEmpty
        }
    }

    Describe 'Get-ResultAccessorPrefix' {
        BeforeAll {
            function Get-ProbeHashtablePair
            {
                param ($Text)

                $ast = [System.Management.Automation.Language.Parser]::ParseInput($Text, [ref] $null, [ref] $null)
                $hashtable = $ast.Find({ param ($node) $node -is [System.Management.Automation.Language.HashtableAst] }, $true)

                return @($hashtable.KeyValuePairs)
            }
        }

        It 'reads the accessor through a cast' {
            $text = @'
class Probe
{
    [Probe] Get()
    {
        $results = @{
            IsSingleInstance = 'Yes'
            Threshold        = $thresholdInDays
            SecureByDefault  = [Boolean]$settings.secureByDefault
            AccessTokens     = $this.AccessTokens
        }

        return $this.AsResult($results)
    }
}
'@
            Get-ResultAccessorPrefix -Pair (Get-ProbeHashtablePair -Text $text) | Should -BeExactly '$settings.'
        }

        It 'reports nothing when $this is the only accessor' {
            $text = @'
class Probe
{
    [Probe] Get()
    {
        $results = @{
            IsSingleInstance = 'Yes'
            AccessTokens     = $this.AccessTokens
        }

        return $this.AsResult($results)
    }
}
'@
            Get-ResultAccessorPrefix -Pair (Get-ProbeHashtablePair -Text $text) | Should -BeExactly ''
        }
    }

    Describe 'Get-VendorPropertyModel' {
        BeforeAll {
            $script:StubGenerator = New-Module -Name 'ApplyStubGenerator' -ScriptBlock {
                $script:LastCall = @{}

                function Get-M365DSCGraphCsdlMetadata
                {
                    param ($APIVersion)

                    return "schema-$APIVersion"
                }

                function New-M365DSCGraphSchemaIndex
                {
                    param ($Schema)

                    return "index-$Schema"
                }

                function Get-M365DSCGraphTypeProperty
                {
                    param ($Schema, $Entity, $Index, [switch] $Qualified, $IncludeNavigationProperties)

                    $script:LastCall = @{
                        Schema     = $Schema
                        Entity     = $Entity
                        Index      = $Index
                        Qualified  = [System.Boolean] $Qualified
                        Navigation = [System.Boolean] $IncludeNavigationProperties
                    }

                    return @([PSCustomObject]@{ Name = 'Version'; GraphName = 'version' })
                }

                function Get-ApplyStubCall
                {
                    return $script:LastCall
                }

                Export-ModuleMember -Function 'Get-M365DSCGraphCsdlMetadata', 'New-M365DSCGraphSchemaIndex',
                    'Get-M365DSCGraphTypeProperty', 'Get-ApplyStubCall'
            }
        }

        It 'hands the sub-namespaced type name to the generator unchanged' {
            $origin = [PSCustomObject]@{
                apiVersion                  = 'beta'
                entityType                  = 'networkaccess.filteringPolicy'
                odataSubtype                = $null
                includeNavigationProperties = $false
            }

            (Get-VendorPropertyModel -Name 'Version' -Origin $origin -Generator $script:StubGenerator).Name |
                Should -BeExactly 'Version'

            $call = & $script:StubGenerator { Get-ApplyStubCall }
            $call.Entity | Should -BeExactly 'networkaccess.filteringPolicy'
            $call.Qualified | Should -BeTrue
            $call.Index | Should -BeExactly 'index-schema-beta'
        }

        It 'prefers the odata subtype over the entity type' {
            $origin = [PSCustomObject]@{
                apiVersion                  = 'beta'
                entityType                  = 'deviceCompliancePolicy'
                odataSubtype                = 'windows10CompliancePolicy'
                includeNavigationProperties = $false
            }

            $null = Get-VendorPropertyModel -Name 'Version' -Origin $origin -Generator $script:StubGenerator
            (& $script:StubGenerator { Get-ApplyStubCall }).Entity | Should -BeExactly 'windows10CompliancePolicy'
        }
    }

    Describe 'Update-ValidateSet' {
        It 'appends the missing member and leaves the rest untouched' {
            $path = New-FixtureResource -Fixture 'TestApplyBasic' -Resource 'TestApplyBasic'
            $null = Invoke-EnumApply -Path $path -Property 'Mode' -Added @('gamma')

            Get-DeclaredSet -Path $path -Property 'Mode' | Should -Be @('alpha', 'beta', 'gamma')
        }

        It 'never removes a declared member the vendor no longer offers' {
            $path = New-FixtureResource -Fixture 'TestApplyBasic' -Resource 'TestApplyBasic'
            $null = Invoke-EnumApply -Path $path -Property 'Mode' -Added @('gamma')

            Get-DeclaredSet -Path $path -Property 'Mode' | Should -Contain 'alpha'
        }

        It 'keeps the casing the resource already declares' {
            $path = New-FixtureResource -Fixture 'TestApplyInline' -Resource 'TestApplyInline'
            $null = Invoke-EnumApply -Path $path -Property 'Severity' -Added @('unknown')

            $set = Get-DeclaredSet -Path $path -Property 'Severity'
            $set | Should -Be @('Critical', 'Warning', 'unknown')
        }

        It 'adds nothing when the member is already declared in another casing' {
            $path = New-FixtureResource -Fixture 'TestApplyInline' -Resource 'TestApplyInline'
            Invoke-EnumApply -Path $path -Property 'Severity' -Added @('CRITICAL') | Should -HaveCount 0
        }

        It 'touches one line only' {
            $path = New-FixtureResource -Fixture 'TestApplyBasic' -Resource 'TestApplyBasic'
            $before = [System.IO.File]::ReadAllText($path)
            $null = Invoke-EnumApply -Path $path -Property 'Mode' -Added @('gamma')
            $after = [System.IO.File]::ReadAllText($path)

            $changed = @(Compare-Object -ReferenceObject ($before -split "`r?`n") -DifferenceObject ($after -split "`r?`n"))
            $changed | Should -HaveCount 2
        }

        It 'renders the set through the generator rather than by hand' {
            $rendered = Get-ValidateSetLine -Member ([System.String[]] @('alpha', 'beta')) -Generator (Get-Generator)
            $rendered | Should -BeExactly "[ValidateSet('alpha', 'beta')]"
        }

        It 'refuses a property that carries no ValidateSet' {
            $path = New-FixtureResource -Fixture 'TestApplyBasic' -Resource 'TestApplyBasic'
            $classEdit = Get-ResourceClassEdit -Path $path

            { Update-ValidateSet -ClassEdit $classEdit -PropertyName 'Enabled' -Member @('x') -Generator (Get-Generator) } |
                Should -Throw '*carries no ValidateSet*'
        }

        It 'refuses a property the class does not declare' {
            $path = New-FixtureResource -Fixture 'TestApplyBasic' -Resource 'TestApplyBasic'
            $classEdit = Get-ResourceClassEdit -Path $path

            { Update-ValidateSet -ClassEdit $classEdit -PropertyName 'Invented' -Member @('x') -Generator (Get-Generator) } |
                Should -Throw '*does not declare*'
        }
    }

    Describe 'Write-ResourceEdit' {
        It 'applies several edits without shifting each other' {
            $path = New-FixtureResource -Fixture 'TestApplyBasic' -Resource 'TestApplyBasic'
            $text = [System.IO.File]::ReadAllText($path)

            $edits = @(
                New-ResourceEdit -Offset $text.IndexOf('alpha') -Length 5 -Text 'first' -Reason 'a'
                New-ResourceEdit -Offset $text.IndexOf('beta') -Length 4 -Text 'second' -Reason 'b'
            )

            $result = Write-ResourceEdit -Path $path -Text $text -Edit $edits -Confirm:$false
            $result | Should -Match "ValidateSet\('first', 'second'\)"
        }

        It 'drops an edit fully inside another' {
            $edits = @(
                New-ResourceEdit -Offset 2 -Length 5 -Text 'XXXXX' -Reason 'outer'
                New-ResourceEdit -Offset 3 -Length 1 -Text 'y' -Reason 'inner'
            )

            Merge-ResourceEdit -Text 'abcdefghij' -Edit $edits | Should -BeExactly 'abXXXXXhij'
        }

        It 'applies from the highest offset down so earlier offsets stay valid' {
            $edits = @(
                New-ResourceEdit -Offset 0 -Length 1 -Text 'LONGER' -Reason 'first'
                New-ResourceEdit -Offset 5 -Length 1 -Text 'Z' -Reason 'second'
            )

            Merge-ResourceEdit -Text 'abcdef' -Edit $edits | Should -BeExactly 'LONGERbcdeZ'
        }

        It 'rolls the file back when an edit leaves it unparseable' {
            $path = New-FixtureResource -Fixture 'TestApplyBasic' -Resource 'TestApplyBasic'
            $text = [System.IO.File]::ReadAllText($path)
            $edits = @(New-ResourceEdit -Offset $text.IndexOf('class TestApplyBasic') -Length 0 -Text '} ' -Reason 'broken')

            { Write-ResourceEdit -Path $path -Text $text -Edit $edits -Confirm:$false } | Should -Throw '*unparseable*'
            [System.IO.File]::ReadAllText($path) | Should -BeExactly $text
        }
    }

    Describe 'Test-AppliedChange' {
        It 'passes a property present in the class and in the result hashtable' {
            $path = New-FixtureResource -Fixture 'TestApplyBasic' -Resource 'TestApplyBasic'
            (Test-AppliedChange -Path $path -PropertyName 'Mode' -RequireResultEntry).Passed | Should -BeTrue
        }

        It 'fails a property declared on the class but missing from the result hashtable' {
            $path = New-FixtureResource -Fixture 'TestApplyBasic' -Resource 'TestApplyBasic'
            $text = [System.IO.File]::ReadAllText($path)
            $declaration = "    [DscProperty()]`r`n    [System.ComponentModel.Description('Orphan.')]`r`n    [System.String] `$Orphan`r`n`r`n"
            $edits = @(New-ResourceEdit -Offset $text.IndexOf('    [DscProperty()]') -Length 0 -Text $declaration -Reason 'orphan')
            $null = Write-ResourceEdit -Path $path -Text $text -Edit $edits -Confirm:$false

            $verified = Test-AppliedChange -Path $path -PropertyName 'Orphan' -RequireResultEntry
            $verified.Passed | Should -BeFalse
            $verified.Reason | Should -Match 'export as null'
        }

        It 'fails a property that is not declared at all' {
            $path = New-FixtureResource -Fixture 'TestApplyBasic' -Resource 'TestApplyBasic'
            (Test-AppliedChange -Path $path -PropertyName 'Invented').Passed | Should -BeFalse
        }

        It 'fails a file that no longer parses' {
            $path = New-FixtureResource -Fixture 'TestApplyBasic' -Resource 'TestApplyBasic'
            [System.IO.File]::WriteAllText($path, "class Broken {`r`n", [System.Text.UTF8Encoding]::new($false))

            (Test-AppliedChange -Path $path -PropertyName 'Mode').Passed | Should -BeFalse
        }
    }

    Describe 'Update-M365DSCResourceFromDrift' {
        BeforeAll {
            $script:previousGitHubActions = $env:GITHUB_ACTIONS
            $env:GITHUB_ACTIONS = $null
        }

        AfterAll {
            $env:GITHUB_ACTIONS = $script:previousGitHubActions
        }

        It 'applies a stale ValidateSet and reports the edit' {
            $path = New-FixtureResource -Fixture 'TestApplyBasic' -Resource 'TestApplyBasic'
            $finding = New-EnumFinding -Resource 'TestApplyBasic' -Property 'Mode' -Added @('gamma')

            $result = Update-M365DSCResourceFromDrift -Finding $finding `
                -ResourcePath (Join-Path -Path $TestDrive -ChildPath 'Resources') `
                -TestRoot (Join-Path -Path $TestDrive -ChildPath 'NoTests') `
                -Confirm:$false

            $result.Applied | Should -BeTrue
            $result.Reverted | Should -BeFalse
            Get-DeclaredSet -Path $path -Property 'Mode' | Should -Be @('alpha', 'beta', 'gamma')
        }

        It 'refuses a finding that is not auto-fixable without the override' {
            $null = New-FixtureResource -Fixture 'TestApplyBasic' -Resource 'TestApplyBasic'
            $finding = New-EnumFinding -Resource 'TestApplyBasic' -Property 'Mode' -Added @('gamma') -AutoFixable $false

            $result = Update-M365DSCResourceFromDrift -Finding $finding `
                -ResourcePath (Join-Path -Path $TestDrive -ChildPath 'Resources') `
                -TestRoot (Join-Path -Path $TestDrive -ChildPath 'NoTests') `
                -Confirm:$false

            $result.Applied | Should -BeFalse
            $result.Reason | Should -Match 'AllowNonAutomatic'
        }

        It 'never applies a cmdlet removal, even with the override' {
            $null = New-FixtureResource -Fixture 'TestApplyBasic' -Resource 'TestApplyBasic'
            $finding = [PSCustomObject]@{
                id = 'VND-CMDLET-REMOVED:Get-Thing'; code = 'VND-CMDLET-REMOVED'; resource = 'TestApplyBasic'
                property = ''; autoFixable = $true
            }

            $result = Update-M365DSCResourceFromDrift -Finding $finding `
                -ResourcePath (Join-Path -Path $TestDrive -ChildPath 'Resources') `
                -TestRoot (Join-Path -Path $TestDrive -ChildPath 'NoTests') `
                -AllowNonAutomatic -Confirm:$false

            $result.Applied | Should -BeFalse
        }

        It 'throws when the override is used under GITHUB_ACTIONS' {
            $null = New-FixtureResource -Fixture 'TestApplyBasic' -Resource 'TestApplyBasic'
            $finding = New-EnumFinding -Resource 'TestApplyBasic' -Property 'Mode' -Added @('gamma')

            try
            {
                $env:GITHUB_ACTIONS = 'true'
                { Update-M365DSCResourceFromDrift -Finding $finding -AllowNonAutomatic -Confirm:$false } |
                    Should -Throw '*local-only switch*'
            }
            finally
            {
                $env:GITHUB_ACTIONS = $null
            }
        }

        It 'applies normally once GITHUB_ACTIONS is gone' {
            $env:GITHUB_ACTIONS = $null
            $path = New-FixtureResource -Fixture 'TestApplyBasic' -Resource 'TestApplyBasic'
            $finding = New-EnumFinding -Resource 'TestApplyBasic' -Property 'Mode' -Added @('gamma')

            $result = Update-M365DSCResourceFromDrift -Finding $finding `
                -ResourcePath (Join-Path -Path $TestDrive -ChildPath 'Resources') `
                -TestRoot (Join-Path -Path $TestDrive -ChildPath 'NoTests') `
                -AllowNonAutomatic -Confirm:$false

            $result.Applied | Should -BeTrue
            Get-DeclaredSet -Path $path -Property 'Mode' | Should -Contain 'gamma'
        }

        It 'reports nothing to do when the member is already declared' {
            $null = New-FixtureResource -Fixture 'TestApplyBasic' -Resource 'TestApplyBasic'
            $finding = New-EnumFinding -Resource 'TestApplyBasic' -Property 'Mode' -Added @('alpha')

            $result = Update-M365DSCResourceFromDrift -Finding $finding `
                -ResourcePath (Join-Path -Path $TestDrive -ChildPath 'Resources') `
                -TestRoot (Join-Path -Path $TestDrive -ChildPath 'NoTests') `
                -Confirm:$false

            $result.Applied | Should -BeFalse
            $result.Reason | Should -Match 'already carries'
        }

        It 'restores the original bytes when the unit test fails' {
            $path = New-FixtureResource -Fixture 'TestApplyBasic' -Resource 'TestApplyBasic'
            $original = [System.IO.File]::ReadAllText($path)
            $hash = (Get-FileHash -Path $path -Algorithm SHA256).Hash

            $testRoot = Join-Path -Path $TestDrive -ChildPath 'FailingTests'
            $null = New-Item -Path $testRoot -ItemType Directory -Force
            Set-Content -Path (Join-Path -Path $testRoot -ChildPath 'Microsoft365DSC.TestApplyBasic.Tests.ps1') `
                -Value "Describe 'Fails' { It 'fails on purpose' { `$true | Should -BeFalse } }"

            $finding = New-EnumFinding -Resource 'TestApplyBasic' -Property 'Mode' -Added @('gamma')
            $result = Update-M365DSCResourceFromDrift -Finding $finding `
                -ResourcePath (Join-Path -Path $TestDrive -ChildPath 'Resources') `
                -TestRoot $testRoot -Confirm:$false

            $result.Applied | Should -BeFalse
            $result.Reverted | Should -BeTrue
            $result.Reason | Should -Match 'unit test'
            [System.IO.File]::ReadAllText($path) | Should -BeExactly $original
            (Get-FileHash -Path $path -Algorithm SHA256).Hash | Should -BeExactly $hash
        }

        It 'reports a resource whose module is absent' {
            $finding = New-EnumFinding -Resource 'NotThere' -Property 'Mode' -Added @('gamma')

            $result = Update-M365DSCResourceFromDrift -Finding $finding `
                -ResourcePath (Join-Path -Path $TestDrive -ChildPath 'Resources') `
                -TestRoot (Join-Path -Path $TestDrive -ChildPath 'NoTests') `
                -Confirm:$false

            $result.Applied | Should -BeFalse
            $result.Reason | Should -Match 'does not exist'
        }
    }
}
