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
    -DscResource 'IntuneDeviceEnrollmentPlatformRestriction' -GenericStubModule $GenericStubPath

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

            Mock -CommandName Update-MgBetaDeviceManagementDeviceEnrollmentConfiguration -MockWith {
            }

            Mock -CommandName New-MgBetaDeviceManagementDeviceEnrollmentConfiguration -MockWith {
            }
            Mock -CommandName Update-DeviceConfigurationPolicyAssignment -MockWith {
            }
            Mock -CommandName Remove-MgBetaDeviceManagementDeviceEnrollmentConfiguration -MockWith {
            }

            Mock -CommandName Get-M365DSCExportCachedCollection -MockWith {
                return Get-MgBetaDeviceManagementDeviceEnrollmentConfiguration
            }
            Mock -CommandName Get-MgBetaDeviceManagementDeviceEnrollmentConfiguration -MockWith {
                return @{
                    '@odata.type'       = '#microsoft.graph.deviceEnrollmentPlatformRestrictionConfiguration'
                    PlatformRestriction = @{
                        PersonalDeviceEnrollmentBlocked = $False
                        PlatformBlocked                 = $False
                    }
                    platformType        = 'ios'
                    id                                = '12345-12345-12345-12345-12345_SinglePlatformRestriction'
                    DeviceEnrollmentConfigurationType = 'singlePlatformRestriction'
                    Description                       = ''
                    DisplayName                       = 'My DSC Restriction'
                    Priority                          = 1
                }
            }

            Mock -CommandName Get-MgBetaDeviceManagementDeviceEnrollmentConfigurationAssignment -MockWith {
                return @()
            }

            Mock -CommandName Write-M365DSCHost -MockWith {
            }
        }

        # Test contexts
        Context -Name "When the restriction doesn't already exist" -Fixture {
            BeforeAll {
                $testParams = @{
                    Id                                = '12345-12345-12345-12345-12345_SinglePlatformRestriction'
                    Description                       = ''
                    DisplayName                       = 'My DSC Restriction'
                    Ensure                            = 'Present'
                    DeviceEnrollmentConfigurationType = 'singlePlatformRestriction'
                    Credential                        = $Credential
                    Priority                          = 1
                    IosRestriction                    = ([MSFT_DeviceEnrollmentPlatformRestriction] @{
                            platformBlocked                 = $False
                            personalDeviceEnrollmentBlocked = $False
                        })
                }

                Mock -CommandName Get-MgBetaDeviceManagementDeviceEnrollmentConfiguration -MockWith {
                    return $null
                }

                Mock -CommandName New-MgBetaDeviceManagementDeviceEnrollmentConfiguration -MockWith {
                    return @{
                        '@odata.type'       = '#microsoft.graph.deviceEnrollmentPlatformRestrictionConfiguration'
                        PlatformRestriction = @{
                            PersonalDeviceEnrollmentBlocked = $False
                            PlatformBlocked                 = $False
                        }
                        platformType        = 'ios'
                        id                                = '12345-12345-12345-12345-12345_SinglePlatformRestriction'
                        DeviceEnrollmentConfigurationType = 'singlePlatformRestriction'
                        Description                       = ''
                        DisplayName                       = 'My DSC Restriction'
                        Priority                          = 1
                    }
                }
            }

            It 'Should return absent from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'IntuneDeviceEnrollmentPlatformRestriction' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Absent'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneDeviceEnrollmentPlatformRestriction' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should create the restriction from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneDeviceEnrollmentPlatformRestriction' -Property $testParams).Set()
                Should -Invoke -CommandName 'New-MgBetaDeviceManagementDeviceEnrollmentConfiguration' -Exactly 1 -ParameterFilter {
                    $BodyParameter.platformType -eq 'ios' -and $null -ne $BodyParameter.platformRestriction
                }
            }
        }

        Context -Name 'When the restriction already exists and is in the Desired State' -Fixture {
            BeforeAll {
                $testParams = @{
                    Id                                = '12345-12345-12345-12345-12345_SinglePlatformRestriction'
                    Description                       = ''
                    DisplayName                       = 'My DSC Restriction'
                    Ensure                            = 'Present'
                    DeviceEnrollmentConfigurationType = 'singlePlatformRestriction'
                    Credential                        = $Credential
                    Priority                          = 1
                    IosRestriction                    = ([MSFT_DeviceEnrollmentPlatformRestriction] @{
                            platformBlocked                 = $False
                            personalDeviceEnrollmentBlocked = $False
                        })
                }

                Mock -CommandName Get-MgBetaDeviceManagementDeviceEnrollmentConfiguration -ParameterFilter { -not [System.String]::IsNullOrEmpty($DeviceEnrollmentConfigurationId) } -MockWith {
                    return $null
                }
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneDeviceEnrollmentPlatformRestriction' -Property $testParams).Test() | Should -Be $true
                Should -Invoke -CommandName Get-MgBetaDeviceManagementDeviceEnrollmentConfiguration -ParameterFilter { $Filter -eq "DisplayName eq 'My DSC Restriction'" }
            }
        }

        Context -Name 'When the restriction already exists and is NOT in the Desired State' -Fixture {
            BeforeAll {
                $testParams = @{
                    Id                                = '12345-12345-12345-12345-12345_SinglePlatformRestriction'
                    Description                       = ''
                    DisplayName                       = 'My DSC Restriction'
                    Ensure                            = 'Present'
                    DeviceEnrollmentConfigurationType = 'singlePlatformRestriction'
                    Credential                        = $Credential
                    Priority                          = 1
                    IosRestriction                    = ([MSFT_DeviceEnrollmentPlatformRestriction] @{
                            platformBlocked                 = $False
                            personalDeviceEnrollmentBlocked = $True # Updated property
                        })
                }
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneDeviceEnrollmentPlatformRestriction' -Property $testParams).Test() | Should -Be $false
            }
        }

        Context -Name 'When the restriction exists and it SHOULD NOT' -Fixture {
            BeforeAll {
                $testParams = @{
                    Id                                = '12345-12345-12345-12345-12345_SinglePlatformRestriction'
                    Description                       = ''
                    DisplayName                       = 'My DSC Restriction'
                    Ensure                            = 'Absent'
                    DeviceEnrollmentConfigurationType = 'singlePlatformRestriction'
                    Credential                        = $Credential
                    Priority                          = 1
                    IosRestriction                    = ([MSFT_DeviceEnrollmentPlatformRestriction] @{
                            platformBlocked                 = $False
                            personalDeviceEnrollmentBlocked = $False
                        })
                }
            }

            It 'Should return Present from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'IntuneDeviceEnrollmentPlatformRestriction' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneDeviceEnrollmentPlatformRestriction' -Property $testParams).Test()| Should -Be $false
            }

            It 'Should remove the restriction from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneDeviceEnrollmentPlatformRestriction' -Property $testParams).Set()
                Should -Invoke -CommandName Remove-MgBetaDeviceManagementDeviceEnrollmentConfiguration -Exactly 1
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
                $result = Invoke-M365DSCResourceMethod -ResourceName 'IntuneDeviceEnrollmentPlatformRestriction' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
