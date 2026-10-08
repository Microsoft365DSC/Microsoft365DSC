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

            Mock -CommandName Set-ExoSecOpsOverrideRule -MockWith {
            }

            Mock -CommandName Remove-ExoSecOpsOverrideRule -MockWith {
            }

            Mock -CommandName New-ExoSecOpsOverrideRule -MockWith {
            }

            Mock -CommandName Set-SecOpsOverridePolicy -MockWith {
            }

            Mock -CommandName New-SecOpsOverridePolicy -MockWith {
                return @{
                    Identity = 'SecOpsOverridePolicy'
                    Mode     = 'Enable'
                    SentTo   = @('secops@contoso.com')
                }
            }

            Mock -CommandName Get-SecOpsOverridePolicy -MockWith {
                return @{
                    Identity = 'SecOpsOverridePolicy'
                    Mode     = 'Enable'
                    SentTo   = @('secops@contoso.com', 'incidentresponse@contoso.com')
                }
            }

            Mock -CommandName Get-ExoSecOpsOverrideRule -MockWith {
                return @(
                    @{
                        Identity = '_Exe:SecOpsOverrid:312c23cf-0377-4162-b93d-6548a9977efb'
                        Mode     = 'PendingDeletion'
                        Comment  = 'Previous rule'
                        SentTo   = @('legacy@contoso.com')
                    },
                    @{
                        Identity = '_Exe:SecOpsOverrid:ca3c51ac-925c-49f4-af42-43e26b874245'
                        Mode     = 'Enforce'
                        Comment  = 'TestComment'
                        SentTo   = @('secops@contoso.com', 'incidentresponse@contoso.com')
                    }
                )
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
                    IsSingleInstance    = 'Yes'
                    SentTo              = @('secops@contoso.com', 'incidentresponse@contoso.com')
                    Comment             = "TestComment";
                    Ensure              = 'Present'
                    Credential          = $Credential;
                }

                Mock -CommandName Get-ExoSecOpsOverrideRule -MockWith {
                    return $null
                }
            }
            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'EXOSecOpsOverrideRule' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Absent'
            }
            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOSecOpsOverrideRule' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should create a new instance against the existing policy from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOSecOpsOverrideRule' -Property $testParams).Set()
                Should -Invoke -CommandName New-SecOpsOverridePolicy -Exactly 0
                Should -Invoke -CommandName Set-SecOpsOverridePolicy -Exactly 0
                Should -Invoke -CommandName New-ExoSecOpsOverrideRule -Exactly 1 -ParameterFilter {
                    $Policy -eq 'SecOpsOverridePolicy' -and $Comment -eq 'TestComment'
                }
            }

            It 'Should create the policy with the SecOps mailboxes and the rule from the Set method when no policy exists' {
                Mock -CommandName Get-SecOpsOverridePolicy -MockWith {
                    return $null
                }

                (New-M365DSCResourceInstance -ResourceName 'EXOSecOpsOverrideRule' -Property $testParams).Set()
                Should -Invoke -CommandName New-SecOpsOverridePolicy -Exactly 1 -ParameterFilter {
                    $Name -eq 'SecOpsOverridePolicy' -and $SentTo.Count -eq 2
                }
                Should -Invoke -CommandName New-ExoSecOpsOverrideRule -Exactly 1
            }

            It 'Should throw from the Set method when SentTo is empty' {
                $noMailboxParams = @{
                    IsSingleInstance = 'Yes'
                    Ensure           = 'Present'
                    SentTo           = @()
                    Credential       = $Credential
                }
                { (New-M365DSCResourceInstance -ResourceName 'EXOSecOpsOverrideRule' -Property $noMailboxParams).Set() } | Should -Throw '*at least one mailbox*'

                Mock -CommandName Get-SecOpsOverridePolicy -MockWith {
                    return $null
                }
                $noMailboxParams.Remove('SentTo')
                { (New-M365DSCResourceInstance -ResourceName 'EXOSecOpsOverrideRule' -Property $noMailboxParams).Set() } | Should -Throw '*at least one mailbox*'
                Should -Invoke -CommandName New-ExoSecOpsOverrideRule -Exactly 0
                Should -Invoke -CommandName Set-SecOpsOverridePolicy -Exactly 0
            }

            It 'Should throw from the Get method when the service returns an error' {
                Mock -CommandName Get-ExoSecOpsOverrideRule -MockWith {
                    Write-Error -Message 'A server side error has occurred because of which the operation could not be completed.'
                }

                { (New-M365DSCResourceInstance -ResourceName 'EXOSecOpsOverrideRule' -Property $testParams).Get() } | Should -Throw '*server side error*'
            }
        }

        Context -Name "The instance exists but it SHOULD NOT" -Fixture {
            BeforeAll {
                $testParams = @{
                    IsSingleInstance    = 'Yes'
                    Ensure              = 'Absent';
                    Credential          = $Credential;
                }
            }
            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'EXOSecOpsOverrideRule' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }
            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOSecOpsOverrideRule' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should remove the active rule and the SecOps mailboxes from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOSecOpsOverrideRule' -Property $testParams).Set()
                Should -Invoke -CommandName Remove-ExoSecOpsOverrideRule -Exactly 1 -ParameterFilter {
                    $Identity -eq '_Exe:SecOpsOverrid:ca3c51ac-925c-49f4-af42-43e26b874245'
                }
                Should -Invoke -CommandName Set-SecOpsOverridePolicy -Exactly 1 -ParameterFilter {
                    $Identity -eq 'SecOpsOverridePolicy' -and $RemoveSentTo.Count -eq 2 -and $RemoveSentTo -contains 'incidentresponse@contoso.com'
                }
            }
        }

        Context -Name "The instance exists and values are already in the desired state" -Fixture {
            BeforeAll {
                $testParams = @{
                    IsSingleInstance    = 'Yes'
                    SentTo              = @('incidentresponse@contoso.com', 'secops@contoso.com')
                    Comment             = "TestComment";
                    Ensure              = 'Present'
                    Credential          = $Credential;
                }
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOSecOpsOverrideRule' -Property $testParams).Test() | Should -Be $true
            }
        }

        Context -Name "The instance exists and values are NOT in the desired state" -Fixture {
            BeforeAll {
                $testParams = @{
                    IsSingleInstance    = 'Yes'
                    SentTo              = @('secops@contoso.com', 'threatintel@contoso.com')
                    Comment             = "TestComment";
                    Ensure              = 'Present'
                    Credential          = $Credential;
                }
            }

            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'EXOSecOpsOverrideRule' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOSecOpsOverrideRule' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should update the SecOps mailboxes on the policy from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOSecOpsOverrideRule' -Property $testParams).Set()
                Should -Invoke -CommandName Set-SecOpsOverridePolicy -Exactly 1 -ParameterFilter {
                    $Identity -eq 'SecOpsOverridePolicy' -and
                    $AddSentTo -contains 'threatintel@contoso.com' -and
                    $RemoveSentTo -contains 'incidentresponse@contoso.com'
                }
                Should -Invoke -CommandName Set-ExoSecOpsOverrideRule -Exactly 0
            }

            It 'Should update the comment on the rule from the Set method' {
                $commentParams = @{
                    IsSingleInstance = 'Yes'
                    Comment          = 'Reviewed by the security operations team'
                    Ensure           = 'Present'
                    Credential       = $Credential
                }

                (New-M365DSCResourceInstance -ResourceName 'EXOSecOpsOverrideRule' -Property $commentParams).Set()
                Should -Invoke -CommandName Set-ExoSecOpsOverrideRule -Exactly 1 -ParameterFilter {
                    $Identity -eq '_Exe:SecOpsOverrid:ca3c51ac-925c-49f4-af42-43e26b874245' -and $Comment -eq 'Reviewed by the security operations team'
                }
                Should -Invoke -CommandName Set-SecOpsOverridePolicy -Exactly 0
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
                $result = Invoke-M365DSCResourceMethod -ResourceName 'EXOSecOpsOverrideRule' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
                $result | Should -Match 'IsSingleInstance\s+=\s+"Yes"'
                $result | Should -Not -Match 'legacy@contoso\.com'
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
