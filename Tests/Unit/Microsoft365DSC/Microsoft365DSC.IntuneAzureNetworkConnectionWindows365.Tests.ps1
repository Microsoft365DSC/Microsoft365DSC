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
    -DscResource "IntuneAzureNetworkConnectionWindows365" -GenericStubModule $GenericStubPath
Describe -Name $Global:DscHelper.DescribeHeader -Fixture {
    InModuleScope -ModuleName $Global:DscHelper.ModuleName -ScriptBlock {
        Invoke-Command -ScriptBlock $Global:DscHelper.InitializeScript -NoNewScope
        BeforeAll {

            $secpasswd = ConvertTo-SecureString (New-Guid | Out-String) -AsPlainText -Force
            $Credential = New-Object System.Management.Automation.PSCredential ('tenantadmin@onmicrosoft.com', $secpasswd)

            Mock -ModuleName M365DSCUtil -CommandName Confirm-M365DSCDependencies -MockWith {
            }

            Mock -CommandName Get-MSCloudLoginConnectionProfile -MockWith {
            }

            Mock -CommandName Reset-MSCloudLoginConnectionProfileContext -MockWith {
            }

            Mock -CommandName Get-PSSession -MockWith {
            }

            Mock -CommandName Remove-PSSession -MockWith {
            }

            Mock -CommandName Update-MgBetaDeviceManagementVirtualEndpointOnPremiseConnection -MockWith {
            }

            Mock -CommandName New-MgBetaDeviceManagementVirtualEndpointOnPremiseConnection -MockWith {
            }

            Mock -CommandName Remove-MgBetaDeviceManagementVirtualEndpointOnPremiseConnection -MockWith {
            }

            Mock -CommandName Get-MgBetaDeviceManagementVirtualEndpointOnPremiseConnection -MockWith {
                return @{
                    AdDomainName = "FakeStringValue"
                    AdDomainPassword = "FakeStringValue"
                    AdDomainUsername = "FakeStringValue"
                    AlternateResourceUrl = "FakeStringValue"
                    ConnectionType = "hybridAzureADJoin"
                    DisplayName = "FakeStringValue"
                    HealthCheckPaused = $True
                    HealthCheckStatus = "pending"
                    HealthCheckStatusDetail = @{
                        HealthChecks = @(
                            @{
                                AdditionalDetails = "FakeStringValue"
                                DisplayName = "FakeStringValue"
                                RecommendedAction = "FakeStringValue"
                                ErrorType = "dnsCheckFqdnNotFound"
                                Status = "pending"
                                StartDateTime = "2023-01-01T00:00:00.0000000+01:00"
                                CorrelationId = "FakeStringValue"
                                EndDateTime = "2023-01-01T00:00:00.0000000+01:00"
                                AdditionalDetail = "FakeStringValue"
                            }
                        )
                        StartDateTime = "2023-01-01T00:00:00.0000000+01:00"
                        EndDateTime = "2023-01-01T00:00:00.0000000+01:00"
                    }
                    HealthCheckStatusDetails = @{
                        HealthChecks = @(
                            @{
                                AdditionalDetails = "FakeStringValue"
                                DisplayName = "FakeStringValue"
                                RecommendedAction = "FakeStringValue"
                                ErrorType = "dnsCheckFqdnNotFound"
                                Status = "pending"
                                StartDateTime = "2023-01-01T00:00:00.0000000+01:00"
                                CorrelationId = "FakeStringValue"
                                EndDateTime = "2023-01-01T00:00:00.0000000+01:00"
                                AdditionalDetail = "FakeStringValue"
                            }
                        )
                        StartDateTime = "2023-01-01T00:00:00.0000000+01:00"
                        EndDateTime = "2023-01-01T00:00:00.0000000+01:00"
                    }
                    Id = "FakeStringValue"
                    InUse = $True
                    InUseByCloudPc = $True
                    ManagedBy = "windows365"
                    OrganizationalUnit = "FakeStringValue"
                    ResourceGroupId = "/subscriptions/FakeStringValue/resourceGroups/FakeStringValue"
                    ScopeIds = @("FakeStringValue")
                    SubnetId = "/subscriptions/FakeStringValue/resourceGroups/FakeStringValue/providers/Microsoft.Network/virtualNetworks/FakeStringValue/subnets/FakeStringValue"
                    SubscriptionId = "/subscriptions/FakeStringValue"
                    SubscriptionName = "FakeStringValue"
                    Type = "hybridAzureADJoin"
                    VirtualNetworkId = "/subscriptions/FakeStringValue/resourceGroups/FakeStringValue/providers/Microsoft.Network/virtualNetworks/FakeStringValue"
                    VirtualNetworkLocation = "FakeStringValue"
                }
            }

            Mock -CommandName Get-AzSubscription -MockWith {
                return @{
                    Id = "FakeStringValue"
                    Name = "FakeStringValue"
                }
            }

            Mock -CommandName New-M365DSCConnection -ModuleName '_Shared' -MockWith {
                return "Credentials"
            }

            # Mock Write-M365DSCHost to hide output during the tests
            Mock -CommandName Write-M365DSCHost -MockWith {
            }
            $Script:exportedInstance = $null
            $Script:ExportMode = $false
        }

        # Test contexts
        Context -Name "The IntuneAzureNetworkConnectionWindows365 should exist but it DOES NOT" -Fixture {
            BeforeAll {
                $testParams = @{
                    AdDomainName = "FakeStringValue"
                    AdDomainUsername = "FakeStringValue"
                    ConnectionType = "hybridAzureADJoin"
                    DisplayName = "FakeStringValue"
                    Id = "FakeStringValue"
                    OrganizationalUnit = "FakeStringValue"
                    ResourceGroupId = "/subscriptions/FakeStringValue/resourceGroups/FakeStringValue"
                    ScopeIds        = @("FakeStringValue")
                    SubnetId = "/subscriptions/FakeStringValue/resourceGroups/FakeStringValue/providers/Microsoft.Network/virtualNetworks/FakeStringValue/subnets/FakeStringValue"
                    SubscriptionName = "FakeStringValue"
                    VirtualNetworkId = "/subscriptions/FakeStringValue/resourceGroups/FakeStringValue/providers/Microsoft.Network/virtualNetworks/FakeStringValue"
                    Ensure = "Present"
                    Credential = $Credential;
                }

                Mock -CommandName Get-MgBetaDeviceManagementVirtualEndpointOnPremiseConnection -MockWith {
                    return $null
                }
            }
            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'IntuneAzureNetworkConnectionWindows365' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Absent'
            }
            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneAzureNetworkConnectionWindows365' -Property $testParams).Test() | Should -Be $false
            }
            It 'Should Create the group from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneAzureNetworkConnectionWindows365' -Property $testParams).Set()
                Should -Invoke -CommandName New-MgBetaDeviceManagementVirtualEndpointOnPremiseConnection -Exactly 1
            }
        }

        Context -Name "The IntuneAzureNetworkConnectionWindows365 exists but it SHOULD NOT" -Fixture {
            BeforeAll {
                $testParams = @{
                    AdDomainName = "FakeStringValue"
                    AdDomainUsername = "FakeStringValue"
                    ConnectionType = "hybridAzureADJoin"
                    DisplayName = "FakeStringValue"
                    Id = "FakeStringValue"
                    OrganizationalUnit = "FakeStringValue"
                    ResourceGroupId = "/subscriptions/FakeStringValue/resourceGroups/FakeStringValue"
                    ScopeIds        = @("FakeStringValue")
                    SubnetId = "/subscriptions/FakeStringValue/resourceGroups/FakeStringValue/providers/Microsoft.Network/virtualNetworks/FakeStringValue/subnets/FakeStringValue"
                    SubscriptionName = "FakeStringValue"
                    VirtualNetworkId = "/subscriptions/FakeStringValue/resourceGroups/FakeStringValue/providers/Microsoft.Network/virtualNetworks/FakeStringValue"
                    Ensure = "Absent"
                    Credential = $Credential;
                }
            }

            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'IntuneAzureNetworkConnectionWindows365' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneAzureNetworkConnectionWindows365' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should Remove the group from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneAzureNetworkConnectionWindows365' -Property $testParams).Set()
                Should -Invoke -CommandName Remove-MgBetaDeviceManagementVirtualEndpointOnPremiseConnection -Exactly 1
            }
        }

        Context -Name "The IntuneAzureNetworkConnectionWindows365 Exists and Values are already in the desired state" -Fixture {
            BeforeAll {
                $testParams = @{
                    AdDomainName = "FakeStringValue"
                    AdDomainUsername = "FakeStringValue"
                    ConnectionType = "hybridAzureADJoin"
                    DisplayName = "FakeStringValue"
                    Id = "FakeStringValue"
                    OrganizationalUnit = "FakeStringValue"
                    ResourceGroupId = "/subscriptions/FakeStringValue/resourceGroups/FakeStringValue"
                    ScopeIds        = @("FakeStringValue")
                    SubnetId = "/subscriptions/FakeStringValue/resourceGroups/FakeStringValue/providers/Microsoft.Network/virtualNetworks/FakeStringValue/subnets/FakeStringValue"
                    SubscriptionName = "FakeStringValue"
                    VirtualNetworkId = "/subscriptions/FakeStringValue/resourceGroups/FakeStringValue/providers/Microsoft.Network/virtualNetworks/FakeStringValue"
                    Ensure = "Present"
                    Credential = $Credential;
                }
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneAzureNetworkConnectionWindows365' -Property $testParams).Test() | Should -Be $true
            }
        }

        Context -Name "The IntuneAzureNetworkConnectionWindows365 exists and values are NOT in the desired state" -Fixture {
            BeforeAll {
                $testParams = @{
                    AdDomainName = "FakeStringValue"
                    AdDomainUsername = "FakeStringValue"
                    ConnectionType = "hybridAzureADJoin"
                    DisplayName = "FakeStringValue"
                    Id = "FakeStringValue"
                    OrganizationalUnit = "FakeStringValue"
                    ResourceGroupId = "/subscriptions/FakeStringValue/resourceGroups/FakeStringValue"
                    ScopeIds        = @("FakeStringValue")
                    SubnetId = "/subscriptions/FakeStringValue/resourceGroups/FakeStringValue/providers/Microsoft.Network/virtualNetworks/FakeStringValue-2/subnets/FakeStringValue" # Drift
                    SubscriptionName = "FakeStringValue"
                    VirtualNetworkId = "/subscriptions/FakeStringValue/resourceGroups/FakeStringValue/providers/Microsoft.Network/virtualNetworks/FakeStringValue-2" # Drift
                    Ensure = "Present"
                    Credential = $Credential;
                }
            }

            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'IntuneAzureNetworkConnectionWindows365' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneAzureNetworkConnectionWindows365' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should call the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneAzureNetworkConnectionWindows365' -Property $testParams).Set()
                Should -Invoke -CommandName Update-MgBetaDeviceManagementVirtualEndpointOnPremiseConnection -Exactly 1
            }
        }

        Context -Name 'ReverseDSC Tests' -Fixture {
            BeforeAll {
                $Global:CurrentModeIsExport = $true
                $Global:PartialExportFileName = "$(New-Guid).partial.ps1"
                $testParams = @{
                    Credential = $Credential
                }
            }

            It 'Should Reverse Engineer resource from the Export method' {
                $result = Invoke-M365DSCResourceMethod -ResourceName 'IntuneAzureNetworkConnectionWindows365' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
