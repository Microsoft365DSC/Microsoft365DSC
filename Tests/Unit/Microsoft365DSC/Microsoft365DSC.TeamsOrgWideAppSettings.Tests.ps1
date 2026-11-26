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
    -DscResource 'TeamsOrgWideAppSettings' -GenericStubModule $GenericStubPath

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

            Mock -CommandName Set-CsTeamsSettingsCustomApp -MockWith {
            }

            Mock -CommandName Get-CsTeamsSettingsCustomApp -MockWith {
                return @{
                    IsSideloadedAppsInteractionEnabled = $true
                }
            }

            Mock -CommandName Write-M365DSCHost -MockWith {
            }
            $Script:exportedInstance = $null
            $Script:ExportMode = $false
        }

        Context -Name 'The settings are already in the Desired State' -Fixture {
            BeforeAll {
                $testParams = @{
                    IsSingleInstance                   = 'Yes'
                    IsSideloadedAppsInteractionEnabled = $true
                    Credential                         = $Credential
                }
            }

            It 'Should return the values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'TeamsOrgWideAppSettings' -Property $testParams).Get().ToHashtable()).IsSideloadedAppsInteractionEnabled | Should -Be $true
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'TeamsOrgWideAppSettings' -Property $testParams).Test() | Should -Be $true
            }
        }

        Context -Name 'The settings are not in the Desired State' -Fixture {
            BeforeAll {
                $testParams = @{
                    IsSingleInstance                   = 'Yes'
                    IsSideloadedAppsInteractionEnabled = $false
                    ApplicationId                      = '12345-12345-12345'
                    TenantId                           = 'contoso.onmicrosoft.com'
                    CertificateThumbprint              = '123451234512345'
                }
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'TeamsOrgWideAppSettings' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should update the settings from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'TeamsOrgWideAppSettings' -Property $testParams).Set()
                Should -Invoke -CommandName Set-CsTeamsSettingsCustomApp -Exactly 1 -ParameterFilter {
                    $isSideloadedAppsInteractionEnabled -eq $false
                }
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
                $result = Invoke-M365DSCResourceMethod -ResourceName 'TeamsOrgWideAppSettings' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
