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
    -DscResource "AADDeviceRegistrationPolicy" -GenericStubModule $GenericStubPath
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

            Mock -CommandName Update-MgBetaDirectoryAttributeSet -MockWith {
            }

            Mock -CommandName Remove-MgBetaDirectoryAttributeSet -MockWith {
            }

            Mock -CommandName Get-MgBetaPolicyDeviceRegistrationPolicy -MockWith {
                return @{
                    AzureAdJoin = @{
                        IsAdminConfigurable = $true
                        AllowedToJoin = @{
                            "@odata.type" = "#microsoft.graph.allDeviceRegistrationMembership"
                        }
                        LocalAdmins = @{
                            EnableGlobalAdmins = $true
                            RegisteringUsers = @{
                                "@odata.type" = "#microsoft.graph.enumeratedDeviceRegistrationMembership"
                                users = @('12345-12345-12345-12345-12345')
                                groups = @()
                            }
                        }
                    }
                    AzureADRegistration = @{
                        IsAdminConfigurable = $false
                        AllowedToRegister = @{
                            "@odata.type" = "#microsoft.graph.allDeviceRegistrationMembership"
                        }
                    }
                    Description = "Tenant-wide policy that manages initial provisioning controls using quota restrictions, additional authentication and authorization checks"
                    DisplayName = "Device Registration Policy"
                    Id = "deviceRegistrationPolicy"
                    LocalAdminPassword = @{
                        IsEnabled = $false
                    }
                    MultiFactorAuthConfiguration = "notRequired"
                    UserDeviceQuota = 50
                }
            }

            Mock -CommandName Get-MgUser -MockWith {
                return @{
                    id = '12345-12345-12345-12345-12345'
                    UserPrincipalName = "john.smith@contoso.com"
                }
            }

            Mock -CommandName Invoke-M365DSCGraphRequest -MockWith {
                return $null
            }

            Mock -CommandName New-M365DSCConnection -ModuleName '_Shared' -MockWith {
                return "Credentials"
            }

            # Mock Write-M365DSCHost to hide output during the tests
            Mock -CommandName Write-M365DSCHost -MockWith {
            }
            $Script:exportedInstances =$null
            $Script:ExportMode = $false
        }

        Context -Name "The instance exists and values are already in the desired state" -Fixture {
            BeforeAll {
                $testParams = @{
                    AzureADAllowedToJoin                    = "All";
                    AzureADAllowedToJoinGroups              = @();
                    AzureADAllowedToJoinUsers               = @();
                    AzureAdJoinLocalAdminsRegisteringGroups = @();
                    AzureAdJoinLocalAdminsRegisteringMode   = "Selected";
                    AzureAdJoinLocalAdminsRegisteringUsers  = @("john.smith@contoso.com");
                    AzureADRegistration                     = ([MSFT_AzureADRegistrationPolicy] @{
                        AllowedToRegister   = ([MSFT_DeviceRegistrationMembership] @{
                            Groups    = @()
                            Users     = @()
                            odataType = "#microsoft.graph.allDeviceRegistrationMembership"
                        })
                        IsAdminConfigurable = $False
                    });
                    IsSingleInstance                        = "Yes";
                    LocalAdminPasswordIsEnabled             = $False;
                    LocalAdminsEnableGlobalAdmins           = $True;
                    MultiFactorAuthConfiguration            = "notRequired";
                    UserDeviceQuota                         = 50;
                    Credential                              = $Credential;
                }
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'AADDeviceRegistrationPolicy' -Property $testParams).Test() | Should -Be $true
            }
        }

        Context -Name "The instance exists and values are NOT in the desired state" -Fixture {
            BeforeAll {
                $testParams = @{
                    AzureADAllowedToJoin                    = "All";
                    AzureADAllowedToJoinGroups              = @();
                    AzureADAllowedToJoinUsers               = @("john.smith@contoso.com");
                    AzureAdJoinLocalAdminsRegisteringGroups = @();
                    AzureAdJoinLocalAdminsRegisteringMode   = "Selected";
                    AzureAdJoinLocalAdminsRegisteringUsers  = @("john.smith@contoso.com");
                    AzureADRegistration                     = ([MSFT_AzureADRegistrationPolicy] @{
                        AllowedToRegister   = ([MSFT_DeviceRegistrationMembership] @{
                            Groups    = @()
                            Users     = @()
                            odataType = "#microsoft.graph.allDeviceRegistrationMembership"
                        })
                        IsAdminConfigurable = $False
                    });
                    IsSingleInstance                        = "Yes";
                    LocalAdminPasswordIsEnabled             = $False;
                    LocalAdminsEnableGlobalAdmins           = $False; # drift
                    MultiFactorAuthConfiguration            = "notRequired";
                    UserDeviceQuota                         = 50;
                    Credential                              = $Credential;
                }
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'AADDeviceRegistrationPolicy' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should call the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'AADDeviceRegistrationPolicy' -Property $testParams).Set()
                Should -Invoke -CommandName Invoke-M365DSCGraphRequest -Exactly 1
            }
        }

        Context -Name 'Only LocalAdminPasswordIsEnabled drifts and the other properties are not specified' -Fixture {
            BeforeAll {
                $testParams = @{
                    IsSingleInstance            = 'Yes'
                    LocalAdminPasswordIsEnabled = $true
                    Credential                  = $Credential
                }
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'AADDeviceRegistrationPolicy' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should keep the current values of the properties that are not specified' {
                (New-M365DSCResourceInstance -ResourceName 'AADDeviceRegistrationPolicy' -Property $testParams).Set()
                Should -Invoke -CommandName Invoke-M365DSCGraphRequest -Exactly 1 -ParameterFilter {
                    $Body.localAdminPassword.isEnabled -eq $true -and
                    $Body.userDeviceQuota -eq 50 -and
                    $Body.multiFactorAuthConfiguration -eq 'notRequired' -and
                    $Body.azureADJoin.isAdminConfigurable -eq $true -and
                    $Body.azureADJoin.allowedToJoin.'@odata.type' -eq '#microsoft.graph.allDeviceRegistrationMembership' -and
                    $Body.azureADJoin.localAdmins.enableGlobalAdmins -eq $true -and
                    $Body.azureADJoin.localAdmins.registeringUsers.'@odata.type' -eq '#microsoft.graph.enumeratedDeviceRegistrationMembership'
                }
            }
        }

        Context -Name 'ReverseDSC Tests' -Fixture {
            BeforeAll {
                $Global:CurrentModeIsExport = $true
                $Global:PartialExportFileName = "$(New-Guid).partial.ps1"
                $testParams = @{
                    Credential  = $Credential;
                }
            }
            It 'Should Reverse Engineer resource from the Export method' {
                $result = Invoke-M365DSCResourceMethod -ResourceName 'AADDeviceRegistrationPolicy' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
