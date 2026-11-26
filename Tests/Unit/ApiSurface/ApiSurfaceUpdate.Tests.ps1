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

        function New-TestModel
        {
            param
            (
                [System.String] $Name = 'Mode',
                [System.String] $ClrType = 'System.String',
                [System.String] $Description = 'The vendor description.',
                [System.Boolean] $IsComplex = $false,
                [System.String[]] $EnumValues = @()
            )

            return [PSCustomObject]@{
                Name         = $Name
                ClrType      = $ClrType
                Description  = $Description
                CimClassName = 'MSFT_Placeholder'
                IsKey        = $false
                IsMandatory  = $false
                IsComplex    = $IsComplex
                IsEnum       = ($EnumValues.Count -gt 0)
                IsArray      = $false
                EnumValues   = $EnumValues
            }
        }

        function New-OrphanFinding
        {
            param
            (
                [System.String] $Resource = 'TestApplyBasic',
                [System.String] $Property = 'Mode'
            )

            return [PSCustomObject]@{
                id          = "RES-PROP-ORPHANED:${Resource}:$Property"
                code        = 'RES-PROP-ORPHANED'
                severity    = 'breaking'
                autoFixable = $false
                resource    = $Resource
                workload    = 'MicrosoftGraph'
                property    = $Property
                from        = [PSCustomObject]@{ typeConstraint = 'String' }
                evidence    = [PSCustomObject]@{ source = "dsc:$Resource/$Property" }
                firstSeen   = '2026-08-10'
            }
        }

        function New-ApplyRecord
        {
            param
            (
                [System.String] $Id,
                [System.Boolean] $Applied,
                [System.String] $Reason = 'ok',
                [System.String] $Resource = 'TestApplyBasic'
            )

            return [ordered]@{
                Id = $Id; Code = 'RES-ENUM-STALE'; Resource = $Resource; Property = 'Mode'
                Applied = $Applied; Reverted = (-not $Applied); Reason = $Reason
                Edit = @('an edit'); Path = 'somewhere'
            }
        }

        function New-DriftFile
        {
            param ([System.Object[]] $Finding)

            $path = Join-Path -Path $TestDrive -ChildPath "drift-$([System.Guid]::NewGuid().ToString('N')).json"
            Set-Content -Path $path -Value (@{ findings = $Finding } | ConvertTo-Json -Depth 10)
            return $path
        }
    }

    Describe 'Set-PropertyDeprecated' {
        It 'prefixes the description and comments out the Get() entry' {
            $path = New-FixtureResource -Fixture 'TestApplyBasic' -Resource 'TestApplyBasic'
            $classEdit = Get-ResourceClassEdit -Path $path
            $edits = @(Set-PropertyDeprecated -ClassEdit $classEdit -Finding (New-OrphanFinding))
            $null = Write-ResourceEdit -Path $path -Text $classEdit.Text -Edit $edits -Confirm:$false

            $text = [System.IO.File]::ReadAllText($path)
            $text | Should -Match "DEPRECATED\. Not offered by the vendor type\. The mode of the policy\."
            $text | Should -Match '(?m)^\s*#DEPRECATED\r?$'
            $text | Should -Match '(?m)^#\s+Mode\s+= '
        }

        It 'leaves the property declared so an existing configuration still compiles' {
            $path = New-FixtureResource -Fixture 'TestApplyBasic' -Resource 'TestApplyBasic'
            $classEdit = Get-ResourceClassEdit -Path $path
            $edits = @(Set-PropertyDeprecated -ClassEdit $classEdit -Finding (New-OrphanFinding))
            $null = Write-ResourceEdit -Path $path -Text $classEdit.Text -Edit $edits -Confirm:$false

            (Get-ResourceClassEdit -Path $path).Property.Contains('Mode') | Should -BeTrue
        }

        It 'does nothing the second time' {
            $path = New-FixtureResource -Fixture 'TestApplyBasic' -Resource 'TestApplyBasic'
            $classEdit = Get-ResourceClassEdit -Path $path
            $edits = @(Set-PropertyDeprecated -ClassEdit $classEdit -Finding (New-OrphanFinding))
            $null = Write-ResourceEdit -Path $path -Text $classEdit.Text -Edit $edits -Confirm:$false

            $again = Get-ResourceClassEdit -Path $path
            @(Set-PropertyDeprecated -ClassEdit $again -Finding (New-OrphanFinding)) | Should -HaveCount 0
        }

        It 'refuses a property the class does not declare' {
            $path = New-FixtureResource -Fixture 'TestApplyBasic' -Resource 'TestApplyBasic'
            $classEdit = Get-ResourceClassEdit -Path $path

            { Set-PropertyDeprecated -ClassEdit $classEdit -Finding (New-OrphanFinding -Property 'Invented') } |
                Should -Throw '*does not declare*'
        }
    }

    Describe 'Update-PropertyType' {
        BeforeAll {
            $script:origin = [PSCustomObject]@{ entityType = 'testType'; apiVersion = 'beta'; includeNavigationProperties = $false }
        }

        It 're-renders the declaration with the vendor type' {
            Mock -CommandName Get-VendorPropertyModel -MockWith { New-TestModel -ClrType 'System.Int64' }

            $path = New-FixtureResource -Fixture 'TestApplyBasic' -Resource 'TestApplyBasic'
            $classEdit = Get-ResourceClassEdit -Path $path
            $finding = [PSCustomObject]@{ code = 'RES-TYPE-MISMATCH'; property = 'Mode'; resource = 'TestApplyBasic' }
            $edits = @(Update-PropertyType -ClassEdit $classEdit -Finding $finding -Generator (Get-M365DSCApiSurfaceGenerator -RepositoryRoot $script:repositoryRoot) -Origin $script:origin)
            $null = Write-ResourceEdit -Path $path -Text $classEdit.Text -Edit $edits -Confirm:$false

            [System.IO.File]::ReadAllText($path) | Should -Match '\[System\.Int64\] \$Mode'
        }

        It 'keeps the Key flag the resource declares' {
            Mock -CommandName Get-VendorPropertyModel -MockWith { New-TestModel -Name 'DisplayName' -ClrType 'System.String' }

            $path = New-FixtureResource -Fixture 'TestApplyBasic' -Resource 'TestApplyBasic'
            $classEdit = Get-ResourceClassEdit -Path $path
            $finding = [PSCustomObject]@{ code = 'RES-TYPE-MISMATCH'; property = 'DisplayName'; resource = 'TestApplyBasic' }
            $edits = @(Update-PropertyType -ClassEdit $classEdit -Finding $finding -Generator (Get-M365DSCApiSurfaceGenerator -RepositoryRoot $script:repositoryRoot) -Origin $script:origin)

            $edits[0].Text | Should -Match '\[DscProperty\(Key\)\]'
        }

        It 'refuses a complex vendor type' {
            Mock -CommandName Get-VendorPropertyModel -MockWith { New-TestModel -IsComplex $true }

            $path = New-FixtureResource -Fixture 'TestApplyBasic' -Resource 'TestApplyBasic'
            $classEdit = Get-ResourceClassEdit -Path $path
            $finding = [PSCustomObject]@{ code = 'RES-TYPE-MISMATCH'; property = 'Mode'; resource = 'TestApplyBasic' }

            { Update-PropertyType -ClassEdit $classEdit -Finding $finding -Generator (Get-M365DSCApiSurfaceGenerator -RepositoryRoot $script:repositoryRoot) -Origin $script:origin } |
                Should -Throw '*written by hand*'
        }
    }

    Describe 'Select-DriftFinding' {
        It 'picks only the named findings' {
            $path = New-DriftFile -Finding @(
                [PSCustomObject]@{ id = 'A'; code = 'RES-ENUM-STALE' }
                [PSCustomObject]@{ id = 'B'; code = 'RES-ENUM-STALE' }
                [PSCustomObject]@{ id = 'C'; code = 'RES-ENUM-STALE' }
            )

            @(Select-DriftFinding -DriftPath $path -Id @('A', 'C')).id | Should -Be @('A', 'C')
        }

        It 'ignores an id the report does not carry' {
            $path = New-DriftFile -Finding @([PSCustomObject]@{ id = 'A'; code = 'RES-ENUM-STALE' })
            Select-DriftFinding -DriftPath $path -Id @('Z') | Should -HaveCount 0
        }
    }

    Describe 'Format-UpdatePullRequestBody' {
        It 'lists the applied and the reverted with their counts' {
            $body = Format-UpdatePullRequestBody -Result @(
                (New-ApplyRecord -Id 'RES-ENUM-STALE:A:One' -Applied $true)
                (New-ApplyRecord -Id 'RES-ENUM-STALE:B:Two' -Applied $false -Reason 'Reverted. 1 unit test failed.')
            )

            $body | Should -Match '## Applied  \(1\)'
            $body | Should -Match '## Attempted and reverted  \(1\)'
            $body | Should -Match 'RES-ENUM-STALE:A:One'
            $body | Should -Match 'Reverted\. 1 unit test failed\.'
        }

        It 'states a count on both sections when nothing happened' {
            $body = Format-UpdatePullRequestBody -Result @()
            $body | Should -Match '## Applied  \(0\)'
            $body | Should -Match '## Attempted and reverted  \(0\)'
        }
    }

    Describe 'Invoke-M365DSCApiSurfaceUpdate' {
        It 'throws when the override is used under GITHUB_ACTIONS' {
            try
            {
                $env:GITHUB_ACTIONS = 'true'
                { Invoke-M365DSCApiSurfaceUpdate -FindingId 'A' -AllowNonAutomatic -Confirm:$false } |
                    Should -Throw '*local-only switch*'
            }
            finally
            {
                $env:GITHUB_ACTIONS = $null
            }
        }

        It 'throws when no finding was named' {
            $path = New-DriftFile -Finding @([PSCustomObject]@{ id = 'A'; code = 'RES-ENUM-STALE' })
            { Invoke-M365DSCApiSurfaceUpdate -DriftPath $path -Confirm:$false } | Should -Throw '*No finding was named*'
        }

        It 'throws when the drift report is absent' {
            { Invoke-M365DSCApiSurfaceUpdate -DriftPath (Join-Path $TestDrive 'nope.json') -FindingId 'A' -Confirm:$false } |
                Should -Throw '*does not exist*'
        }

        It 'throws when none of the named findings is in the report' {
            $path = New-DriftFile -Finding @([PSCustomObject]@{ id = 'A'; code = 'RES-ENUM-STALE' })
            { Invoke-M365DSCApiSurfaceUpdate -DriftPath $path -FindingId 'Z' -Confirm:$false } |
                Should -Throw '*None of the named findings*'
        }

        It 'takes its approval from the ticked boxes of an Issue body' {
            $path = New-DriftFile -Finding @([PSCustomObject]@{ id = 'A'; code = 'RES-ENUM-STALE' })
            $issue = Join-Path -Path $TestDrive -ChildPath 'issue.md'
            Set-Content -Path $issue -Value "## Auto-fixable`n`n- [ ] ``A```n- [x] ``Z```n"

            { Invoke-M365DSCApiSurfaceUpdate -DriftPath $path -FromIssue $issue -Confirm:$false } |
                Should -Throw '*None of the named findings*'
        }

        It 'stages only the resources it applied, never the whole working tree' {
            $script:gitCalls = [System.Collections.Generic.List[System.String[]]]::new()

            Mock -CommandName Invoke-RepositoryCommand -MockWith {
                $script:gitCalls.Add([System.String[]] $Argument)
                return [System.String[]] @()
            }

            Mock -CommandName Test-AppliedResource -MockWith { return [System.String[]] @() }
            Mock -CommandName Update-M365DSCResourceFromDrift -MockWith {
                return [ordered]@{
                    Id       = 'RES-ENUM-STALE:TestPolicy:State'
                    Code     = 'RES-ENUM-STALE'
                    Resource = 'TestPolicy'
                    Property = 'State'
                    Applied  = $true
                    Reverted = $false
                    Reason   = 'applied'
                    Edit     = @('ValidateSet on TestPolicy.State')
                    Path     = 'Modules/Microsoft365DSC/DscResources/MSFT_TestPolicy/MSFT_TestPolicy.psm1'
                }
            }

            $path = New-DriftFile -Finding @([PSCustomObject]@{
                    id = 'RES-ENUM-STALE:TestPolicy:State'; code = 'RES-ENUM-STALE'; resource = 'TestPolicy'
                })

            $null = Invoke-M365DSCApiSurfaceUpdate -DriftPath $path `
                -FindingId 'RES-ENUM-STALE:TestPolicy:State' `
                -NoPullRequest -SkipBuild -Confirm:$false

            $add = @($script:gitCalls | Where-Object -FilterScript { $_[0] -eq 'add' })
            $add.Count | Should -Be 1
            $add[0] | Should -Not -Contain '--all'
            $add[0][-1] | Should -BeExactly 'Modules/Microsoft365DSC/DscResources/MSFT_TestPolicy/MSFT_TestPolicy.psm1'
        }
    }

    Describe 'API Surface Apply workflow' {
        BeforeAll {
            $script:workflow = [System.IO.File]::ReadAllText(
                (Join-Path -Path $script:repositoryRoot -ChildPath '.github/workflows/API Surface Apply.yml'))
        }

        It 'triggers on an issue comment carrying the command' {
            $script:workflow | Should -Match '(?m)^  issue_comment:\r?$'
            $script:workflow | Should -Match "contains\(github\.event\.comment\.body, '/apply-drift'\)"
        }

        It 'requires the label as well as the command' {
            $script:workflow | Should -Match "contains\(github\.event\.issue\.labels\.\*\.name, 'api-drift'\)"
            $script:workflow | Should -Match '&&'
        }

        It 'refuses a commenter without write access' {
            $script:workflow | Should -Match 'collaborators/\$env:COMMENTER/permission'
            $script:workflow | Should -Match "notin @\('admin', 'write', 'maintain'\)"
        }

        It 'can also be dispatched by hand' {
            $script:workflow | Should -Match '(?m)^  workflow_dispatch:\r?$'
            $script:workflow | Should -Match '(?m)^      issue_number:\r?$'
            $script:workflow | Should -Match '(?m)^      finding_id:\r?$'
            $script:workflow | Should -Match "github\.event_name == 'workflow_dispatch'"
        }

        It 'checks the commenter only on the comment path' {
            # A dispatch carries no comment author and already requires write access.
            $script:workflow | Should -Match "if: github\.event_name == 'issue_comment'"
        }

        It 'refuses a dispatch that names neither an Issue nor a finding' {
            $script:workflow | Should -Match 'Pass an Issue number, a finding id, or both\.'
        }

        It 'never passes the local-only override' {
            $script:workflow | Should -Not -Match 'Invoke-M365DSCApiSurfaceUpdate[^\r\n]*-AllowNonAutomatic'
        }

        It 're-reads the Issue body rather than trusting the artifact' {
            $script:workflow | Should -Match 'gh issue view \$env:ISSUE_NUMBER --json body'
            $script:workflow | Should -Match "\`$parameters\['FromIssue'\] = '\./issue-body\.md'"
        }
    }
}
