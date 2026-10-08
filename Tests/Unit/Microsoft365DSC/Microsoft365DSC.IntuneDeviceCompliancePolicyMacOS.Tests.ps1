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
    -DscResource 'IntuneDeviceCompliancePolicyMacOS' -GenericStubModule $GenericStubPath

Describe -Name $Global:DscHelper.DescribeHeader -Fixture {
    InModuleScope -ModuleName $Global:DscHelper.ModuleName -ScriptBlock {
        Invoke-Command -ScriptBlock $Global:DscHelper.InitializeScript -NoNewScope

        BeforeAll {
            $secpasswd = ConvertTo-SecureString ((New-Guid).ToString()) -AsPlainText -Force
            $Credential = New-Object System.Management.Automation.PSCredential ('tenantadmin@onmicrosoft.com', $secpasswd)

            Mock -ModuleName M365DSCUtil -CommandName Confirm-M365DSCDependencies -MockWith {
            }

            Mock -CommandName New-M365DSCConnection -ModuleName '_Shared' -MockWith {
                return 'Credentials'
            }

            Mock -CommandName Update-MgBetaDeviceManagementDeviceCompliancePolicy -MockWith {
            }

            Mock -CommandName New-MgBetaDeviceManagementDeviceCompliancePolicy -MockWith {
            }

            Mock -CommandName Remove-MgBetaDeviceManagementDeviceCompliancePolicy -MockWith {
            }

            Mock -CommandName Get-M365DSCExportCachedCollection -MockWith {
                return Get-MgBetaDeviceManagementDeviceCompliancePolicy
            }
            Mock -CommandName Get-MgBetaDeviceManagementDeviceCompliancePolicy -MockWith {
                return @{
                    DisplayName          = 'MacOS DSC Policy'
                    Description          = 'Test policy'
                    Id                   = 'd95e706d-c92c-410d-a132-09e0b1032dbd'
                    '@odata.type'                               = '#microsoft.graph.macOSCompliancePolicy'
                    PasswordRequired                            = $False
                    PasswordBlockSimple                         = $False
                    PasswordExpirationDays                      = 365
                    PasswordMinimumLength                       = 6
                    PasswordMinutesOfInactivityBeforeLock       = 5
                    PasswordPreviousPasswordBlockCount          = 13
                    PasswordMinimumCharacterSetCount            = 1
                    PasswordRequiredType                        = 'DeviceDefault'
                    OsMinimumVersion                            = 10
                    OsMaximumVersion                            = 13
                    SystemIntegrityProtectionEnabled            = $False
                    DeviceThreatProtectionEnabled               = $False
                    DeviceThreatProtectionRequiredSecurityLevel = 'Unavailable'
                    StorageRequireEncryption                    = $False
                    FirewallEnabled                             = $False
                    FirewallBlockAllIncoming                    = $False
                    FirewallEnableStealthMode                   = $False
                    DeviceCompliancePolicyScript                = @{
                        deviceComplianceScriptId = 'a1f3c0de-6b4a-4f2d-9c37-58e0d2b41f77'
                        rulesContent             = 'eyJSdWxlcyI6W3siU2V0dGluZ05hbWUiOiJGaWxlVmF1bHRFbmFibGVkIiwiT3BlcmF0b3IiOiJJc0VxdWFscyIsIkRhdGFUeXBlIjoiQm9vbGVhbiIsIk9wZXJhbmQiOnRydWUsIk1vcmVJbmZvVXJsIjoiaHR0cHM6Ly9sZWFybi5taWNyb3NvZnQuY29tL2ludHVuZS9pbnR1bmUtc2VydmljZS9wcm90ZWN0L2NvbXBsaWFuY2UtY3VzdG9tLWpzb24iLCJSZW1lZGlhdGlvblN0cmluZ3MiOlt7Ikxhbmd1YWdlIjoiZW5fVVMiLCJUaXRsZSI6IkZpbGVWYXVsdCBtdXN0IGJlIHR1cm5lZCBvbi4iLCJEZXNjcmlwdGlvbiI6IlR1cm4gb24gRmlsZVZhdWx0IGRpc2sgZW5jcnlwdGlvbiBpbiBTeXN0ZW0gU2V0dGluZ3MsIHRoZW4gcmV0cnkuIn1dfV19'
                    }
                }
            }

            Mock -CommandName Invoke-M365DSCGraphRequest -MockWith {
                if ($Uri -like '*$filter=*')
                {
                    return @{
                        value = @(
                            @{
                                id          = 'a1f3c0de-6b4a-4f2d-9c37-58e0d2b41f77'
                                displayName = 'macOS FileVault compliance'
                                platform    = 'macOS'
                                publisher   = 'Contoso'
                                runAsAccount = 'system'
                            }
                        )
                    }
                }

                return @{
                    id          = 'a1f3c0de-6b4a-4f2d-9c37-58e0d2b41f77'
                    displayName = 'macOS FileVault compliance'
                    platform    = 'macOS'
                    publisher   = 'Contoso'
                    runAsAccount = 'system'
                }
            }

            Mock -CommandName Get-MgBetaDeviceManagementDeviceCompliancePolicyAssignment -MockWith {

                return @()
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
        Context -Name "When the iOS Device Compliance Policy doesn't already exist" -Fixture {
            BeforeAll {
                $testParams = @{
                    DisplayName                                 = 'MacOS DSC Policy'
                    Description                                 = 'Test policy'
                    PasswordRequired                            = $False
                    PasswordBlockSimple                         = $False
                    PasswordExpirationDays                      = 365
                    PasswordMinimumLength                       = 6
                    PasswordMinutesOfInactivityBeforeLock       = 5
                    PasswordPreviousPasswordBlockCount          = 13
                    PasswordMinimumCharacterSetCount            = 1
                    PasswordRequiredType                        = 'DeviceDefault'
                    OsMinimumVersion                            = 10
                    OsMaximumVersion                            = 13
                    SystemIntegrityProtectionEnabled            = $False
                    DeviceThreatProtectionEnabled               = $False
                    DeviceThreatProtectionRequiredSecurityLevel = 'Unavailable'
                    StorageRequireEncryption                    = $False
                    FirewallEnabled                             = $False
                    FirewallBlockAllIncoming                    = $False
                    FirewallEnableStealthMode                   = $False
                    DeviceCompliancePolicyScript                = ([MSFT_MicrosoftGraphDeviceCompliancePolicyScript] @{
                        DisplayName  = 'macOS FileVault compliance'
                        RulesContent = '{"Rules":[{"SettingName":"FileVaultEnabled","Operator":"IsEquals","DataType":"Boolean","Operand":true,"MoreInfoUrl":"https://learn.microsoft.com/intune/intune-service/protect/compliance-custom-json","RemediationStrings":[{"Language":"en_US","Title":"FileVault must be turned on.","Description":"Turn on FileVault disk encryption in System Settings, then retry."}]}]}'
                    })
                    Ensure                                      = 'Present'
                    Credential                                  = $Credential
                }

                Mock -CommandName Get-MgBetaDeviceManagementDeviceCompliancePolicy -MockWith {
                    return $null
                }
            }

            It 'Should return absent from the Get method' {
                    ((New-M365DSCResourceInstance -ResourceName 'IntuneDeviceCompliancePolicyMacOS' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Absent'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneDeviceCompliancePolicyMacOS' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should create the iOS Device Compliance Policy from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneDeviceCompliancePolicyMacOS' -Property $testParams).Set()
                Should -Invoke -CommandName 'New-MgBetaDeviceManagementDeviceCompliancePolicy' -Exactly 1
            }
        }

        Context -Name 'When the iOS Device Compliance Policy already exists and is NOT in the Desired State' -Fixture {
            BeforeAll {
                $testParams = @{
                    DisplayName                                 = 'MacOS DSC Policy'
                    Description                                 = 'Test policy'
                    PasswordRequired                            = $False
                    PasswordBlockSimple                         = $False
                    PasswordExpirationDays                      = 365
                    PasswordMinimumLength                       = 6
                    PasswordMinutesOfInactivityBeforeLock       = 5
                    PasswordPreviousPasswordBlockCount          = 13
                    PasswordMinimumCharacterSetCount            = 1
                    PasswordRequiredType                        = 'DeviceDefault'
                    OsMinimumVersion                            = 11 # Updated property
                    OsMaximumVersion                            = 13
                    SystemIntegrityProtectionEnabled            = $False
                    DeviceThreatProtectionEnabled               = $False
                    DeviceThreatProtectionRequiredSecurityLevel = 'Unavailable'
                    StorageRequireEncryption                    = $False
                    FirewallEnabled                             = $False
                    FirewallBlockAllIncoming                    = $False
                    FirewallEnableStealthMode                   = $False
                    DeviceCompliancePolicyScript                = ([MSFT_MicrosoftGraphDeviceCompliancePolicyScript] @{
                        DisplayName  = 'macOS FileVault compliance'
                        RulesContent = '{"Rules":[{"SettingName":"FileVaultEnabled","Operator":"IsEquals","DataType":"Boolean","Operand":true,"MoreInfoUrl":"https://learn.microsoft.com/intune/intune-service/protect/compliance-custom-json","RemediationStrings":[{"Language":"en_US","Title":"FileVault must be turned on.","Description":"Turn on FileVault disk encryption in System Settings, then retry."}]}]}'
                    })
                    Ensure                                      = 'Present'
                    Credential                                  = $Credential
                }
            }

            It 'Should return Present from the Get method' {
                    ((New-M365DSCResourceInstance -ResourceName 'IntuneDeviceCompliancePolicyMacOS' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneDeviceCompliancePolicyMacOS' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should update the iOS Device Compliance Policy from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneDeviceCompliancePolicyMacOS' -Property $testParams).Set()
                Should -Invoke -CommandName Update-MgBetaDeviceManagementDeviceCompliancePolicy -Exactly 1
            }
        }

        Context -Name 'When the policy already exists and IS in the Desired State' -Fixture {
            BeforeAll {
                $testParams = @{
                    DisplayName                                 = 'MacOS DSC Policy'
                    Description                                 = 'Test policy'
                    PasswordRequired                            = $False
                    PasswordBlockSimple                         = $False
                    PasswordExpirationDays                      = 365
                    PasswordMinimumLength                       = 6
                    PasswordMinutesOfInactivityBeforeLock       = 5
                    PasswordPreviousPasswordBlockCount          = 13
                    PasswordMinimumCharacterSetCount            = 1
                    PasswordRequiredType                        = 'DeviceDefault'
                    OsMinimumVersion                            = 10
                    OsMaximumVersion                            = 13
                    SystemIntegrityProtectionEnabled            = $False
                    DeviceThreatProtectionEnabled               = $False
                    DeviceThreatProtectionRequiredSecurityLevel = 'Unavailable'
                    StorageRequireEncryption                    = $False
                    FirewallEnabled                             = $False
                    FirewallBlockAllIncoming                    = $False
                    FirewallEnableStealthMode                   = $False
                    DeviceCompliancePolicyScript                = ([MSFT_MicrosoftGraphDeviceCompliancePolicyScript] @{
                        DisplayName  = 'macOS FileVault compliance'
                        RulesContent = '{"Rules":[{"SettingName":"FileVaultEnabled","Operator":"IsEquals","DataType":"Boolean","Operand":true,"MoreInfoUrl":"https://learn.microsoft.com/intune/intune-service/protect/compliance-custom-json","RemediationStrings":[{"Language":"en_US","Title":"FileVault must be turned on.","Description":"Turn on FileVault disk encryption in System Settings, then retry."}]}]}'
                    })
                    Assignments                                 = @()
                    Ensure                                      = 'Present'
                    Credential                                  = $Credential
                }
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneDeviceCompliancePolicyMacOS' -Property $testParams).Test() | Should -Be $true
            }
        }

        Context -Name 'When the policy exists and it SHOULD NOT' -Fixture {
            BeforeAll {
                $testParams = @{
                    DisplayName                                 = 'MacOS DSC Policy'
                    Description                                 = 'Test policy'
                    PasswordRequired                            = $False
                    PasswordBlockSimple                         = $False
                    PasswordExpirationDays                      = 365
                    PasswordMinimumLength                       = 6
                    PasswordMinutesOfInactivityBeforeLock       = 5
                    PasswordPreviousPasswordBlockCount          = 13
                    PasswordMinimumCharacterSetCount            = 1
                    PasswordRequiredType                        = 'DeviceDefault'
                    OsMinimumVersion                            = 10
                    OsMaximumVersion                            = 13
                    SystemIntegrityProtectionEnabled            = $False
                    DeviceThreatProtectionEnabled               = $False
                    DeviceThreatProtectionRequiredSecurityLevel = 'Unavailable'
                    StorageRequireEncryption                    = $False
                    FirewallEnabled                             = $False
                    FirewallBlockAllIncoming                    = $False
                    FirewallEnableStealthMode                   = $False
                    DeviceCompliancePolicyScript                = ([MSFT_MicrosoftGraphDeviceCompliancePolicyScript] @{
                        DisplayName  = 'macOS FileVault compliance'
                        RulesContent = '{"Rules":[{"SettingName":"FileVaultEnabled","Operator":"IsEquals","DataType":"Boolean","Operand":true,"MoreInfoUrl":"https://learn.microsoft.com/intune/intune-service/protect/compliance-custom-json","RemediationStrings":[{"Language":"en_US","Title":"FileVault must be turned on.","Description":"Turn on FileVault disk encryption in System Settings, then retry."}]}]}'
                    })
                    Ensure                                      = 'Absent'
                    Credential                                  = $Credential
                }
            }

            It 'Should return Present from the Get method' {
                    ((New-M365DSCResourceInstance -ResourceName 'IntuneDeviceCompliancePolicyMacOS' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneDeviceCompliancePolicyMacOS' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should remove the iOS Device Compliance Policy from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneDeviceCompliancePolicyMacOS' -Property $testParams).Set()
                Should -Invoke -CommandName Remove-MgBetaDeviceManagementDeviceCompliancePolicy -Exactly 1
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
                $result = Invoke-M365DSCResourceMethod -ResourceName 'IntuneDeviceCompliancePolicyMacOS' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }

    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
