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
    -DscResource 'IntuneDeviceConfigurationWiredNetworkPolicyWindows10' -GenericStubModule $GenericStubPath
Describe -Name $Global:DscHelper.DescribeHeader -Fixture {
    InModuleScope -ModuleName $Global:DscHelper.ModuleName -ScriptBlock {
        Invoke-Command -ScriptBlock $Global:DscHelper.InitializeScript -NoNewScope
        BeforeAll {

            $secpasswd = ConvertTo-SecureString (New-GUID).ToString() -AsPlainText -Force
            $Credential = New-Object System.Management.Automation.PSCredential ('tenantadmin@onmicrosoft.com', $secpasswd)

            Mock -ModuleName M365DSCUtil -CommandName Confirm-M365DSCDependencies -MockWith {
            }

            Mock -CommandName Get-MSCloudLoginConnectionProfile -MockWith {
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
            Mock -CommandName Update-DeviceConfigurationPolicyAssignment -MockWith {
            }
            # Mock Write-M365DSCHost to hide output during the tests
            Mock -CommandName Write-M365DSCHost -MockWith {
            }
            $Script:exportedInstance = $null
            $Script:ExportMode = $false

            Mock -CommandName Get-MgBetaDeviceManagementDeviceConfigurationAssignment -MockWith {
            }

            Mock -CommandName Get-M365DSCExportCachedCollection -MockWith {
                return Get-MgBetaDeviceManagementDeviceConfiguration
            }
            Mock -CommandName Get-MgBetaDeviceManagementDeviceConfiguration -MockWith {
                return @{
                    outerIdentityPrivacyTemporaryValue      = 'FakeStringValue'
                    eapType                                 = 'eapTls'
                    forceFIPSCompliance                     = $True
                    '@odata.type'                           = '#microsoft.graph.windowsWiredNetworkConfiguration'
                    secondaryAuthenticationMethod           = 'certificate'
                    cacheCredentials                        = $True
                    innerAuthenticationProtocolForEAPTTLS   = 'unencryptedPassword'
                    requireCryptographicBinding             = $True
                    authenticationType                      = 'none'
                    trustedServerCertificateNames           = @('FakeStringValue')
                    enforce8021X                            = $True
                    authenticationRetryDelayPeriodInSeconds = 25
                    performServerValidation                 = $True
                    authenticationBlockPeriodInMinutes      = 25
                    maximumEAPOLStartMessages               = 25
                    disableUserPromptForServerValidation    = $True
                    authenticationPeriodInSeconds           = 25
                    eapolStartPeriodInSeconds               = 25
                    authenticationMethod                    = 'certificate'
                    maximumAuthenticationFailures           = 25
                    Description          = 'FakeStringValue'
                    DeviceManagementApplicabilityRuleDeviceMode = @{
                        Name       = 'FakeStringValue'
                        DeviceMode = 'standardConfiguration'
                        RuleType   = 'include'
                    }
                    DeviceManagementApplicabilityRuleOsEdition = @{
                        Name           = 'FakeStringValue'
                        OsEditionTypes = @('windows10Enterprise')
                        RuleType       = 'include'
                    }
                    DeviceManagementApplicabilityRuleOsVersion = @{
                        Name         = 'FakeStringValue'
                        MinOSVersion = '10.0.19045.0'
                        MaxOSVersion = '10.0.26100.9999'
                        RuleType     = 'include'
                    }
                    DisplayName          = 'FakeStringValue'
                    Id                   = 'FakeStringValue'
                }
            }

            Mock -CommandName Invoke-M365DSCGraphRequest -MockWith {
            }

            Mock -CommandName Invoke-M365DSCGraphRequest -MockWith {
                return @{
                    value = @(@{
                        Id = 'a485d322-13cd-43ef-beda-733f656f48ea'
                        DisplayName = 'RootCertificate'
                    })
                }
            } -ParameterFilter { $Method -eq 'Get' -and $Uri -like '*/rootCertificatesForServerValidation' }

            Mock -CommandName Invoke-M365DSCGraphRequest -MockWith {
                return @{
                    Id = '0b9aef2f-1671-4260-8eb9-3ab3138e176a'
                    DisplayName = 'ClientCertificate'
                }
            } -ParameterFilter { $Method -eq 'Get' -and $Uri -like '*/secondaryIdentityCertificateForClientAuthentication' }

            Mock -CommandName Get-MgBetaDeviceManagementDeviceConfiguration -MockWith {
                return @{
                    Id = 'a485d322-13cd-43ef-beda-733f656f48ea'
                    DisplayName = 'RootCertificate'
                    '@odata.type' = '#microsoft.graph.windows81TrustedRootCertificate'
                }
            } -ParameterFilter { $DeviceConfigurationId -eq 'a485d322-13cd-43ef-beda-733f656f48ea' }

            Mock -CommandName Get-MgBetaDeviceManagementDeviceConfiguration -MockWith {
                return @{
                    Id = '0b9aef2f-1671-4260-8eb9-3ab3138e176a'
                    DisplayName = 'ClientCertificate'
                    '@odata.type' = '#microsoft.graph.windows81SCEPCertificateProfile'
                }
            } -ParameterFilter { $DeviceConfigurationId -eq '0b9aef2f-1671-4260-8eb9-3ab3138e176a' }
        }
        # Test contexts
        Context -Name 'The IntuneDeviceConfigurationWiredNetworkPolicyWindows10 should exist but it DOES NOT' -Fixture {
            BeforeAll {
                $testParams = @{
                    AuthenticationBlockPeriodInMinutes                             = 25
                    AuthenticationMethod                                           = 'certificate'
                    AuthenticationPeriodInSeconds                                  = 25
                    AuthenticationRetryDelayPeriodInSeconds                        = 25
                    AuthenticationType                                             = 'none'
                    CacheCredentials                                               = $True
                    Description                                                    = 'FakeStringValue'
                    DeviceManagementApplicabilityRuleDeviceMode                    = @{
                        Name       = 'FakeStringValue'
                        DeviceMode = 'standardConfiguration'
                        RuleType   = 'include'
                    }
                    DeviceManagementApplicabilityRuleOsEdition                     = @{
                        Name           = 'FakeStringValue'
                        OsEditionTypes = @('windows10Enterprise')
                        RuleType       = 'include'
                    }
                    DeviceManagementApplicabilityRuleOsVersion                     = @{
                        Name         = 'FakeStringValue'
                        MinOSVersion = '10.0.19045.0'
                        MaxOSVersion = '10.0.26100.9999'
                        RuleType     = 'include'
                    }
                    DisableUserPromptForServerValidation                           = $True
                    DisplayName                                                    = 'FakeStringValue'
                    EapolStartPeriodInSeconds                                      = 25
                    EapType                                                        = 'eapTls'
                    Enforce8021X                                                   = $True
                    ForceFIPSCompliance                                            = $True
                    Id                                                             = 'FakeStringValue'
                    InnerAuthenticationProtocolForEAPTTLS                          = 'unencryptedPassword'
                    MaximumAuthenticationFailures                                  = 25
                    MaximumEAPOLStartMessages                                      = 25
                    OuterIdentityPrivacyTemporaryValue                             = 'FakeStringValue'
                    PerformServerValidation                                        = $True
                    RequireCryptographicBinding                                    = $True
                    SecondaryAuthenticationMethod                                  = 'certificate'
                    TrustedServerCertificateNames                                  = @('FakeStringValue')
                    Ensure                                                         = 'Present'
                    Credential                                                     = $Credential
                    RootCertificatesForServerValidationIds                         = @('a485d322-13cd-43ef-beda-733f656f48ea')
                    RootCertificatesForServerValidationDisplayNames                = @('RootCertificate')
                    SecondaryIdentityCertificateForClientAuthenticationId          = '0b9aef2f-1671-4260-8eb9-3ab3138e176a'
                    SecondaryIdentityCertificateForClientAuthenticationDisplayName = 'ClientCertificate'
                }

                Mock -CommandName Get-MgBetaDeviceManagementDeviceConfiguration -MockWith {
                    return $null
                }

                Mock -CommandName Get-MgBetaDeviceManagementDeviceConfiguration -MockWith {
                    return @{
                        Id = 'a485d322-13cd-43ef-beda-733f656f48ea'
                        DisplayName = 'RootCertificate'
                        '@odata.type' = '#microsoft.graph.windows81TrustedRootCertificate'
                    }
                } -ParameterFilter { $DeviceConfigurationId -eq 'a485d322-13cd-43ef-beda-733f656f48ea' }

                Mock -CommandName Get-MgBetaDeviceManagementDeviceConfiguration -MockWith {
                    return @{
                        Id = '0b9aef2f-1671-4260-8eb9-3ab3138e176a'
                        DisplayName = 'ClientCertificate'
                        '@odata.type' = '#microsoft.graph.windows81SCEPCertificateProfile'
                    }
                } -ParameterFilter { $DeviceConfigurationId -eq '0b9aef2f-1671-4260-8eb9-3ab3138e176a' }
            }
            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'IntuneDeviceConfigurationWiredNetworkPolicyWindows10' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Absent'
            }
            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneDeviceConfigurationWiredNetworkPolicyWindows10' -Property $testParams).Test() | Should -Be $false
            }
            It 'Should Create the group from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneDeviceConfigurationWiredNetworkPolicyWindows10' -Property $testParams).Set()
                Should -Invoke -CommandName New-MgBetaDeviceManagementDeviceConfiguration -Exactly 1
            }
        }

        Context -Name 'The IntuneDeviceConfigurationWiredNetworkPolicyWindows10 exists but it SHOULD NOT' -Fixture {
            BeforeAll {
                $testParams = @{
                    AuthenticationBlockPeriodInMinutes                    = 25
                    AuthenticationMethod                                  = 'certificate'
                    AuthenticationPeriodInSeconds                         = 25
                    AuthenticationRetryDelayPeriodInSeconds               = 25
                    AuthenticationType                                    = 'none'
                    CacheCredentials                                      = $True
                    Description                                           = 'FakeStringValue'
                    DeviceManagementApplicabilityRuleDeviceMode           = @{
                        Name       = 'FakeStringValue'
                        DeviceMode = 'standardConfiguration'
                        RuleType   = 'include'
                    }
                    DeviceManagementApplicabilityRuleOsEdition            = @{
                        Name           = 'FakeStringValue'
                        OsEditionTypes = @('windows10Enterprise')
                        RuleType       = 'include'
                    }
                    DeviceManagementApplicabilityRuleOsVersion            = @{
                        Name         = 'FakeStringValue'
                        MinOSVersion = '10.0.19045.0'
                        MaxOSVersion = '10.0.26100.9999'
                        RuleType     = 'include'
                    }
                    DisableUserPromptForServerValidation                  = $True
                    DisplayName                                           = 'FakeStringValue'
                    EapolStartPeriodInSeconds                             = 25
                    EapType                                               = 'eapTls'
                    Enforce8021X                                          = $True
                    ForceFIPSCompliance                                   = $True
                    Id                                                    = 'FakeStringValue'
                    InnerAuthenticationProtocolForEAPTTLS                 = 'unencryptedPassword'
                    MaximumAuthenticationFailures                         = 25
                    MaximumEAPOLStartMessages                             = 25
                    OuterIdentityPrivacyTemporaryValue                    = 'FakeStringValue'
                    PerformServerValidation                               = $True
                    RequireCryptographicBinding                           = $True
                    SecondaryAuthenticationMethod                         = 'certificate'
                    TrustedServerCertificateNames                         = @('FakeStringValue')
                    Ensure                                                = 'Absent'
                    Credential                                                     = $Credential
                    RootCertificatesForServerValidationIds                         = @('a485d322-13cd-43ef-beda-733f656f48ea')
                    RootCertificatesForServerValidationDisplayNames                = @('RootCertificate')
                    SecondaryIdentityCertificateForClientAuthenticationId          = '0b9aef2f-1671-4260-8eb9-3ab3138e176a'
                    SecondaryIdentityCertificateForClientAuthenticationDisplayName = 'ClientCertificate'
                }
            }

            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'IntuneDeviceConfigurationWiredNetworkPolicyWindows10' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneDeviceConfigurationWiredNetworkPolicyWindows10' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should Remove the group from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneDeviceConfigurationWiredNetworkPolicyWindows10' -Property $testParams).Set()
                Should -Invoke -CommandName Remove-MgBetaDeviceManagementDeviceConfiguration -Exactly 1
            }
        }
        Context -Name 'The IntuneDeviceConfigurationWiredNetworkPolicyWindows10 Exists and Values are already in the desired state' -Fixture {
            BeforeAll {
                $testParams = @{
                    AuthenticationBlockPeriodInMinutes                    = 25
                    AuthenticationMethod                                  = 'certificate'
                    AuthenticationPeriodInSeconds                         = 25
                    AuthenticationRetryDelayPeriodInSeconds               = 25
                    AuthenticationType                                    = 'none'
                    CacheCredentials                                      = $True
                    Description                                           = 'FakeStringValue'
                    DeviceManagementApplicabilityRuleDeviceMode           = @{
                        Name       = 'FakeStringValue'
                        DeviceMode = 'standardConfiguration'
                        RuleType   = 'include'
                    }
                    DeviceManagementApplicabilityRuleOsEdition            = @{
                        Name           = 'FakeStringValue'
                        OsEditionTypes = @('windows10Enterprise')
                        RuleType       = 'include'
                    }
                    DeviceManagementApplicabilityRuleOsVersion            = @{
                        Name         = 'FakeStringValue'
                        MinOSVersion = '10.0.19045.0'
                        MaxOSVersion = '10.0.26100.9999'
                        RuleType     = 'include'
                    }
                    DisableUserPromptForServerValidation                  = $True
                    DisplayName                                           = 'FakeStringValue'
                    EapolStartPeriodInSeconds                             = 25
                    EapType                                               = 'eapTls'
                    Enforce8021X                                          = $True
                    ForceFIPSCompliance                                   = $True
                    Id                                                    = 'FakeStringValue'
                    InnerAuthenticationProtocolForEAPTTLS                 = 'unencryptedPassword'
                    MaximumAuthenticationFailures                         = 25
                    MaximumEAPOLStartMessages                             = 25
                    OuterIdentityPrivacyTemporaryValue                    = 'FakeStringValue'
                    PerformServerValidation                               = $True
                    RequireCryptographicBinding                           = $True
                    SecondaryAuthenticationMethod                         = 'certificate'
                    TrustedServerCertificateNames                         = @('FakeStringValue')
                    Ensure                                                = 'Present'
                    Credential                                            = $Credential
                    RootCertificatesForServerValidationIds                = @('a485d322-13cd-43ef-beda-733f656f48ea')
                    SecondaryIdentityCertificateForClientAuthenticationId = '0b9aef2f-1671-4260-8eb9-3ab3138e176a'
                }
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneDeviceConfigurationWiredNetworkPolicyWindows10' -Property $testParams).Test() | Should -Be $true
            }
        }

        Context -Name 'The IntuneDeviceConfigurationWiredNetworkPolicyWindows10 should be created with root certificate identifiers and no display names' -Fixture {
            BeforeAll {
                $testParams = @{
                    DisplayName                            = 'FakeStringValue'
                    Id                                     = 'FakeStringValue'
                    Ensure                                 = 'Present'
                    Credential                             = $Credential
                    RootCertificatesForServerValidationIds = @('a485d322-13cd-43ef-beda-733f656f48ea')
                }

                Mock -CommandName Get-MgBetaDeviceManagementDeviceConfiguration -MockWith {
                    return $null
                }
            }

            It 'Should bind the root certificate by identifier in the create body' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneDeviceConfigurationWiredNetworkPolicyWindows10' -Property $testParams).Set()
                Should -Invoke -CommandName New-MgBetaDeviceManagementDeviceConfiguration -Exactly 1 -ParameterFilter {
                    $BodyParameter['rootCertificatesForServerValidation@odata.bind'] -contains "beta/deviceManagement/deviceConfigurations('a485d322-13cd-43ef-beda-733f656f48ea')"
                }
            }
        }

        Context -Name 'The IntuneDeviceConfigurationWiredNetworkPolicyWindows10 exists and gains a root certificate identifier with no display names' -Fixture {
            BeforeAll {
                $testParams = @{
                    DisplayName                            = 'FakeStringValue'
                    Id                                     = 'FakeStringValue'
                    Ensure                                 = 'Present'
                    Credential                             = $Credential
                    RootCertificatesForServerValidationIds = @('a485d322-13cd-43ef-beda-733f656f48ea', '2c8bd6a5-9f2f-4c07-9d64-5a4a1a2d3b7e')
                }

                Mock -CommandName Get-MgBetaDeviceManagementDeviceConfiguration -MockWith {
                    return @{
                        Id = '2c8bd6a5-9f2f-4c07-9d64-5a4a1a2d3b7e'
                        DisplayName = 'SecondRootCertificate'
                        '@odata.type' = '#microsoft.graph.windows81TrustedRootCertificate'
                    }
                } -ParameterFilter { $DeviceConfigurationId -eq '2c8bd6a5-9f2f-4c07-9d64-5a4a1a2d3b7e' }
            }

            It 'Should post the added root certificate reference by identifier' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneDeviceConfigurationWiredNetworkPolicyWindows10' -Property $testParams).Set()
                Should -Invoke -CommandName Invoke-M365DSCGraphRequest -Exactly 1 -ParameterFilter {
                    $Method -eq 'POST' -and $Body -like "*2c8bd6a5-9f2f-4c07-9d64-5a4a1a2d3b7e*"
                }
            }
        }

        Context -Name 'The IntuneDeviceConfigurationWiredNetworkPolicyWindows10 exists and values are NOT in the desired state' -Fixture {
            BeforeAll {
                $testParams = @{
                    AuthenticationBlockPeriodInMinutes                    = 25
                    AuthenticationMethod                                  = 'certificate'
                    AuthenticationPeriodInSeconds                         = 25
                    AuthenticationRetryDelayPeriodInSeconds               = 25
                    AuthenticationType                                    = 'none'
                    CacheCredentials                                      = $True
                    Description                                           = 'FakeStringValue'
                    DeviceManagementApplicabilityRuleDeviceMode           = @{
                        Name       = 'FakeStringValue'
                        DeviceMode = 'sModeConfiguration' # Updated property
                        RuleType   = 'include'
                    }
                    DeviceManagementApplicabilityRuleOsEdition            = @{
                        Name           = 'FakeStringValue'
                        OsEditionTypes = @('windows10Professional') # Updated property
                        RuleType       = 'exclude' # Updated property
                    }
                    DeviceManagementApplicabilityRuleOsVersion            = @{
                        Name         = 'FakeStringValue'
                        MinOSVersion = '10.0.19045.0'
                        MaxOSVersion = '10.0.22631.9999' # Updated property
                        RuleType     = 'include'
                    }
                    DisableUserPromptForServerValidation                  = $True
                    DisplayName                                           = 'FakeStringValue'
                    EapolStartPeriodInSeconds                             = 7 # Updated property
                    EapType                                               = 'eapTls'
                    Enforce8021X                                          = $True
                    ForceFIPSCompliance                                   = $True
                    Id                                                    = 'FakeStringValue'
                    InnerAuthenticationProtocolForEAPTTLS                 = 'unencryptedPassword'
                    MaximumAuthenticationFailures                         = 25
                    MaximumEAPOLStartMessages                             = 25
                    OuterIdentityPrivacyTemporaryValue                    = 'FakeStringValue'
                    PerformServerValidation                               = $True
                    RequireCryptographicBinding                           = $True
                    SecondaryAuthenticationMethod                         = 'certificate'
                    TrustedServerCertificateNames                         = @('FakeStringValue')
                    Ensure                                                = 'Present'
                    Credential                                            = $Credential
                    RootCertificatesForServerValidationIds                = @('a485d322-13cd-43ef-beda-733f656f48ea')
                    RootCertificatesForServerValidationDisplayNames       = @('RootCertificate')
                    SecondaryIdentityCertificateForClientAuthenticationId = '0b9aef2f-1671-4260-8eb9-3ab3138e176a'
                    SecondaryIdentityCertificateForClientAuthenticationDisplayName = 'ClientCertificate'
                }
            }

            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'IntuneDeviceConfigurationWiredNetworkPolicyWindows10' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneDeviceConfigurationWiredNetworkPolicyWindows10' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should call the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneDeviceConfigurationWiredNetworkPolicyWindows10' -Property $testParams).Set()
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
                $result = Invoke-M365DSCResourceMethod -ResourceName 'IntuneDeviceConfigurationWiredNetworkPolicyWindows10' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
