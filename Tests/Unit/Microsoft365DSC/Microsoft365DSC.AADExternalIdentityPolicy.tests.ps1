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
    -DscResource 'AADExternalIdentityPolicy' -GenericStubModule $GenericStubPath
Describe -Name $Global:DscHelper.DescribeHeader -Fixture {
    InModuleScope -ModuleName $Global:DscHelper.ModuleName -ScriptBlock {
        Invoke-Command -ScriptBlock $Global:DscHelper.InitializeScript -NoNewScope
        BeforeAll {
            $secpasswd = ConvertTo-SecureString (New-Guid | Out-String) -AsPlainText -Force
            $Credential = New-Object System.Management.Automation.PSCredential ('tenantadmin@onmicrosoft.com', $secpasswd)

            $Global:PartialExportFileName = 'c:\TestPath'

            Mock -ModuleName M365DSCUtil -CommandName Confirm-M365DSCDependencies -MockWith {
            }

            Mock -CommandName Save-M365DSCPartialExport -MockWith {
            }

            Mock -CommandName Get-PSSession -MockWith {
            }

            Mock -CommandName Remove-PSSession -MockWith {
            }

            Mock -CommandName Get-MgBetaPolicyExternalIdentityPolicy -MockWith {
                return @{
                    Id                                = 'externalidentitypolicy'
                    DisplayName                       = 'External Identity Policy'
                    AllowDeletedIdentitiesDataRemoval = $False;
                    AllowExternalIdentitiesToLeave    = $True;
                }
            }

            Mock -CommandName New-M365DSCConnection -ModuleName '_Shared' -MockWith {
                return 'Credentials'
            }

            # Mock Write-M365DSCHost to hide output during the tests
            Mock -CommandName Write-M365DSCHost -MockWith {
            }
            $Script:exportedInstances =$null
            $Script:ExportMode = $false
            Mock -CommandName Update-MgBetaPolicyExternalIdentityPolicy -MockWith {
            }
        }

        Context -Name 'The instance exists and values are already in the desired state' -Fixture {
            BeforeAll {
                $testParams = @{
                    IsSingleInstance                  = 'Yes'
                    AllowDeletedIdentitiesDataRemoval = $False;
                    AllowExternalIdentitiesToLeave    = $True;
                    Credential                        = $Credential
                }
            }

            It 'Should return Values from the get method' {
                (New-M365DSCResourceInstance -ResourceName 'AADExternalIdentityPolicy' -Property $testParams).Get().ToHashtable()
                Should -Invoke -CommandName 'Get-MgBetaPolicyExternalIdentityPolicy' -Exactly 1
            }

            It 'Should return true from the test method' {
                (New-M365DSCResourceInstance -ResourceName 'AADExternalIdentityPolicy' -Property $testParams).Test() | Should -Be $true
            }
        }

        Context -Name 'Values are not in the desired state' -Fixture {
            BeforeAll {
                $testParams = @{
                    IsSingleInstance                  = 'Yes'
                    AllowDeletedIdentitiesDataRemoval = $True; # Drift
                    AllowExternalIdentitiesToLeave    = $True;
                    Credential                        = $Credential
                }
            }

            It 'Should return values from the get method' {
                (New-M365DSCResourceInstance -ResourceName 'AADExternalIdentityPolicy' -Property $testParams).Get().ToHashtable()
                Should -Invoke -CommandName 'Get-MgBetaPolicyExternalIdentityPolicy' -Exactly 1
            }

            It 'Should return false from the test method' {
                (New-M365DSCResourceInstance -ResourceName 'AADExternalIdentityPolicy' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should call the set method' {
                (New-M365DSCResourceInstance -ResourceName 'AADExternalIdentityPolicy' -Property $testParams).Set()
                Should -Invoke -CommandName 'Update-MgBetaPolicyExternalIdentityPolicy' -Exactly 1
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

            It 'Should reverse engineer resource from the export method' {
                $result = Invoke-M365DSCResourceMethod -ResourceName 'AADExternalIdentityPolicy' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
