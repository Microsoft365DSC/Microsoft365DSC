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
    -DscResource "IntuneDeviceConfigurationSCEPCertificatePolicyWindows10" -GenericStubModule $GenericStubPath
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
            Mock -CommandName Update-DeviceConfigurationPolicyAssignment -MockWith {
            }
            Mock -CommandName New-M365DSCConnection -ModuleName '_Shared' -MockWith {
                return "Credentials"
            }

            # Mock Write-M365DSCHost to hide output during the tests
            Mock -CommandName Write-M365DSCHost -MockWith {
            }
            $Script:exportedInstances =$null
            $Script:ExportMode = $false

            Mock -CommandName Get-MgBetaDeviceManagementDeviceConfigurationAssignment -MockWith {
            }

            Mock -CommandName Invoke-M365DSCGraphRequest -MockWith {
                return @{
                    Id = "00000000-0000-0000-0000-000000000000"
                    DisplayName = "RootCertificate"
                }
            }

            Mock -CommandName Get-M365DSCExportCachedCollection -MockWith {
                return Get-MgBetaDeviceManagementDeviceConfiguration
            }
            Mock -CommandName Get-MgBetaDeviceManagementDeviceConfiguration -MockWith {
                return @{
                    subjectAlternativeNameType = "none"
                    keyUsage = "keyEncipherment"
                    subjectAlternativeNameFormatString = "FakeStringValue"
                    certificateValidityPeriodScale = "days"
                    keyStorageProvider = "useTpmKspOtherwiseUseSoftwareKsp"
                    '@odata.type' = "#microsoft.graph.windows81SCEPCertificateProfile"
                    scepServerUrls = @("FakeStringValue")
                    renewalThresholdPercentage = 25
                    certificateValidityPeriodValue = 25
                    hashAlgorithm = "sha1"
                    keySize = "size1024"
                    subjectNameFormatString = "FakeStringValue"
                    subjectNameFormat = "commonName"
                    certificateStore = "user"
                    extendedKeyUsages = @(
                        @{
                            objectIdentifier = "FakeStringValue"
                            name = "FakeStringValue"
                        }
                    )
                    customSubjectAlternativeNames = @(
                        @{
                            sanType = "none"
                            name = "FakeStringValue"
                        }
                    )
                    description = "FakeStringValue"
                    DeviceManagementApplicabilityRuleDeviceMode = @{
                        Name = "FakeStringValue"
                        DeviceMode = "standardConfiguration"
                        RuleType = "include"
                    }
                    DeviceManagementApplicabilityRuleOsEdition = @{
                        Name = "FakeStringValue"
                        OsEditionTypes = @("windows10Enterprise")
                        RuleType = "include"
                    }
                    DeviceManagementApplicabilityRuleOsVersion = @{
                        Name = "FakeStringValue"
                        MinOSVersion = "10.0.19045.0"
                        MaxOSVersion = "10.0.26100.9999"
                        RuleType = "include"
                    }
                    displayName = "FakeStringValue"
                    id = "FakeStringValue"

                }
            }
        }

        # Test contexts
        Context -Name "The IntuneDeviceConfigurationSCEPCertificatePolicyWindows10 should exist but it DOES NOT" -Fixture {
            BeforeAll {
                $RootCertificateId = ([Guid]::Empty).ToString()

                $testParams = @{
                    CertificateStore = "user"
                    certificateValidityPeriodScale = "days"
                    certificateValidityPeriodValue = 25
                    customSubjectAlternativeNames = @(
                        ([MSFT_MicrosoftGraphcustomSubjectAlternativeName] @{
                            sanType = "none"
                            name = "FakeStringValue"
                        })
                    )
                    description = "FakeStringValue"
                    DeviceManagementApplicabilityRuleDeviceMode = @{
                        Name = "FakeStringValue"
                        DeviceMode = "standardConfiguration"
                        RuleType = "include"
                    }
                    DeviceManagementApplicabilityRuleOsEdition = @{
                        Name = "FakeStringValue"
                        OsEditionTypes = @("windows10Enterprise")
                        RuleType = "include"
                    }
                    DeviceManagementApplicabilityRuleOsVersion = @{
                        Name = "FakeStringValue"
                        MinOSVersion = "10.0.19045.0"
                        MaxOSVersion = "10.0.26100.9999"
                        RuleType = "include"
                    }
                    displayName = "FakeStringValue"
                    extendedKeyUsages = @(
                        ([MSFT_MicrosoftGraphextendedKeyUsage] @{
                            objectIdentifier = "FakeStringValue"
                            name = "FakeStringValue"
                        })
                    )
                    HashAlgorithm = "sha1"
                    id = "FakeStringValue"
                    KeySize = "size1024"
                    keyStorageProvider = "useTpmKspOtherwiseUseSoftwareKsp"
                    KeyUsage = @("keyEncipherment")
                    renewalThresholdPercentage = 25
                    ScepServerUrls = @("FakeStringValue")
                    SubjectAlternativeNameFormatString = "FakeStringValue"
                    subjectAlternativeNameType = "none"
                    subjectNameFormat = "commonName"
                    SubjectNameFormatString = "FakeStringValue"
                    RootCertificateId = $RootCertificateId
                    RootCertificateDisplayName = "RootCertificate"
                    Ensure = "Present"
                    Credential = $Credential;
                }

                Mock -CommandName Get-MgBetaDeviceManagementDeviceConfiguration -MockWith {
                    return $null
                }

                Mock -CommandName Get-MgBetaDeviceManagementDeviceConfiguration -ParameterFilter { $DeviceConfigurationId -eq $RootCertificateId } -MockWith {
                    return @{
                        Id = $RootCertificateId
                        DisplayName = "RootCertificate"
                        '@odata.type' = "#microsoft.graph.windows81TrustedRootCertificate"
                    }
                }
            }
            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'IntuneDeviceConfigurationSCEPCertificatePolicyWindows10' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Absent'
            }
            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneDeviceConfigurationSCEPCertificatePolicyWindows10' -Property $testParams).Test() | Should -Be $false
            }
            It 'Should Create the group from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneDeviceConfigurationSCEPCertificatePolicyWindows10' -Property $testParams).Set()
                Should -Invoke -CommandName New-MgBetaDeviceManagementDeviceConfiguration -Exactly 1
            }
            It 'Should not send the projected root certificate properties in the create body' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneDeviceConfigurationSCEPCertificatePolicyWindows10' -Property $testParams).Set()
                Should -Invoke -CommandName New-MgBetaDeviceManagementDeviceConfiguration -Exactly 1 -ParameterFilter {
                    -not $BodyParameter.ContainsKey('RootCertificateDisplayName') -and
                    -not $BodyParameter.ContainsKey('RootCertificateId') -and
                    $BodyParameter['rootCertificate@odata.bind'] -like "*deviceConfigurations('$RootCertificateId')"
                }
            }
        }

        Context -Name "The IntuneDeviceConfigurationSCEPCertificatePolicyWindows10 should be created from the root certificate display name alone" -Fixture {
            BeforeAll {
                $ResolvedRootCertificateId = '11111111-1111-1111-1111-111111111111'

                $testParams = @{
                    CertificateStore = "user"
                    certificateValidityPeriodScale = "days"
                    certificateValidityPeriodValue = 25
                    customSubjectAlternativeNames = @(
                        ([MSFT_MicrosoftGraphcustomSubjectAlternativeName] @{
                            sanType = "none"
                            name = "FakeStringValue"
                        })
                    )
                    description = "FakeStringValue"
                    displayName = "FakeStringValue"
                    extendedKeyUsages = @(
                        ([MSFT_MicrosoftGraphextendedKeyUsage] @{
                            objectIdentifier = "FakeStringValue"
                            name = "FakeStringValue"
                        })
                    )
                    HashAlgorithm = "sha1"
                    id = "FakeStringValue"
                    KeySize = "size1024"
                    keyStorageProvider = "useTpmKspOtherwiseUseSoftwareKsp"
                    KeyUsage = @("keyEncipherment")
                    renewalThresholdPercentage = 25
                    ScepServerUrls = @("FakeStringValue")
                    SubjectAlternativeNameFormatString = "FakeStringValue"
                    subjectAlternativeNameType = "none"
                    subjectNameFormat = "commonName"
                    SubjectNameFormatString = "FakeStringValue"
                    RootCertificateDisplayName = "RootCertificate"
                    Ensure = "Present"
                    Credential = $Credential;
                }

                Mock -CommandName Get-MgBetaDeviceManagementDeviceConfiguration -MockWith {
                    return $null
                }

                # An identifier-less deviceConfigurations lookup falls back to a collection GET and returns every profile.
                Mock -CommandName Get-MgBetaDeviceManagementDeviceConfiguration -ParameterFilter { [System.String]::IsNullOrEmpty($DeviceConfigurationId) -and [System.String]::IsNullOrEmpty($Filter) } -MockWith {
                    return @(
                        @{
                            Id = '22222222-2222-2222-2222-222222222222'
                            DisplayName = "AnotherRootCertificate"
                            '@odata.type' = "#microsoft.graph.windows81TrustedRootCertificate"
                        }
                    )
                }

                Mock -CommandName Get-MgBetaDeviceManagementDeviceConfiguration -ParameterFilter { $Filter -like '*windows81TrustedRootCertificate*' } -MockWith {
                    return @{
                        Id = $ResolvedRootCertificateId
                        DisplayName = "RootCertificate"
                        '@odata.type' = "#microsoft.graph.windows81TrustedRootCertificate"
                    }
                }
            }
            It 'Should resolve the root certificate by display name and bind it in the create body' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneDeviceConfigurationSCEPCertificatePolicyWindows10' -Property $testParams).Set()
                Should -Invoke -CommandName New-MgBetaDeviceManagementDeviceConfiguration -Exactly 1 -ParameterFilter {
                    -not $BodyParameter.ContainsKey('RootCertificateDisplayName') -and
                    $BodyParameter['rootCertificate@odata.bind'] -like "*deviceConfigurations('$ResolvedRootCertificateId')"
                }
            }
        }

        Context -Name "The IntuneDeviceConfigurationSCEPCertificatePolicyWindows10 exists but it SHOULD NOT" -Fixture {
            BeforeAll {
                $testParams = @{
                    CertificateStore = "user"
                    certificateValidityPeriodScale = "days"
                    certificateValidityPeriodValue = 25
                    customSubjectAlternativeNames = @(
                        ([MSFT_MicrosoftGraphcustomSubjectAlternativeName] @{
                            sanType = "none"
                            name = "FakeStringValue"
                        })
                    )
                    description = "FakeStringValue"
                    DeviceManagementApplicabilityRuleDeviceMode = @{
                        Name = "FakeStringValue"
                        DeviceMode = "standardConfiguration"
                        RuleType = "include"
                    }
                    DeviceManagementApplicabilityRuleOsEdition = @{
                        Name = "FakeStringValue"
                        OsEditionTypes = @("windows10Enterprise")
                        RuleType = "include"
                    }
                    DeviceManagementApplicabilityRuleOsVersion = @{
                        Name = "FakeStringValue"
                        MinOSVersion = "10.0.19045.0"
                        MaxOSVersion = "10.0.26100.9999"
                        RuleType = "include"
                    }
                    displayName = "FakeStringValue"
                    extendedKeyUsages = @(
                        ([MSFT_MicrosoftGraphextendedKeyUsage] @{
                            objectIdentifier = "FakeStringValue"
                            name = "FakeStringValue"
                        })
                    )
                    HashAlgorithm = "sha1"
                    id = "FakeStringValue"
                    KeySize = "size1024"
                    keyStorageProvider = "useTpmKspOtherwiseUseSoftwareKsp"
                    KeyUsage = @("keyEncipherment")
                    renewalThresholdPercentage = 25
                    ScepServerUrls = @("FakeStringValue")
                    SubjectAlternativeNameFormatString = "FakeStringValue"
                    subjectAlternativeNameType = "none"
                    subjectNameFormat = "commonName"
                    SubjectNameFormatString = "FakeStringValue"
                    RootCertificateId = $RootCertificateId
                    RootCertificateDisplayName = "RootCertificate"
                    Ensure = 'Absent'
                    Credential = $Credential;
                }
            }

            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'IntuneDeviceConfigurationSCEPCertificatePolicyWindows10' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneDeviceConfigurationSCEPCertificatePolicyWindows10' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should Remove the group from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneDeviceConfigurationSCEPCertificatePolicyWindows10' -Property $testParams).Set()
                Should -Invoke -CommandName Remove-MgBetaDeviceManagementDeviceConfiguration -Exactly 1
            }
        }
        Context -Name "The IntuneDeviceConfigurationSCEPCertificatePolicyWindows10 Exists and Values are already in the desired state" -Fixture {
            BeforeAll {
                $testParams = @{
                    CertificateStore = "user"
                    certificateValidityPeriodScale = "days"
                    certificateValidityPeriodValue = 25
                    customSubjectAlternativeNames = @(
                        ([MSFT_MicrosoftGraphcustomSubjectAlternativeName] @{
                            sanType = "none"
                            name = "FakeStringValue"
                        })
                    )
                    description = "FakeStringValue"
                    DeviceManagementApplicabilityRuleDeviceMode = @{
                        Name = "FakeStringValue"
                        DeviceMode = "standardConfiguration"
                        RuleType = "include"
                    }
                    DeviceManagementApplicabilityRuleOsEdition = @{
                        Name = "FakeStringValue"
                        OsEditionTypes = @("windows10Enterprise")
                        RuleType = "include"
                    }
                    DeviceManagementApplicabilityRuleOsVersion = @{
                        Name = "FakeStringValue"
                        MinOSVersion = "10.0.19045.0"
                        MaxOSVersion = "10.0.26100.9999"
                        RuleType = "include"
                    }
                    displayName = "FakeStringValue"
                    extendedKeyUsages = @(
                        ([MSFT_MicrosoftGraphextendedKeyUsage] @{
                            objectIdentifier = "FakeStringValue"
                            name = "FakeStringValue"
                        })
                    )
                    HashAlgorithm = "sha1"
                    id = "FakeStringValue"
                    KeySize = "size1024"
                    keyStorageProvider = "useTpmKspOtherwiseUseSoftwareKsp"
                    KeyUsage = @("keyEncipherment")
                    renewalThresholdPercentage = 25
                    ScepServerUrls = @("FakeStringValue")
                    SubjectAlternativeNameFormatString = "FakeStringValue"
                    subjectAlternativeNameType = "none"
                    subjectNameFormat = "commonName"
                    SubjectNameFormatString = "FakeStringValue"
                    RootCertificateId = "00000000-0000-0000-0000-000000000000"
                    RootCertificateDisplayName = "RootCertificate"
                    Ensure = 'Present'
                    Credential = $Credential;
                }
            }


            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneDeviceConfigurationSCEPCertificatePolicyWindows10' -Property $testParams).Test() | Should -Be $true
            }
        }

        Context -Name "The IntuneDeviceConfigurationSCEPCertificatePolicyWindows10 exists and values are NOT in the desired state" -Fixture {
            BeforeAll {
                $RootCertificateId = ([Guid]::Empty).ToString()

                $testParams = @{
                    CertificateStore = "user"
                    certificateValidityPeriodScale = "days"
                    certificateValidityPeriodValue = 25
                    customSubjectAlternativeNames = @(
                        ([MSFT_MicrosoftGraphcustomSubjectAlternativeName] @{
                            sanType = "none"
                            name = "FakeStringValue"
                        })
                    )
                    description = "FakeStringValue"
                    DeviceManagementApplicabilityRuleDeviceMode = @{
                        Name = "FakeStringValue"
                        DeviceMode = "sModeConfiguration" # Updated property
                        RuleType = "include"
                    }
                    DeviceManagementApplicabilityRuleOsEdition = @{
                        Name = "FakeStringValue"
                        OsEditionTypes = @("windows10Professional") # Updated property
                        RuleType = "exclude" # Updated property
                    }
                    DeviceManagementApplicabilityRuleOsVersion = @{
                        Name = "FakeStringValue"
                        MinOSVersion = "10.0.19045.0"
                        MaxOSVersion = "10.0.22631.9999" # Updated property
                        RuleType = "include"
                    }
                    displayName = "FakeStringValue"
                    extendedKeyUsages = @(
                        ([MSFT_MicrosoftGraphextendedKeyUsage] @{
                            objectIdentifier = "FakeStringValue"
                            name = "FakeStringValue"
                        })
                    )
                    HashAlgorithm = "sha1"
                    id = "FakeStringValue"
                    KeySize = "size1024"
                    keyStorageProvider = "useTpmKspOtherwiseUseSoftwareKsp"
                    KeyUsage = @("keyEncipherment")
                    renewalThresholdPercentage = 7 # Updated property
                    ScepServerUrls = @("FakeStringValue")
                    SubjectAlternativeNameFormatString = "FakeStringValue"
                    subjectAlternativeNameType = "none"
                    subjectNameFormat = "commonName"
                    SubjectNameFormatString = "FakeStringValue"
                    RootCertificateId = $RootCertificateId
                    RootCertificateDisplayName = "RootCertificate"
                    Ensure = 'Present'
                    Credential = $Credential;
                }

                Mock -CommandName Get-MgBetaDeviceManagementDeviceConfiguration -ParameterFilter { $DeviceConfigurationId -eq $RootCertificateId } -MockWith {
                    return @{
                        Id = $RootCertificateId
                        DisplayName = "RootCertificate"
                        '@odata.type' = "#microsoft.graph.windows81TrustedRootCertificate"
                    }
                }
            }

            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'IntuneDeviceConfigurationSCEPCertificatePolicyWindows10' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneDeviceConfigurationSCEPCertificatePolicyWindows10' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should call the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneDeviceConfigurationSCEPCertificatePolicyWindows10' -Property $testParams).Set()
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
                $result = Invoke-M365DSCResourceMethod -ResourceName 'IntuneDeviceConfigurationSCEPCertificatePolicyWindows10' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
