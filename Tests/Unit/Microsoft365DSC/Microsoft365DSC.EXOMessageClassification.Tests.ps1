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
    -DscResource 'EXOMessageClassification' -GenericStubModule $GenericStubPath
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

            Mock -CommandName New-MessageClassification -MockWith {
            }

            Mock -CommandName Set-MessageClassification -MockWith {
            }

            Mock -CommandName Remove-MessageClassification -MockWith {
            }

            Mock -CommandName Get-MessageClassification -MockWith {
                return @{
                    ClassificationID            = '00a71ebb-b13d-4f23-9eee-daba7a1f2336'
                    DisplayName                 = 'Nik Classification'
                    DisplayPrecedence           = 'Medium'
                    Identity                    = 'Default\NikClassification'
                    Name                        = 'NikClassification'
                    PermissionMenuVisible       = $True
                    RecipientDescription        = 'test'
                    RetainClassificationEnabled = $True
                    SenderDescription           = 'test'
                }
            }

            # Mock Write-M365DSCHost to hide output during the tests
            Mock -CommandName Write-M365DSCHost -MockWith {
            }
            $Script:exportedInstances =$null
            $Script:ExportMode = $false
        }

        # Test contexts
        Context -Name "Instance doesn't exist and it should" -Fixture {
            BeforeAll {
                $testParams = @{
                    ClassificationID            = '00a71ebb-b13d-4f23-9eee-daba7a1f2336'
                    Credential                  = $Credential
                    DisplayName                 = 'Nik Classification'
                    DisplayPrecedence           = 'Medium'
                    Ensure                      = 'Present'
                    Identity                    = 'Default\NikClassification'
                    Name                        = 'NikClassification'
                    PermissionMenuVisible       = $True
                    RecipientDescription        = 'test'
                    RetainClassificationEnabled = $True
                    SenderDescription           = 'test'
                }

                Mock -CommandName Get-MessageClassification -MockWith {
                    return $null
                }
            }

            It 'Should return False from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'EXOMessageClassification' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Absent'
            }

            It 'Should call the New- cmdlet' {
                (New-M365DSCResourceInstance -ResourceName 'EXOMessageClassification' -Property $testParams).Set()
                Should -Invoke -CommandName 'New-MessageClassification' -Exactly 1
            }
        }

        Context -Name 'Instance already exists and should be updated' -Fixture {
            BeforeAll {
                $testParams = @{
                    ClassificationID            = '00a71ebb-b13d-4f23-9eee-daba7a1f2336'
                    Credential                  = $Credential
                    DisplayName                 = 'Nik Classification'
                    DisplayPrecedence           = 'Medium'
                    Ensure                      = 'Present'
                    Identity                    = 'Default\NikClassification'
                    Name                        = 'NikClassification'
                    PermissionMenuVisible       = $false # Drift
                    RecipientDescription        = 'test'
                    RetainClassificationEnabled = $True
                    SenderDescription           = 'test'
                }
            }

            It 'Should return False from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'EXOMessageClassification' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should set Call into the Set- command exactly once' {
                (New-M365DSCResourceInstance -ResourceName 'EXOMessageClassification' -Property $testParams).Set()
                Should -Invoke -CommandName 'Set-MessageClassification' -Exactly 1
            }
        }

        Context -Name 'Instance exists and it should not' -Fixture {
            BeforeAll {
                $testParams = @{
                    ClassificationID            = '00a71ebb-b13d-4f23-9eee-daba7a1f2336'
                    Credential                  = $Credential
                    DisplayName                 = 'Nik Classification'
                    DisplayPrecedence           = 'Medium'
                    Ensure                      = 'Absent'
                    Identity                    = 'Default\NikClassification'
                    Name                        = 'NikClassification'
                    PermissionMenuVisible       = $True
                    RecipientDescription        = 'test'
                    RetainClassificationEnabled = $True
                    SenderDescription           = 'test'
                }
            }

            It 'Should return present from the Get-TargetResource function' {
                ((New-M365DSCResourceInstance -ResourceName 'EXOMessageClassification' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should call into the Remove- cmdlet once' {
                (New-M365DSCResourceInstance -ResourceName 'EXOMessageClassification' -Property $testParams).Set()
                Should -Invoke -CommandName 'Remove-MessageClassification' -Exactly 1
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
                $result = Invoke-M365DSCResourceMethod -ResourceName 'EXOMessageClassification' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope

