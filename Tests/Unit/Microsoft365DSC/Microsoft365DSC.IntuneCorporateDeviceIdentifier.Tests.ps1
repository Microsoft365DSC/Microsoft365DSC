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
    -DscResource 'IntuneCorporateDeviceIdentifier' -GenericStubModule $GenericStubPath

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

            Mock -CommandName Import-MgBetaDeviceManagementImportedDeviceIdentityList -MockWith {
            }

            Mock -CommandName Remove-MgBetaDeviceManagementImportedDeviceIdentity -MockWith {
            }

            Mock -CommandName Get-MgBetaDeviceManagementImportedDeviceIdentity -MockWith {
                return @(
                        @{
                            id                         = '12345-67890'
                            importedDeviceIdentifier   = 'ABC123456'
                            importedDeviceIdentityType = 'serialNumber'
                            description                = 'Corporate laptop'
                            platform                   = 'windows'
                            enrollmentState            = 'notContacted'
                            lastModifiedDateTime       = '2024-01-01T00:00:00Z'
                            createdDateTime            = '2024-01-01T00:00:00Z'
                        }
                    )
            }

            # Mock Write-M365DSCHost to hide output during the tests
            Mock -CommandName Write-M365DSCHost -MockWith {
            }
            $Script:exportedInstances = $null
            $Script:ExportMode = $false
        }

        # Test contexts
        Context -Name "When no devices exist in Intune" -Fixture {
            BeforeAll {
                $testParams = @{
                    IsSingleInstance = 'Yes'
                    Devices          = @(
                        ([MSFT_IntuneDeviceIdentifier] @{
                            importedDeviceIdentifier   = 'ABC123456'
                            importedDeviceIdentityType = 'serialNumber'
                            description                = 'Corporate laptop'
                            platform                   = 'windows'
                        })
                    )
                    Ensure           = 'Present'
                    Credential       = $Credential
                }

                Mock -CommandName Get-MgBetaDeviceManagementImportedDeviceIdentity -MockWith {
                    return @()
                }
            }

            It 'Should return Absent from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'IntuneCorporateDeviceIdentifier' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Absent'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneCorporateDeviceIdentifier' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should add devices from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneCorporateDeviceIdentifier' -Property $testParams).Set()
                Should -Invoke -CommandName 'Import-MgBetaDeviceManagementImportedDeviceIdentityList'
            }
        }

        Context -Name 'When devices exist and match the desired state' -Fixture {
            BeforeAll {
                $testParams = @{
                    IsSingleInstance = 'Yes'
                    Devices          = @(
                        ([MSFT_IntuneDeviceIdentifier] @{
                            importedDeviceIdentifier   = 'ABC123456'
                            importedDeviceIdentityType = 'serialNumber'
                            description                = 'Corporate laptop'
                            platform                   = 'windows'
                        })
                    )
                    Ensure           = 'Present'
                    Credential       = $Credential
                }

                Mock -CommandName Get-MgBetaDeviceManagementImportedDeviceIdentity -MockWith {
                    return @(
                            @{
                                id                         = '12345-67890'
                                importedDeviceIdentifier   = 'ABC123456'
                                importedDeviceIdentityType = 'serialNumber'
                                description                = 'Corporate laptop'
                                platform                   = 'windows'
                                enrollmentState            = 'notContacted'
                                lastModifiedDateTime       = '2024-01-01T00:00:00Z'
                                createdDateTime            = '2024-01-01T00:00:00Z'
                            }
                        )
                }
            }

            It 'Should return Present from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'IntuneCorporateDeviceIdentifier' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneCorporateDeviceIdentifier' -Property $testParams).Test() | Should -Be $true
            }
        }

        Context -Name 'When devices exist but do not match desired state' -Fixture {
            BeforeAll {
                $testParams = @{
                    IsSingleInstance = 'Yes'
                    Devices          = @(
                        ([MSFT_IntuneDeviceIdentifier] @{
                            importedDeviceIdentifier   = 'XYZ987654'
                            importedDeviceIdentityType = 'serialNumber'
                            description                = 'Executive laptop'
                            platform                   = 'macos'
                        })
                    )
                    Ensure           = 'Present'
                    Credential       = $Credential
                }

                Mock -CommandName Get-MgBetaDeviceManagementImportedDeviceIdentity -MockWith {
                    return @(
                                @{
                                    id                         = '12345-67890'
                                    importedDeviceIdentifier   = 'ABC123456'
                                    importedDeviceIdentityType = 'serialNumber'
                                    description          = 'Corporate laptop'
                                    platform             = 'windows'
                                    enrollmentState      = 'notContacted'
                                    lastModifiedDateTime = '2024-01-01T00:00:00Z'
                                    createdDateTime      = '2024-01-01T00:00:00Z'
                                }
                            )
                }
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneCorporateDeviceIdentifier' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should add new device and remove old device from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneCorporateDeviceIdentifier' -Property $testParams).Set()
                Should -Invoke -CommandName 'Import-MgBetaDeviceManagementImportedDeviceIdentityList'
                Should -Invoke -CommandName 'Remove-MgBetaDeviceManagementImportedDeviceIdentity'
            }
        }

        Context -Name 'When Ensure is Absent and devices exist' -Fixture {
            BeforeAll {
                $testParams = @{
                    IsSingleInstance = 'Yes'
                    Ensure           = 'Absent'
                    Credential       = $Credential
                }

                Mock -CommandName Get-MgBetaDeviceManagementImportedDeviceIdentity -MockWith {
                    return @(
                                @{
                                    id                         = '12345-67890'
                                    importedDeviceIdentifier   = 'ABC123456'
                                    importedDeviceIdentityType = 'serialNumber'
                                    description                = 'Corporate laptop'
                                    platform                   = 'windows'
                                    enrollmentState            = 'notContacted'
                                    lastModifiedDateTime       = '2024-01-01T00:00:00Z'
                                    createdDateTime            = '2024-01-01T00:00:00Z'
                                }
                            )
                }
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneCorporateDeviceIdentifier' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should remove all devices from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneCorporateDeviceIdentifier' -Property $testParams).Set()
                Should -Invoke -CommandName 'Remove-MgBetaDeviceManagementImportedDeviceIdentity' -Exactly 1
            }
        }

        Context -Name 'When Ensure is Absent and no devices exist' -Fixture {
            BeforeAll {
                $testParams = @{
                    IsSingleInstance = 'Yes'
                    Ensure           = 'Absent'
                    Credential       = $Credential
                }

                Mock -CommandName Get-MgBetaDeviceManagementImportedDeviceIdentity -MockWith {
                    return @()
                }
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneCorporateDeviceIdentifier' -Property $testParams).Test() | Should -Be $true
            }
        }

        Context -Name 'ReverseDSC Tests' -Fixture {
            BeforeAll {
                $Global:CurrentModeIsExport = $true
                $Global:PartialExportFileName = "$(New-Guid).partial.ps1"
                $testParams = @{
                    Credential = $Credential
                }

                Mock -CommandName Get-MgBetaDeviceManagementImportedDeviceIdentity -MockWith {
                    return @(
                            @{
                                id                         = '12345-67890'
                                importedDeviceIdentifier   = 'ABC123456'
                                importedDeviceIdentityType = 'serialNumber'
                                description                = 'Corporate laptop'
                                platform                   = 'windows'
                                enrollmentState            = 'notContacted'
                                lastModifiedDateTime       = '2024-01-01T00:00:00Z'
                                createdDateTime            = '2024-01-01T00:00:00Z'
                            }
                        )
                }
            }

            It 'Should Reverse Engineer resource from the Export method' {
                $result = Invoke-M365DSCResourceMethod -ResourceName 'IntuneCorporateDeviceIdentifier' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
