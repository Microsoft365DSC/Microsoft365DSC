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
    -DscResource 'IntuneTrustedRootCertificateIOS' -GenericStubModule $GenericStubPath
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

            Mock -CommandName Update-MgBetaDeviceManagementDeviceConfiguration -MockWith {
            }

            Mock -CommandName New-MgBetaDeviceManagementDeviceConfiguration -MockWith {
            }

            Mock -CommandName Remove-MgBetaDeviceManagementDeviceConfiguration -MockWith {
            }

            Mock -CommandName Get-MgBetaDeviceManagementDeviceCompliancePolicyAssignment -MockWith {

                return @()
            }
            Mock -CommandName Update-DeviceConfigurationPolicyAssignment -MockWith {
            }
            # Mock Write-M365DSCHost to hide output during the tests
            Mock -CommandName Write-M365DSCHost -MockWith {
            }
            Mock -CommandName Get-M365DSCExportCachedCollection -MockWith {
                return Get-MgBetaDeviceManagementDeviceConfiguration
            }

            $Script:exportedInstances =$null
            $Script:ExportMode = $false
        }

        # Test contexts
        Context -Name "When the IntuneTrustedRootCertificateIOS doesn't already exist" -Fixture {
            BeforeAll {
                $testParams = @{
                    DisplayName                                 = 'Test IntuneTrustedRootCertificateIOS'
                    Description                                 = 'Test IntuneTrustedRootCertificateIOS Description'
                    certFileName                                = "FakeStringValue"
                    trustedRootCertificate                      = "fakestringvalue0"
                    Ensure                                      = 'Present'
                    Credential                                  = $Credential
                }

                Mock -CommandName Get-MgBetaDeviceManagementDeviceConfiguration -MockWith {
                    return $null
                }
            }

            It 'Should return absent from the Get method' {
                    ((New-M365DSCResourceInstance -ResourceName 'IntuneTrustedRootCertificateIOS' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Absent'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneTrustedRootCertificateIOS' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should create the IntuneTrustedRootCertificateIOS from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneTrustedRootCertificateIOS' -Property $testParams).Set()
                Should -Invoke -CommandName 'New-MgBetaDeviceManagementDeviceConfiguration' -Exactly 1
            }
        }

        Context -Name 'When the IntuneTrustedRootCertificateIOS already exists and is NOT in the Desired State' -Fixture {
            BeforeAll {
                $testParams = @{
                    DisplayName                = 'Test IntuneTrustedRootCertificateIOS'
                    Description                = 'Test IntuneTrustedRootCertificateIOS Description'
                    certFileName               = "FakeStringValue"
                    trustedRootCertificate     = "fakestringvalue0"
                    Ensure                     = 'Present'
                    Credential                 = $Credential
                }

                Mock -CommandName Get-MgBetaDeviceManagementDeviceConfiguration -MockWith {
                    return @{
                        DisplayName                      = 'Test IntuneTrustedRootCertificateIOS'
                        Description                      = 'Different Value'
                        Id                               = 'e30954ac-a65e-4dcb-ab79-91d45f3c52b4'
                        certFileName                 = "FakeStringValue"
                        trustedRootCertificate       = "fakestringvalue0"
                        '@odata.type'             = '#microsoft.graph.iosTrustedRootCertificate'
                    }
                }
            }

            It 'Should return Present from the Get method' {
                    ((New-M365DSCResourceInstance -ResourceName 'IntuneTrustedRootCertificateIOS' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneTrustedRootCertificateIOS' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should update the IntuneTrustedRootCertificateIOS from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneTrustedRootCertificateIOS' -Property $testParams).Set()
                Should -Invoke -CommandName Update-MgBetaDeviceManagementDeviceConfiguration -Exactly 1

            }
        }

        Context -Name 'When the policy already exists and IS in the Desired State' -Fixture {
            BeforeAll {
                $testParams = @{
                    DisplayName                                 = 'Test IntuneTrustedRootCertificateIOS'
                    Description                                 = 'Test IntuneTrustedRootCertificateIOS Description'
                    certFileName                                = "FakeStringValue"
                    trustedRootCertificate                      = "fakestringvalue0"
                    Ensure                                      = 'Present'
                    Credential                                  = $Credential
                }

                Mock -CommandName Get-MgBetaDeviceManagementDeviceConfiguration -MockWith {
                    return @{
                        DisplayName                             = 'Test IntuneTrustedRootCertificateIOS'
                        Description                             = 'Test IntuneTrustedRootCertificateIOS Description'
                        Id                                      = 'e30954ac-a65e-4dcb-ab79-91d45f3c52b4'
                        certFileName                        = "FakeStringValue"
                        trustedRootCertificate              = "fakestringvalue0"
                        '@odata.type'                       = '#microsoft.graph.iosTrustedRootCertificate'
                    }
                }
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneTrustedRootCertificateIOS' -Property $testParams).Test() | Should -Be $true
            }
        }

        Context -Name 'When the policy exists and it SHOULD NOT' -Fixture {
            BeforeAll {
                $testParams = @{
                    DisplayName                                 = 'Test IntuneTrustedRootCertificateIOS'
                    Description                                 = 'Test IntuneTrustedRootCertificateIOS Description'
                    certFileName                                = "FakeStringValue"
                    trustedRootCertificate                      = "fakestringvalue0"
                    Ensure                                      = 'Absent'
                    Credential                                  = $Credential
                }

                Mock -CommandName Get-MgBetaDeviceManagementDeviceConfiguration -MockWith {
                    return @{
                        DisplayName                 = 'Test IntuneTrustedRootCertificateIOS'
                        Description                 = 'Test IntuneTrustedRootCertificateIOS Description'
                        Id                          = 'e30954ac-a65e-4dcb-ab79-91d45f3c52b4'
                        certFileName            = "FakeStringValue"
                        trustedRootCertificate  = "fakestringvalue0"
                        '@odata.type'           = '#microsoft.graph.iosTrustedRootCertificate'
                    }
                }
            }

            It 'Should return Present from the Get method' {
                    ((New-M365DSCResourceInstance -ResourceName 'IntuneTrustedRootCertificateIOS' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneTrustedRootCertificateIOS' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should remove the IntuneTrustedRootCertificateIOS from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneTrustedRootCertificateIOS' -Property $testParams).Set()
                Should -Invoke -CommandName Remove-MgBetaDeviceManagementDeviceConfiguration -Exactly 1
            }
        }

        Context -Name 'ReverseDSC Tests' -Fixture {
            BeforeAll {
                $Global:CurrentModeIsExport = $true
                $Global:PartialExportFileName = "$(New-Guid).partial.ps1"
                $testParams = @{
                    Credential = $Credential
                }

                Mock -CommandName Get-MgBetaDeviceManagementDeviceConfiguration -MockWith {
                    return @{
                        DisplayName                      = 'Test IntuneTrustedRootCertificateIOS'
                        Description                      = 'Test IntuneTrustedRootCertificateIOS Description'
                        Id                               = 'e30954ac-a65e-4dcb-ab79-91d45f3c52b4'
                        certFileName                 = "FakeStringValue"
                        trustedRootCertificate       = "fakestringvalue0"
                        '@odata.type'                = '#microsoft.graph.iosTrustedRootCertificate'
                    }
                }
            }

            It 'Should Reverse Engineer resource from the Export method' {
                $result = Invoke-M365DSCResourceMethod -ResourceName 'IntuneTrustedRootCertificateIOS' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
