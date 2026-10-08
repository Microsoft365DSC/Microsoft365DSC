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
    -DscResource 'SPOHomeSite' -GenericStubModule $GenericStubPath

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

            # Mock Write-M365DSCHost to hide output during the tests
            Mock -CommandName Write-M365DSCHost -MockWith {
            }
            $Script:exportedInstances =$null
            $Script:ExportMode = $false
        }

        # Test contexts
        Context -Name 'When there should be no home site set' -Fixture {
            BeforeAll {
                $testParams = @{
                    IsSingleInstance = 'Yes'
                    Credential       = $Credential
                    Ensure           = 'Absent'
                }

                Mock -CommandName Get-PnPHomeSite -MockWith {
                    return $null
                }
            }

            It 'Should return Absent from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'SPOHomeSite' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Absent'
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'SPOHomeSite' -Property $testParams).Test() | Should -Be $true
            }
        }

        Context -Name 'When there is a home site and there should not be' -Fixture {
            BeforeAll {
                $testParams = @{
                    IsSingleInstance = 'Yes'
                    Credential       = $Credential
                    Ensure           = 'Absent'
                }

                Mock -CommandName Get-PnPHomeSite -MockWith {
                    return 'https://contoso.sharepoint.com/sites/homesite'
                }

                Mock -CommandName Remove-PnPHomeSite -MockWith {

                }
            }

            It 'Should return present from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'SPOHomeSite' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'SPOHomeSite' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should call Remove-PnPHomeSite' {
                (New-M365DSCResourceInstance -ResourceName 'SPOHomeSite' -Property $testParams).Set()
                Should -Invoke -CommandName Remove-PnPHomeSite -Exactly 1
            }
        }

        Context -Name "When there should be a home site set and there is not or it's the wrong one" -Fixture {
            BeforeAll {
                $testParams = @{
                    IsSingleInstance = 'Yes'
                    Url              = 'https://contoso.sharepoint.com/sites/homesite'
                    Credential       = $Credential
                    Ensure           = 'Present'
                }

                Mock -CommandName Get-PnPHomeSite -MockWith {
                    return 'https://contoso.sharepoint.com/sites/wrong'
                }

                Mock -CommandName Get-PnPTenantSite -MockWith {
                    throw
                }

                Mock -CommandName Set-PnPHomeSite -MockWith {
                }

                Mock -CommandName New-M365DSCLogEntry -ModuleName '_Shared' -MockWith {
                }
            }

            It 'Should return Present from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'SPOHomeSite' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'SPOHomeSite' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should throw an error' {
                { (New-M365DSCResourceInstance -ResourceName 'SPOHomeSite' -Property $testParams).Set() } | Should -Throw "The specified Site Collection $($testParams.Url) for SPOHomeSite doesn't exist."
                Should -Invoke -CommandName Get-PnPTenantSite -Exactly 1
                Should -Invoke -CommandName New-M365DSCLogEntry -ModuleName '_Shared' -Exactly 1
            }
        }

        Context -Name 'It should set the home site' -Fixture {
            BeforeAll {
                $testParams = @{
                    IsSingleInstance = 'Yes'
                    Url              = 'https://contoso.sharepoint.com/sites/homesite'
                    Credential       = $Credential
                    Ensure           = 'Present'
                }

                Mock -CommandName Get-PnPHomeSite -MockWith {
                    return 'https://contoso.sharepoint.com/sites/homesite1'
                }

                Mock -CommandName Set-PnPHomeSite -MockWith {
                }

                Mock -CommandName Get-PnPTenantSite -MockWith {

                }
            }

            It 'Should set the correct site' {
                (New-M365DSCResourceInstance -ResourceName 'SPOHomeSite' -Property $testParams).Set()
                Should -Invoke -CommandName Get-PnPTenantSite -Exactly 1
                Should -Invoke -CommandName Set-PnPHomeSite -Exactly 1
            }
        }

        Context -Name 'ReverseDSC Tests' -Fixture {
            BeforeAll {
                $Global:CurrentModeIsExport = $true
                $Global:PartialExportFileName = "$(New-Guid).partial.ps1"
                $testParams = @{
                    Credential = $Credential
                }

                Mock -CommandName Get-PnPHomeSite -MockWith {
                    return 'https://contoso.sharepoint.com/sites/TestSite'
                }
            }

            It 'Should Reverse Engineer resource from the Export method' {
                $result = Invoke-M365DSCResourceMethod -ResourceName 'SPOHomeSite' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
