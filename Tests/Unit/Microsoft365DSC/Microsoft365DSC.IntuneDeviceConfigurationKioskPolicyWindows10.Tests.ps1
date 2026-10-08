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
    -DscResource "IntuneDeviceConfigurationKioskPolicyWindows10" -GenericStubModule $GenericStubPath
Describe -Name $Global:DscHelper.DescribeHeader -Fixture {
    InModuleScope -ModuleName $Global:DscHelper.ModuleName -ScriptBlock {
        Invoke-Command -ScriptBlock $Global:DscHelper.InitializeScript -NoNewScope
        BeforeAll {

            $secpasswd = ConvertTo-SecureString (New-Guid | Out-String) -AsPlainText -Force
            $Credential = New-Object System.Management.Automation.PSCredential ('tenantadmin@onmicrosoft.com', $secpasswd)

            Mock -ModuleName M365DSCUtil -CommandName Confirm-M365DSCDependencies -MockWith {
            }

            Mock -CommandName Update-MgBetaDeviceManagementDeviceConfiguration -MockWith {
            }

            Mock -CommandName New-MgBetaDeviceManagementDeviceConfiguration -MockWith {
            }

            Mock -CommandName Remove-MgBetaDeviceManagementDeviceConfiguration -MockWith {
            }

            Mock -CommandName New-M365DSCConnection -ModuleName '_Shared' -MockWith {
                return "Credentials"
            }

            Mock -CommandName Get-M365DSCExportCachedCollection -MockWith {
                return Get-MgBetaDeviceManagementDeviceConfiguration
            }
            Mock -CommandName Get-MgBetaDeviceManagementDeviceConfiguration -MockWith {
                return @{
                    kioskBrowserBlockedURLs = @("FakeStringValue")
                    kioskBrowserDefaultUrl = "FakeStringValue"
                    '@odata.type' = "#microsoft.graph.windowsKioskConfiguration"
                    kioskBrowserEnableNavigationButtons = $True
                    edgeKioskEnablePublicBrowsing = $True
                    kioskBrowserRestartOnIdleTimeInMinutes = 25
                    kioskBrowserBlockedUrlExceptions = @("FakeStringValue")
                    kioskBrowserEnableHomeButton = $True
                    windowsKioskForceUpdateSchedule = @{
                        runImmediatelyIfAfterStartDateTime = $True
                        startDateTime = "2023-01-01T00:00:00.0000000+00:00"
                        dayofMonth = 25
                        recurrence = "none"
                        dayofWeek = "sunday"
                    }
                    kioskProfiles = @(
                        @{
                            profileId = "FakeStringValue"
                            userAccountsConfiguration = @(
                                @{
                                    groupId = "FakeStringValue"
                                    '@odata.type' = "#microsoft.graph.windowsKioskActiveDirectoryGroup"
                                    userName = "FakeStringValue"
                                    userPrincipalName = "FakeStringValue"
                                    groupName = "FakeStringValue"
                                    userId = "FakeStringValue"
                                    displayName = "FakeStringValue"
                                }
                            )
                            profileName = "FakeStringValue"
                            appConfiguration = @{
                                uwpApp = @{
                                    edgeNoFirstRun = $True
                                    name = "FakeStringValue"
                                    edgeKiosk = "FakeStringValue"
                                    classicAppPath = "FakeStringValue"
                                    appId = "FakeStringValue"
                                    appUserModelId = "FakeStringValue"
                                    edgeKioskIdleTimeoutMinutes = 25
                                    autoLaunch = $True
                                    startLayoutTileSize = "hidden"
                                    appType = "unknown"
                                    '@odata.type' = "#microsoft.graph.windowsKioskDesktopApp"
                                    edgeKioskType = "publicBrowsing"
                                    containedAppId = "FakeStringValue"
                                    desktopApplicationId = "FakeStringValue"
                                    desktopApplicationLinkPath = "FakeStringValue"
                                    path = "FakeStringValue"
                                }
                                win32App = @{
                                    edgeNoFirstRun = $True
                                    name = "FakeStringValue"
                                    edgeKiosk = "FakeStringValue"
                                    classicAppPath = "FakeStringValue"
                                    edgeKioskIdleTimeoutMinutes = 25
                                    appUserModelId = "FakeStringValue"
                                    appId = "FakeStringValue"
                                    autoLaunch = $True
                                    startLayoutTileSize = "hidden"
                                    appType = "unknown"
                                    '@odata.type' = "#microsoft.graph.windowsKioskDesktopApp"
                                    edgeKioskType = "publicBrowsing"
                                    containedAppId = "FakeStringValue"
                                    desktopApplicationId = "FakeStringValue"
                                    desktopApplicationLinkPath = "FakeStringValue"
                                    path = "FakeStringValue"
                                }
                                '@odata.type' = "#microsoft.graph.windowsKioskMultipleApps"
                                apps = @(
                                    @{
                                        edgeNoFirstRun = $True
                                        name = "FakeStringValue"
                                        edgeKiosk = "FakeStringValue"
                                        classicAppPath = "FakeStringValue"
                                        appId = "FakeStringValue"
                                        appUserModelId = "FakeStringValue"
                                        edgeKioskIdleTimeoutMinutes = 25
                                        autoLaunch = $True
                                        startLayoutTileSize = "hidden"
                                        appType = "unknown"
                                        '@odata.type' = "#microsoft.graph.windowsKioskDesktopApp"
                                        edgeKioskType = "publicBrowsing"
                                        containedAppId = "FakeStringValue"
                                        desktopApplicationId = "FakeStringValue"
                                        desktopApplicationLinkPath = "FakeStringValue"
                                        path = "FakeStringValue"
                                    }
                                )
                                allowAccessToDownloadsFolder = $True
                                showTaskBar = $True
                                disallowDesktopApps = $True
                                startMenuLayoutXml = $True
                            }
                        }
                    )
                    kioskBrowserEnableEndSessionButton = $True
                    description = "FakeStringValue"
                    DeviceManagementApplicabilityRuleDeviceMode = @{
                        Name = "FakeStringValue"
                        DeviceMode = "standardConfiguration"
                        RuleType = "include"
                    }
                    DeviceManagementApplicabilityRuleOsEdition = @{
                        Name = "FakeStringValue"
                        OsEditionTypes = @("windows10Enterprise")
                        RuleType = "include"
                    }
                    DeviceManagementApplicabilityRuleOsVersion = @{
                        Name = "FakeStringValue"
                        MinOSVersion = "10.0.19045.0"
                        MaxOSVersion = "10.0.26100.9999"
                        RuleType = "include"
                    }
                    displayName = "FakeStringValue"
                    id = "FakeStringValue"

                }
            }

            # Mock Write-M365DSCHost to hide output during the tests
            Mock -CommandName Write-M365DSCHost -MockWith {
            }
            $Script:exportedInstances =$null
            $Script:ExportMode = $false

            Mock -CommandName Get-MgBetaDeviceManagementDeviceConfigurationAssignment -MockWith {
            }
            Mock -CommandName Update-DeviceConfigurationPolicyAssignment -MockWith {
            }
        }
        # Test contexts
        Context -Name "The IntuneDeviceConfigurationKioskPolicyWindows10 should exist but it DOES NOT" -Fixture {
            BeforeAll {
                $testParams = @{
                    description = "FakeStringValue"
                    DeviceManagementApplicabilityRuleDeviceMode = @{
                        Name = "FakeStringValue"
                        DeviceMode = "standardConfiguration"
                        RuleType = "include"
                    }
                    DeviceManagementApplicabilityRuleOsEdition = @{
                        Name = "FakeStringValue"
                        OsEditionTypes = @("windows10Enterprise")
                        RuleType = "include"
                    }
                    DeviceManagementApplicabilityRuleOsVersion = @{
                        Name = "FakeStringValue"
                        MinOSVersion = "10.0.19045.0"
                        MaxOSVersion = "10.0.26100.9999"
                        RuleType = "include"
                    }
                    displayName = "FakeStringValue"
                    EdgeKioskEnablePublicBrowsing = $True
                    id = "FakeStringValue"
                    KioskBrowserBlockedUrlExceptions = @("FakeStringValue")
                    KioskBrowserBlockedURLs = @("FakeStringValue")
                    KioskBrowserDefaultUrl = "FakeStringValue"
                    KioskBrowserEnableEndSessionButton = $True
                    KioskBrowserEnableHomeButton = $True
                    KioskBrowserEnableNavigationButtons = $True
                    KioskBrowserRestartOnIdleTimeInMinutes = 25
                    kioskProfiles = @(
                        ([MSFT_MicrosoftGraphwindowsKioskProfile] @{
                            userAccountsConfiguration = @(
                                ([MSFT_MicrosoftGraphWindowsKioskUser] @{
                                    groupId = "FakeStringValue"
                                    userName = "FakeStringValue"
                                    userPrincipalName = "FakeStringValue"
                                    odataType = "#microsoft.graph.windowsKioskActiveDirectoryGroup"
                                    groupName = "FakeStringValue"
                                    userId = "FakeStringValue"
                                    displayName = "FakeStringValue"
                                })
                            )
                            profileName = "FakeStringValue"
                            appConfiguration = ([MSFT_MicrosoftGraphWindowsKioskAppConfiguration] @{
                                uwpApp = ([MSFT_MicrosoftGraphWindowsKioskUWPApp] @{
                                    edgeNoFirstRun = $True
                                    name = "FakeStringValue"
                                    edgeKiosk = "FakeStringValue"
                                    classicAppPath = "FakeStringValue"
                                    appId = "FakeStringValue"
                                    appUserModelId = "FakeStringValue"
                                    edgeKioskIdleTimeoutMinutes = 25
                                    autoLaunch = $True
                                    startLayoutTileSize = "hidden"
                                    appType = "unknown"
                                    edgeKioskType = "publicBrowsing"
                                    containedAppId = "FakeStringValue"
                                    desktopApplicationId = "FakeStringValue"
                                    desktopApplicationLinkPath = "FakeStringValue"
                                    path = "FakeStringValue"
                                    odataType = "#microsoft.graph.windowsKioskDesktopApp"
                                })
                                win32App = ([MSFT_MicrosoftGraphWindowsKioskWin32App] @{
                                    edgeNoFirstRun = $True
                                    name = "FakeStringValue"
                                    edgeKiosk = "FakeStringValue"
                                    classicAppPath = "FakeStringValue"
                                    edgeKioskIdleTimeoutMinutes = 25
                                    appUserModelId = "FakeStringValue"
                                    appId = "FakeStringValue"
                                    autoLaunch = $True
                                    startLayoutTileSize = "hidden"
                                    appType = "unknown"
                                    edgeKioskType = "publicBrowsing"
                                    containedAppId = "FakeStringValue"
                                    desktopApplicationId = "FakeStringValue"
                                    desktopApplicationLinkPath = "FakeStringValue"
                                    path = "FakeStringValue"
                                    odataType = "#microsoft.graph.windowsKioskDesktopApp"
                                })
                                apps = @(
                                    ([MSFT_MicrosoftGraphWindowsKioskAppBase] @{
                                        edgeNoFirstRun = $True
                                        name = "FakeStringValue"
                                        edgeKiosk = "FakeStringValue"
                                        classicAppPath = "FakeStringValue"
                                        appId = "FakeStringValue"
                                        appUserModelId = "FakeStringValue"
                                        edgeKioskIdleTimeoutMinutes = 25
                                        autoLaunch = $True
                                        startLayoutTileSize = "hidden"
                                        appType = "unknown"
                                        edgeKioskType = "publicBrowsing"
                                        containedAppId = "FakeStringValue"
                                        desktopApplicationId = "FakeStringValue"
                                        desktopApplicationLinkPath = "FakeStringValue"
                                        path = "FakeStringValue"
                                        odataType = "#microsoft.graph.windowsKioskDesktopApp"
                                    })
                                )
                                allowAccessToDownloadsFolder = $True
                                showTaskBar = $True
                                disallowDesktopApps = $True
                                odataType = "#microsoft.graph.windowsKioskMultipleApps"
                                startMenuLayoutXml = $True
                            })
                        })
                    )
                    windowsKioskForceUpdateSchedule = ([MSFT_MicrosoftGraphwindowsKioskForceUpdateSchedule] @{
                        runImmediatelyIfAfterStartDateTime = $True
                        startDateTime = "2023-01-01T00:00:00.0000000+00:00"
                        dayofMonth = 25
                        recurrence = "none"
                        dayofWeek = "sunday"
                    })
                    Ensure = "Present"
                    Credential = $Credential;
                }

                Mock -CommandName Get-MgBetaDeviceManagementDeviceConfiguration -MockWith {
                    return $null
                }
            }
            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'IntuneDeviceConfigurationKioskPolicyWindows10' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Absent'
            }
            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneDeviceConfigurationKioskPolicyWindows10' -Property $testParams).Test() | Should -Be $false
            }
            It 'Should Create the group from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneDeviceConfigurationKioskPolicyWindows10' -Property $testParams).Set()
                Should -Invoke -CommandName New-MgBetaDeviceManagementDeviceConfiguration -Exactly 1
            }
        }

        Context -Name "The IntuneDeviceConfigurationKioskPolicyWindows10 exists but it SHOULD NOT" -Fixture {
            BeforeAll {
                $testParams = @{
                    description = "FakeStringValue"
                    DeviceManagementApplicabilityRuleDeviceMode = @{
                        Name = "FakeStringValue"
                        DeviceMode = "standardConfiguration"
                        RuleType = "include"
                    }
                    DeviceManagementApplicabilityRuleOsEdition = @{
                        Name = "FakeStringValue"
                        OsEditionTypes = @("windows10Enterprise")
                        RuleType = "include"
                    }
                    DeviceManagementApplicabilityRuleOsVersion = @{
                        Name = "FakeStringValue"
                        MinOSVersion = "10.0.19045.0"
                        MaxOSVersion = "10.0.26100.9999"
                        RuleType = "include"
                    }
                    displayName = "FakeStringValue"
                    EdgeKioskEnablePublicBrowsing = $True
                    id = "FakeStringValue"
                    KioskBrowserBlockedUrlExceptions = @("FakeStringValue")
                    KioskBrowserBlockedURLs = @("FakeStringValue")
                    KioskBrowserDefaultUrl = "FakeStringValue"
                    KioskBrowserEnableEndSessionButton = $True
                    KioskBrowserEnableHomeButton = $True
                    KioskBrowserEnableNavigationButtons = $True
                    KioskBrowserRestartOnIdleTimeInMinutes = 25
                    kioskProfiles = @(
                        ([MSFT_MicrosoftGraphwindowsKioskProfile] @{
                            userAccountsConfiguration = @(
                                ([MSFT_MicrosoftGraphWindowsKioskUser] @{
                                    groupId = "FakeStringValue"
                                    userName = "FakeStringValue"
                                    userPrincipalName = "FakeStringValue"
                                    odataType = "#microsoft.graph.windowsKioskActiveDirectoryGroup"
                                    groupName = "FakeStringValue"
                                    userId = "FakeStringValue"
                                    displayName = "FakeStringValue"
                                })
                            )
                            profileName = "FakeStringValue"
                            appConfiguration = ([MSFT_MicrosoftGraphWindowsKioskAppConfiguration] @{
                                uwpApp = ([MSFT_MicrosoftGraphWindowsKioskUWPApp] @{
                                    edgeNoFirstRun = $True
                                    name = "FakeStringValue"
                                    edgeKiosk = "FakeStringValue"
                                    classicAppPath = "FakeStringValue"
                                    appId = "FakeStringValue"
                                    appUserModelId = "FakeStringValue"
                                    edgeKioskIdleTimeoutMinutes = 25
                                    autoLaunch = $True
                                    startLayoutTileSize = "hidden"
                                    appType = "unknown"
                                    edgeKioskType = "publicBrowsing"
                                    containedAppId = "FakeStringValue"
                                    desktopApplicationId = "FakeStringValue"
                                    desktopApplicationLinkPath = "FakeStringValue"
                                    path = "FakeStringValue"
                                    odataType = "#microsoft.graph.windowsKioskDesktopApp"
                                })
                                win32App = ([MSFT_MicrosoftGraphWindowsKioskWin32App] @{
                                    edgeNoFirstRun = $True
                                    name = "FakeStringValue"
                                    edgeKiosk = "FakeStringValue"
                                    classicAppPath = "FakeStringValue"
                                    edgeKioskIdleTimeoutMinutes = 25
                                    appUserModelId = "FakeStringValue"
                                    appId = "FakeStringValue"
                                    autoLaunch = $True
                                    startLayoutTileSize = "hidden"
                                    appType = "unknown"
                                    edgeKioskType = "publicBrowsing"
                                    containedAppId = "FakeStringValue"
                                    desktopApplicationId = "FakeStringValue"
                                    desktopApplicationLinkPath = "FakeStringValue"
                                    path = "FakeStringValue"
                                    odataType = "#microsoft.graph.windowsKioskDesktopApp"
                                })
                                apps = @(
                                    ([MSFT_MicrosoftGraphWindowsKioskAppBase] @{
                                        edgeNoFirstRun = $True
                                        name = "FakeStringValue"
                                        edgeKiosk = "FakeStringValue"
                                        classicAppPath = "FakeStringValue"
                                        appId = "FakeStringValue"
                                        appUserModelId = "FakeStringValue"
                                        edgeKioskIdleTimeoutMinutes = 25
                                        autoLaunch = $True
                                        startLayoutTileSize = "hidden"
                                        appType = "unknown"
                                        edgeKioskType = "publicBrowsing"
                                        containedAppId = "FakeStringValue"
                                        desktopApplicationId = "FakeStringValue"
                                        desktopApplicationLinkPath = "FakeStringValue"
                                        path = "FakeStringValue"
                                        odataType = "#microsoft.graph.windowsKioskDesktopApp"
                                    })
                                )
                                allowAccessToDownloadsFolder = $True
                                showTaskBar = $True
                                disallowDesktopApps = $True
                                odataType = "#microsoft.graph.windowsKioskMultipleApps"
                                startMenuLayoutXml = $True
                            })
                        })
                    )
                    windowsKioskForceUpdateSchedule = ([MSFT_MicrosoftGraphwindowsKioskForceUpdateSchedule] @{
                        runImmediatelyIfAfterStartDateTime = $True
                        startDateTime = "2023-01-01T00:00:00.0000000+00:00"
                        dayofMonth = 25
                        recurrence = "none"
                        dayofWeek = "sunday"
                    })
                    Ensure = 'Absent'
                    Credential = $Credential;
                }
            }

            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'IntuneDeviceConfigurationKioskPolicyWindows10' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneDeviceConfigurationKioskPolicyWindows10' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should Remove the group from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneDeviceConfigurationKioskPolicyWindows10' -Property $testParams).Set()
                Should -Invoke -CommandName Remove-MgBetaDeviceManagementDeviceConfiguration -Exactly 1
            }
        }
        Context -Name "The IntuneDeviceConfigurationKioskPolicyWindows10 Exists and Values are already in the desired state" -Fixture {
            BeforeAll {
                $testParams = @{
                    description = "FakeStringValue"
                    DeviceManagementApplicabilityRuleDeviceMode = @{
                        Name = "FakeStringValue"
                        DeviceMode = "standardConfiguration"
                        RuleType = "include"
                    }
                    DeviceManagementApplicabilityRuleOsEdition = @{
                        Name = "FakeStringValue"
                        OsEditionTypes = @("windows10Enterprise")
                        RuleType = "include"
                    }
                    DeviceManagementApplicabilityRuleOsVersion = @{
                        Name = "FakeStringValue"
                        MinOSVersion = "10.0.19045.0"
                        MaxOSVersion = "10.0.26100.9999"
                        RuleType = "include"
                    }
                    displayName = "FakeStringValue"
                    EdgeKioskEnablePublicBrowsing = $True
                    id = "FakeStringValue"
                    KioskBrowserBlockedUrlExceptions = @("FakeStringValue")
                    KioskBrowserBlockedURLs = @("FakeStringValue")
                    KioskBrowserDefaultUrl = "FakeStringValue"
                    KioskBrowserEnableEndSessionButton = $True
                    KioskBrowserEnableHomeButton = $True
                    KioskBrowserEnableNavigationButtons = $True
                    KioskBrowserRestartOnIdleTimeInMinutes = 25
                    kioskProfiles = @(
                        ([MSFT_MicrosoftGraphwindowsKioskProfile] @{
                            userAccountsConfiguration = @(
                                ([MSFT_MicrosoftGraphWindowsKioskUser] @{
                                    groupId = "FakeStringValue"
                                    userName = "FakeStringValue"
                                    userPrincipalName = "FakeStringValue"
                                    odataType = "#microsoft.graph.windowsKioskActiveDirectoryGroup"
                                    groupName = "FakeStringValue"
                                    userId = "FakeStringValue"
                                    displayName = "FakeStringValue"
                                })
                            )
                            profileName = "FakeStringValue"
                            appConfiguration = ([MSFT_MicrosoftGraphWindowsKioskAppConfiguration] @{
                                uwpApp = ([MSFT_MicrosoftGraphWindowsKioskUWPApp] @{
                                    edgeNoFirstRun = $True
                                    name = "FakeStringValue"
                                    edgeKiosk = "FakeStringValue"
                                    classicAppPath = "FakeStringValue"
                                    appId = "FakeStringValue"
                                    appUserModelId = "FakeStringValue"
                                    edgeKioskIdleTimeoutMinutes = 25
                                    autoLaunch = $True
                                    startLayoutTileSize = "hidden"
                                    appType = "unknown"
                                    edgeKioskType = "publicBrowsing"
                                    containedAppId = "FakeStringValue"
                                    desktopApplicationId = "FakeStringValue"
                                    desktopApplicationLinkPath = "FakeStringValue"
                                    path = "FakeStringValue"
                                    odataType = "#microsoft.graph.windowsKioskDesktopApp"
                                })
                                win32App = ([MSFT_MicrosoftGraphWindowsKioskWin32App] @{
                                    edgeNoFirstRun = $True
                                    name = "FakeStringValue"
                                    edgeKiosk = "FakeStringValue"
                                    classicAppPath = "FakeStringValue"
                                    edgeKioskIdleTimeoutMinutes = 25
                                    appUserModelId = "FakeStringValue"
                                    appId = "FakeStringValue"
                                    autoLaunch = $True
                                    startLayoutTileSize = "hidden"
                                    appType = "unknown"
                                    edgeKioskType = "publicBrowsing"
                                    containedAppId = "FakeStringValue"
                                    desktopApplicationId = "FakeStringValue"
                                    desktopApplicationLinkPath = "FakeStringValue"
                                    path = "FakeStringValue"
                                    odataType = "#microsoft.graph.windowsKioskDesktopApp"
                                })
                                apps = @(
                                    ([MSFT_MicrosoftGraphWindowsKioskAppBase] @{
                                        edgeNoFirstRun = $True
                                        name = "FakeStringValue"
                                        edgeKiosk = "FakeStringValue"
                                        classicAppPath = "FakeStringValue"
                                        appId = "FakeStringValue"
                                        appUserModelId = "FakeStringValue"
                                        edgeKioskIdleTimeoutMinutes = 25
                                        autoLaunch = $True
                                        startLayoutTileSize = "hidden"
                                        appType = "unknown"
                                        edgeKioskType = "publicBrowsing"
                                        containedAppId = "FakeStringValue"
                                        desktopApplicationId = "FakeStringValue"
                                        desktopApplicationLinkPath = "FakeStringValue"
                                        path = "FakeStringValue"
                                        odataType = "#microsoft.graph.windowsKioskDesktopApp"
                                    })
                                )
                                allowAccessToDownloadsFolder = $True
                                showTaskBar = $True
                                disallowDesktopApps = $True
                                odataType = "#microsoft.graph.windowsKioskMultipleApps"
                                startMenuLayoutXml = $True
                            })
                        })
                    )
                    windowsKioskForceUpdateSchedule = ([MSFT_MicrosoftGraphwindowsKioskForceUpdateSchedule] @{
                        runImmediatelyIfAfterStartDateTime = $True
                        startDateTime = "2023-01-01T00:00:00.0000000+00:00"
                        dayofMonth = 25
                        recurrence = "none"
                        dayofWeek = "sunday"
                    })
                    Ensure = 'Present'
                    Credential = $Credential;
                }
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneDeviceConfigurationKioskPolicyWindows10' -Property $testParams).Test() | Should -Be $true
            }
        }

        Context -Name "The IntuneDeviceConfigurationKioskPolicyWindows10 exists and values are NOT in the desired state" -Fixture {
            BeforeAll {
                $testParams = @{
                    description = "FakeStringValue"
                    DeviceManagementApplicabilityRuleDeviceMode = @{
                        Name = "FakeStringValue"
                        DeviceMode = "sModeConfiguration" # Updated property
                        RuleType = "include"
                    }
                    DeviceManagementApplicabilityRuleOsEdition = @{
                        Name = "FakeStringValue"
                        OsEditionTypes = @("windows10Professional") # Updated property
                        RuleType = "exclude" # Updated property
                    }
                    DeviceManagementApplicabilityRuleOsVersion = @{
                        Name = "FakeStringValue"
                        MinOSVersion = "10.0.19045.0"
                        MaxOSVersion = "10.0.22631.9999" # Updated property
                        RuleType = "include"
                    }
                    displayName = "FakeStringValue"
                    EdgeKioskEnablePublicBrowsing = $True
                    id = "FakeStringValue"
                    KioskBrowserBlockedUrlExceptions = @("FakeStringValue")
                    KioskBrowserBlockedURLs = @("FakeStringValue")
                    KioskBrowserDefaultUrl = "FakeStringValue"
                    KioskBrowserEnableEndSessionButton = $True
                    KioskBrowserEnableHomeButton = $True
                    KioskBrowserEnableNavigationButtons = $True
                    KioskBrowserRestartOnIdleTimeInMinutes = 7 # Updated property
                    kioskProfiles = @(
                        ([MSFT_MicrosoftGraphwindowsKioskProfile] @{
                            userAccountsConfiguration = @(
                                ([MSFT_MicrosoftGraphWindowsKioskUser] @{
                                    groupId = "FakeStringValue"
                                    userName = "FakeStringValue"
                                    userPrincipalName = "FakeStringValue"
                                    odataType = "#microsoft.graph.windowsKioskActiveDirectoryGroup"
                                    groupName = "FakeStringValue"
                                    userId = "FakeStringValue"
                                    displayName = "FakeStringValue"
                                })
                            )
                            profileName = "FakeStringValue"
                            appConfiguration = ([MSFT_MicrosoftGraphWindowsKioskAppConfiguration] @{
                                uwpApp = ([MSFT_MicrosoftGraphWindowsKioskUWPApp] @{
                                    edgeNoFirstRun = $True
                                    name = "FakeStringValue"
                                    edgeKiosk = "FakeStringValue"
                                    classicAppPath = "FakeStringValue"
                                    appId = "FakeStringValue"
                                    appUserModelId = "FakeStringValue"
                                    edgeKioskIdleTimeoutMinutes = 25
                                    autoLaunch = $True
                                    startLayoutTileSize = "hidden"
                                    appType = "unknown"
                                    edgeKioskType = "publicBrowsing"
                                    containedAppId = "FakeStringValue"
                                    desktopApplicationId = "FakeStringValue"
                                    desktopApplicationLinkPath = "FakeStringValue"
                                    path = "FakeStringValue"
                                    odataType = "#microsoft.graph.windowsKioskDesktopApp"
                                })
                                win32App = ([MSFT_MicrosoftGraphWindowsKioskWin32App] @{
                                    edgeNoFirstRun = $True
                                    name = "FakeStringValue"
                                    edgeKiosk = "FakeStringValue"
                                    classicAppPath = "FakeStringValue"
                                    edgeKioskIdleTimeoutMinutes = 25
                                    appUserModelId = "FakeStringValue"
                                    appId = "FakeStringValue"
                                    autoLaunch = $True
                                    startLayoutTileSize = "hidden"
                                    appType = "unknown"
                                    edgeKioskType = "publicBrowsing"
                                    containedAppId = "FakeStringValue"
                                    desktopApplicationId = "FakeStringValue"
                                    desktopApplicationLinkPath = "FakeStringValue"
                                    path = "FakeStringValue"
                                    odataType = "#microsoft.graph.windowsKioskDesktopApp"
                                })
                                apps = @(
                                    ([MSFT_MicrosoftGraphWindowsKioskAppBase] @{
                                        edgeNoFirstRun = $True
                                        name = "FakeStringValue"
                                        edgeKiosk = "FakeStringValue"
                                        classicAppPath = "FakeStringValue"
                                        appId = "FakeStringValue"
                                        appUserModelId = "FakeStringValue"
                                        edgeKioskIdleTimeoutMinutes = 25
                                        autoLaunch = $True
                                        startLayoutTileSize = "hidden"
                                        appType = "unknown"
                                        edgeKioskType = "publicBrowsing"
                                        containedAppId = "FakeStringValue"
                                        desktopApplicationId = "FakeStringValue"
                                        desktopApplicationLinkPath = "FakeStringValue"
                                        path = "FakeStringValue"
                                        odataType = "#microsoft.graph.windowsKioskDesktopApp"
                                    })
                                )
                                allowAccessToDownloadsFolder = $True
                                showTaskBar = $True
                                disallowDesktopApps = $True
                                odataType = "#microsoft.graph.windowsKioskMultipleApps"
                                startMenuLayoutXml = $True
                            })
                        })
                    )
                    windowsKioskForceUpdateSchedule = ([MSFT_MicrosoftGraphwindowsKioskForceUpdateSchedule] @{
                        runImmediatelyIfAfterStartDateTime = $True
                        startDateTime = "2023-01-01T00:00:00.0000000+00:00"
                        dayofMonth = 25
                        recurrence = "none"
                        dayofWeek = "sunday"
                    })
                    Ensure = 'Present'
                    Credential = $Credential;
                }
            }

            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'IntuneDeviceConfigurationKioskPolicyWindows10' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneDeviceConfigurationKioskPolicyWindows10' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should call the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneDeviceConfigurationKioskPolicyWindows10' -Property $testParams).Set()
                Should -Invoke -CommandName Update-MgBetaDeviceManagementDeviceConfiguration -Exactly 1
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
                $result = Invoke-M365DSCResourceMethod -ResourceName 'IntuneDeviceConfigurationKioskPolicyWindows10' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
