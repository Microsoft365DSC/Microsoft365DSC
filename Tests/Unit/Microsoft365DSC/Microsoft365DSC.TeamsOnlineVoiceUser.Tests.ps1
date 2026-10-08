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
    -DscResource 'TeamsOnlineVoiceUser' -GenericStubModule $GenericStubPath

Describe -Name $Global:DscHelper.DescribeHeader -Fixture {
    InModuleScope -ModuleName $Global:DscHelper.ModuleName -ScriptBlock {
        Invoke-Command -ScriptBlock $Global:DscHelper.InitializeScript -NoNewScope

        BeforeAll {
            $secpasswd = ConvertTo-SecureString ((New-Guid).ToString()) -AsPlainText -Force
            $Credential = New-Object System.Management.Automation.PSCredential ('tenantadmin@onmicrosoft.com', $secpasswd)

            $Global:PartialExportFileName = 'c:\TestPath'

            Mock -ModuleName M365DSCUtil -CommandName Confirm-M365DSCDependencies -MockWith {
            }

            Mock -CommandName Save-M365DSCPartialExport -MockWith {
            }

            Mock -CommandName New-M365DSCConnection -ModuleName '_Shared' -MockWith {
                return 'Credentials'
            }

            Mock -CommandName Set-CsPhoneNumberAssignment -MockWith {
            }

            Mock -CommandName Get-CsPhoneNumberAssignment -MockWith {
                return @{
                    LocationId = 'c7c5a17f-00d7-47c0-9ddb-3383229d606b'
                    NumberType = 'DirectRouting'
                }
            }

            Mock -CommandName Get-CsOnlineUser -MockWith {
                return @{
                    LineUri           = 'tel:+14255043920'
                    UserPrincipalName = 'John.Smith@Contoso.com'
                }
            }

            # Mock Write-M365DSCHost to hide output during the tests
            Mock -CommandName Write-M365DSCHost -MockWith {
            }
            $Script:exportedInstances =$null
            $Script:ExportMode = $false
        }

        # Test contexts
        Context -Name "When the user isn't assigned" -Fixture {
            BeforeAll {
                $testParams = @{
                    Identity        = 'John.Smith@Contoso.com'
                    TelephoneNumber = '14255043920'
                    LocationId      = 'c7c5a17f-00d7-47c0-9ddb-3383229d606b'
                    Ensure          = 'Present'
                    Credential      = $Credential
                }

                Mock -CommandName Get-CsOnlineUser -MockWith {
                    return $null
                }
            }

            It 'Should return absent from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'TeamsOnlineVoiceUser' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Absent'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'TeamsOnlineVoiceUser' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should create the policy from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'TeamsOnlineVoiceUser' -Property $testParams).Set()
                Should -Invoke -CommandName 'Set-CsPhoneNumberAssignment' -Exactly 1
            }
        }

        Context -Name 'When the assignment already exists and IS in the Desired State' -Fixture {
            BeforeAll {
                $testParams = @{
                    Identity        = 'John.Smith@Contoso.com'
                    TelephoneNumber = '14255043920'
                    LocationId      = 'c7c5a17f-00d7-47c0-9ddb-3383229d606b'
                    Ensure          = 'Present'
                    Credential      = $Credential
                }
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'TeamsOnlineVoiceUser' -Property $testParams).Test() | Should -Be $true
            }
        }

        Context -Name 'When the assignment already exists but is NOT in the desired state' -Fixture {
            BeforeAll {
                $testParams = @{
                    Identity        = 'John.Smith@Contoso.com'
                    TelephoneNumber = '15555555555' # Drift
                    LocationId      = 'c7c5a17f-00d7-47c0-9ddb-3383229d606b'
                    Ensure          = 'Present'
                    Credential      = $Credential
                }
            }

            It 'Should return Present from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'TeamsOnlineVoiceUser' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'TeamsOnlineVoiceUser' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should remove the policy from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'TeamsOnlineVoiceUser' -Property $testParams).Set()
                Should -Invoke -CommandName Get-CsPhoneNumberAssignment -Exactly 1 -ParameterFilter { $TelephoneNumber -eq '15555555555' }
                Should -Invoke -CommandName Set-CsPhoneNumberAssignment -Exactly 1 -ParameterFilter { $TelephoneNumber -eq '15555555555' -and $NumberType -eq 'DirectRouting' }
            }

            It 'Should throw from the Set method when the telephone number is missing or does not exist' {
                $noNumberParams = $testParams.Clone()
                $noNumberParams.Remove('TelephoneNumber')
                { (New-M365DSCResourceInstance -ResourceName 'TeamsOnlineVoiceUser' -Property $noNumberParams).Set() } | Should -Throw -ExpectedMessage '*TelephoneNumber is required*'
                Mock -CommandName Get-CsPhoneNumberAssignment -MockWith {
                    return $null
                }
                { (New-M365DSCResourceInstance -ResourceName 'TeamsOnlineVoiceUser' -Property $testParams).Set() } | Should -Throw -ExpectedMessage '*{15555555555}*does not exist in the tenant*'
                Should -Invoke -CommandName Set-CsPhoneNumberAssignment -Exactly 0
            }
        }

        Context -Name 'ReverseDSC Tests' -Fixture {
            BeforeAll {
                $testParams = @{
                    Credential = $Credential
                }
            }

            It 'Should Reverse Engineer resource from the Export method' {
                $result = Invoke-M365DSCResourceMethod -ResourceName 'TeamsOnlineVoiceUser' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
