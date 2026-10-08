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
    -DscResource "IntuneWindowsHelloForBusinessGlobalPolicy" -GenericStubModule $GenericStubPath
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

            Mock -CommandName Update-MgBetaDeviceManagementDeviceEnrollmentConfiguration -MockWith {
            }

            Mock -CommandName New-M365DSCConnection -ModuleName '_Shared' -MockWith {
                return "Credentials"
            }

            # Mock Write-M365DSCHost to hide output during the tests
            Mock -CommandName Write-M365DSCHost -MockWith {
            }
            $Script:exportedInstances =$null
            $Script:ExportMode = $false

            Mock -CommandName Get-M365DSCExportCachedCollection -MockWith {
                return Get-MgBetaDeviceManagementDeviceEnrollmentConfiguration
            }
            Mock -CommandName Get-MgBetaDeviceManagementDeviceEnrollmentConfiguration -MockWith {
                    return @{
                        pinExpirationInDays = 25
                        unlockWithBiometricsEnabled = $True
                        state = "notConfigured"
                        pinLowercaseCharactersUsage = "allowed"
                        enhancedBiometricsState = "notConfigured"
                        pinSpecialCharactersUsage = "allowed"
                        securityDeviceRequired = $True
                        pinPreviousBlockCount = 25
                        pinUppercaseCharactersUsage = "allowed"
                        '@odata.type' = "#microsoft.graph.deviceEnrollmentWindowsHelloForBusinessConfiguration"
                        pinMaximumLength = 25
                        securityKeyForSignIn = "notConfigured"
                        remotePassportEnabled = $True
                        enhancedSignInSecurity = 25
                        pinMinimumLength = 25
                        Description = "FakeStringValue"
                        DeviceEnrollmentConfigurationType = "unknown"
                        DisplayName = "FakeStringValue"
                        Id = "FakeStringValue"
                        Priority = 25
                        RoleScopeTagIds = @("FakeStringValue")
                        Version = 25
                    }
                }

        }

        # Test contexts
        Context -Name "The IntuneWindowsHelloForBusinessGlobalPolicy Exists and Values are already in the desired state" -Fixture {
            BeforeAll {
                $testParams = @{
                    IsSingleInstance = "Yes"
                    EnhancedBiometricsState = "notConfigured"
                    EnhancedSignInSecurity = 25
                    PinExpirationInDays = 25
                    PinLowercaseCharactersUsage = "allowed"
                    PinMaximumLength = 25
                    PinMinimumLength = 25
                    PinPreviousBlockCount = 25
                    PinSpecialCharactersUsage = "allowed"
                    PinUppercaseCharactersUsage = "allowed"
                    RemotePassportEnabled = $True
                    SecurityDeviceRequired = $True
                    SecurityKeyForSignIn = "notConfigured"
                    State = "notConfigured"
                    UnlockWithBiometricsEnabled = $True
                    Credential = $Credential;
                }
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneWindowsHelloForBusinessGlobalPolicy' -Property $testParams).Test() | Should -Be $true
            }
        }

        Context -Name "The IntuneWindowsHelloForBusinessGlobalPolicy exists and values are NOT in the desired state" -Fixture {
            BeforeAll {
                $testParams = @{
                    IsSingleInstance = "Yes"
                    EnhancedBiometricsState = "notConfigured"
                    EnhancedSignInSecurity = 25
                    PinExpirationInDays = 25
                    PinLowercaseCharactersUsage = "allowed"
                    PinMaximumLength = 25
                    PinMinimumLength = 25
                    PinPreviousBlockCount = 25
                    PinSpecialCharactersUsage = "allowed"
                    PinUppercaseCharactersUsage = "allowed"
                    RemotePassportEnabled = $True
                    SecurityDeviceRequired = $True
                    SecurityKeyForSignIn = "notConfigured"
                    State = "notConfigured"
                    UnlockWithBiometricsEnabled = $False # Drift
                    Credential = $Credential;
                }
            }

            It 'Should return Yes from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'IntuneWindowsHelloForBusinessGlobalPolicy' -Property $testParams).Get().ToHashtable()).IsSingleInstance | Should -Be 'Yes'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneWindowsHelloForBusinessGlobalPolicy' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should call the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneWindowsHelloForBusinessGlobalPolicy' -Property $testParams).Set()
                Should -Invoke -CommandName Update-MgBetaDeviceManagementDeviceEnrollmentConfiguration -Exactly 1
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
                $result = Invoke-M365DSCResourceMethod -ResourceName 'IntuneWindowsHelloForBusinessGlobalPolicy' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
