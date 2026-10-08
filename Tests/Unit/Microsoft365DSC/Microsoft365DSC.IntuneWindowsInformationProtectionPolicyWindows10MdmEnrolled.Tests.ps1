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
    -DscResource 'IntuneWindowsInformationProtectionPolicyWindows10MdmEnrolled' -GenericStubModule $GenericStubPath
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

            Mock -CommandName Update-MgBetaDeviceAppManagementMdmWindowsInformationProtectionPolicy -MockWith {
            }

            Mock -CommandName New-MgBetaDeviceAppManagementMdmWindowsInformationProtectionPolicy -MockWith {
            }

            Mock -CommandName Remove-MgBetaDeviceAppManagementMdmWindowsInformationProtectionPolicy -MockWith {
            }
            Mock -CommandName Update-DeviceConfigurationPolicyAssignment -MockWith {
            }
            Mock -CommandName New-M365DSCConnection -ModuleName '_Shared' -MockWith {
                return 'Credentials'
            }

            Mock -CommandName Get-MgBetaDeviceAppManagementMdmWindowsInformationProtectionPolicy -MockWith {
                return @{
                    '@odata.type' = '#microsoft.graph.MdmWindowsInformationProtectionPolicy'
                    AzureRightsManagementServicesAllowed   = $True
                    DataRecoveryCertificate                = @{
                        Description        = 'FakeStringValue'
                        ExpirationDateTime = '2023-01-01T00:00:00.0000000+00:00'
                        SubjectName        = 'FakeStringValue'
                    }
                    Description                            = 'FakeStringValue'
                    DisplayName                            = 'FakeStringValue'
                    EnforcementLevel                       = 'noProtection'
                    EnterpriseDomain                       = 'FakeStringValue'
                    EnterpriseInternalProxyServers         = @(
                        @{
                            DisplayName = 'FakeStringValue'
                            Resources   = @('FakeStringValue')
                        }
                    )
                    EnterpriseIPRanges                     = @(
                        @{
                            DisplayName = 'FakeStringValue'
                            Ranges      = @(
                                @{
                                    upperAddress  = 'FakeStringValue'
                                    lowerAddress  = 'FakeStringValue'
                                    '@odata.type' = '#microsoft.graph.iPv4Range'
                                }
                            )
                        }
                    )
                    EnterpriseIPRangesAreAuthoritative     = $True
                    EnterpriseNetworkDomainNames           = @(
                        @{
                            DisplayName = 'FakeStringValue'
                            Resources   = @('FakeStringValue')
                        }
                    )
                    EnterpriseProtectedDomainNames         = @(
                        @{
                            DisplayName = 'FakeStringValue'
                            Resources   = @('FakeStringValue')
                        }
                    )
                    EnterpriseProxiedDomains               = @(
                        @{
                            DisplayName    = 'FakeStringValue'
                            ProxiedDomains = @(
                                @{
                                    Proxy           = 'FakeStringValue'
                                    IpAddressOrFQDN = 'FakeStringValue'
                                }
                            )
                        }
                    )
                    EnterpriseProxyServers                 = @(
                        @{
                            DisplayName = 'FakeStringValue'
                            Resources   = @('FakeStringValue')
                        }
                    )
                    EnterpriseProxyServersAreAuthoritative = $True
                    ExemptApps                             = @(
                        @{
                            Description          = 'FakeStringValue'
                            binaryName        = 'FakeStringValue'
                            binaryVersionLow  = 'FakeStringValue'
                            binaryVersionHigh = 'FakeStringValue'
                            '@odata.type'     = '#microsoft.graph.windowsInformationProtectionDesktopApp'
                            Denied               = $True
                            PublisherName        = 'FakeStringValue'
                            ProductName          = 'FakeStringValue'
                            DisplayName          = 'FakeStringValue'
                        }
                    )
                    IconsVisible                           = $True
                    Id                                     = 'FakeStringValue'
                    IndexingEncryptedStoresOrItemsBlocked  = $True
                    NeutralDomainResources                 = @(
                        @{
                            DisplayName = 'FakeStringValue'
                            Resources   = @('FakeStringValue')
                        }
                    )
                    ProtectedApps                          = @(
                        @{
                            Description          = 'FakeStringValue'
                            binaryName        = 'FakeStringValue'
                            binaryVersionLow  = 'FakeStringValue'
                            binaryVersionHigh = 'FakeStringValue'
                            '@odata.type'     = '#microsoft.graph.windowsInformationProtectionDesktopApp'
                            Denied               = $True
                            PublisherName        = 'FakeStringValue'
                            ProductName          = 'FakeStringValue'
                            DisplayName          = 'FakeStringValue'
                        }
                    )
                    ProtectionUnderLockConfigRequired      = $True
                    RevokeOnUnenrollDisabled               = $True
                    SmbAutoEncryptedFileExtensions         = @(
                        @{
                            DisplayName = 'FakeStringValue'
                            Resources   = @('FakeStringValue')
                        }
                    )

                }
            }

            # Mock Write-M365DSCHost to hide output during the tests
            Mock -CommandName Write-M365DSCHost -MockWith {
            }
            $Script:exportedInstances =$null
            $Script:ExportMode = $false
        }
        # Test contexts
        Context -Name 'The IntuneWindowsInformationProtectionPolicyWindows10MdmEnrolled should exist but it DOES NOT' -Fixture {
            BeforeAll {
                $testParams = @{
                    AzureRightsManagementServicesAllowed   = $True
                    DataRecoveryCertificate                = ([MSFT_MicrosoftGraphwindowsInformationProtectionDataRecoveryCertificate] @{
                            Description        = 'FakeStringValue'
                            ExpirationDateTime = '2023-01-01T00:00:00.0000000+00:00'
                            SubjectName        = 'FakeStringValue'
                        })
                    Description                            = 'FakeStringValue'
                    DisplayName                            = 'FakeStringValue'
                    EnforcementLevel                       = 'noProtection'
                    EnterpriseDomain                       = 'FakeStringValue'
                    EnterpriseInternalProxyServers         = @(
                        ([MSFT_MicrosoftGraphwindowsInformationProtectionResourceCollection] @{
                            DisplayName = 'FakeStringValue'
                            Resources   = @('FakeStringValue')
                        })
                    )
                    EnterpriseIPRanges                     = @(
                        ([MSFT_MicrosoftGraphwindowsInformationProtectionIPRangeCollection] @{
                            DisplayName = 'FakeStringValue'
                            Ranges      = @([MSFT_MicrosoftGraphIpRange] @{
                                    UpperAddress = 'FakeStringValue'
                                    LowerAddress = 'FakeStringValue'
                                    odataType    = '#microsoft.graph.iPv4Range'
                                })
                        })
                    )
                    EnterpriseIPRangesAreAuthoritative     = $True
                    EnterpriseNetworkDomainNames           = @(
                        ([MSFT_MicrosoftGraphwindowsInformationProtectionResourceCollection] @{
                            DisplayName = 'FakeStringValue'
                            Resources   = @('FakeStringValue')
                        })
                    )
                    EnterpriseProtectedDomainNames         = @(
                        ([MSFT_MicrosoftGraphwindowsInformationProtectionResourceCollection] @{
                            DisplayName = 'FakeStringValue'
                            Resources   = @('FakeStringValue')
                        })
                    )
                    EnterpriseProxiedDomains               = @(
                        ([MSFT_MicrosoftGraphwindowsInformationProtectionProxiedDomainCollection] @{
                            DisplayName    = 'FakeStringValue'
                            ProxiedDomains = @([MSFT_MicrosoftGraphProxiedDomain] @{
                                    Proxy           = 'FakeStringValue'
                                    IpAddressOrFQDN = 'FakeStringValue'
                                })
                        })
                    )
                    EnterpriseProxyServers                 = @(
                        ([MSFT_MicrosoftGraphwindowsInformationProtectionResourceCollection] @{
                            DisplayName = 'FakeStringValue'
                            Resources   = @('FakeStringValue')
                        })
                    )
                    EnterpriseProxyServersAreAuthoritative = $True
                    ExemptApps                             = @(
                        ([MSFT_MicrosoftGraphwindowsInformationProtectionApp] @{
                            BinaryVersionLow  = 'FakeStringValue'
                            Description       = 'FakeStringValue'
                            odataType         = '#microsoft.graph.windowsInformationProtectionDesktopApp'
                            BinaryName        = 'FakeStringValue'
                            BinaryVersionHigh = 'FakeStringValue'
                            Denied            = $True
                            PublisherName     = 'FakeStringValue'
                            ProductName       = 'FakeStringValue'
                            DisplayName       = 'FakeStringValue'
                        })
                    )
                    IconsVisible                           = $True
                    Id                                     = 'FakeStringValue'
                    IndexingEncryptedStoresOrItemsBlocked  = $True
                    NeutralDomainResources                 = @(
                        ([MSFT_MicrosoftGraphwindowsInformationProtectionResourceCollection] @{
                            DisplayName = 'FakeStringValue'
                            Resources   = @('FakeStringValue')
                        })
                    )
                    ProtectedApps                          = @(
                        ([MSFT_MicrosoftGraphwindowsInformationProtectionApp] @{
                            BinaryVersionLow  = 'FakeStringValue'
                            Description       = 'FakeStringValue'
                            odataType         = '#microsoft.graph.windowsInformationProtectionDesktopApp'
                            BinaryName        = 'FakeStringValue'
                            BinaryVersionHigh = 'FakeStringValue'
                            Denied            = $True
                            PublisherName     = 'FakeStringValue'
                            ProductName       = 'FakeStringValue'
                            DisplayName       = 'FakeStringValue'
                        })
                    )
                    ProtectionUnderLockConfigRequired      = $True
                    RevokeOnUnenrollDisabled               = $True
                    SmbAutoEncryptedFileExtensions         = @(
                        ([MSFT_MicrosoftGraphwindowsInformationProtectionResourceCollection] @{
                            DisplayName = 'FakeStringValue'
                            Resources   = @('FakeStringValue')
                        })
                    )
                    Ensure                                 = 'Present'
                    Credential                             = $Credential
                }

                Mock -CommandName Get-MgBetaDeviceAppManagementMdmWindowsInformationProtectionPolicy -MockWith {
                    return $null
                }
            }
            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'IntuneWindowsInformationProtectionPolicyWindows10MdmEnrolled' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Absent'
            }
            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneWindowsInformationProtectionPolicyWindows10MdmEnrolled' -Property $testParams).Test() | Should -Be $false
            }
            It 'Should Create the group from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneWindowsInformationProtectionPolicyWindows10MdmEnrolled' -Property $testParams).Set()
                Should -Invoke -CommandName New-MgBetaDeviceAppManagementMdmWindowsInformationProtectionPolicy -Exactly 1
            }
        }

        Context -Name 'The IntuneWindowsInformationProtectionPolicyWindows10MdmEnrolled exists but it SHOULD NOT' -Fixture {
            BeforeAll {
                $testParams = @{
                    AzureRightsManagementServicesAllowed   = $True
                    DataRecoveryCertificate                = ([MSFT_MicrosoftGraphwindowsInformationProtectionDataRecoveryCertificate] @{
                            Description        = 'FakeStringValue'
                            ExpirationDateTime = '2023-01-01T00:00:00.0000000+00:00'
                            SubjectName        = 'FakeStringValue'
                        })
                    Description                            = 'FakeStringValue'
                    DisplayName                            = 'FakeStringValue'
                    EnforcementLevel                       = 'noProtection'
                    EnterpriseDomain                       = 'FakeStringValue'
                    EnterpriseInternalProxyServers         = @(
                        ([MSFT_MicrosoftGraphwindowsInformationProtectionResourceCollection] @{
                            DisplayName = 'FakeStringValue'
                            Resources   = @('FakeStringValue')
                        })
                    )
                    EnterpriseIPRanges                     = @(
                        ([MSFT_MicrosoftGraphwindowsInformationProtectionIPRangeCollection] @{
                            DisplayName = 'FakeStringValue'
                            Ranges      = @([MSFT_MicrosoftGraphIpRange] @{
                                    UpperAddress = 'FakeStringValue'
                                    LowerAddress = 'FakeStringValue'
                                    odataType    = '#microsoft.graph.iPv4Range'
                                })
                        })
                    )
                    EnterpriseIPRangesAreAuthoritative     = $True
                    EnterpriseNetworkDomainNames           = @(
                        ([MSFT_MicrosoftGraphwindowsInformationProtectionResourceCollection] @{
                            DisplayName = 'FakeStringValue'
                            Resources   = @('FakeStringValue')
                        })
                    )
                    EnterpriseProtectedDomainNames         = @(
                        ([MSFT_MicrosoftGraphwindowsInformationProtectionResourceCollection] @{
                            DisplayName = 'FakeStringValue'
                            Resources   = @('FakeStringValue')
                        })
                    )
                    EnterpriseProxiedDomains               = @(
                        ([MSFT_MicrosoftGraphwindowsInformationProtectionProxiedDomainCollection] @{
                            DisplayName    = 'FakeStringValue'
                            ProxiedDomains = @([MSFT_MicrosoftGraphProxiedDomain] @{
                                    Proxy           = 'FakeStringValue'
                                    IpAddressOrFQDN = 'FakeStringValue'
                                })
                        })
                    )
                    EnterpriseProxyServers                 = @(
                        ([MSFT_MicrosoftGraphwindowsInformationProtectionResourceCollection] @{
                            DisplayName = 'FakeStringValue'
                            Resources   = @('FakeStringValue')
                        })
                    )
                    EnterpriseProxyServersAreAuthoritative = $True
                    ExemptApps                             = @(
                        ([MSFT_MicrosoftGraphwindowsInformationProtectionApp] @{
                            BinaryVersionLow  = 'FakeStringValue'
                            Description       = 'FakeStringValue'
                            odataType         = '#microsoft.graph.windowsInformationProtectionDesktopApp'
                            BinaryName        = 'FakeStringValue'
                            BinaryVersionHigh = 'FakeStringValue'
                            Denied            = $True
                            PublisherName     = 'FakeStringValue'
                            ProductName       = 'FakeStringValue'
                            DisplayName       = 'FakeStringValue'
                        })
                    )
                    IconsVisible                           = $True
                    Id                                     = 'FakeStringValue'
                    IndexingEncryptedStoresOrItemsBlocked  = $True
                    NeutralDomainResources                 = @(
                        ([MSFT_MicrosoftGraphwindowsInformationProtectionResourceCollection] @{
                            DisplayName = 'FakeStringValue'
                            Resources   = @('FakeStringValue')
                        })
                    )
                    ProtectedApps                          = @(
                        ([MSFT_MicrosoftGraphwindowsInformationProtectionApp] @{
                            BinaryVersionLow  = 'FakeStringValue'
                            Description       = 'FakeStringValue'
                            odataType         = '#microsoft.graph.windowsInformationProtectionDesktopApp'
                            BinaryName        = 'FakeStringValue'
                            BinaryVersionHigh = 'FakeStringValue'
                            Denied            = $True
                            PublisherName     = 'FakeStringValue'
                            ProductName       = 'FakeStringValue'
                            DisplayName       = 'FakeStringValue'
                        })
                    )
                    ProtectionUnderLockConfigRequired      = $True
                    RevokeOnUnenrollDisabled               = $True
                    SmbAutoEncryptedFileExtensions         = @(
                        ([MSFT_MicrosoftGraphwindowsInformationProtectionResourceCollection] @{
                            DisplayName = 'FakeStringValue'
                            Resources   = @('FakeStringValue')
                        })
                    )
                    Ensure                                 = 'Absent'
                    Credential                             = $Credential
                }
            }

            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'IntuneWindowsInformationProtectionPolicyWindows10MdmEnrolled' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneWindowsInformationProtectionPolicyWindows10MdmEnrolled' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should Remove the group from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneWindowsInformationProtectionPolicyWindows10MdmEnrolled' -Property $testParams).Set()
                Should -Invoke -CommandName Remove-MgBetaDeviceAppManagementMdmWindowsInformationProtectionPolicy -Exactly 1
            }
        }
        Context -Name 'The IntuneWindowsInformationProtectionPolicyWindows10MdmEnrolled Exists and Values are already in the desired state' -Fixture {
            BeforeAll {
                $testParams = @{
                    AzureRightsManagementServicesAllowed   = $True
                    DataRecoveryCertificate                = ([MSFT_MicrosoftGraphwindowsInformationProtectionDataRecoveryCertificate] @{
                            Description        = 'FakeStringValue'
                            ExpirationDateTime = '2023-01-01T00:00:00.0000000+00:00'
                            SubjectName        = 'FakeStringValue'
                        })
                    Description                            = 'FakeStringValue'
                    DisplayName                            = 'FakeStringValue'
                    EnforcementLevel                       = 'noProtection'
                    EnterpriseDomain                       = 'FakeStringValue'
                    EnterpriseInternalProxyServers         = @(
                        ([MSFT_MicrosoftGraphwindowsInformationProtectionResourceCollection] @{
                            DisplayName = 'FakeStringValue'
                            Resources   = @('FakeStringValue')
                        })
                    )
                    EnterpriseIPRanges                     = @(
                        ([MSFT_MicrosoftGraphwindowsInformationProtectionIPRangeCollection] @{
                            DisplayName = 'FakeStringValue'
                            Ranges      = @([MSFT_MicrosoftGraphIpRange] @{
                                    UpperAddress = 'FakeStringValue'
                                    LowerAddress = 'FakeStringValue'
                                    odataType    = '#microsoft.graph.iPv4Range'
                                })
                        })
                    )
                    EnterpriseIPRangesAreAuthoritative     = $True
                    EnterpriseNetworkDomainNames           = @(
                        ([MSFT_MicrosoftGraphwindowsInformationProtectionResourceCollection] @{
                            DisplayName = 'FakeStringValue'
                            Resources   = @('FakeStringValue')
                        })
                    )
                    EnterpriseProtectedDomainNames         = @(
                        ([MSFT_MicrosoftGraphwindowsInformationProtectionResourceCollection] @{
                            DisplayName = 'FakeStringValue'
                            Resources   = @('FakeStringValue')
                        })
                    )
                    EnterpriseProxiedDomains               = @(
                        ([MSFT_MicrosoftGraphwindowsInformationProtectionProxiedDomainCollection] @{
                            DisplayName    = 'FakeStringValue'
                            ProxiedDomains = @([MSFT_MicrosoftGraphProxiedDomain] @{
                                    Proxy           = 'FakeStringValue'
                                    IpAddressOrFQDN = 'FakeStringValue'
                                })
                        })
                    )
                    EnterpriseProxyServers                 = @(
                        ([MSFT_MicrosoftGraphwindowsInformationProtectionResourceCollection] @{
                            DisplayName = 'FakeStringValue'
                            Resources   = @('FakeStringValue')
                        })
                    )
                    EnterpriseProxyServersAreAuthoritative = $True
                    ExemptApps                             = @(
                        ([MSFT_MicrosoftGraphwindowsInformationProtectionApp] @{
                            BinaryVersionLow  = 'FakeStringValue'
                            Description       = 'FakeStringValue'
                            odataType         = '#microsoft.graph.windowsInformationProtectionDesktopApp'
                            BinaryName        = 'FakeStringValue'
                            BinaryVersionHigh = 'FakeStringValue'
                            Denied            = $True
                            PublisherName     = 'FakeStringValue'
                            ProductName       = 'FakeStringValue'
                            DisplayName       = 'FakeStringValue'
                        })
                    )
                    IconsVisible                           = $True
                    Id                                     = 'FakeStringValue'
                    IndexingEncryptedStoresOrItemsBlocked  = $True
                    NeutralDomainResources                 = @(
                        ([MSFT_MicrosoftGraphwindowsInformationProtectionResourceCollection] @{
                            DisplayName = 'FakeStringValue'
                            Resources   = @('FakeStringValue')
                        })
                    )
                    ProtectedApps                          = @(
                        ([MSFT_MicrosoftGraphwindowsInformationProtectionApp] @{
                            BinaryVersionLow  = 'FakeStringValue'
                            Description       = 'FakeStringValue'
                            odataType         = '#microsoft.graph.windowsInformationProtectionDesktopApp'
                            BinaryName        = 'FakeStringValue'
                            BinaryVersionHigh = 'FakeStringValue'
                            Denied            = $True
                            PublisherName     = 'FakeStringValue'
                            ProductName       = 'FakeStringValue'
                            DisplayName       = 'FakeStringValue'
                        })
                    )
                    ProtectionUnderLockConfigRequired      = $True
                    RevokeOnUnenrollDisabled               = $True
                    SmbAutoEncryptedFileExtensions         = @(
                        ([MSFT_MicrosoftGraphwindowsInformationProtectionResourceCollection] @{
                            DisplayName = 'FakeStringValue'
                            Resources   = @('FakeStringValue')
                        })
                    )
                    Ensure                                 = 'Present'
                    Credential                             = $Credential
                }
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneWindowsInformationProtectionPolicyWindows10MdmEnrolled' -Property $testParams).Test() | Should -Be $true
            }
        }

        Context -Name 'The IntuneWindowsInformationProtectionPolicyWindows10MdmEnrolled exists and values are NOT in the desired state' -Fixture {
            BeforeAll {
                $testParams = @{
                    AzureRightsManagementServicesAllowed   = $True
                    DataRecoveryCertificate                = ([MSFT_MicrosoftGraphwindowsInformationProtectionDataRecoveryCertificate] @{
                            Description        = 'FakeStringValue'
                            ExpirationDateTime = '2023-01-01T00:00:00.0000000+00:00'
                            SubjectName        = 'FakeStringValue'
                        })
                    Description                            = 'FakeStringValue'
                    DisplayName                            = 'FakeStringValue'
                    EnforcementLevel                       = 'noProtection'
                    EnterpriseDomain                       = 'FakeStringValue'
                    EnterpriseInternalProxyServers         = @(
                        ([MSFT_MicrosoftGraphwindowsInformationProtectionResourceCollection] @{
                            DisplayName = 'FakeStringValue'
                            Resources   = @('FakeStringValue')
                        })
                    )
                    EnterpriseIPRanges                     = @(
                        ([MSFT_MicrosoftGraphwindowsInformationProtectionIPRangeCollection] @{
                            DisplayName = 'FakeStringValue'
                            Ranges      = @([MSFT_MicrosoftGraphIpRange] @{
                                    UpperAddress = 'FakeStringValue'
                                    LowerAddress = 'FakeStringValue'
                                    odataType    = '#microsoft.graph.iPv4Range'
                                })
                        })
                    )
                    EnterpriseIPRangesAreAuthoritative     = $True
                    EnterpriseNetworkDomainNames           = @(
                        ([MSFT_MicrosoftGraphwindowsInformationProtectionResourceCollection] @{
                            DisplayName = 'FakeStringValue'
                            Resources   = @('FakeStringValue')
                        })
                    )
                    EnterpriseProtectedDomainNames         = @(
                        ([MSFT_MicrosoftGraphwindowsInformationProtectionResourceCollection] @{
                            DisplayName = 'FakeStringValue'
                            Resources   = @('FakeStringValue')
                        })
                    )
                    EnterpriseProxiedDomains               = @(
                        ([MSFT_MicrosoftGraphwindowsInformationProtectionProxiedDomainCollection] @{
                            DisplayName    = 'FakeStringValue'
                            ProxiedDomains = @([MSFT_MicrosoftGraphProxiedDomain] @{
                                Proxy           = 'DefinedProxy' # Updated property
                                IpAddressOrFQDN = 'FakeStringValue'
                            })
                        })
                    )
                    EnterpriseProxyServers                 = @(
                        ([MSFT_MicrosoftGraphwindowsInformationProtectionResourceCollection] @{
                            DisplayName = 'FakeStringValue'
                            Resources   = @('FakeStringValue')
                        })
                    )
                    EnterpriseProxyServersAreAuthoritative = $True
                    ExemptApps                             = @(
                        ([MSFT_MicrosoftGraphwindowsInformationProtectionApp] @{
                            BinaryVersionLow  = 'FakeStringValue'
                            Description       = 'FakeStringValue'
                            odataType         = '#microsoft.graph.windowsInformationProtectionDesktopApp'
                            BinaryName        = 'FakeStringValue'
                            BinaryVersionHigh = 'FakeStringValue'
                            Denied            = $True
                            PublisherName     = 'FakeStringValue'
                            ProductName       = 'FakeStringValue'
                            DisplayName       = 'FakeStringValue'
                        })
                    )
                    IconsVisible                           = $True
                    Id                                     = 'FakeStringValue'
                    IndexingEncryptedStoresOrItemsBlocked  = $True
                    NeutralDomainResources                 = @(
                        ([MSFT_MicrosoftGraphwindowsInformationProtectionResourceCollection] @{
                            DisplayName = 'FakeStringValue'
                            Resources   = @('FakeStringValue')
                        })
                    )
                    ProtectedApps                          = @(
                        ([MSFT_MicrosoftGraphwindowsInformationProtectionApp] @{
                            BinaryVersionLow  = 'FakeStringValue'
                            Description       = 'FakeStringValue'
                            odataType         = '#microsoft.graph.windowsInformationProtectionDesktopApp'
                            BinaryName        = 'FakeStringValue'
                            BinaryVersionHigh = 'FakeStringValue'
                            Denied            = $True
                            PublisherName     = 'FakeStringValue'
                            ProductName       = 'FakeStringValue'
                            DisplayName       = 'FakeStringValue'
                        })
                    )
                    ProtectionUnderLockConfigRequired      = $True
                    RevokeOnUnenrollDisabled               = $True
                    SmbAutoEncryptedFileExtensions         = @(
                        ([MSFT_MicrosoftGraphwindowsInformationProtectionResourceCollection] @{
                            DisplayName = 'FakeStringValue'
                            Resources   = @('FakeStringValue')
                        })
                    )
                    Ensure                                 = 'Present'
                    Credential                             = $Credential
                }
            }

            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'IntuneWindowsInformationProtectionPolicyWindows10MdmEnrolled' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneWindowsInformationProtectionPolicyWindows10MdmEnrolled' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should call the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneWindowsInformationProtectionPolicyWindows10MdmEnrolled' -Property $testParams).Set()
                Should -Invoke -CommandName Update-MgBetaDeviceAppManagementMdmWindowsInformationProtectionPolicy -Exactly 1
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
                $result = Invoke-M365DSCResourceMethod -ResourceName 'IntuneWindowsInformationProtectionPolicyWindows10MdmEnrolled' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
