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
    -DscResource "IntuneDeviceConfigurationVpnPolicyWindows10" -GenericStubModule $GenericStubPath
Describe -Name $Global:DscHelper.DescribeHeader -Fixture {
    InModuleScope -ModuleName $Global:DscHelper.ModuleName -ScriptBlock {
        Invoke-Command -ScriptBlock $Global:DscHelper.InitializeScript -NoNewScope
        BeforeAll {

            $secpasswd = ConvertTo-SecureString (New-Guid | Out-String) -AsPlainText -Force
            $Credential = New-Object System.Management.Automation.PSCredential ('tenantadmin@onmicrosoft.com', $secpasswd)

            Mock -ModuleName M365DSCUtil -CommandName Confirm-M365DSCDependencies -MockWith {
            }

            Mock -CommandName Update-MgBetaDeviceManagementDeviceConfiguration -MockWith {
            }

            Mock -CommandName New-MgBetaDeviceManagementDeviceConfiguration -MockWith {
            }

            Mock -CommandName Remove-MgBetaDeviceManagementDeviceConfiguration -MockWith {
            }

            Mock -CommandName New-M365DSCConnection -ModuleName '_Shared' -MockWith {
                return "Credentials"
            }
            Mock -CommandName Get-M365DSCExportCachedCollection -MockWith {
                return Get-MgBetaDeviceManagementDeviceConfiguration
            }
            Mock -CommandName Get-MgBetaDeviceManagementDeviceConfiguration -MockWith {
                return @{
                    dnsRules = @(
                        @{
                            servers = @("FakeStringValue")
                            proxyServerUri = "FakeStringValue"
                            name = "FakeStringValue"
                            persistent = $True
                            autoTrigger = $True
                        }
                    )
                    authenticationMethod = "certificate"
                    proxyServer = @{
                        bypassProxyServerForLocalAddress = $True
                        '@odata.type' = "#microsoft.graph.windows10VpnProxyServer"
                        address = "FakeStringValue"
                        automaticConfigurationScriptUrl = "FakeStringValue"
                        automaticallyDetectProxySettings = $True
                        port = 25
                    }
                    rememberUserCredentials = $True
                    enableDnsRegistration = $True
                    associatedApps = @(
                        @{
                            identifier = "FakeStringValue"
                            appType = "desktop"
                        }
                    )
                    routes = @(
                        @{
                            prefixSize = 25
                            destinationPrefix = "FakeStringValue"
                        }
                    )
                    trustedNetworkDomains = @("FakeStringValue")
                    enableDeviceTunnel = $True
                    singleSignOnIssuerHash = "FakeStringValue"
                    singleSignOnEku = @{
                        objectIdentifier = "FakeStringValue"
                        name = "FakeStringValue"
                    }
                    microsoftTunnelSiteId = "FakeStringValue"
                    enableSingleSignOnWithAlternateCertificate = $True
                    onlyAssociatedAppsCanUseConnection = $True
                    dnsSuffixes = @("FakeStringValue")
                    profileTarget = "user"
                    enableAlwaysOn = $True
                    servers = @(
                        @{
                            isDefaultServer = $True
                            description = "FakeStringValue"
                            address = "FakeStringValue"
                        }
                    )
                    connectionType = "pulseSecure"
                    connectionName = "FakeStringValue"
                    cryptographySuite = @{
                        cipherTransformConstants = "aes256"
                        encryptionMethod = "aes256"
                        pfsGroup = "pfs1"
                        dhGroup = "group1"
                        integrityCheckMethod = "sha2_256"
                        authenticationTransformConstants = "md5_96"
                    }
                    trafficRules = @(
                        @{
                            remotePortRanges = @(
                                @{
                                    lowerNumber = 25
                                    upperNumber = 25
                                }
                            )
                            name = "FakeStringValue"
                            appId = "FakeStringValue"
                            localPortRanges = @(
                                @{
                                    lowerNumber = 25
                                    upperNumber = 25
                                }
                            )
                            appType = "none"
                            localAddressRanges = @(
                                @{
                                    cidrAddress = "FakeStringValue"
                                    upperAddress = "FakeStringValue"
                                    lowerAddress = "FakeStringValue"
                                    '@odata.type' = "#microsoft.graph.iPv4CidrRange"
                                }
                            )
                            remoteAddressRanges = @(
                                @{
                                    cidrAddress = "FakeStringValue"
                                    upperAddress = "FakeStringValue"
                                    lowerAddress = "FakeStringValue"
                                    '@odata.type' = "#microsoft.graph.iPv4CidrRange"
                                }
                            )
                            claims = "FakeStringValue"
                            protocols = 25
                            routingPolicyType = "none"
                            vpnTrafficDirection = "outbound"
                        }
                    )
                    windowsInformationProtectionDomain = "FakeStringValue"
                    enableConditionalAccess = $True
                    '@odata.type' = "#microsoft.graph.windows10VpnConfiguration"
                    enableSplitTunneling = $True
                    description = "FakeStringValue"
                    deviceManagementApplicabilityRuleDeviceMode = @{
                        name = "FakeStringValue"
                        deviceMode = "standardConfiguration"
                        ruleType = "include"
                    }
                    deviceManagementApplicabilityRuleOsEdition = @{
                        name = "FakeStringValue"
                        osEditionTypes = @("windows10Enterprise")
                        ruleType = "include"
                    }
                    deviceManagementApplicabilityRuleOsVersion = @{
                        name = "FakeStringValue"
                        minOSVersion = "FakeStringValue"
                        maxOSVersion = "FakeStringValue"
                        ruleType = "include"
                    }
                    displayName = "FakeStringValue"
                    id = "FakeStringValue"

                }
            }
            Mock -CommandName Update-DeviceConfigurationPolicyAssignment -MockWith {
            }
            # Mock Write-M365DSCHost to hide output during the tests
            Mock -CommandName Write-M365DSCHost -MockWith {
            }
            $Script:exportedInstances =$null
            $Script:ExportMode = $false

            Mock -CommandName Get-MgBetaDeviceManagementDeviceConfigurationAssignment -MockWith {
            }

        }
        # Test contexts
        Context -Name "The IntuneDeviceConfigurationVpnPolicyWindows10 should exist but it DOES NOT" -Fixture {
            BeforeAll {
                $testParams = @{
                    associatedApps = @(
                        ([MSFT_MicrosoftGraphwindows10AssociatedApps] @{
                            identifier = "FakeStringValue"
                            appType = "desktop"
                        })
                    )
                    authenticationMethod = "certificate"
                    connectionName = "FakeStringValue"
                    connectionType = "pulseSecure"
                    cryptographySuite = ([MSFT_MicrosoftGraphcryptographySuite] @{
                        cipherTransformConstants = "aes256"
                        encryptionMethod = "aes256"
                        pfsGroup = "pfs1"
                        dhGroup = "group1"
                        integrityCheckMethod = "sha2_256"
                        authenticationTransformConstants = "md5_96"
                    })
                    description = "FakeStringValue"
                    deviceManagementApplicabilityRuleDeviceMode = ([MSFT_DeviceManagementApplicabilityRuleDeviceMode] @{
                        name = "FakeStringValue"
                        deviceMode = "standardConfiguration"
                        ruleType = "include"
                    })
                    deviceManagementApplicabilityRuleOsEdition = ([MSFT_DeviceManagementApplicabilityRuleOsEdition] @{
                        name = "FakeStringValue"
                        osEditionTypes = @("windows10Enterprise")
                        ruleType = "include"
                    })
                    deviceManagementApplicabilityRuleOsVersion = ([MSFT_DeviceManagementApplicabilityRuleOsVersion] @{
                        name = "FakeStringValue"
                        minOSVersion = "FakeStringValue"
                        maxOSVersion = "FakeStringValue"
                        ruleType = "include"
                    })
                    displayName = "FakeStringValue"
                    dnsRules = @(
                        ([MSFT_MicrosoftGraphvpnDnsRule] @{
                            servers = @("FakeStringValue")
                            proxyServerUri = "FakeStringValue"
                            name = "FakeStringValue"
                            persistent = $True
                            autoTrigger = $True
                        })
                    )
                    dnsSuffixes = @("FakeStringValue")
                    enableAlwaysOn = $True
                    enableConditionalAccess = $True
                    enableDeviceTunnel = $True
                    enableDnsRegistration = $True
                    enableSingleSignOnWithAlternateCertificate = $True
                    enableSplitTunneling = $True
                    id = "FakeStringValue"
                    microsoftTunnelSiteId = "FakeStringValue"
                    onlyAssociatedAppsCanUseConnection = $True
                    profileTarget = "user"
                    proxyServer = ([MSFT_MicrosoftGraphwindows10VpnProxyServer] @{
                        bypassProxyServerForLocalAddress = $True
                        address = "FakeStringValue"
                        automaticConfigurationScriptUrl = "FakeStringValue"
                        automaticallyDetectProxySettings = $True
                        port = 25
                        odataType = "#microsoft.graph.windows10VpnProxyServer"
                    })
                    rememberUserCredentials = $True
                    routes = @(
                        ([MSFT_MicrosoftGraphvpnRoute] @{
                            prefixSize = 25
                            destinationPrefix = "FakeStringValue"
                        })
                    )
                    servers = @(
                        ([MSFT_MicrosoftGraphvpnServer] @{
                            isDefaultServer = $True
                            description = "FakeStringValue"
                            address = "FakeStringValue"
                        })
                    )
                    singleSignOnEku = ([MSFT_MicrosoftGraphextendedKeyUsage] @{
                        objectIdentifier = "FakeStringValue"
                        name = "FakeStringValue"
                    })
                    singleSignOnIssuerHash = "FakeStringValue"
                    trafficRules = @(
                        ([MSFT_MicrosoftGraphvpnTrafficRule] @{
                            remotePortRanges = @(
                                ([MSFT_MicrosoftGraphNumberRange] @{
                                    lowerNumber = 25
                                    upperNumber = 25
                                })
                            )
                            name = "FakeStringValue"
                            appId = "FakeStringValue"
                            localPortRanges = @(
                                ([MSFT_MicrosoftGraphNumberRange] @{
                                    lowerNumber = 25
                                    upperNumber = 25
                                })
                            )
                            appType = "none"
                            localAddressRanges = @(
                                ([MSFT_MicrosoftGraphIPv4Range] @{
                                    cidrAddress = "FakeStringValue"
                                    upperAddress = "FakeStringValue"
                                    lowerAddress = "FakeStringValue"
                                    odataType = "#microsoft.graph.iPv4CidrRange"
                                })
                            )
                            remoteAddressRanges = @(
                                ([MSFT_MicrosoftGraphIPv4Range] @{
                                    cidrAddress = "FakeStringValue"
                                    upperAddress = "FakeStringValue"
                                    lowerAddress = "FakeStringValue"
                                    odataType = "#microsoft.graph.iPv4CidrRange"
                                })
                            )
                            claims = "FakeStringValue"
                            protocols = 25
                            routingPolicyType = "none"
                            vpnTrafficDirection = "outbound"
                        })
                    )
                    trustedNetworkDomains = @("FakeStringValue")
                    windowsInformationProtectionDomain = "FakeStringValue"
                    Ensure = "Present"
                    Credential = $Credential;
                }

                Mock -CommandName Get-MgBetaDeviceManagementDeviceConfiguration -MockWith {
                    return $null
                }
            }
            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'IntuneDeviceConfigurationVpnPolicyWindows10' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Absent'
            }
            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneDeviceConfigurationVpnPolicyWindows10' -Property $testParams).Test() | Should -Be $false
            }
            It 'Should Create the group from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneDeviceConfigurationVpnPolicyWindows10' -Property $testParams).Set()
                Should -Invoke -CommandName New-MgBetaDeviceManagementDeviceConfiguration -Exactly 1
            }
        }

        Context -Name "The IntuneDeviceConfigurationVpnPolicyWindows10 exists but it SHOULD NOT" -Fixture {
            BeforeAll {
                $testParams = @{
                    associatedApps = @(
                        ([MSFT_MicrosoftGraphwindows10AssociatedApps] @{
                            identifier = "FakeStringValue"
                            appType = "desktop"
                        })
                    )
                    authenticationMethod = "certificate"
                    connectionName = "FakeStringValue"
                    connectionType = "pulseSecure"
                    cryptographySuite = ([MSFT_MicrosoftGraphcryptographySuite] @{
                        cipherTransformConstants = "aes256"
                        encryptionMethod = "aes256"
                        pfsGroup = "pfs1"
                        dhGroup = "group1"
                        integrityCheckMethod = "sha2_256"
                        authenticationTransformConstants = "md5_96"
                    })
                    description = "FakeStringValue"
                    deviceManagementApplicabilityRuleDeviceMode = ([MSFT_DeviceManagementApplicabilityRuleDeviceMode] @{
                        name = "FakeStringValue"
                        deviceMode = "standardConfiguration"
                        ruleType = "include"
                    })
                    deviceManagementApplicabilityRuleOsEdition = ([MSFT_DeviceManagementApplicabilityRuleOsEdition] @{
                        name = "FakeStringValue"
                        osEditionTypes = @("windows10Enterprise")
                        ruleType = "include"
                    })
                    deviceManagementApplicabilityRuleOsVersion = ([MSFT_DeviceManagementApplicabilityRuleOsVersion] @{
                        name = "FakeStringValue"
                        minOSVersion = "FakeStringValue"
                        maxOSVersion = "FakeStringValue"
                        ruleType = "include"
                    })
                    displayName = "FakeStringValue"
                    dnsRules = @(
                        ([MSFT_MicrosoftGraphvpnDnsRule] @{
                            servers = @("FakeStringValue")
                            proxyServerUri = "FakeStringValue"
                            name = "FakeStringValue"
                            persistent = $True
                            autoTrigger = $True
                        })
                    )
                    dnsSuffixes = @("FakeStringValue")
                    enableAlwaysOn = $True
                    enableConditionalAccess = $True
                    enableDeviceTunnel = $True
                    enableDnsRegistration = $True
                    enableSingleSignOnWithAlternateCertificate = $True
                    enableSplitTunneling = $True
                    id = "FakeStringValue"
                    microsoftTunnelSiteId = "FakeStringValue"
                    onlyAssociatedAppsCanUseConnection = $True
                    profileTarget = "user"
                    proxyServer = ([MSFT_MicrosoftGraphwindows10VpnProxyServer] @{
                        bypassProxyServerForLocalAddress = $True
                        address = "FakeStringValue"
                        automaticConfigurationScriptUrl = "FakeStringValue"
                        automaticallyDetectProxySettings = $True
                        port = 25
                        odataType = "#microsoft.graph.windows10VpnProxyServer"
                    })
                    rememberUserCredentials = $True
                    routes = @(
                        ([MSFT_MicrosoftGraphvpnRoute] @{
                            prefixSize = 25
                            destinationPrefix = "FakeStringValue"
                        })
                    )
                    servers = @(
                        ([MSFT_MicrosoftGraphvpnServer] @{
                            isDefaultServer = $True
                            description = "FakeStringValue"
                            address = "FakeStringValue"
                        })
                    )
                    singleSignOnEku = ([MSFT_MicrosoftGraphextendedKeyUsage] @{
                        objectIdentifier = "FakeStringValue"
                        name = "FakeStringValue"
                    })
                    singleSignOnIssuerHash = "FakeStringValue"
                    trafficRules = @(
                        ([MSFT_MicrosoftGraphvpnTrafficRule] @{
                            remotePortRanges = @(
                                ([MSFT_MicrosoftGraphNumberRange] @{
                                    lowerNumber = 25
                                    upperNumber = 25
                                })
                            )
                            name = "FakeStringValue"
                            appId = "FakeStringValue"
                            localPortRanges = @(
                                ([MSFT_MicrosoftGraphNumberRange] @{
                                    lowerNumber = 25
                                    upperNumber = 25
                                })
                            )
                            appType = "none"
                            localAddressRanges = @(
                                ([MSFT_MicrosoftGraphIPv4Range] @{
                                    cidrAddress = "FakeStringValue"
                                    upperAddress = "FakeStringValue"
                                    lowerAddress = "FakeStringValue"
                                    odataType = "#microsoft.graph.iPv4CidrRange"
                                })
                            )
                            remoteAddressRanges = @(
                                ([MSFT_MicrosoftGraphIPv4Range] @{
                                    cidrAddress = "FakeStringValue"
                                    upperAddress = "FakeStringValue"
                                    lowerAddress = "FakeStringValue"
                                    odataType = "#microsoft.graph.iPv4CidrRange"
                                })
                            )
                            claims = "FakeStringValue"
                            protocols = 25
                            routingPolicyType = "none"
                            vpnTrafficDirection = "outbound"
                        })
                    )
                    trustedNetworkDomains = @("FakeStringValue")
                    windowsInformationProtectionDomain = "FakeStringValue"
                    Ensure = 'Absent'
                    Credential = $Credential;
                }
            }

            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'IntuneDeviceConfigurationVpnPolicyWindows10' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneDeviceConfigurationVpnPolicyWindows10' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should Remove the group from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneDeviceConfigurationVpnPolicyWindows10' -Property $testParams).Set()
                Should -Invoke -CommandName Remove-MgBetaDeviceManagementDeviceConfiguration -Exactly 1
            }
        }
        Context -Name "The IntuneDeviceConfigurationVpnPolicyWindows10 Exists and Values are already in the desired state" -Fixture {
            BeforeAll {
                $testParams = @{
                    associatedApps = @(
                        ([MSFT_MicrosoftGraphwindows10AssociatedApps] @{
                            identifier = "FakeStringValue"
                            appType = "desktop"
                        })
                    )
                    authenticationMethod = "certificate"
                    connectionName = "FakeStringValue"
                    connectionType = "pulseSecure"
                    cryptographySuite = ([MSFT_MicrosoftGraphcryptographySuite] @{
                        cipherTransformConstants = "aes256"
                        encryptionMethod = "aes256"
                        pfsGroup = "pfs1"
                        dhGroup = "group1"
                        integrityCheckMethod = "sha2_256"
                        authenticationTransformConstants = "md5_96"
                    })
                    description = "FakeStringValue"
                    deviceManagementApplicabilityRuleDeviceMode = ([MSFT_DeviceManagementApplicabilityRuleDeviceMode] @{
                        name = "FakeStringValue"
                        deviceMode = "standardConfiguration"
                        ruleType = "include"
                    })
                    deviceManagementApplicabilityRuleOsEdition = ([MSFT_DeviceManagementApplicabilityRuleOsEdition] @{
                        name = "FakeStringValue"
                        osEditionTypes = @("windows10Enterprise")
                        ruleType = "include"
                    })
                    deviceManagementApplicabilityRuleOsVersion = ([MSFT_DeviceManagementApplicabilityRuleOsVersion] @{
                        name = "FakeStringValue"
                        minOSVersion = "FakeStringValue"
                        maxOSVersion = "FakeStringValue"
                        ruleType = "include"
                    })
                    displayName = "FakeStringValue"
                    dnsRules = @(
                        ([MSFT_MicrosoftGraphvpnDnsRule] @{
                            servers = @("FakeStringValue")
                            proxyServerUri = "FakeStringValue"
                            name = "FakeStringValue"
                            persistent = $True
                            autoTrigger = $True
                        })
                    )
                    dnsSuffixes = @("FakeStringValue")
                    enableAlwaysOn = $True
                    enableConditionalAccess = $True
                    enableDeviceTunnel = $True
                    enableDnsRegistration = $True
                    enableSingleSignOnWithAlternateCertificate = $True
                    enableSplitTunneling = $True
                    id = "FakeStringValue"
                    microsoftTunnelSiteId = "FakeStringValue"
                    onlyAssociatedAppsCanUseConnection = $True
                    profileTarget = "user"
                    proxyServer = ([MSFT_MicrosoftGraphwindows10VpnProxyServer] @{
                        bypassProxyServerForLocalAddress = $True
                        address = "FakeStringValue"
                        automaticConfigurationScriptUrl = "FakeStringValue"
                        automaticallyDetectProxySettings = $True
                        port = 25
                        odataType = "#microsoft.graph.windows10VpnProxyServer"
                    })
                    rememberUserCredentials = $True
                    routes = @(
                        ([MSFT_MicrosoftGraphvpnRoute] @{
                            prefixSize = 25
                            destinationPrefix = "FakeStringValue"
                        })
                    )
                    servers = @(
                        ([MSFT_MicrosoftGraphvpnServer] @{
                            isDefaultServer = $True
                            description = "FakeStringValue"
                            address = "FakeStringValue"
                        })
                    )
                    singleSignOnEku = ([MSFT_MicrosoftGraphextendedKeyUsage] @{
                        objectIdentifier = "FakeStringValue"
                        name = "FakeStringValue"
                    })
                    singleSignOnIssuerHash = "FakeStringValue"
                    trafficRules = @(
                        ([MSFT_MicrosoftGraphvpnTrafficRule] @{
                            remotePortRanges = @(
                                ([MSFT_MicrosoftGraphNumberRange] @{
                                    lowerNumber = 25
                                    upperNumber = 25
                                })
                            )
                            name = "FakeStringValue"
                            appId = "FakeStringValue"
                            localPortRanges = @(
                                ([MSFT_MicrosoftGraphNumberRange] @{
                                    lowerNumber = 25
                                    upperNumber = 25
                                })
                            )
                            appType = "none"
                            localAddressRanges = @(
                                ([MSFT_MicrosoftGraphIPv4Range] @{
                                    cidrAddress = "FakeStringValue"
                                    upperAddress = "FakeStringValue"
                                    lowerAddress = "FakeStringValue"
                                    odataType = "#microsoft.graph.iPv4CidrRange"
                                })
                            )
                            remoteAddressRanges = @(
                                ([MSFT_MicrosoftGraphIPv4Range] @{
                                    cidrAddress = "FakeStringValue"
                                    upperAddress = "FakeStringValue"
                                    lowerAddress = "FakeStringValue"
                                    odataType = "#microsoft.graph.iPv4CidrRange"
                                })
                            )
                            claims = "FakeStringValue"
                            protocols = 25
                            routingPolicyType = "none"
                            vpnTrafficDirection = "outbound"
                        })
                    )
                    trustedNetworkDomains = @("FakeStringValue")
                    windowsInformationProtectionDomain = "FakeStringValue"
                    Ensure = 'Present'
                    Credential = $Credential;
                }
            }


            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneDeviceConfigurationVpnPolicyWindows10' -Property $testParams).Test() | Should -Be $true
            }
        }

        Context -Name "The IntuneDeviceConfigurationVpnPolicyWindows10 exists and values are NOT in the desired state" -Fixture {
            BeforeAll {
                $testParams = @{
                    associatedApps = @(
                        ([MSFT_MicrosoftGraphwindows10AssociatedApps] @{
                            identifier = "FakeStringValue"
                            appType = "desktop"
                        })
                    )
                    authenticationMethod = "certificate"
                    connectionName = "FakeStringValue"
                    connectionType = "pulseSecure"
                    cryptographySuite = ([MSFT_MicrosoftGraphcryptographySuite] @{
                        cipherTransformConstants = "aes128" # Updated property
                        encryptionMethod = "aes128" # Updated property
                        pfsGroup = "pfs1"
                        dhGroup = "group1"
                        integrityCheckMethod = "sha2_256"
                        authenticationTransformConstants = "md5_96"
                    })
                    description = "FakeStringValue"
                    deviceManagementApplicabilityRuleDeviceMode = ([MSFT_DeviceManagementApplicabilityRuleDeviceMode] @{
                        name = "FakeStringValue"
                        deviceMode = "sModeConfiguration" # Updated property
                        ruleType = "include"
                    })
                    deviceManagementApplicabilityRuleOsEdition = ([MSFT_DeviceManagementApplicabilityRuleOsEdition] @{
                        name = "FakeStringValue"
                        osEditionTypes = @("windows10Professional") # Updated property
                        ruleType = "include"
                    })
                    deviceManagementApplicabilityRuleOsVersion = ([MSFT_DeviceManagementApplicabilityRuleOsVersion] @{
                        name = "FakeStringValue"
                        minOSVersion = "FakeStringValue"
                        maxOSVersion = "FakeStringValue"
                        ruleType = "exclude" # Updated property
                    })
                    displayName = "FakeStringValue"
                    dnsRules = @(
                        ([MSFT_MicrosoftGraphvpnDnsRule] @{
                            servers = @("FakeStringValue")
                            proxyServerUri = "FakeStringValue"
                            name = "FakeStringValue"
                            persistent = $True
                            autoTrigger = $True
                        })
                    )
                    dnsSuffixes = @("FakeStringValue")
                    enableAlwaysOn = $True
                    enableConditionalAccess = $True
                    enableDeviceTunnel = $True
                    enableDnsRegistration = $True
                    enableSingleSignOnWithAlternateCertificate = $True
                    enableSplitTunneling = $True
                    id = "FakeStringValue"
                    microsoftTunnelSiteId = "FakeStringValue"
                    onlyAssociatedAppsCanUseConnection = $True
                    profileTarget = "user"
                    proxyServer = ([MSFT_MicrosoftGraphwindows10VpnProxyServer] @{
                        bypassProxyServerForLocalAddress = $True
                        address = "FakeStringValue"
                        automaticConfigurationScriptUrl = "FakeStringValue"
                        automaticallyDetectProxySettings = $True
                        port = 25
                        odataType = "#microsoft.graph.windows10VpnProxyServer"
                    })
                    rememberUserCredentials = $True
                    routes = @(
                        ([MSFT_MicrosoftGraphvpnRoute] @{
                            prefixSize = 25
                            destinationPrefix = "FakeStringValue"
                        })
                    )
                    servers = @(
                        ([MSFT_MicrosoftGraphvpnServer] @{
                            isDefaultServer = $True
                            description = "FakeStringValue"
                            address = "FakeStringValue"
                        })
                    )
                    singleSignOnEku = ([MSFT_MicrosoftGraphextendedKeyUsage] @{
                        objectIdentifier = "FakeStringValue"
                        name = "FakeStringValue"
                    })
                    singleSignOnIssuerHash = "FakeStringValue"
                    trafficRules = @(
                        ([MSFT_MicrosoftGraphvpnTrafficRule] @{
                            remotePortRanges = @(
                                ([MSFT_MicrosoftGraphNumberRange] @{
                                    lowerNumber = 25
                                    upperNumber = 25
                                })
                            )
                            name = "FakeStringValue"
                            appId = "FakeStringValue"
                            localPortRanges = @(
                                ([MSFT_MicrosoftGraphNumberRange] @{
                                    lowerNumber = 25
                                    upperNumber = 25
                                })
                            )
                            appType = "none"
                            localAddressRanges = @(
                                ([MSFT_MicrosoftGraphIPv4Range] @{
                                    cidrAddress = "FakeStringValue"
                                    upperAddress = "FakeStringValue"
                                    lowerAddress = "FakeStringValue"
                                    odataType = "#microsoft.graph.iPv4CidrRange"
                                })
                            )
                            remoteAddressRanges = @(
                                ([MSFT_MicrosoftGraphIPv4Range] @{
                                    cidrAddress = "FakeStringValue"
                                    upperAddress = "FakeStringValue"
                                    lowerAddress = "FakeStringValue"
                                    odataType = "#microsoft.graph.iPv4CidrRange"
                                })
                            )
                            claims = "FakeStringValue"
                            protocols = 25
                            routingPolicyType = "none"
                            vpnTrafficDirection = "outbound"
                        })
                    )
                    trustedNetworkDomains = @("FakeStringValue")
                    windowsInformationProtectionDomain = "FakeStringValue"
                    Ensure = 'Present'
                    Credential = $Credential;
                }
            }

            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'IntuneDeviceConfigurationVpnPolicyWindows10' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneDeviceConfigurationVpnPolicyWindows10' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should call the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneDeviceConfigurationVpnPolicyWindows10' -Property $testParams).Set()
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
                $result = Invoke-M365DSCResourceMethod -ResourceName 'IntuneDeviceConfigurationVpnPolicyWindows10' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
