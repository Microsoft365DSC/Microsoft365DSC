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
    -DscResource 'SPOUserProfileProperty' -GenericStubModule $GenericStubPath

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

            Mock -CommandName Set-PnPUserProfileProperty -MockWith {
                return @{
                }
            }

            Mock -CommandName Get-M365DSCOrganization -MockWith {
                return 'contoso.com'
            }

            Mock -CommandName Get-PnPUserProfileProperty -MockWith {
                return @{
                    AccountName = 'john.smith@contoso.com'
                    MyOldKey = 'MyValue'
                }
            }

            Mock -CommandName Start-Job -MockWith {
            }

            Mock -CommandName Get-Job -MockWith {
            }

            # Mock Write-M365DSCHost to hide output during the tests
            Mock -CommandName Write-M365DSCHost -MockWith {
            }
            $Script:exportedInstances =$null
            $Script:ExportMode = $false

            Mock -CommandName Write-Warning -MockWith {
            }
        }

        # Test contexts
        Context -Name 'Properties are already set' -Fixture {
            BeforeAll {
                $testParams = @{
                    UserName   = 'john.smith@contoso.com'
                    Properties = ([MSFT_SPOUserProfilePropertyInstance] @{
                            Key   = 'MyKey'
                            Value = 'MyValue'
                        })
                    Credential = $Credential
                    Ensure     = 'Present'
                }
            }

            It 'Should return Present from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'SPOUserProfileProperty' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }
        }

        Context -Name 'Properties need to be set' -Fixture {
            BeforeAll {
                $testParams = @{
                    UserName   = 'john.smith@contoso.com'
                    Properties = ([MSFT_SPOUserProfilePropertyInstance] @{
                            Key   = 'MyNewKey'
                            Value = 'MyValue'
                        })
                    Credential = $Credential
                    Ensure     = 'Present'
                }
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'SPOUserProfileProperty' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should Update the settings from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'SPOUserProfileProperty' -Property $testParams).Set()
            }
        }

        Context -Name 'ReverseDSC Tests' -Fixture {
            BeforeAll {
                $Global:CurrentModeIsExport = $true
                $Global:PartialExportFileName = "$(New-Guid).partial.ps1"
                $testParams = @{
                    Credential = $Credential
                }

                Mock -CommandName Get-PnPUser -MockWith {
                    return @{
                        PrincipalType = 'User'
                        Email         = 'john.smith@contoso.com'
                    }
                }
            }

            It 'Should Reverse Engineer resource from the Export method' {
                $result = Invoke-M365DSCResourceMethod -ResourceName 'SPOUserProfileProperty' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }#inmodulescope
}#describe

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
