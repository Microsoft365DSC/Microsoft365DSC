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
    -DscResource 'TeamsM365App' -GenericStubModule $GenericStubPath

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

            Mock -CommandName Get-MgGroup -MockWith {
                return @{
                    DisplayName = "Finance Team"
                    Id = "12345-12345-12345-12345-12345"
                }
            }

            Mock -CommandName Get-M365TeamsApp -MockWith {
                return @{
                    IsBlocked = $false
                    AvailableTo = @{
                        AssignmentType = "UsersAndGroups"
                        Groups = @("12345-12345-12345-12345-12345")
                    }
                    Id = "95de633a-083e-42f5-b444-a4295d8e9314"
                }
            }

            Mock -CommandName New-M365DSCConnection -ModuleName '_Shared' -MockWith {
                return 'Credentials'
            }

            Mock -CommandName Update-M365TeamsApp -MockWith {
            }

            # Mock Write-M365DSCHost to hide output during the tests
            Mock -CommandName Write-M365DSCHost -MockWith {
            }
            $Script:exportedInstances =$null
            $Script:ExportMode = $false
        }

        # Test contexts
        Context -Name "The instance is already in the desired state" -Fixture {
            BeforeAll {
                $testParams = @{
                    AssignmentType       = "UsersAndGroups";
                    Groups               = @("Finance Team");
                    Id                   = "95de633a-083e-42f5-b444-a4295d8e9314";
                    IsBlocked            = $False;
                    Users                = @();
                    Credential = $Credential
                }
            }

            It 'Should return true from the Test method' {
                [boolean] $result = (New-M365DSCResourceInstance -ResourceName 'TeamsM365App' -Property $testParams).Test()
                $result | Should -Be $true
            }
        }

        Context -Name "The instance is NOT in the desired state" -Fixture {
            BeforeAll {
                $testParams = @{
                    AssignmentType       = "UsersAndGroups";
                    Groups               = @();
                    Id                   = "95de633a-083e-42f5-b444-a4295d8e9314";
                    IsBlocked            = $False;
                    Users                = @("john.smith@contoso.com"); # Drift
                    Credential           = $Credential
                }

                Mock -CommandName Get-MgUser -MockWith {
                    return @{
                        UserPrincipalName = "john.smith@contoso.com"
                        Id = "12345-12345-12345-12345-12345"
                    }
                }
            }

            It 'Should return false from the Test method' {
                [boolean] $result = (New-M365DSCResourceInstance -ResourceName 'TeamsM365App' -Property $testParams).Test()
                $result | Should -Be $false
            }

            It 'Update the instance in the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'TeamsM365App' -Property $testParams).Set()
                Should -Invoke -CommandName Update-M365TeamsApp -Exactly 2
            }
        }

        Context -Name 'ReverseDSC Tests' -Fixture {
            BeforeAll {
                $Global:CurrentModeIsExport = $true
                $Global:PartialExportFileName = "$(New-Guid).partial.ps1"
                $testParams = @{
                    Credential = $Credential
                }

                Mock -CommandName Get-AllM365TeamsApps -MockWith {
                    return @{
                        IsBlocked = $false
                        AvailableTo = @{
                            AssignmentType = "UsersAndGroups"
                            Groups = @("12345-12345-12345-12345-12345")
                        }
                        Id = "95de633a-083e-42f5-b444-a4295d8e9314"
                    }
                }
            }

            It 'Should Reverse Engineer resource from the Export method' {
                $result = Invoke-M365DSCResourceMethod -ResourceName 'TeamsM365App' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
