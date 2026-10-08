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

            Mock -CommandName New-M365DSCConnection -ModuleName '_Shared' -MockWith {
                return "Credentials"
            }

            Mock -CommandName Get-MgBetaDeviceManagementMobileThreatDefenseConnector -MockWith {
            }

            Mock -CommandName New-MgBetaDeviceManagementMobileThreatDefenseConnector -MockWith {
            }

            Mock -CommandName Update-MgBetaDeviceManagementMobileThreatDefenseConnector -MockWith {
            }

            Mock -CommandName Remove-MgBetaDeviceManagementMobileThreatDefenseConnector -MockWith {
            }

            # Mock Write-M365DSCHost to hide output during the tests
            Mock -CommandName Write-M365DSCHost -MockWith {
            }
            $Script:exportedInstances =$null
            $Script:ExportMode = $false
        }

        # Test contexts

        Context -Name " 1. The instance should exist but it DOES NOT" -Fixture {
            BeforeAll {
                $testParams = @{
                    AllowPartnerToCollectIOSApplicationMetadata         = $False;
                    AllowPartnerToCollectIosCertificateMetadata         = $False;
                    AllowPartnerToCollectIosPersonalApplicationMetadata = $False;
                    AllowPartnerToCollectIosPersonalCertificateMetadata = $False;
                    AndroidDeviceBlockedOnMissingPartnerData            = $False;
                    AndroidEnabled                                      = $False;
                    AndroidMobileApplicationManagementEnabled           = $False;
                    GrantMobileThreatDefensePartnerRole                 = $False;
                    Id                                                  = "2c7790de-8b02-4814-85cf-e0c59380dee8";
                    IosDeviceBlockedOnMissingPartnerData                = $False;
                    IosEnabled                                          = $False;
                    IosMobileApplicationManagementEnabled               = $False;
                    LaunchMobileThreatDefensePartnerOnSetupEnabled      = $False;
                    MacDeviceBlockedOnMissingPartnerData                = $False;
                    MacEnabled                                          = $False;
                    MicrosoftDefenderForEndpointAttachEnabled           = $False;
                    PartnerState                                        = "available";
                    PartnerUnresponsivenessThresholdInDays              = 0;
                    PartnerUnsupportedOsVersionBlocked                  = $False;
                    WindowsDeviceBlockedOnMissingPartnerData            = $False;
                    WindowsEnabled                                      = $False;
                    WindowsMobileApplicationManagementEnabled           = $False;
                    Ensure                                              = 'Present'
                    Credential                                          = $Credential;
                }

                Mock -CommandName Get-MgBetaDeviceManagementMobileThreatDefenseConnector -MockWith {
                    return $null
                }
            }

            It ' 1.1 Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'IntuneMobileThreatDefenseConnector' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Absent'
            }
            It ' 1.2 Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneMobileThreatDefenseConnector' -Property $testParams).Test() | Should -Be $false
            }
            It ' 1.3 Should create a new instance from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneMobileThreatDefenseConnector' -Property $testParams).Set()
                Should -Invoke -CommandName New-MgBetaDeviceManagementMobileThreatDefenseConnector -Exactly 1
            }
        }

        Context -Name " 2. The instance exists but it SHOULD NOT" -Fixture {
            BeforeAll {
                $testParams = @{
                    AllowPartnerToCollectIOSApplicationMetadata         = $False;
                    AllowPartnerToCollectIosCertificateMetadata         = $False;
                    AllowPartnerToCollectIosPersonalApplicationMetadata = $False;
                    AllowPartnerToCollectIosPersonalCertificateMetadata = $False;
                    AndroidDeviceBlockedOnMissingPartnerData            = $False;
                    AndroidEnabled                                      = $False;
                    AndroidMobileApplicationManagementEnabled           = $False;
                    GrantMobileThreatDefensePartnerRole                 = $False;
                    Id                                                  = "2c7790de-8b02-4814-85cf-e0c59380dee8";
                    IosDeviceBlockedOnMissingPartnerData                = $False;
                    IosEnabled                                          = $False;
                    IosMobileApplicationManagementEnabled               = $False;
                    LaunchMobileThreatDefensePartnerOnSetupEnabled      = $False;
                    MacDeviceBlockedOnMissingPartnerData                = $False;
                    MacEnabled                                          = $False;
                    MicrosoftDefenderForEndpointAttachEnabled           = $False;
                    PartnerState                                        = "available";
                    PartnerUnresponsivenessThresholdInDays              = 0;
                    PartnerUnsupportedOsVersionBlocked                  = $False;
                    WindowsDeviceBlockedOnMissingPartnerData            = $False;
                    WindowsEnabled                                      = $False;
                    WindowsMobileApplicationManagementEnabled           = $False;
                    Ensure              = 'Absent'
                    Credential          = $Credential;
                }

                Mock -CommandName Get-MgBetaDeviceManagementMobileThreatDefenseConnector -MockWith {
                    return @{
                        AllowPartnerToCollectIOSApplicationMetadata         = $False;
                        AllowPartnerToCollectIosCertificateMetadata         = $False;
                        AllowPartnerToCollectIosPersonalApplicationMetadata = $False;
                        AllowPartnerToCollectIosPersonalCertificateMetadata = $False;
                        AndroidDeviceBlockedOnMissingPartnerData            = $False;
                        AndroidEnabled                                      = $False;
                        AndroidMobileApplicationManagementEnabled           = $False;
                        GrantMobileThreatDefensePartnerRole                 = $False;
                        Id                                                  = "2c7790de-8b02-4814-85cf-e0c59380dee8";
                        IosDeviceBlockedOnMissingPartnerData                = $False;
                        IosEnabled                                          = $False;
                        IosMobileApplicationManagementEnabled               = $False;
                        LaunchMobileThreatDefensePartnerOnSetupEnabled      = $False;
                        MacDeviceBlockedOnMissingPartnerData                = $False;
                        MacEnabled                                          = $False;
                        MicrosoftDefenderForEndpointAttachEnabled           = $False;
                        PartnerState                                        = "available";
                        PartnerUnresponsivenessThresholdInDays              = 0;
                        PartnerUnsupportedOsVersionBlocked                  = $False;
                        WindowsDeviceBlockedOnMissingPartnerData            = $False;
                        WindowsEnabled                                      = $False;
                        WindowsMobileApplicationManagementEnabled           = $False;
                    }
                }
            }

            It ' 2.1 Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'IntuneMobileThreatDefenseConnector' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }
            It ' 2.2 Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneMobileThreatDefenseConnector' -Property $testParams).Test() | Should -Be $false
            }
            It ' 2.3 Should remove the instance from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneMobileThreatDefenseConnector' -Property $testParams).Set()
                Should -Invoke -CommandName Remove-MgBetaDeviceManagementMobileThreatDefenseConnector -Exactly 1
            }
        }

        Context -Name " 3. The instance exists and values are already in the desired state" -Fixture {
            BeforeAll {
                $testParams = @{
                    AllowPartnerToCollectIOSApplicationMetadata         = $False;
                    AllowPartnerToCollectIosCertificateMetadata         = $False;
                    AllowPartnerToCollectIosPersonalApplicationMetadata = $False;
                    AllowPartnerToCollectIosPersonalCertificateMetadata = $False;
                    AndroidDeviceBlockedOnMissingPartnerData            = $False;
                    AndroidEnabled                                      = $False;
                    AndroidMobileApplicationManagementEnabled           = $False;
                    GrantMobileThreatDefensePartnerRole                 = $False;
                    Id                                                  = "2c7790de-8b02-4814-85cf-e0c59380dee8";
                    IosDeviceBlockedOnMissingPartnerData                = $False;
                    IosEnabled                                          = $False;
                    IosMobileApplicationManagementEnabled               = $False;
                    LaunchMobileThreatDefensePartnerOnSetupEnabled      = $False;
                    MacDeviceBlockedOnMissingPartnerData                = $False;
                    MacEnabled                                          = $False;
                    MicrosoftDefenderForEndpointAttachEnabled           = $False;
                    PartnerState                                        = "available";
                    PartnerUnresponsivenessThresholdInDays              = 0;
                    PartnerUnsupportedOsVersionBlocked                  = $False;
                    WindowsDeviceBlockedOnMissingPartnerData            = $False;
                    WindowsEnabled                                      = $False;
                    WindowsMobileApplicationManagementEnabled           = $False;
                    Ensure              = 'Present'
                    Credential          = $Credential;
                }

                Mock -CommandName Get-MgBetaDeviceManagementMobileThreatDefenseConnector -MockWith {
                    return @{
                        AllowPartnerToCollectIOSApplicationMetadata         = $False;
                        AllowPartnerToCollectIosCertificateMetadata         = $False;
                        AllowPartnerToCollectIosPersonalApplicationMetadata = $False;
                        AllowPartnerToCollectIosPersonalCertificateMetadata = $False;
                        AndroidDeviceBlockedOnMissingPartnerData            = $False;
                        AndroidEnabled                                      = $False;
                        AndroidMobileApplicationManagementEnabled           = $False;
                        GrantMobileThreatDefensePartnerRole                 = $False;
                        Id                                                  = "2c7790de-8b02-4814-85cf-e0c59380dee8";
                        IosDeviceBlockedOnMissingPartnerData                = $False;
                        IosEnabled                                          = $False;
                        IosMobileApplicationManagementEnabled               = $False;
                        LaunchMobileThreatDefensePartnerOnSetupEnabled      = $False;
                        MacDeviceBlockedOnMissingPartnerData                = $False;
                        MacEnabled                                          = $False;
                        MicrosoftDefenderForEndpointAttachEnabled           = $False;
                        PartnerState                                        = "available";
                        PartnerUnresponsivenessThresholdInDays              = 0;
                        PartnerUnsupportedOsVersionBlocked                  = $False;
                        WindowsDeviceBlockedOnMissingPartnerData            = $False;
                        WindowsEnabled                                      = $False;
                        WindowsMobileApplicationManagementEnabled           = $False;
                    }
                }
            }

            It ' 3.0 Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneMobileThreatDefenseConnector' -Property $testParams).Test() | Should -Be $true
            }
        }

        Context -Name " 4. The instance exists and values are NOT in the desired state" -Fixture {
            BeforeAll {
                $testParams = @{
                    AllowPartnerToCollectIOSApplicationMetadata         = $False;
                    AllowPartnerToCollectIosCertificateMetadata         = $True; #drift
                    AllowPartnerToCollectIosPersonalApplicationMetadata = $False;
                    AllowPartnerToCollectIosPersonalCertificateMetadata = $True; #drift
                    AndroidDeviceBlockedOnMissingPartnerData            = $False;
                    AndroidEnabled                                      = $False;
                    AndroidMobileApplicationManagementEnabled           = $False;
                    GrantMobileThreatDefensePartnerRole                 = $True; #drift
                    Id                                                  = "2c7790de-8b02-4814-85cf-e0c59380dee8";
                    IosDeviceBlockedOnMissingPartnerData                = $False;
                    IosEnabled                                          = $False;
                    IosMobileApplicationManagementEnabled               = $False;
                    LaunchMobileThreatDefensePartnerOnSetupEnabled      = $True; #drift
                    MacDeviceBlockedOnMissingPartnerData                = $False;
                    MacEnabled                                          = $False;
                    MicrosoftDefenderForEndpointAttachEnabled           = $False;
                    PartnerState                                        = "notSetUp"; #drift
                    PartnerUnresponsivenessThresholdInDays              = 1; #drift
                    PartnerUnsupportedOsVersionBlocked                  = $False;
                    WindowsDeviceBlockedOnMissingPartnerData            = $False;
                    WindowsEnabled                                      = $False;
                    WindowsMobileApplicationManagementEnabled           = $True; #drift
                    Ensure              = 'Present'
                    Credential          = $Credential;
                }

                Mock -CommandName Get-MgBetaDeviceManagementMobileThreatDefenseConnector -MockWith {
                    return @{
                        AllowPartnerToCollectIOSApplicationMetadata         = $False;
                        AllowPartnerToCollectIosCertificateMetadata         = $False;
                        AllowPartnerToCollectIosPersonalApplicationMetadata = $False;
                        AllowPartnerToCollectIosPersonalCertificateMetadata = $False;
                        AndroidDeviceBlockedOnMissingPartnerData            = $False;
                        AndroidEnabled                                      = $False;
                        AndroidMobileApplicationManagementEnabled           = $False;
                        GrantMobileThreatDefensePartnerRole                 = $False;
                        Id                                                  = "2c7790de-8b02-4814-85cf-e0c59380dee8";
                        IosDeviceBlockedOnMissingPartnerData                = $False;
                        IosEnabled                                          = $False;
                        IosMobileApplicationManagementEnabled               = $False;
                        LaunchMobileThreatDefensePartnerOnSetupEnabled      = $False;
                        MacDeviceBlockedOnMissingPartnerData                = $False;
                        MacEnabled                                          = $False;
                        MicrosoftDefenderForEndpointAttachEnabled           = $False;
                        PartnerState                                        = "available";
                        PartnerUnresponsivenessThresholdInDays              = 0;
                        PartnerUnsupportedOsVersionBlocked                  = $False;
                        WindowsDeviceBlockedOnMissingPartnerData            = $False;
                        WindowsEnabled                                      = $False;
                        WindowsMobileApplicationManagementEnabled           = $False;
                    }
                }
            }

            It ' 4.1 Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'IntuneMobileThreatDefenseConnector' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It ' 4.2 Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneMobileThreatDefenseConnector' -Property $testParams).Test() | Should -Be $false
            }

            It ' 4.3 Should call the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneMobileThreatDefenseConnector' -Property $testParams).Set()
                Should -Invoke -CommandName Update-MgBetaDeviceManagementMobileThreatDefenseConnector -Exactly 1
            }
        }

        Context -Name ' 5. ReverseDSC Tests' -Fixture {
            BeforeAll {
                $Global:CurrentModeIsExport = $true
                $Global:PartialExportFileName = "$(New-Guid).partial.ps1"
                $testParams = @{
                    Credential  = $Credential;
                }

                Mock -CommandName Get-MgBetaDeviceManagementMobileThreatDefenseConnector -MockWith {
                    return @{
                        AllowPartnerToCollectIOSApplicationMetadata         = $False;
                        AllowPartnerToCollectIosCertificateMetadata         = $False;
                        AllowPartnerToCollectIosPersonalApplicationMetadata = $False;
                        AllowPartnerToCollectIosPersonalCertificateMetadata = $False;
                        AndroidDeviceBlockedOnMissingPartnerData            = $False;
                        AndroidEnabled                                      = $False;
                        AndroidMobileApplicationManagementEnabled           = $False;
                        GrantMobileThreatDefensePartnerRole                 = $False;
                        Id                                                  = "2c7790de-8b02-4814-85cf-e0c59380dee8";
                        IosDeviceBlockedOnMissingPartnerData                = $False;
                        IosEnabled                                          = $False;
                        IosMobileApplicationManagementEnabled               = $False;
                        LaunchMobileThreatDefensePartnerOnSetupEnabled      = $False;
                        MacDeviceBlockedOnMissingPartnerData                = $False;
                        MacEnabled                                          = $False;
                        MicrosoftDefenderForEndpointAttachEnabled           = $False;
                        PartnerState                                        = "available";
                        PartnerUnresponsivenessThresholdInDays              = 0;
                        PartnerUnsupportedOsVersionBlocked                  = $False;
                        WindowsDeviceBlockedOnMissingPartnerData            = $False;
                        WindowsEnabled                                      = $False;
                        WindowsMobileApplicationManagementEnabled           = $False;
                        LastHeartbeatDateTime                               = "1/1/0001 12:00:00 AM";
                    }
                }
            }
            It ' 5.0 Should Reverse Engineer resource from the Export method' {
                $result = Invoke-M365DSCResourceMethod -ResourceName 'IntuneMobileThreatDefenseConnector' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
