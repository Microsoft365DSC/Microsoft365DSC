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

$CurrentScriptPath = $PSCommandPath.Split('\')
$CurrentScriptName = $CurrentScriptPath[$CurrentScriptPath.Length -1]
$ResourceName      = $CurrentScriptName.Split('.')[1]
$Global:DscHelper = New-M365DscUnitTestHelper -StubModule $CmdletModule `
    -DscResource $ResourceName -GenericStubModule $GenericStubPath

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

            Mock -CommandName New-M365DSCConnection -ModuleName '_Shared' -MockWith {
                return "Credentials"
            }

             # Mock Write-M365DSCHost to hide output during the tests
            Mock -CommandName Write-M365DSCHost -MockWith {
            }

            Mock -CommandName Get-MgBetaDeviceManagementApplePushNotificationCertificate -MockWith {
                return @{
                    AppleIdentifier          = "Apple ID";
                    Certificate              = "Test cert";
                    Id                       = "66f4ec83-754f-4a59-a73d-e3182cc636a5";
                }
            }

            Mock -CommandName Get-MgBetaDeviceManagementDataSharingConsent -MockWith {
                return @{
                    DataSharingConsentId = "appleMDMPushCertificate"
                    Granted              = $True;
                }
            }

            Mock -CommandName Update-MgBetaDeviceManagementApplePushNotificationCertificate -MockWith {
            }

            Mock -CommandName Invoke-M365DSCGraphRequest -MockWith {
            }

            $Script:exportedInstance = $null
            $Script:ExportMode = $false
        }

        #Test contexts

        Context -Name '1. The instance should exist but it DOES NOT' -Fixture {
            BeforeAll {
                $testParams = @{
                    AppleIdentifier         = "Apple ID";
                    Certificate             = "Test cert";
                    DataSharingConsentGranted = $True;
                    Ensure                  = 'Present';
                    Credential              = $Credential;
                }

                Mock -CommandName Get-MgBetaDeviceManagementApplePushNotificationCertificate -MockWith {
                    return $null
                }

                Mock -CommandName Get-MgBetaDeviceManagementDataSharingConsent -MockWith {
                    return @{
                        DataSharingConsentId = "appleMDMPushCertificate"
                        Granted              = $false;
                    }
                }
            }

            It '1.1 Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'IntuneAppleMDMPushNotificationCertificate' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Absent'
            }
            It '1.2 Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneAppleMDMPushNotificationCertificate' -Property $testParams).Test() | Should -Be $false
            }
            It '1.3 Should create a new instance from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneAppleMDMPushNotificationCertificate' -Property $testParams).Set()
                Should -Invoke -CommandName Update-MgBetaDeviceManagementApplePushNotificationCertificate -Exactly 1
            }
            It '1.4 Should return the live data sharing consent value from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'IntuneAppleMDMPushNotificationCertificate' -Property $testParams).Get().ToHashtable()).DataSharingConsentGranted | Should -Be $false
            }
            It '1.5 Should grant the data sharing consent from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneAppleMDMPushNotificationCertificate' -Property $testParams).Set()
                Should -Invoke -CommandName Invoke-M365DSCGraphRequest -Exactly 1 -ParameterFilter {
                    $Method -eq 'POST' -and $Uri -eq '/beta/deviceManagement/dataSharingConsents/appleMDMPushCertificate/consentToDataSharing'
                }
            }
        }

        Context -Name '1b. The instance should exist and the data sharing consent should NOT be granted' -Fixture {
            BeforeAll {
                $testParams = @{
                    AppleIdentifier          = "Apple ID";
                    Certificate              = "Test cert";
                    DataSharingConsentGranted = $false;
                    Ensure                   = 'Present';
                    Credential               = $Credential;
                }

                Mock -CommandName Get-MgBetaDeviceManagementApplePushNotificationCertificate -MockWith {
                    return $null
                }

                Mock -CommandName Get-MgBetaDeviceManagementDataSharingConsent -MockWith {
                    return @{
                        DataSharingConsentId = "appleMDMPushCertificate"
                        Granted              = $false;
                    }
                }
            }

            It '1b.1 Should create a new instance from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneAppleMDMPushNotificationCertificate' -Property $testParams).Set()
                Should -Invoke -CommandName Update-MgBetaDeviceManagementApplePushNotificationCertificate -Exactly 1
            }
            It '1b.2 Should not grant the data sharing consent from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneAppleMDMPushNotificationCertificate' -Property $testParams).Set()
                Should -Invoke -CommandName Invoke-M365DSCGraphRequest -Exactly 0 -ParameterFilter {
                    $Uri -eq '/beta/deviceManagement/dataSharingConsents/appleMDMPushCertificate/consentToDataSharing'
                }
            }
        }

        Context -Name '1c. The instance should exist and the data sharing consent is not declared' -Fixture {
            BeforeAll {
                $testParams = @{
                    AppleIdentifier = "Apple ID";
                    Certificate     = "Test cert";
                    Ensure          = 'Present';
                    Credential      = $Credential;
                }

                Mock -CommandName Get-MgBetaDeviceManagementApplePushNotificationCertificate -MockWith {
                    return $null
                }

                Mock -CommandName Get-MgBetaDeviceManagementDataSharingConsent -MockWith {
                    return @{
                        DataSharingConsentId = "appleMDMPushCertificate"
                        Granted              = $false;
                    }
                }
            }

            It '1c.1 Should grant the data sharing consent from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneAppleMDMPushNotificationCertificate' -Property $testParams).Set()
                Should -Invoke -CommandName Invoke-M365DSCGraphRequest -Exactly 1 -ParameterFilter {
                    $Method -eq 'POST' -and $Uri -eq '/beta/deviceManagement/dataSharingConsents/appleMDMPushCertificate/consentToDataSharing'
                }
            }
        }

        Context -Name '2. The instance exists but it SHOULD NOT' -Fixture {
            BeforeAll {
                $testParams = @{
                    AppleIdentifier             = "Apple ID";
                    Certificate                 = "Test cert";
                    DataSharingConsentGranted    = $True;
                    Ensure          = 'Absent'
                    Credential      = $Credential
                }
            }

            It '2.1 Should return values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'IntuneAppleMDMPushNotificationCertificate' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }
            It '2.2 Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneAppleMDMPushNotificationCertificate' -Property $testParams).Test() | Should -Be $false
            }
            It '2.3 Should remove the instance from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneAppleMDMPushNotificationCertificate' -Property $testParams).Set()
                Should -Invoke -CommandName Update-MgBetaDeviceManagementApplePushNotificationCertificate -Exactly 1
            }
        }

        Context -Name '3. The instance exists and values are already in the desired state' -Fixture {
            BeforeAll {
                $testParams = @{
                    AppleIdentifier             = "Apple ID";
                    Certificate                 = "Test cert";
                    DataSharingConsentGranted    = $True;
                    Ensure                  = 'Present'
                    Credential              = $Credential
                }
            }

            It '3.0 Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneAppleMDMPushNotificationCertificate' -Property $testParams).Test() | Should -Be $true
            }
        }

        Context -Name '4. The instance exists and values are NOT in the desired state' -Fixture {
            BeforeAll {
                $testParams = @{
                    AppleIdentifier          = "Apple ID";
                    Certificate              = "Patched cert"; # Updated property
                    DataSharingConsentGranted = $True;
                    Ensure                   = 'Present'
                    Credential               = $Credential
                }
            }

            It '4.1 Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'IntuneAppleMDMPushNotificationCertificate' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It '4.2 Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneAppleMDMPushNotificationCertificate' -Property $testParams).Test() | Should -Be $false
            }

            It '4.3 Should call the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneAppleMDMPushNotificationCertificate' -Property $testParams).Set()
                Should -Invoke -CommandName Update-MgBetaDeviceManagementApplePushNotificationCertificate -Exactly 1
            }
        }

        Context -Name '4b. The instance exists and the data sharing consent is NOT granted yet' -Fixture {
            BeforeAll {
                $testParams = @{
                    AppleIdentifier          = "Apple ID";
                    Certificate              = "Test cert";
                    DataSharingConsentGranted = $True;
                    Ensure                   = 'Present'
                    Credential               = $Credential
                }

                Mock -CommandName Get-MgBetaDeviceManagementDataSharingConsent -MockWith {
                    return @{
                        DataSharingConsentId = "appleMDMPushCertificate"
                        Granted              = $false;
                    }
                }
            }

            It '4b.1 Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneAppleMDMPushNotificationCertificate' -Property $testParams).Test() | Should -Be $false
            }

            It '4b.2 Should grant the data sharing consent from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneAppleMDMPushNotificationCertificate' -Property $testParams).Set()
                Should -Invoke -CommandName Invoke-M365DSCGraphRequest -Exactly 1 -ParameterFilter {
                    $Method -eq 'POST' -and $Uri -eq '/beta/deviceManagement/dataSharingConsents/appleMDMPushCertificate/consentToDataSharing'
                }
            }
        }

        Context -Name '4c. The instance exists and the data sharing consent is not declared' -Fixture {
            BeforeAll {
                $testParams = @{
                    AppleIdentifier = "Apple ID";
                    Certificate     = "Patched cert";
                    Ensure          = 'Present'
                    Credential      = $Credential
                }

                Mock -CommandName Get-MgBetaDeviceManagementDataSharingConsent -MockWith {
                    return @{
                        DataSharingConsentId = "appleMDMPushCertificate"
                        Granted              = $false;
                    }
                }
            }

            It '4c.1 Should not grant the data sharing consent from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneAppleMDMPushNotificationCertificate' -Property $testParams).Set()
                Should -Invoke -CommandName Invoke-M365DSCGraphRequest -Exactly 0 -ParameterFilter {
                    $Uri -eq '/beta/deviceManagement/dataSharingConsents/appleMDMPushCertificate/consentToDataSharing'
                }
            }
        }

        Context -Name '5. ReverseDSC Tests' -Fixture {
            BeforeAll {
                $Global:CurrentModeIsExport = $true
                $Global:PartialExportFileName = "$(New-Guid).partial.ps1"
                $testParams = @{
                    Credential  = $Credential
                }
            }

            It '5.0 Should Reverse Engineer resource from the Export method' {
                $result = Invoke-M365DSCResourceMethod -ResourceName 'IntuneAppleMDMPushNotificationCertificate' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
