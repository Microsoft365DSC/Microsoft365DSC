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
    -DscResource "IntuneMobileAppsWin32AppWindows10" -GenericStubModule $GenericStubPath
Describe -Name $Global:DscHelper.DescribeHeader -Fixture {
    InModuleScope -ModuleName $Global:DscHelper.ModuleName -ScriptBlock {
        Invoke-Command -ScriptBlock $Global:DscHelper.InitializeScript -NoNewScope
        BeforeAll {

            $secpasswd = ConvertTo-SecureString (New-Guid | Out-String) -AsPlainText -Force
            $Credential = New-Object System.Management.Automation.PSCredential ('tenantadmin@onmicrosoft.com', $secpasswd)

            Mock -ModuleName M365DSCUtil -CommandName Confirm-M365DSCDependencies -MockWith {
            }

            Mock -CommandName Get-MSCloudLoginConnectionProfile -MockWith {
                return @{
                    ResourceUrl = "https://graph.microsoft.com/"
                }
            }

            Mock -CommandName Invoke-MgGraphRequest -MockWith {
                if ($Uri -like "*/relationships")
                {
                    return @{
                        value = @(
                            @{
                                "@odata.type" = "#microsoft.graph.mobileAppDependency"
                                id = "11111111-1111-1111-1111-111111111111"
                                targetId = "11111111-1111-1111-1111-111111111111"
                                targetDisplayName = "FakeStringValue"
                                dependencyType = "autoInstall"
                            }
                        )
                    }
                }

                return $null
            }

            Mock -CommandName Reset-MSCloudLoginConnectionProfileContext -MockWith {
            }

            Mock -CommandName Get-PSSession -MockWith {
            }

            Mock -CommandName Remove-PSSession -MockWith {
            }

            Mock -CommandName Update-DeviceAppManagementAppCategory -MockWith {
            }

            Mock -CommandName Update-DeviceAppManagementPolicyAssignment -MockWith {
            }

            Mock -CommandName Update-MgBetaDeviceAppManagementMobileApp -MockWith {
            }

            Mock -CommandName Invoke-M365DSCIntuneMobileAppInitialUpload -MockWith {
            }

            Mock -CommandName New-MgBetaDeviceAppManagementMobileApp -MockWith {
                return @{
                    '@odata.type' = "#microsoft.graph.win32LobApp"
                    allowedArchitectures = "x86,x64"
                    installCommandLine = "IntuneWinAppUtil.exe -s -t 0"
                    uninstallCommandLine = "IntuneWinAppUtil.exe -s -u -t 0"
                    fileName = "IntuneWinAppUtil.intunewin"
                    installExperience = @{
                        deviceRestartBehavior = "suppress"
                        maxRunTimeInMinutes = 60
                        runAsAccount = "system"
                    }
                    setupFilePath = "IntuneWinAppUtil.exe"
                    minimumSupportedOperatingSystem = @{
                        v8_0 = $False
                        v8_1 = $False
                        v10_0 = $False
                        v10_1607 = $True
                        v10_1703 = $False
                        v10_1709 = $False
                        v10_1803 = $False
                        v10_1809 = $False
                        v10_1903 = $False
                        v10_1909 = $False
                        v10_2004 = $False
                        v10_2H20 = $False
                        v10_21H1 = $False
                    }
                    minimumSupportedWindowsRelease = "1607"
                    msiInformation = @{
                        productCode = "{00000000-0000-0000-0000-000000000000}"
                        productVersion = "1.0.0.0"
                        upgradeCode = "{00000000-0000-0000-0000-000000000000}"
                        requiresReboot = $False
                        packageType = "dualPurpose"
                        productName = "IntuneWinAppUtil"
                        publisher = "FakeStringValue"
                    }
                    displayVersion = "1.0.0.0"
                    allowAvailableUninstall = $False
                    rules = @(
                        @{
                            '@odata.type' = "#microsoft.graph.win32LobAppFileSystemRule"
                            check32BitOn64System = $False
                            operationType = "version"
                            fileOrFolderName = "test.exe"
                            operator = "equal"
                            comparisonValue = "1.0.0.0"
                            path = "C:\Path"
                            ruleType = "detection"
                        }
                        @{
                            '@odata.type' = "#microsoft.graph.win32LobAppFileSystemRule"
                            check32BitOn64System = $False
                            operationType = "exists"
                            fileOrFolderName = "test.exe"
                            operator = "notConfigured"
                            path = "C:\Path"
                            ruleType = "requirement"
                        }
                    )
                    returnCodes = @(
                        @{
                            returnCode = 0
                            type = "success"
                        }
                    )
                    Categories = @(
                        @{
                            Id = "FakeStringValue"
                            DisplayName = "FakeStringValue"
                        }
                    )
                    CommittedContentVersion = "FakeStringValue"
                    DependentAppCount = 25
                    Description = "FakeStringValue"
                    Developer = "FakeStringValue"
                    DisplayName = "FakeStringValue"
                    Id = "FakeStringValue"
                    InformationUrl = "FakeStringValue"
                    IsFeatured = $True
                    LargeIcon = @{
                        Type = "FakeStringValue"
                        Value = "VGVzdA=="
                    }
                    Notes = "FakeStringValue"
                    Owner = "FakeStringValue"
                    PrivacyInformationUrl = "FakeStringValue"
                    Publisher = "FakeStringValue"
                    PublishingState = "notPublished"
                    RoleScopeTagIds = @("FakeStringValue")
                    SupersededAppCount = 25
                    SupersedingAppCount = 25
                    UploadState = 25
                }
            }

            Mock -CommandName Remove-MgBetaDeviceAppManagementMobileApp -MockWith {
            }

            Mock -CommandName Get-MgBetaDeviceAppManagementMobileApp -MockWith {
                return @{
                    '@odata.type' = "#microsoft.graph.win32LobApp"
                    allowedArchitectures = "x86,x64"
                    installCommandLine = "IntuneWinAppUtil.exe -s -t 0"
                    uninstallCommandLine = "IntuneWinAppUtil.exe -s -u -t 0"
                    installExperience = @{
                        deviceRestartBehavior = "suppress"
                        maxRunTimeInMinutes = 60
                        runAsAccount = "system"
                    }
                    fileName = "IntuneWinAppUtil.intunewin"
                    setupFilePath = "IntuneWinAppUtil.exe"
                    minimumSupportedOperatingSystem = @{
                        v8_0 = $False
                        v8_1 = $False
                        v10_0 = $False
                        v10_1607 = $True
                        v10_1703 = $False
                        v10_1709 = $False
                        v10_1803 = $False
                        v10_1809 = $False
                        v10_1903 = $False
                        v10_1909 = $False
                        v10_2004 = $False
                        v10_2H20 = $False
                        v10_21H1 = $False
                    }
                    minimumSupportedWindowsRelease = "1607"
                    msiInformation = @{
                        productCode = "{00000000-0000-0000-0000-000000000000}"
                        productVersion = "1.0.0.0"
                        upgradeCode = "{00000000-0000-0000-0000-000000000000}"
                        requiresReboot = $False
                        packageType = "dualPurpose"
                        productName = "IntuneWinAppUtil"
                        publisher = "FakeStringValue"
                    }
                    displayVersion = "1.0.0.0"
                    allowAvailableUninstall = $False
                    rules = @(
                        @{
                            '@odata.type' = "#microsoft.graph.win32LobAppFileSystemRule"
                            check32BitOn64System = $False
                            operationType = "version"
                            fileOrFolderName = "test.exe"
                            operator = "equal"
                            comparisonValue = "1.0.0.0"
                            path = "C:\Path"
                            ruleType = "detection"
                        }
                        @{
                            '@odata.type' = "#microsoft.graph.win32LobAppFileSystemRule"
                            check32BitOn64System = $False
                            operationType = "exists"
                            fileOrFolderName = "test.exe"
                            operator = "notConfigured"
                            path = "C:\Path"
                            ruleType = "requirement"
                        }
                    )
                    returnCodes = @(
                        @{
                            returnCode = 0
                            type = "success"
                        }
                    )
                    Categories = @(
                        @{
                            Id = "FakeStringValue"
                            DisplayName = "FakeStringValue"
                        }
                    )
                    CommittedContentVersion = "FakeStringValue"
                    DependentAppCount = 25
                    Description = "FakeStringValue"
                    Developer = "FakeStringValue"
                    DisplayName = "FakeStringValue"
                    Id = "FakeStringValue"
                    InformationUrl = "FakeStringValue"
                    IsFeatured = $True
                    LargeIcon = @{
                        Type = "FakeStringValue"
                        Value = "VGVzdA=="
                    }
                    Notes = "FakeStringValue"
                    Owner = "FakeStringValue"
                    PrivacyInformationUrl = "FakeStringValue"
                    Publisher = "FakeStringValue"
                    PublishingState = "notPublished"
                    RoleScopeTagIds = @("FakeStringValue")
                    SupersededAppCount = 25
                    SupersedingAppCount = 25
                    UploadState = 25
                }
            }

            Mock -CommandName New-M365DSCConnection -ModuleName '_Shared' -MockWith {
                return "Credentials"
            }

            Mock -CommandName Wait-M365DSCIntuneMobileAppPublished -MockWith {
            }

            # Mock Write-M365DSCHost to hide output during the tests
            Mock -CommandName Write-M365DSCHost -MockWith {
            }
            $Script:exportedInstance = $null
            $Script:ExportMode = $false

            Mock -CommandName Get-MgBetaDeviceAppManagementMobileAppAssignment -MockWith {
                return @(
                    @{
                        Id = "12345-12345-12345-12345-12345"
                        Intent = "required"
                        Source = "direct"
                        SourceId = "12345-12345-12345-12345-12345"
                        Target = @{
                            "@odata.type" = "#microsoft.graph.groupAssignmentTarget"
                            groupId = "26d60dd1-fab6-47bf-8656-358194c1a49d"
                            "deviceAndAppManagementAssignmentFilterId" = '12345-12345-12345-12345-12345'
                            "deviceAndAppManagementAssignmentFilterType" = "none"
                        }
                        Settings = @{
                            "@odata.type" = "#microsoft.graph.win32LobAppAssignmentSettings"
                            notifications = "showAll"
                            deliveryOptimizationPriority = "notConfigured"
                            restartSettings = @{
                                gracePeriodInMinutes = 1440
                                countdownDisplayBeforeRestartInMinutes = 15
                                restartNotificationSnoozeDurationInMinutes = 240
                            }
                        }
                    }
                )
            }
        }

        # Test contexts
        Context -Name "The IntuneMobileAppsWin32AppWindows10 should exist but it DOES NOT" -Fixture {
            BeforeAll {
                $testParams = @{
                    AllowedArchitectures = @("x86", "x64")
                    Assignments = @(
                        ([MSFT_DeviceManagementWin32MobileAppAssignment] @{
                            Intent = "required"
                            DeviceAndAppManagementAssignmentFilterType = "none"
                            GroupId = "26d60dd1-fab6-47bf-8656-358194c1a49d"
                            DataType = "#microsoft.graph.groupAssignmentTarget"
                            assignmentSettings = ([MSFT_DeviceManagementWin32MobileAppAssignmentSettings] @{
                                Notifications = "showAll"
                                DeliveryOptimizationPriority = "notConfigured"
                                RestartSettings = ([MSFT_DeviceManagementWin32MobileAppAssignmentSettingsRestartSettings] @{
                                    GracePeriodInMinutes = 1440
                                    CountdownDisplayBeforeRestartInMinutes = 15
                                    RestartNotificationSnoozeDurationInMinutes = 240
                                })
                            })
                        })
                    )
                    Categories = @(([MSFT_DeviceManagementMobileAppCategory] @{
                        Id = "FakeStringValue"
                        DisplayName = "FakeStringValue"
                    }))
                    InstallExperience = ([MSFT_MicrosoftGraphWin32LobAppInstallExperience] @{
                        DeviceRestartBehavior = "suppress"
                        MaxRunTimeInMinutes = 60
                    })
                    MsiInformation = ([MSFT_MicrosoftGraphWin32LobAppMsiInformation] @{
                        ProductCode = "{00000000-0000-0000-0000-000000000000}"
                        ProductVersion = "1.0.0.0"
                        UpgradeCode = "{00000000-0000-0000-0000-000000000000}"
                        RequiresReboot = $False
                        PackageType = "dualPurpose"
                        ProductName = "IntuneWinAppUtil"
                        Publisher = "FakeStringValue"
                    })
                    Rules = @(
                        ([MSFT_MicrosoftGraphWin32LobAppRule] @{
                            Path = "C:\Path"
                            FileOrFolderName = "test.exe"
                            OdataType = "FileSystem"
                            RuleType = "requirement"
                            FileSystemOperationType = "exists"
                            Operator = "notConfigured"
                            Check32BitOn64System = $False
                        })
                        ([MSFT_MicrosoftGraphWin32LobAppRule] @{
                            Path = "C:\Path"
                            FileOrFolderName = "test.exe"
                            OdataType = "FileSystem"
                            RuleType = "detection"
                            FileSystemOperationType = "version"
                            Operator = "equal"
                            ComparisonValue = "1.0.0.0"
                        })
                    )
                    ReturnCodes = @(
                        ([MSFT_MicrosoftGraphWin32LobAppReturnCode] @{
                            ReturnCode = 0
                            Type = "success"
                        })
                    )
                    InstallCommandLine = "IntuneWinAppUtil.exe -s -t 0"
                    UninstallCommandLine = "IntuneWinAppUtil.exe -s -u -t 0"
                    FileName = "IntuneWinAppUtil.intunewin"
                    SetupFilePath = "IntuneWinAppUtil.exe"
                    Description = "FakeStringValue"
                    Developer = "FakeStringValue"
                    DisplayName = "FakeStringValue"
                    Id = "FakeStringValue"
                    InformationUrl = "FakeStringValue"
                    IsFeatured = $True
                    LargeIcon = ([MSFT_DeviceManagementMimeContent] @{
                        Type = "FakeStringValue"
                        Value = "VGVzdA==" # Base64 encoded string for "Test"
                    })
                    Notes = "FakeStringValue"
                    Owner = "FakeStringValue"
                    PrivacyInformationUrl = "FakeStringValue"
                    Publisher = "FakeStringValue"
                    RoleScopeTagIds = @("FakeStringValue")
                    Relationships = @(
                        ([MSFT_MicrosoftGraphMobileAppRelationship] @{
                            odataType = "#microsoft.graph.mobileAppDependency"
                            targetId = "11111111-1111-1111-1111-111111111111"
                            targetDisplayName = "FakeStringValue"
                            dependencyType = "autoInstall"
                        })
                    )
                    Ensure = "Present"
                    Credential = $Credential;
                }

                Mock -CommandName Get-MgBetaDeviceAppManagementMobileApp -MockWith {
                    return $null
                }

                Mock -CommandName Get-MgBetaDeviceAppManagementMobileApp -ParameterFilter { -not [System.String]::IsNullOrEmpty($Filter) } -MockWith {
                    return @{
                        '@odata.type' = '#microsoft.graph.win32CatalogApp'
                        id            = 'FakeStringValue'
                        displayName   = 'FakeStringValue'
                    }
                }
            }
            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'IntuneMobileAppsWin32AppWindows10' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Absent'
                Should -Invoke -CommandName Get-MgBetaDeviceAppManagementMobileApp -ParameterFilter { $Filter -eq "DisplayName eq 'FakeStringValue'" }
            }
            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneMobileAppsWin32AppWindows10' -Property $testParams).Test() | Should -Be $false
            }
            It 'Should Create the group from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneMobileAppsWin32AppWindows10' -Property $testParams).Set()
                Should -Invoke -CommandName New-MgBetaDeviceAppManagementMobileApp -Exactly 1
                Should -Invoke -CommandName Wait-M365DSCIntuneMobileAppPublished -Exactly 1
            }
        }

        Context -Name "The IntuneMobileAppsWin32AppWindows10 exists but it SHOULD NOT" -Fixture {
            BeforeAll {
                $testParams = @{
                    AllowedArchitectures = @("x86", "x64")
                    Assignments = @(
                        ([MSFT_DeviceManagementWin32MobileAppAssignment] @{
                            Intent = "required"
                            DeviceAndAppManagementAssignmentFilterType = "none"
                            GroupId = "26d60dd1-fab6-47bf-8656-358194c1a49d"
                            DataType = "#microsoft.graph.groupAssignmentTarget"
                            assignmentSettings = ([MSFT_DeviceManagementWin32MobileAppAssignmentSettings] @{
                                Notifications = "showAll"
                                DeliveryOptimizationPriority = "notConfigured"
                                RestartSettings = ([MSFT_DeviceManagementWin32MobileAppAssignmentSettingsRestartSettings] @{
                                    GracePeriodInMinutes = 1440
                                    CountdownDisplayBeforeRestartInMinutes = 15
                                    RestartNotificationSnoozeDurationInMinutes = 240
                                })
                            })
                        })
                    )
                    Categories = @(([MSFT_DeviceManagementMobileAppCategory] @{
                        Id = "FakeStringValue"
                        DisplayName = "FakeStringValue"
                    }))
                    InstallExperience = ([MSFT_MicrosoftGraphWin32LobAppInstallExperience] @{
                        DeviceRestartBehavior = "suppress"
                        MaxRunTimeInMinutes = 60
                    })
                    MsiInformation = ([MSFT_MicrosoftGraphWin32LobAppMsiInformation] @{
                        ProductCode = "{00000000-0000-0000-0000-000000000000}"
                        ProductVersion = "1.0.0.0"
                        UpgradeCode = "{00000000-0000-0000-0000-000000000000}"
                        RequiresReboot = $False
                        PackageType = "dualPurpose"
                        ProductName = "IntuneWinAppUtil"
                        Publisher = "FakeStringValue"
                    })
                    Rules = @(
                        ([MSFT_MicrosoftGraphWin32LobAppRule] @{
                            Path = "C:\Path"
                            FileOrFolderName = "test.exe"
                            OdataType = "FileSystem"
                            RuleType = "requirement"
                            FileSystemOperationType = "exists"
                            Operator = "notConfigured"
                            Check32BitOn64System = $False
                        })
                        ([MSFT_MicrosoftGraphWin32LobAppRule] @{
                            Path = "C:\Path"
                            FileOrFolderName = "test.exe"
                            OdataType = "FileSystem"
                            RuleType = "detection"
                            FileSystemOperationType = "version"
                            Operator = "equal"
                            ComparisonValue = "1.0.0.0"
                        })
                    )
                    ReturnCodes = @(
                        ([MSFT_MicrosoftGraphWin32LobAppReturnCode] @{
                            ReturnCode = 0
                            Type = "success"
                        })
                    )
                    InstallCommandLine = "IntuneWinAppUtil.exe -s -t 0"
                    UninstallCommandLine = "IntuneWinAppUtil.exe -s -u -t 0"
                    FileName = "IntuneWinAppUtil.intunewin"
                    SetupFilePath = "IntuneWinAppUtil.exe"
                    Description = "FakeStringValue"
                    Developer = "FakeStringValue"
                    DisplayName = "FakeStringValue"
                    Id = "FakeStringValue"
                    InformationUrl = "FakeStringValue"
                    IsFeatured = $True
                    LargeIcon = ([MSFT_DeviceManagementMimeContent] @{
                        Type = "FakeStringValue"
                        Value = "VGVzdA==" # Base64 encoded string for "Test"
                    })
                    Notes = "FakeStringValue"
                    Owner = "FakeStringValue"
                    PrivacyInformationUrl = "FakeStringValue"
                    Publisher = "FakeStringValue"
                    RoleScopeTagIds = @("FakeStringValue")
                    Relationships = @(
                        ([MSFT_MicrosoftGraphMobileAppRelationship] @{
                            odataType = "#microsoft.graph.mobileAppDependency"
                            targetId = "11111111-1111-1111-1111-111111111111"
                            targetDisplayName = "FakeStringValue"
                            dependencyType = "autoInstall"
                        })
                    )
                    Ensure = "Absent"
                    Credential = $Credential;
                }
            }

            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'IntuneMobileAppsWin32AppWindows10' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneMobileAppsWin32AppWindows10' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should Remove the group from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneMobileAppsWin32AppWindows10' -Property $testParams).Set()
                Should -Invoke -CommandName Remove-MgBetaDeviceAppManagementMobileApp -Exactly 1
            }
        }

        Context -Name "The IntuneMobileAppsWin32AppWindows10 Exists and Values are already in the desired state" -Fixture {
            BeforeAll {
                $testParams = @{
                    AllowedArchitectures = @("x86", "x64")
                    Assignments = @(
                        ([MSFT_DeviceManagementWin32MobileAppAssignment] @{
                            Intent = "required"
                            DeviceAndAppManagementAssignmentFilterType = "none"
                            GroupId = "26d60dd1-fab6-47bf-8656-358194c1a49d"
                            DataType = "#microsoft.graph.groupAssignmentTarget"
                            assignmentSettings = ([MSFT_DeviceManagementWin32MobileAppAssignmentSettings] @{
                                Notifications = "showAll"
                                DeliveryOptimizationPriority = "notConfigured"
                                RestartSettings = ([MSFT_DeviceManagementWin32MobileAppAssignmentSettingsRestartSettings] @{
                                    GracePeriodInMinutes = 1440
                                    CountdownDisplayBeforeRestartInMinutes = 15
                                    RestartNotificationSnoozeDurationInMinutes = 240
                                })
                            })
                        })
                    )
                    Categories = @(([MSFT_DeviceManagementMobileAppCategory] @{
                        Id = "FakeStringValue"
                        DisplayName = "FakeStringValue"
                    }))
                    InstallExperience = ([MSFT_MicrosoftGraphWin32LobAppInstallExperience] @{
                        DeviceRestartBehavior = "suppress"
                        MaxRunTimeInMinutes = 60
                    })
                    MsiInformation = ([MSFT_MicrosoftGraphWin32LobAppMsiInformation] @{
                        ProductCode = "{00000000-0000-0000-0000-000000000000}"
                        ProductVersion = "1.0.0.0"
                        UpgradeCode = "{00000000-0000-0000-0000-000000000000}"
                        RequiresReboot = $False
                        PackageType = "dualPurpose"
                        ProductName = "IntuneWinAppUtil"
                        Publisher = "FakeStringValue"
                    })
                    Rules = @(
                        ([MSFT_MicrosoftGraphWin32LobAppRule] @{
                            Path = "C:\Path"
                            FileOrFolderName = "test.exe"
                            OdataType = "FileSystem"
                            RuleType = "requirement"
                            FileSystemOperationType = "exists"
                            Operator = "notConfigured"
                            Check32BitOn64System = $False
                        })
                        ([MSFT_MicrosoftGraphWin32LobAppRule] @{
                            Path = "C:\Path"
                            FileOrFolderName = "test.exe"
                            OdataType = "FileSystem"
                            RuleType = "detection"
                            FileSystemOperationType = "version"
                            Operator = "equal"
                            ComparisonValue = "1.0.0.0"
                        })
                    )
                    ReturnCodes = @(
                        ([MSFT_MicrosoftGraphWin32LobAppReturnCode] @{
                            ReturnCode = 0
                            Type = "success"
                        })
                    )
                    InstallCommandLine = "IntuneWinAppUtil.exe -s -t 0"
                    UninstallCommandLine = "IntuneWinAppUtil.exe -s -u -t 0"
                    FileName = "IntuneWinAppUtil.intunewin"
                    SetupFilePath = "IntuneWinAppUtil.exe"
                    Description = "FakeStringValue"
                    Developer = "FakeStringValue"
                    DisplayName = "FakeStringValue"
                    Id = "FakeStringValue"
                    InformationUrl = "FakeStringValue"
                    IsFeatured = $True
                    LargeIcon = ([MSFT_DeviceManagementMimeContent] @{
                        Type = "FakeStringValue"
                        Value = "VGVzdA==" # Base64 encoded string for "Test"
                    })
                    Notes = "FakeStringValue"
                    Owner = "FakeStringValue"
                    PrivacyInformationUrl = "FakeStringValue"
                    Publisher = "FakeStringValue"
                    RoleScopeTagIds = @("FakeStringValue")
                    Relationships = @(
                        ([MSFT_MicrosoftGraphMobileAppRelationship] @{
                            odataType = "#microsoft.graph.mobileAppDependency"
                            targetId = "11111111-1111-1111-1111-111111111111"
                            targetDisplayName = "FakeStringValue"
                            dependencyType = "autoInstall"
                        })
                    )
                    Ensure = "Present"
                    Credential = $Credential;
                }
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneMobileAppsWin32AppWindows10' -Property $testParams).Test() | Should -Be $true
            }
        }

        Context -Name "The IntuneMobileAppsWin32AppWindows10 exists and values are NOT in the desired state" -Fixture {
            BeforeAll {
                $testParams = @{
                    AllowedArchitectures = @("x86", "x64")
                    Assignments = @(
                        ([MSFT_DeviceManagementWin32MobileAppAssignment] @{
                            Intent = "required"
                            DeviceAndAppManagementAssignmentFilterType = "none"
                            GroupId = "26d60dd1-fab6-47bf-8656-358194c1a49d"
                            DataType = "#microsoft.graph.groupAssignmentTarget"
                            assignmentSettings = ([MSFT_DeviceManagementWin32MobileAppAssignmentSettings] @{
                                Notifications = "showAll"
                                DeliveryOptimizationPriority = "notConfigured"
                                RestartSettings = ([MSFT_DeviceManagementWin32MobileAppAssignmentSettingsRestartSettings] @{
                                    GracePeriodInMinutes = 1440
                                    CountdownDisplayBeforeRestartInMinutes = 30 # Drift
                                    RestartNotificationSnoozeDurationInMinutes = 240
                                })
                            })
                        })
                    )
                    Categories = @(([MSFT_DeviceManagementMobileAppCategory] @{
                        Id = "FakeStringValue"
                        DisplayName = "FakeStringValue"
                    }))
                    InstallExperience = ([MSFT_MicrosoftGraphWin32LobAppInstallExperience] @{
                        DeviceRestartBehavior = "suppress"
                        MaxRunTimeInMinutes = 60
                    })
                    MsiInformation = ([MSFT_MicrosoftGraphWin32LobAppMsiInformation] @{
                        ProductCode = "{00000000-0000-0000-0000-000000000000}"
                        ProductVersion = "1.0.0.0"
                        UpgradeCode = "{00000000-0000-0000-0000-000000000000}"
                        RequiresReboot = $False
                        PackageType = "dualPurpose"
                        ProductName = "IntuneWinAppUtil"
                        Publisher = "FakeStringValue"
                    })
                    Rules = @(
                        ([MSFT_MicrosoftGraphWin32LobAppRule] @{
                            Path = "C:\Path"
                            FileOrFolderName = "test.exe"
                            OdataType = "FileSystem"
                            RuleType = "requirement"
                            FileSystemOperationType = "exists"
                            Operator = "notConfigured"
                            Check32BitOn64System = $False
                        })
                        ([MSFT_MicrosoftGraphWin32LobAppRule] @{
                            Path = "C:\Path"
                            FileOrFolderName = "test.exe"
                            OdataType = "FileSystem"
                            RuleType = "detection"
                            FileSystemOperationType = "version"
                            Operator = "equal"
                            ComparisonValue = "1.0.0.0"
                        })
                    )
                    ReturnCodes = @(
                        ([MSFT_MicrosoftGraphWin32LobAppReturnCode] @{
                            ReturnCode = 0
                            Type = "success"
                        })
                    )
                    InstallCommandLine = "IntuneWinAppUtil.exe -s -t 0"
                    UninstallCommandLine = "IntuneWinAppUtil.exe -s -u -t 0"
                    FileName = "IntuneWinAppUtil.intunewin"
                    SetupFilePath = "IntuneWinAppUtil.exe"
                    Description = "FakeStringValue"
                    Developer = "FakeStringValue"
                    DisplayName = "FakeStringValue"
                    Id = "FakeStringValue"
                    InformationUrl = "FakeStringValue"
                    IsFeatured = $True
                    LargeIcon = ([MSFT_DeviceManagementMimeContent] @{
                        Type = "FakeStringValue"
                        Value = "VGVzdA==" # Base64 encoded string for "Test"
                    })
                    Notes = "FakeStringValue"
                    Owner = "FakeStringValue"
                    PrivacyInformationUrl = "FakeStringValue"
                    Publisher = "FakeStringValue"
                    RoleScopeTagIds = @("FakeStringValue")
                    Relationships = @(
                        ([MSFT_MicrosoftGraphMobileAppRelationship] @{
                            odataType = "#microsoft.graph.mobileAppDependency"
                            targetId = "11111111-1111-1111-1111-111111111111"
                            targetDisplayName = "FakeStringValue"
                            dependencyType = "autoInstall"
                        })
                    )
                    Ensure = "Present"
                    Credential = $Credential;
                }
            }

            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'IntuneMobileAppsWin32AppWindows10' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneMobileAppsWin32AppWindows10' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should call the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneMobileAppsWin32AppWindows10' -Property $testParams).Set()
                Should -Invoke -CommandName Update-MgBetaDeviceAppManagementMobileApp -Exactly 1
            }

            It 'Should post the relationships to the updateRelationships action from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneMobileAppsWin32AppWindows10' -Property $testParams).Set()
                Should -Invoke -CommandName Invoke-MgGraphRequest -Exactly 1 -ParameterFilter {
                    $Method -eq 'POST' -and
                    $Uri -like '*/mobileApps/FakeStringValue/updateRelationships' -and
                    $Body -like '*#microsoft.graph.mobileAppDependency*' -and
                    $Body -like '*11111111-1111-1111-1111-111111111111*' -and
                    $Body -like '*autoInstall*'
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
                $result = Invoke-M365DSCResourceMethod -ResourceName 'IntuneMobileAppsWin32AppWindows10' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
