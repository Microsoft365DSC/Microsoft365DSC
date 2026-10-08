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
    -DscResource 'SCAutoSensitivityLabelPolicy' -GenericStubModule $GenericStubPath
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

            Mock -CommandName Import-PSSession -MockWith {
            }

            Mock -CommandName New-PSSession -MockWith {
            }

            Mock -CommandName Remove-AutoSensitivityLabelPolicy -MockWith {
            }

            Mock -CommandName New-AutoSensitivityLabelPolicy -MockWith {
                return @{

                }
            }

            Mock -CommandName Set-AutoSensitivityLabelPolicy -MockWith {
                return @{

                }
            }

            Mock -CommandName Start-Sleep -MockWith {
            }

            # Mock Write-M365DSCHost to hide output during the tests
            Mock -CommandName Write-M365DSCHost -MockWith {
            }
            $Script:exportedInstance =$null
            $Script:ExportMode = $false
        }

        # Test contexts
        Context -Name "Policy doesn't already exist" -Fixture {
            BeforeAll {
                $testParams = @{
                    ApplySensitivityLabel = 'TopSecret'
                    Comment               = 'Test'
                    Credential            = $Credential
                    Ensure                = 'Present'
                    ExchangeLocation      = @('All')
                    Mode                  = 'Enable'
                    Name                  = 'TestPolicy'
                    Priority              = 0
                }

                Mock -CommandName Get-AutoSensitivityLabelPolicy -MockWith {
                    return @{
                        Name = 'TestPolicy'
                        Mode = 'PendingDeletion'
                    }
                }
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'SCAutoSensitivityLabelPolicy' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should return Absent from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'SCAutoSensitivityLabelPolicy' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Absent'
            }

            It 'Should call the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'SCAutoSensitivityLabelPolicy' -Property $testParams).Set()
                Should -Invoke -CommandName New-AutoSensitivityLabelPolicy -Exactly 1
            }
        }

        Context -Name 'Policy already exists and is NOT in the desired state' -Fixture {
            BeforeAll {
                $testParams = @{
                    ApplySensitivityLabel = 'TopSecret'
                    Comment               = 'Test'
                    Credential            = $Credential
                    Ensure                = 'Present'
                    ExchangeLocation      = @('All')
                    Mode                  = 'Enable'
                    Name                  = 'TestPolicy'
                    Priority              = 0
                }

                Mock -CommandName Get-AutoSensitivityLabelPolicy -MockWith {
                    return @{
                        ApplySensitivityLabel = 'TopSecret'
                        Comment               = 'Test'
                        ExchangeLocation      = @(@{DisplayName='All'})
                        Mode                  = 'TestWithoutNotifications'; #Drift
                        Name                  = 'TestPolicy'
                        Priority              = 0
                    }
                }
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'SCAutoSensitivityLabelPolicy' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should return update from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'SCAutoSensitivityLabelPolicy' -Property $testParams).Set()
                Should -Invoke -CommandName Set-AutoSensitivityLabelPolicy -Exactly 1
            }

            It 'Should return Present from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'SCAutoSensitivityLabelPolicy' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }
        }

        Context -Name 'Policy already exists and is in the desired state' -Fixture {
            BeforeAll {
                $testParams = @{
                    ApplySensitivityLabel           = 'TopSecret'
                    Comment                         = 'Test'
                    Credential                      = $Credential
                    Ensure                          = 'Present'
                    ExchangeLocation                = @('All')
                    ExchangeSender                  = @('PradeepG@contoso.com')
                    ExchangeSenderException         = @('MeganB@contoso.com')
                    ExchangeSenderMemberOf          = @('sales@contoso.com')
                    ExchangeSenderMemberOfException = @('marketing@contoso.com')
                    Mode                            = 'Enable'
                    Name                            = 'TestPolicy'
                    Priority                        = 0
                }

                Mock -CommandName Get-AutoSensitivityLabelPolicy -MockWith {
                    return @{
                        ApplySensitivityLabel           = 'TopSecret'
                        Comment                         = 'Test'
                        ExchangeLocation                = @(@{Name='All'})
                        ExchangeSender                  = [System.Collections.ArrayList]@('PradeepG@contoso.com')
                        ExchangeSenderException         = [System.Collections.ArrayList]@('MeganB@contoso.com')
                        ExchangeSenderMemberOf          = [System.Collections.ArrayList]@('{"PrimarySmtpAddress":"sales@contoso.com","DisplayName":"Sales"}')
                        ExchangeSenderMemberOfException = [System.Collections.ArrayList]@('{"PrimarySmtpAddress":"marketing@contoso.com","DisplayName":"Marketing"}')
                        Mode                            = 'Enable'
                        Name                            = 'TestPolicy'
                        Priority                        = 0
                    }
                }
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'SCAutoSensitivityLabelPolicy' -Property $testParams).Test() | Should -Be $true
            }

            It 'Should return Present from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'SCAutoSensitivityLabelPolicy' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

        }

        Context -Name 'Policy should not exist' -Fixture {
            BeforeAll {
                $testParams = @{
                    ApplySensitivityLabel = 'TopSecret'
                    Comment               = 'Test'
                    Credential            = $Credential
                    Ensure                = 'Absent'
                    ExchangeLocation      = @(@{DisplayName='All'})
                    Mode                  = 'Enable'
                    Name                  = 'TestPolicy'
                    Priority              = 0
                }

                Mock -CommandName Get-AutoSensitivityLabelPolicy -MockWith {
                    return @{
                        ApplySensitivityLabel = 'TopSecret'
                        Comment               = 'Test'
                        ExchangeLocation      = @('All')
                        Mode                  = 'Enable'
                        Name                  = 'TestPolicy'
                        Priority              = 0
                    }
                }
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'SCAutoSensitivityLabelPolicy' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should remove update from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'SCAutoSensitivityLabelPolicy' -Property $testParams).Set()
                Should -Invoke -CommandName Remove-AutoSensitivityLabelPolicy -Exactly 1
            }

            It 'Should return Present from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'SCAutoSensitivityLabelPolicy' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }
        }

        Context -Name 'ReverseDSC Tests' -Fixture {
            BeforeAll {
                $Global:CurrentModeIsExport = $true
                $Global:PartialExportFileName = "$(New-Guid).partial.ps1"
                $testParams = @{
                    Credential = $Credential
                }
                Mock -CommandName Get-AutoSensitivityLabelPolicy -MockWith {
                    return @{
                        ApplySensitivityLabel = 'TopSecret'
                        Comment               = 'Test'
                        ExchangeLocation      = @(@{DisplayName='All'})
                        Mode                  = 'Enable'
                        Name                  = 'TestPolicy'
                        Priority              = 0
                    }
                }
            }

            It 'Should Reverse Engineer resource from the Export method' {
                $result = Invoke-M365DSCResourceMethod -ResourceName 'SCAutoSensitivityLabelPolicy' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
