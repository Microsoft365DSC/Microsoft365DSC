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
    -DscResource 'IntuneDeviceConfigurationCustomPolicyMacOS' -GenericStubModule $GenericStubPath
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

            Mock -CommandName Add-M365DSCTelemetryEvent -ModuleName '_Shared' -MockWith {
            }

            Mock -CommandName New-M365DSCLogEntry -ModuleName '_Shared' -MockWith {
            }

            Mock -CommandName Get-PSSession -MockWith {
            }

            Mock -CommandName Remove-PSSession -MockWith {
            }

            Mock -CommandName New-MgBetaDeviceManagementDeviceConfiguration -MockWith {
            }

            Mock -CommandName Update-MgBetaDeviceManagementDeviceConfiguration -MockWith {
            }

            Mock -CommandName Remove-MgBetaDeviceManagementDeviceConfiguration -MockWith {
            }

            Mock -CommandName Get-MgBetaDeviceManagementDeviceConfiguration -MockWith {
                return @{
                    Assignments       = @(
                        @{
                            dataType                                   = '#microsoft.graph.allDevicesAssignmentTarget'
                            deviceAndAppManagementAssignmentFilterType = 'none'
                        }
                    )
                    Description       = 'FakeStringValue'
                    DisplayName       = 'FakeStringValue'
                    Id                = 'FakeStringValue'
                    RoleScopeTagIds   = @('FakeStringArrayValue1', 'FakeStringArrayValue2')
                    '@odata.type'     = '#microsoft.graph.macOSCustomConfiguration'
                    deploymentChannel = 'deviceChannel'
                    payload           = 'FakeStringValue'
                    payloadFileName   = 'FakeStringValue'
                    payloadName       = 'FakeStringValue'
                }
            }

            Mock -CommandName Get-M365DSCExportCachedCollection -MockWith {
                return Get-MgBetaDeviceManagementDeviceConfiguration
            }
            Mock -CommandName Get-MgBetaDeviceManagementDeviceConfigurationAssignment -MockWith {
            }

            Mock -CommandName Update-DeviceConfigurationPolicyAssignment -MockWith {
            }

            Mock -CommandName Write-M365DSCHost -MockWith {
            }

            Mock -CommandName Save-M365DSCPartialExport -MockWith {
            }

            Mock -CommandName Update-M365DSCExportAuthenticationResults -MockWith {
                return @{}
            }

            Mock -CommandName Get-M365DSCExportContentForResource -MockWith {
                return "IntuneDeviceConfigurationCustomPolicyMacOS 'TestInstance' {}`r`n"
            }

            $Script:exportedInstance = $null
            $Script:exportedInstances = $null
            $Script:ExportMode = $false
        }

        # Test contexts
        Context -Name 'The instance should exist but it DOES NOT' -Fixture {
            BeforeAll {
                $testParams = @{
                    DeploymentChannel = 'deviceChannel'
                    Description       = 'FakeStringValue'
                    DisplayName       = 'FakeStringValue'
                    Id                = 'FakeStringValue'
                    Payload           = 'FakeStringValue'
                    PayloadFileName   = 'FakeStringValue'
                    PayloadName       = 'FakeStringValue'
                    RoleScopeTagIds   = @('FakeStringArrayValue1', 'FakeStringArrayValue2')
                    Ensure            = 'Present'
                    Credential        = $Credential
                }

                Mock -CommandName Get-MgBetaDeviceManagementDeviceConfiguration -MockWith {
                    return $null
                }
            }

            It 'Should return Absent from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'IntuneDeviceConfigurationCustomPolicyMacOS' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Absent'
                Should -Invoke -CommandName 'Get-MgBetaDeviceManagementDeviceConfiguration'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneDeviceConfigurationCustomPolicyMacOS' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should create the instance from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneDeviceConfigurationCustomPolicyMacOS' -Property $testParams).Set()
                Should -Invoke -CommandName 'New-MgBetaDeviceManagementDeviceConfiguration' -Exactly 1
            }
        }

        Context -Name 'The instance exists but it SHOULD NOT' -Fixture {
            BeforeAll {
                $testParams = @{
                    DisplayName = 'FakeStringValue'
                    Ensure      = 'Absent'
                    Credential  = $Credential
                }
            }

            It 'Should return Present from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'IntuneDeviceConfigurationCustomPolicyMacOS' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
                Should -Invoke -CommandName 'Get-MgBetaDeviceManagementDeviceConfiguration'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneDeviceConfigurationCustomPolicyMacOS' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should remove the instance from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneDeviceConfigurationCustomPolicyMacOS' -Property $testParams).Set()
                Should -Invoke -CommandName 'Remove-MgBetaDeviceManagementDeviceConfiguration' -Exactly 1
            }
        }

        Context -Name 'The instance exists and values are already in the desired state' -Fixture {
            BeforeAll {
                $testParams = @{
                    DeploymentChannel = 'deviceChannel'
                    Description       = 'FakeStringValue'
                    DisplayName       = 'FakeStringValue'
                    Id                = 'FakeStringValue'
                    Payload           = 'FakeStringValue'
                    PayloadFileName   = 'FakeStringValue'
                    PayloadName       = 'FakeStringValue'
                    RoleScopeTagIds   = @('FakeStringArrayValue1', 'FakeStringArrayValue2')
                    Ensure            = 'Present'
                    Credential        = $Credential
                }
            }

            It 'Should return the expected values from the Get method' {
                $result = (New-M365DSCResourceInstance -ResourceName 'IntuneDeviceConfigurationCustomPolicyMacOS' -Property $testParams).Get().ToHashtable()
                $result.Ensure | Should -Be 'Present'
                $result.DeploymentChannel | Should -Be 'deviceChannel'
                $result.Description | Should -Be 'FakeStringValue'
                $result.DisplayName | Should -Be 'FakeStringValue'
                $result.Id | Should -Be 'FakeStringValue'
                $result.Payload | Should -Be 'FakeStringValue'
                $result.PayloadFileName | Should -Be 'FakeStringValue'
                $result.PayloadName | Should -Be 'FakeStringValue'
                $result.RoleScopeTagIds | Should -Be @('FakeStringArrayValue1', 'FakeStringArrayValue2')
                Should -Invoke -CommandName 'Get-MgBetaDeviceManagementDeviceConfiguration'
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneDeviceConfigurationCustomPolicyMacOS' -Property $testParams).Test() | Should -Be $true
            }
        }

        Context -Name 'The instance exists and values are NOT in the desired state' -Fixture {
            BeforeAll {
                $testParams = @{
                    DeploymentChannel = 'deviceChannel'
                    Description       = 'FakeStringValueDrift' # Updated property
                    DisplayName       = 'FakeStringValue'
                    Id                = 'FakeStringValue'
                    Payload           = 'FakeStringValue'
                    PayloadFileName   = 'FakeStringValue'
                    PayloadName       = 'FakeStringValue'
                    RoleScopeTagIds   = @('FakeStringArrayValue1', 'FakeStringArrayValue2')
                    Ensure            = 'Present'
                    Credential        = $Credential
                }
            }

            It 'Should return Present from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'IntuneDeviceConfigurationCustomPolicyMacOS' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
                Should -Invoke -CommandName 'Get-MgBetaDeviceManagementDeviceConfiguration'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneDeviceConfigurationCustomPolicyMacOS' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should update the instance from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneDeviceConfigurationCustomPolicyMacOS' -Property $testParams).Set()
                Should -Invoke -CommandName 'Update-MgBetaDeviceManagementDeviceConfiguration' -Exactly 1
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

            It 'Should reverse engineer resource from the Export method' {
                $result = Invoke-M365DSCResourceMethod -ResourceName 'IntuneDeviceConfigurationCustomPolicyMacOS' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
                Should -Invoke -CommandName 'Get-MgBetaDeviceManagementDeviceConfiguration'
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
