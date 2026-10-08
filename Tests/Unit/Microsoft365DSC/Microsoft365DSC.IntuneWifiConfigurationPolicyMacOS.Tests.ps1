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
    -DscResource 'IntuneWifiConfigurationPolicyMacOS' -GenericStubModule $GenericStubPath
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

            Mock -CommandName Update-MgBetaDeviceManagementDeviceConfiguration -MockWith {
            }

            Mock -CommandName New-MgBetaDeviceManagementDeviceConfiguration -MockWith {
            }

            Mock -CommandName Remove-MgBetaDeviceManagementDeviceConfiguration -MockWith {
            }
            Mock -CommandName Update-DeviceConfigurationPolicyAssignment -MockWith {
            }
            Mock -CommandName New-M365DSCConnection -ModuleName '_Shared' -MockWith {
                return 'Credentials'
            }

            Mock -CommandName Get-M365DSCExportCachedCollection -MockWith {
                return Get-MgBetaDeviceManagementDeviceConfiguration
            }
            Mock -CommandName Get-MgBetaDeviceManagementDeviceConfiguration -MockWith {
                return @{
                    ProxyManualPort                      = 25
                    '@odata.type'                        = '#microsoft.graph.macosWifiConfiguration'
                    NetworkName                          = 'FakeStringValue'
                    WifiRequirePhysicalMacAddressEnabled = $True
                    WiFiSecurityType                     = 'open'
                    ConnectAutomatically                 = $True
                    ProxyAutomaticConfigurationUrl       = 'FakeStringValue'
                    PreSharedKey                         = 'FakeStringValue'
                    ConnectWhenNetworkNameIsHidden       = $True
                    ProxySettings                        = 'automatic'
                    Ssid                                 = 'FakeStringValue'
                    ProxyManualAddress                   = 'FakeStringValue'
                    Description                          = 'FakeStringValue'
                    DisplayName                          = 'FakeStringValue'
                    Id                                   = 'FakeStringValue'
                }
            }

            # Mock Write-M365DSCHost to hide output during the tests
            Mock -CommandName Write-M365DSCHost -MockWith {
            }
            $Script:exportedInstances =$null
            $Script:ExportMode = $false
        }

        # Test contexts
        Context -Name 'The IntuneWifiConfigurationPolicyMacOS should exist but it DOES NOT' -Fixture {
            BeforeAll {
                $testParams = @{
                    ConnectAutomatically                 = $True
                    ConnectWhenNetworkNameIsHidden       = $True
                    Description                          = 'FakeStringValue'
                    DisplayName                          = 'FakeStringValue'
                    Id                                   = 'FakeStringValue'
                    NetworkName                          = 'FakeStringValue'
                    PreSharedKey                         = 'FakeStringValue'
                    ProxyAutomaticConfigurationUrl       = 'FakeStringValue'
                    ProxyManualAddress                   = 'FakeStringValue'
                    ProxyManualPort                      = 25
                    ProxySettings                        = 'automatic'
                    Ssid                                 = 'FakeStringValue'
                    WifiRequirePhysicalMacAddressEnabled = $True
                    WiFiSecurityType                     = 'open'
                    Ensure                               = 'Present'
                    Credential                           = $Credential
                }

                Mock -CommandName Get-MgBetaDeviceManagementDeviceConfiguration -MockWith {
                    return $null
                }
            }
            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'IntuneWifiConfigurationPolicyMacOS' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Absent'
            }
            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneWifiConfigurationPolicyMacOS' -Property $testParams).Test() | Should -Be $false
            }
            It 'Should Create the group from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneWifiConfigurationPolicyMacOS' -Property $testParams).Set()
                Should -Invoke -CommandName New-MgBetaDeviceManagementDeviceConfiguration -Exactly 1
            }
        }

        Context -Name 'The IntuneWifiConfigurationPolicyMacOS exists but it SHOULD NOT' -Fixture {
            BeforeAll {
                $testParams = @{
                    ConnectAutomatically                 = $True
                    ConnectWhenNetworkNameIsHidden       = $True
                    Description                          = 'FakeStringValue'
                    DisplayName                          = 'FakeStringValue'
                    Id                                   = 'FakeStringValue'
                    NetworkName                          = 'FakeStringValue'
                    PreSharedKey                         = 'FakeStringValue'
                    ProxyAutomaticConfigurationUrl       = 'FakeStringValue'
                    ProxyManualAddress                   = 'FakeStringValue'
                    ProxyManualPort                      = 25
                    ProxySettings                        = 'automatic'
                    Ssid                                 = 'FakeStringValue'
                    WifiRequirePhysicalMacAddressEnabled = $True
                    WiFiSecurityType                     = 'open'
                    Ensure                               = 'Absent'
                    Credential                           = $Credential
                }
            }

            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'IntuneWifiConfigurationPolicyMacOS' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneWifiConfigurationPolicyMacOS' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should Remove the group from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneWifiConfigurationPolicyMacOS' -Property $testParams).Set()
                Should -Invoke -CommandName Remove-MgBetaDeviceManagementDeviceConfiguration -Exactly 1
            }
        }
        Context -Name 'The IntuneWifiConfigurationPolicyMacOS Exists and Values are already in the desired state' -Fixture {
            BeforeAll {
                $testParams = @{
                    ConnectAutomatically                 = $True
                    ConnectWhenNetworkNameIsHidden       = $True
                    Description                          = 'FakeStringValue'
                    DisplayName                          = 'FakeStringValue'
                    Id                                   = 'FakeStringValue'
                    NetworkName                          = 'FakeStringValue'
                    ForcePreSharedKeyUpdate              = $True
                    PreSharedKey                         = 'UpdatedFakeStringValue'
                    ProxyAutomaticConfigurationUrl       = 'FakeStringValue'
                    ProxyManualAddress                   = 'FakeStringValue'
                    ProxyManualPort                      = 25
                    ProxySettings                        = 'automatic'
                    Ssid                                 = 'FakeStringValue'
                    WifiRequirePhysicalMacAddressEnabled = $True
                    WiFiSecurityType                     = 'open'
                    Ensure                               = 'Present'
                    Credential                           = $Credential
                }
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneWifiConfigurationPolicyMacOS' -Property $testParams).Test() | Should -Be $true
            }
        }

        Context -Name 'The IntuneWifiConfigurationPolicyMacOS exists and values are NOT in the desired state' -Fixture {
            BeforeAll {
                $testParams = @{
                    ConnectAutomatically                 = $True
                    ConnectWhenNetworkNameIsHidden       = $True
                    Description                          = 'FakeStringValue'
                    DisplayName                          = 'FakeStringValue'
                    Id                                   = 'FakeStringValue'
                    NetworkName                          = 'FakeStringValue'
                    PreSharedKey                         = 'FakeStringValue'
                    ProxyAutomaticConfigurationUrl       = 'FakeStringValue'
                    ProxyManualAddress                   = 'FakeStringValue'
                    ProxyManualPort                      = 8443 # Updated property
                    ProxySettings                        = 'automatic'
                    Ssid                                 = 'FakeStringValue'
                    WifiRequirePhysicalMacAddressEnabled = $False # Updated property
                    WiFiSecurityType                     = 'open'
                    Ensure                               = 'Present'
                    Credential                           = $Credential
                }
            }

            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'IntuneWifiConfigurationPolicyMacOS' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneWifiConfigurationPolicyMacOS' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should call the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneWifiConfigurationPolicyMacOS' -Property $testParams).Set()
                Should -Invoke -CommandName Update-MgBetaDeviceManagementDeviceConfiguration -Exactly 1
            }
        }

        Context -Name 'ReverseDSC Tests' -Fixture {
            BeforeAll {
                $Global:PartialExportFileName = "$(New-Guid).partial.ps1"
                $testParams = @{
                    Credential = $Credential
                }
            }

            It 'Should Reverse Engineer resource from the Export method' {
                $result = Invoke-M365DSCResourceMethod -ResourceName 'IntuneWifiConfigurationPolicyMacOS' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
