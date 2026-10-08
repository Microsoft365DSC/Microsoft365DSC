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
    -DscResource "IntuneDeviceComplianceScriptWindows10" -GenericStubModule $GenericStubPath
Describe -Name $Global:DscHelper.DescribeHeader -Fixture {
    InModuleScope -ModuleName $Global:DscHelper.ModuleName -ScriptBlock {
        Invoke-Command -ScriptBlock $Global:DscHelper.InitializeScript -NoNewScope
        BeforeAll {

            $secpasswd = ConvertTo-SecureString (New-Guid | Out-String) -AsPlainText -Force
            $Credential = New-Object System.Management.Automation.PSCredential ('tenantadmin@onmicrosoft.com', $secpasswd)

            Mock -ModuleName M365DSCUtil -CommandName Confirm-M365DSCDependencies -MockWith {
            }

            Mock -CommandName Get-PSSession -MockWith {
            }

            Mock -CommandName Remove-PSSession -MockWith {
            }

            Mock -CommandName Invoke-M365DSCGraphRequest -MockWith {
            }

            Mock -CommandName New-M365DSCConnection -ModuleName '_Shared' -MockWith {
                return "Credentials"
            }

            # Mock Write-M365DSCHost to hide output during the tests
            Mock -CommandName Write-M365DSCHost -MockWith {
            }
            $Script:exportedInstances =$null
            $Script:ExportMode = $false

            $allComplianceScripts = @{
                value = @(
                    @{
                        Description = "FakeStringValue"
                        DisplayName = "DeviceComplianceScript"
                        EnforceSignatureCheck = $true
                        Id = "12345-12345-12345-12345-12345"
                        Publisher = "FakeStringValue"
                        RoleScopeTagIds = @("FakeStringValue")
                        RunAsAccount = "system"
                        RunAs32Bit = $true
                        DetectionScriptContent = ""
                    }
                )
            }

            $specificComplianceScript = @{
                Description = "FakeStringValue"
                DisplayName = "DeviceComplianceScript"
                EnforceSignatureCheck = $true
                Id = "12345-12345-12345-12345-12345"
                Publisher = "FakeStringValue"
                RoleScopeTagIds = @("FakeStringValue")
                RunAsAccount = "system"
                RunAs32Bit = $true
                DetectionScriptContent = "V3JpdGUtT3V0cHV0ICR0cnVl"
            }

            $noComplianceScripts = @{
                value = @()
            }
        }
        # Test contexts
        Context -Name "The IntuneDeviceComplianceScriptWindows10 should exist but it DOES NOT" -Fixture {
            BeforeAll {
                $testParams = @{
                    Description = "FakeStringValue"
                    DisplayName = "DeviceComplianceScript"
                    EnforceSignatureCheck = $True
                    Publisher = "FakeStringValue"
                    RoleScopeTagIds = @("FakeStringValue")
                    RunAs32Bit = $True
                    RunAsAccount = "system"
                    DetectionScriptContent = "Write-Output `$true"
                    Ensure = "Present"
                    Credential = $Credential
                }

                Mock -CommandName Invoke-M365DSCGraphRequest -ParameterFilter { $Method -eq 'GET' -and $Uri -eq '/beta/deviceManagement/deviceComplianceScripts' } -MockWith {
                    return $noComplianceScripts
                }

                Mock -CommandName Invoke-M365DSCGraphRequest -ParameterFilter { $Method -eq 'GET' -and $Uri -eq '/beta/deviceManagement/deviceComplianceScripts/' } -MockWith {
                    return $allComplianceScripts
                }
            }

            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'IntuneDeviceComplianceScriptWindows10' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Absent'
                Should -Invoke -CommandName Invoke-M365DSCGraphRequest -ParameterFilter { $Uri -eq '/beta/deviceManagement/deviceComplianceScripts/' } -Exactly 0
                Should -Invoke -CommandName Invoke-M365DSCGraphRequest -ParameterFilter { $Uri -eq '/beta/deviceManagement/deviceComplianceScripts?$filter=DisplayName eq ''DeviceComplianceScript'' and platform eq ''windows10''' } -Exactly 1
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneDeviceComplianceScriptWindows10' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should Create the Intune Device Compliance Script for Windows10 from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneDeviceComplianceScriptWindows10' -Property $testParams).Set()
                Should -Invoke -CommandName Invoke-M365DSCGraphRequest -ParameterFilter { $Method -eq 'POST' } -Exactly 1
            }
        }

        Context -Name "The IntuneDeviceComplianceScriptWindows10 exists but it SHOULD NOT" -Fixture {
            BeforeAll {
                $testParams = @{
                    Description = "FakeStringValue"
                    DisplayName = "DeviceComplianceScript"
                    EnforceSignatureCheck = $True
                    Id = "12345-12345-12345-12345-12345"
                    Publisher = "FakeStringValue"
                    RoleScopeTagIds = @("FakeStringValue")
                    RunAs32Bit = $True
                    RunAsAccount = "system"
                    DetectionScriptContent = "Write-Output `$true"
                    Ensure = "Absent"
                    Credential = $Credential
                }

                Mock -CommandName Invoke-M365DSCGraphRequest -ParameterFilter { $Method -eq 'GET' -and $Uri -eq '/beta/deviceManagement/deviceComplianceScripts' } -MockWith {
                    return $allComplianceScripts
                }

                Mock -CommandName Invoke-M365DSCGraphRequest -ParameterFilter { $Method -eq 'GET' -and $Uri -eq '/beta/deviceManagement/deviceComplianceScripts/12345-12345-12345-12345-12345' } -MockWith {
                    return $specificComplianceScript
                }
            }

            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'IntuneDeviceComplianceScriptWindows10' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneDeviceComplianceScriptWindows10' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should Remove the group from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneDeviceComplianceScriptWindows10' -Property $testParams).Set()
                Should -Invoke -CommandName Invoke-M365DSCGraphRequest -ParameterFilter { $Method -eq 'DELETE' } -Exactly 1
            }
        }
        Context -Name "The IntuneDeviceComplianceScriptWindows10 Exists and Values are already in the desired state" -Fixture {
            BeforeAll {
                $testParams = @{
                    Description = "FakeStringValue"
                    DisplayName = "DeviceComplianceScript"
                    EnforceSignatureCheck = $True
                    Id = "12345-12345-12345-12345-12345"
                    Publisher = "FakeStringValue"
                    RoleScopeTagIds = @("FakeStringValue")
                    RunAs32Bit = $True
                    RunAsAccount = "system"
                    DetectionScriptContent = "Write-Output `$true"
                    Ensure = "Present"
                    Credential = $Credential
                }

                Mock -CommandName Invoke-M365DSCGraphRequest -ParameterFilter { $Method -eq 'GET' -and $Uri -eq '/beta/deviceManagement/deviceComplianceScripts' } -MockWith {
                    return $allComplianceScripts
                }

                Mock -CommandName Invoke-M365DSCGraphRequest -ParameterFilter { $Method -eq 'GET' -and $Uri -eq '/beta/deviceManagement/deviceComplianceScripts/12345-12345-12345-12345-12345' } -MockWith {
                    return $specificComplianceScript
                }
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneDeviceComplianceScriptWindows10' -Property $testParams).Test() | Should -Be $true
            }
        }

        Context -Name "The IntuneDeviceComplianceScriptWindows10 exists and values are NOT in the desired state" -Fixture {
            BeforeAll {
                $testParams = @{
                    Description = "FakeStringValue"
                    DisplayName = "DeviceComplianceScript"
                    EnforceSignatureCheck = $True
                    Id = "12345-12345-12345-12345-12345"
                    Publisher = "FakeStringValue"
                    RoleScopeTagIds = @("FakeStringValue")
                    RunAs32Bit = $False #Drift
                    RunAsAccount = "system"
                    DetectionScriptContent = "Write-Output `$false" #Drift
                    Ensure = "Present"
                    Credential = $Credential
                }

                Mock -CommandName Invoke-M365DSCGraphRequest -ParameterFilter { $Method -eq 'GET' -and $Uri -eq '/beta/deviceManagement/deviceComplianceScripts' } -MockWith {
                    return $allComplianceScripts
                }

                Mock -CommandName Invoke-M365DSCGraphRequest -ParameterFilter { $Method -eq 'GET' -and $Uri -eq '/beta/deviceManagement/deviceComplianceScripts/12345-12345-12345-12345-12345' } -MockWith {
                    return $specificComplianceScript
                }
            }

            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'IntuneDeviceComplianceScriptWindows10' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneDeviceComplianceScriptWindows10' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should call the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneDeviceComplianceScriptWindows10' -Property $testParams).Set()
                Should -Invoke -CommandName Invoke-M365DSCGraphRequest -ParameterFilter { $Method -eq 'PATCH' } -Exactly 1
            }
        }

        Context -Name 'ReverseDSC Tests' -Fixture {
            BeforeAll {
                $Global:CurrentModeIsExport = $true
                $Global:PartialExportFileName = "$(New-Guid).partial.ps1"
                $testParams = @{
                    Credential = $Credential
                }

                Mock -CommandName Invoke-M365DSCGraphRequest -ParameterFilter { $Method -eq 'GET' -and $Uri -eq '/beta/deviceManagement/deviceComplianceScripts' } -MockWith {
                    return $allComplianceScripts
                }

                Mock -CommandName Invoke-M365DSCGraphRequest -ParameterFilter { $Method -eq 'GET' -and $Uri -eq '/beta/deviceManagement/deviceComplianceScripts/12345-12345-12345-12345-12345' } -MockWith {
                    return $specificComplianceScript
                }
            }

            It 'Should Reverse Engineer resource from the Export method' {
                $result = Invoke-M365DSCResourceMethod -ResourceName 'IntuneDeviceComplianceScriptWindows10' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
