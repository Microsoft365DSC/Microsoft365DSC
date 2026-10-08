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
    -DscResource 'EXOEmailAddressPolicy' -GenericStubModule $GenericStubPath
Describe -Name $Global:DscHelper.DescribeHeader -Fixture {
    InModuleScope -ModuleName $Global:DscHelper.ModuleName -ScriptBlock {
        Invoke-Command -ScriptBlock $Global:DscHelper.InitializeScript -NoNewScope

        BeforeAll {
            $secpasswd = ConvertTo-SecureString (New-Guid | Out-String) -AsPlainText -Force
            $Credential = New-Object System.Management.Automation.PSCredential ('tenantadmin@onmicrosoft.com', $secpasswd)

            Mock -ModuleName M365DSCUtil -CommandName Confirm-M365DSCDependencies -MockWith {
            }

            Mock -CommandName New-M365DSCConnection -ModuleName '_Shared' -MockWith {
                return 'Credentials'
            }

            Mock -CommandName Get-PSSession -MockWith {
            }

            Mock -CommandName Remove-PSSession -MockWith {
            }

            Mock -CommandName Set-EmailAddressPolicy -MockWith {
            }

            Mock -CommandName New-EmailAddressPolicy -MockWith {
            }

            Mock -CommandName Remove-EmailAddressPolicy -MockWith {
            }

            Mock -CommandName Get-EmailAddressPolicy -MockWith {
                return @{
                    Name                         = 'Contoso EAP'
                    Priority                     = '1'
                    EnabledEmailAddressTemplates = 'SMTP:@contoso.com'
                }
            }

            # Mock Write-M365DSCHost to hide output during the tests
            Mock -CommandName Write-M365DSCHost -MockWith {
            }
            $Script:exportedInstances =$null
            $Script:ExportMode = $false
        }

        # Test contexts
        Context -Name 'Email Address Policy should exist. Email Address Policy is missing. Test should fail.' -Fixture {
            BeforeAll {
                $testParams = @{
                    Name                         = 'Contoso EAP'
                    Priority                     = '1'
                    EnabledEmailAddressTemplates = 'SMTP:@contoso.com'
                    Ensure                       = 'Present'
                    Credential                   = $Credential
                }

                Mock -CommandName Get-EmailAddressPolicy -MockWith {
                    return $null
                }
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOEmailAddressPolicy' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should call the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOEmailAddressPolicy' -Property $testParams).Set()
                Should -Invoke -CommandName New-EmailAddressPolicy -Exactly 1
            }

            It 'Should return Absent from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'EXOEmailAddressPolicy' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Absent'
            }
        }

        Context -Name 'Email Address Policy should exist. Email Address Policy exists. Test should pass.' -Fixture {
            BeforeAll {
                $testParams = @{
                    Name                         = 'Contoso EAP'
                    Priority                     = '1'
                    EnabledEmailAddressTemplates = 'SMTP:@contoso.com'
                    Ensure                       = 'Present'
                    Credential                   = $Credential
                }
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOEmailAddressPolicy' -Property $testParams).Test() | Should -Be $true
            }

            It 'Should return Present from the Get Method' {
                ((New-M365DSCResourceInstance -ResourceName 'EXOEmailAddressPolicy' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }
        }

        Context -Name 'Email Address Policy should exist. Email Address Policy exists, Priority mismatch. Test should fail.' -Fixture {
            BeforeAll {
                $testParams = @{
                    Name                         = 'Contoso EAP'
                    Priority                     = '2' # Drift
                    EnabledEmailAddressTemplates = 'SMTP:@contoso.com'
                    Ensure                       = 'Present'
                    Credential                   = $Credential
                }
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOEmailAddressPolicy' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should call the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOEmailAddressPolicy' -Property $testParams).Set()
                Should -Invoke -CommandName Set-EmailAddressPolicy -Exactly 1
                Should -Invoke -CommandName Remove-EmailAddressPolicy -Exactly 0
            }

            It 'Should recreate the policy from the Set method when ManagedByFilter drifts' {
                $driftParams = $testParams.Clone()
                $driftParams.ManagedByFilter = "Department -eq 'Sales'"
                (New-M365DSCResourceInstance -ResourceName 'EXOEmailAddressPolicy' -Property $driftParams).Test() | Should -Be $false
                (New-M365DSCResourceInstance -ResourceName 'EXOEmailAddressPolicy' -Property $driftParams).Set()
                Should -Invoke -CommandName Remove-EmailAddressPolicy -Exactly 1
                Should -Invoke -CommandName New-EmailAddressPolicy -Exactly 1 -ParameterFilter { $ManagedByFilter -eq "Department -eq 'Sales'" }
                Should -Invoke -CommandName Set-EmailAddressPolicy -Exactly 0
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

            It 'Should Reverse Engineer resource from the Export method when single' {
                $result = Invoke-M365DSCResourceMethod -ResourceName 'EXOEmailAddressPolicy' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
