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

            Mock -CommandName Get-MigrationEndpoint -MockWith {
                return @{
                    AcceptUntrustedCertificates   = $True;
                    Authentication                = "Basic";
                    EndpointType                  = "IMAP";
                    Identity                      = "testIMAP";
                    MailboxPermission             = "Admin";
                    MaxConcurrentIncrementalSyncs = "10";
                    MaxConcurrentMigrations       = "20";
                    Port                          = 993;
                    RemoteServer                  = "gmail.com";
                    Security                      = "Tls";
                }
            }

            Mock -CommandName Set-MigrationEndpoint -MockWith {
            }

            Mock -CommandName New-MigrationEndpoint -MockWith {
            }

            Mock -CommandName Remove-MigrationEndpoint -MockWith {
            }

            # Mock Write-M365DSCHost to hide output during the tests
            Mock -CommandName Write-M365DSCHost -MockWith {
            }
            $Script:exportedInstances =$null
            $Script:ExportMode = $false
        }
        # Test contexts
        Context -Name "The instance should exist but it DOES NOT" -Fixture {
            BeforeAll {
                $testParams = @{
                    AcceptUntrustedCertificates   = $True;
                    Authentication                = "Basic";
                    EndpointType                  = "IMAP";
                    Identity                      = "testIMAP";
                    MailboxPermission             = "Admin";
                    MaxConcurrentIncrementalSyncs = "10";
                    MaxConcurrentMigrations       = "20";
                    Port                          = 993;
                    RemoteServer                  = "gmail.com";
                    Security                      = "Tls";
                    Ensure                        = 'Present'
                    Credential                    = $Credential;
                }

                Mock -CommandName Get-MigrationEndpoint -MockWith {
                    return $null
                }
            }
            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'EXOMigrationEndpoint' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Absent'
            }
            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOMigrationEndpoint' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should create a new instance from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOMigrationEndpoint' -Property $testParams).Set()
                Should -Invoke -CommandName New-MigrationEndpoint -Exactly 1
            }
        }

        Context -Name "The instance exists but it SHOULD NOT" -Fixture {
            BeforeAll {
                $testParams = @{
                    AcceptUntrustedCertificates   = $True;
                    Authentication                = "Basic";
                    EndpointType                  = "IMAP";
                    Identity                      = "testIMAP";
                    MailboxPermission             = "Admin";
                    MaxConcurrentIncrementalSyncs = "10";
                    MaxConcurrentMigrations       = "20";
                    Port                          = 993;
                    RemoteServer                  = "gmail.com";
                    Security                      = "Tls";
                    Ensure              = 'Absent'
                    Credential          = $Credential;
                }
            }
            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'EXOMigrationEndpoint' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }
            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOMigrationEndpoint' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should remove the instance from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOMigrationEndpoint' -Property $testParams).Set()
                Should -Invoke -CommandName Remove-MigrationEndpoint -Exactly 1
            }
        }

        Context -Name "The instance exists and values are already in the desired state" -Fixture {
            BeforeAll {
                $testParams = @{
                    AcceptUntrustedCertificates   = $True;
                    Authentication                = "Basic";
                    EndpointType                  = "IMAP";
                    Identity                      = "testIMAP";
                    MailboxPermission             = "Admin";
                    MaxConcurrentIncrementalSyncs = "10";
                    MaxConcurrentMigrations       = "20";
                    Port                          = 993;
                    RemoteServer                  = "gmail.com";
                    Security                      = "Tls";
                    Ensure              = 'Present'
                    Credential          = $Credential;
                }
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOMigrationEndpoint' -Property $testParams).Test() | Should -Be $true
            }
        }

        Context -Name "The instance exists and values are NOT in the desired state" -Fixture {
            BeforeAll {
                $testParams = @{
                    AcceptUntrustedCertificates   = $True;
                    Authentication                = "Basic";
                    EndpointType                  = "IMAP";
                    Identity                      = "testIMAP";
                    MailboxPermission             = "Admin";
                    MaxConcurrentIncrementalSyncs = "10";
                    MaxConcurrentMigrations       = "20";
                    Port                          = 993;
                    RemoteServer                  = "gmail.com";
                    Security                      = "None"; # Drift
                    Ensure              = 'Present'
                    Credential          = $Credential;
                }
            }

            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'EXOMigrationEndpoint' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOMigrationEndpoint' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should call the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOMigrationEndpoint' -Property $testParams).Set()
                Should -Invoke -CommandName Set-MigrationEndpoint -Exactly 1
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
                $result = Invoke-M365DSCResourceMethod -ResourceName 'EXOMigrationEndpoint' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
