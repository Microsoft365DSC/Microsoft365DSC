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
    -DscResource 'IntuneWindowsUpdateForBusinessFeatureUpdateProfileWindows10' -GenericStubModule $GenericStubPath
Describe -Name $Global:DscHelper.DescribeHeader -Fixture {
    InModuleScope -ModuleName $Global:DscHelper.ModuleName -ScriptBlock {
        Invoke-Command -ScriptBlock $Global:DscHelper.InitializeScript -NoNewScope
        BeforeAll {

            $secpasswd = ConvertTo-SecureString (New-GUID).ToString() -AsPlainText -Force
            $Credential = New-Object System.Management.Automation.PSCredential ('tenantadmin@onmicrosoft.com', $secpasswd)

            Mock -ModuleName M365DSCUtil -CommandName Confirm-M365DSCDependencies -MockWith {
            }

            Mock -CommandName Get-MgBetaDeviceManagementWindowsFeatureUpdateProfile -MockWith {
                return @{
                    Description          = 'FakeStringValue'
                    DisplayName          = 'FakeStringValue'
                    FeatureUpdateVersion = 'FakeStringValue'
                    Id                   = 'FakeStringValue'
                    RolloutSettings      = @{
                        OfferStartDateTimeInUTC = '2024-01-05T00:00:00.000Z'
                        OfferEndDateTimeInUTC   = '2024-01-07T00:00:00.000Z'
                        OfferIntervalInDays     = 2
                    }
                }
            }

            Mock -CommandName 'Get-Date' -MockWith {
                return [datetime]::new(2024, 01, 01)
            }

            Mock -CommandName Update-MgBetaDeviceManagementWindowsFeatureUpdateProfile -MockWith {
            }

            Mock -CommandName New-MgBetaDeviceManagementWindowsFeatureUpdateProfile -MockWith {
            }

            Mock -CommandName Remove-MgBetaDeviceManagementWindowsFeatureUpdateProfile -MockWith {
            }

            Mock -CommandName New-M365DSCConnection -ModuleName '_Shared' -MockWith {
                return 'Credentials'
            }

            Mock -CommandName Get-MgBetaDeviceManagementWindowsFeatureUpdateProfileAssignment -MockWith {
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
        Context -Name 'The IntuneWindowsUpdateForBusinessFeatureUpdateProfileWindows10 should exist but it DOES NOT' -Fixture {
            BeforeAll {
                $testParams = @{
                    Description          = 'FakeStringValue'
                    DisplayName          = 'FakeStringValue'
                    FeatureUpdateVersion = 'FakeStringValue'
                    Id                   = 'FakeStringValue'
                    RolloutSettings      = ([MSFT_MicrosoftGraphwindowsUpdateRolloutSettings] @{
                        OfferStartDateTimeInUTC = '2024-01-05T00:00:00.000Z'
                        OfferEndDateTimeInUTC   = '2024-01-07T00:00:00.000Z'
                        OfferIntervalInDays     = 2
                    })
                    Ensure               = 'Present'
                    Credential           = $Credential
                }

                Mock -CommandName Get-MgBetaDeviceManagementWindowsFeatureUpdateProfile -MockWith {
                    return $null
                }
            }
            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'IntuneWindowsUpdateForBusinessFeatureUpdateProfileWindows10' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Absent'
            }
            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneWindowsUpdateForBusinessFeatureUpdateProfileWindows10' -Property $testParams).Test() | Should -Be $false
            }
            It 'Should Create the group from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneWindowsUpdateForBusinessFeatureUpdateProfileWindows10' -Property $testParams).Set()
                Should -Invoke -CommandName New-MgBetaDeviceManagementWindowsFeatureUpdateProfile -Exactly 1
            }
        }

        Context -Name 'The IntuneWindowsUpdateForBusinessFeatureUpdateProfileWindows10 exists but it SHOULD NOT' -Fixture {
            BeforeAll {
                $testParams = @{
                    Description          = 'FakeStringValue'
                    DisplayName          = 'FakeStringValue'
                    FeatureUpdateVersion = 'FakeStringValue'
                    Id                   = 'FakeStringValue'
                    RolloutSettings      = ([MSFT_MicrosoftGraphwindowsUpdateRolloutSettings] @{
                        OfferStartDateTimeInUTC = '2024-01-05T00:00:00.000Z'
                        OfferEndDateTimeInUTC   = '2024-01-07T00:00:00.000Z'
                        OfferIntervalInDays     = 2
                    })
                    Ensure               = 'Absent'
                    Credential           = $Credential
                }
            }

            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'IntuneWindowsUpdateForBusinessFeatureUpdateProfileWindows10' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneWindowsUpdateForBusinessFeatureUpdateProfileWindows10' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should remove the profile from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneWindowsUpdateForBusinessFeatureUpdateProfileWindows10' -Property $testParams).Set()
                Should -Invoke -CommandName Remove-MgBetaDeviceManagementWindowsFeatureUpdateProfile -Exactly 1
            }
        }
        Context -Name 'The IntuneWindowsUpdateForBusinessFeatureUpdateProfileWindows10 exists and values are already in the desired state' -Fixture {
            BeforeAll {
                $testParams = @{
                    Description          = 'FakeStringValue'
                    DisplayName          = 'FakeStringValue'
                    FeatureUpdateVersion = 'FakeStringValue'
                    Id                   = 'FakeStringValue'
                    RolloutSettings      = ([MSFT_MicrosoftGraphwindowsUpdateRolloutSettings] @{
                        OfferStartDateTimeInUTC = '2024-01-05T00:00:00.000Z'
                        OfferEndDateTimeInUTC   = '2024-01-07T00:00:00.000Z'
                        OfferIntervalInDays     = 2
                    })
                    Ensure               = 'Present'
                    Credential           = $Credential
                }
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneWindowsUpdateForBusinessFeatureUpdateProfileWindows10' -Property $testParams).Test() | Should -Be $true
            }
        }

        Context -Name 'The IntuneWindowsUpdateForBusinessFeatureUpdateProfileWindows10 exists and values are NOT in the desired state' -Fixture {
            BeforeAll {
                $testParams = @{
                    Description          = 'FakeStringValue'
                    DisplayName          = 'FakeStringValue'
                    FeatureUpdateVersion = 'FakeStringValue'
                    Id                   = 'FakeStringValue'
                    RolloutSettings      = ([MSFT_MicrosoftGraphwindowsUpdateRolloutSettings] @{
                        OfferStartDateTimeInUTC = '2024-01-05T00:00:00.000Z'
                        OfferEndDateTimeInUTC   = '2024-01-07T00:00:00.000Z'
                        OfferIntervalInDays     = 2
                    })
                    Ensure               = 'Present'
                    Credential           = $Credential
                }

                Mock -CommandName Get-MgBetaDeviceManagementWindowsFeatureUpdateProfile -MockWith {
                    return @{
                        Description          = 'FakeStringValue'
                        DisplayName          = 'FakeStringValue'
                        FeatureUpdateVersion = 'FakeStringValue'
                        Id                   = 'FakeStringValue'
                        RolloutSettings      = @{
                            OfferStartDateTimeInUTC = '2024-01-05T00:00:00.000Z'
                            OfferEndDateTimeInUTC   = '2024-01-07T00:00:00.000Z'
                            OfferIntervalInDays     = 1 #drift
                        }
                    }
                }
            }

            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'IntuneWindowsUpdateForBusinessFeatureUpdateProfileWindows10' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneWindowsUpdateForBusinessFeatureUpdateProfileWindows10' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should call the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneWindowsUpdateForBusinessFeatureUpdateProfileWindows10' -Property $testParams).Set()
                Should -Invoke -CommandName Update-MgBetaDeviceManagementWindowsFeatureUpdateProfile -Exactly 1
            }
        }

        Context -Name 'The IntuneWindowsUpdateForBusinessFeatureUpdateProfileWindows10 exists and the RolloutSettings are NOT in the desired state' -Fixture {
            BeforeAll {
                $testParams = @{
                    Description          = 'FakeStringValue'
                    DisplayName          = 'FakeStringValue'
                    FeatureUpdateVersion = 'FakeStringValue'
                    Id                   = 'FakeStringValue'
                    RolloutSettings      = ([MSFT_MicrosoftGraphwindowsUpdateRolloutSettings] @{
                        OfferStartDateTimeInUTC = '2024-01-05T00:00:00.000Z'
                        OfferEndDateTimeInUTC   = '2024-01-07T00:00:00.000Z'
                        OfferIntervalInDays     = 2
                    })
                    Ensure               = 'Present'
                    Credential           = $Credential
                }
            }

            It 'Should return false from the Test method because OfferEndDateTimeInUTC is missing' {
                Mock -CommandName Get-MgBetaDeviceManagementWindowsFeatureUpdateProfile -MockWith {
                    return @{
                        Description          = 'FakeStringValue'
                        DisplayName          = 'FakeStringValue'
                        FeatureUpdateVersion = 'FakeStringValue'
                        Id                   = 'FakeStringValue'
                        RolloutSettings      = @{
                            OfferStartDateTimeInUTC = '2024-01-07T00:00:00.000Z'
                            OfferEndDateTimeInUTC   = $null
                            OfferIntervalInDays     = $null
                        }
                    }
                }
                (New-M365DSCResourceInstance -ResourceName 'IntuneWindowsUpdateForBusinessFeatureUpdateProfileWindows10' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should return false from the Test method because neither OfferStartDateTimeInUTC nor OfferEndDateTimeInUTC is set' {
                Mock -CommandName Get-MgBetaDeviceManagementWindowsFeatureUpdateProfile -MockWith {
                    return @{
                        Description          = 'FakeStringValue'
                        DisplayName          = 'FakeStringValue'
                        FeatureUpdateVersion = 'FakeStringValue'
                        Id                   = 'FakeStringValue'
                        RolloutSettings      = @{
                            OfferEndDateTimeInUTC   = $null
                            OfferStartDateTimeInUTC = $null
                            OfferIntervalInDays     = $null
                        }
                    }
                }
                (New-M365DSCResourceInstance -ResourceName 'IntuneWindowsUpdateForBusinessFeatureUpdateProfileWindows10' -Property $testParams).Test() | Should -Be $false
            }
        }

        Context -Name 'The IntuneWindowsUpdateForBusinessFeatureUpdateProfileWindows10 exists and RolloutSettings are different but still valid' -Fixture {
            It 'Should return true from the Test method because OfferStartDateTimeInUTC is before the current value and time' {
                $testParams = @{
                    Description          = 'FakeStringValue'
                    DisplayName          = 'FakeStringValue'
                    FeatureUpdateVersion = 'FakeStringValue'
                    Id                   = 'FakeStringValue'
                    RolloutSettings      = ([MSFT_MicrosoftGraphwindowsUpdateRolloutSettings] @{
                        OfferStartDateTimeInUTC = '2024-01-05T00:00:00.000Z'
                        OfferEndDateTimeInUTC   = '2024-01-07T00:00:00.000Z'
                        OfferIntervalInDays     = 2
                    })
                    Ensure               = 'Present'
                    Credential           = $Credential
                }
                Mock -CommandName 'Get-Date' -MockWith {
                    return [datetime]::new(2024, 1, 5)
                }
                (New-M365DSCResourceInstance -ResourceName 'IntuneWindowsUpdateForBusinessFeatureUpdateProfileWindows10' -Property $testParams).Test() | Should -Be $true
            }

            It 'Should return true from the Test method because OfferStartDateTimeInUTC and OfferEndDateTimeInUTC are in the past' {
                $testParams = @{
                    Description          = 'FakeStringValue'
                    DisplayName          = 'FakeStringValue'
                    FeatureUpdateVersion = 'FakeStringValue'
                    Id                   = 'FakeStringValue'
                    RolloutSettings      = ([MSFT_MicrosoftGraphwindowsUpdateRolloutSettings] @{
                        OfferStartDateTimeInUTC = '2024-01-05T00:00:00.000Z'
                        OfferEndDateTimeInUTC   = '2024-01-07T00:00:00.000Z'
                        OfferIntervalInDays     = 2
                    })
                    Ensure               = 'Present'
                    Credential           = $Credential
                }

                Mock -CommandName 'Get-Date' -MockWith {
                    return [datetime]::new(2024, 02, 01)
                }

                (New-M365DSCResourceInstance -ResourceName 'IntuneWindowsUpdateForBusinessFeatureUpdateProfileWindows10' -Property $testParams).Test() | Should -Be $true
            }
        }

        Context -Name 'The IntuneWindowsUpdateForBusinessFeatureUpdateProfileWindows10 exists and RolloutSettings are different and invalid' -Fixture {
            It 'Should throw from the Set method because OfferStartDateTimeInUTC is after OfferEndDateTimeInUTC' {
                $testParams = @{
                    Description          = 'FakeStringValue'
                    DisplayName          = 'FakeStringValue'
                    FeatureUpdateVersion = 'FakeStringValue'
                    Id                   = 'FakeStringValue'
                    RolloutSettings      = ([MSFT_MicrosoftGraphwindowsUpdateRolloutSettings] @{
                        OfferStartDateTimeInUTC = '2024-01-08T00:00:00.000Z'
                        OfferEndDateTimeInUTC   = '2024-01-07T00:00:00.000Z'
                        OfferIntervalInDays     = 2
                    })
                    Ensure               = 'Present'
                    Credential           = $Credential
                }
                { (New-M365DSCResourceInstance -ResourceName 'IntuneWindowsUpdateForBusinessFeatureUpdateProfileWindows10' -Property $testParams).Set() } | Should -Throw 'OfferEndDateTimeInUTC must be greater than OfferStartDateTimeInUTC + 1 day.'
            }

            It 'Should throw from the Set method because OfferStartDateTimeInUTC is adjusted and OfferEndDateTimeInUTC is not greater than that time + 1 day' {
                $testParams = @{
                    Description          = 'FakeStringValue'
                    DisplayName          = 'FakeStringValue'
                    FeatureUpdateVersion = 'FakeStringValue'
                    Id                   = 'FakeStringValue'
                    RolloutSettings      = ([MSFT_MicrosoftGraphwindowsUpdateRolloutSettings] @{
                        OfferStartDateTimeInUTC = '2024-01-05T00:00:00.000Z'
                        OfferEndDateTimeInUTC   = '2024-01-07T00:00:00.000Z'
                        OfferIntervalInDays     = 2
                    })
                    Ensure               = 'Present'
                    Credential           = $Credential
                }
                Mock -CommandName 'Get-Date' -MockWith {
                    return [datetime]::new(2024, 1, 5)
                }
                { (New-M365DSCResourceInstance -ResourceName 'IntuneWindowsUpdateForBusinessFeatureUpdateProfileWindows10' -Property $testParams).Set() } | Should -Throw 'OfferEndDateTimeInUTC must be greater than OfferStartDateTimeInUTC + 1 day.'
            }

            It 'Should throw from the Set method because OfferIntervalInDays is more than the gap between start and end time' {
                $testParams = @{
                    Description          = 'FakeStringValue'
                    DisplayName          = 'FakeStringValue'
                    FeatureUpdateVersion = 'FakeStringValue'
                    Id                   = 'FakeStringValue'
                    RolloutSettings      = ([MSFT_MicrosoftGraphwindowsUpdateRolloutSettings] @{
                        OfferStartDateTimeInUTC = '2024-01-05T00:00:00.000Z'
                        OfferEndDateTimeInUTC   = '2024-01-07T00:00:00.000Z'
                        OfferIntervalInDays     = 3
                    })
                    Ensure               = 'Present'
                    Credential           = $Credential
                }
                { (New-M365DSCResourceInstance -ResourceName 'IntuneWindowsUpdateForBusinessFeatureUpdateProfileWindows10' -Property $testParams).Set() } | Should -Throw 'OfferIntervalInDays must be less than or equal to the difference between OfferEndDateTimeInUTC and OfferStartDateTimeInUTC in days.'
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
                $result = Invoke-M365DSCResourceMethod -ResourceName 'IntuneWindowsUpdateForBusinessFeatureUpdateProfileWindows10' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
