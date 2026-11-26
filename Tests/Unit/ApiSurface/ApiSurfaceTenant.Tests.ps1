[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingConvertToSecureStringWithPlainText', '',
    Justification = 'The credential is a fixture that never authenticates against anything.')]
param ()

Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath '..\..\..\Utilities\ApiSurface\M365DSCApiSurface.psd1') -Force

InModuleScope -ModuleName 'M365DSCApiSurface' {

    BeforeAll {
        function New-FakeProxy
        {
            param
            (
                [System.String] $Name,
                [System.String[]] $Command
            )

            $body = ($Command | ForEach-Object -Process {
                    "function $_ { param ([System.String] `$Shared, [System.String] `$$($_ -replace '\W', '')Only, [switch] `$Verbose) }"
                }) -join "`n"

            $module = New-Module -Name $Name -ScriptBlock ([scriptblock]::Create("$body`nExport-ModuleMember -Function '$($Command -join "','")'"))
            return (Import-Module -ModuleInfo $module -PassThru -Force)
        }

        function New-TestOriginRow
        {
            param
            (
                [System.String] $Resource,
                [System.String] $Workload,
                [System.String[]] $Cmdlet
            )

            return [PSCustomObject]@{
                Resource = $Resource
                Workload = $Workload
                Commands = @($Cmdlet | ForEach-Object -Process {
                        [PSCustomObject]@{ Name = $_; Module = 'ExchangeOnlineManagement' }
                    })
            }
        }
    }

    Describe 'New-ConnectionParameter' {
        It 'builds a credential set' {
            $credential = [System.Management.Automation.PSCredential]::new(
                'admin@contoso.onmicrosoft.com', (ConvertTo-SecureString 'x' -AsPlainText -Force))

            (New-ConnectionParameter -Credential $credential).Credential.UserName |
                Should -BeExactly 'admin@contoso.onmicrosoft.com'
        }

        It 'builds a certificate set' {
            $result = New-ConnectionParameter -ApplicationId 'app' -TenantId 'contoso.onmicrosoft.com' -CertificateThumbprint 'ABC'

            $result.ApplicationId | Should -BeExactly 'app'
            $result.CertificateThumbprint | Should -BeExactly 'ABC'
        }

        It 'refuses a credential together with a thumbprint' {
            $credential = [System.Management.Automation.PSCredential]::new(
                'admin@contoso.onmicrosoft.com', (ConvertTo-SecureString 'x' -AsPlainText -Force))

            { New-ConnectionParameter -Credential $credential -CertificateThumbprint 'ABC' } |
                Should -Throw '*not both*'
        }

        It 'refuses a tenant GUID' {
            { New-ConnectionParameter -ApplicationId 'app' `
                    -TenantId 'd4d5b2a1-0000-4000-8000-000000000000' `
                    -CertificateThumbprint 'ABC' } | Should -Throw '*domain name*'
        }

        It 'returns nothing when the set is incomplete' {
            New-ConnectionParameter -ApplicationId 'app' -TenantId 'contoso.onmicrosoft.com' | Should -BeNullOrEmpty
        }
    }

    Describe 'Resolve-ConnectedSource' {
        It 'puts Exchange Online ahead of Security and Compliance' {
            $map = @{
                SecurityComplianceCenter = (New-FakeProxy -Name 'fakeSc' -Command @('Set-ComplianceCase'))
                ExchangeOnline           = (New-FakeProxy -Name 'fakeExo' -Command @('Get-Mailbox'))
            }

            @(Resolve-ConnectedSource -ConnectedModule $map).Workload | Should -Be @('ExchangeOnline', 'SecurityComplianceCenter')
        }

        It 'skips a workload that did not connect' {
            $map = @{ ExchangeOnline = (New-FakeProxy -Name 'fakeExo2' -Command @('Get-Mailbox')) }
            @(Resolve-ConnectedSource -ConnectedModule $map).Workload | Should -Be @('ExchangeOnline')
        }

        It 'returns nothing for an empty map' {
            Resolve-ConnectedSource -ConnectedModule @{} | Should -HaveCount 0
        }
    }

    Describe 'Get-WorkloadCmdletSurface, connected' {
        BeforeAll {
            $script:origin = @(New-TestOriginRow -Resource 'R' -Workload 'ExchangeOnline' `
                    -Cmdlet @('Get-Mailbox', 'Set-ComplianceCase', 'Get-Shared', 'Get-NotAnywhere'))

            $script:map = @{
                ExchangeOnline           = (New-FakeProxy -Name 'proxyExo' -Command @('Get-Mailbox', 'Get-Shared'))
                SecurityComplianceCenter = (New-FakeProxy -Name 'proxySc' -Command @('Set-ComplianceCase', 'Get-Shared'))
            }
        }

        It 'skips the module when nothing is connected' {
            $result = Get-WorkloadCmdletSurface -Origin $script:origin
            $result.SkippedModules | Should -Contain 'ExchangeOnlineManagement'
            $result.Cmdlets.Count | Should -Be 0
        }

        It 'captures from the proxies instead of skipping' {
            $result = Get-WorkloadCmdletSurface -Origin $script:origin -ConnectedModule $script:map
            $result.SkippedModules | Should -HaveCount 0
            $result.Cmdlets.Contains('Get-Mailbox') | Should -BeTrue
            $result.Cmdlets.Contains('Set-ComplianceCase') | Should -BeTrue
        }

        It 'attributes each cmdlet to the proxy that exports it' {
            $result = Get-WorkloadCmdletSurface -Origin $script:origin -ConnectedModule $script:map
            $result.Cmdlets['Get-Mailbox'].workload | Should -BeExactly 'ExchangeOnline'
            $result.Cmdlets['Set-ComplianceCase'].workload | Should -BeExactly 'SecurityComplianceCenter'
        }

        It 'gives an overlapping cmdlet to the first proxy' {
            $result = Get-WorkloadCmdletSurface -Origin $script:origin -ConnectedModule $script:map
            $result.Cmdlets['Get-Shared'].workload | Should -BeExactly 'ExchangeOnline'
        }

        It 'reports a cmdlet neither proxy exports as missing' {
            $result = Get-WorkloadCmdletSurface -Origin $script:origin -ConnectedModule $script:map
            $result.MissingCmdlets | Should -Contain 'Get-NotAnywhere'
        }

        It 'records the spelling the proxy uses, not the one settings.json holds' {
            $origin = @(New-TestOriginRow -Resource 'R' -Workload 'ExchangeOnline' -Cmdlet @('get-MAILBOX'))
            $result = Get-WorkloadCmdletSurface -Origin $origin -ConnectedModule $script:map

            $result.Cmdlets.Contains('Get-Mailbox') | Should -BeTrue
            $result.Cmdlets.Contains('get-MAILBOX') | Should -BeFalse
        }

        It 'captures the parameters of a proxy cmdlet' {
            $result = Get-WorkloadCmdletSurface -Origin $script:origin -ConnectedModule $script:map
            @($result.Cmdlets['Get-Mailbox'].parameters.Keys) | Should -Contain 'Shared'
        }

        It 'processes only the modules IncludeModule names' {
            $result = Get-WorkloadCmdletSurface -Origin $script:origin `
                -ConnectedModule $script:map `
                -IncludeModule @('SomethingElse')

            $result.Cmdlets.Count | Should -Be 0
            $result.SkippedModules | Should -HaveCount 0
        }
    }

    Describe 'Connect-TenantWorkload' {
        It 'downgrades the run when a workload cannot be connected' {
            Mock -CommandName Get-ConnectedWorkloadModule -MockWith { throw 'no proxy appeared' }
            Mock -CommandName Import-Module -MockWith { }

            $result = Connect-TenantWorkload -Workload @('ExchangeOnline') `
                -RepositoryRoot $TestDrive `
                -ApplicationId 'app' `
                -TenantId 'contoso.onmicrosoft.com' `
                -CertificateThumbprint 'ABC' `
                -WarningAction SilentlyContinue

            $result.Module.Count | Should -Be 0
            $result.Error | Should -Match 'no proxy appeared'
        }

        It 'keeps the workload that did connect when another fails' {
            Mock -CommandName Import-Module -MockWith { }
            Mock -CommandName Get-ConnectedWorkloadModule -MockWith {
                if ($Workload -eq 'ExchangeOnline') { return (New-FakeProxy -Name 'okExo' -Command @('Get-Mailbox')) }
                throw 'security and compliance refused'
            }

            $result = Connect-TenantWorkload -Workload @('ExchangeOnline', 'SecurityComplianceCenter') `
                -RepositoryRoot $TestDrive `
                -ApplicationId 'app' `
                -TenantId 'contoso.onmicrosoft.com' `
                -CertificateThumbprint 'ABC' `
                -WarningAction SilentlyContinue

            $result.Module.Keys | Should -Be @('ExchangeOnline')
            $result.Error | Should -Match 'security and compliance refused'
        }

        It 'reports the absence of authentication rather than connecting' {
            Mock -CommandName Import-Module -MockWith { }

            $result = Connect-TenantWorkload -Workload @('ExchangeOnline') `
                -RepositoryRoot $TestDrive `
                -WarningAction SilentlyContinue

            $result.Module.Count | Should -Be 0
            $result.Error | Should -Match 'No authentication was supplied'
        }
    }

    Describe 'The incomplete run is visible in both reports' {
        BeforeAll {
            $script:result = [PSCustomObject]@{
                Findings = @()
                Coverage = @()
                Backlog  = 0
                Summary  = [PSCustomObject]@{ compared = 0; skipped = 0 }
            }
        }

        It 'renders the warning in the Markdown report' {
            Format-DriftMarkdown -Result $script:result -Warning 'ExchangeOnline was not captured.' |
                Should -Match 'Incomplete run.*ExchangeOnline was not captured'
        }

        It 'renders the warning above the approval list in the Issue body' {
            $body = Format-DriftIssueBody -Result $script:result -Warning 'ExchangeOnline was not captured.'
            $lines = @($body -split "`r?`n")
            $heading = @($lines | Where-Object -FilterScript { $_ -like '## Auto-fixable*' })[0]

            $lines[0] | Should -Match 'Incomplete run'
            $lines.IndexOf($heading) | Should -BeGreaterThan 0
        }

        It 'says nothing when the run was complete' {
            Format-DriftIssueBody -Result $script:result -Warning '' | Should -Not -Match 'Incomplete run'
            Format-DriftMarkdown -Result $script:result | Should -Not -Match 'Incomplete run'
        }
    }

    Describe 'Get-BaselineRegression' {
        BeforeAll {
            function New-CompletenessSnapshot
            {
                param ([System.String[]] $Skipped = @())

                return [PSCustomObject]@{ completeness = [PSCustomObject]@{ skippedWorkloads = $Skipped } }
            }
        }

        It 'Names a workload the baseline holds and the run could not see' {
            $lost = @(Get-BaselineRegression `
                    -Baseline (New-CompletenessSnapshot) `
                    -Current (New-CompletenessSnapshot -Skipped @('ExchangeOnline', 'settingsCatalog')))

            $lost | Should -HaveCount 2
            $lost | Should -Contain 'settingsCatalog'
        }

        It 'Reports nothing when the run saw at least as much as the baseline' {
            @(Get-BaselineRegression `
                    -Baseline (New-CompletenessSnapshot -Skipped @('ExchangeOnline')) `
                    -Current (New-CompletenessSnapshot -Skipped @('ExchangeOnline'))) | Should -HaveCount 0

            @(Get-BaselineRegression `
                    -Baseline (New-CompletenessSnapshot -Skipped @('ExchangeOnline')) `
                    -Current (New-CompletenessSnapshot)) | Should -HaveCount 0
        }
    }
}
