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
    -DscResource "IntuneDeviceEnrollmentScopeConfigurationMam" -GenericStubModule $GenericStubPath
Describe -Name $Global:DscHelper.DescribeHeader -Fixture {
    InModuleScope -ModuleName $Global:DscHelper.ModuleName -ScriptBlock {
        Invoke-Command -ScriptBlock $Global:DscHelper.InitializeScript -NoNewScope
        BeforeAll {

            $secpasswd = ConvertTo-SecureString (New-Guid | Out-String) -AsPlainText -Force
            $Credential = New-Object System.Management.Automation.PSCredential ('tenantadmin@onmicrosoft.com', $secpasswd)

            Mock -ModuleName M365DSCUtil -CommandName Confirm-M365DSCDependencies -MockWith {
            }

            Mock -CommandName Get-MSCloudLoginConnectionProfile -MockWith {
            }

            Mock -CommandName Reset-MSCloudLoginConnectionProfileContext -MockWith {
            }

            Mock -CommandName Get-PSSession -MockWith {
            }

            Mock -CommandName Remove-PSSession -MockWith {
            }

            Mock -CommandName Update-MgBetaPolicyMobileAppManagementPolicy -MockWith {
            }

            Mock -CommandName Invoke-M365DSCGraphBatchRequest -MockWith {
            }

            Mock -CommandName Get-MgBetaPolicyMobileAppManagementPolicy -MockWith {
                return @{
                    AppliesTo = "Selected"
                    ComplianceUrl = "FakeStringValue"
                    Description = "FakeStringValue"
                    DiscoveryUrl = "FakeStringValue"
                    DisplayName = "FakeStringValue"
                    Id = "FakeStringValue"
                    IncludedGroups = @(
                        @{
                            DisplayName = "FakeGroup1"
                            Id = "FakeId1"
                        }
                    )
                    IsValid = $True
                    TermsOfUseUrl = "FakeStringValue"
                }
            }

            Mock -CommandName Get-MgGroup -ParameterFilter { $Filter -eq "displayName eq 'FakeGroup1'" } -MockWith {
                return @{
                    DisplayName = "FakeGroup1"
                    Id = "FakeId1"
                }
            }

            Mock -CommandName Get-MgGroup -ParameterFilter { $Filter -eq "displayName eq 'FakeGroup2'" } -MockWith {
                return @{
                    DisplayName = "FakeGroup2"
                    Id = "FakeId2"
                }
            }

            Mock -CommandName Update-MgBetaPolicyMobileAppManagementPolicy -MockWith {
            }

            Mock -CommandName New-M365DSCConnection -ModuleName '_Shared' -MockWith {
                return "Credentials"
            }

            Mock -CommandName Invoke-M365DSCGraphRequest -MockWith {
            }

            # Mock Write-M365DSCHost to hide output during the tests
            Mock -CommandName Write-M365DSCHost -MockWith {
            }
            $Script:exportedInstance = $null
            $Script:ExportMode = $false
        }

        # Test contexts
        Context -Name "The IntuneDeviceEnrollmentScopeConfigurationMam Exists and Values are already in the desired state" -Fixture {
            BeforeAll {
                $testParams = @{
                    AppliesTo = "Selected"
                    ComplianceUrl = "FakeStringValue"
                    DiscoveryUrl = "FakeStringValue"
                    IncludedGroups = @("FakeGroup1")
                    TermsOfUseUrl = "FakeStringValue"
                    IsSingleInstance = 'Yes'
                    Credential = $Credential;
                }
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneDeviceEnrollmentScopeConfigurationMam' -Property $testParams).Test() | Should -Be $true
            }
        }

        Context -Name "The IntuneDeviceEnrollmentScopeConfigurationMam exists and values are NOT in the desired state" -Fixture {
            BeforeAll {
                $testParams = @{
                    AppliesTo = "Selected"
                    ComplianceUrl = "FakeStringValue"
                    DiscoveryUrl = "FakeStringValue"
                    IncludedGroups = @("FakeGroup1", "FakeGroup2")
                    TermsOfUseUrl = "FakeStringValue"
                    IsSingleInstance = 'Yes'
                    Credential = $Credential;
                }
            }

            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'IntuneDeviceEnrollmentScopeConfigurationMam' -Property $testParams).Get().ToHashtable()).IsSingleInstance | Should -Be 'Yes'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneDeviceEnrollmentScopeConfigurationMam' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should call the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneDeviceEnrollmentScopeConfigurationMam' -Property $testParams).Set()
                Should -Invoke -CommandName Update-MgBetaPolicyMobileAppManagementPolicy -Exactly 1
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
                $result = Invoke-M365DSCResourceMethod -ResourceName 'IntuneDeviceEnrollmentScopeConfigurationMam' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
