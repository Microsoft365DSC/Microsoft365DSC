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
    -DscResource 'O365SearchAndIntelligenceConfigurations' -GenericStubModule $GenericStubPath

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

            Mock -CommandName Update-MgBetaOrganizationSettingItemInsight -MockWith {
            }

            Mock -CommandName Update-MgBetaOrganizationSettingPersonInsight -MockWith {
            }

            Mock -CommandName Get-MgGroup -MockWith {
                return @{
                    Id          = "12345-12345-12345-12345-12345"
                    DisplayName = "TestGroup"
                }
            }

            Mock -CommandName Get-MgBetaOrganizationSettingItemInsight -MockWith {
                return @{
                    IsEnabledInOrganization = $True
                    DisabledForGroup        = "12345-12345-12345-12345-12345"
                }
            }

            Mock -CommandName Get-MgBetaOrganizationSettingPersonInsight -MockWith {
                return @{
                    IsEnabledInOrganization = $True
                    DisabledForGroup        = $null
                }
            }

            Mock -CommandName Get-MeetingInsightsSettings -MockWith {
                return "Meeting Insights setting enabled: false"
            }

            Mock -CommandName Set-MeetingInsightsSettings -MockWith {
            }
        }

        # Test contexts
        Context -Name 'When Org Settings are already in the Desired State' -Fixture {
            BeforeAll {
                $testParams = @{
                    IsSingleInstance                       = 'Yes'
                    ItemInsightsIsEnabledInOrganization    = $True;
                    ItemInsightsDisabledForGroup           = "TestGroup"
                    PersonInsightsIsEnabledInOrganization  = $True;
                    MeetingInsightsIsEnabledInOrganization = $false;
                    Credential                             = $Credential
                }
            }

            It 'Should return Present from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'O365SearchAndIntelligenceConfigurations' -Property $testParams).Get().ToHashtable()).ItemInsightsIsEnabledInOrganization | Should -Be $True
            }

            It 'Should return true from the Test method' {
                ((New-M365DSCResourceInstance -ResourceName 'O365SearchAndIntelligenceConfigurations' -Property $testParams).Test()) | Should -Be $true
            }
        }

        # Test contexts
        Context -Name 'When Org Settings are NOT in the Desired State' -Fixture {
            BeforeAll {
                $testParams = @{
                    IsSingleInstance                      = 'Yes'
                    ItemInsightsIsEnabledInOrganization   = $False; # Drift
                    ItemInsightsDisabledForGroup          = "TestGroup"
                    PersonInsightsIsEnabledInOrganization = $True;
                    Credential                            = $Credential
                }
            }

            It 'Should return Present from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'O365SearchAndIntelligenceConfigurations' -Property $testParams).Get().ToHashtable()).ItemInsightsIsEnabledInOrganization | Should -Be $True
            }

            It 'Should return false from the Test method' {
                ((New-M365DSCResourceInstance -ResourceName 'O365SearchAndIntelligenceConfigurations' -Property $testParams).Test()) | Should -Be $false
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
                $result = Invoke-M365DSCResourceMethod -ResourceName 'O365SearchAndIntelligenceConfigurations' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
