[CmdletBinding()]
param(
)
$M365DSCTestFolder = Join-Path -Path $PSScriptRoot `
                        -ChildPath "..\..\Unit" `
                        -Resolve
$CmdletModule = (Join-Path -Path $M365DSCTestFolder `
            -ChildPath "\Stubs\Microsoft365.psm1" `
            -Resolve)
$GenericStubPath = (Join-Path -Path $M365DSCTestFolder `
    -ChildPath "\Stubs\Generic.psm1" `
    -Resolve)
Import-Module -Name (Join-Path -Path $M365DSCTestFolder `
        -ChildPath "\UnitTestHelper.psm1" `
        -Resolve)

$Global:DscHelper = New-M365DscUnitTestHelper -StubModule $CmdletModule `
    -DscResource "IntuneDeviceConfigurationCustomPolicyWindows10" -GenericStubModule $GenericStubPath
Describe -Name $Global:DscHelper.DescribeHeader -Fixture {
    InModuleScope -ModuleName $Global:DscHelper.ModuleName -ScriptBlock {
        Invoke-Command -ScriptBlock $Global:DscHelper.InitializeScript -NoNewScope
        BeforeAll {

            $secpasswd = ConvertTo-SecureString (New-Guid | Out-String) -AsPlainText -Force
            $Credential = New-Object System.Management.Automation.PSCredential ("tenantadmin@onmicrosoft.com", $secpasswd)

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

            Mock -CommandName Get-M365DSCExportCachedCollection -MockWith {
                return Get-MgBetaDeviceManagementDeviceConfiguration
            }
            Mock -CommandName Get-MgBetaDeviceManagementDeviceConfiguration -MockWith {
                return @{
                    '@odata.type' = "#microsoft.graph.windows10CustomConfiguration"
                    omaSettings = @(
                        @{
                            fileName = "FakeStringValue"
                            description = "FakeStringValue"
                            omaUri = "FakeStringValue"
                            '@odata.type' = "#microsoft.graph.omaSettingBase64"
                            secretReferenceValueId = "FakeStringValue"
                            value = "FakeStringValue"
                            isEncrypted = $True
                            displayName = "FakeStringValue"
                        }
                    )
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
                        minOSVersion = "10.0.19045.0"
                        maxOSVersion = "10.0.26100.9999"
                        ruleType = "include"
                    }
                    displayName = "FakeStringValue"
                    id = "FakeStringValue"
                }
            }

            Mock -CommandName New-M365DSCConnection -ModuleName '_Shared' -MockWith {
                return "Credentials"
            }

            Mock -CommandName Get-MgBetaDeviceManagementDeviceConfigurationAssignment -MockWith {
            }
            Mock -CommandName Update-DeviceConfigurationPolicyAssignment -MockWith {
            }
            Mock -CommandName Write-M365DSCHost -MockWith {
            }
        }
        # Test contexts
        Context -Name "The IntuneDeviceConfigurationCustomPolicyWindows10 should exist but it DOES NOT" -Fixture {
            BeforeAll {
                $testParams = @{
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
                        minOSVersion = "10.0.19045.0"
                        maxOSVersion = "10.0.26100.9999"
                        ruleType = "include"
                    }
                    displayName = "FakeStringValue"
                    id = "FakeStringValue"
                    omaSettings = @(
                        ([MSFT_MicrosoftGraphomaSetting] @{
                            fileName = "FakeStringValue"
                            description = "FakeStringValue"
                            omaUri = "FakeStringValue"
                            odataType = "#microsoft.graph.omaSettingBase64"
                            secretReferenceValueId = "FakeStringValue"
                            value = "FakeStringValue"
                            isEncrypted = $True
                            displayName = "FakeStringValue"
                        })
                    )
                    Ensure = "Present"
                    Credential = $Credential;
                }

                Mock -CommandName Get-MgBetaDeviceManagementDeviceConfiguration -MockWith {
                    return $null
                }
            }
            It "Should return Values from the Get method" {
                ((New-M365DSCResourceInstance -ResourceName 'IntuneDeviceConfigurationCustomPolicyWindows10' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Absent'
            }
            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneDeviceConfigurationCustomPolicyWindows10' -Property $testParams).Test() | Should -Be $false
            }
            It 'Should Create the group from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneDeviceConfigurationCustomPolicyWindows10' -Property $testParams).Set()
                Should -Invoke -CommandName New-MgBetaDeviceManagementDeviceConfiguration -Exactly 1
            }
        }

        Context -Name "The IntuneDeviceConfigurationCustomPolicyWindows10 exists but it SHOULD NOT" -Fixture {
            BeforeAll {
                $testParams = @{
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
                        minOSVersion = "10.0.19045.0"
                        maxOSVersion = "10.0.26100.9999"
                        ruleType = "include"
                    }
                    displayName = "FakeStringValue"
                    id = "FakeStringValue"
                    omaSettings = @(
                        ([MSFT_MicrosoftGraphomaSetting] @{
                            fileName = "FakeStringValue"
                            description = "FakeStringValue"
                            omaUri = "FakeStringValue"
                            odataType = "#microsoft.graph.omaSettingBase64"
                            secretReferenceValueId = "FakeStringValue"
                            value = "FakeStringValue"
                            isEncrypted = $True
                            displayName = "FakeStringValue"
                        })
                    )
                    Ensure = "Absent"
                    Credential = $Credential;
                }
            }

            It "Should return Values from the Get method" {
                ((New-M365DSCResourceInstance -ResourceName 'IntuneDeviceConfigurationCustomPolicyWindows10' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneDeviceConfigurationCustomPolicyWindows10' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should Remove the group from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneDeviceConfigurationCustomPolicyWindows10' -Property $testParams).Set()
                Should -Invoke -CommandName Remove-MgBetaDeviceManagementDeviceConfiguration -Exactly 1
            }
        }
        Context -Name "The IntuneDeviceConfigurationCustomPolicyWindows10 Exists and Values are already in the desired state" -Fixture {
            BeforeAll {
                $testParams = @{
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
                        minOSVersion = "10.0.19045.0"
                        maxOSVersion = "10.0.26100.9999"
                        ruleType = "include"
                    }
                    displayName = "FakeStringValue"
                    id = "FakeStringValue"
                    omaSettings = @(
                        ([MSFT_MicrosoftGraphomaSetting] @{
                            fileName = "FakeStringValue"
                            description = "FakeStringValue"
                            omaUri = "FakeStringValue"
                            odataType = "#microsoft.graph.omaSettingBase64"
                            secretReferenceValueId = "FakeStringValue"
                            value = "FakeStringValue"
                            isEncrypted = $True
                            displayName = "FakeStringValue"
                        })
                    )
                    Ensure = "Present"
                    Credential = $Credential;
                }
            }


            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneDeviceConfigurationCustomPolicyWindows10' -Property $testParams).Test() | Should -Be $true
            }
        }

        Context -Name "The IntuneDeviceConfigurationCustomPolicyWindows10 exists and values are NOT in the desired state" -Fixture {
            BeforeAll {
                $testParams = @{
                    description = "FakeStringValue"
                    deviceManagementApplicabilityRuleDeviceMode = @{
                        name = "FakeStringValue"
                        deviceMode = "sModeConfiguration" # Updated property
                        ruleType = "include"
                    }
                    deviceManagementApplicabilityRuleOsEdition = @{
                        name = "FakeStringValue"
                        osEditionTypes = @("windows10Enterprise")
                        ruleType = "exclude" # Updated property
                    }
                    deviceManagementApplicabilityRuleOsVersion = @{
                        name = "FakeStringValue"
                        minOSVersion = "10.0.19045.0"
                        maxOSVersion = "10.0.26100.9999"
                        ruleType = "include"
                    }
                    displayName = "FakeStringValue"
                    id = "FakeStringValue"
                    omaSettings = @(
                        ([MSFT_MicrosoftGraphomaSetting] @{
                            fileName = "FakeStringValue"
                            description = "FakeStringValue"
                            omaUri = "FakeStringValue"
                            odataType = "#microsoft.graph.omaSettingBase64"
                            secretReferenceValueId = "FakeStringValue"
                            value = "FakeStringValue2" # Updated property
                            isEncrypted = $True
                            displayName = "FakeStringValue"
                        })
                    )
                    Ensure = "Present"
                    Credential = $Credential;
                }
            }

            It "Should return Values from the Get method" {
                ((New-M365DSCResourceInstance -ResourceName 'IntuneDeviceConfigurationCustomPolicyWindows10' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneDeviceConfigurationCustomPolicyWindows10' -Property $testParams).Test() | Should -Be $false
            }

            It "Should call the Set method" {
                (New-M365DSCResourceInstance -ResourceName 'IntuneDeviceConfigurationCustomPolicyWindows10' -Property $testParams).Set()
                Should -Invoke -CommandName Update-MgBetaDeviceManagementDeviceConfiguration -Exactly 1
            }
        }

        Context -Name "ReverseDSC Tests" -Fixture {
            BeforeAll {
                $Global:CurrentModeIsExport = $true
                $Global:PartialExportFileName = "$(New-Guid).partial.ps1"
                $testParams = @{
                    Credential = $Credential
                }
            }

            It "Should Reverse Engineer resource from the Export method" {
                $result = Invoke-M365DSCResourceMethod -ResourceName 'IntuneDeviceConfigurationCustomPolicyWindows10' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
