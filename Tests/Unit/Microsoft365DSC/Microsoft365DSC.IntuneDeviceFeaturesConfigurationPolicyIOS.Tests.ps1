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
    -DscResource 'IntuneDeviceFeaturesConfigurationPolicyIOS' -GenericStubModule $GenericStubPath
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
                return @{
                    DisplayName                             = 'FakeStringValue'
                    Description                             = 'FakeStringValue'
                    Id                                      = 'ab915bca-1234-4b11-8acb-719a771139bc'
                    '@odata.type'              = '#microsoft.graph.iosDeviceFeaturesConfiguration'
                    wallpaperDisplayLocation   = 'notConfigured'
                    airPrintDestinations      = @(
                        @{
                            ipAddress     = '1.0.0.1'
                            resourcePath  = 'printers/xerox_Phase'
                            port          = 0
                            forceTls      = $false
                        }
                    )
                    contentFilterSettings     = @{
                            '@odata.Type' = '#microsoft.graph.iosWebContentFilterAutoFilter'
                            allowedUrls = @(
                                'https://www.fakeallowed.com'
                            )
                            blockedUrls = @(
                                'https://www.fakeblocked.com'
                            )
                    }
                    homeScreenDockIcons       = @(
                        @{
                            '@odata.type'   = '#microsoft.graph.iosHomeScreenApp'
                            displayName   = 'Apple Store'
                            bundleID      = 'com.apple.store.Jolly'
                            isWebClip     = $false
                        }
                    )
                    homeScreenPages           = @(
                        @{
                            icons = @(
                                @{
                                    '@odata.type'   = '#microsoft.graph.iosHomeScreenApp'
                                    displayName   = 'App Store'
                                    bundleID      = 'com.apple.AppStore'
                                    isWebClip     = $false
                                }
                            )
                        }
                    )
                    notificationSettings      = @(
                        @{
                            bundleID               = 'app.id'
                            appName                = 'fakeapp'
                            publisher              = 'fakepublisher'
                            enabled                = $true
                            showInNotificationCenter = $true
                            showOnLockScreen       = $true
                            alertType              = 'banner'
                            badgesEnabled          = $true
                            soundsEnabled          = $true
                            previewVisibility      = 'hideWhenLocked'
                        }
                    )
                    singleSignOnSettings      = @{
                        allowedUrls            = @('https://www.fakeurl.com')
                        displayName            = 'iOS-DeviceFeatures-ContentSettingsSpecificSites'
                        kerberosPrincipalName  = 'userPrincipalName'
                        kerberosRealm          = 'fakerealm.com'
                        allowedAppsList        = @(
                            @{
                                name   = 'Intune Company Portal'
                                appId  = 'com.microsoft.companyportal'
                            }
                        )
                    }
                    iosSingleSignOnExtension = @{
                        '@odata.type' = '#microsoft.graph.iosCredentialSingleSignOnExtension'
                        extensionIdentifier = 'com.example.sso.credential'
                        teamIdentifier      = '4HMSJJRMAD'
                        realm               = 'EXAMPLE.COM'
                        domains             = @('example.com')
                    }
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
        Context -Name "When the IntuneDeviceFeaturesConfigurationPolicyIOS doesn't already exist" -Fixture {
            BeforeAll {
               $testParams = @{
                    Description                                  = 'FakeStringValue'
                    DisplayName                                  = 'FakeStringValue'
                    Id                                           = 'FakeStringValue'
                    RoleScopeTagIds = @('Tag1', 'Tag2')
                    AirPrintDestinations = @(
                        ([MSFT_airPrintDestination] @{
                            port = 0
                            resourcePath = 'printers/xerox_Phase'
                            forceTls = $False
                            ipAddress = '1.0.0.1'
                        })
                    )
                    AssetTagTemplate                             = 'FakeStringValue'
                    ContentFilterSettings  = @(
                        ([MSFT_iosWebContentFilterSpecificWebsitesAccess] @{
                            dataType = '#microsoft.graph.iosWebContentFilterAutoFilter'
                            allowedUrls = @(
                                'https://www.fakeallowed.com'
                            )
                            blockedUrls = @(
                                'https://www.fakeblocked.com'
                            )
                        })
                    )
                    LockScreenFootnote                           = 'FakeStringValue'
                    HomeScreenDockIcons    = @(
                        ([MSFT_iosHomeScreenApp] @{
                            bundleID = 'com.apple.store.Jolly'
                            displayName = 'Apple Store'
                            isWebClip = $False
                        })
                    )
                    HomeScreenGridWidth                          = 5
                    HomeScreenGridHeight                         = 6
                    HomeScreenPages = @(
                        ([MSFT_iosHomeScreenItem] @{
                            icons = @(
                                ([MSFT_iosHomeScreenApp] @{
                                    bundleID = 'com.apple.AppStore'
                                    displayName = 'App Store'
                                    isWebClip = $False
                                })
                            )
                        })
                    )
                    NotificationSettings = @(
                        ([MSFT_iosNotificationSettings] @{
                            alertType = 'banner'
                            enabled = $True
                            showOnLockScreen = $True
                            badgesEnabled = $True
                            soundsEnabled = $True
                            publisher = 'fakepublisher'
                            bundleID = 'app.id'
                            showInNotificationCenter = $True
                            previewVisibility = 'hideWhenLocked'
                            appName = 'fakeapp'
                        })
                    )
                    SingleSignOnSettings = @(
                        ([MSFT_iosSingleSignOnSettings] @{
                            allowedAppsList = @(
                                ([MSFT_appListItem] @{
                                    appId = 'com.microsoft.companyportal'
                                    name = 'Intune Company Portal'
                                })
                            )
                            allowedUrls = @('https://www.fakeurl.com')
                            kerberosRealm = 'fakerealm.com'
                            displayName = 'iOS-DeviceFeatures-ContentSettingsSpecificSites'
                            kerberosPrincipalName = 'userPrincipalName'
                        })
                    )
                    WallpaperDisplayLocation                     = 'notConfigured'
                    WallpaperImage                               = @()
                    IosSingleSignOnExtension                     = @(
                        ([MSFT_iosSingleSignOnExtension] @{
                            dataType = '#microsoft.graph.iosCredentialSingleSignOnExtension'
                            extensionIdentifier = 'com.example.sso.credential'
                            domains = @('fakedomain.com')
                            configurations = @(
                                ([MSFT_keyTypedValuePair] @{
                                    key = 'myString'
                                    dataType = '#microsoft.graph.keyStringValuePair'
                                    value = 'myvalue'
                                })

                                ([MSFT_keyTypedValuePair] @{
                                    key = 'mybool'
                                    dataType = '#microsoft.graph.keyBooleanValuePair'
                                    value = $True
                                })

                                ([MSFT_keyTypedValuePair] @{
                                    key = 'myInt'
                                    dataType = '#microsoft.graph.keyIntegerValuePair'
                                    value = 4
                                })
                            )
                            teamIdentifier                     = '4HMSJJRMAD'
                            realm                              = 'EXAMPLE.COM'
                        })
                    )
                    Assignments                                = @()
                    Ensure                                     = 'Present'
                    Credential                                 = $Credential
                }

                Mock -CommandName Get-MgBetaDeviceManagementDeviceConfiguration -MockWith {
                    return $null
                }
            }

            It 'Should return absent from the Get method' {
                    ((New-M365DSCResourceInstance -ResourceName 'IntuneDeviceFeaturesConfigurationPolicyIOS' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Absent'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneDeviceFeaturesConfigurationPolicyIOS' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should create the IntuneDeviceFeaturesConfigurationPolicyIOS from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneDeviceFeaturesConfigurationPolicyIOS' -Property $testParams).Set()
                Should -Invoke -CommandName 'New-MgBetaDeviceManagementDeviceConfiguration' -Exactly 1
            }
        }

        Context -Name 'When the IntuneDeviceFeaturesConfigurationPolicyIOS already exists and is NOT in the Desired State' -Fixture {
            BeforeAll {
               $testParams = @{
                    Assignments              = @()
                    Description              = 'FakeStringValue'
                    DisplayName              = 'FakeStringValue'
                    Id                       = 'ab915bca-1234-4b11-8acb-719a771139bc'
                    TenantId                 = $OrganizationName;
                    WallpaperDisplayLocation = 'notConfigured';
                    AirPrintDestinations = @(
                        ([MSFT_airPrintDestination] @{
                            port = 0
                            resourcePath = 'printers/xerox_Phase'
                            forceTls = $False
                            ipAddress = '1.0.0.1'
                        })
                    )
                   ContentFilterSettings = @(
                        ([MSFT_iosWebContentFilterSpecificWebsitesAccess] @{
                            dataType = '#microsoft.graph.iosWebContentFilterAutoFilter'
                            allowedUrls = @(
                                'https://www.fakeallowed.com'
                            )
                            blockedUrls = @(
                                'https://www.fakeblocked.com'
                            )
                        })
                    )
                    HomeScreenDockIcons = @(
                        ([MSFT_iosHomeScreenApp] @{
                            bundleID = 'com.apple.store.Jolly'
                            displayName = 'Apple Store'
                            isWebClip = $False
                        })
                    )
                    HomeScreenPages = @(
                        ([MSFT_iosHomeScreenItem] @{
                            icons = @(
                                ([MSFT_iosHomeScreenApp] @{
                                    bundleID = 'com.apple.AppStore'
                                    displayName = 'App Store'
                                    isWebClip = $False
                                })
                            )
                        })
                    )
                    NotificationSettings = @(
                        ([MSFT_iosNotificationSettings] @{
                            alertType = 'banner'
                            enabled = $True
                            showOnLockScreen = $False # Updated property
                            badgesEnabled = $True
                            soundsEnabled = $True
                            publisher = 'fakepublisher'
                            bundleID = 'app.id'
                            showInNotificationCenter = $True
                            previewVisibility = 'hideWhenLocked'
                            appName = 'fakeapp'
                        })
                    )
                    SingleSignOnSettings = @(
                        ([MSFT_iosSingleSignOnSettings] @{
                            allowedAppsList = @(
                                ([MSFT_appListItem] @{
                                    appId = 'com.microsoft.companyportal'
                                    name = 'Intune Company Portal'
                                })
                            )
                            allowedUrls = @('https://www.fakeurl.com')
                            kerberosRealm = 'fakerealm.com'
                            displayName = 'iOS-DeviceFeatures-ContentSettingsSpecificSites'
                            kerberosPrincipalName = 'userPrincipalName'
                        })
                    )
                    IosSingleSignOnExtension = @(
                        ([MSFT_iosSingleSignOnExtension] @{
                            dataType           = '#microsoft.graph.iosCredentialSingleSignOnExtension'
                            extensionIdentifier = 'com.example.sso.credential'
                            teamIdentifier      = '4HMSJJRMAD'
                            realm              = 'EXAMPLE.COM'
                            domains            = @('example.com')
                        })
                    )
                    Ensure                                       = 'Present'
                    Credential                                   = $Credential
                }
            }

            It 'Should return Present from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'IntuneDeviceFeaturesConfigurationPolicyIOS' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneDeviceFeaturesConfigurationPolicyIOS' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should update the IntuneDeviceFeaturesConfigurationPolicyIOS from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneDeviceFeaturesConfigurationPolicyIOS' -Property $testParams).Set()
                Should -Invoke -CommandName Update-MgBetaDeviceManagementDeviceConfiguration -Exactly 1
            }
        }

       Context -Name 'When the policy already exists and IS in the Desired State' -Fixture {
            BeforeAll {
               $testParams = @{
                    Assignments              = @()
                    Description              = 'FakeStringValue'
                    DisplayName              = 'FakeStringValue'
                    Id                       = 'ab915bca-1234-4b11-8acb-719a771139bc'
                    TenantId                 = $OrganizationName;
                    WallpaperDisplayLocation = 'notConfigured';
                    AirPrintDestinations = @(
                        ([MSFT_airPrintDestination] @{
                            port = 0
                            resourcePath = 'printers/xerox_Phase'
                            forceTls = $False
                            ipAddress = '1.0.0.1'
                        })
                    )
                   ContentFilterSettings  = @(
                        ([MSFT_iosWebContentFilterSpecificWebsitesAccess] @{
                            dataType = '#microsoft.graph.iosWebContentFilterAutoFilter'
                            allowedUrls = @(
                                'https://www.fakeallowed.com'
                            )
                            blockedUrls = @(
                                'https://www.fakeblocked.com'
                            )
                        })
                    )
                    HomeScreenDockIcons    = @(
                        ([MSFT_iosHomeScreenApp] @{
                            bundleID = 'com.apple.store.Jolly'
                            displayName = 'Apple Store'
                            isWebClip = $False
                        })
                    )
                    HomeScreenPages        = @(
                        ([MSFT_iosHomeScreenItem] @{
                            icons = @(
                                ([MSFT_iosHomeScreenApp] @{
                                    bundleID = 'com.apple.AppStore'
                                    displayName = 'App Store'
                                    isWebClip = $False
                                })
                            )
                        })
                    )
                    NotificationSettings   = @(
                        ([MSFT_iosNotificationSettings] @{
                            alertType = 'banner'
                            enabled = $True
                            showOnLockScreen = $True
                            badgesEnabled = $True
                            soundsEnabled = $True
                            publisher = 'fakepublisher'
                            bundleID = 'app.id'
                            showInNotificationCenter = $True
                            previewVisibility = 'hideWhenLocked'
                            appName = 'fakeapp'
                        })
                    )
                    SingleSignOnSettings   = @(
                        ([MSFT_iosSingleSignOnSettings] @{
                            allowedAppsList = @(
                                ([MSFT_appListItem] @{
                                    appId = 'com.microsoft.companyportal'
                                    name = 'Intune Company Portal'
                                })
                            )
                            allowedUrls = @('https://www.fakeurl.com')
                            kerberosRealm = 'fakerealm.com'
                            displayName = 'iOS-DeviceFeatures-ContentSettingsSpecificSites'
                            kerberosPrincipalName = 'userPrincipalName'
                        })
                    )
                    IosSingleSignOnExtension = @(
                        ([MSFT_iosSingleSignOnExtension] @{
                            dataType           = '#microsoft.graph.iosCredentialSingleSignOnExtension'
                            extensionIdentifier = 'com.example.sso.credential'
                            teamIdentifier      = '4HMSJJRMAD'
                            realm              = 'EXAMPLE.COM'
                            domains            = @('example.com')
                        })
                    )
                    Ensure                                       = 'Present'
                    Credential                                   = $Credential
                }
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneDeviceFeaturesConfigurationPolicyIOS' -Property $testParams).Test() | Should -Be $true
            }
        }

        Context -Name 'When the policy exists and it SHOULD NOT' -Fixture {
            BeforeAll {
               $testParams = @{
                    Description                                  = 'FakeStringValue'
                    DisplayName                                  = 'FakeStringValue'
                    Id                                           = 'FakeStringValue'
                    RoleScopeTagIds                              = @('0')
                    WallpaperDisplayLocation                     = 'notConfigured'
                    Assignments                                  = @()
                    Ensure                                       = 'Absent'
                    Credential                                   = $Credential
                }
            }

            It 'Should return Present from the Get method' {
                    ((New-M365DSCResourceInstance -ResourceName 'IntuneDeviceFeaturesConfigurationPolicyIOS' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneDeviceFeaturesConfigurationPolicyIOS' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should remove the IntuneDeviceFeaturesConfigurationPolicyIOS from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneDeviceFeaturesConfigurationPolicyIOS' -Property $testParams).Set()
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
                $result = Invoke-M365DSCResourceMethod -ResourceName 'IntuneDeviceFeaturesConfigurationPolicyIOS' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
