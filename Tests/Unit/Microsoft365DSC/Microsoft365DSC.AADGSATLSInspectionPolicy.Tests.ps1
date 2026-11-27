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
    -DscResource 'AADGSATLSInspectionPolicy' -GenericStubModule $GenericStubPath
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
                if ($Method -eq 'GET' -and $Uri -like '*/tlsInspectionPolicies?*expand=policyRules*')
                {
                    return @{
                        value = @(
                            @{
                                name        = 'Contoso TLS Inspection Policy'
                                id          = 'aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee'
                                description = 'Default TLS inspection policy for Contoso'
                                settings    = @{
                                    defaultAction = 'bypass'
                                }
                            }
                        )
                    }
                }
                if ($Method -eq 'POST' -and $Uri -like '*/tlsInspectionPolicies')
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
                    Name          = 'Contoso TLS Inspection Policy'
                    Description   = 'Default TLS inspection policy for Contoso'
                    DefaultAction = 'bypass'
                    Ensure        = 'Present'
                    Credential    = $Credential
                }

                Mock -CommandName Invoke-MgGraphRequest -MockWith {
                    param($Method, $Uri, $Body)
                    if ($Method -eq 'GET' -and $Uri -like '*/tlsInspectionPolicies?*expand=policyRules*')
                    {
                        return @{ value = @() }
                    }
                    if ($Method -eq 'POST' -and $Uri -like '*/tlsInspectionPolicies')
                    {
                        return @{ id = 'aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee' }
                    }
                    return $null
                }
            }

            It 'Should return Absent from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'AADGSATLSInspectionPolicy' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Absent'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'AADGSATLSInspectionPolicy' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should create a new instance from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'AADGSATLSInspectionPolicy' -Property $testParams).Set()
                Should -Invoke -CommandName Invoke-MgGraphRequest -Exactly 1 -ParameterFilter {
                    $Method -eq 'POST' -and $Uri -like '*/tlsInspectionPolicies'
                }
            }
        }

        Context -Name 'The instance exists but it SHOULD NOT' -Fixture {
            BeforeAll {
                $testParams = @{
                    Name          = 'Contoso TLS Inspection Policy'
                    Description   = 'Default TLS inspection policy for Contoso'
                    DefaultAction = 'bypass'
                    Ensure        = 'Absent'
                    Credential    = $Credential
                }
            }

            It 'Should return Present from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'AADGSATLSInspectionPolicy' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'AADGSATLSInspectionPolicy' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should remove the instance from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'AADGSATLSInspectionPolicy' -Property $testParams).Set()
                Should -Invoke -CommandName Invoke-MgGraphRequest -Exactly 1 -ParameterFilter {
                    $Method -eq 'DELETE' -and $Uri -like '*/tlsInspectionPolicies/aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee'
                }
            }
        }

        Context -Name 'The instance exists and values are in the desired state' -Fixture {
            BeforeAll {
                $testParams = @{
                    Name          = 'Contoso TLS Inspection Policy'
                    Description   = 'Default TLS inspection policy for Contoso'
                    DefaultAction = 'bypass'
                    Ensure        = 'Present'
                    Credential    = $Credential
                }
            }

            It 'Should return Present from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'AADGSATLSInspectionPolicy' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'AADGSATLSInspectionPolicy' -Property $testParams).Test() | Should -Be $true
            }
        }

        Context -Name 'The instance exists and values are NOT in the desired state' -Fixture {
            BeforeAll {
                $testParams = @{
                    Name          = 'Contoso TLS Inspection Policy'
                    Description   = 'Default TLS inspection policy for Contoso'
                    DefaultAction = 'inspect'
                    Ensure        = 'Present'
                    Credential    = $Credential
                }
            }

            It 'Should return Present from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'AADGSATLSInspectionPolicy' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'AADGSATLSInspectionPolicy' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should update the instance from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'AADGSATLSInspectionPolicy' -Property $testParams).Set()
                Should -Invoke -CommandName Invoke-MgGraphRequest -Exactly 1 -ParameterFilter {
                    $Method -eq 'PATCH' -and $Uri -like '*/tlsInspectionPolicies/aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee'
                }
            }
        }

        Context -Name 'The instance exists and Rules are NOT in the desired state' -Fixture {
            BeforeAll {
                $testParams = @{
                    Name          = 'Contoso TLS Inspection Policy'
                    Description   = 'Default TLS inspection policy for Contoso'
                    DefaultAction = 'bypass'
                    Ensure        = 'Present'
                    Credential    = $Credential
                    Rules         = @(
                        [MSFT_AADGSATLSInspectionPolicyRule] @{
                            Name         = 'test rule 01'
                            Priority     = [System.UInt32] 100
                            Description  = 'test rule 01 description'
                            Action       = 'inspect'
                            Status       = 'enabled'
                            Destinations = @(
                                [MSFT_AADGSATLSInspectionPolicyRuleDestination] @{
                                    Type   = 'tlsInspectionFqdnDestination'
                                    Values = @('contoso.com')
                                }
                            )
                        },
                        [MSFT_AADGSATLSInspectionPolicyRule] @{
                            Name     = 'System Bypass TLS inspection rule'
                            Priority = [System.UInt32] 50
                            Action   = 'bypass'
                            Status   = 'enabled'
                        }
                    )
                }

                Mock -CommandName Invoke-MgGraphRequest -MockWith {
                    param($Method, $Uri, $Body)
                    if ($Method -eq 'GET' -and $Uri -like '*/tlsInspectionPolicies?*expand=policyRules*')
                    {
                        return @{
                            value = @(
                                @{
                                    name        = 'Contoso TLS Inspection Policy'
                                    id          = 'aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee'
                                    description = 'Default TLS inspection policy for Contoso'
                                    settings    = @{
                                        defaultAction = 'bypass'
                                    }
                                    policyRules = @(
                                        @{
                                            id                 = 'existing-rule-id'
                                            name               = 'test rule to remove'
                                            priority           = 200
                                            action             = 'bypass'
                                            settings           = @{ status = 'enabled' }
                                            matchingConditions = $null
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
                (New-M365DSCResourceInstance -ResourceName 'AADGSATLSInspectionPolicy' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should create the new rules and remove the stale rule from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'AADGSATLSInspectionPolicy' -Property $testParams).Set()
                Should -Invoke -CommandName Invoke-MgGraphRequest -Exactly 2 -ParameterFilter {
                    $Method -eq 'POST' -and $Uri -like '*/tlsInspectionPolicies/aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee/policyRules'
                }
                Should -Invoke -CommandName Invoke-MgGraphRequest -Exactly 1 -ParameterFilter {
                    $Method -eq 'DELETE' -and $Uri -like '*/policyRules/existing-rule-id'
                }
            }

            It 'Should always send matchingConditions, even for a rule without destinations' {
                (New-M365DSCResourceInstance -ResourceName 'AADGSATLSInspectionPolicy' -Property $testParams).Set()
                Should -Invoke -CommandName Invoke-MgGraphRequest -ParameterFilter {
                    $Method -eq 'POST' -and $Uri -like '*/policyRules' -and
                    $Body.name -eq 'System Bypass TLS inspection rule' -and
                    $Body.ContainsKey('matchingConditions') -and
                    $Body.matchingConditions.destinations.Count -eq 0
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
                    if ($Method -eq 'GET' -and $Uri -like '*/tlsInspectionPolicies?*expand=policyRules*')
                    {
                        return @{
                            value = @(
                                @{
                                    name        = 'Contoso TLS Inspection Policy'
                                    id          = 'aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee'
                                    description = 'Default TLS inspection policy for Contoso'
                                    settings    = @{
                                        defaultAction = 'bypass'
                                    }
                                    policyRules = @(
                                        @{
                                            id                 = 'e0cf2cb9-29cf-4e3e-b73f-0f521b2a095c'
                                            name               = 'test rule 01'
                                            priority           = 100
                                            description        = 'test rule 01 description'
                                            action             = 'inspect'
                                            settings           = @{ status = 'enabled' }
                                            matchingConditions = @{
                                                destinations = @(
                                                    @{
                                                        '@odata.type' = '#microsoft.graph.networkaccess.tlsInspectionFqdnDestination'
                                                        values        = @('contoso.com')
                                                    }
                                                )
                                            }
                                        },
                                        @{
                                            id                 = '72d8838d-2b8f-4f0a-aba2-ee5302b10457'
                                            name               = 'System Bypass TLS inspection rule'
                                            priority           = 50
                                            description        = 'Auto-created TLS rule for system bypass categories.'
                                            action             = 'bypass'
                                            settings           = @{ status = 'enabled' }
                                            matchingConditions = $null
                                        },
                                        @{
                                            id                 = '70c325ce-29f1-4cc5-a821-8e6e6ecd37ec'
                                            name               = 'Recommended TLS inspection bypass categories rule'
                                            priority           = 65000
                                            description        = 'Auto-created TLS rule for recommended bypass categories.'
                                            action             = 'bypass'
                                            settings           = @{ status = 'enabled' }
                                            matchingConditions = @{
                                                destinations = @(
                                                    @{
                                                        '@odata.type' = '#microsoft.graph.networkaccess.tlsInspectionWebCategoryDestination'
                                                        values        = @('Education', 'Finance', 'Government', 'HealthAndMedicine')
                                                    }
                                                )
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
                $result = Invoke-M365DSCResourceMethod -ResourceName 'AADGSATLSInspectionPolicy' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }

            It 'Should exclude the auto-created system rules from the Get method' {
                $result = (New-M365DSCResourceInstance -ResourceName 'AADGSATLSInspectionPolicy' -Property @{ Name = 'Contoso TLS Inspection Policy'; Credential = $Credential }).Get().ToHashtable()
                $result.Rules.Name | Should -Not -Contain 'System Bypass TLS inspection rule'
                $result.Rules.Name | Should -Not -Contain 'Recommended TLS inspection bypass categories rule'
                $result.Rules.Name | Should -Contain 'test rule 01'
            }
        }
    }
}
