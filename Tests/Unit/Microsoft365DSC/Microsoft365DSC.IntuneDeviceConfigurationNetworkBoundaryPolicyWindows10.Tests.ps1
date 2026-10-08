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
    -DscResource 'IntuneDeviceConfigurationNetworkBoundaryPolicyWindows10' -GenericStubModule $GenericStubPath
Describe -Name $Global:DscHelper.DescribeHeader -Fixture {
    InModuleScope -ModuleName $Global:DscHelper.ModuleName -ScriptBlock {
        Invoke-Command -ScriptBlock $Global:DscHelper.InitializeScript -NoNewScope
        BeforeAll {

            $secpasswd = ConvertTo-SecureString (New-GUID).ToString() -AsPlainText -Force
            $Credential = New-Object System.Management.Automation.PSCredential ('tenantadmin@onmicrosoft.com', $secpasswd)

            Mock -ModuleName M365DSCUtil -CommandName Confirm-M365DSCDependencies -MockWith {
            }

            Mock -CommandName Get-PSSession -MockWith {
            }

            Mock -CommandName Remove-PSSession -MockWith {
            }

            Mock -CommandName Update-MgBetaDeviceManagementDeviceConfiguration -MockWith {
            }

            Mock -CommandName New-MgBetaDeviceManagementDeviceConfiguration -MockWith {
            }

            Mock -CommandName Remove-MgBetaDeviceManagementDeviceConfiguration -MockWith {
            }

            Mock -CommandName New-M365DSCConnection -ModuleName '_Shared' -MockWith {
                return 'Credentials'
            }

            Mock -CommandName Get-M365DSCExportCachedCollection -MockWith {
                return Get-MgBetaDeviceManagementDeviceConfiguration
            }
            Mock -CommandName Get-MgBetaDeviceManagementDeviceConfiguration -MockWith {
                return @{
                    windowsNetworkIsolationPolicy               = @{
                        EnterpriseProxyServers                 = @('FakeStringValue')
                        EnterpriseInternalProxyServers         = @('FakeStringValue')
                        EnterpriseIPRangesAreAuthoritative     = $True
                        EnterpriseCloudResources               = @(
                            @{
                                Proxy           = 'FakeStringValue'
                                IpAddressOrFQDN = 'FakeStringValue'
                            }
                        )
                        EnterpriseProxyServersAreAuthoritative = $True
                        EnterpriseNetworkDomainNames           = @('FakeStringValue')
                        EnterpriseIPRanges                     = @(
                            @{
                                UpperAddress  = 'FakeStringValue'
                                LowerAddress  = 'FakeStringValue'
                                '@odata.type' = '#microsoft.graph.iPv4Range'
                            }
                        )
                        NeutralDomainResources                 = @('FakeStringValue')
                    }
                    '@odata.type'                               = '#microsoft.graph.windows10NetworkBoundaryConfiguration'
                    description                                 = 'FakeStringValue'
                    deviceManagementApplicabilityRuleDeviceMode = @{
                        name       = 'FakeStringValue'
                        deviceMode = 'standardConfiguration'
                        ruleType   = 'include'
                    }
                    deviceManagementApplicabilityRuleOsEdition  = @{
                        name           = 'FakeStringValue'
                        osEditionTypes = @('windows10Enterprise')
                        ruleType       = 'include'
                    }
                    deviceManagementApplicabilityRuleOsVersion  = @{
                        name         = 'FakeStringValue'
                        minOSVersion = '10.0.19045.0'
                        maxOSVersion = '10.0.26100.9999'
                        ruleType     = 'include'
                    }
                    displayName                                 = 'FakeStringValue'
                    id                                          = 'FakeStringValue'
                }
            }

            Mock -CommandName Get-MgBetaDeviceManagementDeviceConfigurationAssignment -MockWith {
            }
            Mock -CommandName Update-DeviceConfigurationPolicyAssignment -MockWith {
            }
            # Mock Write-M365DSCHost to hide output during the tests
            Mock -CommandName Write-M365DSCHost -MockWith {
            }
            $Script:exportedInstances =$null
            $Script:ExportMode = $false
        }

        # Test contexts
        Context -Name 'The IntuneDeviceConfigurationNetworkBoundaryPolicyWindows10 should exist but it DOES NOT' -Fixture {
            BeforeAll {
                $testParams = @{
                    description                                 = 'FakeStringValue'
                    deviceManagementApplicabilityRuleDeviceMode = @{
                        name       = 'FakeStringValue'
                        deviceMode = 'standardConfiguration'
                        ruleType   = 'include'
                    }
                    deviceManagementApplicabilityRuleOsEdition  = @{
                        name           = 'FakeStringValue'
                        osEditionTypes = @('windows10Enterprise')
                        ruleType       = 'include'
                    }
                    deviceManagementApplicabilityRuleOsVersion  = @{
                        name         = 'FakeStringValue'
                        minOSVersion = '10.0.19045.0'
                        maxOSVersion = '10.0.26100.9999'
                        ruleType     = 'include'
                    }
                    displayName                                 = 'FakeStringValue'
                    id                                          = 'FakeStringValue'
                    windowsNetworkIsolationPolicy               = ([MSFT_MicrosoftGraphwindowsNetworkIsolationPolicy] @{
                            EnterpriseProxyServers                 = @('FakeStringValue')
                            EnterpriseInternalProxyServers         = @('FakeStringValue')
                            EnterpriseIPRangesAreAuthoritative     = $True
                            EnterpriseCloudResources               = @(
                            ([MSFT_MicrosoftGraphProxiedDomain] @{
                                    Proxy           = 'FakeStringValue'
                                    IpAddressOrFQDN = 'FakeStringValue'
                                })
                            )
                            EnterpriseProxyServersAreAuthoritative = $True
                            EnterpriseNetworkDomainNames           = @('FakeStringValue')
                            EnterpriseIPRanges                     = @(
                            ([MSFT_MicrosoftGraphIpRange] @{
                                    UpperAddress = 'FakeStringValue'
                                    LowerAddress = 'FakeStringValue'
                                    odataType    = '#microsoft.graph.iPv4Range'
                                })
                            )
                            NeutralDomainResources                 = @('FakeStringValue')
                        })
                    Ensure                                      = 'Present'
                    Credential                                  = $Credential
                }

                Mock -CommandName Get-MgBetaDeviceManagementDeviceConfiguration -MockWith {
                    return $null
                }
            }
            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'IntuneDeviceConfigurationNetworkBoundaryPolicyWindows10' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Absent'
            }
            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneDeviceConfigurationNetworkBoundaryPolicyWindows10' -Property $testParams).Test() | Should -Be $false
            }
            It 'Should Create the group from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneDeviceConfigurationNetworkBoundaryPolicyWindows10' -Property $testParams).Set()
                Should -Invoke -CommandName New-MgBetaDeviceManagementDeviceConfiguration -Exactly 1
            }
        }

        Context -Name 'The IntuneDeviceConfigurationNetworkBoundaryPolicyWindows10 exists but it SHOULD NOT' -Fixture {
            BeforeAll {
                $testParams = @{
                    description                                 = 'FakeStringValue'
                    deviceManagementApplicabilityRuleDeviceMode = @{
                        name       = 'FakeStringValue'
                        deviceMode = 'standardConfiguration'
                        ruleType   = 'include'
                    }
                    deviceManagementApplicabilityRuleOsEdition  = @{
                        name           = 'FakeStringValue'
                        osEditionTypes = @('windows10Enterprise')
                        ruleType       = 'include'
                    }
                    deviceManagementApplicabilityRuleOsVersion  = @{
                        name         = 'FakeStringValue'
                        minOSVersion = '10.0.19045.0'
                        maxOSVersion = '10.0.26100.9999'
                        ruleType     = 'include'
                    }
                    displayName                                 = 'FakeStringValue'
                    id                                          = 'FakeStringValue'
                    windowsNetworkIsolationPolicy               = ([MSFT_MicrosoftGraphwindowsNetworkIsolationPolicy] @{
                            EnterpriseProxyServers                 = @('FakeStringValue')
                            EnterpriseInternalProxyServers         = @('FakeStringValue')
                            EnterpriseIPRangesAreAuthoritative     = $True
                            EnterpriseCloudResources               = @(
                            ([MSFT_MicrosoftGraphProxiedDomain] @{
                                    Proxy           = 'FakeStringValue'
                                    IpAddressOrFQDN = 'FakeStringValue'
                                })
                            )
                            EnterpriseProxyServersAreAuthoritative = $True
                            EnterpriseNetworkDomainNames           = @('FakeStringValue')
                            EnterpriseIPRanges                     = @(
                            ([MSFT_MicrosoftGraphIpRange] @{
                                    UpperAddress = 'FakeStringValue'
                                    LowerAddress = 'FakeStringValue'
                                    odataType    = '#microsoft.graph.iPv4Range'
                                })
                            )
                            NeutralDomainResources                 = @('FakeStringValue')
                        })
                    Ensure                                      = 'Absent'
                    Credential                                  = $Credential
                }
            }

            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'IntuneDeviceConfigurationNetworkBoundaryPolicyWindows10' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneDeviceConfigurationNetworkBoundaryPolicyWindows10' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should Remove the group from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneDeviceConfigurationNetworkBoundaryPolicyWindows10' -Property $testParams).Set()
                Should -Invoke -CommandName Remove-MgBetaDeviceManagementDeviceConfiguration -Exactly 1
            }
        }
        Context -Name 'The IntuneDeviceConfigurationNetworkBoundaryPolicyWindows10 Exists and Values are already in the desired state' -Fixture {
            BeforeAll {
                $testParams = @{
                    description                                 = 'FakeStringValue'
                    deviceManagementApplicabilityRuleDeviceMode = @{
                        name       = 'FakeStringValue'
                        deviceMode = 'standardConfiguration'
                        ruleType   = 'include'
                    }
                    deviceManagementApplicabilityRuleOsEdition  = @{
                        name           = 'FakeStringValue'
                        osEditionTypes = @('windows10Enterprise')
                        ruleType       = 'include'
                    }
                    deviceManagementApplicabilityRuleOsVersion  = @{
                        name         = 'FakeStringValue'
                        minOSVersion = '10.0.19045.0'
                        maxOSVersion = '10.0.26100.9999'
                        ruleType     = 'include'
                    }
                    displayName                                 = 'FakeStringValue'
                    id                                          = 'FakeStringValue'
                    windowsNetworkIsolationPolicy               = ([MSFT_MicrosoftGraphwindowsNetworkIsolationPolicy] @{
                            EnterpriseProxyServers                 = @('FakeStringValue')
                            EnterpriseInternalProxyServers         = @('FakeStringValue')
                            EnterpriseIPRangesAreAuthoritative     = $True
                            EnterpriseCloudResources               = @(
                            ([MSFT_MicrosoftGraphProxiedDomain] @{
                                    Proxy           = 'FakeStringValue'
                                    IpAddressOrFQDN = 'FakeStringValue'
                                })
                            )
                            EnterpriseProxyServersAreAuthoritative = $True
                            EnterpriseNetworkDomainNames           = @('FakeStringValue')
                            EnterpriseIPRanges                     = @(
                            ([MSFT_MicrosoftGraphIpRange] @{
                                    UpperAddress = 'FakeStringValue'
                                    LowerAddress = 'FakeStringValue'
                                    odataType    = '#microsoft.graph.iPv4Range'
                                })
                            )
                            NeutralDomainResources                 = @('FakeStringValue')
                        })
                    Ensure                                      = 'Present'
                    Credential                                  = $Credential
                }
            }


            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneDeviceConfigurationNetworkBoundaryPolicyWindows10' -Property $testParams).Test() | Should -Be $true
            }
        }

        Context -Name 'The IntuneDeviceConfigurationNetworkBoundaryPolicyWindows10 exists and values are NOT in the desired state' -Fixture {
            BeforeAll {
                $testParams = @{
                    description                                 = 'FakeStringValue'
                    deviceManagementApplicabilityRuleDeviceMode = @{
                        name       = 'FakeStringValue'
                        deviceMode = 'sModeConfiguration' # Updated property
                        ruleType   = 'include'
                    }
                    deviceManagementApplicabilityRuleOsEdition  = @{
                        name           = 'FakeStringValue'
                        osEditionTypes = @('windows10Enterprise')
                        ruleType       = 'exclude' # Updated property
                    }
                    deviceManagementApplicabilityRuleOsVersion  = @{
                        name         = 'FakeStringValue'
                        minOSVersion = '10.0.19045.0'
                        maxOSVersion = '10.0.26100.9999'
                        ruleType     = 'include'
                    }
                    displayName                                 = 'FakeStringValue'
                    id                                          = 'FakeStringValue'
                    windowsNetworkIsolationPolicy               = ([MSFT_MicrosoftGraphwindowsNetworkIsolationPolicy] @{
                            EnterpriseProxyServers                 = @('FakeStringValue')
                            EnterpriseInternalProxyServers         = @('FakeStringValue')
                            EnterpriseIPRangesAreAuthoritative     = $False # Updated property
                            EnterpriseCloudResources               = @(
                            ([MSFT_MicrosoftGraphProxiedDomain] @{
                                    Proxy           = 'FakeStringValue'
                                    IpAddressOrFQDN = 'FakeStringValue'
                                })
                            )
                            EnterpriseProxyServersAreAuthoritative = $True
                            EnterpriseNetworkDomainNames           = @('FakeStringValue')
                            EnterpriseIPRanges                     = @(
                            ([MSFT_MicrosoftGraphIpRange] @{
                                    UpperAddress = 'FakeStringValue'
                                    LowerAddress = 'FakeStringValue'
                                    odataType    = '#microsoft.graph.iPv4Range'
                                })
                            )
                            NeutralDomainResources                 = @('FakeStringValue')
                        })
                    Ensure                                      = 'Present'
                    Credential                                  = $Credential
                }
            }

            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'IntuneDeviceConfigurationNetworkBoundaryPolicyWindows10' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneDeviceConfigurationNetworkBoundaryPolicyWindows10' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should call the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneDeviceConfigurationNetworkBoundaryPolicyWindows10' -Property $testParams).Set()
                Should -Invoke -CommandName Update-MgBetaDeviceManagementDeviceConfiguration -Exactly 1
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
                $result = Invoke-M365DSCResourceMethod -ResourceName 'IntuneDeviceConfigurationNetworkBoundaryPolicyWindows10' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
