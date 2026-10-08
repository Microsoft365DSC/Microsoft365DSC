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
    -DscResource 'IntuneWindowsAutopilotDeploymentProfileAzureADHybridJoined' -GenericStubModule $GenericStubPath
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

            Mock -CommandName Update-MgBetaDeviceManagementWindowsAutopilotDeploymentProfile -MockWith {
            }

            Mock -CommandName New-MgBetaDeviceManagementWindowsAutopilotDeploymentProfile -MockWith {
            }

            Mock -CommandName Remove-MgBetaDeviceManagementWindowsAutopilotDeploymentProfile -MockWith {
            }

            Mock -CommandName New-M365DSCConnection -ModuleName '_Shared' -MockWith {
                return 'Credentials'
            }

            Mock -CommandName Get-MgBetaDeviceManagementWindowsAutopilotDeploymentProfile -MockWith {
                return @{
                    hybridAzureADJoinSkipConnectivityCheck = $True
                    '@odata.type'                          = '#microsoft.graph.activeDirectoryWindowsAutopilotDeploymentProfile'
                    Description                    = 'FakeStringValue'
                    DeviceNameTemplate             = 'FakeStringValue'
                    DeviceType                     = 'windowsPc'
                    DisplayName                    = 'FakeStringValue'
                    PreprovisioningAllowed         = $True
                    EnrollmentStatusScreenSettings = @{
                        HideInstallationProgress                         = $True
                        BlockDeviceSetupRetryByUser                      = $True
                        AllowLogCollectionOnInstallFailure               = $True
                        AllowDeviceUseBeforeProfileAndAppInstallComplete = $True
                        InstallProgressTimeoutInMinutes                  = 25
                        CustomErrorMessage                               = 'FakeStringValue'
                        AllowDeviceUseOnInstallFailure                   = $True
                    }
                    HardwareHashExtractionEnabled  = $True
                    Id                             = 'FakeStringValue'
                    Locale                       = 'FakeStringValue'
                    ManagementServiceAppId         = 'FakeStringValue'
                    OutOfBoxExperienceSetting     = @{
                        eulaHidden                   = $True
                        escapeLinkHidden             = $True
                        privacySettingsHidden        = $True
                        deviceUsageType              = 'singleUser'
                        keyboardSelectionPageSkipped = $True
                        userType                     = 'administrator'
                    }
                }
            }

            Mock -CommandName Get-MgBetaDeviceManagementWindowsAutopilotDeploymentProfileAssignment -MockWith {
            }

            Mock -CommandName Write-M365DSCHost -MockWith {
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
        Context -Name 'The IntuneWindowsAutopilotDeploymentProfileAzureADHybridJoined should exist but it DOES NOT' -Fixture {
            BeforeAll {
                $testParams = @{
                    Description                            = 'FakeStringValue'
                    DeviceNameTemplate                     = 'FakeStringValue'
                    DeviceType                             = 'windowsPc'
                    DisplayName                            = 'FakeStringValue'
                    PreprovisioningAllowed                       = $True
                    EnrollmentStatusScreenSettings         = ([MSFT_MicrosoftGraphwindowsEnrollmentStatusScreenSettings] @{
                        HideInstallationProgress                         = $True
                        BlockDeviceSetupRetryByUser                      = $True
                        AllowLogCollectionOnInstallFailure               = $True
                        AllowDeviceUseBeforeProfileAndAppInstallComplete = $True
                        InstallProgressTimeoutInMinutes                  = 25
                        CustomErrorMessage                               = 'FakeStringValue'
                        AllowDeviceUseOnInstallFailure                   = $True
                        })
                    HardwareHashExtractionEnabled                    = $True
                    HybridAzureADJoinSkipConnectivityCheck = $True
                    Id                                     = 'FakeStringValue'
                    Locale                               = 'FakeStringValue'
                    ManagementServiceAppId                 = 'FakeStringValue'
                    OutOfBoxExperienceSetting              = ([MSFT_MicrosoftGraphoutOfBoxExperienceSetting] @{
                        DeviceUsageType              = 'singleUser'
                        EscapeLinkHidden             = $True
                        EulaHidden                   = $True
                        KeyboardSelectionPageSkipped = $True
                        PrivacySettingsHidden        = $True
                        UserType                     = 'administrator'
                    })
                    Ensure                                 = 'Present'
                    Credential                             = $Credential
                }

                Mock -CommandName Get-MgBetaDeviceManagementWindowsAutopilotDeploymentProfile -MockWith {
                    return $null
                }
            }
            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'IntuneWindowsAutopilotDeploymentProfileAzureADHybridJoined' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Absent'
            }
            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneWindowsAutopilotDeploymentProfileAzureADHybridJoined' -Property $testParams).Test() | Should -Be $false
            }
            It 'Should Create the group from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneWindowsAutopilotDeploymentProfileAzureADHybridJoined' -Property $testParams).Set()
                Should -Invoke -CommandName New-MgBetaDeviceManagementWindowsAutopilotDeploymentProfile -Exactly 1
            }
        }

        Context -Name 'The IntuneWindowsAutopilotDeploymentProfileAzureADHybridJoined exists but it SHOULD NOT' -Fixture {
            BeforeAll {
                $testParams = @{
                    Description                            = 'FakeStringValue'
                    DeviceNameTemplate                     = 'FakeStringValue'
                    DeviceType                             = 'windowsPc'
                    DisplayName                            = 'FakeStringValue'
                    PreprovisioningAllowed                       = $True
                    EnrollmentStatusScreenSettings         = ([MSFT_MicrosoftGraphwindowsEnrollmentStatusScreenSettings] @{
                        HideInstallationProgress                         = $True
                        BlockDeviceSetupRetryByUser                      = $True
                        AllowLogCollectionOnInstallFailure               = $True
                        AllowDeviceUseBeforeProfileAndAppInstallComplete = $True
                        InstallProgressTimeoutInMinutes                  = 25
                        CustomErrorMessage                               = 'FakeStringValue'
                        AllowDeviceUseOnInstallFailure                   = $True
                    })
                    HardwareHashExtractionEnabled                    = $True
                    HybridAzureADJoinSkipConnectivityCheck = $True
                    Id                                     = 'FakeStringValue'
                    Locale                               = 'FakeStringValue'
                    ManagementServiceAppId                 = 'FakeStringValue'
                    OutOfBoxExperienceSetting              = ([MSFT_MicrosoftGraphoutOfBoxExperienceSetting] @{
                        DeviceUsageType              = 'singleUser'
                        EscapeLinkHidden             = $True
                        EulaHidden                   = $True
                        KeyboardSelectionPageSkipped = $True
                        PrivacySettingsHidden        = $True
                        UserType                     = 'administrator'
                    })
                    Ensure                                 = 'Absent'
                    Credential                             = $Credential
                }
            }

            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'IntuneWindowsAutopilotDeploymentProfileAzureADHybridJoined' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneWindowsAutopilotDeploymentProfileAzureADHybridJoined' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should Remove the group from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneWindowsAutopilotDeploymentProfileAzureADHybridJoined' -Property $testParams).Set()
                Should -Invoke -CommandName Remove-MgBetaDeviceManagementWindowsAutopilotDeploymentProfile -Exactly 1
            }
        }
        Context -Name 'The IntuneWindowsAutopilotDeploymentProfileAzureADHybridJoined Exists and Values are already in the desired state' -Fixture {
            BeforeAll {
                $testParams = @{
                    Description                            = 'FakeStringValue'
                    DeviceNameTemplate                     = 'FakeStringValue'
                    DeviceType                             = 'windowsPc'
                    DisplayName                            = 'FakeStringValue'
                    PreprovisioningAllowed                       = $True
                    EnrollmentStatusScreenSettings         = ([MSFT_MicrosoftGraphwindowsEnrollmentStatusScreenSettings] @{
                        HideInstallationProgress                         = $True
                        BlockDeviceSetupRetryByUser                      = $True
                        AllowLogCollectionOnInstallFailure               = $True
                        AllowDeviceUseBeforeProfileAndAppInstallComplete = $True
                        InstallProgressTimeoutInMinutes                  = 25
                        CustomErrorMessage                               = 'FakeStringValue'
                        AllowDeviceUseOnInstallFailure                   = $True
                    })
                    HardwareHashExtractionEnabled                    = $True
                    HybridAzureADJoinSkipConnectivityCheck = $True
                    Id                                     = 'FakeStringValue'
                    Locale                               = 'FakeStringValue'
                    ManagementServiceAppId                 = 'FakeStringValue'
                    OutOfBoxExperienceSetting              = ([MSFT_MicrosoftGraphoutOfBoxExperienceSetting] @{
                        DeviceUsageType              = 'singleUser'
                        EscapeLinkHidden             = $True
                        EulaHidden                   = $True
                        KeyboardSelectionPageSkipped = $True
                        PrivacySettingsHidden        = $True
                        UserType                     = 'administrator'
                    })
                    Ensure                                 = 'Present'
                    Credential                             = $Credential
                }
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneWindowsAutopilotDeploymentProfileAzureADHybridJoined' -Property $testParams).Test() | Should -Be $true
            }
        }

        Context -Name 'The IntuneWindowsAutopilotDeploymentProfileAzureADHybridJoined exists and values are NOT in the desired state' -Fixture {
            BeforeAll {
                $testParams = @{
                    Description                            = 'FakeStringValue'
                    DeviceNameTemplate                     = 'FakeStringValue'
                    DeviceType                             = 'windowsPc'
                    DisplayName                            = 'FakeStringValue'
                    PreprovisioningAllowed                       = $True
                    EnrollmentStatusScreenSettings         = ([MSFT_MicrosoftGraphwindowsEnrollmentStatusScreenSettings] @{
                            HideInstallationProgress                         = $True
                            BlockDeviceSetupRetryByUser                      = $True
                            AllowLogCollectionOnInstallFailure               = $True
                            AllowDeviceUseBeforeProfileAndAppInstallComplete = $True
                            InstallProgressTimeoutInMinutes                  = 30 # Updated property
                            CustomErrorMessage                               = 'FakeStringValue'
                            AllowDeviceUseOnInstallFailure                   = $True
                        })
                    HardwareHashExtractionEnabled                    = $True
                    HybridAzureADJoinSkipConnectivityCheck = $True
                    Id                                     = 'FakeStringValue'
                    Locale                               = 'FakeStringValue'
                    ManagementServiceAppId                 = 'FakeStringValue'
                    OutOfBoxExperienceSetting              = ([MSFT_MicrosoftGraphoutOfBoxExperienceSetting] @{
                        DeviceUsageType              = 'singleUser'
                        EscapeLinkHidden             = $True
                        EulaHidden                   = $True
                        KeyboardSelectionPageSkipped = $True
                        PrivacySettingsHidden        = $True
                        UserType                     = 'administrator'
                    })
                    Ensure                                 = 'Present'
                    Credential                             = $Credential
                }
            }

            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'IntuneWindowsAutopilotDeploymentProfileAzureADHybridJoined' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneWindowsAutopilotDeploymentProfileAzureADHybridJoined' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should call the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneWindowsAutopilotDeploymentProfileAzureADHybridJoined' -Property $testParams).Set()
                Should -Invoke -CommandName Update-MgBetaDeviceManagementWindowsAutopilotDeploymentProfile -Exactly 1
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
                $result = Invoke-M365DSCResourceMethod -ResourceName 'IntuneWindowsAutopilotDeploymentProfileAzureADHybridJoined' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
