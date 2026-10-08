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
    -DscResource "AADIdentityAPIConnector" -GenericStubModule $GenericStubPath
Describe -Name $Global:DscHelper.DescribeHeader -Fixture {
    InModuleScope -ModuleName $Global:DscHelper.ModuleName -ScriptBlock {
        Invoke-Command -ScriptBlock $Global:DscHelper.InitializeScript -NoNewScope
        BeforeAll {

            $secpasswd = ConvertTo-SecureString (New-Guid | Out-String) -AsPlainText -Force
            $Credential = New-Object System.Management.Automation.PSCredential ('tenantadmin@onmicrosoft.com', $secpasswd)

            Mock -ModuleName M365DSCUtil -CommandName Confirm-M365DSCDependencies -MockWith {
            }

            Mock -CommandName Get-PSSession -MockWith {
            }

            Mock -CommandName Remove-PSSession -MockWith {
            }

            Mock -CommandName Update-MgBetaIdentityAPIConnector -MockWith {
            }

            Mock -CommandName New-MgBetaIdentityAPIConnector -MockWith {
            }

            Mock -CommandName Remove-MgBetaIdentityAPIConnector -MockWith {
            }

            Mock -CommandName Get-MgBetaIdentityAPIConnector -MockWith {
                return @{
                    DisplayName = 'FakeStringValue'
                    TargetUrl = 'FakeStringValue'
                    Id = 'FakeStringValue'
                    AuthenticationConfiguration = @{
                        certificateList = @(
                            @{
                                Thumbprint = 'FakeStringValue'
                                IsActive = $true
                            }
                        )
                        Username = 'FakeStringValue'
                        Password = $Cred
                    }
                }
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
        # Test contexts
        Context -Name "The AADIdentityAPIConnector should exist but it DOES NOT" -Fixture {
            BeforeAll {
                $testParams = @{
                    DisplayName = 'FakeStringValue'
                    TargetUrl = 'FakeStringValue'
                    Id = 'FakeStringValue'
                    AuthenticationConfiguration = @{
                        dataType = '#microsoft.graph.basicAuthentication'
                        Username = 'FakeStringValue'
                        Password = $Credential
                        CertificateList = @(
                             [MSFT_AADIdentityAPIConnectionCertificate] @{
                                 Thumbprint = 'FakeStringValue'
                                 Pkcs12Value = New-Object -TypeName System.Management.Automation.PSCredential('Pkcs12Value',
                                    (ConvertTo-SecureString -String "FakeStringValue" -AsPlainText -Force))
                                 Password = New-Object -TypeName System.Management.Automation.PSCredential('Password',
                                    (ConvertTo-SecureString -String "FakeStringValue" -AsPlainText -Force))
                                 IsActive = $true
                             }
                        )
                    }
                    Credential = $Credential
                }

                Mock -CommandName Get-MgBetaIdentityAPIConnector -MockWith {
                    return $null
                }
            }
            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'AADIdentityAPIConnector' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Absent'
            }
            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'AADIdentityAPIConnector' -Property $testParams).Test() | Should -Be $false
            }
            It 'Should Create the group from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'AADIdentityAPIConnector' -Property $testParams).Set()
                Should -Invoke -CommandName New-MgBetaIdentityAPIConnector -Exactly 1
            }
        }

        Context -Name "The AADIdentityAPIConnector exists but it SHOULD NOT" -Fixture {
            BeforeAll {
                $testParams = @{
                    DisplayName = 'FakeStringValue'
                    TargetUrl = 'FakeStringValue'
                    Id = 'FakeStringValue'
                    AuthenticationConfiguration = @{
                        dataType = '#microsoft.graph.basicAuthentication'
                        Username = 'FakeStringValue'
                        Password = $Credential
                        CertificateList = @(
                             [MSFT_AADIdentityAPIConnectionCertificate] @{
                                 Thumbprint = 'FakeStringValue'
                                 Pkcs12Value = New-Object -TypeName System.Management.Automation.PSCredential('Pkcs12Value',
                                    (ConvertTo-SecureString -String "FakeStringValue" -AsPlainText -Force))
                                 Password = New-Object -TypeName System.Management.Automation.PSCredential('Password',
                                    (ConvertTo-SecureString -String "FakeStringValue" -AsPlainText -Force))
                                 IsActive = $true
                             }
                        )
                    }
                    Credential = $Credential
                    Ensure = 'Absent'
                }
            }

            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'AADIdentityAPIConnector' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'AADIdentityAPIConnector' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should Remove the group from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'AADIdentityAPIConnector' -Property $testParams).Set()
                Should -Invoke -CommandName Remove-MgBetaIdentityAPIConnector -Exactly 1
            }
        }

        Context -Name "The AADIdentityAPIConnector exists and values are NOT in the desired state" -Fixture {
            BeforeAll {
                $testParams = @{
                    DisplayName = 'FakeStringValue'
                    TargetUrl = 'FakeStringValue2' # Drift
                    Id = 'FakeStringValue'
                    AuthenticationConfiguration = @{
                        dataType = '#microsoft.graph.basicAuthentication'
                        Username = 'FakeStringValue'
                        Password = $Credential
                        CertificateList = @(
                             [MSFT_AADIdentityAPIConnectionCertificate] @{
                                 Thumbprint = 'FakeStringValue'
                                 Pkcs12Value = New-Object -TypeName System.Management.Automation.PSCredential('Pkcs12Value',
                                    (ConvertTo-SecureString -String "FakeStringValue" -AsPlainText -Force))
                                 Password = New-Object -TypeName System.Management.Automation.PSCredential('Password',
                                    (ConvertTo-SecureString -String "FakeStringValue" -AsPlainText -Force))
                                 IsActive = $true
                             }
                        )
                    }
                    Credential = $Credential
                }
            }

            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'AADIdentityAPIConnector' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'AADIdentityAPIConnector' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should call the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'AADIdentityAPIConnector' -Property $testParams).Set()
                Should -Invoke -CommandName Remove-MgBetaIdentityApiConnector -Exactly 1
                Should -Invoke -CommandName New-MgBetaIdentityApiConnector -Exactly 1
            }
        }

        Context -Name "The AADIdentityAPIConnector exists and values are in the desired state" -Fixture {
            BeforeAll {
                $testParams = @{
                    DisplayName = 'FakeStringValue'
                    TargetUrl = 'FakeStringValue'
                    Id = 'FakeStringValue'
                    AuthenticationConfiguration = @{
                        dataType = '#microsoft.graph.pkcs12Certificate'
                        CertificateList = @(
                             [MSFT_AADIdentityAPIConnectionCertificate] @{
                                 Thumbprint = 'FakeStringValue'
                                 Pkcs12Value = New-Object -TypeName System.Management.Automation.PSCredential('Pkcs12Value',
                                    (ConvertTo-SecureString -String "FakeStringValue" -AsPlainText -Force))
                                 Password = New-Object -TypeName System.Management.Automation.PSCredential('Password',
                                    (ConvertTo-SecureString -String "FakeStringValue" -AsPlainText -Force))
                                 IsActive = $true
                             }
                        )
                    }
                    Credential = $Credential
                    Ensure = 'Present'
                }
            }

            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'AADIdentityAPIConnector' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'AADIdentityAPIConnector' -Property $testParams).Test() | Should -Be $true
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
                $result = Invoke-M365DSCResourceMethod -ResourceName 'AADIdentityAPIConnector' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
