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
    -DscResource 'EXOJournalRule' -GenericStubModule $GenericStubPath
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

            Mock -CommandName New-JournalRule -MockWith {
            }

            Mock -CommandName Set-JournalRule -MockWith {
            }

            Mock -CommandName Remove-JournalRule -MockWith {
            }

            Mock -CommandName Enable-JournalRule -MockWith {
            }

            Mock -CommandName Disable-JournalRule -MockWith {
            }

            Mock -CommandName Get-JournalRule -MockWith {
                return @{
                    Name                = 'TestRule'
                    JournalEmailAddress = 'test@contoso.com'
                    Enabled             = $False
                    Scope               = 'Global'
                    Recipient           = 'JohnSmith@contoso.com'
                }
            }

            # Mock Write-M365DSCHost to hide output during the tests
            Mock -CommandName Write-M365DSCHost -MockWith {
            }
            $Script:exportedInstances =$null
            $Script:ExportMode = $false
        }

        # Test contexts
        Context -Name "Rule doesn't exist and it should" -Fixture {
            BeforeAll {
                $testParams = @{
                    Name                = 'TestRule'
                    JournalEmailAddress = 'test@contoso.com'
                    Enabled             = $True
                    RuleScope           = 'Global'
                    Recipient           = 'bob.houle@contoso.com'
                    Ensure              = 'Present'
                    Credential          = $Credential
                }

                Mock -CommandName Get-JournalRule -MockWith {
                    return $null
                }
            }

            It 'Should return False from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'EXOJournalRule' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Absent'
            }

            It 'Should call the New-JournalRule cmdlet' {
                (New-M365DSCResourceInstance -ResourceName 'EXOJournalRule' -Property $testParams).Set()
                Should -Invoke -CommandName 'New-JournalRule' -Exactly 1
            }
        }

        Context -Name 'Journal Rule already exists and should be updated' -Fixture {
            BeforeAll {
                $testParams = @{
                    Name                = 'TestRule'
                    JournalEmailAddress = 'test@contoso.com'
                    Enabled             = $True
                    RuleScope           = 'Global'
                    Recipient           = 'john.smith@contoso.com' # Drift
                    Ensure              = 'Present'
                    Credential          = $Credential
                }
            }

            It 'Should return False from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'EXOJournalRule' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should set Call into the Set-JournalRule command exactly once' {
                (New-M365DSCResourceInstance -ResourceName 'EXOJournalRule' -Property $testParams).Set()
                Should -Invoke -CommandName 'Set-JournalRule' -Exactly 1
                Should -Invoke -CommandName 'Enable-JournalRule' -Exactly 1 -ParameterFilter { $PesterBoundParameters.ContainsKey('Confirm') -and -not $Confirm }
            }
        }

        Context -Name 'Rule exists and it should not' -Fixture {
            BeforeAll {
                $testParams = @{
                    Name                = 'TestRule'
                    JournalEmailAddress = 'test@contoso.com'
                    Ensure              = 'Absent'
                    Credential          = $Credential
                }
            }

            It 'Should return present from the Get-TargetResource function' {
                ((New-M365DSCResourceInstance -ResourceName 'EXOJournalRule' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should call into the Remove-JournalRule cmdlet once' {
                (New-M365DSCResourceInstance -ResourceName 'EXOJournalRule' -Property $testParams).Set()
                Should -Invoke -CommandName 'Remove-JournalRule' -Exactly 1 -ParameterFilter { $PesterBoundParameters.ContainsKey('Confirm') -and -not $Confirm }
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
                $result = Invoke-M365DSCResourceMethod -ResourceName 'EXOJournalRule' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope

