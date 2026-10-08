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
    -DscResource 'IntuneVPNConfigurationPolicyMacOS' -GenericStubModule $GenericStubPath
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
                    Assignments                    = @(
                        @{
                            dataType                                   = '#microsoft.graph.allDevicesAssignmentTarget'
                            deviceAndAppManagementAssignmentFilterType = 'none'
                        }
                    )
                    Description                    = 'FakeStringValue'
                    DisplayName                    = 'FakeStringValue'
                    Id                             = 'FakeStringValue'
                    RoleScopeTagIds                = @('FakeStringArrayValue1', 'FakeStringArrayValue2')
                    '@odata.type'                  = '#microsoft.graph.macOSVpnConfiguration'
                    associatedDomains              = @('FakeStringArrayValue1', 'FakeStringArrayValue2')
                    authenticationMethod           = 'certificate'
                    connectionName                 = 'FakeStringValue'
                    connectionType                 = 'ciscoAnyConnect'
                    customData                     = @(
                        @{
                            key   = 'FakeStringValue'
                            value = 'FakeStringValue'
                        }
                    )
                    customKeyValueData             = @(
                        @{
                            name  = 'FakeStringValue'
                            value = 'FakeStringValue'
                        }
                    )
                    deploymentChannel              = 'deviceChannel'
                    disableOnDemandUserOverride    = $true
                    disconnectOnIdle               = $true
                    disconnectOnIdleTimerInSeconds = 25
                    enablePerApp                   = $true
                    enableSplitTunneling           = $true
                    excludedDomains                = @('FakeStringArrayValue1', 'FakeStringArrayValue2')
                    excludeLocalNetworks           = $true
                    identifier                     = 'FakeStringValue'
                    includeAllNetworks             = $true
                    loginGroupOrDomain             = 'FakeStringValue'
                    onDemandRules                  = @(
                        @{
                            action                = 'connect'
                            dnsSearchDomains      = @('FakeStringArrayValue1', 'FakeStringArrayValue2')
                            dnsServerAddressMatch = @('FakeStringArrayValue1', 'FakeStringArrayValue2')
                            domainAction          = 'connectIfNeeded'
                            domains               = @('FakeStringArrayValue1', 'FakeStringArrayValue2')
                            interfaceTypeMatch    = 'notConfigured'
                            probeRequiredUrl      = 'FakeStringValue'
                            probeUrl              = 'FakeStringValue'
                            ssids                 = @('FakeStringArrayValue1', 'FakeStringArrayValue2')
                        }
                    )
                    optInToDeviceIdSharing         = $true
                    providerType                   = 'notConfigured'
                    proxyServer                    = @{
                        address                          = 'FakeStringValue'
                        automaticallyDetectProxySettings = $true
                        automaticConfigurationScriptUrl  = 'FakeStringValue'
                        bypassProxyServerForLocalAddress = $true
                        '@odata.type'                    = '#microsoft.graph.windows10VpnProxyServer'
                        port                             = 25
                    }
                    realm                          = 'FakeStringValue'
                    role                           = 'FakeStringValue'
                    safariDomains                  = @('FakeStringArrayValue1', 'FakeStringArrayValue2')
                    server                         = @{
                        address         = 'FakeStringValue'
                        description     = 'FakeStringValue'
                        isDefaultServer = $true
                    }
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
                return "IntuneVPNConfigurationPolicyMacOS 'TestInstance' {}`r`n"
            }

            $Script:exportedInstance = $null
            $Script:exportedInstances = $null
            $Script:ExportMode = $false
        }

        # Test contexts
        Context -Name 'The instance should exist but it DOES NOT' -Fixture {
            BeforeAll {
                $testParams = @{
                    AssociatedDomains              = @('FakeStringArrayValue1', 'FakeStringArrayValue2')
                    AuthenticationMethod           = 'certificate'
                    ConnectionName                 = 'FakeStringValue'
                    ConnectionType                 = 'ciscoAnyConnect'
                    CustomData                     = @{
                        Key   = 'FakeStringValue'
                        Value = 'FakeStringValue'
                    }
                    CustomKeyValueData             = @{
                        Name  = 'FakeStringValue'
                        Value = 'FakeStringValue'
                    }
                    DeploymentChannel              = 'deviceChannel'
                    Description                    = 'FakeStringValue'
                    DisableOnDemandUserOverride    = $true
                    DisconnectOnIdle               = $true
                    DisconnectOnIdleTimerInSeconds = 25
                    DisplayName                    = 'FakeStringValue'
                    EnablePerApp                   = $true
                    EnableSplitTunneling           = $true
                    ExcludedDomains                = @('FakeStringArrayValue1', 'FakeStringArrayValue2')
                    ExcludeLocalNetworks           = $true
                    Id                             = 'FakeStringValue'
                    Identifier                     = 'FakeStringValue'
                    IncludeAllNetworks             = $true
                    LoginGroupOrDomain             = 'FakeStringValue'
                    OnDemandRules                  = @{
                        Action                = 'connect'
                        DnsSearchDomains      = @('FakeStringArrayValue1', 'FakeStringArrayValue2')
                        DnsServerAddressMatch = @('FakeStringArrayValue1', 'FakeStringArrayValue2')
                        DomainAction          = 'connectIfNeeded'
                        Domains               = @('FakeStringArrayValue1', 'FakeStringArrayValue2')
                        InterfaceTypeMatch    = 'notConfigured'
                        ProbeRequiredUrl      = 'FakeStringValue'
                        ProbeUrl              = 'FakeStringValue'
                        Ssids                 = @('FakeStringArrayValue1', 'FakeStringArrayValue2')
                    }
                    OptInToDeviceIdSharing         = $true
                    ProviderType                   = 'notConfigured'
                    ProxyServer                    = @{
                        Address                          = 'FakeStringValue'
                        AutomaticallyDetectProxySettings = $true
                        AutomaticConfigurationScriptUrl  = 'FakeStringValue'
                        BypassProxyServerForLocalAddress = $true
                        ODataType                        = '#microsoft.graph.windows10VpnProxyServer'
                        Port                             = 25
                    }
                    Realm                          = 'FakeStringValue'
                    Role                           = 'FakeStringValue'
                    RoleScopeTagIds                = @('FakeStringArrayValue1', 'FakeStringArrayValue2')
                    SafariDomains                  = @('FakeStringArrayValue1', 'FakeStringArrayValue2')
                    Server                         = @{
                        Address         = 'FakeStringValue'
                        Description     = 'FakeStringValue'
                        IsDefaultServer = $true
                    }
                    Ensure                         = 'Present'
                    Credential                     = $Credential
                }

                Mock -CommandName Get-MgBetaDeviceManagementDeviceConfiguration -MockWith {
                    return $null
                }
            }

            It 'Should return Absent from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'IntuneVPNConfigurationPolicyMacOS' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Absent'
                Should -Invoke -CommandName 'Get-MgBetaDeviceManagementDeviceConfiguration'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneVPNConfigurationPolicyMacOS' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should create the instance from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneVPNConfigurationPolicyMacOS' -Property $testParams).Set()
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
                ((New-M365DSCResourceInstance -ResourceName 'IntuneVPNConfigurationPolicyMacOS' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
                Should -Invoke -CommandName 'Get-MgBetaDeviceManagementDeviceConfiguration'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneVPNConfigurationPolicyMacOS' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should remove the instance from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneVPNConfigurationPolicyMacOS' -Property $testParams).Set()
                Should -Invoke -CommandName 'Remove-MgBetaDeviceManagementDeviceConfiguration' -Exactly 1
            }
        }

        Context -Name 'The instance exists and values are already in the desired state' -Fixture {
            BeforeAll {
                $testParams = @{
                    AssociatedDomains              = @('FakeStringArrayValue1', 'FakeStringArrayValue2')
                    AuthenticationMethod           = 'certificate'
                    ConnectionName                 = 'FakeStringValue'
                    ConnectionType                 = 'ciscoAnyConnect'
                    CustomData                     = @{
                        Key   = 'FakeStringValue'
                        Value = 'FakeStringValue'
                    }
                    CustomKeyValueData             = @{
                        Name  = 'FakeStringValue'
                        Value = 'FakeStringValue'
                    }
                    DeploymentChannel              = 'deviceChannel'
                    Description                    = 'FakeStringValue'
                    DisableOnDemandUserOverride    = $true
                    DisconnectOnIdle               = $true
                    DisconnectOnIdleTimerInSeconds = 25
                    DisplayName                    = 'FakeStringValue'
                    EnablePerApp                   = $true
                    EnableSplitTunneling           = $true
                    ExcludedDomains                = @('FakeStringArrayValue1', 'FakeStringArrayValue2')
                    ExcludeLocalNetworks           = $true
                    Id                             = 'FakeStringValue'
                    Identifier                     = 'FakeStringValue'
                    IncludeAllNetworks             = $true
                    LoginGroupOrDomain             = 'FakeStringValue'
                    OnDemandRules                  = @{
                        Action                = 'connect'
                        DnsSearchDomains      = @('FakeStringArrayValue1', 'FakeStringArrayValue2')
                        DnsServerAddressMatch = @('FakeStringArrayValue1', 'FakeStringArrayValue2')
                        DomainAction          = 'connectIfNeeded'
                        Domains               = @('FakeStringArrayValue1', 'FakeStringArrayValue2')
                        InterfaceTypeMatch    = 'notConfigured'
                        ProbeRequiredUrl      = 'FakeStringValue'
                        ProbeUrl              = 'FakeStringValue'
                        Ssids                 = @('FakeStringArrayValue1', 'FakeStringArrayValue2')
                    }
                    OptInToDeviceIdSharing         = $true
                    ProviderType                   = 'notConfigured'
                    ProxyServer                    = @{
                        Address                          = 'FakeStringValue'
                        AutomaticallyDetectProxySettings = $true
                        AutomaticConfigurationScriptUrl  = 'FakeStringValue'
                        BypassProxyServerForLocalAddress = $true
                        ODataType                        = '#microsoft.graph.windows10VpnProxyServer'
                        Port                             = 25
                    }
                    Realm                          = 'FakeStringValue'
                    Role                           = 'FakeStringValue'
                    RoleScopeTagIds                = @('FakeStringArrayValue1', 'FakeStringArrayValue2')
                    SafariDomains                  = @('FakeStringArrayValue1', 'FakeStringArrayValue2')
                    Server                         = @{
                        Address         = 'FakeStringValue'
                        Description     = 'FakeStringValue'
                        IsDefaultServer = $true
                    }
                    Ensure                         = 'Present'
                    Credential                     = $Credential
                }
            }

            It 'Should return the expected values from the Get method' {
                $result = (New-M365DSCResourceInstance -ResourceName 'IntuneVPNConfigurationPolicyMacOS' -Property $testParams).Get().ToHashtable()
                $result.Ensure | Should -Be 'Present'
                $result.AssociatedDomains | Should -Be @('FakeStringArrayValue1', 'FakeStringArrayValue2')
                $result.AuthenticationMethod | Should -Be 'certificate'
                $result.ConnectionName | Should -Be 'FakeStringValue'
                $result.ConnectionType | Should -Be 'ciscoAnyConnect'
                $result.DeploymentChannel | Should -Be 'deviceChannel'
                $result.Description | Should -Be 'FakeStringValue'
                $result.DisableOnDemandUserOverride | Should -Be $true
                $result.DisconnectOnIdle | Should -Be $true
                $result.DisconnectOnIdleTimerInSeconds | Should -Be 25
                $result.DisplayName | Should -Be 'FakeStringValue'
                $result.EnablePerApp | Should -Be $true
                $result.EnableSplitTunneling | Should -Be $true
                $result.ExcludedDomains | Should -Be @('FakeStringArrayValue1', 'FakeStringArrayValue2')
                $result.ExcludeLocalNetworks | Should -Be $true
                $result.Id | Should -Be 'FakeStringValue'
                $result.Identifier | Should -Be 'FakeStringValue'
                $result.IncludeAllNetworks | Should -Be $true
                $result.LoginGroupOrDomain | Should -Be 'FakeStringValue'
                $result.OptInToDeviceIdSharing | Should -Be $true
                $result.ProviderType | Should -Be 'notConfigured'
                $result.Realm | Should -Be 'FakeStringValue'
                $result.Role | Should -Be 'FakeStringValue'
                $result.RoleScopeTagIds | Should -Be @('FakeStringArrayValue1', 'FakeStringArrayValue2')
                $result.SafariDomains | Should -Be @('FakeStringArrayValue1', 'FakeStringArrayValue2')
                Should -Invoke -CommandName 'Get-MgBetaDeviceManagementDeviceConfiguration'
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneVPNConfigurationPolicyMacOS' -Property $testParams).Test() | Should -Be $true
            }
        }

        Context -Name 'The instance exists and values are NOT in the desired state' -Fixture {
            BeforeAll {
                $testParams = @{
                    AssociatedDomains              = @('FakeStringArrayValue1', 'FakeStringArrayValue2')
                    AuthenticationMethod           = 'certificate'
                    ConnectionName                 = 'FakeStringValueDrift' # Updated property
                    ConnectionType                 = 'ciscoAnyConnect'
                    CustomData                     = @{
                        Key   = 'FakeStringValue'
                        Value = 'FakeStringValue'
                    }
                    CustomKeyValueData             = @{
                        Name  = 'FakeStringValue'
                        Value = 'FakeStringValue'
                    }
                    DeploymentChannel              = 'deviceChannel'
                    Description                    = 'FakeStringValue'
                    DisableOnDemandUserOverride    = $true
                    DisconnectOnIdle               = $true
                    DisconnectOnIdleTimerInSeconds = 25
                    DisplayName                    = 'FakeStringValue'
                    EnablePerApp                   = $true
                    EnableSplitTunneling           = $true
                    ExcludedDomains                = @('FakeStringArrayValue1', 'FakeStringArrayValue2')
                    ExcludeLocalNetworks           = $true
                    Id                             = 'FakeStringValue'
                    Identifier                     = 'FakeStringValue'
                    IncludeAllNetworks             = $true
                    LoginGroupOrDomain             = 'FakeStringValue'
                    OnDemandRules                  = @{
                        Action                = 'connect'
                        DnsSearchDomains      = @('FakeStringArrayValue1', 'FakeStringArrayValue2')
                        DnsServerAddressMatch = @('FakeStringArrayValue1', 'FakeStringArrayValue2')
                        DomainAction          = 'connectIfNeeded'
                        Domains               = @('FakeStringArrayValue1', 'FakeStringArrayValue2')
                        InterfaceTypeMatch    = 'notConfigured'
                        ProbeRequiredUrl      = 'FakeStringValue'
                        ProbeUrl              = 'FakeStringValue'
                        Ssids                 = @('FakeStringArrayValue1', 'FakeStringArrayValue2')
                    }
                    OptInToDeviceIdSharing         = $true
                    ProviderType                   = 'notConfigured'
                    ProxyServer                    = @{
                        Address                          = 'FakeStringValue'
                        AutomaticallyDetectProxySettings = $true
                        AutomaticConfigurationScriptUrl  = 'FakeStringValue'
                        BypassProxyServerForLocalAddress = $true
                        ODataType                        = '#microsoft.graph.windows10VpnProxyServer'
                        Port                             = 25
                    }
                    Realm                          = 'FakeStringValue'
                    Role                           = 'FakeStringValue'
                    RoleScopeTagIds                = @('FakeStringArrayValue1', 'FakeStringArrayValue2')
                    SafariDomains                  = @('FakeStringArrayValue1', 'FakeStringArrayValue2')
                    Server                         = @{
                        Address         = 'FakeStringValue'
                        Description     = 'FakeStringValue'
                        IsDefaultServer = $true
                    }
                    Ensure                         = 'Present'
                    Credential                     = $Credential
                }
            }

            It 'Should return Present from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'IntuneVPNConfigurationPolicyMacOS' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
                Should -Invoke -CommandName 'Get-MgBetaDeviceManagementDeviceConfiguration'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneVPNConfigurationPolicyMacOS' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should update the instance from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneVPNConfigurationPolicyMacOS' -Property $testParams).Set()
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
                $result = Invoke-M365DSCResourceMethod -ResourceName 'IntuneVPNConfigurationPolicyMacOS' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
                Should -Invoke -CommandName 'Get-MgBetaDeviceManagementDeviceConfiguration'
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
