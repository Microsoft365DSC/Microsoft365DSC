Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath '..\..\..\Utilities\ApiSurface\M365DSCApiSurface.psd1') -Force

InModuleScope -ModuleName 'M365DSCApiSurface' {

    BeforeAll {
        $script:fixtureRoot = Join-Path -Path $PSScriptRoot -ChildPath 'Fixtures/ApiSurface'
        $script:repositoryRoot = Join-Path -Path $PSScriptRoot -ChildPath '../../..' -Resolve
        $script:since = 'Microsoft.Graph.Authentication 2.34.0 -> 2.35.1'

        $script:result = Get-Content -Path (Join-Path -Path $script:fixtureRoot -ChildPath 'drift-result.json') -Raw |
            ConvertFrom-Json

        $script:autoFixableId = [System.String[]] @($script:result.Findings |
                Where-Object -FilterScript { $_.autoFixable } |
                ForEach-Object -Process { $_.id })

        function Get-TestBody
        {
            param
            (
                [System.String[]] $Ticked = @(),
                [System.String] $Since = $script:since
            )

            return (Format-DriftIssueBody -Result $script:result -Ticked $Ticked -Since $Since) -replace "`r`n", "`n"
        }

        function New-BulkResult
        {
            param
            (
                [System.Int32] $AutoFixable = 200,
                [System.Int32] $Decision = 200,
                [System.Int32] $Breaking = 200
            )

            $findings = [System.Collections.Generic.List[System.Object]]::new()

            for ($i = 0; $i -lt $AutoFixable; $i++)
            {
                $findings.Add([PSCustomObject]@{
                        id          = ('RES-ENUM-STALE:BulkResource{0:D4}:PropertyWithALongEnoughName' -f $i)
                        code        = 'RES-ENUM-STALE'
                        severity    = 'warning'
                        autoFixable = $true
                        to          = [PSCustomObject]@{ added = @('memberOne', 'memberTwo') }
                        evidence    = [PSCustomObject]@{ source = ('csdl:beta/bulkType{0:D4}/property' -f $i) }
                        firstSeen   = '2026-08-27'
                    })
            }

            for ($i = 0; $i -lt $Decision; $i++)
            {
                $findings.Add([PSCustomObject]@{
                        id          = ('RES-TYPE-MISMATCH:BulkResource{0:D4}:PropertyWithALongEnoughName' -f $i)
                        code        = 'RES-TYPE-MISMATCH'
                        severity    = 'warning'
                        autoFixable = $false
                        from        = [PSCustomObject]@{ typeConstraint = 'UInt32' }
                        to          = [PSCustomObject]@{ vendorType = 'Edm.Int64' }
                        evidence    = [PSCustomObject]@{ source = ('csdl:beta/bulkType{0:D4}/property' -f $i) }
                        firstSeen   = '2026-08-27'
                    })
            }

            for ($i = 0; $i -lt $Breaking; $i++)
            {
                $findings.Add([PSCustomObject]@{
                        id          = ('RES-PROP-ORPHANED:BulkResource{0:D4}:PropertyWithALongEnoughName' -f $i)
                        code        = 'RES-PROP-ORPHANED'
                        severity    = 'breaking'
                        autoFixable = $false
                        from        = [PSCustomObject]@{ typeConstraint = 'String' }
                        evidence    = [PSCustomObject]@{ source = ('dsc:BulkResource{0:D4}/Property' -f $i) }
                        firstSeen   = '2026-08-01'
                    })
            }

            return [PSCustomObject]@{
                Findings = @($findings)
                Coverage = @()
                Backlog  = 0
                Summary  = [PSCustomObject]@{ compared = 500; skipped = 3 }
            }
        }

        function New-TestDependency
        {
            param
            (
                [System.Collections.IDictionary] $Pinned = @{}
            )

            $map = [ordered]@{}
            foreach ($name in $Pinned.Keys)
            {
                $map[$name] = [ordered]@{ pinned = $Pinned[$name]; manifests = @('Manifest') }
            }

            return [ordered]@{ dependencies = $map }
        }
    }

    Describe 'Format-DriftIssueBody' {
        It 'renders the fixture drift into the expected body' {
            $expected = [System.IO.File]::ReadAllText((Join-Path -Path $script:fixtureRoot -ChildPath 'issue-body.md')) -replace "`r`n", "`n"
            Get-TestBody | Should -BeExactly $expected
        }

        It 'renders the same drift twice into the same body' {
            Get-TestBody | Should -BeExactly (Get-TestBody)
        }

        It 'orders the sections the way phase 3 specifies' {
            $headings = @((Get-TestBody) -split "`n" | Where-Object -FilterScript { $_ -like '## *' })

            $headings | Should -HaveCount 11
            $headings[0] | Should -BeLike '## Auto-fixable*'
            $headings[1] | Should -BeLike '## Needs a decision*'
            $headings[2] | Should -BeLike '## Graph shim, regenerate to fix*'
            $headings[3] | Should -BeLike '## Intune settings catalog, regenerate to fix*'
            $headings[4] | Should -BeLike '## Read-only, suggested for no implementation*'
            $headings[5] | Should -BeLike '## Coverage gaps*'
            $headings[6] | Should -BeLike '## Graph nouns with full CRUD and no resource*'
            $headings[7] | Should -BeLike '## Cmdlets no resource calls any more*'
            $headings[8] | Should -BeLike '## Vendor changes since *'
            $headings[9] | Should -BeLike '## Newer dependency versions available*'
            $headings[10] | Should -BeLike '## Unaccepted breaking findings*'
        }

        It 'gives every finding code a section to render in' {
            $covered = @((Get-DriftSection).Codes)

            foreach ($code in @(
                    'VND-CMDLET-REMOVED', 'VND-CMDLET-REROUTED', 'VND-PARAM-ADDED', 'VND-PARAM-TYPECHANGED',
                    'VND-TYPE-PROP-ADDED', 'VND-ENUM-MEMBER-ADDED', 'VND-NEWER-VERSION',
                    'RES-PROP-MISSING', 'RES-PROP-READONLY', 'RES-PROP-ORPHANED', 'RES-TYPE-MISMATCH',
                    'RES-ENUM-STALE', 'SHIM-MISSING', 'SHIM-STALE', 'COV-NO-RESOURCE', 'COV-CMDLET-UNUSED',
                    'CAT-SETTING-ADDED', 'CAT-SETTING-REMOVED', 'CAT-OPTION-ADDED', 'CAT-TEMPLATE-VERSION',
                    'CAT-TEMPLATE-NEW'))
            {
                $covered | Should -Contain $code -Because "$code would be counted and never shown"
            }
        }

        It 'lists a finding of an auto-fixable code that is not auto-fixable' {
            $result = [PSCustomObject]@{
                summary  = [PSCustomObject]@{ total = 1 }
                coverage = @()
                findings = @([PSCustomObject]@{
                        id         = 'RES-PROP-MISSING:TestPolicy:Conditions'
                        code       = 'RES-PROP-MISSING'
                        severity   = 'warning'
                        autoFixable = $false
                        resource   = 'TestPolicy'
                        property   = 'Conditions'
                        evidence   = [PSCustomObject]@{ source = 'csdl:beta/testPolicy/conditions' }
                    })
            }

            $body = Format-DriftIssueBody -Result $result -Ticked @() -Since ''
            $body | Should -BeLike '*RES-PROP-MISSING:TestPolicy:Conditions*'
            $body | Should -Not -BeLike "*- [ ] ``RES-PROP-MISSING:TestPolicy:Conditions``*"
        }

        It 'names the dependency move in the vendor section' {
            Get-TestBody | Should -Match '## Vendor changes since Microsoft\.Graph\.Authentication 2\.34\.0 -> 2\.35\.1  \(1\)'
        }

        It 'falls back to the baseline snapshot when no pin moved' {
            Get-TestBody -Since '' | Should -Match '## Vendor changes since the baseline snapshot  \(1\)'
        }

        It 'names the oldest first seen date rather than an age on the breaking section' {
            # An age in days would change on every weekly run and rewrite an unchanged Issue.
            Get-TestBody | Should -Match '## Unaccepted breaking findings, oldest 2026-07-01  \(2\)'
        }

        It 'carries no timestamp, run number or run URL' {
            $body = Get-TestBody
            $body | Should -Not -Match '\d{4}-\d{2}-\d{2}T'
            $body | Should -Not -Match 'github\.com'
            $body | Should -Not -Match '(?i)run (id|number)'
        }

        It 'states a count on every section even when it is empty' {
            $empty = [PSCustomObject]@{
                Findings = @()
                Coverage = @()
                Backlog  = 0
                Summary  = [PSCustomObject]@{ compared = 0; skipped = 0 }
            }

            $body = Format-DriftIssueBody -Result $empty
            foreach ($heading in @($body -split "`r?`n" | Where-Object -FilterScript { $_ -like '## *' }))
            {
                $heading | Should -Match '\(\d+\)$'
            }
        }

        It 'collapses everything that is not auto-fixable' {
            $body = Get-TestBody
            $body | Should -Match '(?m)^<details>$'
            $body | Should -Match '(?m)^</details>$'
            ($body -split "`n").IndexOf('<details>') | Should -BeLessThan ($body -split "`n").IndexOf('## Needs a decision  (2)')
        }
    }

    Describe 'Issue body round trip' {
        It 'parses back every id it rendered as ticked' {
            $script:autoFixableId.Count | Should -Be 5

            $body = Get-TestBody -Ticked $script:autoFixableId
            Get-DriftIssueTicked -Body $body | Should -Be $script:autoFixableId
        }

        It 'returns exactly the three ticked of five' {
            $ticked = [System.String[]] @($script:autoFixableId[0], $script:autoFixableId[2], $script:autoFixableId[4])

            $body = Get-TestBody -Ticked $ticked
            $parsed = Get-DriftIssueTicked -Body $body

            $parsed | Should -Be $ticked
            $body | Should -Match '(?m)^- \[ \] '
        }

        It 'keeps a tick across a rewrite of the same drift' {
            $first = Get-TestBody -Ticked ([System.String[]] @($script:autoFixableId[1]))
            $second = Get-TestBody -Ticked (Get-DriftIssueTicked -Body $first)

            $second | Should -BeExactly $first
        }

        It 'drops a tick whose finding is gone' {
            $body = Get-TestBody -Ticked ([System.String[]] @('RES-ENUM-STALE:Vanished:State'))
            Get-DriftIssueTicked -Body $body | Should -HaveCount 0
        }

        It 'parses a body GitHub handed back with CRLF endings' {
            $body = (Get-TestBody -Ticked $script:autoFixableId) -replace "`n", "`r`n"
            Get-DriftIssueTicked -Body $body | Should -Be $script:autoFixableId
        }

        It 'leaves an unticked body parsing to nothing' {
            Get-DriftIssueTicked -Body (Get-TestBody) | Should -HaveCount 0
        }

        It 'renders when the parse of an empty body collapsed to null' {
            # An empty Issue body parses to an empty array, which PowerShell unrolls to $null.
            $ticked = Get-DriftIssueTicked -Body ''
            $ticked | Should -BeNullOrEmpty

            { Format-DriftIssueBody -Result $script:result -Ticked $ticked } | Should -Not -Throw
        }
    }

    Describe 'Issue body truncation' {
        BeforeAll {
            $script:bulk = New-BulkResult
            $script:full = New-DriftIssueBody -Result $script:bulk
            $script:fullLength = Measure-DriftIssueBodyLength -Body $script:full

            # A budget just above what an intact approval list needs on its own. The collapsed
            # sections give up entries and the approval list does not.
            $script:collapsedBudget = 2000 + (Measure-DriftIssueBodyLength -Body (
                    New-DriftIssueBody -Result $script:bulk -CollapsedLimit 0))
        }

        It 'builds a fixture that actually exceeds what GitHub accepts' {
            $script:fullLength | Should -BeGreaterThan 65536
        }

        It 'brings an oversized body under the budget' {
            $body = Format-DriftIssueBody -Result $script:bulk
            Measure-DriftIssueBodyLength -Body $body | Should -BeLessOrEqual 65536
        }

        It 'leaves a body that already fits untouched' {
            Format-DriftIssueBody -Result $script:result -MaximumLength 65536 |
                Should -BeExactly (New-DriftIssueBody -Result $script:result)
        }

        It 'truncates the same input the same way twice' {
            $first = Format-DriftIssueBody -Result $script:bulk -MaximumLength 20000
            $second = Format-DriftIssueBody -Result $script:bulk -MaximumLength 20000

            $first | Should -BeExactly $second
        }

        It 'gives up collapsed entries before approval entries' {
            $body = Format-DriftIssueBody -Result $script:bulk -MaximumLength $script:collapsedBudget
            $rendered = @([regex]::Matches($body, '(?m)^- \[[ x]\] `([^`]+)`$'))
            $expected = @($script:bulk.Findings | Where-Object -FilterScript { $_.autoFixable })

            $rendered.Count | Should -Be $expected.Count
            # RES-TYPE-MISMATCH and RES-PROP-ORPHANED share this section.
            $body | Should -Match '## Needs a decision  \(400\)'
            $body | Should -Match '- \.\.\. and \d+ more, listed in full in the api-drift artifact\.'
        }

        It 'never drops an entry without saying so' {
            $body = Format-DriftIssueBody -Result $script:bulk -MaximumLength $script:collapsedBudget

            foreach ($name in @('Needs a decision', 'Unaccepted breaking findings'))
            {
                $section = ($body -split '(?m)^## ') | Where-Object -FilterScript { $_ -like "$name*" }
                $listed = @([regex]::Matches($section, '(?m)^- `')).Count
                $total = [System.Int32] ([regex]::Match($section, '\((\d+)\)').Groups[1].Value)

                if ($listed -lt $total)
                {
                    $section | Should -Match "and $($total - $listed) more"
                }
            }
        }

        It 'keeps the true count in a heading it could not fill' {
            $body = Format-DriftIssueBody -Result $script:bulk -MaximumLength $script:collapsedBudget
            $body | Should -Match '## Unaccepted breaking findings, oldest 2026-08-01  \(200\)'
        }

        It 'round trips a tick that survived the truncation' {
            $ticked = [System.String[]] @($script:bulk.Findings[0].id)
            $body = Format-DriftIssueBody -Result $script:bulk -Ticked $ticked -MaximumLength $script:collapsedBudget

            Get-DriftIssueTicked -Body $body | Should -Be $ticked
        }

        It 'trims the approval list only when it alone busts the budget, and says so' {
            $body = Format-DriftIssueBody -Result $script:bulk -MaximumLength 4000
            $rendered = @([regex]::Matches($body, '(?m)^- \[[ x]\] `([^`]+)`$'))

            $rendered.Count | Should -BeLessThan 200
            $rendered.Count | Should -BeGreaterThan 0
            Measure-DriftIssueBodyLength -Body $body | Should -BeLessOrEqual 4000
            $body | Should -Match "## Auto-fixable  \(tick, then comment /apply-drift\)  \(200\)"
            $body | Should -Match '- \.\.\. and \d+ more, listed in full in the api-drift artifact\.'
        }

        It 'measures the budget the way GitHub stores the body, with CRLF' {
            # A budget between the two lengths only binds when the carriage returns are counted.
            $lineFeedLength = $script:full.Length
            $script:fullLength | Should -BeGreaterThan $lineFeedLength

            $budget = $lineFeedLength + [System.Math]::Floor(($script:fullLength - $lineFeedLength) / 2)
            $body = Format-DriftIssueBody -Result $script:bulk -MaximumLength $budget

            Measure-DriftIssueBodyLength -Body $body | Should -BeLessOrEqual $budget
            $body | Should -Match '- \.\.\. and \d+ more, listed in full in the api-drift artifact\.'
        }
    }

    Describe 'Get-FittingItemLimit' {
        BeforeAll {
            $script:bisect = New-BulkResult -AutoFixable 20 -Decision 20 -Breaking 20
        }

        It 'returns the largest limit that still fits and rejects the next one up' {
            $budget = 4300
            $limit = Get-FittingItemLimit -Result $script:bisect -MaximumLength $budget -UpperBound 60

            $limit | Should -BeGreaterThan 0
            Measure-DriftIssueBodyLength -Body (New-DriftIssueBody -Result $script:bisect -CollapsedLimit $limit) |
                Should -BeLessOrEqual $budget
            Measure-DriftIssueBodyLength -Body (New-DriftIssueBody -Result $script:bisect -CollapsedLimit ($limit + 1)) |
                Should -BeGreaterThan $budget
        }

        It 'reports -1 when even an empty collapsed block is too long' {
            Get-FittingItemLimit -Result $script:bisect -MaximumLength 200 -UpperBound 60 | Should -Be -1
        }
    }

    Describe 'Get-DriftVendorSince' {
        It 'anchors on Microsoft.Graph.Authentication when several pins moved' {
            $baseline = New-TestDependency -Pinned ([ordered]@{ 'Az.Resources' = '9.0.1'; 'Microsoft.Graph.Authentication' = '2.34.0' })
            $current = New-TestDependency -Pinned ([ordered]@{ 'Az.Resources' = '10.1.0'; 'Microsoft.Graph.Authentication' = '2.35.1' })

            Get-DriftVendorSince -Baseline $baseline -Current $current |
                Should -BeExactly 'Microsoft.Graph.Authentication 2.34.0 -> 2.35.1'
        }

        It 'falls back to the first other pin that moved' {
            $baseline = New-TestDependency -Pinned ([ordered]@{ 'Az.Resources' = '9.0.1'; 'PnP.PowerShell' = '2.4.0' })
            $current = New-TestDependency -Pinned ([ordered]@{ 'Az.Resources' = '9.0.1'; 'PnP.PowerShell' = '2.5.0' })

            Get-DriftVendorSince -Baseline $baseline -Current $current | Should -BeExactly 'PnP.PowerShell 2.4.0 -> 2.5.0'
        }

        It 'returns nothing when no pin moved' {
            $snapshot = New-TestDependency -Pinned ([ordered]@{ 'Az.Resources' = '9.0.1' })
            Get-DriftVendorSince -Baseline $snapshot -Current $snapshot | Should -BeExactly ''
        }

        It 'ignores a module the current snapshot does not carry' {
            $baseline = New-TestDependency -Pinned ([ordered]@{ 'Az.Resources' = '9.0.1' })
            $current = New-TestDependency

            Get-DriftVendorSince -Baseline $baseline -Current $current | Should -BeExactly ''
        }
    }

    Describe 'API Surface Check workflow' {
        BeforeAll {
            $script:workflowPath = Join-Path -Path $script:repositoryRoot -ChildPath '.github/workflows/API Surface Check.yml'
            $script:workflow = [System.IO.File]::ReadAllText($script:workflowPath)
        }

        It 'runs weekly and on demand, never nightly' {
            $script:workflow | Should -Match "cron: '0 0 \* \* 6'"
            $script:workflow | Should -Match '(?m)^  workflow_dispatch:\r?$'
        }

        It 'uploads the drift report as an artifact' {
            $script:workflow | Should -Match 'actions/upload-artifact'
            $script:workflow | Should -Match 'Utilities/ApiSurface/api-drift\.json'
        }

        It 'updates one labeled Issue rather than opening a new one per run' {
            $script:workflow | Should -Match 'gh issue list --label \$env:DRIFT_ISSUE_LABEL'
            $script:workflow | Should -Match 'gh issue edit \$env:ISSUE_NUMBER --body-file'
        }

        It 'feeds the current body back in so ticks survive' {
            $script:workflow | Should -Match "CurrentIssueBodyPath = '\./current-issue-body\.md'"
        }
    }
}
