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
    -DscResource 'IntuneVPNConfigurationPolicyAndroidWork' -GenericStubModule $GenericStubPath
Describe -Name $Global:DscHelper.DescribeHeader -Fixture {
    InModuleScope -ModuleName $Global:DscHelper.ModuleName -ScriptBlock {
        Invoke-Command -ScriptBlock $Global:DscHelper.InitializeScript -NoNewScope
        BeforeAll {
            $secpasswd = ConvertTo-SecureString ((New-Guid).ToString()) -AsPlainText -Force
            $Credential = New-Object System.Management.Automation.PSCredential ('tenantadmin@onmicrosoft.com', $secpasswd)

            Mock -ModuleName M365DSCUtil -CommandName Confirm-M365DSCDependencies -MockWith {
            }

            Mock -CommandName New-M365DSCConnection -ModuleName '_Shared' -MockWith {
                return 'Credentials'
            }

            Mock -CommandName Update-MgBetaDeviceManagementDeviceConfiguration -MockWith {
            }

            Mock -CommandName New-MgBetaDeviceManagementDeviceConfiguration -MockWith {
            }

            Mock -CommandName Remove-MgBetaDeviceManagementDeviceConfiguration -MockWith {
            }

            Mock -CommandName Get-M365DSCExportCachedCollection -MockWith {
                return Get-MgBetaDeviceManagementDeviceConfiguration
            }
            Mock -CommandName Get-MgBetaDeviceManagementDeviceConfiguration -MockWith {
                return  @{
                    Id                                          = 'FakeStringValue'
                    DisplayName                                 = 'FakeStringValue'
                    Description                                 = 'FakeStringValue'
                    '@odata.type'                           = '#microsoft.graph.androidWorkProfileVpnConfiguration'
                    authenticationMethod                    = 'usernameAndPassword'
                    connectionName                          = 'FakeStringValue'
                    connectionType                          = 'ciscoAnyConnect'
                    fingerprint                             = 'FakeStringValue'
                    lockdownExclusionList                   = @('FakeStringValue')
                    proxyServer                             = @(
                        @{
                            port                            = 80
                            automaticConfigurationScriptUrl = 'https://www.test.com'
                            address                         = 'proxy.test.com'
                        }
                    )
                    servers                                  = @(
                        @{
                            isDefaultServer                 = $True
                            description                     = 'server'
                            address                         = 'vpn.test.com'
                        }
                    )
                    customData                              = @(
                        @{
                            key                             = 'FakeStringValue'
                            value                           = 'FakeStringValue'
                        }
                    )
                    customKeyValueData                      = @(
                        @{
                            name                            = 'FakeStringValue'
                            value                           = 'FakeStringValue'
                        }
                    )
                    targetedMobileApps                    = @(
                        @{
                            name                            = 'FakeStringValue'
                            publisher                       = 'FakeStringValue'
                            appStoreUrl                     = 'FakeStringValue'
                            appId                           = 'FakeStringValue'
                        }
                    )
                }
            }

            Mock -CommandName Get-MgBetaDeviceManagementDeviceCompliancePolicyAssignment -MockWith {
                return @()
            }
            Mock -CommandName Update-DeviceConfigurationPolicyAssignment -MockWith {
            }
            # Mock Write-M365DSCHost to hide output during the tests
            Mock -CommandName Write-M365DSCHost -MockWith {
            }
            $Script:exportedInstances =$null
            $Script:ExportMode = $false
        }

        # Test contexts
        Context -Name "When the IntuneVPNConfigurationPolicyAndroidWork doesn't already exist" -Fixture {
            BeforeAll {
               $testParams = @{
                    connectionName                             = 'FakeStringValue'
                    connectionType                             = 'ciscoAnyConnect'
                    Description                                = 'FakeStringValue'
                    DisplayName                                = 'FakeStringValue'
                    fingerprint                                = 'FakeStringValue'
                    Id                                         = 'FakeStringValue'
                    lockdownExclusionList                      = @('FakeStringValue')
                    proxyServer                                = @(
                        ([MSFT_MicrosoftvpnProxyServer] @{
                            port                               = 80
                            automaticConfigurationScriptUrl    = 'https://www.test.com'
                            address                            = 'proxy.test.com'
                        })
                    )
                    servers                                    = @(
                        ([MSFT_MicrosoftGraphvpnServer] @{
                            isDefaultServer                    = $True
                            description                        = 'server'
                            address                            = 'vpn.test.com'
                        })
                    )
                    customData                                 = @(
                        ([MSFT_customData] @{
                            key                                = 'FakeStringValue'
                            value                              = 'FakeStringValue'
                        })
                    )
                    customKeyValueData                         = @(
                        ([MSFT_customKeyValueData] @{
                            name                               = 'FakeStringValue'
                            value                              = 'FakeStringValue'
                        })
                    )
                     targetedMobileApps                      = @(
                        ([MSFT_targetedMobileApps] @{
                            name                               = 'FakeStringValue'
                            publisher                          = 'FakeStringValue'
                            appStoreUrl                        = 'FakeStringValue'
                            appId                              = 'FakeStringValue'
                        })
                    )
                    Ensure                                     = 'Present'
                    Credential                                 = $Credential
                }

                Mock -CommandName Get-MgBetaDeviceManagementDeviceConfiguration -MockWith {
                    return $null
                }
            }

            It 'Should return absent from the Get method' {
                    ((New-M365DSCResourceInstance -ResourceName 'IntuneVPNConfigurationPolicyAndroidWork' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Absent'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneVPNConfigurationPolicyAndroidWork' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should create the IntuneVPNConfigurationPolicyAndroidWork from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneVPNConfigurationPolicyAndroidWork' -Property $testParams).Set()
                Should -Invoke -CommandName 'New-MgBetaDeviceManagementDeviceConfiguration' -Exactly 1 -ParameterFilter {
                    $BodyParameter.proxyServer.address -eq 'proxy.test.com' -and $BodyParameter.proxyServer.port -eq 80
                }
            }
        }

        Context -Name 'When the IntuneVPNConfigurationPolicyAndroidWork already exists and is NOT in the Desired State' -Fixture {
            BeforeAll {
               $testParams = @{
                    DisplayName                               = 'FakeStringValue'
                    Description                               = 'FakeStringValue'
                    Id                                        = 'FakeStringValue'
                    authenticationMethod                      = 'usernameAndPassword'
                    connectionName                            = 'FakeStringValue'
                    connectionType                            = 'ciscoAnyConnect'
                    fingerprint                               = 'UpdatedFakeStringValue' # Updated property
                    lockdownExclusionList                     = @('UpdatedFakeStringValue') # Updated property
                    proxyServer                               = @(
                        ([MSFT_MicrosoftvpnProxyServer] @{
                            port                              = 80
                            automaticConfigurationScriptUrl   = 'https://www.test.com'
                            address                           = 'proxy.test.com'
                        })
                    )
                    servers                                   = @(
                        ([MSFT_MicrosoftGraphvpnServer] @{
                            isDefaultServer                   = $True
                            description                       = 'server'
                            address                           = 'vpn.test.com'
                        })
                    )
                    customData                                = @(
                        ([MSFT_customData] @{
                           key                                = 'FakeStringValue'
                            value                             = 'FakeStringValue'
                        })
                    )
                    customKeyValueData                        = @(
                        ([MSFT_customKeyValueData] @{
                            name                              = 'UpdatedName' # Updated property
                            value                             = 'FakeStringValue'
                        })
                    )
                    targetedMobileApps                      = @(
                        ([MSFT_targetedMobileApps] @{
                            name                             = 'FakeStringValue'
                            publisher                        = 'FakeStringValue'
                            appStoreUrl                      = 'FakeStringValue'
                            appId                            = 'FakeStringValue'
                        })
                    )
                    Ensure                                   = 'Present'
                    Credential                               = $Credential
                }
            }

            It 'Should return Present from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'IntuneVPNConfigurationPolicyAndroidWork' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneVPNConfigurationPolicyAndroidWork' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should update the IntuneVPNConfigurationPolicyAndroidWork from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneVPNConfigurationPolicyAndroidWork' -Property $testParams).Set()
                Should -Invoke -CommandName Update-MgBetaDeviceManagementDeviceConfiguration -Exactly 1

            }
        }

       Context -Name 'When the policy already exists and IS in the Desired State' -Fixture {
            BeforeAll {
               $testParams = @{
                    DisplayName                              = 'FakeStringValue'
                    Description                              = 'FakeStringValue'
                    authenticationMethod                     = 'usernameAndPassword'
                    connectionName                           = 'FakeStringValue'
                    connectionType                           = 'ciscoAnyConnect'
                    fingerprint                              = 'FakeStringValue'
                    lockdownExclusionList                    = @('FakeStringValue')
                    proxyServer                              = @(
                        ([MSFT_MicrosoftvpnProxyServer] @{
                            port                             = 80
                            automaticConfigurationScriptUrl  = 'https://www.test.com'
                            address                          = 'proxy.test.com'
                        })
                    )
                    servers                                   = @(
                        ([MSFT_MicrosoftGraphvpnServer] @{
                            isDefaultServer                  = $True
                            description                      = 'server'
                            address                          = 'vpn.test.com'
                        })
                    )
                    customData                               = @(
                        ([MSFT_customData] @{
                            key                              = 'FakeStringValue'
                            value                            = 'FakeStringValue'
                        })
                    )
                    customKeyValueData      = @(
                        ([MSFT_customKeyValueData] @{
                            name                            = 'FakeStringValue'
                            value                           = 'FakeStringValue'
                        })
                    )
                    targetedMobileApps                    = @(
                        ([MSFT_targetedMobileApps] @{
                            name                            = 'FakeStringValue'
                            publisher                       = 'FakeStringValue'
                            appStoreUrl                     = 'FakeStringValue'
                            appId                           = 'FakeStringValue'
                        })
                    )
                    Ensure                                  = 'Present'
                    Credential                              = $Credential
                }
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneVPNConfigurationPolicyAndroidWork' -Property $testParams).Test() | Should -Be $true
            }
        }

        Context -Name 'When the policy exists and it SHOULD NOT' -Fixture {
            BeforeAll {
                $testParams = @{
                    DisplayName                             = 'FakeStringValue'
                    Description                             = 'FakeStringValue'
                    authenticationMethod                    = 'usernameAndPassword'
                    connectionName                          = 'FakeStringValue'
                    connectionType                          = 'ciscoAnyConnect'
                    fingerprint                             = 'FakeStringValue'
                    lockdownExclusionList                   = @('FakeStringValue')
                    proxyServer                             = @(
                        ([MSFT_MicrosoftvpnProxyServer] @{
                            port = 80
                            automaticConfigurationScriptUrl = 'https://www.test.com'
                            address                         = 'proxy.test.com'
                        })
                    )
                    servers                                 = @(
                        ([MSFT_MicrosoftGraphvpnServer] @{
                            isDefaultServer                 = $True
                            description                     = 'server'
                            address                         = 'vpn.test.com'
                        })
                    )
                    Ensure                                  = 'Absent'
                    Credential                              = $Credential
                }
            }

            It 'Should return Present from the Get method' {
                    ((New-M365DSCResourceInstance -ResourceName 'IntuneVPNConfigurationPolicyAndroidWork' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneVPNConfigurationPolicyAndroidWork' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should remove the IntuneVPNConfigurationPolicyAndroidWork from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneVPNConfigurationPolicyAndroidWork' -Property $testParams).Set()
                Should -Invoke -CommandName Remove-MgBetaDeviceManagementDeviceConfiguration -Exactly 1
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
                $result = Invoke-M365DSCResourceMethod -ResourceName 'IntuneVPNConfigurationPolicyAndroidWork' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
