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
    -DscResource 'AADConditionalAccessPolicy' -GenericStubModule $GenericStubPath

Describe -Name $Global:DscHelper.DescribeHeader -Fixture {
    InModuleScope -ModuleName $Global:DscHelper.ModuleName -ScriptBlock {
        Invoke-Command -ScriptBlock $Global:DscHelper.InitializeScript -NoNewScope

        BeforeAll {
            $secpasswd = ConvertTo-SecureString ((New-Guid).ToString()) -AsPlainText -Force
            $Credential = New-Object System.Management.Automation.PSCredential ('tenantadmin@onmicrosoft.com', $secpasswd)

            Mock -ModuleName M365DSCUtil -CommandName Confirm-M365DSCDependencies -MockWith {
            }

            Mock -CommandName New-M365DSCLogEntry -ModuleName '_Shared' -MockWith {
            }

            Mock -CommandName Get-MSCloudLoginConnectionProfile -MockWith {
            }

            Mock -CommandName New-M365DSCConnection -ModuleName '_Shared' -MockWith {
                return 'Credentials'
            }

            Mock -CommandName Get-MgUser -MockWith {
                return @{
                    Id                = '76d3c3f6-8269-462b-9385-37435cb33f1e'
                    UserPrincipalName = 'alexw@contoso.com'
                }
            }
            Mock -CommandName Get-MgGroup -ParameterFilter { $GroupId -eq 'f1eb1a09-c0c2-4df4-9e69-fee01f00db31' } -MockWith {
                return @{
                    Id          = 'f1eb1a09-c0c2-4df4-9e69-fee01f00db31'
                    DisplayName = 'Group 01'
                }
            }
            Mock -CommandName Get-MgGroup -ParameterFilter { $Filter -eq "DisplayName eq 'Group 01'" } -MockWith {
                return @(@{
                    Id          = 'f1eb1a09-c0c2-4df4-9e69-fee01f00db31'
                    DisplayName = 'Group 01'
                })
            }
            Mock -CommandName Get-MgDirectoryRoleTemplate -MockWith {
                return @{
                    Id          = '17315797-102d-40b4-93e0-432062caca18'
                    DisplayName = 'Compliance Administrator'
                }
            }
            Mock -CommandName Get-MgBetaIdentityConditionalAccessNamedLocation -MockWith {
                return @{
                    Id          = '9e4ca5f3-0ba9-4257-b906-74d3038ac970'
                    DisplayName = 'Contoso LAN'
                }
            }
            Mock -CommandName Get-MgBetaPolicyAuthenticationStrengthPolicy -MockWith {
                return @{
                    Id          = "00000000-0000-0000-0000-000000000004"
                    DisplayName = "Phishing-resistant MFA"
                }
            }
            Mock -CommandName Get-MgBetaAgreement -MockWith {
                return @(
                    @{
                        Id          = '4a2f1c8b-1b59-4f0e-9d21-2f8e5c3d7a10'
                        DisplayName = 'Contractor Data Handling Agreement'
                    },
                    @{
                        Id          = 'b7c3e5d9-6f42-4a1b-8c07-19d4e2f6a5b3'
                        DisplayName = 'Employee Acceptable Use Policy'
                    }
                )
            }
            Mock -CommandName Get-MgServicePrincipal -ParameterFilter { $Filter -eq "AppId eq '00000012-0000-0000-c000-000000000000'" } -MockWith {
                return @{
                    Id          = '00000012-0000-0000-c000-000000000000'
                    DisplayName = 'Microsoft Rights Management Services'
                }
            }
            Mock -CommandName Get-MgServicePrincipal -ParameterFilter { $Filter -eq "DisplayName eq 'Microsoft Rights Management Services'" } -MockWith {
                return @{
                    Id          = '00000012-0000-0000-c000-000000000000'
                    DisplayName = 'Microsoft Rights Management Services'
                }
            }

            Mock -CommandName Get-MgBetaIdentityConditionalAccessPolicy -MockWith {
                return @{
                    Id              = 'bcc0cf19-ee89-46f0-8e12-4b89123ee6f9'
                    DisplayName     = 'Allin'
                    State           = 'disabled'
                    Conditions      = @{
                        Applications     = @{
                            IncludeApplications = @('All')
                            ExcludeApplications = @('00000012-0000-0000-c000-000000000000', 'Office365')
                            IncludeUserActions  = @('urn:user:registersecurityinfo')
                        }
                        Users            = @{
                            IncludeUsers  = 'All'
                            ExcludeUsers  = '76d3c3f6-8269-462b-9385-37435cb33f1e'
                            IncludeGroups = @('f1eb1a09-c0c2-4df4-9e69-fee01f00db31')
                            ExcludeGroups = @('f1eb1a09-c0c2-4df4-9e69-fee01f00db31')
                            IncludeRoles  = @('17315797-102d-40b4-93e0-432062caca18')
                            ExcludeRoles  = @('17315797-102d-40b4-93e0-432062caca18')
                            IncludeGuestsOrExternalUsers = @{
                                guestOrExternalUserTypes = 'b2bCollaborationGuest'
                                externalTenants          = @{
                                    membershipKind       = 'enumerated'
                                    members = @('11111111-1111-1111-1111-111111111111')
                                }
                            }
                            ExcludeGuestsOrExternalUsers = @{
                                guestOrExternalUserTypes = 'internalGuest,b2bCollaborationMember'
                                externalTenants          = @{
                                    membershipKind       = 'all'
                                }
                            }
                        }
                        Platforms        = @{
                            IncludePlatforms = @('Android', 'IOS')
                            ExcludePlatforms = @('Windows', 'WindowsPhone', 'MacOS')
                        }
                        Locations        = @{
                            IncludeLocations = 'AllTrusted'
                            ExcludeLocations = '9e4ca5f3-0ba9-4257-b906-74d3038ac970'
                        }
                        Devices          = @{
                            IncludeDevices = @('All')
                            ExcludeDevices = @('Compliant', 'DomainJoined')
                            DeviceFilter   = @{
                                Mode = @('exclude')
                                Rule = @('device.isCompliant -eq True -or device.trustType -eq "ServerAD"')
                            }
                        }
                        ClientAppTypes   = @('Browser', 'MobileAppsAndDesktopClients')
                        SignInRiskLevels = @('High')
                        UserRiskLevels   = @('High')
                        ServicePrincipalRiskLevels = @('High')
                    }
                    GrantControls   = @{
                        Operator       = 'AND'
                        BuiltInControls = @('Mfa', 'CompliantDevice', 'DomainJoinedDevice', 'ApprovedApplication', 'CompliantApplication')
                        AuthenticationStrength = @{
                            Id = "00000000-0000-0000-0000-000000000004"
                        }
                    }
                    SessionControls = @{
                        ApplicationEnforcedRestrictions = @{
                            IsEnabled = $True
                        }
                        CloudAppSecurity                = @{
                            IsEnabled            = $True
                            CloudAppSecurityType = 'MonitorOnly'
                        }
                        ContinuousAccessEvaluation = @{
                            mode = 'strictLocation'
                        }
                        SecureSignInSession            = @{
                            IsEnabled = $True
                        }
                        SignInFrequency                 = @{
                            IsEnabled          = $True
                            Type               = 'Days'
                            Value              = 5
                            AuthenticationType = 'primaryAndSecondaryAuthentication'
                        }
                        PersistentBrowser               = @{
                            IsEnabled = $True
                            Mode      = 'Always'
                        }
                        disableResilienceDefaults       = $true
                    }
                }
            }

            Mock -CommandName New-MgBetaIdentityConditionalAccessPolicy -MockWith {
            }

            Mock -CommandName Update-MgBetaIdentityConditionalAccessPolicy -MockWith {
            }

            Mock -CommandName Get-MgDirectoryCustomSecurityAttributeDefinition -MockWith {
            }

            Mock -CommandName Remove-MgBetaIdentityConditionalAccessPolicy -MockWith {
            }

            # Mock Write-M365DSCHost to hide output during the tests
            Mock -CommandName Write-M365DSCHost -MockWith {
            }
            $Script:exportedInstance =$null
            $Script:ExportMode = $false
        }

        # Test contexts
        Context -Name "When Conditional Access Policy doesn't exist but should" -Fixture {
            BeforeAll {
                $testParams = @{
                    AuthenticationStrength               = "Phishing-resistant MFA"
                    BuiltInControls                      = @('Mfa', 'CompliantDevice', 'DomainJoinedDevice', 'ApprovedApplication', 'CompliantApplication')
                    ClientAppTypes                       = @('Browser', 'MobileAppsAndDesktopClients')
                    CloudAppSecurityIsEnabled            = $True
                    CloudAppSecurityType                 = 'MonitorOnly'
                    ContinuousAccessEvaluationMode       = 'strictLocation'
                    DisplayName                          = 'Allin'
                    Ensure                               = 'Present'
                    ExcludeApplications                  = @('Microsoft Rights Management Services', 'Office365')
                    ExcludeGroups                        = @('Group 01')
                    ExcludeLocations                     = 'Contoso LAN'
                    ExcludePlatforms                     = @('Windows', 'WindowsPhone', 'MacOS')
                    ExcludeRoles                         = @('Compliance Administrator')
                    ExcludeUsers                         = 'alexw@contoso.com'
                    ExcludeExternalTenantsMembers        = @()
                    ExcludeExternalTenantsMembershipKind = 'all'
                    ExcludeGuestOrExternalUserTypes      = @('internalGuest', 'b2bCollaborationMember')
                    Credential                           = $Credscredential
                    GrantControlOperator                 = 'AND'
                    Id                                   = 'bcc0cf19-ee89-46f0-8e12-4b89123ee6f9'
                    IncludeApplications                  = @('All')
                    IncludeGroups                        = @('Group 01')
                    IncludeLocations                     = 'AllTrusted'
                    IncludePlatforms                     = @('Android', 'IOS')
                    IncludeRoles                         = @('Compliance Administrator')
                    IncludeUserActions                   = @('urn:user:registersecurityinfo')
                    IncludeUsers                         = 'All'
                    IncludeExternalTenantsMembers        = @('11111111-1111-1111-1111-111111111111')
                    IncludeExternalTenantsMembershipKind = 'enumerated'
                    IncludeGuestOrExternalUserTypes      = @('b2bCollaborationGuest')
                    PersistentBrowserIsEnabled           = $True
                    PersistentBrowserMode                = 'Always'
                    DisableResilienceDefaultsIsEnabled   = $True
                    SecureSignInSessionIsEnabled         = $True
                    SignInFrequencyAuthenticationType    = 'primaryAndSecondaryAuthentication'
                    SignInFrequencyIsEnabled             = $True
                    SignInFrequencyType                  = 'Days'
                    SignInFrequencyValue                 = 5
                    SignInRiskLevels                     = @('High')
                    State                                = 'disabled'
                    UserRiskLevels                       = @('High')
                    DeviceFilterMode                     = 'exclude'
                    DeviceFilterRule                     = 'device.isCompliant -eq True -or device.trustType -eq "ServerAD"'
                }

                Mock -CommandName Get-MgBetaIdentityConditionalAccessPolicy -MockWith {
                    return $null
                }
            }

            It 'Should return absent from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'AADConditionalAccessPolicy' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Absent'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'AADConditionalAccessPolicy' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should create the policy in the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'AADConditionalAccessPolicy' -Property $testParams).Set()
                Should -Invoke -CommandName New-MgBetaIdentityConditionalAccessPolicy -Exactly 1 -ParameterFilter {
                    ($BodyParameter.conditions.platforms.includePlatforms -join ',') -ceq 'android,iOS' -and
                    ($BodyParameter.conditions.platforms.excludePlatforms -join ',') -ceq 'windows,windowsPhone,macOS'
                }
            }
        }

        Context -Name 'Policy exists but is not in the Desired State' -Fixture {
            BeforeAll {
                $testParams = @{
                    ApplicationEnforcedRestrictionsIsEnabled = $True
                    AuthenticationStrength                   = "Phishing-resistant MFA"
                    BuiltInControls                          = @('Mfa', 'CompliantDevice', 'DomainJoinedDevice', 'ApprovedApplication', 'CompliantApplication')
                    ClientAppTypes                           = @('Browser', 'MobileAppsAndDesktopClients')
                    CloudAppSecurityIsEnabled                = $True
                    CloudAppSecurityType                     = 'MonitorOnly'
                    ContinuousAccessEvaluationMode           = 'strictLocation'
                    DisplayName                              = 'Allin'
                    Ensure                                   = 'Present'
                    ExcludeApplications                      = @('Microsoft Rights Management Services', 'Office365')
                    ExcludeGroups                            = @('Group 01')
                    ExcludeLocations                         = 'Contoso LAN'
                    ExcludePlatforms                         = @('Windows', 'WindowsPhone', 'MacOS')
                    ExcludeRoles                             = @('Compliance Administrator')
                    ExcludeUsers                             = 'alexw@contoso.com'
                    ExcludeExternalTenantsMembers            = @()
                    ExcludeExternalTenantsMembershipKind     = 'all'
                    ExcludeGuestOrExternalUserTypes          = @('internalGuest', 'b2bCollaborationMember')
                    Credential                               = $Credscredential
                    GrantControlOperator                     = 'AND'
                    Id                                       = 'bcc0cf19-ee89-46f0-8e12-4b89123ee6f9'
                    IncludeApplications                      = @('All')
                    IncludeGroups                            = @('Group 01')
                    IncludeLocations                         = 'AllTrusted'
                    IncludePlatforms                         = @('Android', 'IOS')
                    IncludeRoles                             = @('Compliance Administrator')
                    IncludeUserActions                       = @('urn:user:registersecurityinfo')
                    IncludeUsers                             = 'All'
                    IncludeExternalTenantsMembers            = @('11111111-1111-1111-1111-111111111111')
                    IncludeExternalTenantsMembershipKind     = 'enumerated'
                    IncludeGuestOrExternalUserTypes          = @('b2bCollaborationGuest')
                    PersistentBrowserIsEnabled               = $True
                    PersistentBrowserMode                    = 'Always'
                    DisableResilienceDefaultsIsEnabled       = $True
                    ServicePrincipalRiskLevels               = @('High')
                    SecureSignInSessionIsEnabled             = $True
                    SignInFrequencyAuthenticationType        = 'primaryAndSecondaryAuthentication'
                    SignInFrequencyIsEnabled                 = $True
                    SignInFrequencyType                      = 'Days'
                    SignInFrequencyValue                     = 5
                    SignInRiskLevels                         = @('High')
                    State                                    = 'enabled' # Drift
                    UserRiskLevels                           = @('High')
                    DeviceFilterMode                         = 'exclude'
                    DeviceFilterRule                         = 'device.isCompliant -eq True -or device.trustType -eq "ServerAD"'
                }
            }

            It 'Should return Present from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'AADConditionalAccessPolicy' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'AADConditionalAccessPolicy' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should update the settings from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'AADConditionalAccessPolicy' -Property $testParams).Set()
                Should -Invoke -CommandName Update-MgBetaIdentityConditionalAccessPolicy -Exactly 1
            }
        }

        Context -Name 'Policy exists but is not in the Desired State. Not all params specified' -Fixture {
            BeforeAll {
                $testParams = @{
                    DisplayName                              = 'Allin'
                    Ensure                                   = 'Present'
                    Credential                               = $Credscredential
                    State                                    = 'enabled' # Drift
                }
            }

            It 'Should return Present from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'AADConditionalAccessPolicy' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'AADConditionalAccessPolicy' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should update the settings from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'AADConditionalAccessPolicy' -Property $testParams).Set()
                Should -Invoke -CommandName Update-MgBetaIdentityConditionalAccessPolicy -Exactly 1
            }
        }

        Context -Name 'Policy exists and is already in the Desired State' -Fixture {
            BeforeAll {
                $testParams = @{
                    ApplicationEnforcedRestrictionsIsEnabled = $True
                    AuthenticationStrength                   = "Phishing-resistant MFA"
                    BuiltInControls                          = @('Mfa', 'CompliantDevice', 'DomainJoinedDevice', 'ApprovedApplication', 'CompliantApplication')
                    ClientAppTypes                           = @('Browser', 'MobileAppsAndDesktopClients')
                    CloudAppSecurityIsEnabled                = $True
                    CloudAppSecurityType                     = 'MonitorOnly'
                    ContinuousAccessEvaluationMode           = 'strictLocation'
                    DisplayName                              = 'Allin'
                    Ensure                                   = 'Present'
                    ExcludeApplications                      = @('Microsoft Rights Management Services', 'Office365')
                    ExcludeGroups                            = @('Group 01')
                    ExcludeLocations                         = 'Contoso LAN'
                    ExcludePlatforms                         = @('Windows', 'WindowsPhone', 'MacOS')
                    ExcludeRoles                             = @('Compliance Administrator')
                    ExcludeUsers                             = 'alexw@contoso.com'
                    ExcludeExternalTenantsMembers            = @()
                    ExcludeExternalTenantsMembershipKind     = 'all'
                    ExcludeGuestOrExternalUserTypes          = @('internalGuest', 'b2bCollaborationMember')
                    Credential                               = $Credscredential
                    GrantControlOperator                     = 'AND'
                    Id                                       = 'bcc0cf19-ee89-46f0-8e12-4b89123ee6f9'
                    IncludeApplications                      = @('All')
                    IncludeGroups                            = @('Group 01')
                    IncludeLocations                         = 'AllTrusted'
                    IncludePlatforms                         = @('Android', 'IOS')
                    IncludeRoles                             = @('Compliance Administrator')
                    IncludeUserActions                       = @('urn:user:registersecurityinfo')
                    IncludeUsers                             = 'All'
                    IncludeExternalTenantsMembers            = @('11111111-1111-1111-1111-111111111111')
                    IncludeExternalTenantsMembershipKind     = 'enumerated'
                    IncludeGuestOrExternalUserTypes          = @('b2bCollaborationGuest')
                    PersistentBrowserIsEnabled               = $True
                    PersistentBrowserMode                    = 'Always'
                    DisableResilienceDefaultsIsEnabled       = $True
                    SecureSignInSessionIsEnabled             = $True
                    SignInFrequencyAuthenticationType        = 'primaryAndSecondaryAuthentication'
                    SignInFrequencyIsEnabled                 = $True
                    SignInFrequencyType                      = 'Days'
                    SignInFrequencyValue                     = 5
                    SignInRiskLevels                         = @('High')
                    State                                    = 'disabled'
                    UserRiskLevels                           = @('High')
                    DeviceFilterMode                         = 'exclude'
                    DeviceFilterRule                         = 'device.isCompliant -eq True -or device.trustType -eq "ServerAD"'
                }
            }

            It 'Should return Present from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'AADConditionalAccessPolicy' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'AADConditionalAccessPolicy' -Property $testParams).Test() | Should -Be $true
            }
        }

        Context -Name 'Policy exists but it should not' -Fixture {
            BeforeAll {
                $testParams = @{
                    ApplicationEnforcedRestrictionsIsEnabled = $True
                    AuthenticationStrength                   = "Phishing-resistant MFA"
                    BuiltInControls                          = @('Mfa', 'CompliantDevice', 'DomainJoinedDevice', 'ApprovedApplication', 'CompliantApplication')
                    ClientAppTypes                           = @('Browser', 'MobileAppsAndDesktopClients')
                    CloudAppSecurityIsEnabled                = $True
                    CloudAppSecurityType                     = 'MonitorOnly'
                    ContinuousAccessEvaluationMode           = 'strictLocation'
                    DisplayName                              = 'Allin'
                    Ensure                                   = 'Absent'
                    ExcludeApplications                      = @('Microsoft Rights Management Services', 'Office365')
                    ExcludeGroups                            = @('Group 01')
                    ExcludeLocations                         = 'Contoso LAN'
                    ExcludePlatforms                         = @('Windows', 'WindowsPhone', 'MacOS')
                    ExcludeRoles                             = @('Compliance Administrator')
                    ExcludeUsers                             = 'alexw@contoso.com'
                    Credential                               = $Credscredential
                    GrantControlOperator                     = 'AND'
                    Id                                       = 'bcc0cf19-ee89-46f0-8e12-4b89123ee6f9'
                    IncludeApplications                      = @('All')
                    IncludeGroups                            = @('Group 01')
                    IncludeLocations                         = 'AllTrusted'
                    IncludePlatforms                         = @('Android', 'IOS')
                    IncludeRoles                             = @('Compliance Administrator')
                    IncludeUserActions                       = @('urn:user:registersecurityinfo')
                    IncludeUsers                             = 'All'
                    PersistentBrowserIsEnabled               = $True
                    PersistentBrowserMode                    = 'Always'
                    DisableResilienceDefaultsIsEnabled       = $True
                    SecureSignInSessionIsEnabled             = $True
                    SignInFrequencyAuthenticationType        = 'primaryAndSecondaryAuthentication'
                    SignInFrequencyIsEnabled                 = $True
                    SignInFrequencyType                      = 'Days'
                    SignInFrequencyValue                     = 5
                    SignInRiskLevels                         = @('High')
                    State                                    = 'disabled'
                    UserRiskLevels                           = @('High')
                    DeviceFilterMode                         = 'exclude'
                    DeviceFilterRule                         = 'device.isCompliant -eq True -or device.trustType -eq "ServerAD"'
                }
            }

            It 'Should return Present from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'AADConditionalAccessPolicy' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'AADConditionalAccessPolicy' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should remove the policy from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'AADConditionalAccessPolicy' -Property $testParams).Set()
                Should -Invoke -CommandName Remove-MgBetaIdentityConditionalAccessPolicy -Exactly 1
            }
        }

        Context -Name 'ServicePrincipal filter with a single custom security attribute that exists in the tenant' -Fixture {
            BeforeAll {
                $testParams = @{
                    DisplayName                  = 'Allin'
                    Ensure                       = 'Present'
                    Credential                   = $Credscredential
                    State                        = 'disabled'
                    IncludeApplications          = @('All')
                    IncludeUsers                 = 'All'
                    ServicePrincipalFilterMode   = 'include'
                    ServicePrincipalFilterRule   = "CustomSecurityAttribute.AttributeSet_MyAttribute -eq 'Value1'"
                }

                Mock -CommandName Get-MgBetaIdentityConditionalAccessPolicy -MockWith {
                    return @{
                        Id          = 'bcc0cf19-ee89-46f0-8e12-4b89123ee6f9'
                        DisplayName = 'Allin'
                        State       = 'disabled'
                        Conditions  = @{
                            Applications        = @{
                                IncludeApplications = @('All')
                            }
                            Users               = @{
                                IncludeUsers = 'All'
                            }
                            ClientApplications  = @{
                                IncludeServicePrincipals = @()
                                ExcludeServicePrincipals = @()
                                ServicePrincipalFilter   = @{
                                    Mode = 'include'
                                    Rule = "CustomSecurityAttribute.AttributeSet_MyAttribute -eq 'Value1'"
                                }
                            }
                        }
                        GrantControls   = $null
                        SessionControls = $null
                    }
                }

                Mock -CommandName Get-MgDirectoryCustomSecurityAttributeDefinition -MockWith {
                    return @(
                        @{ id = 'AttributeSet_MyAttribute' }
                    )
                }
            }

            It 'Should return Present from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'AADConditionalAccessPolicy' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return the correct ServicePrincipalFilterMode from Get' {
                ((New-M365DSCResourceInstance -ResourceName 'AADConditionalAccessPolicy' -Property $testParams).Get().ToHashtable()).ServicePrincipalFilterMode | Should -Be 'include'
            }

            It 'Should return the correct ServicePrincipalFilterRule from Get' {
                ((New-M365DSCResourceInstance -ResourceName 'AADConditionalAccessPolicy' -Property $testParams).Get().ToHashtable()).ServicePrincipalFilterRule | Should -Be "CustomSecurityAttribute.AttributeSet_MyAttribute -eq 'Value1'"
            }

            It 'Should return true from the Test method when in desired state' {
                (New-M365DSCResourceInstance -ResourceName 'AADConditionalAccessPolicy' -Property $testParams).Test() | Should -Be $true
            }

            It 'Should validate the attributes and update the policy when applying the filter' {
                (New-M365DSCResourceInstance -ResourceName 'AADConditionalAccessPolicy' -Property $testParams).Set()
                Should -Invoke -CommandName Get-MgDirectoryCustomSecurityAttributeDefinition -Exactly 1
                Should -Invoke -CommandName Update-MgBetaIdentityConditionalAccessPolicy -Exactly 1
            }
        }

        Context -Name 'ServicePrincipal filter with multiple custom security attributes that all exist in the tenant' -Fixture {
            BeforeAll {
                $testParams = @{
                    DisplayName                  = 'Allin'
                    Ensure                       = 'Present'
                    Credential                   = $Credscredential
                    State                        = 'disabled'
                    IncludeApplications          = @('All')
                    IncludeUsers                 = 'All'
                    ServicePrincipalFilterMode   = 'exclude'
                    ServicePrincipalFilterRule   = "CustomSecurityAttribute.Set1_AttrA -eq 'Foo' -or CustomSecurityAttribute.Set2_AttrB -eq 'Bar'"
                }

                Mock -CommandName Get-MgBetaIdentityConditionalAccessPolicy -MockWith {
                    return @{
                        Id          = 'bcc0cf19-ee89-46f0-8e12-4b89123ee6f9'
                        DisplayName = 'Allin'
                        State       = 'disabled'
                        Conditions  = @{
                            Applications        = @{
                                IncludeApplications = @('All')
                            }
                            Users               = @{
                                IncludeUsers = 'All'
                            }
                            ClientApplications  = @{
                                IncludeServicePrincipals = @()
                                ExcludeServicePrincipals = @()
                                ServicePrincipalFilter   = @{
                                    Mode = 'exclude'
                                    Rule = "CustomSecurityAttribute.Set1_AttrA -eq 'Foo' -or CustomSecurityAttribute.Set2_AttrB -eq 'Bar'"
                                }
                            }
                        }
                        GrantControls   = $null
                        SessionControls = $null
                    }
                }

                Mock -CommandName Get-MgDirectoryCustomSecurityAttributeDefinition -MockWith {
                    return @(
                        @{ id = 'Set1_AttrA' }
                        @{ id = 'Set2_AttrB' }
                    )
                }
            }

            It 'Should return Present from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'AADConditionalAccessPolicy' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return the correct ServicePrincipalFilterMode from Get' {
                ((New-M365DSCResourceInstance -ResourceName 'AADConditionalAccessPolicy' -Property $testParams).Get().ToHashtable()).ServicePrincipalFilterMode | Should -Be 'exclude'
            }

            It 'Should return the correct ServicePrincipalFilterRule from Get' {
                ((New-M365DSCResourceInstance -ResourceName 'AADConditionalAccessPolicy' -Property $testParams).Get().ToHashtable()).ServicePrincipalFilterRule | Should -Be "CustomSecurityAttribute.Set1_AttrA -eq 'Foo' -or CustomSecurityAttribute.Set2_AttrB -eq 'Bar'"
            }

            It 'Should return true from the Test method when in desired state' {
                (New-M365DSCResourceInstance -ResourceName 'AADConditionalAccessPolicy' -Property $testParams).Test() | Should -Be $true
            }

            It 'Should validate the attributes and update the policy when applying the filter' {
                (New-M365DSCResourceInstance -ResourceName 'AADConditionalAccessPolicy' -Property $testParams).Set()
                Should -Invoke -CommandName Get-MgDirectoryCustomSecurityAttributeDefinition -Exactly 1
                Should -Invoke -CommandName Update-MgBetaIdentityConditionalAccessPolicy -Exactly 1
            }
        }

        Context -Name 'ServicePrincipal filter with a custom security attribute that does not exist in the tenant' -Fixture {
            BeforeAll {
                $testParams = @{
                    DisplayName                  = 'Allin'
                    Ensure                       = 'Present'
                    Credential                   = $Credscredential
                    State                        = 'disabled'
                    IncludeApplications          = @('All')
                    IncludeUsers                 = 'All'
                    ServicePrincipalFilterMode   = 'include'
                    ServicePrincipalFilterRule   = "CustomSecurityAttribute.AttributeSet_NonExistent -eq 'Value1'"
                }

                Mock -CommandName Get-MgBetaIdentityConditionalAccessPolicy -MockWith {
                    return $null
                }

                Mock -CommandName Get-MgDirectoryCustomSecurityAttributeDefinition -MockWith {
                    return @(

                    )
                }
            }

            It 'Should return absent from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'AADConditionalAccessPolicy' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Absent'
            }

            It 'Should throw when applying a filter that references a missing custom attribute' {
                { (New-M365DSCResourceInstance -ResourceName 'AADConditionalAccessPolicy' -Property $testParams).Set() } | Should -Throw
            }
        }

        Context -Name 'ServicePrincipal filter drift - mode changed' -Fixture {
            BeforeAll {
                $testParams = @{
                    DisplayName                  = 'Allin'
                    Ensure                       = 'Present'
                    Credential                   = $Credscredential
                    State                        = 'disabled'
                    IncludeApplications          = @('All')
                    IncludeUsers                 = 'All'
                    ServicePrincipalFilterMode   = 'exclude'
                    ServicePrincipalFilterRule   = "CustomSecurityAttribute.AttributeSet_MyAttribute -eq 'Value1'"
                }

                Mock -CommandName Get-MgBetaIdentityConditionalAccessPolicy -MockWith {
                    return @{
                        Id          = 'bcc0cf19-ee89-46f0-8e12-4b89123ee6f9'
                        DisplayName = 'Allin'
                        State       = 'disabled'
                        Conditions  = @{
                            Applications        = @{
                                IncludeApplications = @('All')
                            }
                            Users               = @{
                                IncludeUsers = 'All'
                            }
                            ClientApplications  = @{
                                IncludeServicePrincipals = @()
                                ExcludeServicePrincipals = @()
                                ServicePrincipalFilter   = @{
                                    Mode = 'include'  # drifted - policy has 'include', desired is 'exclude'
                                    Rule = "CustomSecurityAttribute.AttributeSet_MyAttribute -eq 'Value1'"
                                }
                            }
                        }
                        GrantControls   = $null
                        SessionControls = $null
                    }
                }

                Mock -CommandName Get-MgDirectoryCustomSecurityAttributeDefinition -MockWith {
                    return @(
                        @{ id = 'AttributeSet_MyAttribute' }
                    )
                }
            }

            It 'Should return Present from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'AADConditionalAccessPolicy' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method when ServicePrincipalFilterMode has drifted' {
                (New-M365DSCResourceInstance -ResourceName 'AADConditionalAccessPolicy' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should validate attributes and update the policy from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'AADConditionalAccessPolicy' -Property $testParams).Set()
                Should -Invoke -CommandName Get-MgDirectoryCustomSecurityAttributeDefinition -Exactly 1
                Should -Invoke -CommandName Update-MgBetaIdentityConditionalAccessPolicy -Exactly 1
            }
        }

        Context -Name 'ServicePrincipal filter drift - rule changed' -Fixture {
            BeforeAll {
                $testParams = @{
                    DisplayName                  = 'Allin'
                    Ensure                       = 'Present'
                    Credential                   = $Credscredential
                    State                        = 'disabled'
                    IncludeApplications          = @('All')
                    IncludeUsers                 = 'All'
                    ServicePrincipalFilterMode   = 'include'
                    ServicePrincipalFilterRule   = "CustomSecurityAttribute.AttributeSet_MyAttribute -eq 'NewValue'"
                }

                Mock -CommandName Get-MgBetaIdentityConditionalAccessPolicy -MockWith {
                    return @{
                        Id          = 'bcc0cf19-ee89-46f0-8e12-4b89123ee6f9'
                        DisplayName = 'Allin'
                        State       = 'disabled'
                        Conditions  = @{
                            Applications        = @{
                                IncludeApplications = @('All')
                            }
                            Users               = @{
                                IncludeUsers = 'All'
                            }
                            ClientApplications  = @{
                                IncludeServicePrincipals = @()
                                ExcludeServicePrincipals = @()
                                ServicePrincipalFilter   = @{
                                    Mode = 'include'
                                    Rule = "CustomSecurityAttribute.AttributeSet_MyAttribute -eq 'OldValue'"  # drifted
                                }
                            }
                        }
                        GrantControls   = $null
                        SessionControls = $null
                    }
                }

                Mock -CommandName Get-MgDirectoryCustomSecurityAttributeDefinition -MockWith {
                    return @(
                        @{ id = 'AttributeSet_MyAttribute' }
                    )
                }
            }

            It 'Should return Present from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'AADConditionalAccessPolicy' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method when ServicePrincipalFilterRule has drifted' {
                (New-M365DSCResourceInstance -ResourceName 'AADConditionalAccessPolicy' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should validate attributes and update the policy from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'AADConditionalAccessPolicy' -Property $testParams).Set()
                Should -Invoke -CommandName Get-MgDirectoryCustomSecurityAttributeDefinition -Exactly 1
                Should -Invoke -CommandName Update-MgBetaIdentityConditionalAccessPolicy -Exactly 1
            }
        }

        Context -Name 'Policy requires two terms of use' -Fixture {
            BeforeAll {
                $testParams = @{
                    DisplayName          = 'Allin'
                    Ensure               = 'Present'
                    Credential           = $Credscredential
                    State                = 'disabled'
                    IncludeApplications  = @('All')
                    IncludeUsers         = 'All'
                    GrantControlOperator = 'AND'
                    BuiltInControls      = @('Mfa')
                    TermsOfUse           = @('Contractor Data Handling Agreement', 'Employee Acceptable Use Policy')
                }

                Mock -CommandName Get-MgBetaIdentityConditionalAccessPolicy -MockWith {
                    return @{
                        Id              = 'bcc0cf19-ee89-46f0-8e12-4b89123ee6f9'
                        DisplayName     = 'Allin'
                        State           = 'disabled'
                        Conditions      = @{
                            Applications = @{
                                IncludeApplications = @('All')
                            }
                            Users        = @{
                                IncludeUsers = 'All'
                            }
                        }
                        GrantControls   = @{
                            Operator        = 'AND'
                            BuiltInControls = @('Mfa')
                            TermsOfUse      = @('4a2f1c8b-1b59-4f0e-9d21-2f8e5c3d7a10', 'b7c3e5d9-6f42-4a1b-8c07-19d4e2f6a5b3')
                        }
                        SessionControls = $null
                    }
                }
            }

            It 'Should resolve every terms of use id from the Get method' {
                $result = (New-M365DSCResourceInstance -ResourceName 'AADConditionalAccessPolicy' -Property $testParams).Get().ToHashtable()
                $result.TermsOfUse | Should -Be @('Contractor Data Handling Agreement', 'Employee Acceptable Use Policy')
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'AADConditionalAccessPolicy' -Property $testParams).Test() | Should -Be $true
            }

            It 'Should send every terms of use id from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'AADConditionalAccessPolicy' -Property $testParams).Set()
                Should -Invoke -CommandName Update-MgBetaIdentityConditionalAccessPolicy -Exactly 1 -ParameterFilter {
                    $BodyParameter.grantControls.termsOfUse.Count -eq 2 -and
                    $BodyParameter.grantControls.termsOfUse[0] -eq '4a2f1c8b-1b59-4f0e-9d21-2f8e5c3d7a10' -and
                    $BodyParameter.grantControls.termsOfUse[1] -eq 'b7c3e5d9-6f42-4a1b-8c07-19d4e2f6a5b3'
                }
            }
        }

        Context -Name 'Policy requires no terms of use' -Fixture {
            BeforeAll {
                $testParams = @{
                    DisplayName                        = 'Allin'
                    Ensure                             = 'Present'
                    Credential                         = $Credscredential
                    State                              = 'disabled'
                    IncludeApplications                = @('All')
                    IncludeUsers                       = 'All'
                    GrantControlOperator               = 'AND'
                    BuiltInControls                    = @('Mfa')
                    DisableResilienceDefaultsIsEnabled = $false
                }

                Mock -CommandName Get-MgBetaIdentityConditionalAccessPolicy -MockWith {
                    return @{
                        Id              = 'bcc0cf19-ee89-46f0-8e12-4b89123ee6f9'
                        DisplayName     = 'Allin'
                        State           = 'disabled'
                        Conditions      = @{
                            Applications = @{
                                IncludeApplications = @('All')
                            }
                            Users        = @{
                                IncludeUsers = 'All'
                            }
                        }
                        GrantControls   = @{
                            Operator        = 'AND'
                            BuiltInControls = @('Mfa')
                        }
                        SessionControls = $null
                    }
                }
            }

            It 'Should return an empty terms of use collection from the Get method' {
                $result = (New-M365DSCResourceInstance -ResourceName 'AADConditionalAccessPolicy' -Property $testParams).Get().ToHashtable()
                $result.TermsOfUse -is [System.String[]] | Should -BeTrue
                $result.TermsOfUse | Should -BeNullOrEmpty
                $result.DisableResilienceDefaultsIsEnabled | Should -Be $false
                Should -Invoke -CommandName Get-MgBetaAgreement -Exactly 0
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'AADConditionalAccessPolicy' -Property $testParams).Test() | Should -Be $true
            }
        }

        Context -Name 'Terms of use that the tenant does not hold' -Fixture {
            BeforeAll {
                $testParams = @{
                    DisplayName          = 'Allin'
                    Ensure               = 'Present'
                    Credential           = $Credscredential
                    State                = 'disabled'
                    IncludeApplications  = @('All')
                    IncludeUsers         = 'All'
                    GrantControlOperator = 'AND'
                    BuiltInControls      = @('Mfa')
                    TermsOfUse           = @('Vendor Confidentiality Agreement')
                }

                Mock -CommandName Get-MgBetaIdentityConditionalAccessPolicy -MockWith {
                    return @{
                        Id              = 'bcc0cf19-ee89-46f0-8e12-4b89123ee6f9'
                        DisplayName     = 'Allin'
                        State           = 'disabled'
                        Conditions      = @{
                            Applications = @{
                                IncludeApplications = @('All')
                            }
                            Users        = @{
                                IncludeUsers = 'All'
                            }
                        }
                        GrantControls   = @{
                            Operator        = 'AND'
                            BuiltInControls = @('Mfa')
                        }
                        SessionControls = $null
                    }
                }
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'AADConditionalAccessPolicy' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should omit the terms of use grant control from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'AADConditionalAccessPolicy' -Property $testParams).Set()
                Should -Invoke -CommandName Update-MgBetaIdentityConditionalAccessPolicy -Exactly 1 -ParameterFilter {
                    -not $BodyParameter.grantControls.ContainsKey('termsOfUse')
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
                $result = Invoke-M365DSCResourceMethod -ResourceName 'AADConditionalAccessPolicy' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
