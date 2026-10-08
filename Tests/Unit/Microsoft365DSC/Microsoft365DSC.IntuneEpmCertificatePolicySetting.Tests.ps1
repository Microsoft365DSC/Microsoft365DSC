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
    -DscResource "IntuneEpmCertificatePolicySetting" -GenericStubModule $GenericStubPath
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

            Mock -CommandName Invoke-M365DSCGraphRequest -MockWith {
            }

            $baseBody = @{
                id          = 'FakeStringValue'
                displayName = 'FakeStringValue'
                description = 'FakeStringValue'
                settingDefinitionId = 'device_vendor_msft_policy_privilegemanagement_reusablesettings_certificatefile'
                settingInstance = @{
                    '@odata.type' = '#microsoft.graph.deviceManagementConfigurationSimpleSettingInstance'
                    settingDefinitionId = 'device_vendor_msft_policy_privilegemanagement_reusablesettings_certificatefile'
                    simpleSettingValue = @{
                        '@odata.type' = '#microsoft.graph.deviceManagementConfigurationStringSettingValue'
                        value = 'FakeStringValue'
                    }
                }
            }

            Mock -CommandName Invoke-M365DSCGraphRequest -ParameterFilter { $Uri -match "reusablePolicySettings\/FakeStringValue\?*" -and $Method -eq 'GET' } -MockWith {
                return $baseBody
            }

            Mock -CommandName Invoke-M365DSCGraphRequest -ParameterFilter { $Uri -match "reusablePolicySettings\?" -and $Method -eq 'GET' } -MockWith {
                return @{
                    value = @($baseBody)
                }
            }

            Mock -CommandName Get-M365DSCExportCachedCollection -MockWith {
                return @($baseBody)
            }

            Mock -CommandName New-M365DSCConnection -ModuleName '_Shared' -MockWith {
                return "Credentials"
            }

            # Mock Write-M365DSCHost to hide output during the tests
            Mock -CommandName Write-M365DSCHost -MockWith {
            }
            $Script:exportedInstance = $null
            $Script:ExportMode = $false
        }

        # Test contexts
        Context -Name "The IntuneEpmCertificatePolicySetting should exist but it DOES NOT" -Fixture {
            BeforeAll {
                $testParams = @{
                    Id          = 'FakeStringValue'
                    DisplayName = 'FakeStringValue'
                    Description = 'FakeStringValue'
                    CertificateFile = "FakeStringValue"
                    Ensure = 'Present'
                    Credential = $Credential;
                }

                Mock -CommandName Invoke-M365DSCGraphRequest -ParameterFilter { $Method -eq 'GET' } -MockWith {
                    return $null
                }
            }
            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'IntuneEpmCertificatePolicySetting' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Absent'
            }
            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneEpmCertificatePolicySetting' -Property $testParams).Test() | Should -Be $false
            }
            It 'Should Create the group from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneEpmCertificatePolicySetting' -Property $testParams).Set()
                Should -Invoke -CommandName Invoke-M365DSCGraphRequest -ParameterFilter { $Method -eq 'POST' } -Exactly 1
            }
        }

        Context -Name "The IntuneEpmCertificatePolicySetting exists but it SHOULD NOT" -Fixture {
            BeforeAll {
                $testParams = @{
                    Id          = 'FakeStringValue'
                    DisplayName = 'FakeStringValue'
                    Description = 'FakeStringValue'
                    CertificateFile = "FakeStringValue"
                    Ensure = 'Absent'
                    Credential = $Credential;
                }
            }

            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'IntuneEpmCertificatePolicySetting' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneEpmCertificatePolicySetting' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should Remove the group from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneEpmCertificatePolicySetting' -Property $testParams).Set()
                Should -Invoke -CommandName Invoke-M365DSCGraphRequest -ParameterFilter { $Method -eq 'DELETE' } -Exactly 1
            }
        }

        Context -Name "The IntuneEpmCertificatePolicySetting Exists and Values are already in the desired state" -Fixture {
            BeforeAll {
                $testParams = @{
                    Id          = 'FakeStringValue'
                    DisplayName = 'FakeStringValue'
                    Description = 'FakeStringValue'
                    CertificateFile = "FakeStringValue"
                    Ensure = 'Present'
                    Credential = $Credential;
                }
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneEpmCertificatePolicySetting' -Property $testParams).Test() | Should -Be $true
            }
        }

        Context -Name "The IntuneEpmCertificatePolicySetting exists and values are NOT in the desired state" -Fixture {
            BeforeAll {
                $testParams = @{
                    Id          = 'FakeStringValue'
                    DisplayName = 'FakeStringValue'
                    Description = 'FakeStringValue'
                    CertificateFile = "FakeStringValue2" # Drift
                    Ensure = 'Present'
                    Credential = $Credential;
                }
            }

            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'IntuneEpmCertificatePolicySetting' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneEpmCertificatePolicySetting' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should call the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneEpmCertificatePolicySetting' -Property $testParams).Set()
                Should -Invoke -CommandName Invoke-M365DSCGraphRequest -ParameterFilter { $Method -eq 'PUT' } -Exactly 1
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
                $result = Invoke-M365DSCResourceMethod -ResourceName 'IntuneEpmCertificatePolicySetting' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
