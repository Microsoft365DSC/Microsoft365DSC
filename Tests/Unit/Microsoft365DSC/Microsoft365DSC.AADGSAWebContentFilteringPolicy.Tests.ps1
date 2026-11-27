[CmdletBinding()]
param(
)
$M365DSCTestFolder = Join-Path -Path $PSScriptRoot `
    -ChildPath '..\..\Unit' `
    -Resolve
$CmdletModule = (Join-Path -Path $M365DSCTestFolder `
        -ChildPath '\Stubs\Microsoft365.psm1' `
        -Resolve)
$GenericStubPath = (Join-Path -Path $M365DSCTestFolder `
        -ChildPath '\Stubs\Generic.psm1' `
        -Resolve)
Import-Module -Name (Join-Path -Path $M365DSCTestFolder `
        -ChildPath '\UnitTestHelper.psm1' `
        -Resolve)

$Global:DscHelper = New-M365DscUnitTestHelper -StubModule $CmdletModule `
    -DscResource 'AADGSAWebContentFilteringPolicy' -GenericStubModule $GenericStubPath
Describe -Name $Global:DscHelper.DescribeHeader -Fixture {
    InModuleScope -ModuleName $Global:DscHelper.ModuleName -ScriptBlock {
        Invoke-Command -ScriptBlock $Global:DscHelper.InitializeScript -NoNewScope
        BeforeAll {
            $secpasswd = ConvertTo-SecureString (New-Guid | Out-String) -AsPlainText -Force
            $Credential = New-Object System.Management.Automation.PSCredential ('tenantadmin@mydomain.com', $secpasswd)

            Mock -ModuleName M365DSCUtil -CommandName Confirm-M365DSCDependencies -MockWith {
            }

            Mock -CommandName New-M365DSCConnection -ModuleName '_Shared' -MockWith {
                return 'Credentials'
            }

            Mock -CommandName Add-M365DSCTelemetryEvent -ModuleName '_Shared' -MockWith {
            }

            Mock -CommandName Get-MSCloudLoginConnectionProfile -MockWith {
                return @{
                    ResourceUrl = 'https://graph.microsoft.com/'
                }
            }

            Mock -CommandName Invoke-MgGraphRequest -MockWith {
                param($Method, $Uri, $Body)
                if ($Method -eq 'GET' -and $Uri -like '*/webFilteringPolicies?*expand=policyRules*')
                {
                    return @{
                        value = @(
                            @{
                                name        = 'Block social media websites'
                                id          = 'aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee'
                                description = 'Policy to block access to social media categories'
                                settings    = @{
                                    defaultAction = @{
                                        '@odata.type' = '#microsoft.graph.networkaccess.webFilteringActionAllow'
                                    }
                                }
                            }
                        )
                    }
                }
                if ($Method -eq 'POST' -and $Uri -like '*/webFilteringPolicies')
                {
                    return @{ id = 'aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee' }
                }
                return $null
            }

            Mock -CommandName Write-M365DSCHost -MockWith {}

            Mock -CommandName Save-M365DSCPartialExport -MockWith {}

            Mock -CommandName New-M365DSCLogEntry -ModuleName '_Shared' -MockWith {}
        }

        Context -Name 'The instance should exist but it DOES NOT' -Fixture {
            BeforeAll {
                $testParams = @{
                    Name          = 'Block social media websites'
                    Description   = 'Policy to block access to social media categories'
                    DefaultAction = 'allow'
                    Ensure        = 'Present'
                    Credential    = $Credential
                }

                Mock -CommandName Invoke-MgGraphRequest -MockWith {
                    param($Method, $Uri, $Body)
                    if ($Method -eq 'GET' -and $Uri -like '*/webFilteringPolicies?*expand=policyRules*')
                    {
                        return @{ value = @() }
                    }
                    if ($Method -eq 'POST' -and $Uri -like '*/webFilteringPolicies')
                    {
                        return @{ id = 'aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee' }
                    }
                    return $null
                }
            }

            It 'Should return Absent from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'AADGSAWebContentFilteringPolicy' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Absent'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'AADGSAWebContentFilteringPolicy' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should create a new instance from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'AADGSAWebContentFilteringPolicy' -Property $testParams).Set()
                Should -Invoke -CommandName Invoke-MgGraphRequest -Exactly 1 -ParameterFilter {
                    $Method -eq 'POST' -and $Uri -like '*/webFilteringPolicies'
                }
            }
        }

        Context -Name 'The instance exists but it SHOULD NOT' -Fixture {
            BeforeAll {
                $testParams = @{
                    Name          = 'Block social media websites'
                    Description   = 'Policy to block access to social media categories'
                    DefaultAction = 'allow'
                    Ensure        = 'Absent'
                    Credential    = $Credential
                }
            }

            It 'Should return Present from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'AADGSAWebContentFilteringPolicy' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'AADGSAWebContentFilteringPolicy' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should remove the instance from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'AADGSAWebContentFilteringPolicy' -Property $testParams).Set()
                Should -Invoke -CommandName Invoke-MgGraphRequest -Exactly 1 -ParameterFilter {
                    $Method -eq 'DELETE' -and $Uri -like '*/webFilteringPolicies/aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee'
                }
            }
        }

        Context -Name 'The instance exists and values are in the desired state' -Fixture {
            BeforeAll {
                $testParams = @{
                    Name          = 'Block social media websites'
                    Description   = 'Policy to block access to social media categories'
                    DefaultAction = 'allow'
                    Ensure        = 'Present'
                    Credential    = $Credential
                }
            }

            It 'Should return Present from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'AADGSAWebContentFilteringPolicy' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'AADGSAWebContentFilteringPolicy' -Property $testParams).Test() | Should -Be $true
            }
        }

        Context -Name 'The instance exists and values are NOT in the desired state' -Fixture {
            BeforeAll {
                $testParams = @{
                    Name          = 'Block social media websites'
                    Description   = 'Policy to block access to social media categories'
                    DefaultAction = 'block'
                    Ensure        = 'Present'
                    Credential    = $Credential
                }
            }

            It 'Should return Present from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'AADGSAWebContentFilteringPolicy' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'AADGSAWebContentFilteringPolicy' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should update the instance from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'AADGSAWebContentFilteringPolicy' -Property $testParams).Set()
                Should -Invoke -CommandName Invoke-MgGraphRequest -Exactly 1 -ParameterFilter {
                    $Method -eq 'PATCH' -and $Uri -like '*/webFilteringPolicies/aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee'
                }
            }
        }

        Context -Name 'The instance exists and Rules are NOT in the desired state' -Fixture {
            BeforeAll {
                $testParams = @{
                    Name          = 'Block social media websites'
                    Description   = 'Policy to block access to social media categories'
                    DefaultAction = 'allow'
                    Ensure        = 'Present'
                    Credential    = $Credential
                    Rules         = @(
                        [MSFT_AADGSAWebContentFilteringPolicyRule] @{
                            Name              = 'Block Facebook'
                            Priority          = [System.UInt32] 100
                            Description       = 'Block access to social networking'
                            Action            = 'block'
                            Status            = 'enabled'
                            HttpRequestMethod = 'get'
                            SessionType       = 'user'
                            Destinations      = @(
                                [MSFT_AADGSAWebContentFilteringPolicyRuleDestination] @{
                                    Type   = 'webFilteringWebCategoryDestination'
                                    Values = @('SocialNetworking')
                                }
                            )
                        }
                    )
                }

                Mock -CommandName Invoke-MgGraphRequest -MockWith {
                    param($Method, $Uri, $Body)
                    if ($Method -eq 'GET' -and $Uri -like '*/webFilteringPolicies?*expand=policyRules*')
                    {
                        return @{
                            value = @(
                                @{
                                    name        = 'Block social media websites'
                                    id          = 'aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee'
                                    description = 'Policy to block access to social media categories'
                                    settings    = @{
                                        defaultAction = @{
                                            '@odata.type' = '#microsoft.graph.networkaccess.webFilteringActionAllow'
                                        }
                                    }
                                    policyRules = @(
                                        @{
                                            id       = 'existing-rule-id'
                                            name     = 'Block a stale category'
                                            priority = 200
                                            action   = @{
                                                '@odata.type' = '#microsoft.graph.networkaccess.webFilteringActionBlock'
                                            }
                                            settings           = @{ status = 'enabled' }
                                            matchingConditions = @{
                                                destinations = @{
                                                    httpRequestMethod = 'get'
                                                    targets           = @(
                                                        @{
                                                            '@odata.type' = '#microsoft.graph.networkaccess.webFilteringWebCategoryDestination'
                                                            values        = @('Gambling')
                                                        }
                                                    )
                                                }
                                                sources = @{ sessionType = 'user' }
                                            }
                                        }
                                    )
                                }
                            )
                        }
                    }
                    return $null
                }
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'AADGSAWebContentFilteringPolicy' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should create the new rule and remove the stale rule from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'AADGSAWebContentFilteringPolicy' -Property $testParams).Set()
                Should -Invoke -CommandName Invoke-MgGraphRequest -Exactly 1 -ParameterFilter {
                    $Method -eq 'POST' -and $Uri -like '*/webFilteringPolicies/aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee/policyRules'
                }
                Should -Invoke -CommandName Invoke-MgGraphRequest -Exactly 1 -ParameterFilter {
                    $Method -eq 'DELETE' -and $Uri -like '*/policyRules/existing-rule-id'
                }
            }

            It 'Should always send matchingConditions, even when destinations would be empty' {
                (New-M365DSCResourceInstance -ResourceName 'AADGSAWebContentFilteringPolicy' -Property $testParams).Set()
                Should -Invoke -CommandName Invoke-MgGraphRequest -ParameterFilter {
                    $Method -eq 'POST' -and $Uri -like '*/policyRules' -and
                    $Body.name -eq 'Block Facebook' -and
                    $Body.ContainsKey('matchingConditions') -and
                    $Body.matchingConditions.destinations.targets.Count -eq 1
                }
            }
        }

        Context -Name 'ReverseDSC Tests' -Fixture {
            BeforeAll {
                $Global:CurrentModeIsExport = $true
                $Global:PartialExportFileName = "$(New-Guid).partial.ps1"
                $testParams = @{
                    Credential = $Credential
                }

                Mock -CommandName Invoke-MgGraphRequest -MockWith {
                    param($Method, $Uri, $Body)
                    if ($Method -eq 'GET' -and $Uri -like '*/webFilteringPolicies?*expand=policyRules*')
                    {
                        return @{
                            value = @(
                                @{
                                    name        = 'Block social media websites'
                                    id          = 'aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee'
                                    description = 'Policy to block access to social media categories'
                                    settings    = @{
                                        defaultAction = @{
                                            '@odata.type' = '#microsoft.graph.networkaccess.webFilteringActionAllow'
                                        }
                                    }
                                    policyRules = @(
                                        @{
                                            id       = 'e0cf2cb9-29cf-4e3e-b73f-0f521b2a095c'
                                            name     = 'Block Facebook'
                                            priority = 100
                                            action   = @{
                                                '@odata.type' = '#microsoft.graph.networkaccess.webFilteringActionBlock'
                                            }
                                            settings           = @{ status = 'enabled' }
                                            matchingConditions = @{
                                                destinations = @{
                                                    httpRequestMethod = 'get'
                                                    targets           = @(
                                                        @{
                                                            '@odata.type' = '#microsoft.graph.networkaccess.webFilteringWebCategoryDestination'
                                                            values        = @('SocialNetworking')
                                                        }
                                                    )
                                                }
                                                sources = @{ sessionType = 'user' }
                                            }
                                        }
                                    )
                                }
                            )
                        }
                    }
                    return $null
                }
            }

            It 'Should reverse engineer resource from the Export method' {
                $result = Invoke-M365DSCResourceMethod -ResourceName 'AADGSAWebContentFilteringPolicy' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}
