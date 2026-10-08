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
    -DscResource 'EXODataEncryptionPolicy' -GenericStubModule $GenericStubPath
Describe -Name $Global:DscHelper.DescribeHeader -Fixture {
    InModuleScope -ModuleName $Global:DscHelper.ModuleName -ScriptBlock {
        Invoke-Command -ScriptBlock $Global:DscHelper.InitializeScript -NoNewScope

        BeforeAll {
            $secpasswd = ConvertTo-SecureString (New-Guid | Out-String) -AsPlainText -Force
            $Credential = New-Object System.Management.Automation.PSCredential ('tenantadmin@contoso.onmicrosoft.com', $secpasswd)

            Mock -ModuleName M365DSCUtil -CommandName Confirm-M365DSCDependencies -MockWith {
            }

            Mock -CommandName New-M365DSCConnection -ModuleName '_Shared' -MockWith {
                return 'Credentials'
            }

            Mock -CommandName New-DataEncryptionPolicy -MockWith {
            }

            Mock -CommandName Set-DataEncryptionPolicy -MockWith {
            }

            Mock -CommandName Get-DataEncryptionPolicy -MockWith {
                return @{
                    Identity                  = 'Test'
                    AzureKeyIDs               = [System.Collections.ArrayList]::new(@('123456789'))
                    Description               = 'Test Description'
                    Enabled                   = $true
                    Name                      = 'Test Policy'
                    PermanentDataPurgeContact = 'John.Smith@Contoso.com'
                    PermanentDataPurgeReason  = 'Test'
                }
            }

            # Mock Write-M365DSCHost to hide output during the tests
            Mock -CommandName Write-M365DSCHost -MockWith {
            }
            $Script:exportedInstances =$null
            $Script:ExportMode = $false
        }

        # Test contexts
        Context -Name "Policy doesn't exist and it should" -Fixture {
            BeforeAll {
                $testParams = @{
                    Identity                  = 'Test'
                    AzureKeyIDs               = '123456789'
                    Description               = 'Test Description'
                    Enabled                   = $true
                    Name                      = 'Test Policy'
                    PermanentDataPurgeContact = 'John.Smith@Contoso.com'
                    PermanentDataPurgeReason  = 'Test'
                    Credential                = $Credential
                    Ensure                    = 'Present'
                }

                Mock -CommandName Get-DataEncryptionPolicy -MockWith {
                    return $null
                }
            }

            It 'Should return False from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'EXODataEncryptionPolicy' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Absent'
            }

            It 'Should call the New- cmdlet' {
                (New-M365DSCResourceInstance -ResourceName 'EXODataEncryptionPolicy' -Property $testParams).Set()
                Should -Invoke -CommandName 'New-DataEncryptionPolicy' -Exactly 1
            }
        }

        Context -Name 'Policy already exists and should be updated' -Fixture {
            BeforeAll {
                $testParams = @{
                    Identity                  = 'Test'
                    AzureKeyIDs               = '123456789'
                    Description               = 'Test Description'
                    Enabled                   = $false # Drift
                    Name                      = 'Test Policy'
                    PermanentDataPurgeContact = 'John.Smith@Contoso.com'
                    PermanentDataPurgeReason  = 'Test'
                    Credential                = $Credential
                    Ensure                    = 'Present'
                }
            }

            It 'Should return False from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'EXODataEncryptionPolicy' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should set Call into the Set- command exactly once' {
                (New-M365DSCResourceInstance -ResourceName 'EXODataEncryptionPolicy' -Property $testParams).Set()
                Should -Invoke -CommandName 'Set-DataEncryptionPolicy' -Exactly 1
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
                $result = Invoke-M365DSCResourceMethod -ResourceName 'EXODataEncryptionPolicy' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope

